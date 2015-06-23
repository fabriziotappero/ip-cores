
`include "def.h"
`include "data.h"

`timescale 1ns/1ps

module cfi_ctrl_engine_bench();


  // Signal Bus
  wire [`ADDRBUS_dim - 1:0] A;         // Address Bus 
  wire [`DATABUS_dim - 1:0] DQ;        // Data I/0 Bus
  // Control Signal
  wire WE_N;                            // Write Enable 
  wire OE_N;                            // Output Enable
  wire CE_N;                            // Chip Enable
  wire RST_N;                           // Reset
  wire WP_N;                           // Write Protect
  wire ADV_N;                            // Latch Enable
  wire CLK;                              // Clock
  wire WAIT;                           // Wait

  // Voltage signal rappresentad by integer Vector which correspond to millivolts
  wire [`Voltage_range] VCC;  // Supply Voltage
  wire [`Voltage_range] VCCQ; // Supply Voltage for I/O Buffers
  wire [`Voltage_range] VPP; // Optional Supply Voltage for Fast Program & Erase  

  //wire STS;
  
  wire Info;      // Activate/Deactivate info device operation
assign Info = 1;
assign VCC = 36'd1700;
assign VCCQ = 36'd1700;
assign VPP = 36'd2000;

parameter sys_clk_half_period = 15.15/2;
parameter sys_clk_period = sys_clk_half_period*2;
   reg sys_clk;
   reg sys_rst;

initial begin
   sys_clk  = 0;
   forever 
      #sys_clk_half_period sys_clk  = ~sys_clk;
end
   
initial begin
   sys_rst  = 1;
   #sys_clk_period;
   #sys_clk_period;
   sys_rst  = 0;
end

   reg do_rst, do_init, do_readstatus, do_clearstatus,
       do_eraseblock, do_write, do_read,
       do_unlockblock;
   reg [15:0] bus_dat_i;
   reg [23:0] bus_adr_i;
   wire       bus_ack_o;
   wire [15:0] bus_dat_o;
   wire        bus_busy_o;

/* used in testbench only */
   reg [7:0]   cfi_status;
   reg [15:0]  cfi_read_data;


task cfi_engine_wait_for_ready;
   begin
      while (bus_busy_o)
	 #sys_clk_period;
   end
endtask

task cfi_engine_read_status;
   output [7:0] status_o;
   begin
      //$display("%t: Reading status ",$time);
      do_readstatus  = 1;
      #sys_clk_period;
      do_readstatus  = 0;
      while(!bus_ack_o) /* wait for ack back from internal FSMs */
	 #sys_clk_period;
      //$display("%t: status: %h", $time, bus_dat_o[7:0]);
      status_o 	= bus_dat_o[7:0];
      cfi_engine_wait_for_ready();
      /* status:
       7 : write status ( 0 - busy, 1 - ready )
       6 : erase suspend status
       5 : erase status ( 0 - successful, 1 - error)
       4 : program status ( 0  - successful, 1 - error)
       others aren't important
       */
   end
endtask


task cfi_engine_clear_status;
   begin
      $display("%t: Clearing status register ",$time);
      do_clearstatus  = 1;
      #sys_clk_period;
      do_clearstatus  = 0;

      cfi_engine_wait_for_ready();

   end
endtask

task cfi_engine_unlock_block;
   input [23:0] address;
   begin
      $display("%t: Unlocking block at address %h ",$time, address);
      bus_adr_i = address;
      do_unlockblock  = 1;
      #sys_clk_period;
      do_unlockblock  = 0;

      cfi_engine_wait_for_ready();
      
      cfi_engine_read_status(cfi_status);
      while (!cfi_status[7])
	 cfi_engine_read_status(cfi_status);

   end
endtask


task cfi_engine_erase_block;
   input [23:0] address;
   begin
      $display("%t: Erasing block at address %h ",$time, address);
      bus_adr_i = address;
      do_eraseblock  = 1;
      #sys_clk_period;
      do_eraseblock  = 0;

      cfi_engine_wait_for_ready();
      
      cfi_engine_read_status(cfi_status);
      while (!cfi_status[7])
	 cfi_engine_read_status(cfi_status);

      /* Check status */
      if (cfi_status[5])
	 $display("$t: Erase failed for address %h",$time, address);
      else
	 $display("$t: Erase succeeded for address %h",$time, address);
      
   end
endtask


task cfi_engine_write_word;
   input [23:0] address;
   input [15:0] data;
   begin
      $display("%t: Writing data %h to address %h",$time , data, address);
      bus_adr_i  = address;
      bus_dat_i = data;
      
      do_write 	 = 1;
      #sys_clk_period;
      do_write  = 0;

      cfi_engine_wait_for_ready();
      
      cfi_engine_read_status(cfi_status);
      while (!cfi_status[7])
	 cfi_engine_read_status(cfi_status);

   end
