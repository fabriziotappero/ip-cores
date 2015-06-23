#ifndef RVIBOARDTOOLS_H
#define RVIBOARDTOOLS_H


#include <QtGui/QWidget>
#include <QString>
#include <QTimer>
#include <QVector>
#include <QString>
//#include <qwt_array.h> // ??
#include "rvicommthread.h"



namespace Ui
{
    class RVIBoardTools;
}

class RVIBoardTools : public QWidget
{
    Q_OBJECT

public:

    enum VariableType
    {
        Time = 0,
        ChannelA = 1,
        ChannelB = 2
    };

    RVIBoardTools(QWidget *parent = 0);
    ~RVIBoardTools();
    void setDefaultValues();

    QVector<double> getData(VariableType var = Time);


signals:
    // ch A
    void channelAEnabled(bool set);
    void channelAData(QVector<double> time, QVector<double> chA);
    void channelAColorChanged(QColor );
    void channelAChangeDiv(int value);
    void channelAMove(int value);
    void channelAResetPos();
    // ch B
    void channelBEnabled(bool set);
    void channelBData(QVector<double> time, QVector<double> chB);
    void channelBColorChanged(QColor );
    void channelBChangeDiv(int value);
    void channelBMove(int value);
    void channelBResetPos();
    // time
    void timeChangeDiv(int value);
    void timeMove(int value);
    void timeChangeLimits(double, double);
     // trigger
    void showTriggerLine(bool, int);
    void changeTriggerValue(double);
    // adq
    void statusChanged(QString);
    void stopAcquistion();


private:
    Ui::RVIBoardTools *ui;


    RVICommThread *board;
    QTimer *slidersTimer;
    QTimer *dataTimer;

    QVector<double> *dataAVec;
    QVector<double> *dataBVec;
    QVector<double> *timeVec;
    QList<int> data;

    short int confTScal;
    bool confTScalEn;

    bool paused;

    double chAVoltMultiplier;
    double chBVoltMultiplier;
    double chAOffset;
    double chBOffset;


public slots:
     void setChannelADiv(double div);
     void setChannelBDiv(double div);
     void setTimeDiv(double div);
     void setPaused(const bool &on);

private slots:
    // Actions from UI
    // chA
    void on_trigBox_toggled(bool );
    void on_sampleTimeCombo_currentIndexChanged(int index);
    void on_trigLevelSpinBox_valueChanged(int );
    void on_trigOffsetSpinBox_valueChanged(int );
    void on_trigSlopeCombo_currentIndexChanged(int index);
    void on_channelAColorButton_clicked();
    void on_channelABox_toggled(bool set);
    void on_channelAZoomSlider_valueChanged(int value);
    void on_channelAZoomSlider_sliderReleased();
    void on_channelAResetButton_pressed();
    void on_channelAPosSlider_sliderReleased();
    void on_channelAPosSlider_valueChanged(int value);
    void on_channelAAutoButton_toggled(bool checked);
    // chB
    void on_channelBColorButton_clicked();
    void on_channelBBox_toggled(bool set);
    void on_channelBPosSlider_sliderReleased();
    void on_channelBResetButton_pressed();
    void on_channelBAutoButton_toggled(bool checked);
    void on_channelBZoomSlider_sliderReleased();
    void on_channelBZoomSlider_valueChanged(int value);
    void on_channelBPosSlider_valueChanged(int value);
    // Trigg
    void on_trigSouceCombo_currentIndexChanged(int index);
    void on_trigLineCheck_toggled(bool checked);
    void on_timeAutoButton_toggled(bool checked);
    void on_trigLevelSlider_valueChanged(int value);
    // Time
    void on_timePosSlider_valueChanged(int value);
    void on_timePosSlider_sliderReleased();
    void on_timeZoomSlider_sliderReleased();
    void on_adcSampleButton_clicked();
    void on_timeZoomSlider_valueChanged(int value);
    void on_bufferSpinBox_valueChanged(int value);
    // aqc
    void on_singleButton_toggled(bool checked);
    void on_runButton_toggled(bool checked);



    void setVoltMultipliers();
    void updateSlidersValues();
    void uncheckRunButtons();

    void startAcquisition(const bool &continuous = true);
    void stop();
    void showResults();
    void sendStatusMessage(const QString &status);
    void updateTimeVec();
    void fillTriggerCombo();
    void fillSampleTimeCombo();


};

#endif // RVIBOARDTOOLS_H
