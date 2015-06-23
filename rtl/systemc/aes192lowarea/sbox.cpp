//////////////////////////////////////////////////////////////////////
////                                                              ////
////  AES sbox module implementation                              ////
////                                                              ////
////  This file is part of the SystemC AES                        ////
////                                                              ////
////  Description:                                                ////
////  S-box calculation calculating inverse on gallois field      ////
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

#include "sbox.h"

void sbox::registers(){
  if(!reset.read()){
     to_invert.write(0);
	 ah_reg.write(0);
     alph.write(0);	  
  }else{
	 to_invert.write(next_to_invert.read());
	 ah_reg.write(next_ah_reg.read());
     alph.write(next_alph.read());	  
  }	  
}

void sbox::first_mux(){
	sc_uint<8> data_var;
	sc_uint<8> InvInput;
	sc_uint<4> ah_t,al_t;
	bool aA,aB,aC,aD;
	
	data_var=data_i.read();
	InvInput=data_var;
	
	switch(decrypt_i.read()){
		case 1:
		  //Apply inverse affine trasformation
          aA=data_var[0]^data_var[5]; aB=data_var[1]^data_var[4];
		  aC=data_var[2]^data_var[7]; aD=data_var[3]^data_var[6];
		  InvInput[0]=(!data_var[5])^aC;
		  InvInput[1]=data_var[0]^aD;
		  InvInput[2]=(!data_var[7])^aB;
		  InvInput[3]=data_var[2]^aA;
		  InvInput[4]=data_var[1]^aD;
		  InvInput[5]=data_var[4]^aC;
		  InvInput[6]=data_var[3]^aA;
		  InvInput[7]=data_var[6]^aB;
		  break;
		default:
          InvInput=data_var;
		  break;
	}	
	
	//Convert elements from GF(2^8) into two elements of GF(2^4^2)
	
	aA=InvInput[1]^InvInput[7];
	aB=InvInput[5]^InvInput[7];
	aC=InvInput[4]^InvInput[6];
	
	
	al_t[0]=aC^InvInput[0]^InvInput[5];
	al_t[1]=InvInput[1]^InvInput[2];
	al_t[2]=aA;
	al_t[3]=InvInput[2]^InvInput[4];
	
	ah_t[0]=aC^InvInput[5];
	ah_t[1]=aA^aC;
	ah_t[2]=aB^InvInput[2]^InvInput[3];
	ah_t[3]=aB;
	
	al.write(al_t);
	ah.write(ah_t);
	next_ah_reg.write(ah_t);
}

void sbox::end_mux(){	
	sc_uint<8> data_var,data_o_var;
	bool aA,aB,aC,aD;


	//Take the output of the inverter
	data_var=inva.read();
	
	switch(decrypt_i.read()){
		case 0:
		  //Apply affine trasformation
          aA=data_var[0]^data_var[1]; aB=data_var[2]^data_var[3];
		  aC=data_var[4]^data_var[5]; aD=data_var[6]^data_var[7];
		  data_o_var[0]=(!data_var[0])^aC^aD;
		  data_o_var[1]=(!data_var[5])^aA^aD;
		  data_o_var[2]=data_var[2]^aA^aD;
		  data_o_var[3]=data_var[7]^aA^aB;
		  data_o_var[4]=data_var[4]^aA^aB;
		  data_o_var[5]=(!data_var[1])^aB^aC;
		  data_o_var[6]=(!data_var[6])^aB^aC;
		  data_o_var[7]=data_var[3]^aC^aD;
		  data_o.write(data_o_var);
		  break;
		default:
          data_o.write(data_var);
		  break;
	}	
	
}	
	
//Four operations in parallel
void sbox::square1(){
	sc_uint<4> ah_t;
	
	ah_t[0]=ah.read()[0]^ah.read()[2];
	ah_t[1]=ah.read()[2];
	ah_t[2]=ah.read()[1]^ah.read()[3];
	ah_t[3]=ah.read()[3];
	
	ah2.write(ah_t);
}

