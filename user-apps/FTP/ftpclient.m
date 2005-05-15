/*
 Project: FTP

 Copyright (C) 2005 Riccardo Mottola

 Author: Riccardo Mottola

 Created: 2005-03-30

 FTP client class

 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.

 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

 */
 
#import "ftpclient.h"
#import "AppController.h"
#import "fileElement.h"

#include <arpa/inet.h>  /* for inet_ntoa and similar */
#include <netdb.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>


#define MAX_CONTROL_BUFF 2048
#define MAX_DATA_BUFF 2048

@implementation ftpclient

/* initializer */
/* we set possibly unused stuff to NULL */
- (id)init
{
    if (!(self =[super init]))
        return nil;
    controller = NULL;
    return self;
}

- (id)initWithController:(id)cont
{
    if (!(self =[super init]))
        return nil;
    controller = cont;
    usesPassive = NO;
    usesPorts = YES;
    return self;
}

/*
 changes the current working directory
 this directory is implicit in many other actions
 */
- (void)changeWorkingDir:(NSString *)dir
{
    char            tempStr[MAX_CONTROL_BUFF];
    char            tempStr2[MAX_CONTROL_BUFF];
    NSMutableArray *reply;

    [dir getCString:tempStr2];
    sprintf(tempStr, "CWD %s\r\n", tempStr2);
    [self writeLine:tempStr];
    if ([self readReply:&reply] == 250)
    {
        NSLog(@"successful cwd");
        [super changeWorkingDir:dir];
    }
}

/* if we have a valid controller, we suppose it respons to appendTextToLog */
/* RM: is there a better way to append a newline? */
- (void)logIt:(NSString *)str
{
    NSMutableString *tempStr;
    
    if (controller == NULL)
        return;
    tempStr = [NSMutableString stringWithCapacity:([str length] + 1)];
    [tempStr appendString:str];
    [tempStr appendString:@"\n"];
    [controller appendTextToLog:tempStr];
}


/*
 read the reply of a command, be it single or multi-line
 returned is the first numerical code
 NOTE: the parser is NOT robust in handling errors
 */
- (int)readReply :(NSMutableArray **)result
{
    char  buff[MAX_CONTROL_BUFF];
    int   readBytes;
    int   ch;
    /* the first numerical code, in case of multi-line output it is followed
       by '-' in the first line and by ' ' in the last line */
    char  numCodeStr[4];
    int   numCode;
    int   startNumCode;
    char  separator;
    enum  states { N1, N2, N3, SEPARATOR, CHARS, GOTR, END };
    enum  states state;
    BOOL  multiline;

    readBytes = 0;
    state = N1;
    separator = 0;
    multiline = NO;
    *result = [NSMutableArray arrayWithCapacity:1];


    while (!(state == END))
    {
        ch = getc(controlInStream);
        switch (state)
        {
            case N1:
                buff[readBytes] = ch;
                numCodeStr[readBytes] = ch;
                readBytes++;
                if (ch == ' ') /* skip internal lines of multi-line */
                    state = CHARS;
                else
                    state = N2;
                break;
            case N2:
                buff[readBytes] = ch;
                numCodeStr[readBytes] = ch;
                readBytes++;
                state = N3;
                break;
            case N3:
                buff[readBytes] = ch;
                numCodeStr[readBytes] = ch;
                readBytes++;
                state = SEPARATOR;
                break;
            case SEPARATOR:
                buff[readBytes] = ch;
                numCodeStr[readBytes] = '\0';
                readBytes++;
                numCode = atoi(numCodeStr);
                separator = ch;
                state = CHARS;
                break;
            case CHARS:
                if (ch == '\r')
                    state = GOTR;
                else
                {
                    buff[readBytes++] = ch;
                }
                break;
            case GOTR:
                if (ch == '\n')
                {
                    buff[readBytes] = '\0';
                    [self logIt:[NSString stringWithCString:buff]];
                    [*result addObject:[NSString stringWithCString:buff]];
                    readBytes = 0;
                    if (separator == ' ')
                    {
                        if (multiline)
                        {
                            if (numCode == startNumCode)
                                state = END;
                        } else
                        {
                            startNumCode = numCode;
                            state = END;
                        }
                    } else
                    {
                        startNumCode = numCode;
                        multiline = YES;
                        state = N1;
                    }
                }
                break;
            default:
                NSLog(@"Duh, a case default in the readReply parser");
        }
    }
    [*result retain];
    return startNumCode;
}

