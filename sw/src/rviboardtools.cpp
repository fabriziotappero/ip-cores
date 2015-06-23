#include <cmath>
#include <QTimer>
#include <QString>
#include <QColorDialog>
#include <QInputDialog>
#include <qwt_counter.h>
#include "rviboardtools.h"
#include "ui_rviboardtools.h"

// temp
#include <QDir>


class Suffixer
{
public:
    Suffixer(double number = 0.0)
    {
        setNumber(number);
    }

    void setNumber(double number)
    {
        number = qAbs(number);
        if (number < 1e-9)
        {
            multiplier = 1e9;
            suffix = QString("p");
        }
        else if (number < 1e-6)
        {
            multiplier = 1e6;
            suffix = QString("n");
        }
        else if (number < 1e-3)
        {
            multiplier = 1e6;
            suffix = QString("u");
        }
        else if (number < 1.0)
        {
            multiplier = 1e3;
            suffix = QString("m");
        }
        else
        {
            multiplier = 1.0;
            suffix = QString("");
        }
    }

    double multiplier;
    QString suffix;
};


RVIBoardTools::RVIBoardTools(QWidget *parent)
    : QWidget(parent),
    ui(new Ui::RVIBoardTools)
{
    ui->setupUi(this);

    slidersTimer = new QTimer(this);
    slidersTimer->setInterval(550);

    dataTimer = new QTimer(this);
    dataTimer->setInterval(30);   // plot update time

    dataAVec = new QVector<double>;
    dataBVec = new QVector<double>;
    timeVec = new QVector<double>;
    board = new RVICommThread(this);


    // Timer for sliders
    connect(slidersTimer, SIGNAL(timeout()),this, SLOT(updateSlidersValues()));

    connect(ui->timeZoomSlider , SIGNAL(sliderPressed()), slidersTimer , SLOT(start()));
    connect(ui->timeZoomSlider, SIGNAL(sliderReleased()), slidersTimer, SLOT(stop()));
    connect(ui->timePosSlider , SIGNAL(sliderPressed()), slidersTimer , SLOT(start()));
    connect(ui->timePosSlider, SIGNAL(sliderReleased()), slidersTimer, SLOT(stop()));

    connect(ui->channelAZoomSlider , SIGNAL(sliderPressed()), slidersTimer , SLOT(start()));
    connect(ui->channelAZoomSlider, SIGNAL(sliderReleased()), slidersTimer, SLOT(stop()));
    connect(ui->channelAPosSlider, SIGNAL(sliderPressed()), slidersTimer , SLOT(start()));
    connect(ui->channelAPosSlider, SIGNAL(sliderReleased()), slidersTimer, SLOT(stop()));

    connect(ui->channelBZoomSlider , SIGNAL(sliderPressed()), slidersTimer , SLOT(start()));
    connect(ui->channelBZoomSlider, SIGNAL(sliderReleased()), slidersTimer, SLOT(stop()));
    connect(ui->channelBPosSlider, SIGNAL(sliderPressed()), slidersTimer , SLOT(start()));
    connect(ui->channelBPosSlider, SIGNAL(sliderReleased()), slidersTimer, SLOT(stop()));

    // Board connections
    //connect(board, SIGNAL(chANewData(int )), this, SLOT(chAAppData(int)) );
    //connect(board, SIGNAL(chBNewData(int )), this, SLOT(chBAppData(int)));
    //connect(board, SIGNAL(finished()),this,SLOT(uncheckRunButtons()));
    //connect(board, SIGNAL(endOfBuffer()), this, SLOT(showResults()),Qt::DirectConnection);
    connect(board, SIGNAL(statusMessage(QString)), this, SLOT(sendStatusMessage(QString)));
    connect(this, SIGNAL(stopAcquistion()), board, SLOT(stopAcquistion()), Qt::DirectConnection);
    // Timer for board
    connect(dataTimer, SIGNAL(timeout()), this, SLOT(showResults()), Qt::DirectConnection);


}

RVIBoardTools::~RVIBoardTools()
{
    delete ui;
}