void sbox::square2(){
	sc_uint<4> al_t;
	
	al_t[0]=al.read()[0]^al.read()[2];
	al_t[1]=al.read()[2];
	al_t[2]=al.read()[1]^al.read()[3];
	al_t[3]=al.read()[3];
	
	al2.write(al_t);
}	
	
void sbox::mul1(){
	//al x ah
    sc_uint<4> alxh_t;
	sc_uint<4> aA,aB;
	
	aA=al.read()[0]^al.read()[3];
	aB=al.read()[2]^al.read()[3];
	
	alxh_t[0]=(al.read()[0]&ah.read()[0])^(al.read()[3]&ah.read()[1])^(al.read()[2]&ah.read()[2])^(al.read()[1]&ah.read()[3]);
	alxh_t[1]=(al.read()[1]&ah.read()[0])^(aA&ah.read()[1])^(aB&ah.read()[2])^((al.read()[1]^al.read()[2])&ah.read()[3]);
	alxh_t[2]=(al.read()[2]&ah.read()[0])^(al.read()[1]&ah.read()[1])^(aA&ah.read()[2])^(aB&ah.read()[3]);
	alxh_t[3]=(al.read()[3]&ah.read()[0])^(al.read()[2]&ah.read()[1])^(al.read()[1]&ah.read()[2])^(aA&ah.read()[3]);
	
	alxh.write(alxh_t);
}

void sbox::sum1(){
	sc_uint<4> alph_t;
	
	alph_t[0]=al.read()[0]^ah.read()[0];
	alph_t[1]=al.read()[1]^ah.read()[1];
	alph_t[2]=al.read()[2]^ah.read()[2];
	alph_t[3]=al.read()[3]^ah.read()[3];
	
	next_alph.write(alph_t);
}	

//Secuential operations
void sbox::intermediate(){
	sc_uint<4> aA,aB;
	sc_uint<4> ah2e,ah2epl2,to_invert_var;
	
	//ah square is multiplied with e
	aA=ah2.read()[0]^ah2.read()[1];
	aB=ah2.read()[2]^ah2.read()[3];
	ah2e[0]=ah2.read()[1]^aB;
	ah2e[1]=aA;
	ah2e[2]=aA^ah2.read()[2];
	ah2e[3]=aA^aB;
	
	//Addition of ah2e plus al2
	ah2epl2[0]=ah2e[0]^al2.read()[0];
	ah2epl2[1]=ah2e[1]^al2.read()[1];
	ah2epl2[2]=ah2e[2]^al2.read()[2];
	ah2epl2[3]=ah2e[3]^al2.read()[3];
	
	//Addition of last result with the result of (al x ah)
	to_invert_var[0]=ah2epl2[0]^alxh.read()[0];
	to_invert_var[1]=ah2epl2[1]^alxh.read()[1];
	to_invert_var[2]=ah2epl2[2]^alxh.read()[2];
	to_invert_var[3]=ah2epl2[3]^alxh.read()[3];

    //Registers 
	next_to_invert.write(to_invert_var);
}


void sbox::inversion(){
	sc_uint<4> to_invert_var;
	sc_uint<4> aA,d_t;
	
	to_invert_var=to_invert.read();
	
	//Invert the result in GF(2^4)
	aA=to_invert_var[1]^to_invert_var[2]^to_invert_var[3]^(to_invert_var[1]&to_invert_var[2]&to_invert_var[3]);
	d_t[0]=aA^to_invert_var[0]^(to_invert_var[0]&to_invert_var[2])^(to_invert_var[1]&to_invert_var[2])^(to_invert_var[0]&to_invert_var[1]&to_invert_var[2]);
	d_t[1]=(to_invert_var[0]&to_invert_var[1])^(to_invert_var[0]&to_invert_var[2])^(to_invert_var[1]&to_invert_var[2])^to_invert_var[3]^(to_invert_var[1]&to_invert_var[3])^(to_invert_var[0]&to_invert_var[1]&to_invert_var[3]);
	d_t[2]=(to_invert_var[0]&to_invert_var[1])^to_invert_var[2]^(to_invert_var[0]&to_invert_var[2])^to_invert_var[3]^(to_invert_var[0]&to_invert_var[3])^(to_invert_var[0]&to_invert_var[2]&to_invert_var[3]);
	d_t[3]=aA^(to_invert_var[0]&to_invert_var[3])^(to_invert_var[1]&to_invert_var[3])^(to_invert_var[2]&to_invert_var[3]);
	
	d.write(d_t);
	
}