/*
 writes a single line to the control connection
 */
- (int)writeLine:(char *)line
{
    int sentBytes;
    int bytesToSend;
    
    bytesToSend = strlen(line);
    [self logIt:[NSString stringWithCString:line length:(bytesToSend - 2)]];
    if ((sentBytes = send(controlSocket, line, strlen(line), 0)) < bytesToSend)
        NSLog(@"sent %d out of %d", sentBytes, bytesToSend);
    return sentBytes;
}

- (int)setTypeToI
{
    NSMutableArray *reply;
    
    [self writeLine:"TYPE I\r\n"];
    [self readReply:&reply];
    [reply release];
    return 0;
}

- (int)setTypeToA
{
    NSMutableArray *reply;

    [self writeLine:"TYPE A\r\n"];
    [self readReply:&reply];
    [reply release];
    return 0;
}

- (void)retrieveFile:(fileElement *)file to:(localclient *)localClient beingAt:(int)depth
{
    NSString           *fileName;
    unsigned long long fileSize;
    char               fNameCStr[MAX_CONTROL_BUFF];
    char               command[MAX_CONTROL_BUFF];
    NSFileHandle       *remoteFileHandle;
    NSFileHandle       *localFileHandle;
    NSMutableArray     *reply;
    NSData             *dataBuff;
    int                localSocket;
    struct sockaddr    from;
    int                fromLen;
    int                replyCode;
    NSFileManager      *localFm;
    unsigned           chunkLen;
    unsigned           totalBytes;
    NSString           *pristineLocalPath; /* original path */
    NSString           *pristineRemotePath; /* original path */
    NSString           *localPath;

    fromLen = sizeof(from);

    fileName = [file filename];
    fileSize = [file size];
    pristineLocalPath = [localClient workingDir];
    localPath = [pristineLocalPath stringByAppendingPathComponent:fileName];
    pristineRemotePath = [self workingDir];

    if ([file isDir])
    {
        NSArray      *dirList;
        NSString     *remoteDir;
        NSEnumerator *en;
        fileElement  *fEl;

        if (depth > 3)
        {
            NSLog(@"Max depth reached: %d", depth);
            return;
        }
        
        NSLog(@"it is a dir: %@", fileName);
        remoteDir = [[self workingDir] stringByAppendingPathComponent:fileName];
        NSLog(@"from %@ to %@", [self workingDir], remoteDir);
        [self changeWorkingDir:remoteDir];
        NSLog(@"remote dir changed: %@", [self workingDir]);

        if ([localClient createNewDir:localPath] == YES)
        {
            [localClient changeWorkingDir:localPath];
    
            dirList = [self dirContents];
            en = [dirList objectEnumerator];
            while (fEl = [en nextObject])
            {
                NSLog(@"recurse, download : %@", [fEl filename]);
                [self retrieveFile:fEl to:localClient beingAt:(depth+1)];
            }
        }
        /* we get back were we started */
        [self changeWorkingDir:pristineRemotePath];
        return;
    }

    /* lets settle to a plain binary standard type */
    [self setTypeToI];
    
    if ([self initDataConn] < 0)
    {
        NSLog(@"error initiating data connection, retrieveFile");
        return;
    }
    
    [fileName getCString:fNameCStr];
    sprintf(command, "RETR %s\r\n", fNameCStr);
    [self writeLine:command];
    replyCode = [self readReply:&reply];
    NSLog(@"%d reply is %@: ", replyCode, [reply objectAtIndex:0]);

    if(replyCode != 150)
        return; /* we have an error or some unexpected condition */
    
    [reply release];
    if ((localSocket = accept(dataSocket, &from, &fromLen)) < 0)
    {
        perror("accepting socket, retrieveFile: ");
    }

    NSLog(@"opened socket");

    localFm = [NSFileManager defaultManager];

    if ([localFm fileExistsAtPath:localPath] == NO)
    {
        NSLog(@"File does not exist");
        if ([localFm createFileAtPath:localPath contents:[NSData data] attributes:nil] == NO)
        {
            NSLog(@"local file creation error");
            [self closeDataConn];
            return;
        }
    } else
    {
        NSLog(@"File exists...");
    }

    localFileHandle = [NSFileHandle fileHandleForWritingAtPath:localPath];
    if(localFileHandle == nil)
    {
        NSLog(@"no file exists");
        [self closeDataConn];
        return;
    }
    remoteFileHandle = [[NSFileHandle alloc] initWithFileDescriptor: localSocket];


    totalBytes = 0;
    chunkLen = 0;
    [controller setProgress:0];
    [controller setStatusInfo:fileName];
    dataBuff = [remoteFileHandle availableData];
    while (chunkLen = [dataBuff length])
    {
        totalBytes += chunkLen;
        [controller setProgress:(((float)totalBytes / fileSize) * 100)];
        [localFileHandle writeData:dataBuff];
        dataBuff = [remoteFileHandle availableData];
//        NSLog(@"chunk %u", chunkLen);
    }
    [controller setProgress:(((float)totalBytes / fileSize) * 100)];
    
    NSLog(@"transferred %u", totalBytes);
    close(localSocket);
    [self closeDataConn];
    [self readReply:&reply];
    [reply release];
}

