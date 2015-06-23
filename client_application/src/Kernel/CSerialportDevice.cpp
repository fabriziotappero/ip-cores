/*
 * @file     SerialportDevice.cpp
 * @date     May 14, 2012
 * @author   Aart Mulder
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef linux
#include <fcntl.h>
#include <errno.h>
#include <termios.h>
#include <unistd.h>
#include "CPathLib.h"      //For serial port enumeration
#else
#include <windows.h>
#include <Winerror.h>
#endif

#include <QDebug>
#include <QStringList>
#include <QProcess>

#include "CSerialportDevice.h"
#include "sysconf.h"

    /** @author Aart Mulder
     *  @version 1
     */

#define RX_BUF_SIZE				5000

CSerialportDevice::CSerialportDevice(int nLoopTime, QString sName) : CDevice(nLoopTime, sName)
{
#ifdef linux
	fd1 = -1;
#else
	m_fpSerialPort = INVALID_HANDLE_VALUE;
#endif

	this->ResetRxCnt();
}

CSerialportDevice::~CSerialportDevice()
{
	this->Disconnect();
}

bool CSerialportDevice::Send(unsigned char cData)
{
	int wr;

#ifdef SIM_SERIAL_LOOPBACK
		REFER(wr);
		OnDataReceived(cData);
#else
#ifdef linux
	wr = write(fd1, &cData, 1);
#else
	WriteFile(m_fpSerialPort, &cData, 1, (DWORD*)&wr, 0);
#endif
	if(wr != 1)
	{
		return false;
	}
#endif
	return true;
}

bool CSerialportDevice::Send(unsigned char *pData, unsigned int nSize)
{
	unsigned int wr;

#ifdef SIM_SERIAL_LOOPBACK
	REFER(wr);
	for(unsigned int i = 0; i < nSize; i++)
	{
		OnDataReceived(pData[i]);
	}
#else
#ifdef linux
	wr = write(fd1, pData, nSize);
#else
	WriteFile(m_fpSerialPort, pData, nSize, (DWORD*)&wr, 0);
#endif
	if(wr != nSize)
	{
		return false;
	}
#endif

	return true;
}

QList<QString> CSerialportDevice::GetPortNames()
{
	QList<QString> aPortNames;

#ifdef linux
    CPathLib::ReadDir("/dev", &aPortNames, "\\b(ttyS|ttyUSB|rfcomm|ttyACM)");
	aPortNames = QStringList(aPortNames).replaceInStrings("tty", "/dev/tty");
    aPortNames = QStringList(aPortNames).replaceInStrings("rfcomm", "/dev/rfcomm");
#else
    HKEY hKey;
    long lResult;

    if( (lResult = RegCreateKeyExA(
            HKEY_LOCAL_MACHINE, //hKey
            "HARDWARE\\DEVICEMAP\\SERIALCOMM",
            0,                  //Reserved
            NULL,               //lpClass
            0,                  //dwOptions
            KEY_READ,     //samDesired
            NULL,               //lpSecurityAttributes
            &hKey,              //phkResult
            NULL)) == ERROR_SUCCESS) //lpdwDisposition
    {
        char rval[256];
        DWORD rval_len = 256 ;

        char rdata[256];
        DWORD rdata_len = 256;

        DWORD rtype = REG_SZ ;
        int i = 0;

        while( RegEnumValueA(hKey, i, rval, &rval_len, NULL, &rtype,
        (unsigned char*)rdata, &rdata_len) != ERROR_NO_MORE_ITEMS)
        {
            qDebug() << rval << " : " << rdata;
            aPortNames.append(QString(rdata));
            i++;
            rval_len=256;
            rdata_len=256;
            memset(rval, '\0', rval_len);
            memset(rdata, '\0', rdata_len);
        }
        RegCloseKey (hKey);
    }
#endif

	return aPortNames;
}

bool CSerialportDevice::Connect(char *sName)
{
    return Connect(sName, 9600);
}

