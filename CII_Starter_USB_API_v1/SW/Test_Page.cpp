//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "Test_Page.h"
#include "Main.h"
#include "PS2_Thread.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TForm4 *Form4;
//---------------------------------------------------------------------------
__fastcall TForm4::TForm4(TComponent* Owner)
   : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TForm4::Button1Click(TObject *Sender)
{
   Form1->Show_All_Button(false);
   Button1->Enabled=false;
   Form1->PS2_REC->Suspend();
   Form1->USB1.Reset_Device(0);
   int i;
   Form1->Sdram_Multi->ItemIndex=0;
   Form1->Flash_Multi->ItemIndex=0;
   Form1->Button13Click(this);
   //---------------------------------------------------
   // ToDo : LED Test
   if(CheckBox1->Checked)
   {
      Screen->Cursor=crHourGlass;
      for(i=0;i<144;i++)
      {
         switch(i%9)
         {
            case 0 : Form1->D1->Checked=!Form1->D1->Checked;
                     Form1->DR0->Checked=!Form1->DR0->Checked;
                     Form1->DR9->Checked=!Form1->DR9->Checked;
                     break;
            case 1 : Form1->D2->Checked=!Form1->D2->Checked;
                     Form1->DR1->Checked=!Form1->DR1->Checked;
                     break;
            case 2 : Form1->D3->Checked=!Form1->D3->Checked;
                     Form1->DR2->Checked=!Form1->DR2->Checked;
                     break;
            case 3 : Form1->D4->Checked=!Form1->D4->Checked;
                     Form1->DR3->Checked=!Form1->DR3->Checked;
                     break;
            case 4 : Form1->D5->Checked=!Form1->D5->Checked;
                     Form1->DR4->Checked=!Form1->DR4->Checked;
                     break;
            case 5 : Form1->D6->Checked=!Form1->D6->Checked;
                     Form1->DR5->Checked=!Form1->DR5->Checked;
                     break;
            case 6 : Form1->D7->Checked=!Form1->D7->Checked;
                     Form1->DR6->Checked=!Form1->DR6->Checked;
                     break;
            case 7 : Form1->D8->Checked=!Form1->D8->Checked;
                     Form1->DR7->Checked=!Form1->DR7->Checked;
                     break;
            case 8 : Form1->DR8->Checked=!Form1->DR8->Checked;
         }
         Form1->Button2Click(this);
         Sleep(20);
         Application->ProcessMessages();
      }
      Form1->D1->Checked=false;
      Form1->D2->Checked=false;
      Form1->D3->Checked=false;
      Form1->D4->Checked=false;
      Form1->D5->Checked=false;
      Form1->D6->Checked=false;
      Form1->D7->Checked=false;
      Form1->D8->Checked=false;
      Form1->DR0->Checked=false;
      Form1->DR1->Checked=false;
      Form1->DR2->Checked=false;
      Form1->DR3->Checked=false;
      Form1->DR4->Checked=false;
      Form1->DR5->Checked=false;
      Form1->DR6->Checked=false;
      Form1->DR7->Checked=false;
      Form1->DR8->Checked=false;
      Form1->DR9->Checked=false;
      Form1->Button2Click(this);
      Screen->Cursor=crArrow;
      ShowMessage("LED Test OK!!");
   }
   //---------------------------------------------------
   // ToDo : SEG 7 Test
   if(CheckBox2->Checked)
   {
      Screen->Cursor=crHourGlass;
      for(i=0;i<33;i++)
      {
         Form1->DIG_1->ItemIndex=i%16;
         Form1->DIG_2->ItemIndex=i%16;
         Form1->DIG_3->ItemIndex=i%16;
         Form1->DIG_4->ItemIndex=i%16;
         Form1->Button1Click(this);
         Sleep(100);
         Application->ProcessMessages();
      }
      Screen->Cursor=crArrow;
      ShowMessage("7 SEG Test OK!!");
   }
   //---------------------------------------------------
   // ToDo : SDRAM Test
   if(CheckBox5->Checked)
   {
      Screen->Cursor=crHourGlass;
      bool Fail=false;
      for(i=0;i<128;i++)
      {
         Form1->oSDR_ADDR->Text=IntToHex(i*i*i*4,6);
         Form1->oSDR_DATA->Text=IntToHex(4660,4);
         Form1->Button9Click(this);
         Form1->Button10Click(this);
         if(Form1->oSDR_DATA->Text!=Form1->iSDR_DATA->Text)
         {
            Fail=true;
            break;
         }
         Application->ProcessMessages();
      }
      Form1->oSDR_ADDR->Text="0";
      Form1->oSDR_DATA->Text="0000";
      Form1->iSDR_DATA->Text="0000";
      Screen->Cursor=crArrow;
      if(!Fail)
      ShowMessage("SDRAM Test Passed!!");
      else
      ShowMessage("SDRAM Test Failed!!");
   }
   //---------------------------------------------------
   // ToDo : SRAM Test
   if(CheckBox3->Checked)
   {
      Screen->Cursor=crHourGlass;
      bool Fail=false;
      for(i=0;i<128;i++)
      {
         Form1->oSR_ADDR->Text=IntToHex(i*i,6);
         Form1->oSR_DATA->Text=IntToHex(4660,4);
         Form1->Button16Click(this);
         Form1->Button17Click(this);
         if(Form1->oSR_DATA->Text!=Form1->iSR_DATA->Text)
         {
            Fail=true;
            break;
         }
         Application->ProcessMessages();
      }
      Form1->oSR_ADDR->Text="0";
      Form1->oSR_DATA->Text="0000";
      Form1->iSR_DATA->Text="0000";
      Screen->Cursor=crArrow;
      if(!Fail)
      ShowMessage("SRAM Test Passed!!");
      else
      ShowMessage("SRAM Test Failed!!");
   }
   //---------------------------------------------------
   // ToDo : FLASH Test
   if(CheckBox4->Checked)
   {
      Screen->Cursor=crHourGlass;
      int Error=0;
      //  Erase FLASH
      Form1->Button3Click(this);
      while(Form1->HexToInt(Form1->iFL_DATA->Text)<128)
      {
         Form1->Button4Click(this);
         Application->ProcessMessages();
         Sleep(100);
      }
      Form1->iFL_DATA->Text="00";
      for(i=0;i<128;i++)
      {
         Form1->oFL_ADDR->Text=IntToHex(i*i*4,6);
         Form1->oFL_DATA->Text=IntToHex(0xA5,2);
         Form1->Button5Click(this);
         Form1->Button5Click(this);
         Form1->Button4Click(this);
         if(Form1->oFL_DATA->Text!=Form1->iFL_DATA->Text)
         Error++;
         Application->ProcessMessages();
      }
      Form1->oFL_ADDR->Text="0";
      Form1->oFL_DATA->Text="00";
      Form1->iFL_DATA->Text="00";
      Screen->Cursor=crArrow;
      if(Error<16)
      ShowMessage("FLASH Test Passed.");
      else
      ShowMessage("FLASH Test Failed.");
   }
   //---------------------------------------------------
   // ToDo : LCD Test
   if(CheckBox6->Checked)
   {
      Screen->Cursor=crHourGlass;
      char x[8];
      int Text_Len;
      AnsiString Str1;
      x[1]=LCD;
      x[2]=0x12;
      x[3]=0x34;
      x[4]=0x56;
      x[5]=0x00;
      x[6]=0x00;
      x[7]=DISPLAY;
      Form1->PS2_REC->Suspend();
      Form1->USB1.Reset_Device(0);
      for(int j=0;j<6;j++)
      {
         x[0]=LCD_CMD;
         //------------------- LCD Init ---------------------------
         // Function Set
         x[6]=0x38;
         Form1->USB1.Write_Data(x,8,0,true);
         Sleep(2);
         // Display Set
         x[6]=0x0C;
         Form1->USB1.Write_Data(x,8,0,true);
         Sleep(2);
         // Clear Display
         x[6]=0x01;
         Form1->USB1.Write_Data(x,8,0,true);
         Sleep(2);
         // Mode Set
         x[6]=0x06;
         Form1->USB1.Write_Data(x,8,0,true);
         Sleep(2);
         // Return to Line 1 Start
         x[6]=0x80;
         Form1->USB1.Write_Data(x,8,0,true);
         Sleep(2);
         Sleep(200);
         //---------------- Show LCD Line1 -----------------------
         x[0]=LCD_DAT;
         for(i=1;i<=16;i++)
         {
            x[6]=0xFF;
            Form1->USB1.Write_Data(x,8,0,true);
         }
         //---------------- Change to Line2 ----------------------
         x[0]=LCD_CMD;
         // Return to Line 2 Start
         x[6]=0xC0;
         Form1->USB1.Write_Data(x,8,0,true);
         Sleep(2);
         //---------------- Show LCD Line2 -----------------------
         x[0]=LCD_DAT;
         for(i=1;i<=16;i++)
         {
            x[6]=0xFF;
            Form1->USB1.Write_Data(x,8,0,true);
         }
         Sleep(500);
      }
      //-------------------------------------------------------
      Form1->PS2_REC->Resume();
      Screen->Cursor=crArrow;
      ShowMessage("LCD Test OK!!");
   }
   //---------------------------------------------------
   Button1->Enabled=true;
   Form1->Show_All_Button(true);
}
//---------------------------------------------------------------------------

