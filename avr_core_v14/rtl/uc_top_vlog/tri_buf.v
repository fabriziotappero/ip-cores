//******************************************************************************************
// 
//
// 
// Written by Ruslan Lepetenok (lepetenokr@yahoo.com)
//******************************************************************************************

module tri_buf(
	       out,
	       in,
	       en
	       );

parameter tech = 4;

output 	out;  
input	in;
input	en;

assign out = (en) ? in : 1'bz;

		
endmodule // uc_top_vlog			