void RVIBoardTools::setDefaultValues()
{
    // Fill trigger combo
    fillTriggerCombo();

    // Fill trigger Slope
    ui->trigSlopeCombo->addItem(QIcon(":/images/rising.png"),"Rising");
    ui->trigSlopeCombo->addItem(QIcon(":/images/falling.png"),"Falling");


    // Set Max-Min values
    ui->bufferSpinBox->setMaximum(MAX_BUFF_SIZE);
    ui->bufferSpinBox->setMinimum(MIN_BUFF_SIZE);




    fillSampleTimeCombo();

    // Data
    chAOffset = 0;
    chBOffset = 0;

    confTScal = 1023;
    confTScalEn = 1;

    paused = false;

    ui->bufferSpinBox->setValue(1000);
    setVoltMultipliers();
    updateTimeVec();


    // Signals
    emit timeChangeLimits(timeVec->first(), timeVec->last());
    emit channelAColorChanged( ui->channelAColorButton->palette().button().color());
    emit channelBColorChanged( ui->channelBColorButton->palette().button().color());

}


void RVIBoardTools::stop()
{
    if (!ui->runButton->isChecked())
    {
        dataTimer->stop();
        statusChanged("stop timer");
    }
   emit stopAcquistion();
   //board->terminate();
}

void RVIBoardTools::setPaused(const bool &on)
{
    paused = on;
    setEnabled(!on);
    if (on)
        emit statusChanged(tr("Paused"));
}

void RVIBoardTools::startAcquisition(const bool &continuous)
{
    bool ok;

//    if (board->isRunning())
//    {
//        //while (!board->isFinished())
//       // {
//            repaint();
//            stop();
//            board->quit();
//        //}
//    }

    emit timeChangeLimits(timeVec->first(), timeVec->last());

    board->setAddress(ui->addressBox->currentText().toShort(&ok, 16));
    board->setContinuous(continuous);
    board->setTrigger(ui->trigBox->isChecked(),
                     ui->trigSlopeCombo->currentText() == "Falling",
                     ui->trigSouceCombo->currentText() == "A",
                     ui->trigLevelSpinBox->value()* 1023/100,
                     ui->trigOffsetSpinBox->value());
    board->setChannels(ui->channelABox->isChecked(),
                      ui->channelBBox->isChecked());
    board->setBuffer(ui->bufferSpinBox->value());
    board->setTimeScaler(ui->sampleTimeCombo->currentIndex() > 0,
                        ui->sampleTimeCombo->currentIndex() - 1);

    board->start(QThread::LowestPriority);

    if (!dataTimer->isActive())
        dataTimer->start();

    disconnect(board, SIGNAL(finished()),this,SLOT(startAcquisition()));

}


void RVIBoardTools::showResults()
{
    if (!paused)
    {
        if ( ui->quickUpdateCheck->isChecked() || board->isBufferFull()  )
        {
            if (ui->channelABox->isChecked())
            {
                dataAVec->clear();
                data = board->getChannelData(0);
                if (data.size() > 5)
                {
                    for (int i = 0; i < data.size(); i++)
                        dataAVec->append((data.at(i) - 512)* chAVoltMultiplier + chAOffset);
                    emit channelAData(*timeVec, *dataAVec);
                }
            }
            if (ui->channelBBox->isChecked())
            {
                dataBVec->clear();
                data = board->getChannelData(1);
                if (data.size() > 5)
                {
                    for (int i = 0; i < data.size(); i++)
                        dataBVec->append((data.at(i) - 512) * chBVoltMultiplier + chBOffset);
                    emit channelBData(*timeVec, *dataBVec);
                }
            }
        }
    }
}


void RVIBoardTools::sendStatusMessage(const QString &status)
{
    emit statusChanged(status);
}



void RVIBoardTools::updateTimeVec()
{
    double deltaTime;
    deltaTime = pow(2.0,ui->sampleTimeCombo->currentIndex()) / board->getADCSampleRate();

    int size;
    size = ui->bufferSpinBox->value();
    if (ui->channelABox->isChecked() && ui->channelBBox->isChecked())
        size = size/2;

    timeVec->clear();
    timeVec->append(deltaTime * ui->trigOffsetSpinBox->value());
    for (int i = 1; i < size; i++)
        timeVec->append(timeVec->at(i-1) + deltaTime);
    //statusChanged(tr("Primero %1 y segundo %2").arg(timeVec->first()).arg(timeVec->last()));
}

