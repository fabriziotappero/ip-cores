/*
 * @file     Serialport.cpp
 * @date     May 14, 2012
 * @author   Aart Mulder
 */

#include <QDir>
#include <QDateTime>
#include <QImage>
#include <QDebug>

#include "CSerialport.h"

#define NEW_FRAME_CHAR    char('S')

CSerialport::CSerialport() :
    CSerialportDevice(10, "SerialportDevice")
{
    connect(this, SIGNAL(send(QByteArray)), this, SLOT(onSend(QByteArray)));
    connect(this, SIGNAL(send(unsigned char)), this, SLOT(onSend(unsigned char)));

    m_nBytesExpected = 0;
    m_nBytesReceived = 0;

    m_bTimeoutTimer = false;
    m_nTimeoutTime = 10000;
    m_sFilename = "";
    m_sDir = "";
    m_oRxQMutex.unlock();
    m_aRxQForGUI.clear();

    this->Start();
}

void CSerialport::BeforeClientLoop()
{

}

void CSerialport::ClientLoop()
{
    if(m_bTimeoutTimer)
    {
        if(m_oRxTimeoutTimer.elapsed() >= m_nTimeoutTime)
        {
            /* Communication timeout occured */
            if(this->m_oCommState == S_WaitForData)
            {
                handleStreamComplete("", m_sDir);
            }

            m_bTimeoutTimer = false;
        }
    }
}

void CSerialport::AfterClientLoop()
{

}

void CSerialport::OnDataReceived(quint8 cData)
{
    handleRxByte(cData);
}

void CSerialport::OnDataReceived(quint8 *pData, int nSize)
{
    for(int i = 0; i < nSize; i++)
    {
        handleRxByte(pData[i]);
    }
}

void CSerialport::Send(unsigned char cData)
{
    emit send(cData);
}

void CSerialport::Send(QByteArray aData)
{
    emit send(aData);
}

void CSerialport::onSend(unsigned char cData)
{
    CSerialportDevice::Send(cData);
}

void CSerialport::onSend(QByteArray aData)
{
    CSerialportDevice::Send((unsigned char*)aData.data(), (unsigned int)aData.size());
}

bool CSerialport::Connect(char *sName, quint32 nBaudrate)
{
    m_oCommState = S_StandBy;
    m_bTimeoutTimer = false;

    return CSerialportDevice::Connect(sName, nBaudrate);
}

bool CSerialport::Disconnect()
{
    m_oCommState = S_StandBy;
    m_bTimeoutTimer = false;

    return CSerialportDevice::Disconnect();
}

bool CSerialport::IsStateStandby()
{
    return (m_oCommState == S_StandBy ? true : false);
}

bool CSerialport::IsStateWaitForData()
{
    return (m_oCommState == S_WaitForData ? true : false);
}

int CSerialport::GetBytesExpected()
{
    return this->m_nBytesExpected;
}

/**
 * @brief Reads the number of bytes received.
 * @return int with the number of bytes received.
 */
int CSerialport::GetBytesReceived()
{
    return this->m_nBytesReceived;
}

/**
 * @brief Writes the data that has been received since the last call
 * of this function into the QByteArray where @e pRxData is pointing to.
 * @param pRxData is the pointer to a QByteArray where the received data
 * will be stored in.
 */
void CSerialport::GetNewBytes(QByteArray *pRxData)
{
    m_oRxQMutex.lock();
    pRxData->reserve(m_aRxQForGUI.size());
    while(!m_aRxQForGUI.empty())
    {
        pRxData->append(m_aRxQForGUI.dequeue());
    }
    m_oRxQMutex.unlock();
}

void CSerialport::CancelRequest()
{
    m_bTimeoutTimer = false;
    m_oCommState = S_StandBy;

    m_nBytesReceived = 0;
    m_nBytesExpected = 0;

    this->Flush();
}

