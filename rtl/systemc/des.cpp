//////////////////////////////////////////////////////////////////////
////                                                              ////
////  DES algorithm implementation                                ////
////                                                              ////
////  This file is part of the SystemC DES                        ////
////                                                              ////
////  Description:                                                ////
////  Top file for DES algorithm                                  ////
////                                                              ////
////  To Do:                                                      ////
////   - nothing                                                  ////
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
// Revision 1.1.1.1  2004/07/05 17:31:17  jcastillo
// First import
//

#include "des.h"

void
des::reg_signal ()
{
  if (!reset)
    {
      ready_o.write (0);
      data_o.write (0);
      stage1_iter.write (0);
      data_ready.write (1);
    }
  else
    {
      ready_o.write (next_ready_o.read ());
      data_o.write (next_data_o.read ());
      stage1_iter.write (next_stage1_iter.read ());
      data_ready.write (next_data_ready.read ());
    }

}

void
des::des_proc ()
{

  sc_uint < 32 > L_i_var, R_i_var;
  sc_uint < 64 > data_i_var, data_o_var, data_o_var_t, key_i_var;
  sc_uint < 56 > key_var_perm;

  L_i_var = 0;
  R_i_var = 0;
  data_i_var = 0;

  next_ready_o.write (0);
  next_data_ready.write (data_ready.read ());
  next_stage1_iter.write (stage1_iter.read ());

  stage1_L_i.write (0);
  stage1_R_i.write (0);
  stage1_round_key_i.write (0);

  //The permutations are always performed => less resources needed     

  key_i_var = key_i.read ();

  key_var_perm[55] = key_i_var[7];
  key_var_perm[54] = key_i_var[15];
  key_var_perm[53] = key_i_var[23];
  key_var_perm[52] = key_i_var[31];
  key_var_perm[51] = key_i_var[39];
  key_var_perm[50] = key_i_var[47];
  key_var_perm[49] = key_i_var[55];
  key_var_perm[48] = key_i_var[63];

  key_var_perm[47] = key_i_var[6];
  key_var_perm[46] = key_i_var[14];
  key_var_perm[45] = key_i_var[22];
  key_var_perm[44] = key_i_var[30];
  key_var_perm[43] = key_i_var[38];
  key_var_perm[42] = key_i_var[46];
  key_var_perm[41] = key_i_var[54];
  key_var_perm[40] = key_i_var[62];

  key_var_perm[39] = key_i_var[5];
  key_var_perm[38] = key_i_var[13];
  key_var_perm[37] = key_i_var[21];
  key_var_perm[36] = key_i_var[29];
  key_var_perm[35] = key_i_var[37];
  key_var_perm[34] = key_i_var[45];
  key_var_perm[33] = key_i_var[53];
  key_var_perm[32] = key_i_var[61];

  key_var_perm[31] = key_i_var[4];
  key_var_perm[30] = key_i_var[12];
  key_var_perm[29] = key_i_var[20];
  key_var_perm[28] = key_i_var[28];
  key_var_perm[27] = key_i_var[1];
  key_var_perm[26] = key_i_var[9];
  key_var_perm[25] = key_i_var[17];
  key_var_perm[24] = key_i_var[25];

  key_var_perm[23] = key_i_var[33];
  key_var_perm[22] = key_i_var[41];
  key_var_perm[21] = key_i_var[49];
  key_var_perm[20] = key_i_var[57];
  key_var_perm[19] = key_i_var[2];
  key_var_perm[18] = key_i_var[10];
  key_var_perm[17] = key_i_var[18];
  key_var_perm[16] = key_i_var[26];

  key_var_perm[15] = key_i_var[34];
  key_var_perm[14] = key_i_var[42];
  key_var_perm[13] = key_i_var[50];
  key_var_perm[12] = key_i_var[58];
  key_var_perm[11] = key_i_var[3];
  key_var_perm[10] = key_i_var[11];
  key_var_perm[9] = key_i_var[19];
  key_var_perm[8] = key_i_var[27];

  key_var_perm[7] = key_i_var[35];
  key_var_perm[6] = key_i_var[43];
  key_var_perm[5] = key_i_var[51];
  key_var_perm[4] = key_i_var[59];
  key_var_perm[3] = key_i_var[36];
  key_var_perm[2] = key_i_var[44];
  key_var_perm[1] = key_i_var[52];
  key_var_perm[0] = key_i_var[60];


  //Apply data to round module with the IP
  data_i_var = data_i.read ();
  L_i_var[31] = data_i_var[6];
  L_i_var[30] = data_i_var[14];
  L_i_var[29] = data_i_var[22];
  L_i_var[28] = data_i_var[30];
  L_i_var[27] = data_i_var[38];
  L_i_var[26] = data_i_var[46];
  L_i_var[25] = data_i_var[54];
  L_i_var[24] = data_i_var[62];

  L_i_var[23] = data_i_var[4];
  L_i_var[22] = data_i_var[12];
  L_i_var[21] = data_i_var[20];
  L_i_var[20] = data_i_var[28];
  L_i_var[19] = data_i_var[36];
  L_i_var[18] = data_i_var[44];
  L_i_var[17] = data_i_var[52];
  L_i_var[16] = data_i_var[60];

  L_i_var[15] = data_i_var[2];
  L_i_var[14] = data_i_var[10];
  L_i_var[13] = data_i_var[18];
  L_i_var[12] = data_i_var[26];
  L_i_var[11] = data_i_var[34];
  L_i_var[10] = data_i_var[42];
  L_i_var[9] = data_i_var[50];
  L_i_var[8] = data_i_var[58];

  L_i_var[7] = data_i_var[0];
  L_i_var[6] = data_i_var[8];
  L_i_var[5] = data_i_var[16];
  L_i_var[4] = data_i_var[24];
  L_i_var[3] = data_i_var[32];
  L_i_var[2] = data_i_var[40];
  L_i_var[1] = data_i_var[48];
  L_i_var[0] = data_i_var[56];

  R_i_var[31] = data_i_var[7];
  R_i_var[30] = data_i_var[15];
  R_i_var[29] = data_i_var[23];
  R_i_var[28] = data_i_var[31];
  R_i_var[27] = data_i_var[39];
  R_i_var[26] = data_i_var[47];
  R_i_var[25] = data_i_var[55];
  R_i_var[24] = data_i_var[63];

  R_i_var[23] = data_i_var[5];
  R_i_var[22] = data_i_var[13];
  R_i_var[21] = data_i_var[21];
  R_i_var[20] = data_i_var[29];
  R_i_var[19] = data_i_var[37];
  R_i_var[18] = data_i_var[45];
  R_i_var[17] = data_i_var[53];
  R_i_var[16] = data_i_var[61];

  R_i_var[15] = data_i_var[3];
  R_i_var[14] = data_i_var[11];
  R_i_var[13] = data_i_var[19];
  R_i_var[12] = data_i_var[27];
  R_i_var[11] = data_i_var[35];
  R_i_var[10] = data_i_var[43];
  R_i_var[9] = data_i_var[51];
  R_i_var[8] = data_i_var[59];

  R_i_var[7] = data_i_var[1];
  R_i_var[6] = data_i_var[9];
  R_i_var[5] = data_i_var[17];
  R_i_var[4] = data_i_var[25];
  R_i_var[3] = data_i_var[33];
  R_i_var[2] = data_i_var[41];
  R_i_var[1] = data_i_var[49];
  R_i_var[0] = data_i_var[57];

  //IP-1 Permutation

  data_o_var_t.range (63, 32) = stage1_R_o.read ();
  data_o_var_t.range (31, 0) = stage1_L_o.read ();

  data_o_var[63] = data_o_var_t[24];
  data_o_var[62] = data_o_var_t[56];
  data_o_var[61] = data_o_var_t[16];
  data_o_var[60] = data_o_var_t[48];
  data_o_var[59] = data_o_var_t[8];
  data_o_var[58] = data_o_var_t[40];
  data_o_var[57] = data_o_var_t[0];
  data_o_var[56] = data_o_var_t[32];

  data_o_var[55] = data_o_var_t[25];
  data_o_var[54] = data_o_var_t[57];
  data_o_var[53] = data_o_var_t[17];
  data_o_var[52] = data_o_var_t[49];
  data_o_var[51] = data_o_var_t[9];
  data_o_var[50] = data_o_var_t[41];
  data_o_var[49] = data_o_var_t[1];
  data_o_var[48] = data_o_var_t[33];

  data_o_var[47] = data_o_var_t[26];
  data_o_var[46] = data_o_var_t[58];
  data_o_var[45] = data_o_var_t[18];
  data_o_var[44] = data_o_var_t[50];
  data_o_var[43] = data_o_var_t[10];
  data_o_var[42] = data_o_var_t[42];
  data_o_var[41] = data_o_var_t[2];
  data_o_var[40] = data_o_var_t[34];

  data_o_var[39] = data_o_var_t[27];
  data_o_var[38] = data_o_var_t[59];
  data_o_var[37] = data_o_var_t[19];
  data_o_var[36] = data_o_var_t[51];
  data_o_var[35] = data_o_var_t[11];
  data_o_var[34] = data_o_var_t[43];
  data_o_var[33] = data_o_var_t[3];
  data_o_var[32] = data_o_var_t[35];

  data_o_var[31] = data_o_var_t[28];
  data_o_var[30] = data_o_var_t[60];
  data_o_var[29] = data_o_var_t[20];
  data_o_var[28] = data_o_var_t[52];
  data_o_var[27] = data_o_var_t[12];
  data_o_var[26] = data_o_var_t[44];
  data_o_var[25] = data_o_var_t[4];
  data_o_var[24] = data_o_var_t[36];

  data_o_var[23] = data_o_var_t[29];
  data_o_var[22] = data_o_var_t[61];
  data_o_var[21] = data_o_var_t[21];
  data_o_var[20] = data_o_var_t[53];
  data_o_var[19] = data_o_var_t[13];
  data_o_var[18] = data_o_var_t[45];
  data_o_var[17] = data_o_var_t[5];
  data_o_var[16] = data_o_var_t[37];

  data_o_var[15] = data_o_var_t[30];
  data_o_var[14] = data_o_var_t[62];
  data_o_var[13] = data_o_var_t[22];
  data_o_var[12] = data_o_var_t[54];
  data_o_var[11] = data_o_var_t[14];
  data_o_var[10] = data_o_var_t[46];
  data_o_var[9] = data_o_var_t[6];
  data_o_var[8] = data_o_var_t[38];

  data_o_var[7] = data_o_var_t[31];
  data_o_var[6] = data_o_var_t[63];
  data_o_var[5] = data_o_var_t[23];
  data_o_var[4] = data_o_var_t[55];
  data_o_var[3] = data_o_var_t[15];
  data_o_var[2] = data_o_var_t[47];
  data_o_var[1] = data_o_var_t[7];
  data_o_var[0] = data_o_var_t[39];

  //Assign data output
  next_data_o.write (data_o_var);

  //FSM to control the round datapath         
  stage1_iteration_i.write (stage1_iter.read ());

  next_ready_o.write (0);
  stage1_L_i.write (stage1_L_o.read ());
  stage1_R_i.write (stage1_R_o.read ());
  stage1_round_key_i.write (stage1_round_key_o.read ());

  switch (stage1_iter.read ())
    {
    case 0:
      if (load_i.read ())
	{
	  next_stage1_iter.write (1);
	  stage1_L_i.write (L_i_var);
	  stage1_R_i.write (R_i_var);
	  stage1_round_key_i.write (key_var_perm);
	  next_data_ready.write (0);
	}
      else if (!data_ready.read ())
	{
	  next_stage1_iter.write (0);
	  //Can accept data                 
	  next_ready_o.write (1);
	  next_data_ready.write (1);
	}
      break;
    case 15:
      next_stage1_iter.write (0);
      break;
    default:
      next_stage1_iter.write (stage1_iter.read () + 1);
      break;
    }

}