void RVIBoardTools::setVoltMultipliers()
{
    if (!(ui->channelAZBtn->isChecked()))
    {
        if (ui->chASpan2VRadio->isChecked())
            chAVoltMultiplier = 2.0/1024;
        else
            chAVoltMultiplier = 1.0/1024;
    }
    else
        chAVoltMultiplier = 0.0;

    if (!(ui->channelBZBtn->isChecked()))
    {
        if (ui->chBSpan2VRadio->isChecked())
            chBVoltMultiplier = 2.0/1024;
        else
            chBVoltMultiplier = 1.0/1024;
    }
    else
        chBVoltMultiplier = 0.0;
}


void RVIBoardTools::uncheckRunButtons()
{
    ui->runButton->setChecked(false);
    ui->singleButton->setChecked(false);
}


QVector<double> RVIBoardTools::getData(RVIBoardTools::VariableType var)
{
    switch(var)
    {
        case RVIBoardTools::ChannelA:
            return *dataAVec;
            break;

        case RVIBoardTools::ChannelB:
            return *dataBVec;
            break;

        default:
            return *timeVec;
            break;
    }

}


///////////////////////////////////////////////////////////////////////
// Trigger

void RVIBoardTools::on_trigLevelSlider_valueChanged(int value)
{
    double d_value;
    if (ui->trigSouceCombo->currentText() == "B")
    {
        if (ui->chBSpan2VRadio->isChecked())
            d_value = (value - 50) * 2.0/50;
        else
            d_value = (value - 50) * 1.0/50;
    }
    else
    {
        if (ui->chASpan2VRadio->isChecked())
            d_value = (value - 50) * 2.0/50;
        else
            d_value = (value - 50) * 1.0/50;
    }
   emit changeTriggerValue(d_value);

}


void RVIBoardTools::on_trigLineCheck_toggled(bool checked)
{
    emit showTriggerLine(checked, ui->trigSouceCombo->currentIndex());
}


void RVIBoardTools::on_trigSouceCombo_currentIndexChanged(int index)
{
    emit showTriggerLine(ui->trigLineCheck->isChecked(), index);
        if (board->isRunning())
    {
        stop();
        connect(board, SIGNAL(finished()),this,SLOT(startAcquisition()));
    }

}

void RVIBoardTools::fillTriggerCombo()
{
    ui->trigSouceCombo->clear();
    if (ui->channelABox->isChecked() == true)
    {
        ui->trigSouceCombo->addItem("A");
    }
    if (ui->channelBBox->isChecked() == true)
    {
        ui->trigSouceCombo->addItem("B");
    }
}


////////////////////////////
// Channel A
void RVIBoardTools::on_channelABox_toggled(bool set)
{
    emit channelAEnabled(set);
}


void RVIBoardTools::on_channelAColorButton_clicked()
{
    QColorDialog *colorChooser = new QColorDialog();
    QColor color = colorChooser->getColor(ui->channelAColorButton->palette().button().color());
    ui->channelAColorButton->setPalette(color);
    emit channelAColorChanged( color);
}


void RVIBoardTools::setChannelADiv(double div)
{
    Suffixer mod(div);
    ui->channelAZoomSpinBox->setValue(div * mod.multiplier);
    ui->channelAZoomSpinBox->setSuffix(" " + mod.suffix + tr("V/Div"));
}


void RVIBoardTools::on_channelAZoomSlider_valueChanged(int value)
{
    if (value != 0 )
    {
        ui->channelAAutoButton->setChecked(false);
        emit channelAChangeDiv(value);

        if (!slidersTimer->isActive())
        {
            ui->channelAZoomSlider->setValue(0);
        }
    }
}


void RVIBoardTools::on_channelAZoomSlider_sliderReleased()
{
    ui->channelAZoomSlider->setValue(0);
}


