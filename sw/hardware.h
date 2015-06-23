#ifndef __HARDWARE_H__
#define __HARDWARE_H__

// NOTE: Update to match actual addresses in your system!

#ifndef TIMER_HW_VAL
    // TODO: Update to match address of timer peripheral
    //       Expected to return time in ms
    #define TIMER_HW_VAL    (*((volatile unsigned int*) (0x12000100)))
#endif

#ifndef USB_FUNC_BASE
    // TODO: Update to match address of USB device core
    #define USB_FUNC_BASE       0x13000000
#endif

#endif
