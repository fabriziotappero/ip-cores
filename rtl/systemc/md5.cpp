//////////////////////////////////////////////////////////////////////
////                                                              ////
////  MD5 main implementation file                                ////
////                                                              ////
////  This file is part of the SystemC MD5                        ////
////                                                              ////
////  Description:                                                ////
////  MD5 main implementation file                                ////
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
// Revision 1.1.1.1  2004/09/08 16:24:49  jcastillo
// Initial release
//

#include "md5.h"


void
md5::md5_rom ()
{
  switch (round64.read ())
    {
    case 0:
      t.write (0xD76AA478070);
      break;
    case 1:
      t.write (0xE8C7B7560C1);
      break;
    case 2:
      t.write (0x242070DB112);
      break;
    case 3:
      t.write (0xC1BDCEEE163);
      break;
    case 4:
      t.write (0xF57C0FAF074);
      break;
    case 5:
      t.write (0x4787C62A0C5);
      break;
    case 6:
      t.write (0xA8304613116);
      break;
    case 7:
      t.write (0xFD469501167);
      break;
    case 8:
      t.write (0x698098D8078);
      break;
    case 9:
      t.write (0x8B44F7AF0C9);
      break;
    case 10:
      t.write (0xFFFF5BB111A);
      break;
    case 11:
      t.write (0x895CD7BE16B);
      break;
    case 12:
      t.write (0x6B90112207C);
      break;
    case 13:
      t.write (0xFD9871930CD);
      break;
    case 14:
      t.write (0xA679438E11E);
      break;
    case 15:
      t.write (0x49B4082116F);
      break;

    case 16:
      t.write (0xf61e2562051);
      break;
    case 17:
      t.write (0xc040b340096);
      break;
    case 18:
      t.write (0x265e5a510EB);
      break;
    case 19:
      t.write (0xe9b6c7aa140);
      break;
    case 20:
      t.write (0xd62f105d055);
      break;
    case 21:
      t.write (0x0244145309A);
      break;
    case 22:
      t.write (0xd8a1e6810EF);
      break;
    case 23:
      t.write (0xe7d3fbc8144);
      break;
    case 24:
      t.write (0x21e1cde6059);
      break;
    case 25:
      t.write (0xc33707d609E);
      break;
    case 26:
      t.write (0xf4d50d870E3);
      break;
    case 27:
      t.write (0x455a14ed148);
      break;
    case 28:
      t.write (0xa9e3e90505D);
      break;
    case 29:
      t.write (0xfcefa3f8092);
      break;
    case 30:
      t.write (0x676f02d90E7);
      break;
    case 31:
      t.write (0x8d2a4c8a14C);
      break;

    case 32:
      t.write (0xfffa3942045);
      break;
    case 33:
      t.write (0x8771f6810B8);
      break;
    case 34:
      t.write (0x6d9d612210B);
      break;
    case 35:
      t.write (0xfde5380c17E);
      break;
    case 36:
      t.write (0xa4beea44041);
      break;
    case 37:
      t.write (0x4bdecfa90B4);
      break;
    case 38:
      t.write (0xf6bb4b60107);
      break;
    case 39:
      t.write (0xbebfbc7017A);
      break;
    case 40:
      t.write (0x289b7ec604D);
      break;
    case 41:
      t.write (0xeaa127fa0B0);
      break;
    case 42:
      t.write (0xd4ef3085103);
      break;
    case 43:
      t.write (0x04881d05176);
      break;
    case 44:
      t.write (0xd9d4d039049);
      break;
    case 45:
      t.write (0xe6db99e50BC);
      break;
    case 46:
      t.write (0x1fa27cf810F);
      break;
    case 47:
      t.write (0xc4ac5665172);
      break;

    case 48:
      t.write (0xf4292244060);
      break;
    case 49:
      t.write (0x432aff970A7);
      break;
    case 50:
      t.write (0xab9423a70FE);
      break;
    case 51:
      t.write (0xfc93a039155);
      break;
    case 52:
      t.write (0x655b59c306C);
      break;
    case 53:
      t.write (0x8f0ccc920A3);
      break;
    case 54:
      t.write (0xffeff47d0FA);
      break;
    case 55:
      t.write (0x85845dd1151);
      break;
    case 56:
      t.write (0x6fa87e4f068);
      break;
    case 57:
      t.write (0xfe2ce6e00AF);
      break;
    case 58:
      t.write (0xa30143140F6);
      break;
    case 59:
      t.write (0x4e0811a115D);
      break;
    case 60:
      t.write (0xf7537e82064);
      break;
    case 61:
      t.write (0xbd3af2350AB);
      break;
    case 62:
      t.write (0x2ad7d2bb0F2);
      break;
    case 63:
      t.write (0xeb86d391159);
      break;

    }
}