- (void)storeFile:(fileElement *)file from:(localclient *)localClient beingAt:(int)depth
{
    NSString           *fileName;
    unsigned long long fileSize;
    char               fNameCStr[MAX_CONTROL_BUFF];
    char               command[MAX_CONTROL_BUFF];
    NSFileHandle       *remoteFileHandle;
    NSFileHandle       *localFileHandle;
    NSMutableArray     *reply;
    NSData             *dataBuff;
    int                localSocket;
    struct sockaddr    from;
    int                fromLen;
    int                replyCode;
    unsigned           chunkLen;
    unsigned           totalBytes;
    unsigned int       blockSize;
    NSString           *pristinePath; /* original path */
    NSString           *localPath;

    fromLen = sizeof(from);

    fileName = [file filename];
    fileSize = [file size];
    pristinePath = [localClient workingDir];
    localPath = [localPath stringByAppendingPathComponent:fileName];


    if ([file isDir])
    {
        NSLog(@"it is a dir: %@", fileName);
        return;
    }
    
    /* lets settle to a plain binary standard type */
    [self setTypeToI];

    if ([self initDataConn] < 0)
    {
        NSLog(@"error initiating data connection, retrieveFile");
        return;
    }

    [fileName getCString:fNameCStr];
    sprintf(command, "STOR %s\r\n", fNameCStr);
    [self writeLine:command];
    replyCode = [self readReply:&reply];
    NSLog(@"%d reply is %@: ", replyCode, [reply objectAtIndex:0]);
    [reply release];
    if ((localSocket = accept(dataSocket, &from, &fromLen)) < 0)
    {
        perror("accepting socket, storeFile: ");
    }

    NSLog(@"opened socket");

    localFileHandle = [NSFileHandle fileHandleForReadingAtPath:localPath];
    if(localFileHandle == nil)
    {
        NSLog(@"no file exists");
        [self closeDataConn];
        return;
    }
    remoteFileHandle = [[NSFileHandle alloc] initWithFileDescriptor: localSocket];


    totalBytes = 0;
    chunkLen = 0;
    blockSize = fileSize / 100;
    if (blockSize < 10240)
        blockSize = 10240;
    [controller setProgress:0];
    dataBuff = [localFileHandle readDataOfLength:blockSize];
    while (chunkLen = [dataBuff length])
    {
        totalBytes += chunkLen;
        [controller setProgress:(((float)totalBytes / fileSize) * 100)];
        [remoteFileHandle writeData:dataBuff];
        dataBuff = [localFileHandle readDataOfLength:blockSize];
        NSLog(@"chunk %u", chunkLen);
    }
    [controller setProgress:(((float)totalBytes / fileSize) * 100)];
    
    NSLog(@"transferred %u", totalBytes);
    close(localSocket);
    [self closeDataConn];
    [self readReply:&reply];
    [reply release];
}



