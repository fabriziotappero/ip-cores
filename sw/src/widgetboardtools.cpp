#include "widgetboardtools.h"
#include "ui_widgetboardtools.h"

WidgetBoardTools::WidgetBoardTools(QWidget *parent)
    : QWidget(parent), ui(new Ui::WidgetBoardTools)
{
    maxBufferSize = 1000;
    minBufferSize = 20;
    scaleBits = 5;
    sampleRate = 20e6;
    timeDivitions = 10;
    hSamplesNumber = 200;

    ui->setupUi(this);
    fillTriggerCombo();
    fillTriggerSlope();
    on_bufferSlider_valueChanged(1000);
    setUpMaxValues();




}

WidgetBoardTools::~WidgetBoardTools()
{
    delete ui;
}



void WidgetBoardTools::fillTriggerCombo()
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

void WidgetBoardTools::fillTriggerSlope()
{
    ui->trigSlopeCombo->addItem(QIcon(":/images/rising.png"),"Rising");
    ui->trigSlopeCombo->addItem(QIcon(":/images/falling.png"),"Falling");
}


void WidgetBoardTools::setUpMaxValues()
{

    ui->bufferSpinBox->setMaximum(maxBufferSize);
//    ui->bufferSlider->setMaximum(maxBufferSize);
    ui->bufferSpinBox->setMinimum(minBufferSize);
//    ui->bufferSlider->setMinimum(minBufferSize);

    float timePositions = 2^scaleBits;
    float period = 1/sampleRate;
    float positionValue;
    float maxPositionValue;
    int samplesPerDiv = hSamplesNumber/timeDivitions;
    positionValue = period*samplesPerDiv;
    maxPositionValue = period*samplesPerDiv*timePositions;
    ui->timeScaleSpinBox->setDecimals(9);
    ui->timeScaleSpinBox->setMaximum(timeDivitions*positionValue*timePositions);
    ui->timeScaleSpinBox->setMinimum(0);
    ui->timeScaleSpinBox->setSingleStep(positionValue);

//    ui->timeScaleKnob->Qwt
//
//  TickType {
//   NoTick = -1,
//   MinorTick,
//   MediumTick,
//   MajorTick,
//   NTickTypes
// }

}

void WidgetBoardTools::on_bufferSlider_valueChanged(int value)
{
    ui->trigOffsetSlider->setMaximum(value - 1);
    ui->triggerOffsetSpinBox->setMaximum(value - 1);
    ui->trigOffsetSlider->setMinimum(-value);
    ui->triggerOffsetSpinBox->setMinimum(-value);
    ui->triggerOffsetSpinBox->setValue(0);
}



void WidgetBoardTools::on_runButton_clicked(bool checked)
{
    if (checked == true)
        ui->runButton->setText(tr("Stop"));
    else
        ui->runButton->setText(tr("Start"));

}
