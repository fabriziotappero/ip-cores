// $Id: testtclsh.cpp 504 2013-04-13 15:37:24Z mueller $
//
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
//
// This program is free software; you may redistribute and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 2, or at your option any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for complete details.
// 
// Revision History: 
// Date         Rev Version  Comment
// 2013-02-10   485   1.0    Initial version
// ---------------------------------------------------------------------------

#include <stdlib.h>
#include <stdio.h>
#include <readline/readline.h>
#include <readline/history.h>

#include "tcl.h"

#include <iostream>

using namespace std;

extern "C" int Rutiltpp_Init(Tcl_Interp* interp);
extern "C" int Rlinktpp_Init(Tcl_Interp* interp);
//extern "C" int Rusbtpp_Init(Tcl_Interp* interp);
extern "C" int Rwxxtpp_Init(Tcl_Interp* interp);

int main(int argc, const char* argv[]) 
{
  cout << "testtclsh starting..." << endl;

  Tcl_Interp* interp = Tcl_CreateInterp();
  if (!interp) {
    cout << "Tcl_CreateInterp() failed" << endl;
    return 1;
  }
  
  Rutiltpp_Init(interp);
  Rlinktpp_Init(interp);
  // Rusbtpp_Init(interp);
  Rwxxtpp_Init(interp);

  char* line;
  while ((line = readline("testtclsh> "))) {
    if (line[0]!=0) add_history(line);
    int rc = Tcl_Eval(interp, line);
    if (rc != TCL_OK) {
      cout << "command '" << line << "' failed" << endl;
    }
    const char* res = Tcl_GetStringResult(interp);
    if (res && res[0])
      cout << Tcl_GetStringResult(interp) << endl;
    free(line);
  }

  Tcl_DeleteInterp(interp);
  Tcl_Finalize();

  cout << "testtclsh exit..." << endl;
  return 0;
}
