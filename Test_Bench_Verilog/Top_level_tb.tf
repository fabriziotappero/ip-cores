/************************************************************
 MODULE:		Top Level Test Bench for System On A Chip Design

 FILE NAME:	Top_level_tb.tf
 DATE:		May 28th, 2002
 AUTHOR:		Hossein Amidi
 COMPANY:	
 CODE TYPE:	Behavioral Transfer Level

 DESCRIPTION:	This module is the top level Behavioral code of System On a Chip Testbench in 
 Verilog code.
 
 It will instantiate the following blocks in the ASIC:

 1)   SOC
 2)	SDRAM Behavioral Model

 Hossein Amidi
 (C) May 2002

*********************************************************/

// DEFINES
`timescale 1ns / 10ps
 
module testbench;

// Parameter
`include        "parameter.v"

// Inputs
reg clk;
reg reset;
reg irq;
reg ser_rxd;
wire [flash_size - 1 : 0]flash_datain;

// Outputs
wire [add_size - 1 : 0]addr;
wire [cs_size  - 1 : 0]cs;
wire ras;
wire cas;
wire we;
wire [dqm_size - 1 : 0]dqm;
wire cke;
wire [ba_size - 1 : 0]ba;
wire pllclk;
wire halted;
wire ser_txd;
wire flash_cle;
wire flash_ale;
wire flash_ce;
wire flash_re;
wire flash_we;
wire flash_wp;
wire flash_rb;
wire flash_irq;
wire [flash_size - 1 : 0]flash_dataout;


// Bidirs
wire [data_size - 1 : 0]dq;

// Internal wires
integer i;
wire [flash_size - 1 : 0]wflash_dataout;

reg	pre;
reg	vdd;

wire pll_lock;

wire [data_size - 1 : 0]mem_dataout;
wire [data_size - 1 : 0]mem_datain;
wire [padd_size - 1 : 0]mem_addr;
wire memreq;
wire rdwrbar;



/*---------------------------------Instantiation of Modules-------------------------*/

MEM Memory ( // Input
					.DataIn(mem_dataout),
					.Address(mem_addr),
					.MemReq(memreq),
					.RdWrBar(rdwrbar),
					.clock(pllclk),
//					.pll_lock(pll_lock),
					// Output
					.DataOut(mem_datain)
					);


k9f1g08u0m  flash_0(	// Input
							.ceb(flash_ce),
							.cle(flash_cle),
							.ale(flash_ale),
							.web(flash_we),
							.reb(flash_re),
							.io(wflash_dataout),
							.wpb(flash_wp),
							.rbb(flash_rb),
							.pre(pre),
							.vdd(vdd)
							);


sdram sdram_0(// Inputs
				.Addr(addr),
			   .Ba(ba),
			   .Clk(pllclk),
				.Cke(cke),
				.Cs_n(cs[0]),
				.Ras_n(ras),
				.Cas_n(cas),
				.We_n(we),
				.Dqm(dm),
				// Inouts
				.Dq(dq[7:0])
				);


sdram sdram_1(// Inputs
				.Addr(addr),
			   .Ba(ba),
			   .Clk(pllclk),
				.Cke(cke),
				.Cs_n(cs[0]),
				.Ras_n(ras),
				.Cas_n(cas),
				.We_n(we),
				.Dqm(dm),
				// Inouts
				.Dq(dq[15:8])
				);

sdram sdram_2(// Inputs
				.Addr(addr),
			   .Ba(ba),
			   .Clk(pllclk),
				.Cke(cke),
				.Cs_n(cs[0]),
				.Ras_n(ras),
				.Cas_n(cas),
				.We_n(we),
				.Dqm(dm),
				// Inouts
				.Dq(dq[23:16])
				);


sdram sdram_3(// Inputs
				.Addr(addr),
			   .Ba(ba),
			   .Clk(pllclk),
				.Cke(cke),
				.Cs_n(cs[0]),
				.Ras_n(ras),
				.Cas_n(cas),
				.We_n(we),
				.Dqm(dm),
				// Inouts
				.Dq(dq[31:24])
				);

soc soc_0 (// Input
	        .clk(clk), 
	        .reset(reset), 
	        .irq(irq), 
	        .ser_rxd(ser_rxd), 
			  .flash_datain(flash_datain),
			  .mem_datain(mem_datain),
			  // Output
			  .pll_lock(pll_lock),
			  .addr(addr),
			  .cs(cs),
	        .ras(ras), 
	        .cas(cas), 
	        .we(we),
			  .dqm(dqm),
	        .cke(cke),
 			  .ba(ba),
	        .pllclk(pllclk), 
	        .halted(halted), 
	        .ser_txd(ser_txd), 
	        .flash_cle(flash_cle), 
	        .flash_ale(flash_ale), 
	        .flash_ce(flash_ce), 
	        .flash_re(flash_re), 
	        .flash_we(flash_we), 
	        .flash_wp(flash_wp), 
	        .flash_rb(flash_rb), 
	        .flash_irq(flash_irq),
			  .flash_dataout(flash_dataout),
			  .mem_dataout(mem_dataout),
			  .mem_addr(mem_addr),
			  .mem_req(memreq),
			  .mem_rdwr(rdwrbar),
			  // Inout
			  .dq(dq)
	        );





initial begin
   clk = 0;
   reset = 0;
   irq = 0;
   ser_rxd = 0;
	pre = 0;
	vdd = 0;
	i = 0;
end

always
begin
	#10 clk <= ~clk;
end

always
begin
	#40 ser_rxd <= ~ser_rxd;
end


task init;
begin
  #10  $display("Reset in process, at time %t",$time);
  #40  reset = 1'b1;
		 $display("Reset is %d, at time %t",reset,$time);
  #20  reset = 1'b0;
		 $display("Reset is %d, at time %t",reset,$time);
		 $display("PLL Lock is %d, at time %t",soc_0.dll_0.pll_lock,$time);
  #150 $display ("Wait for PLL's to Locks, at time %t ", $time);
  #80	 $display("PLL Lock is %d, at time %t",soc_0.dll_0.pll_lock,$time);
  #50  $display ("Setting internal Register of Sub Modules, at time %t", $time);

  #40  $display("Initializing the Memory ..., at time %t",$time);
		 for( i = 0 ; i < 31; i = i + 1)
			Memory.MEM_Data[i] = 32'h0;  	
		 for(i = 0; i < 31; i = i + 1)
			$display("memory [%0d] = %h ", i, Memory.MEM_Data[i]);
  #40  $display("Memory Initialized to known value , at time %t",$time);

end
endtask


task cpu;
begin
	#50
	$display ("RISC CPU 32-bit Version 1.0. This is the BASIC CONFIDENCE TEST.");
   $display ("Loading program memory with %s", "program.txt");
   $readmemb("program.txt",Memory.MEM_Data);
	$display ("Memory loading is done ... ");

	for(i = 0; i < 80; i = i + 1)
		$display("memory [%0d] = %h ", i, Memory.MEM_Data[i]);
end
endtask

initial
begin
 	init;
	cpu;
   $display ("End of Simulation, at time %t", $time);
	#2750
   $stop;
   $finish;
end


endmodule