void CSerialport::RequestNewFrame(QString sFilename, QString sDir)
{
    /* Request of a new frame is only allowed if no request is pending */
    if(m_oCommState != S_StandBy)
    {
        return;
    }

    m_sFilename = sFilename;
    if(sFilename.length() == 0)
    {
        m_sFilename = QString("image_") + QDateTime::currentDateTime().toString("yyyyMMdd_hh_mm_ss_zzz") + QString(".tif");
    }

    m_sDir = sDir;
    if(sDir.length() == 0)
    {
        m_sDir = QDir::currentPath();
    }

    m_nBytesReceived = 0;
    m_nBytesExpected = 0;

    this->Flush();

    m_oCommState = S_WaitForData;

    m_oRxTimeoutTimer.restart();
    m_bTimeoutTimer = true;

    this->Send(NEW_FRAME_CHAR);
}

void CSerialport::handleRxByte(quint8 cData)
{
    m_oRxTimeoutTimer.restart();
    m_bTimeoutTimer = true;

    if(this->m_oCommState != S_WaitForData)
    {
        /*
         * When no frame is requested: only display the received data
         * to the user. No processing or storage in the Queue is done.
         */
        m_oRxQMutex.lock();
        m_aRxQForGUI.append(cData);
        m_oRxQMutex.unlock();

        return;
    }

    switch(m_nBytesReceived)
    {
    case 0:
        m_nBytesExpected = (quint32)cData;
        m_aRxBuf.clear();
        break;
    case 1:
        m_nBytesExpected = m_nBytesExpected + ((quint32)cData << 8) + 2;
        m_aRxBuf.reserve(m_nBytesExpected);
        break;
    default:
        /* Add all following bytes to the buffer */
        m_aRxBuf.append(cData);
        break;
    }
    m_oRxQMutex.lock();
    m_aRxQForGUI.append(cData);
    m_oRxQMutex.unlock();

    m_nBytesReceived++;

    if(m_nBytesReceived == m_nBytesExpected)
    {
        handleStreamComplete(m_sFilename, m_sDir);
    }
}

