#ifndef _DATA_PLOT_H
#define _DATA_PLOT_H 1

#include <qwt_plot.h>
#include <qwt_plot_curve.h>
#include <qwt_plot_grid.h>
#include <qwt_plot_marker.h>
//#include <qwt_picker.h>
#include <qwt_plot_picker.h>
#include <qwt_plot_rescaler.h>

//const int PLOT_SIZE = 600;      // 0 to 200

class DataPlot : public QwtPlot
{
    Q_OBJECT


    public:
        DataPlot(QWidget* = NULL);
        void updateDivs();


    public slots:
        //  void setTimerInterval(double interval);
        void enableTriggerLine(const bool &on, const  int &channel);
        void setTriggerLineValue(double val);

        void setCurveAColor(const QColor &color);
        void setCurveBColor(const QColor &color);
        void setPaused(const bool &pause);
        void curveAShow(const bool &show);
        void curveBShow(const bool &show);
        void curveAUpdate(QVector<double> time, QVector<double> chA);
        void curveBUpdate(QVector<double> time, QVector<double> chB);

        void curveASetLimits(const double &down, const double &up);
        void curveAZoom(const int &value);
        void curveAMove(const int &value);
        void curveAResetPos();
        void curveBSetLimits(const double &down, const double &up);
        void curveBZoom(const int &value);
        void curveBMove(const int &value);
        void curveBResetPos();
        void timeSetLimits(const double &min, const double &max);
        void timeZoom(const int &value);
        void timeMove(const int &value);

        void curveAShowGrid(const bool &on);
        void curveBShowGrid(const bool &on);
        void timeShowGrid(const bool &on);




    private:
        void alignScales();
        void elementZoom(const int &axisId, const int &value, const bool &move = 0);
        void elementSetLimits(const int &axisId, const double &min, const double &max);
        void elementShowGrid(const int &axisId, const bool &on);

        QwtPlotGrid *gridA;
        QwtPlotGrid *gridB;

        // QwtPlotGrid *gridB;
        bool paused;
        double aDiv;
        double bDiv;
        double tDiv;

        QwtPlotCurve *curveA;
        QwtPlotCurve *curveB;
        QwtPlotMarker *triggerLine;
        QwtPlotRescaler *aRescaler;
        QwtPlotRescaler *bRescaler;
        QwtPlotRescaler *tRescaler;


    signals:
        void tScaleDivChanged(double );
        void aScaleDivChanged(double );
        void bScaleDivChanged(double );
};

#endif



