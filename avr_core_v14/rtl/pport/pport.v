//**********************************************************************************************
//  Parallel Port Peripheral for the AVR Core
//  Version 1.5
//  Modified 05.02.2012
//  Designed by Ruslan Lepetenok.
//  Verilog version
// io_out_en/dm_out_en generation bug was fixed (07.06.12)
//**********************************************************************************************

`timescale 1 ns / 1 ns

module pport(
   ireset,
   cp2,
   adr,
   dbus_in,
   dbus_out,
   iore,
   iowe,
   io_out_en,
   ramadr,
   dm_dbus_in,
   dm_dbus_out,
   ramre,
   ramwe,
   dm_sel,
   cpuwait,
   dm_out_en,
   portx,
   ddrx,
   pinx,
   resync_out
);
   parameter                 portx_adr    = 0;
   parameter                 ddrx_adr     = 0;
   parameter                 pinx_adr     = 0;
   parameter                 portx_dm_loc = 0; // Must be 0 or 1 only
   parameter                 ddrx_dm_loc  = 0; // Must be 0 or 1 only
   parameter                 pinx_dm_loc  = 0; // Must be 0 or 1 only
   parameter                 port_width   = 8;
   parameter                 port_rs_type = 0;
   parameter                 port_mode    = 0; // 0 -> c_pport_mode_bidir;  1 -> c_pport_mode_out 2 -> c_pport_mode_in
   
   // Clock and Reset
   input                     ireset;
   input                     cp2;
   // I/O 
   input [5:0]               adr;
   input [7:0]               dbus_in;
   output [7:0]              dbus_out;
   input                     iore;
   input                     iowe;
   output                    io_out_en;
   // DM
   input [7:0]               ramadr;
   input [7:0]               dm_dbus_in;
   output [7:0]              dm_dbus_out;
   input                     ramre;
   input                     ramwe;
   input                     dm_sel;
   output                    cpuwait;
   output                    dm_out_en;
   // External connection
   output [port_width-1:0]   portx;
   output [port_width-1:0]   ddrx;
   input [port_width-1:0]    pinx;
   //
   output [port_width-1:0]   resync_out;
   
  
  wire[7:0] portx_dout;
  wire[7:0] ddrx_dout; 
  
  // Individual select signals
  wire sel_portx;
  wire sel_pinx;
  wire sel_ddrx;

  // Individual write enable signals
  wire we_portx;
  wire we_ddrx;

   // PPort Mode | Implemented registers
   //------------+-----------------------
   //  Bidir	 |  portx/ddrx/pinx
   //  In        |  pinx
   //  Out       |  portx
   
   
   // Constant replacent
   localparam c_pport_mode_bidir = 0, 
              c_pport_mode_out   = 1, 
	      c_pport_mode_in    = 2;
   
   localparam c_impl_portx = (port_mode == c_pport_mode_bidir) | (port_mode == c_pport_mode_out);
   localparam c_impl_pinx = (port_mode == c_pport_mode_bidir) | (port_mode == c_pport_mode_in);
   localparam c_impl_ddrx = (port_mode == c_pport_mode_bidir);
   
 

//localparam LP_PORT_IMPL_MASK = (port_width == 8) ? {8{1'b1}} : {{(8-port_width){1'b0}},{port_width{1'b1}}};
localparam LP_PORT_IMPL_MASK = (port_width == 1) ? 8'b00000001 : 
                               (port_width == 2) ? 8'b00000011 :
                               (port_width == 3) ? 8'b00000111 :
                               (port_width == 4) ? 8'b00001111 :
                               (port_width == 5) ? 8'b00011111 :
                               (port_width == 6) ? 8'b00111111 :
                               (port_width == 7) ? 8'b01111111 :
                               (port_width == 8) ? 8'b11111111 : 8'b0;			       			       			       			       			       


localparam LP_WBE_WIDTH      = (port_width%8) ? (port_width/8+1) : (port_width/8);

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// For the sake of the example only
// wire re_portx;
// wire re_ddrx;
// assign re_portx = (portx_dm_loc) ?  (dm_sel & ramre) : iore;
// assign re_ddrx  = (ddrx_dm_loc) ?   (dm_sel & ramre) : iore; 


assign dbus_out    =  (portx_dout &  {8{sel_portx}} & {8{!portx_dm_loc[0]}}) |
                      (ddrx_dout  &   {8{sel_pinx}} & {8{!ddrx_dm_loc[0]}}) |
                      (resync_out &   {8{sel_ddrx}} & {8{!pinx_dm_loc[0]}}); 

assign dm_dbus_out =  (portx_dout &  {8{sel_portx}} & {8{portx_dm_loc[0]}}) |
		      (ddrx_dout  &   {8{sel_pinx}} & {8{ddrx_dm_loc[0]}}) |
		      (resync_out &   {8{sel_ddrx}} & {8{pinx_dm_loc[0]}}); 

assign io_out_en   = iore & ((sel_portx & !portx_dm_loc[0]) |
		             (sel_pinx  & !ddrx_dm_loc[0]) |
		             (sel_ddrx  & !pinx_dm_loc[0])); 

assign dm_out_en   = (dm_sel & ramre) & ((sel_portx & portx_dm_loc[0]) |
		                         (sel_pinx  & ddrx_dm_loc[0]) |
		                         (sel_ddrx  & pinx_dm_loc[0])); 


assign sel_portx = (portx_dm_loc) ?  (ramadr[7:0] == portx_adr/*[7:0]*/) : (adr[5:0] == portx_adr[5:0]);
assign sel_pinx  = (ddrx_dm_loc) ?   (ramadr[7:0] == ddrx_adr/*[7:0]*/)  : (adr[5:0] == ddrx_adr[5:0]); 
assign sel_ddrx  = (pinx_dm_loc) ?   (ramadr[7:0] == pinx_adr/*[7:0]*/)  : (adr[5:0] == pinx_adr[5:0]); 

assign we_portx = (portx_dm_loc) ?  (dm_sel & ramwe) : iowe;
assign we_ddrx  = (ddrx_dm_loc) ?   (dm_sel & ramwe) : iowe; 


generate
if (c_impl_portx) begin : portx_is_implemented
       rg_md #(
	       .p_width     (8),   
               .p_init_val  ({port_width{1'b0}}),
	       .p_impl_mask (LP_PORT_IMPL_MASK),
	       .p_sync_rst  (0)   
	       )
   rg_md_portx_ist(
               .clk   (cp2),
               .nrst  (ireset),
               .wdata ((portx_dm_loc) ? dm_dbus_in : dbus_in),  				     
               .wbe   ({LP_WBE_WIDTH{(sel_portx & we_portx)}}),
               .rdata (portx_dout)										     
	       );
end // portx_is_implemented
else begin : portx_is_not_implemented
 assign portx_dout = {8{1'b0}};
end // portx_is_not_implemented


if (c_impl_ddrx) begin : ddrx_is_implemented
       rg_md #(
	       .p_width     (8),   
               .p_init_val  ({port_width{1'b0}}),
	       .p_impl_mask (LP_PORT_IMPL_MASK),
	       .p_sync_rst  (0)   
	       )
   rg_md_ddrx_inst(
               .clk   (cp2),
               .nrst  (ireset),
               .wdata ((ddrx_dm_loc) ? dm_dbus_in : dbus_in),  				     
               .wbe   ({LP_WBE_WIDTH{(sel_ddrx & we_ddrx)}}),
               .rdata (ddrx_dout)										     
	       );
end // ddrx_is_implemented
else begin : ddrx_is_not_implemented
 assign ddrx_dout = {8{1'b0}}; 
end // ddrx_is_not_implemented


if (!c_impl_pinx) begin : pinx_is_implemented
      rsnc_bit_vlog #(
	          .add_stgs_num (0),
                  .inv_f_stgs   (1)
		     )
   rsnc_bit_vlog_pinx_inst[port_width-1:0](	                   
                  .clk  (cp2),
                  .din  (pinx[port_width-1:0]),
                  .dout (resync_out[port_width-1:0])
                  );
end // pinx_is_implemented
else begin : pinx_is_not_implemented
  assign resync_out[port_width-1:0] = pinx[port_width-1:0]; 
end // pinx_is_not_implemented

endgenerate

assign cpuwait = 1'b0;

assign ddrx[port_width-1:0]  =  ddrx_dout[port_width-1:0];
assign portx[port_width-1:0] =  portx_dout[port_width-1:0];

endmodule // pport