void sbox::mul2(){
	//ah x d
    sc_uint<4> ahp_t;
	sc_uint<4> aA,aB;
	
	aA=ah_reg.read()[0]^ah_reg.read()[3];
	aB=ah_reg.read()[2]^ah_reg.read()[3];
	
	ahp_t[0]=(ah_reg.read()[0]&d.read()[0])^(ah_reg.read()[3]&d.read()[1])^(ah_reg.read()[2]&d.read()[2])^(ah_reg.read()[1]&d.read()[3]);
	ahp_t[1]=(ah_reg.read()[1]&d.read()[0])^(aA&d.read()[1])^(aB&d.read()[2])^((ah_reg.read()[1]^ah_reg.read()[2])&d.read()[3]);
	ahp_t[2]=(ah_reg.read()[2]&d.read()[0])^(ah_reg.read()[1]&d.read()[1])^(aA&d.read()[2])^(aB&d.read()[3]);
	ahp_t[3]=(ah_reg.read()[3]&d.read()[0])^(ah_reg.read()[2]&d.read()[1])^(ah_reg.read()[1]&d.read()[2])^(aA&d.read()[3]);
	
	ahp.write(ahp_t);
}

void sbox::mul3(){
	//d x al
    sc_uint<4> alp_t;
	sc_uint<4> aA,aB;
	
	aA=d.read()[0]^d.read()[3];
	aB=d.read()[2]^d.read()[3];
	
	alp_t[0]=(d.read()[0]&alph.read()[0])^(d.read()[3]&alph.read()[1])^(d.read()[2]&alph.read()[2])^(d.read()[1]&alph.read()[3]);
	alp_t[1]=(d.read()[1]&alph.read()[0])^(aA&alph.read()[1])^(aB&alph.read()[2])^((d.read()[1]^d.read()[2])&alph.read()[3]);
	alp_t[2]=(d.read()[2]&alph.read()[0])^(d.read()[1]&alph.read()[1])^(aA&alph.read()[2])^(aB&alph.read()[3]);
	alp_t[3]=(d.read()[3]&alph.read()[0])^(d.read()[2]&alph.read()[1])^(d.read()[1]&alph.read()[2])^(aA&alph.read()[3]);
	
	alp.write(alp_t);
}

//Convert again to GF(2^8);
void sbox::inversemap(){
    sc_uint<4> aA,aB;
	sc_uint<4> alp_t,ahp_t;
	sc_uint<8> inva_t;
	
	alp_t=alp.read();
	ahp_t=ahp.read();
	
	aA=alp_t[1]^ahp_t[3];
	aB=ahp_t[0]^ahp_t[1];
	
	inva_t[0]=alp_t[0]^ahp_t[0];
	inva_t[1]=aB^ahp_t[3];
	inva_t[2]=aA^aB;
	inva_t[3]=aB^alp_t[1]^ahp_t[2];
	inva_t[4]=aA^aB^alp_t[3];
	inva_t[5]=aB^alp_t[2];
	inva_t[6]=aA^alp_t[2]^alp_t[3]^ahp_t[0];
	inva_t[7]=aB^alp_t[2]^ahp_t[3];
	
	inva.write(inva_t);
}
