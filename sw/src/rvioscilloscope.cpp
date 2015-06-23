#include <QtGui>
#include <QSvgGenerator>
#include <QFileDialog>
#include "rvioscilloscope.h"
#include <qwt_counter.h>
#include <qwt_plot_zoomer.h>
#include "data_plot.h"
#include "ui_rvioscilloscope.h"
#include <qwt_plot_picker.h>
#include <qwt_picker_machine.h>


class Zoomer: public QwtPlotZoomer
{
public:
    Zoomer(int xAxis, int yAxis, QwtPlotCanvas *canvas):
        QwtPlotZoomer(xAxis, yAxis, canvas)
    {
        setTrackerMode(QwtPicker::AlwaysOff);
        setRubberBand(QwtPicker::NoRubberBand);

        // RightButton: zoom out by 1
        // Ctrl+RightButton: zoom out to full size

        setMousePattern(QwtEventPattern::MouseSelect2,
            Qt::RightButton, Qt::ControlModifier);

        setMousePattern(QwtEventPattern::MouseSelect3,
            Qt::RightButton);

    }
};


RVIOscilloscope::RVIOscilloscope(QWidget *parent)
    : QMainWindow(parent), ui(new Ui::RVIOscilloscope)
{
    ui->setupUi(this);

    extraTools = new RVIBoardTools(this);
    ui->toolsLayout->addWidget(extraTools);

    createPlot();



    // zoom
    d_zoomer[0] = new Zoomer( QwtPlot::xBottom, QwtPlot::yLeft,
    plot->canvas());
    d_zoomer[0]->setRubberBand(QwtPicker::RectRubberBand);
    d_zoomer[0]->setRubberBandPen(QColor(Qt::green));
    d_zoomer[0]->setTrackerMode(QwtPicker::ActiveOnly);
    d_zoomer[0]->setTrackerPen(QColor(Qt::white));

    d_zoomer[1] = new Zoomer(QwtPlot::xTop, QwtPlot::yRight,
    plot->canvas());

    d_panner = new QwtPlotPanner(plot->canvas());
    d_panner->setMouseButton(Qt::MidButton);



    enableZoomMode(false);


    // picker
    QwtPlotPicker *selectLine = new QwtPlotPicker( QwtPlot::xBottom, QwtPlot::yLeft ,
                                    QwtPlotPicker::VLineRubberBand,
                                    QwtPlotPicker::AlwaysOff,
                                    plot->canvas());

    //selectLine->setRubberBand(QwtPlotPicker::VLineRubberBand);
        selectLine->setStateMachine(new QwtPickerClickPointMachine);
    selectLine->setAxis(QwtPlot::xBottom, QwtPlot::yLeft);
    selectLine->setRubberBandPen(QPen(Qt::yellow, 0, Qt::SolidLine));
    selectLine->setEnabled(true);

    //selectLine->begin();
    //selectLine->append(QPoint(0,0));
    selectLine->setTrackerPen(QColor(Qt::white));


    connect(ui->actionDockControls,SIGNAL(triggered(bool)), this, SLOT(setDockedControlsDock(bool)));
    connect(ui->controlsDock,SIGNAL(topLevelChanged(bool)), ui->actionDockControls, SLOT(toggle()));
    connect(ui->actionShowControls, SIGNAL(toggled(bool)), ui->controlsDock, SLOT(setVisible(bool)));
    connect(ui->controlsDock, SIGNAL(visibilityChanged(bool)), ui->actionShowControls, SLOT(setChecked(bool)));

    connect(ui->actionZoom, SIGNAL(triggered(bool)), this,  SLOT(enableZoomMode(bool)));
    connect(ui->actionSaveImage, SIGNAL(triggered()), SLOT(exportSVG()));
    connect(ui->actionPause, SIGNAL(toggled(bool)), plot, SLOT(setPaused(bool)));
    connect(ui->actionPause, SIGNAL(toggled(bool)), extraTools, SLOT(setPaused(bool)));

    connect(ui->actionEnChAGrid, SIGNAL(triggered(bool)), plot, SLOT(curveAShowGrid(bool)));
    connect(ui->actionEnChBGrid, SIGNAL(triggered(bool)), plot, SLOT(curveBShowGrid(bool)));
    connect(ui->actionEnTimeGrid, SIGNAL(triggered(bool)), plot, SLOT(timeShowGrid(bool)));

    connect(extraTools, SIGNAL(statusChanged(QString)) ,ui->statusBar, SLOT(showMessage(QString)));
    connect(extraTools, SIGNAL(channelAEnabled(bool)), plot, SLOT(curveAShow(bool)));
    connect(extraTools, SIGNAL(channelBEnabled(bool)), plot, SLOT(curveBShow(bool)));
    connect(extraTools, SIGNAL(channelAColorChanged(QColor)),plot,SLOT(setCurveAColor(QColor)));
    connect(extraTools, SIGNAL(channelBColorChanged(QColor)),plot,SLOT(setCurveBColor(QColor)));
    connect(extraTools, SIGNAL(channelAData(QVector<double> , QVector<double> )),plot,SLOT(curveAUpdate(QVector<double>,QVector<double>)));
    connect(extraTools, SIGNAL(channelBData(QVector<double> , QVector<double> )),plot,SLOT(curveBUpdate(QVector<double> , QVector<double> )));
    connect(plot, SIGNAL(aScaleDivChanged(double)), extraTools, SLOT(setChannelADiv(double)));
    connect(plot, SIGNAL(tScaleDivChanged(double)), extraTools, SLOT(setTimeDiv(double)));
    //connect(extraTools, SIGNAL(channelAChangeDiv(double,double)),plot,SLOT(curveASetLimits(double,double)));
    connect(extraTools, SIGNAL(channelAChangeDiv(int)), plot, SLOT(curveAZoom(int)));
    connect(extraTools, SIGNAL(channelAMove(int)), plot, SLOT(curveAMove(int)));
    connect(extraTools, SIGNAL(channelAResetPos()), plot, SLOT(curveAResetPos()));
    connect(extraTools, SIGNAL(channelBChangeDiv(int)), plot, SLOT(curveBZoom(int)));
    connect(extraTools, SIGNAL(channelBMove(int)), plot, SLOT(curveBMove(int)));
    connect(extraTools, SIGNAL(channelBResetPos()), plot, SLOT(curveBResetPos()));
    connect(extraTools, SIGNAL(timeChangeDiv(int)), plot, SLOT(timeZoom(int)));
    connect(extraTools, SIGNAL(timeMove(int)), plot, SLOT(timeMove(int)));
    connect(extraTools, SIGNAL(timeChangeLimits(double,double)), plot, SLOT(timeSetLimits(double,double)));
    connect(extraTools, SIGNAL(timeChangeLimits(double,double)), this, SLOT(updateZoomLimits()));

    connect(extraTools, SIGNAL(showTriggerLine(bool, int)),plot,SLOT(enableTriggerLine(bool, int)));
    connect(extraTools, SIGNAL(changeTriggerValue(double)),plot,SLOT(setTriggerLineValue(double)));

    extraTools->setDefaultValues();
    plot->updateDivs();
}

