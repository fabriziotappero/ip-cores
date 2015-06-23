// --------------------------------------------------------------------
// Copyright (c) 2005 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
//
// Major Functions:	CII Starter Kit USB API Borland C++ Builder Code
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            :| Mod. Date :| Changes Made:
//   V1.0 :| Johnny Chen       :| 06/06/07  :| Initial Revision
// --------------------------------------------------------------------
//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "Main.h"
#include "About.h"
#include "PS2_Thread.h"
#include "Test_Page.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TForm1 *Form1;

int PS2_times=0;
bool USB_is_Open=false;
FILE *file1,*file2;

//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
   : TForm(Owner)
{
   Form1->DoubleBuffered=true;
   // ToDo  :  Check Number Of FTDI Device In System
   int NumDev=USB1.Number_Of_Device();
   if(NumDev!=0)
   {
      NonUSBPort1->Visible=false;
      OpenUSBPort0->Visible=true;
      if(NumDev>1)
      OpenUSBPort1->Visible=true;
      if(NumDev>2)
      OpenUSBPort2->Visible=true;
      if(NumDev>3)
      OpenUSBPort3->Visible=true;
   }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormClose(TObject *Sender, TCloseAction &Action)
{
   // ToDo : Close Control Panel and Close USB JTAG Port
   Close_USB_Port();
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button2Click(TObject *Sender)
{
   // ToDo : Send LED Value To FPGA
   char x[8];
   x[0]=WRITE;
   x[1]=LED;
   x[2]=0x00;
   x[3]=(char(DR9->Checked)<<1)+(char(DR8->Checked));
   x[4]=(char(DR7->Checked)<<7)+(char(DR6->Checked)<<6)+(char(DR5->Checked)<<5)+(char(DR4->Checked)<<4)+
        (char(DR3->Checked)<<3)+(char(DR2->Checked)<<2)+(char(DR1->Checked)<<1)+(char(DR0->Checked));
   x[5]=0x00;
   x[6]=(char(D8->Checked)<<7)+(char(D7->Checked)<<6)+(char(D6->Checked)<<5)+(char(D5->Checked)<<4)+
        (char(D4->Checked)<<3)+(char(D3->Checked)<<2)+(char(D2->Checked)<<1)+(char(D1->Checked));
   x[7]=DISPLAY;
   PS2_REC->Suspend();
   USB1.Reset_Device(0);
   USB1.Write_Data(x,8,0,true);
   PS2_REC->Resume();
   Button1Click(this);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button5Click(TObject *Sender)
{
   // ToDo : Flash Random Write
   char x[8];
   x[0]=WRITE;
   x[1]=FLASH;
   x[2]=char(HexToInt(oFL_ADDR->Text)>>16);
   x[3]=char(HexToInt(oFL_ADDR->Text)>>8);
   x[4]=char(HexToInt(oFL_ADDR->Text));
   x[5]=0xFF;
   x[6]=char(HexToInt(oFL_DATA->Text));
   x[7]=NORMAL;
   USB1.Reset_Device(0);
   USB1.Write_Data(x,8,0,true);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button4Click(TObject *Sender)
{
   // ToDo : Flash Random Read
   char x[8];
   //-----------------------------------
   // T-Rex TXD Output Select to FLASH
   x[0]=SETUP;
   x[1]=SET_REG;
   x[2]=0x12;
   x[3]=0x34;
   x[4]=0x56;
   x[5]=0x00;
   x[6]=FLASH;
   x[7]=OUTSEL;
   USB1.Reset_Device(0);
   USB1.Write_Data(x,8,0,true);
   Sleep(10);
   //-----------------------------------
   // Send Flash Address To FPGA
   x[0]=READ;
   x[1]=FLASH;
   x[2]=char(HexToInt(oFL_ADDR->Text)>>16);
   x[3]=char(HexToInt(oFL_ADDR->Text)>>8);
   x[4]=char(HexToInt(oFL_ADDR->Text));
   x[5]=0xFF;
   x[6]=0x00;
   x[7]=NORMAL;
   USB1.Write_Data(x,8,1,true);
   Sleep(10);
   // Flash Random Read
   USB1.Read_Data(x,1);
   // Show Get Value To Text Filed
   iFL_DATA->Text=IntToHex((unsigned char)x[0],2);
   //-----------------------------------
   // T-Rex TXD Output Select to PS2
   x[0]=SETUP;
   x[1]=SET_REG;
   x[2]=0x12;
   x[3]=0x34;
   x[4]=0x56;
   x[5]=0x00;
   x[6]=PS2;
   x[7]=OUTSEL;
   USB1.Reset_Device(0);
   USB1.Write_Data(x,8,0,true);
   //-----------------------------------
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button3Click(TObject *Sender)
{
   // ToDo : Erase Flash
   Screen->Cursor=crHourGlass;
   // Show Busy Panel
   Panel1->Visible=true;
   // Disable All Button
   Show_All_Button(false);
   // Set ProgressBar
   ProgressBar1->Max=400;
   // Send Erase Command To FPGA
   char x[8];
   int wait=0;
   x[0]=ERASE;
   x[1]=FLASH;
   x[2]=0x00;
   x[3]=0x00;
   x[4]=0x00;
   x[5]=0xFF;
   x[6]=0x00;
   x[7]=NORMAL;
   USB1.Reset_Device(0);
   USB1.Write_Data(x,8,0,true);
   USB1.Write_Data(x,8,0,true);
   USB1.Write_Data(x,8,0,true);
   // Wait 40 Sec.....
   for(int i=0;i<400;i++)
   {
      // Display Process %
      Process_Label->Caption=IntToStr(i*100/400)+" %";
      ProgressBar1->Position=i;
      Application->ProcessMessages();
      // Waitting
      Sleep(100);
   }
   Form1->iFL_DATA->Text="00";
   // Max Wait 60 Sec...
   while((HexToInt(Form1->iFL_DATA->Text)!=255) && wait<600 )
   {
      Form1->Button4Click(this);
      Application->ProcessMessages();
      Sleep(100);
      wait++;
   }
   if(wait==600)
   ShowMessage("FLASH Erase TimeOut!!");
   Form1->iFL_DATA->Text="00";
   // Close Busy Panel
   Panel1->Visible=false;
   // Enable All Button
   Show_All_Button(true);
   Screen->Cursor=crArrow;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button6Click(TObject *Sender)
{
   // TODO : Write File To Flash
   if(OpenDialog1->Execute())
   {
      char x[8];
      int File_Length,File_Type;
      int ADDR=HexToInt(iWR_ADDR->Text);
      Screen->Cursor=crHourGlass;
      // Show Busy Panel
      Panel1->Visible=true;
      // Disable All Button
      Show_All_Button(false);
      // Send Flash Write Command To FPGA
      x[0]=WRITE;
      x[1]=FLASH;
      x[5]=0xFF;
      x[7]=NORMAL;
      USB1.Reset_Device(0);
      // Check File Type and Open File
      if(Select_File(OpenDialog1->FileName)==1)
      {
         File_AscToHex(OpenDialog1->FileName,"123.tmp",1);
         Sleep(100);
         file1=fopen("123.tmp","rb");
      }
      else
      file1=fopen(OpenDialog1->FileName.c_str(),"rb");
      // Set File ptr To File End
      fseek(file1,0,SEEK_END);
      // Set Transport Length
      if(CheckBox1->Checked)
      {
         // Check File Length
         File_Length=ftell(file1);
         // Show File Length To Text Field
         iWR_Length->Text=IntToHex(File_Length,6);
      }
      else
      File_Length=HexToInt(iWR_Length->Text);
      // Set ProgressBar
      ProgressBar1->Max=File_Length;
      // Set File ptr To File Start
      fseek(file1,0,SEEK_SET);
      // Read File Data To Temp Memory
      unsigned char* a=(unsigned char*)VirtualAlloc(NULL,File_Length,MEM_COMMIT,PAGE_READWRITE);
      fread(a,sizeof(char),File_Length,file1);
      // Transport File To Flash
      for(int i=0;i<File_Length;i++)
      {
         // Display Process %
         Process_Label->Caption=IntToStr(i*100/File_Length)+" %";
         ProgressBar1->Position=i;
         Application->ProcessMessages();
         // Send Data and Address
         x[2]=char(ADDR>>16);
         x[3]=char(ADDR>>8);
         x[4]=char(ADDR);
         x[5]=0xFF;
         x[6]=a[i];
         if(i%MAX_TOTAL_PACKET==MAX_TOTAL_PACKET-1)
         USB1.Reset_Device(0);
         if(i<File_Length-1)
         USB1.Write_Data(x,8,0,false);
         else
         USB1.Write_Data(x,8,0,true);
         // Inc Address
         ADDR++;
      }
      USB1.Reset_Device(0);
      // Close File
      fclose(file1);
      // Delete Temp File
      if(FileExists("123.tmp"))
      DeleteFile("123.tmp");
      // Close Busy Panel
      Panel1->Visible=false;
      // Enable All Button
      Show_All_Button(true);
      // Free Temp Memory
      VirtualFree(a,0,MEM_RELEASE);
      Screen->Cursor=crArrow;
   }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button7Click(TObject *Sender)
{
   // ToDo : Load Flash Content to File
   if(SaveDialog1->Execute())
   {
      char x[8];
      int DATA_Read=0;
      int Queue;
      int Flash_Length;
      int ADDR=HexToInt(iRD_ADDR->Text);
      Screen->Cursor=crHourGlass;
      // Show Busy Panel
      Panel1->Visible=true;
      // Disable All Button
      Show_All_Button(false);
      //-----------------------------------
      // T-Rex TXD Output Select to FLASH
      x[0]=SETUP;
      x[1]=SET_REG;
      x[2]=0x12;
      x[3]=0x34;
      x[4]=0x56;
      x[5]=0x00;
      x[6]=FLASH;;
      x[7]=OUTSEL;
      USB1.Reset_Device(0);
      USB1.Write_Data(x,8,0,true);
      Sleep(10);
      //-----------------------------------
      // Send Flash Read Command To FPGA
      x[0]=READ;
      x[1]=FLASH;
      x[5]=0xFF;
      x[6]=0x00;
      x[7]=NORMAL;
      // Set Transport Length
      if(CheckBox2->Checked)
      {
         // Set Transport Length = Flash Size = 4Mbyte
         Flash_Length=1048576*4;
         // Show Transport Length To Text Field
         iRD_Length->Text=IntToHex(Flash_Length,6);
      }
      else
      Flash_Length=HexToInt(iRD_Length->Text);
      unsigned char* a=(unsigned char*)VirtualAlloc(NULL,Flash_Length+MAX_RXD_PACKET,MEM_COMMIT,PAGE_READWRITE);
      // Set ProgressBar
      ProgressBar1->Max=Flash_Length;
      // Transport Flash Data To File
      for(int i=0;i<Flash_Length;i++)
      {
         // Display Process %
         Process_Label->Caption=IntToStr(i*100/Flash_Length)+" %";
         ProgressBar1->Position=i;
         Application->ProcessMessages();
         // Send Address
         x[2]=char(ADDR>>16);
         x[3]=char(ADDR>>8);
         x[4]=char(ADDR);
         if(i%ALMOST_FULL_SIZE==ALMOST_FULL_SIZE-1)
         USB1.Write_Data(x,8,1,true);
         else if(i==Flash_Length-1)
         USB1.Write_Data(x,8,1,true);
         else
         USB1.Write_Data(x,8,1,false);
         if(i%MAX_RXD_PACKET==MAX_RXD_PACKET-1)
         {
            // Flash Seq. Read
            USB1.Read_Data(&a[DATA_Read],MAX_RXD_PACKET);
            DATA_Read+=MAX_RXD_PACKET;
            USB1.Reset_Device(0);
         }
         // Inc Address
         ADDR++;
      }
      // Wait a short time to get Data Form USB JTAG
      USB1.Write_Data(x,0,8,true);
      Sleep(100);
      Queue=USB1.Number_Of_Queue_Data();
      USB1.Read_Data(&a[DATA_Read],Queue);
      // Check File and Write File
      if(Select_File(SaveDialog1->FileName)==1)
      {
         file2=fopen("123.tmp","w+b");
         fwrite(a,sizeof(char),Flash_Length,file2);
         fclose(file2);
         Sleep(100);
         File_HexToAsc("123.tmp",SaveDialog1->FileName,1);
      }
      else
      {
         file2=fopen(SaveDialog1->FileName.c_str(),"w+b");
         fwrite(a,sizeof(char),Flash_Length,file2);
         fclose(file2);
      }
      Sleep(100);
      VirtualFree(a,0,MEM_RELEASE);
      // Delete Temp File
      if(FileExists("123.tmp"))
      DeleteFile("123.tmp");
      //-----------------------------------
      // T-Rex TXD Output Select to PS2
      x[0]=SETUP;
      x[1]=SET_REG;
      x[2]=0x12;
      x[3]=0x34;
      x[4]=0x56;
      x[5]=0x00;
      x[6]=PS2;
      x[7]=OUTSEL;
      USB1.Reset_Device(0);
      USB1.Write_Data(x,8,0,true);
      //-----------------------------------
      // Close Busy Panel
      Panel1->Visible=false;
      // Enable All Button
      Show_All_Button(true);
      Screen->Cursor=crArrow;
   }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::CheckBox1Click(TObject *Sender)
{
   // ToDo : if( Flash Write Size == File Length )
   // Disable iWR_Length Text Field
   if(CheckBox1->Checked)
   iWR_Length->ReadOnly=true;
   else
   iWR_Length->ReadOnly=false;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::CheckBox2Click(TObject *Sender)
{
   // ToDo : if( Flash Read Size = Entrie Flash )
   // Show iRD_Length = 4 MByte
   // And Disable iRD_Length Text Field
   if(CheckBox2->Checked)
   {
      iRD_Length->Text="400000";
      iRD_Length->ReadOnly=true;
   }
   else
   {
      iRD_Length->Text="0";
      iRD_Length->ReadOnly=false;
   }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::OpenUSBPort0Click(TObject *Sender)
{
   // ToDo : Open USB JTAG Port 1 and Enable All Button
   if(USB_is_Open)
   {
      USB1.Close_Device();
      USB_is_Open=false;
   }
   USB1.Select_Device(0);
   if(USB1.Open_Device())
   {
      USB_is_Open=true;
      USB1.Reset_Device(0);
      PS2_REC = new TPS2_REC(true);
      PS2_REC->Resume();
      Show_All_Button(true);
      CloseUSBPort1->Visible=true;
   }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::OpenUSBPort1Click(TObject *Sender)
{
   // ToDo : Open USB JTAG Port 2 and Enable All Button
   if(USB_is_Open)
   {
      USB1.Close_Device();
      USB_is_Open=false;
   }
   USB1.Select_Device(1);
   if(USB1.Open_Device())
   {
      USB_is_Open=true;
      USB1.Reset_Device(0);
      PS2_REC = new TPS2_REC(true);
      PS2_REC->Resume();
      Show_All_Button(true);
      CloseUSBPort1->Visible=true;
   }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::OpenUSBPort2Click(TObject *Sender)
{
   // ToDo : Open USB JTAG Port 3 and Enable All Button
   if(USB_is_Open)
   {
      USB1.Close_Device();
      USB_is_Open=false;
   }
   USB1.Select_Device(2);
   if(USB1.Open_Device())
   {
      USB_is_Open=true;
      USB1.Reset_Device(0);
      PS2_REC = new TPS2_REC(true);
      PS2_REC->Resume();
      Show_All_Button(true);
      CloseUSBPort1->Visible=true;
   }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::OpenUSBPort3Click(TObject *Sender)
{
   // ToDo : Open USB JTAG Port 4 and Enable All Button
   if(USB_is_Open)
   {
      USB1.Close_Device();
      USB_is_Open=false;
   }
   USB1.Select_Device(3);
   if(USB1.Open_Device())
   {
      USB_is_Open=true;
      USB1.Reset_Device(0);
      PS2_REC = new TPS2_REC(true);
      PS2_REC->Resume();
      Show_All_Button(true);
      CloseUSBPort1->Visible=true;
   }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::About1Click(TObject *Sender)
{
   // ToDo : Show About Form
   AboutBox->Visible=true;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Help1Click(TObject *Sender)
{
   // ToDo : Open Help
   ShellExecute(NULL,NULL,"CII_Starter_Kit_UserGuide.pdf",NULL,NULL,SW_SHOWNORMAL);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button8Click(TObject *Sender)
{
   // ToDo : Clear PS2 Text Windows
   Memo1->Clear();
}
//---------------------------------------------------------------------------
int __fastcall TForm1::HexToInt(AnsiString strHex)
{
  return StrToInt64("0x"+strHex);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Show_All_Button(bool Show)
{
   // ToDo : Enable / Disable All Button
   // Please add all button in this function
   Button1->Enabled=Show;
   Button2->Enabled=Show;
   Button3->Enabled=Show;
   Button4->Enabled=Show;
   Button5->Enabled=Show;
   Button6->Enabled=Show;
   Button7->Enabled=Show;
   Button8->Enabled=Show;
   Button9->Enabled=Show;
   Button10->Enabled=Show;
   Button11->Enabled=Show;
   Button12->Enabled=Show;
   Button13->Enabled=Show;
   Button14->Enabled=Show;
   Button15->Enabled=Show;
   Button16->Enabled=Show;
   Button17->Enabled=Show;
   Button18->Enabled=Show;
   Default_IMG->Enabled=Show;
   Cursor_EN->Enabled=Show;
   ScrollBar1->Enabled=Show;
   ScrollBar2->Enabled=Show;

}
//---------------------------------------------------------------------------

void __fastcall TForm1::CheckBox4Click(TObject *Sender)
{
   // ToDo : if( Sdram Read Size = Entrie Sdram )
   // Show iSDR_SRD_Length = 8 MByte
   // And Disable iSDR_SRD_Length Text Field
   if(CheckBox4->Checked)
   {
      iSDR_SRD_Length->Text="800000";
      iSDR_SRD_Length->ReadOnly=true;
   }
   else
   {
      iSDR_SRD_Length->Text="0";
      iSDR_SRD_Length->ReadOnly=false;
   }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::CheckBox3Click(TObject *Sender)
{
   // ToDo : if( Sdram Write Size == File Length )
   // Disable iSDR_SWR_Length Text Field
   if(CheckBox3->Checked)
   iSDR_SWR_Length->ReadOnly=true;
   else
   iSDR_SWR_Length->ReadOnly=false;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button9Click(TObject *Sender)
{
   // ToDo : Sdram Random Write
   char x[8];
   x[0]=WRITE;
   x[1]=SDRAM;
   x[2]=char(HexToInt(oSDR_ADDR->Text)>>16);
   x[3]=char(HexToInt(oSDR_ADDR->Text)>>8);
   x[4]=char(HexToInt(oSDR_ADDR->Text));
   x[5]=char(HexToInt(oSDR_DATA->Text)>>8);
   x[6]=char(HexToInt(oSDR_DATA->Text));
   x[7]=NORMAL;
   USB1.Reset_Device(0);
   USB1.Write_Data(x,8,0,true);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button10Click(TObject *Sender)
{
   // ToDo : Sdram Random Read
   char x[8];
   //-----------------------------------
   // T-Rex TXD Output Select to SDRAM
   x[0]=SETUP;
   x[1]=SET_REG;
   x[2]=0x12;
   x[3]=0x34;
   x[4]=0x56;
   x[5]=0x00;
   x[6]=SDRAM;
   x[7]=OUTSEL;
   USB1.Reset_Device(0);
   USB1.Write_Data(x,8,0,true);
   Sleep(10);
   //-----------------------------------
   // Send SDRAM Address To FPGA
   x[0]=READ;
   x[1]=SDRAM;
   x[2]=char(HexToInt(oSDR_ADDR->Text)>>16);
   x[3]=char(HexToInt(oSDR_ADDR->Text)>>8);
   x[4]=char(HexToInt(oSDR_ADDR->Text));
   x[5]=0x00;
   x[6]=0x00;
   x[7]=NORMAL;
   USB1.Write_Data(x,8,2,true);
   Sleep(10);
   // Sdram Random Read
   USB1.Read_Data(x,2);
   // Show Get Value To Text Filed
   iSDR_DATA->Text=IntToHex((unsigned char)x[0]+(unsigned char)x[1]*256,4);
   //-----------------------------------
   // T-Rex TXD Output Select to PS2
   x[0]=SETUP;
   x[1]=SET_REG;
   x[2]=0x12;
   x[3]=0x34;
   x[4]=0x56;
   x[5]=0x00;
   x[6]=PS2;
   x[7]=OUTSEL;
   USB1.Reset_Device(0);
   USB1.Write_Data(x,8,0,true);
   //-----------------------------------
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button11Click(TObject *Sender)
{
   // TODO : Write File To Sdram
   if(OpenDialog2->Execute())
   {
      char x[8];
      int File_Length;
      int ADDR=HexToInt(iSDR_SWR_ADDR->Text);
      Screen->Cursor=crHourGlass;
      // Show Busy Panel
      Panel1->Visible=true;
      // Disable All Button
      Show_All_Button(false);
      // Send Sdram Write Command To FPGA
      x[0]=WRITE;
      x[1]=SDRAM;
      x[7]=NORMAL;
      USB1.Reset_Device(0);
      // Check File Type and Open File
      if(Select_File(OpenDialog2->FileName)==1)
      {
         File_AscToHex(OpenDialog2->FileName,"123.tmp",2);
         Sleep(100);
         file1=fopen("123.tmp","rb");
      }
      else
      file1=fopen(OpenDialog2->FileName.c_str(),"rb");
      // Set File ptr To File End
      fseek(file1,0,SEEK_END);
      // Set Transport Length
      if(CheckBox3->Checked)
      {
         // Check File Length
         File_Length=ftell(file1);
         // Show File Length To Text Field
         iSDR_SWR_Length->Text=IntToHex(File_Length,6);
      }
      else
      File_Length=HexToInt(iSDR_SWR_Length->Text);
      // Set ProgressBar
      ProgressBar1->Max=File_Length;
      // Set File ptr To File Start
      fseek(file1,0,SEEK_SET);
      // Read File Data To Temp Memory
      unsigned char* a=(unsigned char*)VirtualAlloc(NULL,File_Length+1,MEM_COMMIT,PAGE_READWRITE);
      fread(a,sizeof(char),File_Length,file1);
      // Transport File To Sdram
      for(int i=0;i<File_Length;i+=2)
      {
         // Display Process %
         Process_Label->Caption=IntToStr(i*100/File_Length)+" %";
         ProgressBar1->Position=i;
         Application->ProcessMessages();
         // Send Data and Address
         x[2]=char(ADDR>>16);
         x[3]=char(ADDR>>8);
         x[4]=char(ADDR);
         x[5]=a[i+1];
         x[6]=a[i];
         if(i%MAX_TOTAL_PACKET==MAX_TOTAL_PACKET-2)
         USB1.Reset_Device(0);
         if(i<File_Length-2)
         USB1.Write_Data(x,8,0,false);
         else
         USB1.Write_Data(x,8,0,true);
         // Inc Address
         ADDR++;
      }
      USB1.Reset_Device(0);
      // Close File
      fclose(file1);
      // Close Busy Panel
      Panel1->Visible=false;
      // Enable All Button
      Show_All_Button(true);
      // Free Temp Memory
      VirtualFree(a,0,MEM_RELEASE);
      Screen->Cursor=crArrow;
   }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button12Click(TObject *Sender)
{
   int t1,t2;
   // ToDo : Load Sdram Content to File
   if(SaveDialog2->Execute())
   {
      char x[8];
      int Sdram_Length;
      int DATA_Read=0;
      int Queue;
      int ADDR=HexToInt(iSDR_SRD_ADDR->Text);
      Screen->Cursor=crHourGlass;
      // Show Busy Panel
      Panel1->Visible=true;
      // Disable All Button
      Show_All_Button(false);
      //-----------------------------------
      // T-Rex TXD Output Select to SDRAM
      x[0]=SETUP;
      x[1]=SET_REG;
      x[2]=0x12;
      x[3]=0x34;
      x[4]=0x56;
      x[5]=0x00;
      x[6]=SDRAM;;
      x[7]=OUTSEL;
      USB1.Reset_Device(0);
      USB1.Write_Data(x,8,0,true);
      Sleep(10);
      //-----------------------------------
      // Send Sdram Read Command To FPGA
      x[0]=READ;
      x[1]=SDRAM;
      x[5]=0x00;
      x[6]=0x00;
      x[7]=NORMAL;
      // Set Transport Length
      if(CheckBox4->Checked)
      {
         // Set Transport Length = Sdram Size = 8Mbyte
         Sdram_Length=8388608;
         // Show Transport Length To Text Field
         iSDR_SRD_Length->Text=IntToHex(Sdram_Length,6);
      }
      else
      Sdram_Length=HexToInt(iSDR_SRD_Length->Text);
      unsigned char* a=(unsigned char*)VirtualAlloc(NULL,Sdram_Length+MAX_RXD_PACKET,MEM_COMMIT,PAGE_READWRITE);
      // Set ProgressBar
      ProgressBar1->Max=Sdram_Length;
      // Transport Sdram Data To File
      for(int i=0;i<Sdram_Length;i+=2)
      {
         // Display Process %
         Process_Label->Caption=IntToStr(i*100/Sdram_Length)+" %";
         ProgressBar1->Position=i;
         Application->ProcessMessages();
         // Send Address
         x[2]=char(ADDR>>16);
         x[3]=char(ADDR>>8);
         x[4]=char(ADDR);
         if(i%ALMOST_FULL_SIZE==ALMOST_FULL_SIZE-2)
         USB1.Write_Data(x,8,2,true);
         else if(i==Sdram_Length-2)
         USB1.Write_Data(x,8,2,true);
         else
         USB1.Write_Data(x,8,2,false);
         if(i%MAX_RXD_PACKET==MAX_RXD_PACKET-2)
         {
            // Sdram Seq. Read
            USB1.Read_Data(&a[DATA_Read],MAX_RXD_PACKET);
            DATA_Read+=MAX_RXD_PACKET;
            USB1.Reset_Device(0);
         }
         // Inc Address
         ADDR++;
      }
      // Wait a short time to get Data Form USB JTAG
      USB1.Write_Data(x,0,8,true);
      Sleep(100);
      Queue=USB1.Number_Of_Queue_Data();
      USB1.Read_Data(&a[DATA_Read],Queue);
      // Check File and Write File
      if(Select_File(SaveDialog2->FileName)==1)
      {
         file2=fopen("123.tmp","w+b");
         fwrite(a,sizeof(char),Sdram_Length,file2);
         fclose(file2);
         Sleep(100);
         File_HexToAsc("123.tmp",SaveDialog2->FileName,2);
      }
      else
      {
         file2=fopen(SaveDialog2->FileName.c_str(),"w+b");
         fwrite(a,sizeof(char),Sdram_Length,file2);
         fclose(file2);
      }
      Sleep(100);
      VirtualFree(a,0,MEM_RELEASE);
      // Delete Temp File
      if(FileExists("123.tmp"))
      DeleteFile("123.tmp");
      //-----------------------------------
      // T-Rex TXD Output Select to PS2
      x[0]=SETUP;
      x[1]=SET_REG;
      x[2]=0x12;
      x[3]=0x34;
      x[4]=0x56;
      x[5]=0x00;
      x[6]=PS2;
      x[7]=OUTSEL;
      USB1.Reset_Device(0);
      USB1.Write_Data(x,8,0,true);
      //-----------------------------------
      // Close Busy Panel
      Panel1->Visible=false;
      // Enable All Button
      Show_All_Button(true);
      Screen->Cursor=crArrow;
   }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::TabSheet1Show(TObject *Sender)
{
   // ToDo  :  Enable PS2_REC Thread
   if(USB_is_Open)
   {
      USB1.Reset_Device(0);
      PS2_REC->Resume();
   }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button13Click(TObject *Sender)
{
   // ToDo : Send External IO Value To FPGA
   char x[8];
   x[0]=WRITE;
   x[1]=EXTIO;
   x[2]=0x12;
   x[3]=0x34;
   x[4]=0x56;
   x[5]=0x00;
   x[6]=0x00;
   x[7]=NORMAL;
   USB1.Write_Data(x,8,0,true);
   // ToDo : Send Sdram Multiplexer To FPGA
   x[0]=SETUP;
   x[1]=SDRSEL;
   x[6]=char(Sdram_Multi->ItemIndex);
   x[7]=OUTSEL;
   USB1.Write_Data(x,8,0,true);
   // ToDo : Send Flash Multiplexer To FPGA
   x[0]=SETUP;
   x[1]=FLSEL;
   x[6]=char(Flash_Multi->ItemIndex);
   x[7]=OUTSEL;
   USB1.Write_Data(x,8,0,true);
   // ToDo : Send SRAM Multiplexer To FPGA
   x[0]=SETUP;
   x[1]=SRSEL;
   x[6]=char(Sram_Multi->ItemIndex);
   x[7]=OUTSEL;
   USB1.Write_Data(x,8,0,true);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Close_USB_Port()
{
   // ToDo : Close USB Port
   if(USB_is_Open)
   {
      PS2_REC->Terminate();
      USB1.Close_Device();
      Show_All_Button(false);
      CloseUSBPort1->Visible=false;
      USB_is_Open=false;
   }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::CloseUSBPort1Click(TObject *Sender)
{
   Close_USB_Port();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button14Click(TObject *Sender)
{
   // ToDo : Board Test
   Form4->Visible=true;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::TabSheet2Show(TObject *Sender)
{
   // ToDo  :  Disable PS2_REC Thread
   if(USB_is_Open)
   {
      PS2_REC->Suspend();
      USB1.Reset_Device(0);
   }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::TabSheet3Show(TObject *Sender)
{
   // ToDo  :  Disable PS2_REC Thread
   if(USB_is_Open)
   {
      PS2_REC->Suspend();
      USB1.Reset_Device(0);
   }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::TabSheet4Show(TObject *Sender)
{
   // ToDo  :  Disable PS2_REC Thread
   if(USB_is_Open)
   {
      PS2_REC->Suspend();
      USB1.Reset_Device(0);
   }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::TabSheet5Show(TObject *Sender)
{
   // ToDo  :  Disable PS2_REC Thread
   if(USB_is_Open)
   {
      PS2_REC->Suspend();
      USB1.Reset_Device(0);
   }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::TabSheet6Show(TObject *Sender)
{
   // ToDo  :  Disable PS2_REC Thread
   if(USB_is_Open)
   {
      PS2_REC->Suspend();
      USB1.Reset_Device(0);
   }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::TabSheet7Show(TObject *Sender)
{
   // ToDo  :  Disable PS2_REC Thread
   if(USB_is_Open)
   {
      PS2_REC->Suspend();
      USB1.Reset_Device(0);
   }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button16Click(TObject *Sender)
{
   // ToDo : SRAM Random Write
   char x[8];
   x[0]=WRITE;
   x[1]=SRAM;
   x[2]=char(HexToInt(oSR_ADDR->Text)>>16);
   x[3]=char(HexToInt(oSR_ADDR->Text)>>8);
   x[4]=char(HexToInt(oSR_ADDR->Text));
   x[5]=char(HexToInt(oSR_DATA->Text)>>8);
   x[6]=char(HexToInt(oSR_DATA->Text));
   x[7]=NORMAL;
   USB1.Reset_Device(0);
   USB1.Write_Data(x,8,0,true);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button17Click(TObject *Sender)
{
   // ToDo : SRAM Random Read
   char x[8];
   //-----------------------------------
   // T-Rex TXD Output Select to SRAM
   x[0]=SETUP;
   x[1]=SET_REG;
   x[2]=0x12;
   x[3]=0x34;
   x[4]=0x56;
   x[5]=0x00;
   x[6]=SRAM;
   x[7]=OUTSEL;
   USB1.Reset_Device(0);
   USB1.Write_Data(x,8,0,true);
   Sleep(10);
   //-----------------------------------
   // Send SRAM Address To FPGA
   x[0]=READ;
   x[1]=SRAM;
   x[2]=char(HexToInt(oSR_ADDR->Text)>>16);
   x[3]=char(HexToInt(oSR_ADDR->Text)>>8);
   x[4]=char(HexToInt(oSR_ADDR->Text));
   x[5]=0x00;
   x[6]=0x00;
   x[7]=NORMAL;
   USB1.Write_Data(x,8,2,true);
   Sleep(10);
   // SRAM Random Read
   USB1.Read_Data(x,2);
   // Show Get Value To Text Filed
   iSR_DATA->Text=IntToHex((unsigned char)x[0]+(unsigned char)x[1]*256,4);
   //-----------------------------------
   // T-Rex TXD Output Select to PS2
   x[0]=SETUP;
   x[1]=SET_REG;
   x[2]=0x12;
   x[3]=0x34;
   x[4]=0x56;
   x[5]=0x00;
   x[6]=PS2;
   x[7]=OUTSEL;
   USB1.Reset_Device(0);
   USB1.Write_Data(x,8,0,true);
   //-----------------------------------
}
//---------------------------------------------------------------------------
void __fastcall TForm1::CheckBox5Click(TObject *Sender)
{
   // ToDo : if( Sram Write Size == File Length )
   // Disable iSR_SWR_Length Text Field
   if(CheckBox5->Checked)
   iSR_SWR_Length->ReadOnly=true;
   else
   iSR_SWR_Length->ReadOnly=false;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::CheckBox6Click(TObject *Sender)
{
   // ToDo : if( Sram Read Size = Entrie Sram )
   // Show iSR_SRD_Length = 512 KByte
   // And Disable iSR_SRD_Length Text Field
   if(CheckBox6->Checked)
   {
      iSR_SRD_Length->Text="80000";
      iSR_SRD_Length->ReadOnly=true;
   }
   else
   {
      iSR_SRD_Length->Text="0";
      iSR_SRD_Length->ReadOnly=false;
   }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button15Click(TObject *Sender)
{
   // TODO : Write File To Sram
   if(OpenDialog3->Execute())
   {
      char x[8];
      int File_Length;
      int ADDR=HexToInt(iSR_SWR_ADDR->Text);
      Screen->Cursor=crHourGlass;
      // Show Busy Panel
      Panel1->Visible=true;
      // Disable All Button
      Show_All_Button(false);
      // Send Sram Write Command To FPGA
      x[0]=WRITE;
      x[1]=SRAM;
      x[7]=NORMAL;
      USB1.Reset_Device(0);
      // Check File Type and Open File
      if(Select_File(OpenDialog3->FileName)==1)
      {
         File_AscToHex(OpenDialog3->FileName,"123.tmp",2);
         Sleep(100);
         file1=fopen("123.tmp","rb");
      }
      else
      file1=fopen(OpenDialog3->FileName.c_str(),"rb");
      // Set File ptr To File End
      fseek(file1,0,SEEK_END);
      // Set Transport Length
      if(CheckBox5->Checked)
      {
         // Check File Length
         File_Length=ftell(file1);
         // Show File Length To Text Field
         iSR_SWR_Length->Text=IntToHex(File_Length,6);
      }
      else
      File_Length=HexToInt(iSR_SWR_Length->Text);
      // Set ProgressBar
      ProgressBar1->Max=File_Length;
      // Set File ptr To File Start
      fseek(file1,0,SEEK_SET);
      // Read File Data To Temp Memory
      unsigned char* a=(unsigned char*)VirtualAlloc(NULL,File_Length+1,MEM_COMMIT,PAGE_READWRITE);
      fread(a,sizeof(char),File_Length,file1);
      // Transport File To Sram
      for(int i=0;i<File_Length;i+=2)
      {
         // Display Process %
         Process_Label->Caption=IntToStr(i*100/File_Length)+" %";
         ProgressBar1->Position=i;
         Application->ProcessMessages();
         // Send Data and Address
         x[2]=char(ADDR>>16);
         x[3]=char(ADDR>>8);
         x[4]=char(ADDR);
         x[5]=a[i+1];
         x[6]=a[i];
         if(i%MAX_TOTAL_PACKET==MAX_TOTAL_PACKET-2)
         USB1.Reset_Device(0);
         if(i<File_Length-2)
         USB1.Write_Data(x,8,0,false);
         else
         USB1.Write_Data(x,8,0,true);
         // Inc Address
         ADDR++;
      }
      USB1.Reset_Device(0);
      // Close File
      fclose(file1);
      // Close Busy Panel
      Panel1->Visible=false;
      // Enable All Button
      Show_All_Button(true);
      // Free Temp Memory
      VirtualFree(a,0,MEM_RELEASE);
      Screen->Cursor=crArrow;
   }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button18Click(TObject *Sender)
{
   // ToDo : Load Sram Content to File
   if(SaveDialog3->Execute())
   {
      char x[8];
      int Sram_Length;
      int DATA_Read=0;
      int Queue;
      int ADDR=HexToInt(iSR_SRD_ADDR->Text);
      Screen->Cursor=crHourGlass;
      // Show Busy Panel
      Panel1->Visible=true;
      // Disable All Button
      Show_All_Button(false);
      //-----------------------------------
      // T-Rex TXD Output Select to SRAM
      x[0]=SETUP;
      x[1]=SET_REG;
      x[2]=0x12;
      x[3]=0x34;
      x[4]=0x56;
      x[5]=0x00;
      x[6]=SRAM;;
      x[7]=OUTSEL;
      USB1.Reset_Device(0);
      USB1.Write_Data(x,8,0,true);
      Sleep(10);
      //-----------------------------------
      // Send Sram Read Command To FPGA
      x[0]=READ;
      x[1]=SRAM;
      x[5]=0x00;
      x[6]=0x00;
      x[7]=NORMAL;
      // Set Transport Length
      if(CheckBox6->Checked)
      {
         // Set Transport Length = Sram Size = 512KByte
         Sram_Length=524288;
         // Show Transport Length To Text Field
         iSR_SRD_Length->Text=IntToHex(Sram_Length,6);
      }
      else
      Sram_Length=HexToInt(iSR_SRD_Length->Text);
      unsigned char* a=(unsigned char*)VirtualAlloc(NULL,Sram_Length+MAX_RXD_PACKET,MEM_COMMIT,PAGE_READWRITE);
      // Set ProgressBar
      ProgressBar1->Max=Sram_Length;
      // Transport Sram Data To File
      for(int i=0;i<Sram_Length;i+=2)
      {
         // Display Process %
         Process_Label->Caption=IntToStr(i*100/Sram_Length)+" %";
         ProgressBar1->Position=i;
         Application->ProcessMessages();
         // Send Address
         x[2]=char(ADDR>>16);
         x[3]=char(ADDR>>8);
         x[4]=char(ADDR);
         if(i%ALMOST_FULL_SIZE==ALMOST_FULL_SIZE-2)
         USB1.Write_Data(x,8,2,true);
         else if(i==Sram_Length-2)
         USB1.Write_Data(x,8,2,true);
         else
         USB1.Write_Data(x,8,2,false);
         if(i%MAX_RXD_PACKET==MAX_RXD_PACKET-2)
         {
            // Sram Seq. Read
            USB1.Read_Data(&a[DATA_Read],MAX_RXD_PACKET);
            DATA_Read+=MAX_RXD_PACKET;
            USB1.Reset_Device(0);
         }
         // Inc Address
         ADDR++;
      }
      // Wait a short time to get Data Form USB JTAG
      USB1.Write_Data(x,0,8,true);
      Sleep(100);
      Queue=USB1.Number_Of_Queue_Data();
      USB1.Read_Data(&a[DATA_Read],Queue);
      // Check File and Write File
      if(Select_File(SaveDialog3->FileName)==1)
      {
         file2=fopen("123.tmp","w+b");
         fwrite(a,sizeof(char),Sram_Length,file2);
         fclose(file2);
         Sleep(100);
         File_HexToAsc("123.tmp",SaveDialog3->FileName,2);
      }
      else
      {
         file2=fopen(SaveDialog3->FileName.c_str(),"w+b");
         fwrite(a,sizeof(char),Sram_Length,file2);
         fclose(file2);
      }
      Sleep(100);
      VirtualFree(a,0,MEM_RELEASE);
      // Delete Temp File
      if(FileExists("123.tmp"))
      DeleteFile("123.tmp");
      //-----------------------------------
      // T-Rex TXD Output Select to PS2
      x[0]=SETUP;
      x[1]=SET_REG;
      x[2]=0x12;
      x[3]=0x34;
      x[4]=0x56;
      x[5]=0x00;
      x[6]=PS2;
      x[7]=OUTSEL;
      USB1.Reset_Device(0);
      USB1.Write_Data(x,8,0,true);
      //-----------------------------------
      // Close Busy Panel
      Panel1->Visible=false;
      // Enable All Button
      Show_All_Button(true);
      Screen->Cursor=crArrow;
   }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::ScrollBar2Change(TObject *Sender)
{
   Cur_Y->Caption=IntToStr(ScrollBar2->Position);
   // ToDo : Send VGA Value To FPGA
   char x[8];
   x[0]=WRITE;
   x[1]=VGA;
   x[2]=0x00;
   x[3]=0x00;
   x[7]=DISPLAY;
   PS2_REC->Suspend();
   USB1.Reset_Device(0);
   x[4]=0x01;
   x[5]=char(ScrollBar1->Position/256);
   x[6]=char(ScrollBar1->Position%256);
   USB1.Write_Data(x,8,0,true);
   x[4]=0x02;
   x[5]=char(ScrollBar2->Position/256);
   x[6]=char(ScrollBar2->Position%256);
   USB1.Write_Data(x,8,0,true);
   PS2_REC->Resume();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::ScrollBar1Change(TObject *Sender)
{
   Cur_X->Caption=IntToStr(ScrollBar1->Position);
   // ToDo : Send VGA Value To FPGA
   char x[8];
   x[0]=WRITE;
   x[1]=VGA;
   x[2]=0x00;
   x[3]=0x00;
   x[7]=DISPLAY;
   PS2_REC->Suspend();
   USB1.Reset_Device(0);
   x[4]=0x01;
   x[5]=char(ScrollBar1->Position/256);
   x[6]=char(ScrollBar1->Position%256);
   USB1.Write_Data(x,8,0,true);
   x[4]=0x02;
   x[5]=char(ScrollBar2->Position/256);
   x[6]=char(ScrollBar2->Position%256);
   USB1.Write_Data(x,8,0,true);
   PS2_REC->Resume();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Default_IMGClick(TObject *Sender)
{
   // ToDo : Send VGA Value To FPGA
   char x[8];
   x[0]=WRITE;
   x[1]=VGA;
   x[2]=0x00;
   x[3]=0x00;
   x[4]=0x00;
   x[5]=0x00;
   x[6]=(char(!Default_IMG->Checked)<<1)+char(Cursor_EN->Checked);
   x[7]=DISPLAY;
   PS2_REC->Suspend();
   USB1.Reset_Device(0);
   USB1.Write_Data(x,8,0,true);
   PS2_REC->Resume();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Cursor_ENClick(TObject *Sender)
{
   // ToDo : Send VGA Value To FPGA
   char x[8];
   x[0]=WRITE;
   x[1]=VGA;
   x[2]=0x00;
   x[3]=0x00;
   x[4]=0x00;
   x[5]=0x00;
   x[6]=(char(!Default_IMG->Checked)<<1)+char(Cursor_EN->Checked);
   x[7]=DISPLAY;
   PS2_REC->Suspend();
   USB1.Reset_Device(0);
   USB1.Write_Data(x,8,0,true);
   x[4]=0x03;
   x[5]=0x00;
   x[6]=0x00;
   USB1.Write_Data(x,8,0,true);
   x[4]=0x04;
   x[5]=char(1023/256);
   x[6]=char(1023%256);
   USB1.Write_Data(x,8,0,true);
   x[4]=0x05;
   x[5]=0x00;
   x[6]=0x00;
   USB1.Write_Data(x,8,0,true);
   PS2_REC->Resume();
}
//---------------------------------------------------------------------------
int __fastcall TForm1::Select_File(String File_Name)
{
   int i;
   int File_Type;
   String Sub_Name;
   for(i=File_Name.Length()-3;i<=File_Name.Length();i++)
   Sub_Name=Sub_Name+File_Name[i];
   if(Sub_Name==".hex" || Sub_Name==".HEX")
   File_Type=1;
   else
   File_Type=0;
   return File_Type;
}
//---------------------------------------------------------------------------
int __fastcall TForm1::AscToHex(unsigned char a)
{
   int Out_Hex;
   if(a>=0x30 && a<=0x39)
   Out_Hex=a-0x30;
   else if(a>=0x41 && a<=0x46)
   Out_Hex=a-0x40+9;
   else if(a>=0x61 && a<=0x66)
   Out_Hex=a-0x60+9;
   else if( (a==0x20) || (a==0x09) || (a==0x0A) || (a==0x0D) )
   Out_Hex=100;
   else
   Out_Hex=200;
   return Out_Hex;
}
//---------------------------------------------------------------------------
int __fastcall TForm1::File_AscToHex(String File_Input,String File_Output,int File_Type)
{
   unsigned int File_Length;
   unsigned int tmp=0;
   unsigned int i,j,k;
   unsigned char *hex08;
   unsigned short *hex16;
   unsigned int *hex32;

   file1=fopen(File_Input.c_str(),"rb");
   file2=fopen(File_Output.c_str(),"w+b");
   fseek(file1,0,SEEK_END);
   File_Length=ftell(file1);
   fseek(file1,0,SEEK_SET);
   unsigned char* a=(unsigned char*)VirtualAlloc(NULL,File_Length+1,MEM_COMMIT,PAGE_READWRITE);
   hex08=a;
   hex16=(unsigned short*)a;
   hex32=(unsigned int*)a;
   fread(a,sizeof(char),File_Length,file1);
   j=0;
   k=0;
   for(i=0;i<File_Length;i++)
   {
      if(AscToHex(a[i])==200 && File_Type!=0)
      {
         ShowMessage("Invalid Character Detected!!");
         fclose(file1);
         VirtualFree(a,0,MEM_RELEASE);
         return 0;
      }
      else if(AscToHex(a[i])==100)
      {
         /*
         if(k!=0)
         {
            if(File_Type==1)
            hex08[j]=tmp;
            else if(File_Type==2)
            hex16[j]=tmp;
            else if(File_Type==3)
            hex32[j]=tmp;
            tmp=0;
            j++;
         }
         k=0;
         */
      }
      else
      {
         tmp=(tmp<<4)+AscToHex(a[i]);
         if(k==1 && File_Type==1)
         {
            hex08[j]=tmp;
            tmp=0;
            j++;
            k=0;
         }
         else if(k==3 && File_Type==2)
         {
            hex16[j]=tmp;
            tmp=0;
            j++;
            k=0;
         }
         else if(k==7 && File_Type==3)
         {
            hex32[j]=tmp;
            tmp=0;
            j++;
            k=0;
         }
         else
         k++;
      }
   }
   if(k!=0)
   {
      if(File_Type==1)
      hex08[j]=tmp;
      else if(File_Type==2)
      hex16[j]=tmp;
      else if(File_Type==3)
      hex32[j]=tmp;
      tmp=0;
      j++;
      k=0;
   }
   if(File_Type==1)
   fwrite(hex08,sizeof(char),j,file2);
   else if(File_Type==2)
   fwrite(hex16,sizeof(short),j,file2);
   else if(File_Type==3)
   fwrite(hex32,sizeof(int),j,file2);
   fclose(file1);
   fclose(file2);
   VirtualFree(a,0,MEM_RELEASE);
   return 1;
}
//---------------------------------------------------------------------------
int __fastcall TForm1::File_HexToAsc(String File_Input,String File_Output,int File_Type)
{
   unsigned int File_Length;
   unsigned int i;
   String   tmp;

   file1=fopen(File_Input.c_str(),"rb");
   file2=fopen(File_Output.c_str(),"w+");
   fseek(file1,0,SEEK_END);
   File_Length=ftell(file1);
   fseek(file1,0,SEEK_SET);
   unsigned char* a=(unsigned char*)VirtualAlloc(NULL,File_Length+16,MEM_COMMIT,PAGE_READWRITE);
   fread(a,sizeof(char),File_Length,file1);
   i=0;
   while(i<File_Length)
   {
      if(File_Type==1)
      {
         tmp=IntToHex(a[i],2)+"\n";
         fputs(tmp.c_str(),file2);
         i++;
      }
      else if(File_Type==2)
      {
         tmp=IntToHex((a[i+1]<<8)+a[i],4)+"\n";
         fputs(tmp.c_str(),file2);
         i+=2;
      }
      else if(File_Type==3)
      {
         tmp=IntToHex((a[i+3]<<24)+(a[i+2]<<16)+(a[i+1]<<8)+a[i],8)+"\n";
         fputs(tmp.c_str(),file2);
         i+=4;
      }
   }
   fclose(file1);
   fclose(file2);
   VirtualFree(a,0,MEM_RELEASE);
   return 1;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button1Click(TObject *Sender)
{
   // ToDo : Send 7-SEG Value To FPGA
   char x[8];
   x[0]=WRITE;
   x[1]=SEG7;
   x[2]=0x00;
   x[3]=0x00;
   x[4]=0x00;
   x[5]=(DIG_4->ItemIndex<<4)+DIG_3->ItemIndex;
   x[6]=(DIG_2->ItemIndex<<4)+DIG_1->ItemIndex;
   x[7]=DISPLAY;
   PS2_REC->Suspend();
   USB1.Reset_Device(0);
   USB1.Write_Data(x,8,0,true);
   PS2_REC->Resume();
}
//---------------------------------------------------------------------------


