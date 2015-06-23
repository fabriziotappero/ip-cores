#ifndef RVICOMMTHREAD_H
#define RVICOMMTHREAD_H

#include <QThread>
#include <QTimer>
#include "include/epp_parallel_use_win.h"


const int MAX_BUFF_SIZE= 15359;// = 15359;  size of memory address bus
const int MIN_BUFF_SIZE = 20;
const int SCALE_BITS = 5; // bits for data skipper
const double BASE_SAMPLE_RATE = 20e6;
const int PLOT_SIZE = 15359;
const int ADC_PS_BITS = 5;


class RVICommThread : public QThread
{
    Q_OBJECT

    public:
        RVICommThread(QObject *parent);
        ~RVICommThread();
        // Reimplementation
        void run();

        // Control
        void setAddress(const short int &address);
        void setContinuous(const bool &on);
        void setTrigger(const bool &on, const bool &slope, const bool &channel, const int &level, \
                        const int &offset);
        void setChannels(const bool &chAOn, const bool &chBOn);
        void setBuffer(const int &size);
        void setTimeScaler(const bool &on, const int &value);

        // ADC
        void setADCPreScale(const int &preScale);

        // Data
        QList<int> getChannelData(int channel);
        bool isBufferFull();
        double getADCSampleRate();

    public slots:
        void stopAcquistion();
        void configADC();

    private slots:
        void endWaiting();

    signals:
        void chANewData(int val);
        void chBNewData(int val);
        void statusMessage(QString message);
        void endOfBuffer();

    private:
        QString translateStatus(const EppParallelUseWin::PPStatusType &port_status);
        EppParallelUseWin port;
        void checkDataSize();
        bool acqStopped;
        bool dataUsed;
        bool bufferFull;

        //Data
        QList<int>   channelData[2]; // two channels
        // Timer
        QTimer *timer;
        bool waiting;
        // Config variables
        short int portAddress;
        bool continuous;
        bool triggerOn;
        bool triggerSlope;
        bool triggerChannel;
        bool timeScaleEnabled;
        int  timeScaleValue;
        bool channelAEnabled;
        bool channelBEnabled;
        int  bufferSize;
        int  triggerLevel;
        int  triggerOffset;
        // ADC
        int adcPreScaler;

        // Values
        double aDCSampleRate;

};

#endif // RVICOMMTHREAD_H



