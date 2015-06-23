// *****************************************************************************************
// External interrupts controller
// Version 0.14
// Modified 29.03.2007
// Designed by Ruslan Lepetenok(lepetenokr@yahoo.com)
// Modified 08.06.12(Verilog version)
// *****************************************************************************************

`timescale 1 ns / 1 ns


module ext_int_mod(
                   ireset, 
		   cp2, 
		   adr, 
		   iowe, 
		   iore, 
		   dbus_in, 
		   dbus_out, 
		   io_out_en, 
		   ramadr, 
		   ramre, 
		   ramwe, 
		   dm_sel, 
		   dm_dbus_in, 
		   dm_dbus_out, 
		   dm_out_en, 
		   e_int_in, 
		   irq, 
		   irq_ack
		   );
	
   `include "avr_adr_pack.vh"		   
		   
   parameter                 eimsk_adr     = EIMSK_Address;
   parameter                 eifr_adr      = EIFR_Address;
   parameter                 eicra_adr     = EICRA_Address;
   parameter                 eicrb_adr     = EICRB_Address;
   
   parameter                 eimsk_dm_loc  = 0;
   parameter                 eifr_dm_loc   = 0;
   parameter                 eicra_dm_loc  = 1;
   parameter                 eicrb_dm_loc  = 0;
   
   parameter                 rsnc_type     = 0 /*c_pport_rs_md_fre*/;
   parameter                 dis_rsnc      = 0;
   
   
   input                     ireset;
   input                     cp2;
   // I/O i/f
   input [5:0]               adr;
   input                     iowe;
   input                     iore;
   input [7:0]               dbus_in;
   output [7:0]              dbus_out;
   output                    io_out_en;
   // DM i/f
   input [7:0]               ramadr;
   input                     ramre;
   input                     ramwe;
   input                     dm_sel;
   input [7:0]               dm_dbus_in;
   output [7:0]              dm_dbus_out;
   output                    dm_out_en;
   // External interrupts
   input [7:0]               e_int_in;
   // Interrupt (CPU i/f)
   output [7:0]              irq;
   input [7:0]               irq_ack;
 
   wire[7:0] eicra_current;
   wire[7:0] eicrb_current;
   wire[7:0] eimsk_current;
   wire[7:0] eifr_current;

   wire sel_eicra;
   wire sel_eicrb;
   wire sel_eimsk;
   wire sel_eifr;

   wire we_eicra;
   wire we_eicrb;
   wire we_eimsk;
   wire we_eifr;
 
   
   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   
   wire [7:0]                eint_resync;
   wire [7:0]                 eint_del_rg;
   reg [7:0]                 int_fl_set;
   
   wire [7:0]                flr_din;
   wire                      flr_wr_en;
   
   reg [7:0]                 eifr_next;
   
   // ********************************************************************************		
   
generate
 if (dis_rsnc != 0)
  begin : rsnc_is_impl
   if (rsnc_type == 0 /*c_pport_rs_md_rre*/ )
    begin : standard_resync_used
     rsnc_vect #(.width(8), .add_stgs_num(0), .inv_f_stgs(0)) eint_resync_inst(.clk(cp2), .di(e_int_in), .do(eint_resync));
    end
   else if (rsnc_type == 1/*c_pport_rs_md_fre*/ )
    begin : no_latch_resync_used
      rsnc_vect #(.width(8), .add_stgs_num(0), .inv_f_stgs(1)) eint_resync_inst(.clk(cp2), .di(e_int_in), .do(eint_resync));
    end
   else if (rsnc_type == 2 /*c_pport_rs_md_latch*/ )
    begin : latch_resync_used
      rsnc_l_vect #(.tech(0), .width(8), .add_stgs_num(0)) eint_resync_inst(.clk(cp2), .di(e_int_in), .do(eint_resync));		// TBD
    end
   end // rsnc_is_impl
  else
   begin : rsnc_not_impl
    assign eint_resync = e_int_in;
   end // rsnc_not_impl
endgenerate
	

