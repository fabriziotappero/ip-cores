//---------------------------------------------------------------------------

#ifndef PS2_ThreadH
#define PS2_ThreadH
//---------------------------------------------------------------------------
#include <Classes.hpp>
//---------------------------------------------------------------------------
class TPS2_REC : public TThread
{            
private:
   char Get_ASCII;
protected:
   void __fastcall Execute();
public:
   __fastcall TPS2_REC(bool CreateSuspended);
   void __fastcall Show_ASCII();
};
//---------------------------------------------------------------------------
#endif
 