//**********************************************************************************************
//  Identifier module for the AVR Core
//  Version 0.4
//  Modified 04.01.2007
//  Designed by Ruslan Lepetenok(lepetenokr@yahoo.com)
//**********************************************************************************************

`timescale 1 ns / 1 ns

module id_mod (
   ireset,
   cp2,
   adr,
   dbus_in,
   dbus_out,
   iore,
   iowe,
   out_en
);
   // AVR Control
   input        ireset;
   input        cp2;
   input [5:0]  adr;
   input [7:0]  dbus_in;
   output [7:0] dbus_out;
   input        iore;
   input        iowe;
   output       out_en;
   
  localparam PINC_address  = 6'h13; // Input Pins           Port C
  parameter P_IO_ADR = PINC_address;  

//  parameter P_ID_STR       = "1234567890";
  parameter P_ID_STR = "AVR core v.12 by Ruslan Lepetenok. I'm searching for a job.lepetenokr@yahoo.com";
  parameter P_ID_STR_LEN   =  79;
   
  localparam LP_CNT_WIDTH  = 7;
   
   reg [LP_CNT_WIDTH-1:0]    ptr_cnt_current;
   reg [LP_CNT_WIDTH-1:0]    ptr_cnt_next;
   
   wire                      adr_cmp_match; 
   
   reg [7:0]                 out_rg_current;
   wire [7:0]                out_rg_next;


//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$  

function[7:0] fn_ident_string;
input[LP_CNT_WIDTH-1:0]  arg; 

reg[7:0] res;
integer    i;
integer  adr_tmp;
begin

adr_tmp = P_ID_STR_LEN - 1 - arg;

if(arg == P_ID_STR_LEN) begin
 res = {8{1'b0}};
end
else begin
 for(i=0;i<8;i=i+1) res[i] = P_ID_STR[8*adr_tmp+i];
end

fn_ident_string = res;

end
endfunction // fn_ident_string
  
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$  


assign adr_cmp_match = (adr == P_IO_ADR) ? 1'b1 : 1'b0;   
   

   always @(negedge ireset or posedge cp2)
   begin: main_seq
      if (!ireset) begin		// Reset
         ptr_cnt_current <= {LP_CNT_WIDTH{1'b0}};
	 out_rg_current  <= {8{1'b0}};
      end 
      else 		// Clock	 
      begin
        ptr_cnt_current <= ptr_cnt_next; 
        out_rg_current  <= out_rg_next;  
      end 
   end // main_seq

 always@*
  begin : main_comb
  
   ptr_cnt_next = ptr_cnt_current;
   
   if(adr_cmp_match) begin
    if(iore) begin
     ptr_cnt_next = ptr_cnt_current + 1; // Increment
    end
    else if(iowe) begin
     ptr_cnt_next = {LP_CNT_WIDTH{1'b0}};           // Clear 
    end
   end
  
  end // main_comb
   
   assign out_rg_next = (adr_cmp_match && iowe) ?  fn_ident_string({LP_CNT_WIDTH{1'b0}}) :
                                                   fn_ident_string(ptr_cnt_current);
   
   assign out_en   = adr_cmp_match & iore;
   assign dbus_out = out_rg_current;
   
endmodule // id_mod
