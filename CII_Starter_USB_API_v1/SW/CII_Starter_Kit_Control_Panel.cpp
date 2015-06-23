//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
//---------------------------------------------------------------------------
USEFORM("Main.cpp", Form1);
USEFORM("About.cpp", AboutBox);
USEFORM("Test_Page.cpp", Form4);
//---------------------------------------------------------------------------
WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
     try
     {
           Application->Initialize();
           Application->Title = "CII Starter Kit Control Panel";
                 Application->CreateForm(__classid(TForm1), &Form1);
       Application->CreateForm(__classid(TAboutBox), &AboutBox);
       Application->CreateForm(__classid(TForm4), &Form4);
       Application->Run();
     }
     catch (Exception &exception)
     {
           Application->ShowException(&exception);
     }
     catch (...)
     {
           try
           {
                throw Exception("");
           }
           catch (Exception &exception)
           {
                Application->ShowException(&exception);
           }
     }
     return 0;
}
//---------------------------------------------------------------------------
