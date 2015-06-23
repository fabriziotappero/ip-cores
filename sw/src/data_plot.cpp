#include <stdlib.h>
#include <QFont>
#include <qwt_painter.h>
#include <qwt_plot_canvas.h>
#include <qwt_plot_marker.h>
#include <qwt_plot_curve.h>
#include <qwt_scale_widget.h>
#include <qwt_legend.h>
#include <qwt_scale_draw.h>
#include <qwt_plot_grid.h>
#include <qwt_math.h>
#include "data_plot.h"

//
//  Initialize main window
//
DataPlot::DataPlot(QWidget *parent):
    QwtPlot(parent)
{
    // Disable polygon clipping
    QwtPainter::setDeviceClipping(false);

    // We don't need the cache here
    canvas()->setPaintAttribute(QwtPlotCanvas::PaintCached, false);
    canvas()->setPaintAttribute(QwtPlotCanvas::PaintPacked, false);

    canvas()->setFocusIndicator(QwtPlotCanvas::ItemFocusIndicator);

    //canvas()->setPaintAttribute(QwtPlotCanvas::FocusIndicator, true);
#if QT_VERSION >= 0x040000
//#ifdef 1
    /*
       Qt::WA_PaintOnScreen is only supported for X11, but leads
       to substantial bugs with Qt 4.2.x/Windows
     */
    //canvas()->setAttribute(Qt::WA_PaintOnScreen, true);
//#endif
#endif

    alignScales();



    // Insert new curves
    curveA = new QwtPlotCurve("Channel A");
    curveA->attach(this);
    curveA->setData(0,0,0);
    curveA->setAxis(QwtPlot::xBottom, QwtPlot::yLeft);

    curveB = new QwtPlotCurve("Channel B");
    curveB->attach(this);
    curveB->setData(0,0,0);
    curveB->setAxis(QwtPlot::xBottom, QwtPlot::yRight);

    triggerLine = new QwtPlotMarker;
    triggerLine->attach(this);
    triggerLine->setYAxis(QwtPlot::yLeft);
    triggerLine->setYValue(0);
    triggerLine->setLineStyle(QwtPlotMarker::HLine);
    triggerLine->setLinePen(QPen(Qt::white, 0, Qt::SolidLine));
    enableTriggerLine(false, 0);

    // Axis 
    // setAxisTitle(QwtPlot::xBottom, "Time/seconds");
    setAxisScale(QwtPlot::xBottom, 0, 10);
    enableAxis(QwtPlot::xBottom, true);
    //setAxisTitle(QwtPlot::xBottom, "Time [s]");
    //setAxisMaxMinor(QwtPlot::yLeft, 20);
    //setAxisMaxMajor(QwtPlot::yLeft, 10);
    enableAxis(QwtPlot::yLeft, true);
    setAxisScale(QwtPlot::yLeft, -2, 2);
    setAxisTitle(QwtPlot::yLeft, tr("A"));
    axisTitle(QwtPlot::yLeft).setFont(QFont("Serif", 8));

    setAxisMaxMajor(QwtPlot::xBottom, 13);
    setAxisMaxMinor(QwtPlot::xBottom, 10);

    enableAxis(QwtPlot::yRight, true);
    setAxisScale(QwtPlot::yRight, -2, 2);
    setAxisTitle(QwtPlot::yRight, "B");


    setAxisFont(QwtPlot::xBottom, QFont("Serif", 8));
    setAxisFont(QwtPlot::yRight, QFont("Serif", 8));
    setAxisFont(QwtPlot::yLeft, QFont("Serif", 8));

    // grid
    gridA = new QwtPlotGrid();
    gridA->setAxis(QwtPlot::xBottom, QwtPlot::yLeft);

    gridA->setMajPen(QPen(Qt::white, 0, Qt::DotLine));
    gridA->setMinPen(QPen(Qt::white, 0 , Qt::DotLine));
    gridA->attach(this);


    gridB = new QwtPlotGrid();
    gridB->setAxis(QwtPlot::xBottom, QwtPlot::yRight);
    //gridA->enableXMin(true);
    gridB->enableX(false);
    gridB->setMajPen(QPen(Qt::gray, 0, Qt::DotLine));
    gridB->setMinPen(QPen(Qt::gray, 0 , Qt::DotLine));
    gridB->attach(this);

    alignScales();

    setPaused(false);

}