// ********************************************************************************	


       rg_md #(
	       .p_width     (8),   
               .p_init_val  ({8{1'b0}}),
	       .p_impl_mask ({8{1'b1}}),
	       .p_sync_rst  (0)   
	       )
  rg_md_eint_del_rg_inst(
               .clk   (cp2),
               .nrst  (ireset),
               .wdata (eint_resync),  				     
               .wbe   (1'b1),
               .rdata (eint_del_rg)										     
	       );



assign sel_eicra = (eicra_dm_loc) ?  (ramadr[7:0] == eicra_adr) : (adr[5:0] == eicra_adr[5:0]);
assign sel_eicrb = (eicrb_dm_loc) ?  (ramadr[7:0] == eicrb_adr) : (adr[5:0] == eicrb_adr[5:0]);
assign sel_eimsk = (eimsk_dm_loc) ?  (ramadr[7:0] == eimsk_adr) : (adr[5:0] == eimsk_adr[5:0]);
assign sel_eifr  = (eifr_dm_loc ) ?  (ramadr[7:0] == eifr_adr ) : (adr[5:0] == eifr_adr[5:0] );

assign we_eicra = (eicra_dm_loc) ?  (dm_sel & ramwe) : iowe;
assign we_eicrb = (eicrb_dm_loc) ?  (dm_sel & ramwe) : iowe;
assign we_eimsk = (eimsk_dm_loc) ?  (dm_sel & ramwe) : iowe;
assign we_eifr  = (eifr_dm_loc ) ?  (dm_sel & ramwe) : iowe;


       rg_md #(
	       .p_width     (8),   
               .p_init_val  ({8{1'b0}}),
	       .p_impl_mask ({8{1'b1}}),
	       .p_sync_rst  (0)   
	       )
  rg_md_eicra_inst(
               .clk   (cp2),
               .nrst  (ireset),
               .wdata ((eicra_dm_loc) ? dm_dbus_in : dbus_in),  				     
               .wbe   ((sel_eicra & we_eicra)),
               .rdata (eicra_current)										     
	       );

       rg_md #(
	       .p_width     (8),   
               .p_init_val  ({8{1'b0}}),
	       .p_impl_mask ({8{1'b1}}),
	       .p_sync_rst  (0)   
	       )
  rg_md_eicrb_inst(
               .clk   (cp2),
               .nrst  (ireset),
               .wdata ((eicrb_dm_loc) ? dm_dbus_in : dbus_in),  				     
               .wbe   ((sel_eicrb & we_eicrb)),
               .rdata (eicrb_current)										     
	       );

       rg_md #(
	       .p_width     (8),   
               .p_init_val  ({8{1'b0}}),
	       .p_impl_mask ({8{1'b1}}),
	       .p_sync_rst  (0)   
	       )
  rg_md_eimsk_inst(
               .clk   (cp2),
               .nrst  (ireset),
               .wdata ((eimsk_dm_loc) ? dm_dbus_in : dbus_in),  				     
               .wbe   ((sel_eimsk & we_eimsk)),
               .rdata (eimsk_current)										     
	       );

       rg_md #(
	       .p_width     (8),   
               .p_init_val  ({8{1'b0}}),
	       .p_impl_mask ({8{1'b1}}),
	       .p_sync_rst  (0)   
	       )
  rg_md_eifr_inst(
               .clk   (cp2),
               .nrst  (ireset),
               .wdata (eifr_next),  				     
               .wbe   (1'b1),
               .rdata (eifr_current)										     
	       );


always @(eint_del_rg or eint_resync or eicra_current or eicrb_current)
begin: int_fl_set_gen_comb
integer                   i;
int_fl_set = {8{1'b0}};

for (i = 0; i < 4; i = i + 1)
begin
  
   if ((eint_resync[i] == 1'b0 && eint_del_rg[i] == 1'b0 && eicra_current[i * 2 + 1] == 1'b0 && eicra_current[i * 2] == 1'b0) | // Low level
       (eint_resync[i] != eint_del_rg[i] && eicra_current[i * 2 + 1] == 1'b0 && eicra_current[i * 2] == 1'b1) |                 // Any change
       (eint_resync[i] == 1'b0 && eint_del_rg[i] == 1'b1 && eicra_current[i * 2 + 1] == 1'b1 && eicra_current[i * 2] == 1'b0) | // Falling
       (eint_resync[i] == 1'b1 && eint_del_rg[i] == 1'b0 && eicra_current[i * 2 + 1] == 1'b1 && eicra_current[i * 2] == 1'b1))  // Rising
   int_fl_set[i] = 1'b1;
   
   
   if ((eint_resync[i + 4] == 1'b0 && eint_del_rg[i + 4] == 1'b0 && eicrb_current[i * 2 + 1] == 1'b0 && eicrb_current[i * 2] == 1'b0) | // Low level
       (eint_resync[i + 4] != eint_del_rg[i + 4] && eicrb_current[i * 2 + 1] == 1'b0 && eicrb_current[i * 2] == 1'b1) |                 // Any change
       (eint_resync[i + 4] == 1'b0 && eint_del_rg[i + 4] == 1'b1 && eicrb_current[i * 2 + 1] == 1'b1 && eicrb_current[i * 2] == 1'b0) | // Falling
       (eint_resync[i + 4] == 1'b1 && eint_del_rg[i + 4] == 1'b0 && eicrb_current[i * 2 + 1] == 1'b1 && eicrb_current[i * 2] == 1'b1))  // Rising
   int_fl_set[i + 4] = 1'b1;

end
end // int_fl_set_gen_comb

// Write to Flag Register
assign flr_din   = (eifr_dm_loc) ? dm_dbus_in : dbus_in;
assign flr_wr_en = sel_eifr & we_eifr;


always @(flr_din or flr_wr_en or irq_ack or eifr_current or int_fl_set)
begin: fr_wr_comb
   integer                   i;
   eifr_next = eifr_current;
   for (i = 0; i < 8; i = i + 1)
      if (eifr_current[i])		// Clear
      begin
       if ((flr_din[i] && flr_wr_en) | irq_ack[i]) eifr_next[i] = 1'b0;
      end
      else// Set  
       eifr_next[i] = int_fl_set[i];
end // fr_wr_comb

 // Outputs
assign dbus_out    =  (eicra_current &   {8{sel_eicra}} & {8{!eicra_dm_loc[0]}}) |
                      (eicrb_current &   {8{sel_eicrb}} & {8{!eicrb_dm_loc[0]}}) |
                      (eimsk_current &   {8{sel_eimsk}} & {8{!eimsk_dm_loc[0]}}) | 	       
                      (eifr_current  &   {8{sel_eifr }} & {8{!eifr_dm_loc[0]}}); 

assign dm_dbus_out =  (eicra_current &   {8{sel_eicra}} & {8{eicra_dm_loc[0]}}) |
		      (eicrb_current &   {8{sel_eicrb}} & {8{eicrb_dm_loc[0]}}) |
		      (eimsk_current &   {8{sel_eimsk}} & {8{eimsk_dm_loc[0]}}) |  	       
		      (eifr_current  &   {8{sel_eifr }} & {8{eifr_dm_loc[0]}}); 

assign io_out_en   = iore & ((sel_eicra & !eicra_dm_loc[0]) |
		             (sel_eicrb & !eicrb_dm_loc[0]) |
		             (sel_eimsk & !eimsk_dm_loc[0]) |		     
		             (sel_eifr  & !eifr_dm_loc[0])); 

assign dm_out_en   = (dm_sel & ramre) & ((sel_eicra & eicra_dm_loc[0]) |
		                         (sel_eicrb & eicrb_dm_loc[0]) |
                                         (sel_eimsk & eimsk_dm_loc[0]) | 	     
                                         (sel_eifr  & eifr_dm_loc[0])); 
   

assign irq = eifr_current & eimsk_current;
  
   
endmodule // ext_int_mod