bool CSerialportDevice::Connect(char *sName, quint32 nBaudrate)
{
#ifdef linux
    QProcess oProcess;

#if 0
    if(QString(sName).contains("/dev/rfcomm0"))
    {
        oProcess.start("gksudo rfcomm release /dev/rfcomm0");
        oProcess.waitForFinished(20000);
        oProcess.start("gksudo rfcomm bind /dev/rfcomm0 00:07:80:4B:23:7A 1");
        oProcess.waitForFinished(20000);
    }
#endif
	fd1 = open(sName, O_RDWR | O_NOCTTY | O_NDELAY);

	if (fd1 == -1 )
	{
		qDebug() << "Could not connect to " << sName << "\n";
		return false;
	}
	else
	{
		fcntl(fd1, F_SETFL,0);
        configure_port(nBaudrate);
		qDebug() << "Successfully connected to " << sName << "\n";
		return true;
	}
#else
	DCB dcb;
	BOOL fSuccess;
    char aTmpCommPort[20];
    HANDLE fpSerialPort = INVALID_HANDLE_VALUE;

    strcpy(aTmpCommPort, "\\\\.\\");
    strcat(aTmpCommPort, sName);
    fpSerialPort = CreateFileA( aTmpCommPort,
			GENERIC_READ | GENERIC_WRITE,
			0,    // must be opened with exclusive-access
			NULL, // default security attributes
			OPEN_EXISTING, // must use OPEN_EXISTING
            0,//FILE_FLAG_NO_BUFFERING,    // not overlapped I/O
			NULL  // hTemplate must be NULL for comm devices
	);

    if (fpSerialPort == INVALID_HANDLE_VALUE)
	{
        qDebug() << "Could not connect to " << sName << "\n";
        // Handle the error.

		return false;
	}

    qDebug() << "Successfully connected to " << sName << "\n";

	/*
	 * Build on the current configuration, and skip setting the size
	 * of the input and output buffers with SetupComm.
	 */
	dcb.DCBlength = sizeof(DCB);
    fSuccess = GetCommState(fpSerialPort, &dcb);

	if (!fSuccess)
	{
        // Handle the error.
        return false;
	}

    switch(nBaudrate)
    {
    case 9600:
        dcb.BaudRate = CBR_9600;     // set the baud rate
        break;
    case 19200:
        dcb.BaudRate = CBR_19200;     // set the baud rate
        break;
    case 38400:
        dcb.BaudRate = CBR_38400;     // set the baud rate
        break;
    case 57600:
        dcb.BaudRate = CBR_57600;     // set the baud rate
        break;
    case 115200:
        dcb.BaudRate = CBR_115200;     // set the baud rate
        break;
#ifdef linux
    case 230400:
        dcb.BaudRate = CBR_230400;     // set the baud rate
        break;
#endif
    default:
        dcb.BaudRate = CBR_9600;     // set the baud rate
        break;
    }

	dcb.ByteSize = 8;             // data size, xmit, and rcv
    dcb.Parity = ODDPARITY;        // no parity bit
	dcb.StopBits = ONESTOPBIT;    // one stop bit

    fSuccess = SetCommState(fpSerialPort, &dcb);

	if (!fSuccess)
	{
	   // Handle the error.
	   return false;
	}

	 COMMTIMEOUTS CommTimeouts;
     if(!GetCommTimeouts (fpSerialPort, &CommTimeouts))
	 {
		 // Handle the error.
		 return false;
	 }
	 // Change the COMMTIMEOUTS structure settings.
     memset((void*)&CommTimeouts, 0, sizeof(CommTimeouts));
     CommTimeouts.ReadIntervalTimeout = 5;
     CommTimeouts.ReadTotalTimeoutMultiplier = 1;
     CommTimeouts.ReadTotalTimeoutConstant = 5;
     CommTimeouts.WriteTotalTimeoutMultiplier = 10;
     CommTimeouts.WriteTotalTimeoutConstant = 10;

	 // Set the timeout parameters for all read and write operations
	 // on the port.
     if (!SetCommTimeouts (fpSerialPort, &CommTimeouts))
	 {
		 // Could not set the timeout parameters.
         return false;
	 }

	 m_fpSerialPort = fpSerialPort;
#endif

     return true;
}