/* initialize a connection */
/* set up and connect the control socket */
- (int)connect:(int)port :(char *)server
{
    struct hostent      *hostentPtr;
    char                *tempStr;
    int                 addrLen; /* socklen_t on some systems? */
    NSMutableArray      *reply;

    NSLog(@"connect to %s : %d", server, port);

    if((hostentPtr = gethostbyname(server)) == NULL)
    {
        NSLog(@"Could not resolve %s", server);
        return ERR_COULDNT_RESOLVE;
    }
    bcopy((char *)hostentPtr->h_addr, (char *)&remoteSockName.sin_addr, hostentPtr->h_length);
    remoteSockName.sin_family = PF_INET;
    remoteSockName.sin_port = htons(port);

    tempStr = inet_ntoa(remoteSockName.sin_addr);

    if ((controlSocket = socket(PF_INET, SOCK_STREAM, 0)) < 0)
    {
        perror("socket failed: ");
        return ERR_SOCKET_FAIL;
    }
    if (connect(controlSocket, (struct sockaddr*) &remoteSockName, sizeof(remoteSockName)) < 0)
    {
        perror("connect failed: ");
        return ERR_CONNECT_FAIL;
    }

    /* we retrieve now the local name of the created socked */
    /* the local port is for example important as default data port */
    addrLen = sizeof(localSockName);
    if (getsockname(controlSocket, (struct sockaddr *)&localSockName, &addrLen) < 0)
    {
        perror("ftpclient: getsockname");
        return ERR_GESOCKNAME_FAIL;
    }
    
    controlInStream = fdopen(controlSocket, "r");
    [self readReply :&reply];
    [reply release];
    return 0;
}

- (void)disconnect
{
    NSMutableArray *reply;
    
    [self writeLine:"QUIT\r\n"];
    [self readReply:&reply];
}

- (int)authenticate:(char *)user :(char *)pass
{
    char           tempStr[MAX_CONTROL_BUFF];
    NSMutableArray *reply;
    int            replyCode;

    sprintf(tempStr, "USER %s\r\n", user);
    [self writeLine:tempStr];
    [self readReply:&reply];
    NSLog(@"user reply is: %@", [reply objectAtIndex:0]);
    [reply release];
    
    sprintf(tempStr, "PASS %s\r\n", pass);
    [self writeLine:tempStr];
    replyCode = [self readReply:&reply];
    NSLog(@"pass reply is: %@", [reply objectAtIndex:0]);
    if (replyCode == 530)
    {
        NSLog(@"Not logged in: %@", [reply objectAtIndex:0]);
        [self disconnect];
        return -1;
    }
    [reply release];

    /* get home directory as dir we first connected to */
    [self writeLine:"PWD\r\n"];
    [self readReply:&reply];
    if ([reply count] >= 1)
    {
        NSString *line;
        unsigned int length;
        unsigned int first;
        unsigned int last;
        unsigned int i;
        
        line = [reply objectAtIndex:0];
        NSLog(@"pwd reply is: %@", line);
        length = [line length];
        i = 0;
        while (i < length && ([line characterAtIndex:i] != '\"'))
            i++;
        first = i;
        if (first < length)
        {
            first++;
            i = length-1;
            while (i > 0 &&  ([line characterAtIndex:i] != '\"'))
                i--;
            last = i;
            homeDir = [[line substringWithRange: NSMakeRange(first, last-first)] retain];
            NSLog(@"homedir: %@", homeDir);
        } else
            homeDir = nil;
    }
    return 0;
}