void CSerialport::handleStreamComplete(QString sFilename, QString sDir)
{
    QImage *pImage;
    QString sFilename2;
    QFile file;
    QDir oDir;

    if(sFilename.length() == 0)
    {
        sFilename = QString("image_") + QDateTime::currentDateTime().toString("yyyyMMdd_hh_mm_ss_zzz") + QString(".tif");
    }

    if(sDir.length() == 0)
    {
        sDir = QDir::currentPath();
    }

    oDir.setCurrent(sDir);
    sFilename2 = oDir.absoluteFilePath(sFilename);

    file.setFileName(sFilename2);

    /*
     * Don't create the file if no data has been received
     * and turn of the repeat function if enabled.
     */
    if(m_aRxBuf.size() < 1)
    {
        m_oCommState = S_StandBy;
        m_bTimeoutTimer = false;

        emit showErrorMessage("No data has been received.", true, false);

        return;
    }

    if (!file.open(QIODevice::WriteOnly))
        return;

    if(m_aRxBuf.size() & 0x1)
        m_aRxBuf.append('\0');

    QDataStream dStream(&file);

    m_nImageWidth = 752;
    m_nImageHeight = 480;

    /* Write tiff header */
    dStream << (quint8)0x4D << (quint8)0x4D << (quint8)0x00 << (quint8)0x2A << (quint8)0x00 << (quint8)0x00;

    /* Write header offset */
    dStream << (quint8)(((m_aRxBuf.size() + 8) & 0xFF00) >> 8) << (quint8)(((m_aRxBuf.size() + 8) & 0x00FF) >> 0);

    /* Write stream data */
    dStream.writeRawData(m_aRxBuf.data(), m_aRxBuf.size());

    /* Write number of directories */
    dStream << (quint8)0x00 << (quint8)0x08;

    /* Write image width */
    //Byte 0 to 7
    dStream << (quint8)0x01 << (quint8)0x00 << (quint8)0x00 << (quint8)0x03 << (quint8)0x00 << (quint8)0x00 << (quint8)0x00 << (quint8)0x01;
    //Byte 8 to 9
    dStream << (quint8)((m_nImageWidth & 0xFF00) >> 8) << (quint8)((m_nImageWidth & 0x00FF) >> 0);
    //Byte 10 to 11
    dStream << (quint8)0x00 << (quint8)0x00;

    /* Write image height */
    //Byte 0 to 7
    dStream << (quint8)0x01 << (quint8)0x01 << (quint8)0x00 << (quint8)0x03 << (quint8)0x00 << (quint8)0x00 << (quint8)0x00 << (quint8)0x01;
    //Byte 8 to 9
    dStream << (quint8)((m_nImageHeight & 0xFF00) >> 8) << (quint8)((m_nImageHeight & 0x00FF) >> 0);
    //Byte 10 to 11
    dStream << (quint8)0x00 << (quint8)0x00;

    /* Write bits per sample */
    //Byte 0 to 5
    dStream << (quint8)0x01 << (quint8)0x02 << (quint8)0x00 << (quint8)0x03 << (quint8)0x00 << (quint8)0x00;
    //Byte 6 to 11
    dStream << (quint8)0x00 << (quint8)0x01 << (quint8)0x00 << (quint8)0x01 << (quint8)0x00 << (quint8)0x00;

    /* Write compression */
    //Byte 0 to 5
    dStream << (quint8)0x01 << (quint8)0x03 << (quint8)0x00 << (quint8)0x03 << (quint8)0x00 << (quint8)0x00;
    //Byte 6 to 11
    dStream << (quint8)0x00 << (quint8)0x01 << (quint8)0x00 << (quint8)0x04 << (quint8)0x00 << (quint8)0x00;

    /* Write photometric interpretation */
    //Byte 0 to 5
    dStream << (quint8)0x01 << (quint8)0x06 << (quint8)0x00 << (quint8)0x03 << (quint8)0x00 << (quint8)0x00;
    //Byte 6 to 11
    dStream << (quint8)0x00 << (quint8)0x01 << (quint8)0x00 << (quint8)0x00 << (quint8)0x00 << (quint8)0x00;

    /* Write strip offset */
    //Byte 0 to 5
    dStream << (quint8)0x01 << (quint8)0x11 << (quint8)0x00 << (quint8)0x03 << (quint8)0x00 << (quint8)0x00;
    //Byte 6 to 11
    dStream << (quint8)0x00 << (quint8)0x01 << (quint8)0x00 << (quint8)0x08 << (quint8)0x00 << (quint8)0x08;

    /* Write rows per strip */
    //Byte 0 to 5
    dStream << (quint8)0x01 << (quint8)0x16 << (quint8)0x00 << (quint8)0x03 << (quint8)0x00 << (quint8)0x00;
    //Byte 6 to 7
    dStream << (quint8)0x00 << (quint8)0x01;
    //Byte 8 to 9
    dStream << (quint8)((m_nImageHeight & 0xFF00) >> 8) << (quint8)((m_nImageHeight & 0x00FF) >> 0);
    //Byte 10 to 11
    dStream << (quint8)0x00 << (quint8)0x00;

    /* Write strip byte count */
    //Byte 0 to 5
    dStream << (quint8)0x01 << (quint8)0x17 << (quint8)0x00 << (quint8)0x03 << (quint8)0x00 << (quint8)0x00;
    //Byte 6 to 7
    dStream << (quint8)0x00 << (quint8)0x01;
    //Byte 8 to 9
    dStream << (quint8)((m_aRxBuf.size() & 0xFF00) >> 8) << (quint8)((m_aRxBuf.size() & 0x00FF) >> 0);
    //Byte 10 to 11
    dStream << (quint8)0x00 << (quint8)0x00;

    /* Write EOB */
    dStream << (quint8)0x00 << (quint8)0x00 << (quint8)0x00 << (quint8)0x00;

    file.close();

    qDebug() << " ";
    qDebug() << "=========================================================";
    qDebug() << "========== Start decoding of new frame ==================";
    qDebug() << "=========================================================";
    qDebug() << " ";

    pImage = new QImage(sFilename2);
    if(pImage->isNull())
    {
        m_oCommState = S_StandBy;
        m_bTimeoutTimer = false;

        emit showErrorMessage(QString("Failed to open the file: %1").arg(sFilename2), true, false);

        return;
    }
    delete pImage;

    emit frameCompleted(sFilename2);

    m_oCommState = S_StandBy;
    m_bTimeoutTimer = false;
}
