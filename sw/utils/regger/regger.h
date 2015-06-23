#ifndef REGGER_H
#define REGGER_H

#include <iostream>
#include <iomanip>
#include <fstream>
#include <string>
#include <deque>

using namespace std;

struct param
{
string prefix;
string name;
string value;
int row;
int name_start;
int value_start;
int value_end;
int name_end;
};

class regger
{
public:
    regger();
    void SetDriverToRTL();
    void SetRTLToDriver();
    void ShowRegs();
    void ScanFiles();
    void AddFile(string cfile, string rtlfile);
  private:
    string verilog_file;
    string c_file;
    deque<param> rtl_params;
    deque<param> driver_params;
};

#endif // REGGER_H
