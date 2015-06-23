/* Testbench of Wishbone classic-slave wrapped basic CFI controller */

`include "def.h"
`include "data.h"

`timescale 1ns/1ps

module cfi_ctrl_wb_bench();


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

parameter sys_clk_half_period = 15.15/2; /* 66MHz */
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

   reg [31:0] wb_adr_i;
   reg [31:0] wb_dat_i;
   reg 	      wb_stb_i;
   reg 	      wb_cyc_i;
   reg [3:0]  wb_sel_i;
   reg 	      wb_we_i;
   wire [31:0] wb_dat_o;   
   wire        wb_ack_o;
   
   task wb_wait_for_ack;
      begin
	 while (!wb_ack_o)
	   #sys_clk_period;

	 wb_stb_i = 0;
	 wb_cyc_i = 0;
	 /* Leave these deasserted for a cycle */
	 #sys_clk_period;
      end
   endtask // wb_wait_for_ack

   task wb_write_16bits;
      input [31:0] address;
      input [15:0] dat;
      begin
	 wb_adr_i = {address[31:1],1'b0};
	 wb_dat_i = {dat,dat};
	 wb_sel_i = address[1] ? 4'h3 : 4'hc;
	 wb_we_i = 1;
	 wb_stb_i = 1;
	 wb_cyc_i = 1;
	 #sys_clk_period;
	 wb_wait_for_ack();
      end
   endtask // wb_write_16bits
   

   task wb_write_32bits;
      input [31:0] address;
      input [31:0] dat;
      begin
	 wb_adr_i = address;
	 wb_dat_i = dat;
	 wb_sel_i = 4'hf;
	 wb_we_i = 1;
	 wb_stb_i = 1;
	 wb_cyc_i = 1;
	 #sys_clk_period;
	 wb_wait_for_ack();
      end
   endtask // wb_write_32bits

   task wb_read_8bits;
      input [31:0] address;
      output [7:0] dat;
      begin
	 wb_adr_i = address[31:0];
	 wb_sel_i = address[1:0] == 2'b00 ? 4'h8 :
		    address[1:0] == 2'b01 ? 4'h4 :
		    address[1:0] == 2'b10 ? 4'h2 : 4'h1;
	 wb_we_i = 0;
	 wb_stb_i = 1;
	 wb_cyc_i = 1;
	 #sys_clk_period;
	 wb_wait_for_ack();
	 dat = address[1:0] == 2'b00 ? wb_dat_o[31:24] :
	       address[1:0] == 2'b01 ? wb_dat_o[23:16] :
	       address[1:0] == 2'b10 ? wb_dat_o[15:8]  : wb_dat_o[7:0];
      end
   endtask // wb_read_16bits
   
   task wb_read_16bits;
      input [31:0] address;
      output [15:0] dat;
      begin
	 wb_adr_i = {address[31:1],1'b0};
	 wb_sel_i = address[1] ? 4'h3 : 4'hc;
	 wb_we_i = 0;
	 wb_stb_i = 1;
	 wb_cyc_i = 1;
	 #sys_clk_period;
	 wb_wait_for_ack();
	 dat = address[1] ? wb_dat_o[15:0] : wb_dat_o[31:16];
      end
   endtask // wb_read_16bits
   
   task wb_read_32bits;
      input [31:0] address;
      output [31:0] dat;
      begin
	 wb_adr_i = address;
	 wb_sel_i = 4'hf;
	 wb_we_i = 0;
	 wb_stb_i = 1;
	 wb_cyc_i = 1;
	 #sys_clk_period;
	 wb_wait_for_ack();
	 dat = wb_dat_o;
      end
   endtask // wb_read_32bits

   reg [31:0] temp_data;
   reg [7:0]  status_reg;

   task wb_cfi_read_status_reg;
      output [7:0] stat;
      begin
	 wb_write_16bits(32'h0, 16'h0070);
	 wb_read_16bits(32'h0, stat);
      end
   endtask // wb_cfi_read_status_reg

   task wb_cfi_wait_for_status_ready;
      begin
	 wb_cfi_read_status_reg(status_reg);
	 while (!status_reg[7])
	   wb_cfi_read_status_reg(status_reg);
      end
   endtask // wb_cfi_wait_for_status_ready
   
   task wb_cfi_write_16bits;
      input [31:0] address;
      input [15:0] dat;
       begin
	  wb_write_16bits(address, 16'h0040);
	  wb_write_16bits(address, dat);
	  wb_cfi_wait_for_status_ready();
       end
   endtask // wb_cfi_write_16bits
   
   task wb_cfi_write_32bits;
      input [31:0] address;
      input [31:0] dat;
      begin
	 wb_cfi_write_16bits(address, dat[31:16]);
	 wb_cfi_write_16bits(address+2, dat[15:0]);
      end
   endtask // wb_cfi_write_32bits

   task wb_cfi_read_8bits;
      input [31:0] address;
      output [7:0] dat;
      begin
	 wb_write_16bits(address, 16'h00ff);
	 wb_read_8bits(address, dat);
      end
   endtask // wb_read_8bits
   
   task wb_cfi_read_16bits;
      input [31:0] address;
      output [15:0] dat;
       begin
	  wb_write_16bits(address, 16'h00ff);
	  wb_read_16bits(address, dat);
       end
   endtask // wb_cfi_read_16bits
   
   task wb_cfi_read_32bits;
      input [31:0] address;
      output [31:0] dat;
      begin
	 wb_cfi_read_16bits(address, dat[31:16]);
	 wb_cfi_read_16bits(address+2, dat[15:0]);
      end
   endtask // wb_cfi_write_32bits

   task wb_cfi_unlock_and_erase_block;
      input [31:0] address;
      begin
	 /* Unlock block */
	 wb_write_16bits(address, 16'h0060);
	 wb_write_16bits(address, 16'h00D0);
	 /* Erase block */
	 wb_write_16bits(address, 16'h0020);
	 wb_write_16bits(address, 16'h00D0);
	 wb_cfi_wait_for_status_ready();
      end
   endtask

   task wb_cfi_read_device_ident;
      input [31:0] address;
      output [15:0] data;
      begin
	 wb_write_16bits(32'd0, 16'h0090);
	 wb_read_16bits((address<<1), data);
      end
   endtask // wb_cfi_read_device_ident

   task wb_cfi_query;
      input [31:0] address;
      output [15:0] data;
      begin
	 wb_write_16bits(32'd0, 16'h0098);
	 wb_read_16bits((address<<1), data);
      end
   endtask // wb_cfi_query

   task wb_cfi_read_all_device_ident;
      begin
	 $display("%t Reading device identifier information", $time);
	 wb_cfi_read_device_ident(0,temp_data[15:0]);
	 $display("%t Manufacturer code: %04h",$time,temp_data[15:0]);
	 wb_cfi_read_device_ident(31'h1,temp_data[15:0]);
	 $display("%t Device ID code: %04h",$time,temp_data[15:0]);
	 wb_cfi_read_device_ident(31'h5,temp_data[15:0]);
	 $display("%t RCR: %04h",$time,temp_data[15:0]);
	 wb_cfi_read_device_ident(31'h2 + ((128*1024)>>1),temp_data[15:0]);
	 $display("%t Block 0 locked?: %04h",$time,temp_data[15:0]);
      end
   endtask // wb_cfi_read_all_device_ident

   task wb_cfi_queries;
      begin
	 $display("%t Querying CFI device", $time);
	 wb_cfi_query(31'h10,temp_data[15:0]);
	 $display("%t Query ID string: %04h",$time,temp_data[15:0]);
	 wb_cfi_query(31'h13,temp_data[15:0]);
	 $display("%t Vendor command set and control interface ID: %04h",$time,temp_data[15:0]);
	 wb_cfi_query(31'h27,temp_data[15:0]);
	 $display("%t size 2^n: %04h",$time,temp_data[15:0]);
	 wb_cfi_query(31'h28,temp_data[15:0]);
	 $display("%t device interface code: %04h",$time,temp_data[15:0]);
	 wb_cfi_query(31'h2c,temp_data[15:0]);
	 $display("%t number of erase block regions: %04h",$time,temp_data[15:0]);
	 
      end
      endtask
   
   integer i;

   parameter test_length = 16;
   reg [31:0] temp_result;
   
 /* Main test stimulus block */
initial begin

   wb_adr_i = 0;
   wb_dat_i = 0;
   wb_stb_i = 0;
   wb_cyc_i = 0;
   wb_sel_i = 0;
   wb_we_i = 0;
   
   $dumpfile("../out/cfi_ctrl_wb_bench.vcd");
   $dumpvars(0);
   $display("Starting CFI Wishbone controller test");
   #550; // Wait for the part to power up

   
   wb_cfi_read_all_device_ident();
   #500;
   wb_cfi_queries();
   #500;
   
   /* Ready first block for play*/
   wb_cfi_unlock_and_erase_block(0);
   
   /* Clear status register */
   wb_write_16bits(32'd0, 16'h0050);
   
   /* Write a 32-bit word */
   wb_cfi_write_32bits(32'h0000_0000, 32'hdeadbeef);

   /* read it back */
   wb_cfi_read_32bits(32'h0000_0000, temp_data);
   /* works because we're already in read array mode */
   wb_read_32bits(32'h0000_0000, temp_data);
   
   /* Write data  */
   for (i = 0; i< ((4*test_length)/4); i=i+1) begin
      temp_result[31:16] = 16'hdead-i;
      temp_result[15:0] = 16'hbeef+i;
      wb_cfi_write_32bits(32'h0000_0000+i*4, temp_result);
   end

   /* Read it back 16-bits at a time and check it */
   for (i = 0; i< ((4*test_length)/4); i=i+1) begin
      wb_cfi_read_16bits(32'h0000_0000+i*4, temp_data[31:16]);
      wb_cfi_read_16bits(32'h0000_0000+i*4+2, temp_data[15:0]);
      temp_result[31:16] = 16'hdead-i;
      temp_result[15:0] = 16'hbeef+i;
      if (temp_data != temp_result) begin
	 $display("Read verify error at %h",(i*4));
	 $finish;
      end
   end
   /* Read it back 8-bits at a time and check it */
   for (i = 0; i< ((4*test_length)/4); i=i+1) begin
      wb_read_8bits(32'h0000_0000+i*4, temp_data[31:24]);
      wb_read_8bits(32'h0000_0000+i*4+1, temp_data[23:16]);
      wb_read_8bits(32'h0000_0000+i*4+2, temp_data[15:8]);
      wb_read_8bits(32'h0000_0000+i*4+3, temp_data[7:0]);
      temp_result[31:16] = 16'hdead-i;
      temp_result[15:0] = 16'hbeef+i;
      if (temp_data != temp_result) begin	
	 $display("Read verify error at %h",(i*4));
	 $finish;
      end
   end
   
   /* Read it back and check it */
   for (i = 0; i< ((4*test_length)/4); i=i+1) begin
      wb_read_32bits(32'h0000_0000+i*4, temp_data);
      temp_result[31:16] = 16'hdead-i;
      temp_result[15:0] = 16'hbeef+i;
      if (temp_data != temp_result) begin
	 $display("Read verify error at %h",(i*4));
	 $finish;
      end
   end

   /* Test doing things on next block */
   wb_cfi_unlock_and_erase_block(32'h20000);

   /* Write 4k of data  */
   for (i = 0; i< ((4*test_length)/4); i=i+1) begin
      temp_result[31:16] = 16'hdead-i;
      temp_result[15:0] = 16'hbeef+i;
      wb_cfi_write_32bits(32'h0002_0000+i*4, temp_result);
   end
   /* Read it back and check it */
   /* Do one read to get it into the read array mode */
   wb_cfi_read_16bits(32'h0002_0000, temp_data[15:0]);
   for (i = 0; i< ((4*test_length)/4); i=i+1) begin
      wb_read_32bits(32'h0002_0000+i*4, temp_data);
      temp_result[31:16] = 16'hdead-i;
      temp_result[15:0] = 16'hbeef+i;
      if (temp_data != temp_result) begin
	$display("Read verify error at %h",(i*4));
	 $finish;
      end
   end

   /* Read it back 16-bits at a time and check it */
   for (i = 0; i< ((4*test_length)/4); i=i+1) begin
      wb_read_16bits(32'h0002_0000+i*4, temp_data[31:16]);
      wb_read_16bits(32'h0002_0000+i*4+2, temp_data[15:0]);
      temp_result[31:16] = 16'hdead-i;
      temp_result[15:0] = 16'hbeef+i;
      if (temp_data != temp_result) begin
	 $display("Read verify error at %h",(i*4));
	 $finish;
      end
   end
      
   $display("Finishing CFI Wishbone controller test");
   $finish;
end

/* timeout function - sim shouldn't run much longer than this */
/*   
initial begin
   #55000;
   $display("Simulation finish due to timeout");
   $finish;
end
*/
cfi_ctrl
  #(.cfi_engine("DISABLED")) /* Simpler controller */
  dut
   (
    .wb_clk_i(sys_clk), 
    .wb_rst_i(sys_rst),

    .wb_adr_i(wb_adr_i),
    .wb_dat_i(wb_dat_i),
    .wb_stb_i(wb_stb_i),
    .wb_cyc_i(wb_cyc_i),
    .wb_we_i (wb_we_i ),
    .wb_sel_i(wb_sel_i),
    .wb_dat_o(wb_dat_o),
    .wb_ack_o(wb_ack_o),    
    
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