void
md5::funcs ()
{
  sc_uint < 32 > aux, fr_var, tr_var, rotate1, rotate2;
  sc_uint < 8 > s_var;
  sc_uint < 4 > nblock;
  sc_uint < 32 > message_var[16];

  message_var[0]=message.read().range(511,480); 
  message_var[1]=message.read().range(479,448); 
  message_var[2]=message.read().range(447,416); 
  message_var[3]=message.read().range(415,384); 
  message_var[4]=message.read().range(383,352); 
  message_var[5]=message.read().range(351,320); 
  message_var[6]=message.read().range(319,288); 
  message_var[7]=message.read().range(287,256); 
  message_var[8]=message.read().range(255,224); 
  message_var[9]=message.read().range(223,192); 
  message_var[10]=message.read().range(191,160);  
  message_var[11]=message.read().range(159,128);  
  message_var[12]=message.read().range(127,96);  
  message_var[13]=message.read().range(95,64);  
  message_var[14]=message.read().range(63,32);  
  message_var[15]=message.read().range(31,0);   

  fr_var = 0;

  switch (round.read ())
    {
    case 0:
      fr_var = ((br.read () & cr.read ()) | (~br.read () & dr.read ()));
      break;
    case 1:
      fr_var = ((br.read () & dr.read ()) | (cr.read () & (~dr.read ())));
      break;
    case 2:
      fr_var = (br.read () ^ cr.read () ^ dr.read ());
      break;
    case 3:
      fr_var = (cr.read () ^ (br.read () | ~dr.read ()));
      break;
    default:
      break;
    }

  tr_var = t.read ().range (43, 12);
  s_var = t.read ().range (11, 4);
  nblock = t.read ().range (3, 0);

  aux = (ar.read () + fr_var + message_var[(int) nblock] + tr_var);

  //cout << (int)round64.read() << " " << (int)fr_var << " " << (int)aux << " " << (int)nblock << " " << (int)message_var[(int)nblock] << endl;

  rotate1 = aux << (int) s_var;
  rotate2 = aux >> (int) (32 - s_var);
  func_out.write (br.read () + (rotate1 | rotate2));

}

void
md5::round64FSM ()
{

  next_ar.write (ar.read ());
  next_br.write (br.read ());
  next_cr.write (cr.read ());
  next_dr.write (dr.read ());
  next_round64.write (round64.read ());
  next_round.write (round.read ());
  hash_generated.write (0);

  if (generate_hash.read () != 0)
    {
      next_ar.write (dr.read ());
      next_br.write (func_out.read ());
      next_cr.write (br.read ());
      next_dr.write (cr.read ());
    }

  switch (round64.read ())
    {

    case 0:
      next_round.write (0);
      if (generate_hash.read ())
	{
	  next_round64.write (1);
	}
      break;
    case 15:
    case 31:
    case 47:
      next_round.write (round.read () + 1);
      next_round64.write (round64.read () + 1);
      break;
    case 63:
      next_round.write (0);
      next_round64.write (0);
      hash_generated.write (1);
      break;
    default:
      next_round64.write (round64.read () + 1);
      break;
    }

  if (newtext_i.read ())
    {
      next_ar.write (0x67452301);
      next_br.write (0xEFCDAB89);
      next_cr.write (0x98BADCFE);
      next_dr.write (0x10325476);
      next_round.write (0);
      next_round64.write (0);
    }

  if (getdata_state.read () == 0)
    {
      next_ar.write (A.read ());
      next_br.write (B.read ());
      next_cr.write (C.read ());
      next_dr.write (D.read ());
    }
}

