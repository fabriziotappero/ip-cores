//////////////////////////////////////////////////////////////////////////////                                                                                          
//                                                                          //
//  Minimalistic 1-wire (onewire) master with Avalon MM bus interface       //
//  testbench                                                               //
//                                                                          //
//  Copyright (C) 2010  Iztok Jeras                                         //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  This RTL is free hardware: you can redistribute it and/or modify        //
//  it under the terms of the GNU Lesser General Public License             //
//  as published by the Free Software Foundation, either                    //
//  version 3 of the License, or (at your option) any later version.        //
//                                                                          //
//  This RTL is distributed in the hope that it will be useful,             //
//  but WITHOUT ANY WARRANTY; without even the implied warranty of          //
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           //
//  GNU General Public License for more details.                            //
//                                                                          //
//  You should have received a copy of the GNU General Public License       //
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module onewire_tb;

localparam DEBUG = 1'b0;

// system clock parameters
localparam real FRQ = 6_000_000;      // frequency 6MHz
localparam real TCP = (10.0**9)/FRQ;  // time clock period in ns

`ifdef CDR_E
localparam CDR_E = 1;
`else
localparam CDR_E = 0;
`endif

`ifdef PRESET_50_10
localparam OVD_E = 1'b1;   // overdrive functionality enable
localparam BTP_N = "5.0";  // normal    mode
localparam BTP_O = "1.0";  // overdrive mode
`elsif PRESET_60_05
localparam OVD_E = 1'b1;   // overdrive functionality enable
localparam BTP_N = "6.0";  // normal    mode
localparam BTP_O = "0.5";  // overdrive mode
`elsif PRESET_75
localparam OVD_E = 1'b0;   // overdrive functionality enable
localparam BTP_N = "7.5";  // normal    mode
localparam BTP_O = "1.0";  // overdrive mode
`else // default
localparam OVD_E = 1'b1;   // overdrive functionality enable
localparam BTP_N = "5.0";  // normal    mode
localparam BTP_O = "1.0";  // overdrive mode
`endif

// port width parameters
`ifdef BDW_32
localparam BDW   = 32;     // 32bit bus data width
`elsif BDW_8
localparam BDW   =  8;     //  8bit bus data width
`else // default
localparam BDW   = 32;     //       bus data width
`endif

// number of wires
`ifdef OWN
localparam OWN   = `OWN;  // number of wires
`else
localparam OWN   =  3;    // slaves with different timing (min, typ, max)
`endif

// computed bus address port width
localparam BAW   = (BDW==32) ? 1 : 2;

