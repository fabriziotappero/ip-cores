//**********************************************************************************************
// Verilog wrapper for Altera lpm_ff primitive (required by Quartus) 
// Version 0.1
// Modified  21.10.12
// Designed by Ruslan Lepetenok (lepetenokr@yahoo.com)
//**********************************************************************************************

`timescale 1 ns / 1 ns

module altera_lpm_ff_wrp(
                         q,     
                         data,  
                         clock, 
                         enable,
                         aclr,  
                         aset,  
                         sclr,  
                         sset,  
                         aload, 
                         sload, 
                         );

output  q;     
input   data;  
input   clock; 
input   enable;
input   aclr;  
input   aset;  
input   sclr;  
input   sset;  
input   aload; 
input   sload; 

`ifdef C_FOR_QUARTUS

lpm_ff lpm_ff_inst( 
                   .q	   (q	   ), 
                   .data   (data   ), 
		   .clock  (clock  ), 
		   .enable (enable ), 
		   .aclr   (aclr   ), 
                   .aset   (aset   ),
		   .sclr   (sclr   ), 
		   .sset   (sset   ), 
		   .aload  (aload  ), 
		   .sload  (sload  ) 
		   ); 

`endif

endmodule // altera_lpm_ff_wrp