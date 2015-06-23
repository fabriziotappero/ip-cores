//---------------------------------------------------------------------------
#ifndef ThreadH
#define ThreadH
//---------------------------------------------------------------------------
#include <Classes.hpp>

#define READ_TIMEOUT 500   // milliseconds

#define TWMD_WITH_GLERR 1
#define TWMD_AND_CLOSE  2

struct stErr
{
   DWORD Err;
   AnsiString asMsg;
};


//---------------------------------------------------------------------------
class Thread_Com : public TThread
{
enum {CANT_OPEN_COM = 1, CANT_CONFIG_COM, CREATE_EV_ERROR, ERR_READ_COM,
	ERR_READOVER_COM, ERR_READWAIT_COM, ERR_WRITE_COM};

private:
protected:

   void __fastcall Execute();
   void __fastcall HandleASuccessfulRead(char c);
public:
   int NumPort;
   int BaudRate;
	int dwLastErr;
	AnsiString sLastErr;
   BOOL __fastcall WriteToComPort(AnsiString ASbuf);
   __fastcall Thread_Com(bool CreateSuspended, int NumPortD, int BaudRate);
    virtual void __fastcall AfterConstruction();
};
//---------------------------------------------------------------------------
BOOL WriteToComPort(AnsiString ASbuf);
BOOL ChangePort(int PortNum);
#endif
