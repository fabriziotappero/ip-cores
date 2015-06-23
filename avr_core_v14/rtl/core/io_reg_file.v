//************************************************************************************************
// Internal I/O registers (implemented inside the core) decoder/multiplexer 
// for AVR core
// Version 2.1 (Special version for the JTAG OCD)
// Designed by Ruslan Lepetenok
// Modified 08.01.2007
// EIND register is added 
// std_library was added
// Converted to verilog
// Modified 03.07.12
// Modifies 18.08.12 Verilog Lint
//************************************************************************************************

`timescale 1 ns / 1 ns

module io_reg_file(
                   cp2, 
		   cp2en, 
		   ireset, 
		   adr, 
		   iowe, 
		   dbusout, 
		   sreg_fl_in, 
		   sreg_out, 
		   sreg_fl_wr_en, 
		   spl_out, 
		   sph_out, 
		   sp_ndown_up, 
		   sp_en, 
		   rampz_out, 
		   eind_out
		   );

   parameter             pc22b = 0;
   parameter             eind_width = 1;
   parameter             rampz_width = 1;

   //Clock and reset
   input                 cp2;
   input                 cp2en;
   input                 ireset;
   // I/O i/f
   input [5:0]           adr;
   input                 iowe;
   input [7:0]           dbusout;
   // SREG related signals
   input [7:0]           sreg_fl_in;
   output [7:0]          sreg_out;
   input [7:0]           sreg_fl_wr_en;		//FLAGS WRITE ENABLE SIGNALS       
   // SPL/SPH related signals
   output [7:0]          spl_out;
   output [7:0]          sph_out;
   input                 sp_ndown_up;		// DIRECTION OF CHANGING OF STACK POINTER SPH:SPL 0->UP(+) 1->DOWN(-)
   input                 sp_en;		// WRITE ENABLE(COUNT ENABLE) FOR SPH AND SPL REGISTERS
   // RAMPZ related signals
   output reg [7:0]      rampz_out;
   // EIND related signals
   output [7:0]          eind_out;
   reg    [7:0]          eind_out; // !!!
   
   reg [7:0]             spl_current;
   reg [7:0]             spl_next;
   
   reg [7:0]             sph_current;
   reg [7:0]             sph_next;
   
   reg [7:0]             sreg_current;
   reg [7:0]             sreg_next;
   
   reg [rampz_width-1:0] rampz_current;
   reg [rampz_width-1:0] rampz_next;
   
   reg [eind_width-1:0]  eind_current;
   reg [eind_width-1:0]  eind_next;
   
   // SP calculation
   wire [15:0]           sp_res;
   
// Register addresses  
parameter P_SPL_Address   = 6'h3D; // Stack Pointer(Low)
parameter P_SPH_Address   = 6'h3E; // Stack Pointer(High)
parameter P_SREG_Address  = 6'h3F; // Status Register
parameter P_RAMPZ_Address = 6'h3B; // RAM Page Z Select Register
parameter P_EIND_Address  = 6'h3C; // !!!TBD!!! Occupated by XDIV in Mega128
   
//#################################################################################################################################
   
   // SP incrementer/decrementer
   assign sp_res = (!sp_ndown_up) ? (({sph_current, spl_current}) - 16'd1) :   // Decrement SP
                                    (({sph_current, spl_current}) + 16'd1);    // Increment SP 
   
   
   always @(cp2en or adr or iowe or dbusout or sreg_fl_in or sreg_fl_wr_en or sp_res or sp_en or spl_current or sph_current or 
            sreg_current or rampz_current)
   begin: next_regs_comb
      integer               i;
      spl_next   = spl_current;
      sph_next   = sph_current;
      sreg_next  = sreg_current;
      rampz_next = rampz_current;
      
      if (cp2en)		// Clock enable
      begin
         
         if (iowe)		// Write to I/O
         begin
            if (adr == P_SPL_Address)
               spl_next = dbusout;		// data bus
            if (adr == P_SPH_Address)
               sph_next = dbusout;		// data bus
         end
         else if (sp_en)		// call/rcall/icall/ret/reti/push/pop/IRQ   
         begin
            spl_next = sp_res[7:0];
            sph_next = sp_res[15:8];
         end
         
         if (iowe)		// Write to I/O
         begin
            if (adr == P_SREG_Address)
               sreg_next = dbusout;		// data bus
         end
         else 
	 begin
            // Modify individual SREG flags  
            for (i = 0; i < 8; i = i + 1)
             if (sreg_fl_wr_en[i])
                  sreg_next[i] = sreg_fl_in[i];
         end 
	 
         if (iowe && adr == P_RAMPZ_Address)		// Write to I/O
            rampz_next = dbusout[rampz_width-1:0];
      end
      
      end // next_regs_comb
      
      generate
        if (!pc22b)
         begin : no_eind
	  always @(*) // !!!TBD!!!
           eind_out = {8{1'b0}};
         end

        else  // (pc22b == 1)
        begin : eind_is_impl
            
         always @(cp2en or adr or iowe or dbusout or eind_current)
          begin: next_eind_comb
           eind_next = eind_current;
           if (iowe && adr == P_EIND_Address)		// Write to I/O
            eind_next = dbusout[eind_width-1:0];
           end // next_eind_comb
               
               
          always @(posedge cp2 or negedge ireset)
           begin: eind_seq
            if (!ireset)	   // Reset 
             eind_current <= {eind_width{1'b0}};
            else	   // Clock
             eind_current <= eind_next;
            end // eind_seq
             
           always @(eind_current)
            begin: eind_gen_comb
             integer i;
	     eind_out = {8{1'b0}};
             for (i = 0; i < 8; i = i + 1)
              if (i < eind_width)
               eind_out[i] = eind_current[i];
             end // eind_gen_comb
	   	
           end // eind_is_impl
        endgenerate
               
               
  always @(posedge cp2 or negedge ireset)
  begin: regs_seq
     if (!ireset)	   // Reset 
     begin
	spl_current   <= {8{1'b0}};
	sph_current   <= {8{1'b0}};
	sreg_current  <= {8{1'b0}};
	rampz_current <= {rampz_width{1'b0}};
     end
     else	   // Clock
     begin
	spl_current   <= spl_next;
	sph_current   <= sph_next;
	sreg_current  <= sreg_next;
	rampz_current <= rampz_next;
     end
     end // regs_seq
     
     assign spl_out  = spl_current;
     assign sph_out  = sph_current;
     assign sreg_out = sreg_current;

     always @(rampz_current)
     begin: rampz_gen_comb
      integer i;
      rampz_out = {8{1'b0}};  
      for (i = 0; i < rampz_width; i = i + 1)
       rampz_out[i] = rampz_current[i];
     end // rampz_gen_comb
                     
endmodule // io_reg_file
