#ifndef UPDATEDETECTTHREAD_H
#define UPDATEDETECTTHREAD_H
#include <QThread>

class EziDebugPrj ;
class QTimer ;
class UpdateDetectThread : public QThread
{
    Q_OBJECT
public:
    UpdateDetectThread(EziDebugPrj *prj,QObject *parent = 0);
    //~UpdateDetectThread();

protected:
    void run();
signals:
    void codeFileChanged(void) ;
public slots:
    void update();
private:
    EziDebugPrj *  m_pprj ;
    QTimer  *    m_ptimer ;
};

#endif // UPDATEDETECTTHREAD_H
