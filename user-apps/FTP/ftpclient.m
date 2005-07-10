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
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

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
#include <time.h>


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
    usesPassive = YES;
    usesPorts = NO;
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
        [super changeWorkingDir:dir];
    else
        NSLog(@"cwd failed");
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
    char               buff[MAX_DATA_BUFF];
    FILE               *localFileStream;
    int                bytesRead;
    NSMutableArray     *reply;
    struct sockaddr    from;
    int                fromLen;
    int                replyCode;
    unsigned long long totalBytes;
    NSString           *localPath;
    BOOL               gotFile;

    fromLen = sizeof(from);

    NSLog(@"filesize should be %u", (unsigned)[file size]);
    fileName = [file filename];
    fileSize = [file size];
    localPath = [[localClient workingDir] stringByAppendingPathComponent:fileName];

    if ([file isDir])
    {
        NSString     *pristineLocalPath;  /* original path */
        NSString     *pristineRemotePath; /* original path */
        NSArray      *dirList;
        NSString     *remoteDir;
        NSEnumerator *en;
        fileElement  *fEl;

        if (depth > 5)
        {
            NSLog(@"Max depth reached: %d", depth);
            return;
        }

        pristineLocalPath = [[localClient workingDir] retain];
        pristineRemotePath = [[self workingDir] retain];
        
        remoteDir = [[self workingDir] stringByAppendingPathComponent:fileName];
        [self changeWorkingDir:remoteDir];

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
        [localClient changeWorkingDir:pristineLocalPath];
        [pristineLocalPath release];
        [pristineRemotePath release];
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
    
    if ([self initDataStream] < 0)
        return;
    
    localFileStream = fopen([localPath cString], "w");
    if (localFileStream == NULL)
    {
        perror("local fopen failed");
        return;
    }
    
    totalBytes = 0;
    gotFile = NO;
    [controller setTransferBegin:fileName :fileSize];
    while (!gotFile)
    {
        bytesRead = read(localSocket, buff, MAX_DATA_BUFF);
        if (bytesRead == 0)
            gotFile = YES;
        else if (bytesRead < 0)
        {
            gotFile = YES;
            NSLog(@"error on socket read, retrieve file");
        } else
        {
            if (fwrite(buff, sizeof(char), bytesRead, localFileStream) < bytesRead)
            {
                NSLog(@"file write error, retrieve file");
            }
            totalBytes += bytesRead;
            [controller setTransferProgress:totalBytes];
        }
    }
    [controller setTransferEnd:totalBytes];
    
    NSLog(@"transferred %u", (unsigned long)totalBytes);
    fclose(localFileStream);
    [self closeDataStream];
    [self readReply:&reply];
    [reply release];
}

