#ifndef EPP_PARALLEL_ACCESS_WIN_H
#define EPP_PARALLEL_ACCESS_WIN_H

#include <windows.h>

typedef void (WINAPI *PORTOUT) (short int Port, char Data);
typedef void (WINAPI *PORTWORDOUT)(short int Port, short int Data);
typedef void (WINAPI *PORTDWORDOUT)(short int Port, int Data);
typedef char (WINAPI *PORTIN) (short int Port);
typedef short int (WINAPI *PORTWORDIN)(short int Port);
typedef int (WINAPI *PORTDWORDIN)(short int Port);
typedef void (WINAPI *SETPORTBIT)(short int Port, char Bit);
typedef void (WINAPI *CLRPORTBIT)(short int Port, char Bit);
typedef void (WINAPI *NOTPORTBIT)(short int Port, char Bit);
typedef short int (WINAPI *GETPORTBIT)(short int Port, char Bit);
typedef short int (WINAPI *RIGHTPORTSHIFT)(short int Port, short int Val);
typedef short int (WINAPI *LEFTPORTSHIFT)(short int Port, short int Val);
typedef short int (WINAPI *ISDRIVERINSTALLED)();

extern PORTOUT PortOut;
extern PORTWORDOUT PortWordOut;
extern PORTDWORDOUT PortDWordOut;
extern PORTIN PortIn;
extern PORTWORDIN PortWordIn;
extern PORTDWORDIN PortDWordIn;
extern SETPORTBIT SetPortBit;
extern CLRPORTBIT ClrPortBit;
extern NOTPORTBIT NotPortBit;
extern GETPORTBIT GetPortBit;
extern RIGHTPORTSHIFT RightPortShift;
extern LEFTPORTSHIFT LeftPortShift;
extern ISDRIVERINSTALLED IsDriverInstalled;

extern int LoadIODLL();
extern void UnloadIODLL();

#endif //EPP_PARALLEL_ACCESS_WIN_H
