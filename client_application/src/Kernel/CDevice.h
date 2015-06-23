/*
 * @file     Device.h
 * @date     May 14, 2012
 * @author   Aart Mulder
 */

#ifndef CDevice_h
#define CDevice_h

#include <QThread>
#include <QString>

#include "CDeviceState.h"

    /** @author Aart Mulder
     *  @version 1
     */
class CDevice : public QThread {
    /* {since=2011-12-09}*/

	Q_OBJECT

 public:
    CDevice(int nLoopTime, QString sName);
    virtual ~CDevice();
	void Start();
	void Pause();
	void Resume();
	void Stop();
    int GetLoopTime();
    QString GetName();

 protected:
	virtual void DeviceLoopWaitForStart();
    virtual void BeforeDeviceLoop()  = 0;
    virtual void DeviceLoop()  = 0;
    virtual void AfterDeviceLoop()  = 0;
	void DelayMs(int delay);

 private:
    /** 
     *  Needs local variable to store the last timestamp that the deviceloop has been executed.
     */
    void run();
    /* {deprecated=false}*/

	CDeviceState m_oDeviceState;

 protected:
	const QString m_sName;
	const int m_nLoopTime;
};

#endif // CDevice_h
