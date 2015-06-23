#ifndef RVIOSCILLOSCOPE_H
#define RVIOSCILLOSCOPE_H

#include <QtGui/QMainWindow>
#include <qwt_plot_zoomer.h>
#include <qwt_plot_panner.h>
#include "data_plot.h"
#include "rviboardtools.h"

namespace Ui
{
    class RVIOscilloscope;
}

class RVIOscilloscope : public QMainWindow
{
    Q_OBJECT

public:
    RVIOscilloscope(QWidget *parent = 0);
    ~RVIOscilloscope();

private:
    Ui::RVIOscilloscope *ui;

    QwtPlotZoomer *d_zoomer[2];
    QwtPlotPanner *d_panner;
    QAction *zoomAct;

    DataPlot *plot;
    RVIBoardTools *extraTools;

    void createPlot();

private slots:
    void on_actionSaveData_triggered();
    void on_actionBackgroundColor_triggered();
    void enableZoomMode(bool on);
    void setDockedControlsDock(bool set);
    void exportSVG();
    void updateZoomLimits();
};

#endif // RVIOSCILLOSCOPE_H