bool CSerialportDevice::Disconnect()
{
#ifdef linux
	::close(fd1);
	fd1 = -1;
#else
    CloseHandle(m_fpSerialPort);
    m_fpSerialPort = INVALID_HANDLE_VALUE;
#endif

	return true;
}

void CSerialportDevice::BeforeDeviceLoop()
{
	quint8 aFlush[1000];

	this->serialRead((char*)aFlush, 1000);

	BeforeClientLoop();
}

void CSerialportDevice::DeviceLoop()
{
	quint8 rxBuf[RX_BUF_SIZE+1];
	int nBytesReceived = 0;

    while( (nBytesReceived = this->serialRead((char*)rxBuf, RX_BUF_SIZE+1)) > 0)
	{
        this->OnDataReceived(rxBuf, nBytesReceived);
	}

	ClientLoop();
}

void CSerialportDevice::AfterDeviceLoop()
{
	AfterClientLoop();

	qDebug() << "@CSerialportDevice::AfterDeviceLoop()";
}

int CSerialportDevice::serialRead(char* aData, int nMaxSize)
{
#ifdef linux
    int iIn = 0;
#else
    unsigned long iIn = 0;
#endif

#ifdef linux
	if (fd1 < 1)
		return -1;
#else
	if(m_fpSerialPort == INVALID_HANDLE_VALUE)
		return -1;
#endif


#ifdef linux
	iIn = read(fd1, aData, nMaxSize - 1);
#else
    ReadFile(m_fpSerialPort, aData, nMaxSize-1, &iIn, 0);
#endif

    if (iIn <= 0)
	{
		return 0; // assume that command generated no response
	}
	else if(iIn > 0)
	{
        aData[iIn < nMaxSize ? iIn : nMaxSize-1] = '\0';
		this->m_nRxCnt += iIn;
	}
	return iIn;
}

#ifdef linux
void CSerialportDevice::configure_port(quint32 nBaudrate)      // configure the port
{
	struct termios port_settings;      // structure to store the port settings in

    switch(nBaudrate)
    {
    case 9600:
        port_settings.c_cflag = B9600;
        break;
    case 19200:
        port_settings.c_cflag = B19200;
        break;
    case 38400:
        port_settings.c_cflag = B38400;
        break;
    case 57600:
        port_settings.c_cflag = B57600;
        break;
    case 115200:
        port_settings.c_cflag = B115200;
        break;
    case 230400:
        port_settings.c_cflag = B230400;
        break;
    default:
        port_settings.c_cflag = B9600;
        break;
    }
//    port_settings.c_cflag = B9600;
    port_settings.c_cflag &= ~PARODD;    // set no parity, stop bits, data bits
	port_settings.c_cflag &= ~CSTOPB;
	port_settings.c_cflag &= ~CSIZE;
	port_settings.c_cflag |= CS8;

	port_settings.c_lflag = 0;

	port_settings.c_cc[VTIME] = 1;
	port_settings.c_cc[VMIN] = 0;

	port_settings.c_iflag = 0;
	port_settings.c_oflag = 0;

	tcsetattr(fd1, TCSANOW, &port_settings);    // apply the settings to the port

	tcflush(fd1, TCIOFLUSH);
}
#endif

void CSerialportDevice::ResetRxCnt()
{
	this->m_nRxCnt = 0;
}

quint64 CSerialportDevice::GetRxCnt()
{
	return this->m_nRxCnt;
}

void CSerialportDevice::Flush()
{
#ifdef linux
    tcflush(fd1, TCIOFLUSH);
#endif
}
