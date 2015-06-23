#include "epp_parallel_access_win.h"

PORTOUT PortOut;
PORTWORDOUT PortWordOut;
PORTDWORDOUT PortDWordOut;
PORTIN PortIn;
PORTWORDIN PortWordIn;
PORTDWORDIN PortDWordIn;
SETPORTBIT SetPortBit;
CLRPORTBIT ClrPortBit;
NOTPORTBIT NotPortBit;
GETPORTBIT GetPortBit;
RIGHTPORTSHIFT RightPortShift;
LEFTPORTSHIFT LeftPortShift;
ISDRIVERINSTALLED IsDriverInstalled;

HMODULE hio;

void UnloadIODLL() {
	FreeLibrary(hio);
}

int LoadIODLL() {
        hio =  LoadLibraryA("io");
	if (hio == NULL) return 1;
	PortOut = (PORTOUT)GetProcAddress(hio, "PortOut");
	PortWordOut = (PORTWORDOUT)GetProcAddress(hio, "PortWordOut");
	PortDWordOut = (PORTDWORDOUT)GetProcAddress(hio, "PortDWordOut");
	PortIn = (PORTIN)GetProcAddress(hio, "PortIn");
	PortWordIn = (PORTWORDIN)GetProcAddress(hio, "PortWordIn");
	PortDWordIn = (PORTDWORDIN)GetProcAddress(hio, "PortDWordIn");
	SetPortBit = (SETPORTBIT)GetProcAddress(hio, "SetPortBit");
	ClrPortBit = (CLRPORTBIT)GetProcAddress(hio, "ClrPortBit");
	NotPortBit = (NOTPORTBIT)GetProcAddress(hio, "NotPortBit");
	GetPortBit = (GETPORTBIT)GetProcAddress(hio, "GetPortBit");
	RightPortShift = (RIGHTPORTSHIFT)GetProcAddress(hio, "RightPortShift");
	LeftPortShift = (LEFTPORTSHIFT)GetProcAddress(hio, "LeftPortShift");
	IsDriverInstalled = (ISDRIVERINSTALLED)GetProcAddress(hio, "IsDriverInstalled");

	atexit(UnloadIODLL);

	return 0;
}