- (void)storeFile:(fileElement *)file from:(localclient *)localClient beingAt:(int)depth
{
    NSString           *fileName;
    unsigned long long fileSize;
    char               fNameCStr[MAX_CONTROL_BUFF];
    char               command[MAX_CONTROL_BUFF];
    char               buff[MAX_DATA_BUFF];
    FILE               *localFileStream;
    NSMutableArray     *reply;
    int                bytesRead;
    struct sockaddr    from;
    int                fromLen;
    int                replyCode;
    unsigned           totalBytes;
    NSString           *localPath;
    BOOL               gotFile;

    fromLen = sizeof(from);

    fileName = [file filename];
    fileSize = [file size];
    
    localPath = [[localClient workingDir] stringByAppendingPathComponent:fileName];

    if ([file isDir])
    {
        NSString     *pristineLocalPath;  /* original path */
        NSString     *pristineRemotePath; /* original path */
        NSArray      *dirList;
        NSString     *remotePath;
        NSEnumerator *en;
        fileElement  *fEl;

        if (depth > 3)
        {
            NSLog(@"Max depth reached: %d", depth);
            return;
        }

        pristineLocalPath = [[localClient workingDir] retain];
        pristineRemotePath = [[self workingDir] retain];

        NSLog(@"it is a dir: %@", fileName);
        remotePath = [pristineRemotePath stringByAppendingPathComponent:fileName];
        [localClient changeWorkingDir:localPath];
        NSLog(@"local dir changed: %@", [localClient workingDir]);

        if ([self createNewDir:remotePath] == YES)
        {
            NSLog(@"remote dir created succesfully");
            [self changeWorkingDir:remotePath];

            dirList = [localClient dirContents];
            en = [dirList objectEnumerator];
            while (fEl = [en nextObject])
            {
                NSLog(@"recurse, upload : %@", [fEl filename]);
                [self storeFile:fEl from:localClient beingAt:(depth+1)];
            }
        }
        /* we get back were we started */
        [self changeWorkingDir:pristineRemotePath];
        [localClient changeWorkingDir:pristineLocalPath];
        [pristineLocalPath release];
        [pristineRemotePath release];
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

    if ([self initDataStream] < 0)
        return;


    localFileStream = fopen([localPath cString], "r");
    if (localFileStream == NULL)
    {
        perror("local fopen failed");
        return;
    }

    totalBytes = 0;
    gotFile = NO;
    [controller setTransferBegin:fileName :fileSize];
    while (!gotFile)
    {
        bytesRead = fread(buff, sizeof(char), MAX_DATA_BUFF, localFileStream);
        if (bytesRead == 0)
        {
            gotFile = YES;
            if (!feof(localFileStream))
                NSLog(@"error on file read, store file");
            else
                NSLog(@"feof");
        } else
        {
            if (write(localSocket, buff, bytesRead) < bytesRead)
            {
                NSLog(@"socket write error, store file");
            }
            totalBytes += bytesRead;
            [controller setTransferProgress:totalBytes];
        }
    }
    [controller setTransferEnd:totalBytes];
    
    NSLog(@"transferred %u", totalBytes);
    fclose(localFileStream);
    [self closeDataStream];
    [self readReply:&reply];
    [reply release];
}

- (void)deleteFile:(fileElement *)file beingAt:(int)depth
{
    NSString           *fileName;
    NSString           *localPath;
    NSFileManager      *fm;
    char               command[MAX_CONTROL_BUFF];
    NSMutableArray     *reply;
    int                replyCode;

    fm = [NSFileManager defaultManager];
    fileName = [file filename];
    localPath = [[self workingDir] stringByAppendingPathComponent:fileName];

    if ([file isDir])
    {
        NSString     *pristineRemotePath; /* original path */
        NSArray      *dirList;
        NSString     *remotePath;
        NSEnumerator *en;
        fileElement  *fEl;

        if (depth > 3)
        {
            NSLog(@"Max depth reached: %d", depth);
            return;
        }

        pristineRemotePath = [[self workingDir] retain];

        NSLog(@"it is a dir: %@", fileName);
        remotePath = [pristineRemotePath stringByAppendingPathComponent:fileName];

        NSLog(@"remote dir created succesfully");
        [self changeWorkingDir:remotePath];

        dirList = [self dirContents];
        en = [dirList objectEnumerator];
        while (fEl = [en nextObject])
        {
            NSLog(@"recurse, delete : %@", [fEl filename]);
            [self deleteFile:fEl beingAt:(depth+1)];
        }

        /* we get back were we started */
        [self changeWorkingDir:pristineRemotePath];
        [pristineRemotePath release];
    }

    sprintf(command, "DELE %s\r\n", [fileName cString]);
    [self writeLine:command];
    replyCode = [self readReply:&reply];
    NSLog(@"%d reply is %@: ", replyCode, [reply objectAtIndex:0]);
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
        NSMutableArray *reply;
        int            replyCode;
        NSScanner      *addrScan;
        int            a1, a2, a3, a4;
        int            p1, p2;
        
        if ((dataSocket = socket(AF_INET, SOCK_STREAM, 0)) < 0)
        {
            perror("socket in initDataConn");
            return -1;
        }

        [self writeLine:"PASV\r\n"];
        replyCode = [self readReply:&reply];
        if (replyCode != 227)
        {
            NSLog(@"passive mode failed");
            return -1;
        }
        NSLog(@"pasv reply is: %d %@", replyCode, [reply objectAtIndex:0]);

        addrScan = [NSScanner scannerWithString:[reply objectAtIndex:0]];
        [addrScan setCharactersToBeSkipped:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
        if ([addrScan scanInt:NULL] == NO)
        {
            NSLog(@"error while scanning pasv address");
            return -1;
        }
        NSLog(@"skipped result code");
        if ([addrScan scanInt:&a1] == NO)
        {
            NSLog(@"error while scanning pasv address");
            return -1;
        }
        NSLog(@"got first");
        if ([addrScan scanInt:&a2] == NO)
        {
            NSLog(@"error while scanning pasv address");
            return -1;
        }
        NSLog(@"got second");
        if ([addrScan scanInt:&a3] == NO)
        {
            NSLog(@"error while scanning pasv address");
            return -1;
        }
        if ([addrScan scanInt:&a4] == NO)
        {
            NSLog(@"error while scanning pasv address");
            return -1;
        }
        if ([addrScan scanInt:&p1] == NO)
        {
            NSLog(@"error while scanning pasv port");
            return -1;
        }
        if ([addrScan scanInt:&p2] == NO)
        {
            NSLog(@"error while scanning pasv port");
            return -1;
        }
        NSLog(@"read: %d %d %d %d : %d %d", a1, a2, a3, a4, p1, p2);

        dataSockName.sin_family = AF_INET;
        dataSockName.sin_addr.s_addr = htonl((a1 << 24) | (a2 << 16) | (a3 << 8) | a4);
        dataSockName.sin_port = htons((p1 << 8) | p2);

        if (connect(dataSocket, (struct sockaddr *) &dataSockName, sizeof(dataSockName)) < 0)
        {
            perror("connect in initDataConn");
            return -1;
        }
        
        return 0;
    }

    /* active mode, default or PORT arbitrated */
    dataSockName = localSockName;

    /* system picks up a port */
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
        char           tempStr[256];
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

- (int)initDataStream
{
    struct sockaddr from;
    int             fromLen;
    
    fromLen = sizeof(from);
    if (usesPassive)
    {
        dataStream = fdopen(dataSocket, "r");
        localSocket = dataSocket;
    } else
    {
        if ((localSocket = accept(dataSocket, &from, &fromLen)) < 0)
        {
            perror("accepting socket, initDataStream: ");
        }
        dataStream = fdopen(localSocket, "r");
    }

    if (dataStream == NULL)
    {
        perror("data stream opening failed");
        return -1;
    }
    NSLog(@"data stream open");
    return 0;
}

- (int)closeDataConn
{
    close (dataSocket);
    return 0;
}

/*
 since fclose of a stream causes the underlying file descriptor to be closed too,
 calling closeDataConn is not necessary after closing the stream
 */
- (void)closeDataStream
{
    fclose (dataStream);
    close(localSocket);
}

/*
 creates a new directory
 tries to guess if the given dir is relative (no starting /) or absolute
 Is this portable to non-unix OS's?
 */
- (BOOL)createNewDir:(NSString *)dir
{
    NSString       *remotePath;
    char           command[MAX_CONTROL_BUFF];
    char           pathCStr[MAX_CONTROL_BUFF];
    NSMutableArray *reply;
    int            replyCode;

    if ([dir hasPrefix:@"/"])
    {
        NSLog(@"%@ is an absolute path", dir);
        remotePath = dir;
    } else
    {
        NSLog(@"%@ is a relative path", dir);
        remotePath = [[self workingDir] stringByAppendingPathComponent:dir];
    }

    [remotePath getCString:pathCStr];
    sprintf(command, "MKD %s\r\n", pathCStr);
    [self writeLine:command];
    replyCode = [self readReply:&reply];
    if (replyCode == 257)
        return YES;
    else
    {
        NSLog(@"remote mkdir code: %d %@", replyCode, [reply objectAtIndex:0]);
        return NO;
    }
}


/* RM again: a better path limit is needed */
- (NSArray *)dirContents
{
    int                ch;
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

    if ([self initDataStream] < 0)
        return nil;
    
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
    [self closeDataStream];
    [self readReply:&reply];
    return [NSArray arrayWithArray:listArr];
}

@end
