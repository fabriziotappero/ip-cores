/*
* uTosNet commandline utility

* uTosNet_cmd.h
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


#include <QtNetwork>
#include <QTcpSocket>
#include <QApplication>


class uTosNetCmdClass : public QObject
{
	Q_OBJECT
	
public:
	uTosNetCmdClass();
	~uTosNetCmdClass();
	
	void run(int argc, char *argv[]);

	QApplication *currentApp;
		
public slots:
	
private:
	QTcpSocket socket;

};
