#include <QtGui/QDialog>
#include <QThread>
#include <QString>
#include <QTimer>
#include <cmath>
//#include <QBasicTimer>
#include "rvicommthread.h"

RVICommThread::RVICommThread(QObject *parent): QThread(parent = 0)
{
    portAddress = 0;
    continuous = 0;
    triggerOn = 0;
    triggerSlope = 0;
    triggerChannel = 0;
    timeScaleEnabled = 0;
    timeScaleValue = 0;
    channelAEnabled = 0;
    channelBEnabled = 0;
    bufferSize = 0;
    triggerLevel = 0;
    triggerOffset = 0;

    aDCSampleRate = BASE_SAMPLE_RATE;

}


RVICommThread::~RVICommThread()
{
    port.closeEPP();
}


void RVICommThread::run()
{
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Init
    acqStopped = false;
    bufferFull = false;

    unsigned short int confArray[5];

    if (bufferSize < triggerOffset || -bufferSize > triggerOffset )
    {
        if (triggerOffset < 0)
            triggerOffset = -bufferSize;
        else
            triggerOffset = bufferSize;

        emit statusMessage(tr("Too big trigger offset, truncating to: %1").arg(triggerOffset));
    }
    if ( (channelAEnabled == false) && (channelBEnabled == false) )
    {
        emit statusMessage(tr("All channels disabled."));
        return;
    }
    timer = new QTimer;
    timer->setSingleShot(true);
    connect(timer, SIGNAL(timeout()), SLOT(endWaiting()));
    ////////////////////////////////////////////////////////////////////////////////////////////////
    //  Writing config
    confArray[0] = 1;                                     // Run
    confArray[0] = continuous        << 1 | confArray[0]; // Cont
    confArray[0] = triggerOn         << 2 | confArray[0]; // TrOn
    confArray[0] = triggerSlope      << 3 | confArray[0]; // TrEdg
    confArray[0] = triggerChannel    << 4 | confArray[0]; // TrCh
    confArray[0] = timeScaleEnabled  << 5 | confArray[0]; // TScalEn
    confArray[0] = timeScaleValue    << 6 | confArray[0]; // TScal00..04

    confArray[1] = channelAEnabled;                       // RCh00
    confArray[1] = channelBEnabled   << 1 | confArray[1]; // RCh01

    confArray[2] = bufferSize;                            // BuffS00..13

    confArray[3] = triggerLevel;                          // TrLvl00..09

    confArray[4] = triggerOffset;                         // TrOff00..14

    /*
      ADR  NAME        MODE    [     15|     14|     13|     12|     11|     10|      9|      8|
                                      7|      6|      5|      4|      3|      2|      1|      0]    bits

       00   RunConf_R   RW     [       |       |       |       |       |TScal04|TScal03|TScal02|
    --                          TScal01|TScal00|TScalEn|   TrCh|  TrEdg|   TrOn|   Cont|  Start]
    --
    -- 01   Channels_R  RW     [       |       |       |       |       |       |       |       |
    --                                 |       |       |       |       |       |  RCh01|  RCh00]
    --
    -- 02   BuffSize_R  RW     [       |       |BuffS13|BuffS12|BuffS11|BuffS10|BuffS09|BuffS08|
    --                          BuffS07|BuffS06|BuffS05|BuffS04|BuffS03|BuffS02|BuffS01|BuffS00]
    --
    -- 03   TrigLvl_R   RW     [       |       |       |       |       |       |TrLvl09|TrLvl08|
    --                          TrLvl07|TrLvl06|TrLvl05|TrLvl04|TrLvl03|TrLvl02|TrLvl01|TrLvl00]
    --
    -- 04   TrigOff_R   RW     [       |TrOff14|TrOff13|TrOff12|TrOff11|TrOff10|TrOff09|TrOff08|
    --                          TrOff07|TrOff06|TrOff00|TrOff00|TrOff00|TrOff00|TrOff00|TrOff00]
    --
    -- 05   ADCConf     RW     [       |       |       |       |   ADCS|ADSleep| ADPSEn| ADPS08|
    --                           ADPS07| ADPS06| ADPS05| ADPS04| ADPS03| ADPS02| ADPS01| ADPS00]
    --
    -- 08   Data_O      R      [ErrFlag|RunFlag|       |       |       |  DCh00|  Dat09|  Dat08|
    --                            Dat07|  Dat06|  Dat05|  Dat04|  Dat03|  Dat02|  Dat01|  Dat00]
    --
    -- 09   Error_O     R      [       |       |       |       |       |       |       |       |
    --                                 |       |       |       |       | ErrN02| ErrN01| ErrN00]
    */


    EppParallelUseWin::PPStatusType status;

    status = port.negotiateEPP(portAddress);
    emit statusMessage(translateStatus(status));

    if (status != EppParallelUseWin::PP_CONECTED)
        return;

    status = port.testDataTransfer();
    for (int i = 4; i >= 0; i--)
    {
        port.writeWord(confArray[i], i);
        status = port.testDataTransfer();

        if (status != EppParallelUseWin::PP_CONECTED)
        {
            for (int j = 0; (j <= 5) && (status != EppParallelUseWin::PP_CONECTED); j++)
            {
                port.writeWord(confArray[i], i);
                status = port.testDataTransfer();
            }
            if (status != EppParallelUseWin::PP_CONECTED)
            {
                emit statusMessage(translateStatus(status));
                return;
            }
        }

    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //  Write and check stream address
    char address = 8;  // input data address
    port.testDataTransfer();
    port.writeAddress(address);
    port.readAddress(address);
    if (address != 8)
    {
        emit statusMessage(tr("Can't write an address"));
        return;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Getting data
    int count = 0;    
    bool oddBuffer = false;
    unsigned int data = 0x80; // stopped with errors


    dataUsed = false;
    port.testDataTransfer(); // clear time out flags
    channelData[0].clear();
    channelData[1].clear();


    if (triggerOn)
        emit statusMessage(tr("Waiting for trigger..."));
    else
        emit statusMessage(tr("Running"));

    do {
        port.readWord(data);
        status =  port.testDataTransfer();

        if ((status == EppParallelUseWin::PP_CONECTED) && (data != 0xFFFF))
        {
            // check running flag
            if ((data & 0x4000) == 0x0000 )
            {
                port.readWord(data ,0);
                port.readWord(data,8);
                if ((data & 0x4000) == 0x0000 )
                {
                    if (continuous)
                    {
                        emit statusMessage(tr("Error in data"));
                    }
                    else
                    {
                        checkDataSize();
                    }
                    bufferFull = true;
                    while (dataUsed == false && acqStopped == false) ;
                 //   emit endOfBuffer();
                    return;
                }
            }
            // if buffer is full

            else if ( ((data & 0x8000) == 0x0000) != oddBuffer)
            {
             //   emit endOfBuffer();
                dataUsed = false;
                bufferFull = true;
                checkDataSize();
                while (dataUsed == false && acqStopped == false) ;
                channelData[0].clear();
                channelData[1].clear();
            }

            // channel A
            else if ( (data & 0x0400) == 0x0400 )
            {
             //   emit chBNewData(0x3FF & data);
                channelData[0] << (0x3FF & data);
             //   oddBuffer = (data & 0x8000) == 0x0000 ;
            }
            // channel B
            else
            {
            //    emit chANewData(0x3FF & data);
                channelData[1] << (0x3FF & data);

            }
            oddBuffer = (data & 0x8000) == 0x0000 ;
            count = 0;
        }
        else
        {
            count++;
            if (count >= 500000)
            {
                if (triggerOn)
                {
                    statusMessage(tr("Still waiting for trigger..."));
                    count = 0;
                }
                else
                {
               //     emit endOfBuffer();
                    emit statusMessage(tr("Too much time out. Check the cable."));
                    return;
                }
            }
        }
    } while (acqStopped == false);

}


QList<int> RVICommThread::getChannelData(int channel)
{
    if (channel > 1 || channel < 0)
        channel = 0;
    dataUsed = true;
    bufferFull = false;
    return channelData[channel];
}

bool RVICommThread::isBufferFull()
{
    return bufferFull;
}



void RVICommThread::checkDataSize()
{
    if (channelAEnabled && channelBEnabled)
    {
        if ( (bufferSize != (channelData[0].size()-1)*2) && \
             (bufferSize != (channelData[1].size()-1)*2) )
            emit statusMessage(tr("Data size and buffer size not match"));
        else
            emit statusMessage(tr(""));
    }
    else if (channelAEnabled)
    {
        if (bufferSize != channelData[0].size())
            emit statusMessage(tr("Data size and buffer size not match"));
        else
            emit statusMessage(tr(""));
    }
    else
    {
        if (bufferSize != channelData[1].size())
            emit statusMessage(tr("Data size and buffer size not match"));
        else
            emit statusMessage(tr(""));
    }
}


QString RVICommThread::translateStatus(const EppParallelUseWin::PPStatusType &port_status)
{
  switch(port_status)
  {
    case EppParallelUseWin::PP_CONECTED:
        return QString( tr("Conected"));
        break;
    case EppParallelUseWin::PP_TIME_OUT:
        return QString( tr("Time Out"));
        break;
    case EppParallelUseWin::PP_COMUNICATION_FAIL:
        return QString( tr("Comunication fail at 0x%1").arg(portAddress, 0, 16));
        break;
    case EppParallelUseWin::PP_NEGOTIATION_FAIL:
        return QString( tr("Negotiation fail at 0x%1").arg(portAddress, 0, 16));
        break;
    case EppParallelUseWin::PP_LOAD_LIBRARY_FAIL:
       return QString( tr("Can´t load the library"));
        break;
    case EppParallelUseWin::PP_WRONG_BASE_ADDRESS:
        return QString( tr("Wrong port base address: 0x%1").arg(portAddress, 0, 16));
        break;
    default:
        return QString( tr("OK"));
        break;
  }
}

void RVICommThread::endWaiting()
{
    waiting = false;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
// Parameters
void RVICommThread::setAddress(const short int &address)
{
    portAddress = address;
}


void RVICommThread::setContinuous(const bool &on)
{
    continuous = on;
}


void RVICommThread::setTrigger(const bool &on, const bool &slope, const bool &channel, const int &level, const int &offset)
{
    triggerOn = on;
    triggerSlope = slope;
    triggerChannel = channel;
    triggerLevel = level;
    triggerOffset = offset;
}


void RVICommThread::setChannels(const bool &chAOn, const bool &chBOn)
{
    channelAEnabled = chAOn;
    channelBEnabled = chBOn;
}


void RVICommThread::setBuffer(const int &size)
{
    bufferSize = size;
}


void RVICommThread::setTimeScaler(const bool &on, const int &value)
{
    timeScaleEnabled = on;
    timeScaleValue = value;
}


void RVICommThread::setADCPreScale(const int &preScale)
{
    adcPreScaler = preScale;
}


void RVICommThread::stopAcquistion()
{
    acqStopped = true;
}


void RVICommThread::configADC()
{
    if (adcPreScaler > pow(2.0, 8) )
    {
        emit statusMessage("Too big pre scaler, setting to default value (1).");
        adcPreScaler = 1;
    }
    else
    {
        emit statusMessage(tr("ADC Config Writed."));
    }

    unsigned short int config;
    config = adcPreScaler;                     // clk_pre_scaler
    config = 1                 << 9  | config; // clk_pre_scaler_ena
    config = 0                 << 10 | config; // adc sleep
    config = 0                 << 11 | config; // adc_chip_sel

    // if clk_pre_scaler_ena = 1,
    // freq_adc = freq_wbn / ((clk_pre_scaler+1)*2)

    EppParallelUseWin::PPStatusType status;

    status = port.negotiateEPP(portAddress);


    if (status != EppParallelUseWin::PP_CONECTED)
    {
        emit statusMessage(translateStatus(status));
        return;
    }

    status = port.testDataTransfer();

    port.writeWord(config, 5);
    status = port.testDataTransfer();

    if (status != EppParallelUseWin::PP_CONECTED)
    {
        for (int j = 0; (j <= 5) && (status != EppParallelUseWin::PP_CONECTED); j++)
        {
            port.writeWord(config, 5);
            status = port.testDataTransfer();
        }
        if (status != EppParallelUseWin::PP_CONECTED)
        {
            emit statusMessage(translateStatus(status));
            return;
        }
    }

    aDCSampleRate = BASE_SAMPLE_RATE/adcPreScaler;

}

double RVICommThread::getADCSampleRate()
{
    return aDCSampleRate;
}