//
//  Set a plain canvas frame and align the scales to it
//
void DataPlot::alignScales()
{
    // The code below shows how to align the scales to
    // the canvas frame, but is also a good example demonstrating
    // why the spreaded API needs polishing.

    canvas()->setFrameStyle(QFrame::Box | QFrame::Plain );
    canvas()->setLineWidth(1);

    for ( int i = 0; i < QwtPlot::axisCnt; i++ )
    {
        QwtScaleWidget *scaleWidget = (QwtScaleWidget *)axisWidget(i);
        if ( scaleWidget )
            scaleWidget->setMargin(0);

        QwtScaleDraw *scaleDraw = (QwtScaleDraw *)axisScaleDraw(i);
        if ( scaleDraw )
            scaleDraw->enableComponent(QwtAbstractScaleDraw::Backbone, false);
    }
}



void DataPlot::setCurveAColor(const QColor &color)
{
    curveA->setPen(QPen(color));
    replot();
}


void DataPlot::setCurveBColor(const QColor &color)
{
    curveB->setPen(QPen(color));
    replot();
}

void DataPlot::setPaused(const bool &pause)
{
    paused = pause;
}

void DataPlot::curveAShow(const bool &show)
{
    if (show)
        curveA->attach(this);
    else
        curveA->detach();
}

void DataPlot::curveBShow(const bool &show)
{
    if (show)
        curveB->attach(this);
    else
        curveB->detach();
}


void DataPlot::curveAUpdate(QVector<double> time, QVector<double> chA)
{
    if (paused == false)
    {
        curveA->setData(time, chA);
        replot();
    }

    updateDivs();
}

void DataPlot::curveBUpdate(QVector<double> time, QVector<double> chB)
{
    
    if (paused == false)
    {
        curveB->setData(time, chB);
        replot();
    }

    updateDivs();
}

void DataPlot::updateDivs()
{
    QwtValueList tiks;
    // Get aDiv values
    tiks = gridA->yScaleDiv().ticks(QwtScaleDiv::MajorTick);
    aDiv = tiks.value(1, 0.0) - tiks.value(0, 0.0);
    aDiv = qAbs(aDiv);

    // Get bDiv values
    tiks = gridB->yScaleDiv().ticks(QwtScaleDiv::MajorTick);
    bDiv = tiks.value(1, 0.0) - tiks.value(0, 0.0);
    bDiv = qAbs(bDiv);

    // Get tDiv values
    tiks = gridA->xScaleDiv().ticks(QwtScaleDiv::MajorTick);
    tDiv = tiks.value(1, 0.0) - tiks.value(0, 0.0);
    tDiv = qAbs(tDiv);

    if (aDiv != 0.0)
        emit aScaleDivChanged(aDiv);
    else
        aDiv = 1e-5;

    if (bDiv != 0.0)
        emit aScaleDivChanged(bDiv);
    else
        bDiv = 1e-5;

    if (tDiv != 0.0)
        emit tScaleDivChanged(tDiv);
    else
        tDiv = 1/(20e6);

}

void  DataPlot::curveASetLimits(const double &down, const double &up)
{
    elementSetLimits(QwtPlot::yLeft, down, up);
}


void  DataPlot::curveAZoom(const int &value)
{
    elementZoom(QwtPlot::yLeft, value);
}

void  DataPlot::curveAMove(const int &value)
{
    elementZoom(QwtPlot::yLeft, value, true);
}

