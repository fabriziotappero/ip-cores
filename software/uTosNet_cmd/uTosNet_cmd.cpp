/*
* uTosNet commandline utility

* uTosNet_cmd.cpp
* File created by:
*	Simon Falsig
*	University of Southern Denmark
*	Copyright 2010
*
* This file is part of the uTosnet commandline utility
*
*	The uTosnet commandline utility is free software: you can redistribute it 
*	and/or modify it under the terms of the GNU Lesser General Public License as
*	published by the Free Software Foundation, either version 3 of the License,
*	or (at your option) any later version.
*
*	The uTosnet commandline utility is distributed in the hope that it will be
*	useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
*	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
*	General Public License for more details.
*
*	You should have received a copy of the GNU Lesser General Public License
*	along with the uTosnet commandline utility. If not, see
*	<http://www.gnu.org/licenses/>.
*/


#include "uTosNet_cmd.h"

#include <iostream>

using namespace std;

uTosNetCmdClass::uTosNetCmdClass()
{}

uTosNetCmdClass::~uTosNetCmdClass()
{}

void uTosNetCmdClass::run(int argc, char *argv[])
{
	int *sendBuffer;
	int *readBuffer;
	
	sendBuffer = new int[2];
	readBuffer = new int[1];
	sendBuffer[0] = 0;
	readBuffer[0] = 0;
	
	bool expectAnswer = false;
	
	if(argc >= 4)
	{
		bool convOk = false;
		int data = 0, size = 0, addr;
		
		addr = QString(argv[3]).toInt(&convOk, 16);			//Read in the address to access
		if(!convOk)
		{
			cout << "Invalid address specified: " << argv[3] << endl;
			return;
		}
		
		switch(argv[2][0])									//Construct the packet depending on whether it is read or a write
		{
			case 'w':
			case 'W':
				if(argc == 5)										//If data is specified,
				{
					data = QString(argv[4]).toInt(&convOk, 16);		// - read it in
					if(!convOk)
					{
						cout << "Invalid data specified: " << argv[4] << endl;
						return;
					}
				}
				else
				{
					cout << "No data specified for write operation!" << endl;
					return;
				}
				sendBuffer[1] = data;
				((char*)sendBuffer)[3] = 0;
				((char*)sendBuffer)[2] = 0;
				((char*)sendBuffer)[1] = (1<<3) + (1<<2) + (addr >> 8);
				((char*)sendBuffer)[0] = addr & 0xff;
				size = 8;
				break;
			case 'r':
			case 'R':
				((char*)sendBuffer)[3] = (1<<3) + (1<<2) + (addr >> 8);
				((char*)sendBuffer)[2] = addr & 0xff;
				((char*)sendBuffer)[1] = 0;
				((char*)sendBuffer)[0] = 0;
				expectAnswer = true;
				size = 4;
				break;
			default:
				break;
		}
		
		socket.connectToHost(argv[1], 50000);

		if(socket.waitForConnected(10000))			//Connect to specified host, times out if not connected within 10 seconds
		{
			socket.write((char*)sendBuffer, size);	//Send data to host
			
			if(expectAnswer)
			{
				if(socket.waitForReadyRead(10000))	//Wait for answer from host, times out if no data received within 10 seconds
				{
					socket.read((char*)readBuffer, 4);
					cout << (readBuffer[0] & 0xffff) << endl;
				}
			}
		}
		else
		{
			cout << "Could not connect to host: " << argv[1] << endl;
		}
	}
	else
	{
		cout << "uTosNet commandline utility" << endl << 
				"Usage: utosnet_cmd host {W|R} address [data]" << endl << endl <<
				"  host     The IP address of the host to connect to" << endl <<
				"  W        Perform a write operation" << endl <<
				"  R        Perform a read operation" << endl <<
				"  address  The shared memory address to access" << endl <<
				"  data     The data to write (only required when performing a write)" << endl << endl;
	}

	return;	
}

int main(int argc, char *argv[])			//Starts the application
{
	QApplication app(argc, argv);

	uTosNetCmdClass uTosNetCmd;

	uTosNetCmd.currentApp = &app;

	uTosNetCmd.run(argc, argv);

	return 0;
} 

