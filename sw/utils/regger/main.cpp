#include <iostream>
#include "regger.h"
using namespace std;

int menu()
{
  int option = 0;

  cout << "<------------- Menu ------------------->" << endl
       << "1. Set Driver regs to RTL & Bench values" << endl
       << "2. Set RTL & Bench regs to Driver values" << endl
       << "3. View Regs"                             << endl
       << "4. Exit"                                  << endl
       << "<-------------------------------------->" << endl;

  cin >> option;


  return option;
}

int main()
{
    regger reg;
    //reg.AddFile("test.c","test.v");
    reg.AddFile("../../drivers/gfx/bare/oc_gfx_regs.h","../../../rtl/verilog/gfx/gfx_params.v");
    reg.ScanFiles();
    reg.ShowRegs();
    reg.SetRTLToDriver();
    //reg.SetDriverToRTL();
    return 0;

    while(1)
    {
        int option = menu();

        switch(option)
        {
          case 1:
            reg.SetDriverToRTL();
          break;
          case 2:
            reg.SetDriverToRTL();
          break;
          case 3:
            reg.ShowRegs();
          break;
          case 4:
            return 0;
          default:
          break;
        }
    }

}

