/*
 * @file     DeviceState.cpp
 * @date     May 14, 2012
 * @author   Aart Mulder
 */

#include "CDeviceState.h"

CDeviceState::CDeviceState()
{
	this->m_eDeviceState = DEVICE_STATE_STOP;
}

CDeviceState::~CDeviceState()
{
}

EDeviceState CDeviceState::GetDeviceState()
{
	EDeviceState eDeviceState;
	this->m_oMutex.lock();
	eDeviceState = this->m_eDeviceState;
	this->m_oMutex.unlock();
	return eDeviceState;
}

void CDeviceState::SetDeviceState(EDeviceState eDeviceState)
{
	this->m_oMutex.lock();
	this->m_eDeviceState = eDeviceState;
	this->m_oMutex.unlock();
}
