//////////////////////////////////////////////////////////////////////
////                                                              ////
////  SBOX 7                                                      ////
////                                                              ////
////  This file is part of the SystemC DES                        ////
////                                                              ////
////  Description:                                                ////
////  Sbox of DES algorithm                                       ////
////                                                              ////
////  To Do:                                                      ////
////   - done                                                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - Javier Castillo, jcastilo@opencores.org               ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.1.1.1  2004/07/05 17:31:18  jcastillo
// First import
//

#include "s7.h"

void
s7::s7_box ()
{
  switch (stage1_input.read ())
    {
    case 0:
      stage1_output.write (4);
      break;
    case 1:
      stage1_output.write (13);
      break;
    case 2:
      stage1_output.write (11);
      break;
    case 3:
      stage1_output.write (0);
      break;
    case 4:
      stage1_output.write (2);
      break;
    case 5:
      stage1_output.write (11);
      break;
    case 6:
      stage1_output.write (14);
      break;
    case 7:
      stage1_output.write (7);
      break;
    case 8:
      stage1_output.write (15);
      break;
    case 9:
      stage1_output.write (4);
      break;
    case 10:
      stage1_output.write (0);
      break;
    case 11:
      stage1_output.write (9);
      break;
    case 12:
      stage1_output.write (8);
      break;
    case 13:
      stage1_output.write (1);
      break;
    case 14:
      stage1_output.write (13);
      break;
    case 15:
      stage1_output.write (10);
      break;
    case 16:
      stage1_output.write (3);
      break;
    case 17:
      stage1_output.write (14);
      break;
    case 18:
      stage1_output.write (12);
      break;
    case 19:
      stage1_output.write (3);
      break;
    case 20:
      stage1_output.write (9);
      break;
    case 21:
      stage1_output.write (5);
      break;
    case 22:
      stage1_output.write (7);
      break;
    case 23:
      stage1_output.write (12);
      break;
    case 24:
      stage1_output.write (5);
      break;
    case 25:
      stage1_output.write (2);
      break;
    case 26:
      stage1_output.write (10);
      break;
    case 27:
      stage1_output.write (15);
      break;
    case 28:
      stage1_output.write (6);
      break;
    case 29:
      stage1_output.write (8);
      break;
    case 30:
      stage1_output.write (1);
      break;
    case 31:
      stage1_output.write (6);
      break;
    case 32:
      stage1_output.write (1);
      break;
    case 33:
      stage1_output.write (6);
      break;
    case 34:
      stage1_output.write (4);
      break;
    case 35:
      stage1_output.write (11);
      break;
    case 36:
      stage1_output.write (11);
      break;
    case 37:
      stage1_output.write (13);
      break;
    case 38:
      stage1_output.write (13);
      break;
    case 39:
      stage1_output.write (8);
      break;
    case 40:
      stage1_output.write (12);
      break;
    case 41:
      stage1_output.write (1);
      break;
    case 42:
      stage1_output.write (3);
      break;
    case 43:
      stage1_output.write (4);
      break;
    case 44:
      stage1_output.write (7);
      break;
    case 45:
      stage1_output.write (10);
      break;
    case 46:
      stage1_output.write (14);
      break;
    case 47:
      stage1_output.write (7);
      break;
    case 48:
      stage1_output.write (10);
      break;
    case 49:
      stage1_output.write (9);
      break;
    case 50:
      stage1_output.write (15);
      break;
    case 51:
      stage1_output.write (5);
      break;
    case 52:
      stage1_output.write (6);
      break;
    case 53:
      stage1_output.write (0);
      break;
    case 54:
      stage1_output.write (8);
      break;
    case 55:
      stage1_output.write (15);
      break;
    case 56:
      stage1_output.write (0);
      break;
    case 57:
      stage1_output.write (14);
      break;
    case 58:
      stage1_output.write (5);
      break;
    case 59:
      stage1_output.write (2);
      break;
    case 60:
      stage1_output.write (9);
      break;
    case 61:
      stage1_output.write (3);
      break;
    case 62:
      stage1_output.write (2);
      break;
    case 63:
      stage1_output.write (12);
      break;
    }


}
