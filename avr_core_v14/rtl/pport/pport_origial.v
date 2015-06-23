`timescale 1 ns / 1 ns

//**********************************************************************************************
//  Parallel Port Peripheral for the AVR Core
//  Version 1.3
//  Modified 19.01.2007
//  Designed by Ruslan Lepetenok.
//**********************************************************************************************

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
   parameter                 portx_adr = PORTA_address;
   parameter                 ddrx_adr = DDRA_address;
   parameter                 pinx_adr = PINA_address;
   parameter                 portx_dm_loc = 0;
   parameter                 ddrx_dm_loc = 0;
   parameter                 pinx_dm_loc = 0;
   parameter                 port_width = 8;
   parameter                 port_rs_type = c_pport_rs_md_fre;
   parameter                 port_mode = c_pport_mode_bidir;
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
   
   wire [port_width-1:0]     portx_current;
   wire [port_width-1:0]     portx_next;
   
   wire [port_width-1:0]     ddrx_current;
   wire [port_width-1:0]     ddrx_next;
   
   wire [port_width-1:0]     pinx_resync;
   
   parameter                 c_tot_port_num = 3;		// PORTx/DDRx/PINx
   wire [c_tot_port_num-1:0] port_rd;
   
   // PPort Mode | Implemented registers
   //------------+-----------------------
   //  Bidir	 |  portx/ddrx/pinx
   //  In        |  pinx
   //  Out       |  portx
   
   parameter c_impl_portx = (port_mode == c_pport_mode_bidir) | (port_mode == c_pport_mode_out);
   parameter c_impl_pinx = (port_mode == c_pport_mode_bidir) | (port_mode == c_pport_mode_in);
   parameter c_impl_ddrx = (port_mode == c_pport_mode_bidir);
   
   generate
      if (c_impl_pinx)
      begin : pinx_is_impl
         if (port_rs_type == c_pport_rs_md_rre)
         begin : standard_resync_used
            
            rsnc_vect #(.width(port_width), .add_stgs_num(0), .inv_f_stgs(0)) pinx_resync_inst(
               .clk(cp2),
               .di(pinx),
               .do(pinx_resync)
            );
         end
      
      if (port_rs_type == c_pport_rs_md_fre)
      begin : no_latch_resync_used
         
         rsnc_vect #(.width(port_width), .add_stgs_num(0), .inv_f_stgs(1)) pinx_resync_inst(
            .clk(cp2),
            .di(pinx),
            .do(pinx_resync)
         );
      end
   
   if (port_rs_type == c_pport_rs_md_latch)
   begin : latch_resync_used
      
      rsnc_l_vect #(.tech(0), .width(port_width), .add_stgs_num(0)) pinx_resync_inst(		// TBD
         .clk(cp2),
         .di(pinx),
         .do(pinx_resync)
      );
   end
end
endgenerate
// pinx_is_impl

generate
if (!c_impl_pinx)
begin : pinx_not_impl
 assign pinx_resync = {port_width{1'b0}};
end
endgenerate
// pinx_not_impl	

assign portx_next = fn_wr_port(portx_current, portx_adr, portx_dm_loc, adr, iowe, dbus_in, ramadr, dm_sel, ramwe, dm_dbus_in);

assign ddrx_next = fn_wr_port(ddrx_current, ddrx_adr, ddrx_dm_loc, adr, iowe, dbus_in, ramadr, dm_sel, ramwe, dm_dbus_in);

assign port_rd = {{fn_exp_to_byte(portx_current), portx_adr, portx_dm_loc, c_impl_portx}, {fn_exp_to_byte(ddrx_current), ddrx_adr, ddrx_dm_loc, c_impl_ddrx}, {fn_exp_to_byte(pinx_resync), pinx_adr, pinx_dm_loc, c_impl_pinx}};

generate
if (!c_impl_portx)
begin : portx_is_impl

always @(posedge cp2 or negedge ireset)
begin: seq_prc_portx
   if (!ireset)		// Reset
      portx_current <= {port_width{1'b0}};
   else 		// Clock
      portx_current <= portx_next;
end
end
endgenerate
// portx_is_impl

generate
if (!c_impl_portx)
begin : portx_not_impl
assign portx_current = {port_width{1'b0}};
end
endgenerate
// portx_not_impl

generate
if (c_impl_ddrx)
begin : ddrx_is_impl

always @(posedge cp2 or negedge ireset)
begin: seq_prc_ddrx
   if (!ireset)		// Reset
      ddrx_current <= {port_width{1'b0}};
   else 		// Clock
      ddrx_current <= ddrx_next;
end
end // ddrx_is_impl
endgenerate


generate
if (!c_impl_ddrx)
begin : ddrx_not_impl
 assign ddrx_current = {port_width{1'b0}}; // reg/wire mismatch
end // ddrx_not_impl
endgenerate
	

assign dbus_out    = fn_rd_io_port(port_rd, adr);
assign dm_dbus_out = fn_rd_dm_port(port_rd, ramadr);
assign io_out_en   = fn_gen_io_out_en(port_rd, adr, iore);
assign dm_out_en   = fn_gen_dm_out_en(port_rd, ramadr, ramre, dm_sel);

// Outputs
assign portx = portx_current;
assign ddrx = ddrx_current;
assign resync_out = pinx_resync;
assign cpuwait = 1'b0;

endmodule