// clock dividers for normal and overdrive mode
// NOTE! must be round integer values
`ifdef PRESET_60_05
// there is no way to cast a real value into an integer
localparam integer CDR_N = 45 - 1;
localparam integer CDR_O =  4 - 1;
`else
localparam integer CDR_N = ((BTP_N == "5.0") ?  5.0 : 7.5 ) * FRQ / 1_000_000 - 1;
localparam integer CDR_O = ((BTP_O == "1.0") ?  1.0 : 0.67) * FRQ / 1_000_000 - 1;
`endif

// Avalon MM parameters
localparam AAW = BAW;    // address width
localparam ADW = BDW;    // data width
localparam ABW = ADW/8;  // byte enable width

// system_signals
reg            clk;  // clock
reg            rst;  // reset (asynchronous)
// Avalon MM interface
reg            avalon_read;
reg            avalon_write;
reg  [AAW-1:0] avalon_address;
reg  [ABW-1:0] avalon_byteenable;
reg  [ADW-1:0] avalon_writedata;
wire [ADW-1:0] avalon_readdata;
wire           avalon_waitrequest;
wire           avalon_interrupt;

// Avalon MM local signals
wire           avalon_transfer;
reg  [BDW-1:0] data;

// onewire
wire [OWN-1:0] owr;     // bidirectional
wire [OWN-1:0] owr_p;   // output power enable from master
wire [OWN-1:0] owr_e;   // output pull down enable from master
wire [OWN-1:0] owr_i;   // input into master

// slave conviguration
reg            slave_ena;    // slave enable (connect/disconnect from wire)
reg      [3:0] slave_sel;    // 1-wire slave select
reg            slave_ovd;    // overdrive mode enable
reg            slave_dat_r;  // read  data
wire [OWN-1:0] slave_dat_w;  // write data

// error checking
integer        error;
integer        n;

// overdrive enable loop
integer        i;

//////////////////////////////////////////////////////////////////////////////
// configuration printout and waveforms
//////////////////////////////////////////////////////////////////////////////

// request for a dumpfile
initial begin
  $dumpfile("onewire.vcd");
  $dumpvars(0, onewire_tb);
end

// print configuration
initial begin
  $display ("NOTE: Ports : BDW=%0d, BAW=%0d, OWN=%0d", BDW, BAW, OWN);
  $display ("NOTE: Clock : FRQ=%3.2fMHz, TCP=%3.2fns", FRQ/1_000_000.0, TCP);
  $display ("NOTE: Divide: CDR_E=%0b, CDR_N=%0d, CDR_O=%0d", CDR_E, CDR_N, CDR_O);
  $display ("NOTE: Config: OVD_E=%0b, BTP_N=%1.2fus, BTP_O=%1.2fus",
                           OVD_E, (CDR_N+1)*1_000_000/FRQ, (CDR_O+1)*1_000_000/FRQ);
end

//////////////////////////////////////////////////////////////////////////////
// clock and reset
//////////////////////////////////////////////////////////////////////////////

// clock generation
initial         clk = 1'b1;
always #(TCP/2) clk = ~clk;

// reset generation
initial begin
  rst = 1'b1;
  repeat (2) @(posedge clk);
  rst = 1'b0;
end

//////////////////////////////////////////////////////////////////////////////
// Avalon write and read transfers
//////////////////////////////////////////////////////////////////////////////

initial begin
  // reset error counter
  error = 0;

  // Avalon MM interface is idle
  avalon_read  = 1'b0;
  avalon_write = 1'b0;

  // long delay to skip presence pulse
  slave_ena = 1'b0;
  #1000_000;

  // set clock divider ratios
  if (CDR_E) begin
    if (BDW==32) begin
      avalon_cycle (1, 1, 4'hf, {   16'h0001,    16'h0001}, data);
      avalon_cycle (1, 1, 4'hf, {CDR_O[15:0], CDR_N[15:0]}, data);
    end else if (BDW==8) begin
      avalon_cycle (1, 2, 1'b1,      8'h01, data);
      avalon_cycle (1, 3, 1'b1,      8'h01, data);
      avalon_cycle (1, 2, 1'b1, CDR_N[7:0], data);
      avalon_cycle (1, 3, 1'b1, CDR_O[7:0], data);
    end
  end

  // test with slaves with different timing (each slave one one of the wires)
  for (slave_sel=0; slave_sel<OWN; slave_sel=slave_sel+1) begin

    // select normal/overdrive mode
    //for (slave_ovd=0; slave_ovd<(OVD_E?2:1); slave_ovd=slave_ovd+1) begin
    for (i=0; i<(OVD_E?2:1); i=i+1) begin

      slave_ovd = i[0];

      // testbench status message 
      $display("NOTE: Loop: speed=%s, ovd=%b, BTP=\"%s\")", (slave_sel==0) ? "typ" : (slave_sel==1) ? "min" : "max", slave_ovd, slave_ovd ? BTP_O : BTP_N);

      // generate a reset pulse
      slave_ena   = 1'b0;
      slave_dat_r = 1'b1;
      avalon_request (16'd0, slave_sel, {slave_ovd, 2'b10});
      avalon_polling (8, n);
      // expect no response
      if (data[0] !== 1'b1) begin
        error = error+1;
        $display("ERROR: (t=%0t)  Wrong presence detect responce ('1' expected).", $time);
      end

      // generate a reset pulse
      slave_ena   = 1'b1;
      slave_dat_r = 1'b1;
      avalon_request (16'd0, slave_sel, {slave_ovd, 2'b10});
      avalon_polling (8, n);
      // expect presence response
      if (data[0] !== 1'b0) begin
        error = error+1;
        $display("ERROR: (t=%0t)  Wrong presence detect response ('0' expected).", $time);
      end

      // write '0'
      slave_ena   = 1'b1;
      slave_dat_r = 1'b1;
      avalon_request (16'd0, slave_sel, {slave_ovd, 2'b00});
      avalon_polling (8, n);
      // check if '0' was written into the slave
      if (slave_dat_w[slave_sel] !== 1'b0) begin
        error = error+1;
        $display("ERROR: (t=%0t)  Wrong write data for write '0'.", $time);
      end
      // check if '0' was read from the slave
      if (data[0] !== 1'b0) begin
        error = error+1;
        $display("ERROR: (t=%0t)  Wrong read  data for write '0'.", $time);
      end

      // write '1', read '1'
      slave_ena   = 1'b1;
      slave_dat_r = 1'b1;
      avalon_request (16'd0, slave_sel, {slave_ovd, 2'b01});
      avalon_polling (8, n);
      // check if '0' was written into the slave
      if (slave_dat_w[slave_sel] !== 1'b1) begin
        error = error+1;
        $display("ERROR: (t=%0t)  Wrong write data for write '1', read '1'.", $time);
      end
      // check if '1' was read from the slave
      if (data[0] !== 1'b1) begin
        error = error+1;
        $display("ERROR: (t=%0t)  Wrong read  data for write '1', read '1'.", $time);
      end

      // write '1', read '0'
      slave_ena   = 1'b1;
      slave_dat_r = 1'b0;
      avalon_request (16'd0, slave_sel, {slave_ovd, 2'b01});
      avalon_polling (8, n);
      // check if '0' was written into the slave
      if (slave_dat_w[slave_sel] !== 1'b0) begin
        error = error+1;
        $display("ERROR: (t=%0t)  Wrong write data for write '1', read '0'.", $time);
      end
      // check if '0' was read from the slave
      if (data[0] !== 1'b0) begin
        error = error+1;
        $display("ERROR: (t=%0t)  Wrong read  data for write '1', read '0'.", $time);
      end

    end  // slave_ovd

  end  // slave_sel

  // test power supply on a typical normal mode slave
  slave_sel = 0;

  // generate a delay pulse (1ms) with power supply enabled
  avalon_request (16'd1, slave_sel, 3'b011);
  avalon_polling (1, n);
  // check if '1' was read from the slave
  if ((data[0] !== 1'b1) & ~slave_ovd) begin
    error = error+1;
    $display("ERROR: (t=%0t)  Wrong presence detect response (power expected).", $time);
  end
  // check if power is present
  if (owr_p[slave_sel] !== 1'b1) begin
    error = error+1;
    $display("ERROR: (t=%0t)  Wrong line power state", $time);
  end
  // check the time to run a delay cycle
  if ((n-1)*2 != FRQ/1000) begin
    $display("WARNING: (t=%0t)  Non ideal cycle time (%0dus), should be around 1ms.", $time, 2*(n-1)*1_000_000/FRQ);
  end

  // generate a idle pulse (0ms) with power supply enabled
  avalon_request (16'd1, slave_sel, 3'b111);
  avalon_polling (1, n);
  // check if power is present
  if (owr_p[slave_sel] !== 1'b1) begin
    error = error+1;
    $display("ERROR: (t=%0t)  Wrong line power state", $time);
  end
  // check the time to run an idle cycle
  if (n>1) begin
    $display("ERROR: (t=%0t)  Non ideal idle cycle time, should be around zero.", $time);
  end

  // generate a delay pulse and break it with an idle pulse, before it finishes
  repeat (10) @(posedge clk);
  avalon_request (16'd0, 4'h0, 3'b011);
  repeat (10) @(posedge clk);
  avalon_request (16'd0, 4'h0, 3'b111);

  // wait a few cycles and finish
  repeat (10) @(posedge clk);
  $finish(); 
end

// avalon request cycle
task avalon_request (
  input [15:0] pwr,  // power enable
  input  [3:0] sel,  // onewire slave select
  input  [2:0] cmd   // command {ovd, rst, dat}
);
  reg [BDW-1:0] data;  // read data
begin
  if (BDW==32) begin
    avalon_cycle (1, 0, 4'hf, {pwr<<sel, 4'h0, sel, 3'b000, pwr[0], 1'b1, cmd}, data);  
  end else begin
    avalon_cycle (1, 1, 1'b1, {pwr[3:0]<<sel, 2'h0, sel[1:0]}, data);  
    avalon_cycle (1, 0, 1'b1, {    3'b000, pwr[0], 1'b1, cmd}, data);  
  end
end endtask

// wait for the onewire cycle completion
task avalon_polling (
  input  integer dly,
  output integer n
); begin
  // set cycle counter to zero
  n = 0;
  // poll till owr_cyc ends
  if (BDW==32) begin
    data = 32'h08;
    while (data & 32'h08) begin
      repeat (dly) @ (posedge clk);
      avalon_cycle (0, 0, 4'hf, 32'hxxxx_xxxx, data);
      n = n + 1;
    end
  end else begin
    data = 8'h08;
    while (data & 8'h08) begin
      repeat (dly) @ (posedge clk);
      avalon_cycle (0, 0, 1'b1, 8'hxx, data);
      n = n + 1;
    end
  end
end endtask

//////////////////////////////////////////////////////////////////////////////
// Avalon transfer cycle generation task
//////////////////////////////////////////////////////////////////////////////

task automatic avalon_cycle (
  input            r_w,  // 0-read or 1-write cycle
  input  [AAW-1:0] adr,
  input  [ABW-1:0] ben,
  input  [ADW-1:0] wdt,
  output [ADW-1:0] rdt
);
begin
  if (DEBUG) $display ("Avalon MM cycle start: T=%10tns, %s address=%08x byteenable=%04b writedata=%08x", $time/1000.0, r_w?"write":"read ", adr, ben, wdt);
  // start an Avalon cycle
  avalon_read       <= ~r_w;
  avalon_write      <=  r_w;
  avalon_address    <=  adr;
  avalon_byteenable <=  ben;
  avalon_writedata  <=  wdt;
  // wait for waitrequest to be retracted
  @ (posedge clk); while (~avalon_transfer) @ (posedge clk);
  // end Avalon cycle
  avalon_read       <= 1'b0;
  avalon_write      <= 1'b0;
  // read data
  rdt = avalon_readdata;
  if (DEBUG) $display ("Avalon MM cycle end  : T=%10tns, readdata=%08x", $time/1000.0, rdt);
end
endtask

// avalon cycle transfer cycle end status
assign avalon_transfer = (avalon_read | avalon_write) & ~avalon_waitrequest;

assign avalon_waitrequest = 1'b0;

//////////////////////////////////////////////////////////////////////////////
// RTL instance
//////////////////////////////////////////////////////////////////////////////

sockit_owm #(
  .OVD_E    (OVD_E),
  .CDR_E    (CDR_E),
  .BDW      (BDW  ),
  .BAW      (BAW  ),
  .OWN      (OWN  ),
  .BTP_N    (BTP_N),
  .BTP_O    (BTP_O),
  .CDR_N    (CDR_N),
  .CDR_O    (CDR_O)
) onewire_master (
  // system
  .clk      (clk),
  .rst      (rst),
  // Avalon
  .bus_ren  (avalon_read),
  .bus_wen  (avalon_write),
  .bus_adr  (avalon_address),
  .bus_wdt  (avalon_writedata),
  .bus_rdt  (avalon_readdata),
  .bus_irq  (avalon_interrupt),
  // onewire
  .owr_p    (owr_p),
  .owr_e    (owr_e),
  .owr_i    (owr_i)
);

// pullup
pullup onewire_pullup [OWN-1:0] (owr);

// tristate buffers
bufif1 onewire_buffer [OWN-1:0] (owr, owr_p, owr_e | owr_p);

// read back
assign owr_i = owr;

//////////////////////////////////////////////////////////////////////////////
// Verilog onewire slave models
//////////////////////////////////////////////////////////////////////////////

`ifdef OWN

