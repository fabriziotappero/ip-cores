/*
 * @file     SerialportDevice.h
 * @date     May 14, 2012
 * @author   Aart Mulder
 */

#ifndef CSerialportDevice_h
#define CSerialportDevice_h

#include <QString>
#include <QList>

#ifndef linux
#include <windows.h>
#include <tchar.h>
#include <stdio.h>
#endif

#include "CDevice.h"

	/** @author Aart Mulder
	 *  @version 1
	 */

class CSerialportDevice : public CDevice {
	/* {since=2011-12-09}*/
	Q_OBJECT

 public:
	CSerialportDevice(int nLoopTime, QString sName);
	virtual ~CSerialportDevice();
    static QList<QString> GetPortNames();
	bool Connect(char *sName);
    bool Connect(char *sName, quint32 nBaudrate);
    bool Disconnect();
	void ResetRxCnt();
	quint64 GetRxCnt();
    void Flush();

 protected:
	void BeforeDeviceLoop();
	void DeviceLoop();
	void AfterDeviceLoop();
	virtual void BeforeClientLoop() = 0;
	virtual void ClientLoop() = 0;
	virtual void AfterClientLoop() = 0;
	virtual void OnDataReceived(quint8 cData) = 0;
	virtual void OnDataReceived(quint8 *pData, int nSize) = 0;
	bool Send(unsigned char cData);
	bool Send(unsigned char *pData, unsigned int nSize);

	quint64 m_nRxCnt;

 private:
	int serialRead(char* aData, int nMaxSize);
#ifdef linux
    void configure_port(quint32 nBaudrate);
#endif

#ifdef linux
	int fd1;
#else
	HANDLE m_fpSerialPort;
#endif

 signals:
	void DebugMessage(QString sMessage);

 private slots:

};

#endif // CSerialportDevice_h
