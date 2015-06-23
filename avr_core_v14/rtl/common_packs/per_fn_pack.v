// *****************************************************************************************
// Peripheral functions
// Version 0.1
// Modified 04.12.2006
// Designed by Ruslan Lepetenok
// *****************************************************************************************


// type port_rd_single_type is record	
//  port_current : std_logic_vector(7 downto 0);
//  port_adr     : integer;
//  use_dm       : integer;
//  impl_port    : integer;
// end record;	

// Record emulation for Verilog

// port_current : std_logic_vector(7 downto 0);  -> [7:0] ???
// port_adr     : integer;                       -> [7:0] ???  
// use_dm       : integer;
// impl_port    : integer;




function [7:0] fn_wr_port;
   input [7:0]            port_current;
   input [6:0]            port_adr;
   input integer          use_dm;
   input [6:0]            adr;
   input                   iowe;
   input [7:0]            dbus_in;
   input [7:0] /* ??? */            ramadr;
   input                   dm_sel;
   input                   ramwe;
   input [7:0]            dm_dbus_in;
   
   reg[7:0]               port_next;
begin
   port_next = port_current;
   
   case (use_dm)
       0 :		// I/O
         if (adr == port_adr && iowe)
            port_next = dbus_in[7:0];
      default :		// DM
         if (ramadr == port_adr && dm_sel && ramwe)
            port_next = dm_dbus_in[7:0];
   endcase
   fn_wr_port = port_next;
end
endfunction

function [7:0] fn_wr_port_mux;
   input integer          use_dm;
   input [7:0]            dbus_in;
   input [7:0]            dm_dbus_in;
   
   reg [7:0]               port_next;
begin
   port_next = {8{1'b0}};
   case (use_dm)
      0 :		// I/O
         port_next = dbus_in[7:0];
      default :		// DM
         port_next = dm_dbus_in[7:0];
   endcase
   fn_wr_port_mux = port_next;
end
endfunction

function  fn_wr_port_en;
   input integer           port_adr;
   input integer           use_dm;
   input [5:0]            adr;
   input                   iowe;
   input [7:0]            ramadr;
   input                   dm_sel;
   input                   ramwe;
   
   reg                     tmp;
begin
   tmp = 1'b0;
   
   case (use_dm)
      0 :		// I/O
         if (adr == port_adr && iowe)
            tmp = 1'b1;
      default :		// DM
         if (ramadr == port_adr && dm_sel && ramwe)
            tmp = 1'b1;
   endcase
   fn_wr_port_en = tmp;
end
endfunction

function [31:0] fn_rd_io_port;
   input [7:0]             portsport_currentport_adruse_dmimpl_port[];
   input [31:0]            adr;
   input                   _adr;
   
   reg [7:0]               result;
   integer                 _adr;
begin
   result = {8{1'b0}};
   for (i = ; i <= ; i = i + 1)
      if (ports.use_dm == 0 & adr == ports.port_adr)
      begin
         result = ports.port_current;
      end
   fn_rd_io_port = result;
end
endfunction

function [7:0] fn_rd_dm_port;
   input [7:0]             portsport_currentport_adruse_dmimpl_port[];
   input [31:0]            ramadr;
   
   reg [7:0]               result;
begin
   result = {8{1'b0}};
   for (i = ; i <= ; i = i + 1)
      if (ports.use_dm != 0 & ramadr == ports.port_adr)
      begin
         result = ports.port_current;
      end
   fn_rd_dm_port = result;
end
endfunction

function  fn_gen_io_out_en;
   input [7:0]             portsport_currentport_adruse_dmimpl_port[];
   input [31:0]            adr;
   input                   _adr;
   input                   iore;
   reg                     result;
   integer                 _adr;
begin
   result = 1'b0;
   for (i = ; i <= ; i = i + 1)
      if (ports.use_dm == 0 & ports.impl_port != 0 & adr == ports.port_adr)
      begin
         result = iore;
      end
   fn_gen_io_out_en = result;
end
endfunction

function  fn_gen_dm_out_en;
   input [7:0]             portsport_currentport_adruse_dmimpl_port[];
   input [31:0]            ramadr;
   input                   _ramadr;
   input                   ramre;
   input                   dm_sel;
   reg                     result;
   integer                 _ramadr;
begin
   result = 1'b0;
   for (i = ; i <= ; i = i + 1)
      if (ports.use_dm != 0 & ports.impl_port != 0 & ramadr == ports.port_adr)
      begin
         result = ramre & dm_sel;
      end
   fn_gen_dm_out_en = result;
end
endfunction

function [31:0] fn_exp_to_byte;
   input [31:0]            in_vect;
   input                   _in_vect;
   reg [7:0]               result;
   integer                 _in_vect;
begin
   result = {8{1'b0}};
   result[_in_vect-1:0] = in_vect;
   fn_exp_to_byte = result;
end
endfunction

function [31:0] _fn_wr_port_1;
   input [31:0]            port_current;
   input                   _port_current;
   input integer           port_adr;
   input integer           use_dm;
   input [31:0]            adr;
   input                   _adr;
   input                   iowe;
   input [31:0]            dbus_in;
   input                   _dbus_in;
   input [31:0]            ramadr;
   input                   _ramadr;
   input                   dm_sel;
   input                   ramwe;
   input [31:0]            dm_dbus_in;
   input                   _dm_dbus_in;
   input [7:0]             mask;
   input [7:0]             init_val;
   
   reg [_port_current-1:0] port_next;
   integer                 _port_current;
   integer                 _adr;
   integer                 _dbus_in;
   integer                 _ramadr;
   integer                 _dm_dbus_in;
begin
   port_next = port_current;
   
   case (use_dm)
      0 :		// I/O
         if (adr == port_adr && iowe)
            port_next = (dbus_in[_port_current-1:0] & mask[_port_current-1:0]) | (init_val[_port_current-1:0] & (~mask[_port_current-1:0]));
      default :		// DM
         if (ramadr == port_adr && dm_sel && ramwe)
            port_next = (dm_dbus_in[_port_current-1:0] & mask[_port_current-1:0]) | (init_val[_port_current-1:0] & (~mask[_port_current-1:0]));
   endcase
   _fn_wr_port_1 = port_next;
end
endfunction


