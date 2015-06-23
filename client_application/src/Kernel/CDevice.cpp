/*
 * @file     Device.cpp
 * @date     May 14, 2012
 * @author   Aart Mulder
 */

#include <QTime>

#include "CDevice.h"

    /** @author Aart Mulder
     *  @version 1
     */

    /* {since=2011-12-09}*/

CDevice::CDevice(int nLoopTime, QString sName) : QThread(NULL), m_nLoopTime(nLoopTime), m_sName(sName)
{
	this->m_oDeviceState.SetDeviceState(DEVICE_STATE_WAIT_FOR_FIRST_START);

	this->start();
}

CDevice::~CDevice()
{
}

void CDevice::Start()
{
	if(this->m_oDeviceState.GetDeviceState() == DEVICE_STATE_WAIT_FOR_FIRST_START)
	{
		this->m_oDeviceState.SetDeviceState(DEVICE_STATE_RUN);
	}
}

void CDevice::Pause()
{
	if(this->m_oDeviceState.GetDeviceState() == DEVICE_STATE_RUN)
	{
		this->m_oDeviceState.SetDeviceState(DEVICE_STATE_PAUSE);
	}
}

void CDevice::Resume()
{
	if(this->m_oDeviceState.GetDeviceState() == DEVICE_STATE_PAUSE)
	{
		this->m_oDeviceState.SetDeviceState(DEVICE_STATE_RUN);
	}
}

void CDevice::Stop()
{
	this->m_oDeviceState.SetDeviceState(DEVICE_STATE_STOP);
}

int CDevice::GetLoopTime()
{
	return m_nLoopTime;
}

QString CDevice::GetName()
{
	return m_sName;
}

void CDevice::DelayMs(int delay)
{
	this->msleep(delay);
}

void CDevice::DeviceLoopWaitForStart()
{

}

/** 
 *  Needs local variable to store the last timestamp that the deviceloop has been executed.
 */
void CDevice::run()
{
	QTime elapsedTimer;

	while(this->m_oDeviceState.GetDeviceState() == DEVICE_STATE_WAIT_FOR_FIRST_START)
	{
		DeviceLoopWaitForStart();
		this->msleep(this->m_nLoopTime);
	}

	this->BeforeDeviceLoop();

	try
	{
		while(this->m_oDeviceState.GetDeviceState() != DEVICE_STATE_STOP
			  && this->m_oDeviceState.GetDeviceState() != DEVICE_STATE_UNKNOWN)
		{
			while(this->m_oDeviceState.GetDeviceState() == DEVICE_STATE_PAUSE)
			{
				this->msleep(this->m_nLoopTime);
			}

			while(this->m_oDeviceState.GetDeviceState() == DEVICE_STATE_RUN)
			{
				elapsedTimer.restart();

				this->DeviceLoop();

				int nSleep = (elapsedTimer.elapsed() < m_nLoopTime ? m_nLoopTime-elapsedTimer.elapsed() : 0);

				this->msleep(nSleep);
			}
		}
	}
	catch(...)
	{
		//Handle ERROR
	}

	this->AfterDeviceLoop();
}
