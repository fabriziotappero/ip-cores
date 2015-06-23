/*
this script sets the registers in the driver, based on the gfx_params.
*/

#include <iostream>
#include <string>
#include <deque>
using namespace std;

struct param
{
string name;
string value;
}

class regger
{
public:
  SetDriverToRTL();
  SetRTLToDriver();
  ShowRegs();
  ScanFiles();
private:
  deque<param> rtl_params;
  deque<param> driver_params;
}

int menu()
{
  int option = 0;
  
  cout << "<------------- Menu ------------------->" << endl 
       << "1. Set Driver regs to RTL & Bench values" << endl 
       << "2. Set RTL & Bench regs to Driver values" << endl 
       << "3. View Regs" << endl;
  while(option < 1 || option > 3)
  {  
    cin >> option;
  }
  
  return option;
}

void SetDriverToRTL()
{

}

void SetRTLToDriver()
{

}

void ShowRegs()
{

}

int main()
{
  int option = menu();

  switch(option)
  {
    case 1:
    break;
    case 2:
    break;
    case 3:
    break;
    default:
    break;
  }
}