RVIOscilloscope::~RVIOscilloscope()
{
    delete ui;
}


void RVIOscilloscope::createPlot()
{

    plot = new DataPlot(this);
    //setCentralWidget(plot);
    ui->mainLayout->addWidget(plot);
    plot->setMinimumHeight(200);
    plot->setMinimumWidth(200);
    plot->setCanvasBackground(QColor(Qt::black));

    plot->setCurveAColor(Qt::red);
    plot->setCurveBColor(Qt::yellow);
//    QSizePolicy sizePolicy(QSizePolicy::Preferred, QSizePolicy::Preferred);
//    sizePolicy.setVerticalStretch(30);
//    plot->setSizePolicy(sizePolicy);
    //plot->setMargin(12);

}


void RVIOscilloscope::enableZoomMode(bool on)
{
    d_panner->setEnabled(on);

    d_zoomer[0]->setEnabled(on);
   // d_zoomer[0]->zoom(0);

    d_zoomer[1]->setEnabled(on);
   // d_zoomer[1]->zoom(0);
}


void RVIOscilloscope::updateZoomLimits()
{
    d_zoomer[0]->setZoomBase();
    d_zoomer[1]->setZoomBase();
}


void RVIOscilloscope::on_actionBackgroundColor_triggered()
{
    QColorDialog *colorChooser = new QColorDialog(plot->canvasBackground());
    plot->setCanvasBackground(colorChooser->getColor());

}

void RVIOscilloscope::setDockedControlsDock(bool set)
{
    ui->controlsDock->setFloating(!(set));
}

void RVIOscilloscope::exportSVG()
{
    QString fileName = "plot.svg";

    fileName = QFileDialog::getSaveFileName(
        this, "Export File Name", QString(),
        "SVG Documents (*.svg)");

    if ( !fileName.isEmpty() )
    {
        QSvgGenerator generator;
        generator.setFileName(fileName);
        generator.setSize(QSize(800, 600));

        plot->print(generator);
    }

}

void RVIOscilloscope::on_actionSaveData_triggered()
{
    QString fileName = "data";

    fileName = QFileDialog::getSaveFileName(
        this, "File name:", fileName,
        "Text file (*.txt);;All files (*.*)");

    if ( !fileName.isEmpty() )
    {
        QFile file(fileName);

        if (file.open(QFile::WriteOnly | QFile::Truncate))
        {
             QTextStream out(&file);
             out << qSetFieldWidth(15) << right << "Time"  << "Channel A" << "Channel B" << endl;
             for (int i = 0; i < extraTools->getData(RVIBoardTools::Time).size(); i++)
             {
                 out << qSetFieldWidth(15) << right  \
                     << extraTools->getData(RVIBoardTools::Time).value(i, 0.0)\
                     << extraTools->getData(RVIBoardTools::ChannelA).value(i, 0.0) \
                     << extraTools->getData(RVIBoardTools::ChannelB).value(i, 0.0) << endl;
             }

        }
    }
}