/* initialize the data connection */
- (int)initDataConn
{
    int addrLen; /* socklen_t on some systems ? */
    int socketReuse;
    
    socketReuse = YES;

    /* passive mode */
    if (usesPassive)
    {
        return 0;
    }

    /* active mode, default or PORT arbitrated */
    dataSockName = localSockName;
    
    if (usesPorts)
        dataSockName.sin_port = 0;
    
    if ((dataSocket = socket(AF_INET, SOCK_STREAM, 0)) < 0)
    {
        perror("socket in initDataConn");
        return -1;
    }

    /* if we use the default port, we set the option to reuse the port */
    /* linux is happier if we set both ends that way */
    if (!usesPorts)
    {
        if (setsockopt(dataSocket, SOL_SOCKET, SO_REUSEADDR, &socketReuse, sizeof (socketReuse)) < 0)
        {
            perror("ftpclient: setsockopt (reuse address) on data");
        }
        if (setsockopt(controlSocket, SOL_SOCKET, SO_REUSEADDR, &socketReuse, sizeof (socketReuse)) < 0)
        {
            perror("ftpclient: setsockopt (reuse address) on control");
        }
    }
    
    if (bind(dataSocket, (struct sockaddr *)&dataSockName, sizeof (dataSockName)) < 0)
    {
        perror("ftpclient: bind");
        return -1;
    }

    addrLen = sizeof (dataSockName);
    if (getsockname(dataSocket, (struct sockaddr *)&dataSockName, &addrLen) < 0)
    {
        perror("ftpclient: getsockname");
        return -1;
    }
    
    if (listen(dataSocket, 1) < 0)
    {
        perror("ftpclient: listen");
        return -1;
    }

    if (usesPorts)
    {
        union addrAccess { /* we use this union to extract the 8 bytes of an address */
            struct in_addr   sinAddr;
            unsigned char    ipv4[4];
        } addr;
        NSMutableArray *reply;
        char           tempStr[128];
        unsigned char  p1, p2;
        int            returnCode;
        unsigned int   port;


        addr.sinAddr = dataSockName.sin_addr;
        port = ntohs(dataSockName.sin_port);
        p1 = (port & 0xFF00) >> 8;
        p2 = port & 0x00FF;
        sprintf(tempStr, "PORT %u,%u,%u,%u,%u,%u\r\n", addr.ipv4[0], addr.ipv4[1], addr.ipv4[2], addr.ipv4[3], p1, p2);
        [self writeLine:tempStr];
        if ((returnCode = [self readReply:&reply]) != 200)
        {
            NSLog(@"error occoured in port command: %@", reply);
            return -1;
        }
    }
    return 0;
}

- (int)closeDataConn
{
    close (dataSocket);
    return 0;
}

/*
 creates a new directory
 tries to guess if the given dir is relative (no starting /) or absolute
 Is this portable to non-unix OS's?
 */
- (BOOL)createNewDir:(NSString *)dir
{
    NSFileManager *fm;
    NSString      *localPath;

    if (NO == NO)
        return NO;
    else
        return YES;
}


/* RM again: a better path limit is needed */
- (NSArray *)dirContents
{
    int                ch;
    FILE               *dataStream;
    int                localSocket;
    struct sockaddr    from;
    int                fromLen;
    char               buff[MAX_DATA_BUFF];
    int                readBytes;
    enum               states_m1 { READ, GOTR };
    enum               states_m1 state;
    NSMutableArray     *listArr;
    fileElement        *aFile;
    char               path[4096];
    NSMutableArray     *reply;

    [workingDir getCString:path];

    /* lets settle to a plain ascii standard type */
    [self setTypeToA];
    
    /* create an array with a reasonable starting size */
    listArr = [NSMutableArray arrayWithCapacity:5];
    
    [self initDataConn];
    [self writeLine:"LIST\r\n"];
    [self readReply:&reply];

    fromLen = sizeof(from);
    if ((localSocket = accept(dataSocket, &from, &fromLen)) < 0)
    {
        perror("accepting socket, dir list: ");
    }
    dataStream = fdopen(localSocket, "r");
    if (dataStream == NULL)
    {
        perror("data stream opening failed");
        return NULL;
    }
    NSLog(@"data stream open");
    
    /* read the directory listing, each line being CR-LF terminated */
    state = READ;
    readBytes = 0;
    while ((ch = getc(dataStream)) != EOF)
    {
        if (ch == '\r')
            state = GOTR;
        else if (ch == '\n' && state == GOTR)
        {
            
            buff[readBytes] = '\0';
            fprintf(stderr, "%s\n", buff);
            state = READ; /* reset the state for a new line */
            readBytes = 0;
            aFile = [[fileElement alloc] initWithLsLine:buff];
            if (aFile)
                [listArr addObject:aFile];
        } else
            buff[readBytes++] = ch;
    }
    if (ferror(dataStream))
    {
        perror("error in reading data stream: ");
    } else if (feof(dataStream))
    {
         fprintf(stderr, "feof\n");
    }
    fclose (dataStream);
    [self closeDataConn];
    [self readReply:&reply];
    return [NSArray arrayWithArray:listArr];
}

@end
