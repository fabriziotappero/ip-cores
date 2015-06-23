//******************************************************************************************
// 
//
// 
// Written by Ruslan Lepetenok (lepetenokr@yahoo.com)
//******************************************************************************************

module tri_buf_vect(
	       out,
	       in,
	       en
	       );

parameter tech       = 1;
parameter width      = 1;
parameter en_inv_pol = 0;

output[width-1:0] 	out;  
input[width-1:0]	in;
input[width-1:0]	en;

wire[width-1:0]	       en_int;


assign en_int = (en_inv_pol) ? ~en : en;

tri_buf #(.tech(tech)) tri_buf_inst[width-1:0](
	       .out (out),
	       .in  (in),
	       .en  (en)
	       );	


		
endmodule // tri_buf_vect			