// fast slave device
onewire_slave_model onewire_slave [OWN-1:0] (
  // configuration
  .ena    (slave_ena),
  .ovd    (slave_ovd),
  .dat_r  (slave_dat_r),
  .dat_w  (slave_dat_w),
  // 1-wire signal
  .owr    (owr)
);

`else

// Verilog onewire slave models for normal mode

// typical slave device
onewire_slave_model #(
  .TS     (30)
) onewire_slave_n_typ (
  // configuration
  .ena    (slave_ena & (slave_ovd==0)),
  .ovd    (slave_ovd     ),
  .dat_r  (slave_dat_r   ),
  .dat_w  (slave_dat_w[0]),
  // 1-wire signal
  .owr    (owr[0])
);

// fast slave device
onewire_slave_model #(
  .TS     (15 + 0.1)
) onewire_slave_n_min (
  // configuration
  .ena    (slave_ena & (slave_ovd==0)),
  .ovd    (slave_ovd     ),
  .dat_r  (slave_dat_r   ),
  .dat_w  (slave_dat_w[1]),
  // 1-wire signal
  .owr    (owr[1])
);

onewire_slave_model #(
  .TS     (60 - 0.1)
) onewire_slave_n_max (
  // configuration
  .ena    (slave_ena & (slave_ovd==0)),
  .ovd    (slave_ovd     ),
  .dat_r  (slave_dat_r   ),
  .dat_w  (slave_dat_w[2]),
  // 1-wire signal
  .owr    (owr[2])
);

// Verilog onewire slave models for overdrive mode

// typical slave device
onewire_slave_model #(
  .TS     (30)
) onewire_slave_o_typ (
  // configuration
  .ena    (slave_ena & (slave_ovd==1)),
  .ovd    (slave_ovd     ),
  .dat_r  (slave_dat_r   ),
  .dat_w  (slave_dat_w[0]),
  // 1-wire signal
  .owr    (owr[0])
);

// fast slave device
onewire_slave_model #(
  .TS     (16)
) onewire_slave_o_min (
  // configuration
  .ena    (slave_ena & (slave_ovd==1)),
  .ovd    (slave_ovd     ),
  .dat_r  (slave_dat_r   ),
  .dat_w  (slave_dat_w[1]),
  // 1-wire signal
  .owr    (owr[1])
);

onewire_slave_model #(
  .TS     (47)
) onewire_slave_o_max (
  // configuration
  .ena    (slave_ena & (slave_ovd==1)),
  .ovd    (slave_ovd     ),
  .dat_r  (slave_dat_r   ),
  .dat_w  (slave_dat_w[2]),
  // 1-wire signal
  .owr    (owr[2])
);

`endif

endmodule
