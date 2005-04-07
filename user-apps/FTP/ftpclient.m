/*
   Project: FTP

   Copyright (C) 2005 Free Software Foundation

   Author: 

   Created: 2005-03-30 09:47:41 +0200 by multix

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#include <arpa/inet.h>  /* for inet_ntoa and similar */
#include <netdb.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#import "ftpclient.h"

#define MAX_CONTROL_BUFF 2048
#define MAX_DATA_BUFF 2048

@implementation ftpclient

/* read the reply of a command, be it single or multi-line */
/* returned is the first numerical code                    */
/* NOTE: the parser is NOT robust in handling errors */
- (int)readReply
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

    readBytes = 0;
    state = N1;
    separator = 0;

    while (!(state == END))
    {
        ch = getc(controlInStream);
        switch (state)
        {
            case N1:
                buff[readBytes] = ch;
                numCodeStr[readBytes] = ch;
                readBytes++;
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
                if (separator == 0);
                {
                    separator = ch;
                    startNumCode = numCode;
                }
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
                    NSLog(@"%s", buff);
                    readBytes = 0;
                    if (numCode == startNumCode)
                        state = END;
                }
                break;
            default:
                NSLog(@"Duh, a case default in the readReply parser");
        }
    }
    return startNumCode;
}

- (int) writeLine:(char *)line
{
    int sentBytes;
    int bytesToSend;
    
    bytesToSend = strlen(line);
    if ((sentBytes = send(controlSocket, line, strlen(line), 0)) < bytesToSend)
        NSLog(@"sent %d out of %d", sentBytes, bytesToSend);
    return sentBytes;
}

/* initialize a connection */
/* set up and connect the control socket */
- (int)connect:(int)port :(char *)server
{
    struct hostent      *hostentPtr;
    char                *tempStr;
    int                 addrLen; /* socklen_t on some systems? */

    NSLog(@"connect to %s : %d", server, port);

    if((hostentPtr = gethostbyname(server)) == NULL)
    {
        NSLog(@"Could not resolve %c", server);
        return -1;
    }
    bcopy((char *)hostentPtr->h_addr, (char *)&remoteSockName.sin_addr, hostentPtr->h_length);
    remoteSockName.sin_family = PF_INET;
    remoteSockName.sin_port = htons(port);

    tempStr = inet_ntoa(remoteSockName.sin_addr);
    NSLog(@"%s", tempStr);

    if ((controlSocket = socket(PF_INET, SOCK_STREAM, 0)) < 0)
    {
        perror("socket failed: ");
        return -1;
    }
    if (connect(controlSocket, (struct sockaddr*) &remoteSockName, sizeof(remoteSockName)) < 0)
    {
        perror("connect failed: ");
        return -1;
    }

    /* we retrieve now the local name of the created socked */
    /* the local port is for example important as default data port */
    addrLen = sizeof(localSockName);
    if (getsockname(controlSocket, (struct sockaddr *)&localSockName, &addrLen) < 0)
    {
            perror("ftpclient: getsockname");
    }
    
    controlInStream = fdopen(controlSocket, "r");
    [self readReply];
    return 0;
}

- (void)disconnect
{
    [self writeLine:"QUIT\r\n"];
    [self readReply];
}

- (int)authenticate:(char *)user :(char *)pass
{
    char    tempStr[MAX_CONTROL_BUFF];

    sprintf(tempStr, "USER %s\r\n", user);
    [self writeLine:tempStr];
    [self readReply];
    sprintf(tempStr, "PASS %s\r\n", pass);
    [self writeLine:tempStr];
    [self readReply];
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
        perror("ftpclient: setsockopt (reuse address)");
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

- (NSArray *)getDirList:(char *)path
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
    
    /* create an array with a reasonable starting size */
    listArr = [NSMutableArray arrayWithCapacity:5];
    
    [self initDataConn];
    [self writeLine:"NLST\r\n"];
    [self readReply];
    
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
//        printf("%c", ch);
        if (ch == '\r')
            state = GOTR;
        else if (ch == '\n' && state == GOTR)
        {
            buff[readBytes] = '\0';
            printf("%s\n", buff);
            state = READ; /* reset the state for a new line */
            readBytes = 0;
            [listArr addObject:[NSString stringWithCString:buff]];
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
    printf("\n datasockread end\n");
    return [NSArray arrayWithArray:listArr];
}

@end
