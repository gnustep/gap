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

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

#include <stdio.h>

#import <Foundation/Foundation.h>
#import "client.h"

#define ERR_COULDNT_RESOLVE -1
#define ERR_SOCKET_FAIL -2
#define ERR_CONNECT_FAIL -3
#define ERR_GESOCKNAME_FAIL -4

@interface ftpclient : client
{
    id  controller;
    int userDataPort;
    int serverDataPort;
    int dataSocket;
    int controlSocket;
    FILE *controlInStream;
    struct sockaddr_in  remoteSockName;
    struct sockaddr_in  localSockName;
    struct sockaddr_in  dataSockName;
}

- (id)init;
- (id)initWithController:(id)cont;

- (void)logIt:(NSString *)str;

- (int)connect:(int)port :(char *)server;
- (void)disconnect;
- (int)authenticate:(char *)user :(char *)pass;
- (int)initDataConn;


@end