void RVIBoardTools::on_channelAAutoButton_toggled(bool checked)
{
    if (checked)
    {
        emit channelAChangeDiv(0);
    }
    else
    {
        emit channelAChangeDiv(-1);
    }
}


void RVIBoardTools::on_channelAPosSlider_valueChanged(int value)
{
    if (value != 0 )
    {
        emit channelAMove(value);

        if (!slidersTimer->isActive())
        {
            ui->channelAPosSlider->setValue(0);
        }
    }
}

void RVIBoardTools::on_channelAPosSlider_sliderReleased()
{
    ui->channelAPosSlider->setValue(0);
}


void RVIBoardTools::on_channelAResetButton_pressed()
{
    emit channelAResetPos();
}


////////////////////////////
// Channel B
void RVIBoardTools::on_channelBBox_toggled(bool set)
{
    emit channelBEnabled(set);
}


void RVIBoardTools::on_channelBColorButton_clicked()
{
    QColorDialog *colorChooser = new QColorDialog();
    QColor color = colorChooser->getColor(ui->channelBColorButton->palette().button().color());
    ui->channelBColorButton->setPalette(color);
    emit channelBColorChanged( color);
}


void RVIBoardTools::setChannelBDiv(double div)
{
    Suffixer mod(div);
    ui->channelBZoomSpinBox->setValue(div * mod.multiplier);
    ui->channelBZoomSpinBox->setSuffix(" " + mod.suffix + tr("V/Div"));
}


void RVIBoardTools::on_channelBZoomSlider_valueChanged(int value)
{
    if (value != 0 )
    {
        ui->channelBAutoButton->setChecked(false);
        emit channelBChangeDiv(value);

        if (!slidersTimer->isActive())
        {
            ui->channelBZoomSlider->setValue(0);
        }
    }
}


void RVIBoardTools::on_channelBZoomSlider_sliderReleased()
{
    ui->channelBPosSlider->setValue(0);
}


void RVIBoardTools::on_channelBAutoButton_toggled(bool checked)
{
    if (checked)
    {
        emit channelBChangeDiv(0);
    }
    else
    {
        emit channelBChangeDiv(-1);
    }
}


void RVIBoardTools::on_channelBPosSlider_valueChanged(int value)
{
    if (value != 0 )
    {
        emit channelBMove(value);

        if (!slidersTimer->isActive())
        {
            ui->channelBPosSlider->setValue(0);
        }
    }
}

void RVIBoardTools::on_channelBPosSlider_sliderReleased()
{
    ui->channelBPosSlider->setValue(0);
}


void RVIBoardTools::on_channelBResetButton_pressed()
{
    emit channelBResetPos();
}



////////////////////////////
// Time

void RVIBoardTools::on_timeZoomSlider_valueChanged(int value)
{
    if (value != 0 )
    {
        ui->timeAutoButton->setChecked(false);
        emit timeChangeDiv(value);

        if (!slidersTimer->isActive())
        {
            ui->timeZoomSlider->setValue(0);
        }
    }
}


void RVIBoardTools::on_timeAutoButton_toggled(bool checked)
{
    if (checked)
    {
        emit channelAChangeDiv(0);
    }
    else
    {
        emit channelAChangeDiv(-1);
    }
}


void RVIBoardTools::setTimeDiv(double div)
{
    Suffixer mod(div);
    ui->timeZoomSpinBox->setValue(div * mod.multiplier);
    ui->timeZoomSpinBox->setSuffix(" " + mod.suffix + tr("s/Div"));
}


void RVIBoardTools::on_bufferSpinBox_valueChanged(int value)
{
    ui->trigOffsetSlider->setMaximum(value - 1);
    ui->trigOffsetSpinBox->setMaximum(value - 1);
    ui->trigOffsetSlider->setMinimum(-value);
    ui->trigOffsetSpinBox->setMinimum(-value);
    ui->trigOffsetSpinBox->setValue(0);

        if (board->isRunning())
    {
        stop();
        connect(board, SIGNAL(finished()),this,SLOT(startAcquisition()));
    }

}


