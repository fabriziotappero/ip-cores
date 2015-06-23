//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "PS2_Thread.h"
#include "Main.h"
#pragma package(smart_init)
//---------------------------------------------------------------------------

//   Important: Methods and properties of objects in VCL can only be
//   used in a method called using Synchronize, for example:
//
//      Synchronize(UpdateCaption);
//
//   where UpdateCaption could look like:
//
//      void __fastcall TPS2_REC::UpdateCaption()
//      {
//        Form1->Caption = "Updated in a thread";
//      }
//---------------------------------------------------------------------------

__fastcall TPS2_REC::TPS2_REC(bool CreateSuspended)
   : TThread(CreateSuspended)
{
}
//---------------------------------------------------------------------------
void __fastcall TPS2_REC::Execute()
{
   //---- Place thread code here ----
   while(!Terminated)
   {
      Synchronize(Show_ASCII);
   }
}
//---------------------------------------------------------------------------
void __fastcall TPS2_REC::Show_ASCII()
{
   // Read PS2 Ascii To Text Windows
   Form1->USB1.Write_Data(&Get_ASCII,0,1,true);
   Sleep(30);
   Form1->USB1.Read_Data(&Get_ASCII,1);
   // Check Get Data is Valid
   if(Get_ASCII!=0x00)
   PS2_times++;
   // Check Get Data is Byte 1
   if(PS2_times==1)
   Form1->Memo1->Text=Form1->Memo1->Text+(char)Get_ASCII;
   else if(PS2_times==2)
   PS2_times=0;
   Application->ProcessMessages();
}
//---------------------------------------------------------------------------