void
md5::reg_signal ()
{
  if (!reset)
    {
      ready_o.write (0);
      data_o.write (0);
      message.write (0);

      ar.write (0x67452301);
      br.write (0xEFCDAB89);
      cr.write (0x98BADCFE);
      dr.write (0x10325476);

      getdata_state.write (0);
      generate_hash.write (0);

      round.write (0);
      round64.write (0);

      A.write (0x67452301);
      B.write (0xEFCDAB89);
      C.write (0x98BADCFE);
      D.write (0x10325476);

    }
  else
    {
      ready_o.write (next_ready_o.read ());
      data_o.write (next_data_o.read ());
      message.write (next_message.read ());

      ar.write (next_ar.read ());
      br.write (next_br.read ());
      cr.write (next_cr.read ());
      dr.write (next_dr.read ());

      A.write (next_A.read ());
      B.write (next_B.read ());
      C.write (next_C.read ());
      D.write (next_D.read ());

      generate_hash.write (next_generate_hash.read ());
      getdata_state.write (next_getdata_state.read ());

      round.write (next_round.read ());
      round64.write (next_round64.read ());

    }

}


void
md5::md5_getdata ()
{

  sc_biguint < 128 > data_o_var;
  sc_biguint < 512 > aux;

  sc_uint < 32 > A_t, B_t, C_t, D_t;

  next_A.write (A.read ());
  next_B.write (B.read ());
  next_C.write (C.read ());
  next_D.write (D.read ());

  next_generate_hash.write (0);
  next_ready_o.write (0);
  next_data_o.write (0);

  aux = message.read ();
  next_message.write (message.read ());
  next_getdata_state.write (getdata_state.read ());

  if (newtext_i.read ())
    {
      next_A.write (0x67452301);
      next_B.write (0xEFCDAB89);
      next_C.write (0x98BADCFE);
      next_D.write (0x10325476);
      next_getdata_state.write (0);
    }

  switch (getdata_state.read ())
    {

    case 0:
      if (load_i.read ())
	{
	  aux.range (511, 384) = data_i.read ();
	  next_message.write (aux);
	  next_getdata_state.write (1);
	}
      break;
    case 1:
      if (load_i.read ())
	{
	  aux.range (383, 256) = data_i.read ();
	  next_message.write (aux);
	  next_getdata_state.write (2);
	}
      break;
    case 2:
      if (load_i.read ())
	{
	  aux.range (255, 128) = data_i.read ();
	  next_message.write (aux);
	  next_getdata_state.write (3);
	}
      break;
    case 3:
      if (load_i.read ())
	{
	  aux.range (127, 0) = data_i.read ();
	  next_message.write (aux);
	  next_getdata_state.write (4);
	  next_generate_hash.write (1);
	}
      break;
    case 4:
      next_generate_hash.write (1);

      A_t = dr.read () + A.read ();
      B_t = func_out.read () + B.read ();
      C_t = br.read () + C.read ();
      D_t = cr.read () + D.read ();

      data_o_var.range (127, 96) = A_t;
      data_o_var.range (95, 64) = B_t;
      data_o_var.range (63, 32) = C_t;
      data_o_var.range (31, 0) = D_t;
      next_data_o.write (data_o_var);


      if (hash_generated.read ())
	{
	  next_A.write (A_t);
	  next_B.write (B_t);
	  next_C.write (C_t);
	  next_D.write (D_t);
	  next_getdata_state.write (0);
	  next_ready_o.write (1);
	  next_generate_hash.write (0);
	}
      break;
    }

}