void RVIBoardTools::on_timeZoomSlider_sliderReleased()
{
    ui->timeZoomSlider->setValue(0);
}


void RVIBoardTools::on_timePosSlider_sliderReleased()
{
    ui->timePosSlider->setValue(0);
}


void RVIBoardTools::on_timePosSlider_valueChanged(int value)
{
    if (value != 0 )
    {
        emit timeMove(value);

        if (!slidersTimer->isActive())
        {
            ui->timePosSlider->setValue(0);
        }
    }
}

void RVIBoardTools::fillSampleTimeCombo()
{
    double value;
    double freq = board->getADCSampleRate();
    for (int i = 0; i <= pow(2.0,SCALE_BITS); i++)
    {
        value = pow(2.0,i)/freq;
        if( value < 1e-3 )
            ui->sampleTimeCombo->addItem(QString("%L1 ns").arg(value*1e6));
        else if(value < 1)
            ui->sampleTimeCombo->addItem(QString("%L1 ms").arg(value*1e3));
        else
            ui->sampleTimeCombo->addItem(QString("%L1 s").arg(value));
    }
}
////////////////////////////
// Common

void  RVIBoardTools::updateSlidersValues()
{
    on_channelAZoomSlider_valueChanged(ui->channelAZoomSlider->value());
    on_channelAPosSlider_valueChanged(ui->channelAPosSlider->value());
    on_channelBZoomSlider_valueChanged(ui->channelAZoomSlider->value());
    on_channelBPosSlider_valueChanged(ui->channelAPosSlider->value());
    on_timeZoomSlider_valueChanged(ui->timeZoomSlider->value());
    on_timePosSlider_valueChanged(ui->timePosSlider->value());
}



void RVIBoardTools::on_runButton_toggled(bool checked)
{
    if (checked == true)
    {
        ui->runButton->setText(tr("Stop"));
        ui->singleButton->setEnabled(false);
        startAcquisition(true); // start continuous
    }
    else
    {
        ui->runButton->setText(tr("Start"));
        ui->singleButton->setEnabled(true);
        stop();
    }
}


void RVIBoardTools::on_singleButton_toggled(bool checked)
{
    if (checked == true)
    {
        ui->singleButton->setText(tr("Stop"));
        ui->runButton->setEnabled(false);
        startAcquisition(false); // start single
    }
    else
    {
        ui->singleButton->setText(tr("Single"));
        ui->runButton->setEnabled(true);
        stop();
    }
}




void RVIBoardTools::on_adcSampleButton_clicked()
{
     bool ok;
     QStringList items;
     int index;

    for (int i = 1; i <= pow(2.0, ADC_PS_BITS); i++)
    {
        items << tr("%1 Hz").arg(BASE_SAMPLE_RATE/i);
    }

     QString text = QInputDialog::getItem(this, tr("Set ADC sample rate"),
                                          tr("Sample rate:"), items, 0, false, &ok);

    index = items.indexOf(text);
    board->setAddress(ui->addressBox->currentText().toShort(&ok, 16));
    board->setADCPreScale(index);
    board->configADC();
    fillSampleTimeCombo();

}



void RVIBoardTools::on_trigSlopeCombo_currentIndexChanged(int index)
{
    if (board->isRunning())
    {
        stop();
        connect(board, SIGNAL(finished()),this,SLOT(startAcquisition()));
    }
}

void RVIBoardTools::on_trigOffsetSpinBox_valueChanged(int )
{
    if (board->isRunning())
    {
        stop();
        connect(board, SIGNAL(finished()),this,SLOT(startAcquisition()));
    }
}

void RVIBoardTools::on_trigLevelSpinBox_valueChanged(int )
{
    if (board->isRunning())
    {
        stop();
        connect(board, SIGNAL(finished()),this,SLOT(startAcquisition()));
    }
}

void RVIBoardTools::on_sampleTimeCombo_currentIndexChanged(int index)
{   
    if (board->isRunning())
    {
        stop();
        connect(board, SIGNAL(finished()),this,SLOT(startAcquisition()));
    }
}

void RVIBoardTools::on_trigBox_toggled(bool )
{

}
