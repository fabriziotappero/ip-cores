//---------------------------------------------------------------------------

#ifndef MainH
#define MainH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <stdio.h>
#include "RS232_Command.h"
#include "USB_JTAG.h"
#include <Buttons.hpp>
#include <ExtCtrls.hpp>
#include <Dialogs.hpp>
#include <ComCtrls.hpp>
#include <Menus.hpp>
#include <Graphics.hpp>
#include <jpeg.hpp>
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
   TGroupBox *GroupBox3;
   TLabel *Label5;
   TLabel *Label6;
   TEdit *oFL_ADDR;
   TEdit *oFL_DATA;
   TLabel *Label7;
   TEdit *iFL_DATA;
   TButton *Button3;
   TButton *Button4;
   TButton *Button5;
   TButton *Button6;
   TButton *Button7;
   TGroupBox *GroupBox4;
   TGroupBox *GroupBox5;
   TEdit *iWR_ADDR;
   TLabel *Label8;
   TLabel *Label9;
   TEdit *iWR_Length;
   TCheckBox *CheckBox1;
   TEdit *iRD_ADDR;
   TLabel *Label10;
   TLabel *Label11;
   TEdit *iRD_Length;
   TGroupBox *GroupBox7;
   TCheckBox *CheckBox2;
   TMainMenu *MainMenu1;
   TMenuItem *Setting1;
   TMenuItem *Help1;
   TMenuItem *About1;
   TMenuItem *OpenUSBPort0;
   TPanel *Panel1;
   TProgressBar *ProgressBar1;
   TLabel *Label12;
   TLabel *Process_Label;
   TGroupBox *GroupBox8;
   TGroupBox *GroupBox9;
   TLabel *Label13;
   TLabel *Label14;
   TLabel *Label15;
   TEdit *iSDR_DATA;
   TEdit *oSDR_ADDR;
   TEdit *oSDR_DATA;
   TGroupBox *GroupBox10;
   TLabel *Label16;
   TLabel *Label17;
   TEdit *iSDR_SWR_ADDR;
   TEdit *iSDR_SWR_Length;
   TGroupBox *GroupBox11;
   TLabel *Label18;
   TLabel *Label19;
   TEdit *iSDR_SRD_ADDR;
   TEdit *iSDR_SRD_Length;
   TButton *Button9;
   TButton *Button10;
   TButton *Button11;
   TCheckBox *CheckBox3;
   TButton *Button12;
   TCheckBox *CheckBox4;
   TPageControl *PageControl1;
   TTabSheet *TabSheet2;
   TTabSheet *TabSheet3;
   TMenuItem *OpenUSBPort1;
   TMenuItem *OpenUSBPort2;
   TMenuItem *OpenUSBPort3;
   TMenuItem *NonUSBPort1;
   TOpenDialog *OpenDialog1;
   TSaveDialog *SaveDialog1;
   TOpenDialog *OpenDialog2;
   TSaveDialog *SaveDialog2;
   TTabSheet *TabSheet4;
   TComboBox *Sdram_Multi;
   TComboBox *Flash_Multi;
   TLabel *Label20;
   TLabel *Label21;
   TButton *Button13;
   TButton *Button14;
   TMenuItem *CloseUSBPort1;
   TTabSheet *TabSheet5;
   TGroupBox *GroupBox13;
   TGroupBox *GroupBox14;
   TLabel *Label22;
   TLabel *Label23;
   TLabel *Label24;
   TEdit *iSR_DATA;
   TEdit *oSR_ADDR;
   TEdit *oSR_DATA;
   TGroupBox *GroupBox15;
   TLabel *Label25;
   TLabel *Label26;
   TEdit *iSR_SWR_ADDR;
   TEdit *iSR_SWR_Length;
   TGroupBox *GroupBox16;
   TLabel *Label27;
   TLabel *Label28;
   TEdit *iSR_SRD_ADDR;
   TEdit *iSR_SRD_Length;
   TButton *Button15;
   TButton *Button16;
   TButton *Button17;
   TButton *Button18;
   TOpenDialog *OpenDialog3;
   TSaveDialog *SaveDialog3;
   TCheckBox *CheckBox5;
   TCheckBox *CheckBox6;
   TTabSheet *TabSheet6;
   TLabel *Label1;
   TLabel *Label2;
   TLabel *Label3;
   TLabel *Label4;
   TButton *Button1;
   TComboBox *DIG_4;
   TComboBox *DIG_3;
   TComboBox *DIG_2;
   TComboBox *DIG_1;
   TGroupBox *GroupBox6;
   TMemo *Memo1;
   TButton *Button8;
   TGroupBox *GroupBox2;
   TCheckBox *D1;
   TCheckBox *D2;
   TCheckBox *D3;
   TCheckBox *D4;
   TButton *Button2;
   TCheckBox *D5;
   TCheckBox *D6;
   TCheckBox *D7;
   TCheckBox *D8;
   TCheckBox *DR9;
   TCheckBox *DR8;
   TCheckBox *DR7;
   TCheckBox *DR6;
   TCheckBox *DR5;
   TCheckBox *DR4;
   TCheckBox *DR3;
   TCheckBox *DR2;
   TCheckBox *DR1;
   TCheckBox *DR0;
   TLabel *Label33;
   TComboBox *Sram_Multi;
   TTabSheet *TabSheet7;
   TImage *Image1;
   TScrollBar *ScrollBar1;
   TScrollBar *ScrollBar2;
   TLabel *Label36;
   TLabel *Label34;
   TCheckBox *Default_IMG;
   TCheckBox *Cursor_EN;
   TLabel *Cur_X;
   TLabel *Cur_Y;
   void __fastcall FormClose(TObject *Sender, TCloseAction &Action);
   void __fastcall Button2Click(TObject *Sender);
   void __fastcall Button5Click(TObject *Sender);
   void __fastcall Button4Click(TObject *Sender);
   void __fastcall Button3Click(TObject *Sender);
   void __fastcall Button6Click(TObject *Sender);
   void __fastcall Button7Click(TObject *Sender);
   void __fastcall CheckBox1Click(TObject *Sender);
   void __fastcall CheckBox2Click(TObject *Sender);
   void __fastcall OpenUSBPort0Click(TObject *Sender);
   void __fastcall About1Click(TObject *Sender);
   void __fastcall Help1Click(TObject *Sender);
   void __fastcall Button8Click(TObject *Sender);
   void __fastcall CheckBox4Click(TObject *Sender);
   void __fastcall CheckBox3Click(TObject *Sender);
   void __fastcall Button9Click(TObject *Sender);
   void __fastcall Button10Click(TObject *Sender);
   void __fastcall Button11Click(TObject *Sender);
   void __fastcall Button12Click(TObject *Sender);
   void __fastcall OpenUSBPort1Click(TObject *Sender);
   void __fastcall OpenUSBPort2Click(TObject *Sender);
   void __fastcall OpenUSBPort3Click(TObject *Sender);
   void __fastcall TabSheet1Show(TObject *Sender);
   void __fastcall Button13Click(TObject *Sender);
   void __fastcall CloseUSBPort1Click(TObject *Sender);
   void __fastcall Button14Click(TObject *Sender);
   void __fastcall TabSheet2Show(TObject *Sender);
   void __fastcall TabSheet3Show(TObject *Sender);
   void __fastcall TabSheet4Show(TObject *Sender);
   void __fastcall TabSheet5Show(TObject *Sender);
   void __fastcall Button16Click(TObject *Sender);
   void __fastcall Button17Click(TObject *Sender);
   void __fastcall CheckBox5Click(TObject *Sender);
   void __fastcall CheckBox6Click(TObject *Sender);
   void __fastcall Button15Click(TObject *Sender);
   void __fastcall Button18Click(TObject *Sender);
   void __fastcall TabSheet6Show(TObject *Sender);
   void __fastcall TabSheet7Show(TObject *Sender);
   void __fastcall ScrollBar2Change(TObject *Sender);
   void __fastcall ScrollBar1Change(TObject *Sender);
   void __fastcall Default_IMGClick(TObject *Sender);
   void __fastcall Cursor_ENClick(TObject *Sender);
        void __fastcall Button1Click(TObject *Sender);
private:	// User declarations
public:		// User declarations
   __fastcall TForm1(TComponent* Owner);
   void __fastcall Show_All_Button(bool Show);
   void __fastcall Close_USB_Port();
   int __fastcall  HexToInt(AnsiString strHex);
   int __fastcall Select_File(String File_Name);
   int __fastcall AscToHex(unsigned char a);
   int __fastcall File_AscToHex(String File_Input,String File_Output,int File_Type);
   int __fastcall File_HexToAsc(String File_Input,String File_Output,int File_Type);
   TThread *PS2_REC;
   USB_JTAG USB1;
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
extern int PS2_times;
//---------------------------------------------------------------------------
#endif
