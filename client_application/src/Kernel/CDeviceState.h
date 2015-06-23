/*
 * @file     DeviceState.h
 * @date     May 14, 2012
 * @author   Aart Mulder
 */

#ifndef CDeviceState_h
#define CDeviceState_h

#include <QMutex>

enum EDeviceState
{
	DEVICE_STATE_UNKNOWN,
	DEVICE_STATE_WAIT_FOR_FIRST_START,
	DEVICE_STATE_STOP,
	DEVICE_STATE_RUN,
	DEVICE_STATE_PAUSE,

	NR_OF_DEVICE_STATES
};


class CDeviceState {

 public:

    CDeviceState();

    virtual ~CDeviceState();

    EDeviceState GetDeviceState();

	void SetDeviceState(EDeviceState eDeviceState);

 public:
    EDeviceState m_eDeviceState;
	QMutex m_oMutex;
};

#endif // CDeviceState_h
