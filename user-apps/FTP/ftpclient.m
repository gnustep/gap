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
    return self;
}

/* RM, fxme: should check for 200 result code */
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


/* read the reply of a command, be it single or multi-line */
/* returned is the first numerical code                    */
/* NOTE: the parser is NOT robust in handling errors */
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

- (void)retrieveFile:(NSString *)file toPath:(NSString *)localPath
{
//    NSString       *localPath;
    char           fNameCStr[MAX_CONTROL_BUFF];
    char           command[MAX_CONTROL_BUFF];
    NSFileHandle   *remoteFileHandle;
    NSFileHandle   *localFileHandle;
    NSMutableArray *reply;
    NSData         *dataBuff;
    int            localSocket;
    struct sockaddr_in from;
    int                fromLen;
    int                replyCode;
    NSFileManager      *localFm;
    
    if ([self initDataConn] < 0)
    {
        NSLog(@"error initiating data connection, retrieveFile");
        return;
    }
    localPath = [localPath stringByAppendingPathComponent:file];
    NSLog(@"local path: %@", localPath);
    
    [file getCString:fNameCStr];
    sprintf(command, "RETR %s\r\n", fNameCStr);
    [self writeLine:command];
    replyCode = [self readReply:&reply];
    NSLog(@"%d reply is %@: ", replyCode, [reply objectAtIndex:0]);

    if ((localSocket = accept(dataSocket, (struct sockaddr *) &from, &fromLen)) < 0)
    {
        perror("accepting socket, retrieveFile: ");
    }

    NSLog(@"opened socket");
/*
    {
        FILE *myfile;
        char fn[4096];

        
    } */

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

    while (dataBuff = [remoteFileHandle availableData])
        [localFileHandle writeData:dataBuff];

    [self closeDataConn];
    [self readReply:&reply];
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
    int socketReuse;
    
    socketReuse = YES;
    dataSockName = localSockName;
    
    dataSocket = socket(AF_INET, SOCK_STREAM, 0);
    if (setsockopt(dataSocket, SOL_SOCKET, SO_REUSEADDR, &socketReuse, sizeof (socketReuse)) < 0)
    {
        perror("ftpclient: setsockopt (reuse address) on data");
    }
    if (setsockopt(controlSocket, SOL_SOCKET, SO_REUSEADDR, &socketReuse, sizeof (socketReuse)) < 0)
    {
        perror("ftpclient: setsockopt (reuse address) on control");
    }
    if (bind(dataSocket, (struct sockaddr *)&dataSockName, sizeof (dataSockName)) < 0)
    {
        perror("ftpclient: bind");
        return -1;
    }
    
    if (listen(dataSocket, 1) < 0)
    {
        perror("ftpclient: listen");
        return -1;
    }
    return 0;
}

- (int)closeDataConn
{
    close (dataSocket);
    return 0;
}

/* RM: skipping total here is a bit of a hack. fixme */
/* RM again: a better path limit is needed */
- (NSArray *)dirContents
{
    int                ch;
    FILE               *dataStream;
    int                localSocket;
    struct sockaddr_in from;
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
    
    /* create an array with a reasonable starting size */
    listArr = [NSMutableArray arrayWithCapacity:5];
    
    [self initDataConn];
    [self writeLine:"LIST\r\n"];
    [self readReply:&reply];
    
    if ((localSocket = accept(dataSocket, (struct sockaddr *) &from, &fromLen)) < 0)
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
            if (strstr(buff, "total") == buff)
                fprintf(stderr, "skipped");
            else
            {
                aFile = [[fileElement alloc] initWithLsLine:buff];
                [listArr addObject:aFile];
            }
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