endtask


task cfi_engine_read_word;
   input [23:0] address;
   output [15:0] data;
   begin
      $display("%t: Reading word from address %h",$time , address);
      bus_adr_i  = address;
      
      do_read 	 = 1;
      #sys_clk_period;
      do_read  = 0;

      cfi_engine_wait_for_ready();
      data = bus_dat_o;
      
   end
endtask // cfi_engine_read_word

   task cfi_engine_reset;
      begin
	 $display("%t: Resetting flash device", $time);

	 do_rst 	 = 1;
	 #sys_clk_period;
	 do_rst  = 0;

	 cfi_engine_wait_for_ready();
      end
   endtask
      

 /* Main test stimulus block */
initial begin
   do_rst 	   = 0;
   do_init 	   = 0;
   do_readstatus   =0;
   do_clearstatus = 0;
   do_eraseblock   =0;
   do_unlockblock  =0;
   do_write 	   =0;
   do_read 	   =0;
   bus_dat_i 	   = 0;
   bus_adr_i 	   = 0;
   
   $dumpfile("../out/cfi_ctrl_engine_bench.vcd");
   $dumpvars(0);
   $display("Starting CFI engine test");
   #550; // Wait for the part to power up
   cfi_engine_read_status(cfi_status);
   cfi_engine_wait_for_ready();
   cfi_engine_unlock_block(24'h00_1000);
   cfi_engine_wait_for_ready();
   cfi_engine_erase_block(24'h00_1000);

   cfi_engine_clear_status();

   cfi_engine_write_word(24'h00_1000, 16'hdead);
   cfi_engine_write_word(24'h00_1001, 16'hcafe);
   cfi_engine_write_word(24'h00_1002, 16'hc001);
   cfi_engine_write_word(24'h00_1003, 16'h4311);
   cfi_engine_write_word(24'h00_1004, 16'hecc1);
   cfi_engine_write_word(24'h00_1005, 16'hd311);

   cfi_engine_read_word(24'h00_1000, cfi_read_data);
   cfi_engine_read_word(24'h00_1001, cfi_read_data);
   cfi_engine_read_word(24'h00_1002, cfi_read_data);
   cfi_engine_read_word(24'h00_1003, cfi_read_data);
   cfi_engine_read_word(24'h00_1004, cfi_read_data);
   cfi_engine_read_word(24'h00_1005, cfi_read_data);

   cfi_engine_reset();

   cfi_engine_read_word(24'h00_1000, cfi_read_data);
   cfi_engine_read_word(24'h00_1001, cfi_read_data);
   cfi_engine_read_word(24'h00_1002, cfi_read_data);
   cfi_engine_read_word(24'h00_1003, cfi_read_data);
   cfi_engine_read_word(24'h00_1004, cfi_read_data);
   cfi_engine_read_word(24'h00_1005, cfi_read_data);
   
      
   #1000
   $display("Finishing CFI engine test");
   $finish;
end

/* timeout function - sim shouldn't run much longer than this */
initial begin
   #55000;
   $display("Simulation finish due to timeout");
   $finish;
end

      

cfi_ctrl_engine 
/*# (.cfi_part_elov_cycles(10))*/
dut
   (
    .clk_i(sys_clk), 
    .rst_i(sys_rst),

    .do_rst_i(do_rst),
    .do_init_i(do_init),
    .do_readstatus_i(do_readstatus),
    .do_clearstatus_i(do_clearstatus),
    .do_eraseblock_i(do_eraseblock),
    .do_unlockblock_i(do_unlockblock),
    .do_write_i(do_write),
    .do_read_i(do_read),

    .bus_dat_o(bus_dat_o),
    .bus_dat_i(bus_dat_i),
    .bus_adr_i(bus_adr_i),
    .bus_req_done_o(bus_ack_o),
    .bus_busy_o(bus_busy_o),
   
    .flash_dq_io(DQ),
    .flash_adr_o(A),
    .flash_adv_n_o(ADV_N),
    .flash_ce_n_o(CE_N),
    .flash_clk_o(CLK),
    .flash_oe_n_o(OE_N),
    .flash_rst_n_o(RST_N),
    .flash_wait_i(WAIT),
    .flash_we_n_o(WE_N),
    .flash_wp_n_o(WP_N)

    );

x28fxxxp30 part(A, DQ, WE_N, OE_N, CE_N, ADV_N, CLK, 
		WAIT, WP_N, RST_N, VCC, VCCQ, VPP, Info);


endmodule