void DataPlot::curveAResetPos()
{
    double yUp, yDown;
    yUp = qAbs(axisScaleDiv(QwtPlot::yLeft)->upperBound());
    yDown = qAbs(axisScaleDiv(QwtPlot::yLeft)->lowerBound());
    if (yUp >= yDown)
        curveASetLimits(-yUp, yUp);
    else
        curveASetLimits(-yDown, yDown);
}


void  DataPlot::curveBSetLimits(const double &down, const double &up)
{
    elementSetLimits(QwtPlot::yRight, down, up);
}


void  DataPlot::curveBZoom(const int &value)
{
    elementZoom(QwtPlot::yRight, value);
}


void  DataPlot::curveBMove(const int &value)
{
    elementZoom(QwtPlot::yRight, value, true);
}


void DataPlot::curveBResetPos()
{
    double yUp, yDown;
    yUp = qAbs(axisScaleDiv(QwtPlot::yRight)->upperBound());
    yDown = qAbs(axisScaleDiv(QwtPlot::yRight)->lowerBound());
    if (yUp >= yDown)
        curveBSetLimits(-yUp, yUp);
    else
        curveBSetLimits(-yDown, yDown);
}


void DataPlot::timeSetLimits(const double &min, const double &max)
{
    elementSetLimits(QwtPlot::xBottom, min, max);
}

void DataPlot::timeZoom(const int &value)
{
    elementZoom(QwtPlot::xBottom, value);
}

void DataPlot::timeMove(const int &value)
{
    elementZoom(QwtPlot::xBottom, value, true);
}

void DataPlot::elementZoom(const int &axisId, const int &value, const bool &move)
{
    double up, down, div;

    switch(axisId)
    {
        case QwtPlot::yLeft:
            div = aDiv;
            break;

        case QwtPlot::yRight:
            div = bDiv;
            break;

        default:
            div = tDiv;
            break;
    }

    if (value == 0)  //auto scale
    {
        setAxisAutoScale(axisId);
    }
    else
    {
        up =  axisScaleDiv(axisId)->upperBound() - div * value/10.0 ;
        if (up >= 10.0)
            up = axisScaleDiv(axisId)->upperBound();


        down = move ? axisScaleDiv(axisId)->lowerBound() - div * value/10.0 :
               axisScaleDiv(axisId)->lowerBound() + div * value/10.0;

        if (down <= -10.0)
            down = axisScaleDiv(axisId)->lowerBound();

        setAxisScale(axisId, down, up);
    }

    updateDivs();
    replot();
}


void DataPlot::elementSetLimits(const int &axisId, const double &min, const double &max)
{
    if (min == 0 && max == 0)
        setAxisAutoScale(axisId);
    else
        setAxisScale(axisId,  \
                     min, \
                     max);
    replot();
    updateDivs();
}



void DataPlot::curveAShowGrid(const bool &on)
{
    elementShowGrid(QwtPlot::yLeft, on);
}


void DataPlot::curveBShowGrid(const bool &on)
{
    elementShowGrid(QwtPlot::yRight, on);
}


void DataPlot::timeShowGrid(const bool &on)
{
    elementShowGrid(QwtPlot::xBottom, on);
}

void DataPlot::elementShowGrid(const int &axisId, const bool &on)
{
    switch(axisId)
    {
        case QwtPlot::yLeft:
            gridA->enableY(on);
            break;

        case QwtPlot::yRight:
            gridB->enableY(on);
            break;

        default:
            gridA->enableX(on);
            break;
    }
    replot();
}



void DataPlot::enableTriggerLine(const bool &on, const  int &channel)
{
    int axisId;
    switch(channel)
    {
        case 1:
            axisId = QwtPlot::yRight;
            break;

        default:
            axisId = QwtPlot::yLeft;
            break;
    }

    triggerLine->setVisible(on);
    if(on)
    {
        triggerLine->show();
        triggerLine->setAxis(QwtPlot::xBottom, axisId);
        replot();
    }
    else
    {
        triggerLine->hide();
        replot();
    }
}

void DataPlot::setTriggerLineValue(double val)
{
    triggerLine->setYValue(val);
    replot();
}
