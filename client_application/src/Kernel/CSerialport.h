/*
 * @file     Serialport.h
 * @date     May 14, 2012
 * @author   Aart Mulder
 */

#ifndef CSERIALPORT_H
#define CSERIALPORT_H

/** @author Aart Mulder
 *  @version 1
 */

#include <QByteArray>
#include <QTime>
#include <QMutex>
#include <QQueue>

#include "CSerialportDevice.h"

class CSerialport : public CSerialportDevice
{
    Q_OBJECT

    enum E_CommState
    {
        S_Unknown,
        S_StandBy,
        S_WaitForData
    };

public:
    CSerialport();
    void Send(unsigned char cData);
    void Send(QByteArray aData);
    void RequestNewFrame(QString sFilename = "", QString sDir = "");
    bool Connect(char *sName, quint32 nBaudrate);
    bool Disconnect();
    bool IsStateStandby();
    bool IsStateWaitForData();
    int  GetBytesReceived();
    int  GetBytesExpected();
    void GetNewBytes(QByteArray *pRxData);
    void CancelRequest();

protected:
   void BeforeClientLoop();
   void ClientLoop();
   void AfterClientLoop();
   void OnDataReceived(quint8 cData);
   void OnDataReceived(quint8 *pData, int nSize);

private:
   unsigned int m_nBytesExpected, m_nBytesReceived, m_nImageWidth, m_nImageHeight;
   QByteArray m_aRxBuf;
   E_CommState m_oCommState;
   bool m_bTimeoutTimer;
   QTime m_oRxTimeoutTimer;
   int m_nTimeoutTime;
   QString m_sFilename;
   QString m_sDir;
   QQueue<quint8> m_aRxQForGUI;
   QMutex m_oRxQMutex;

   void handleRxByte(quint8 cData);
   void handleStreamComplete(QString sFilename = "", QString sDir = "");

private slots:
    void onSend(unsigned char cData);
    void onSend(QByteArray aData);

signals:
    void send(unsigned char cData);
    void send(QByteArray aData);
    void showErrorMessage(QString sMessage, bool bEnableBtSingleShot, bool bCheckedBtRepeat);
    void frameCompleted(QString sFilename);

};

#endif // CSERIALPORT_H
