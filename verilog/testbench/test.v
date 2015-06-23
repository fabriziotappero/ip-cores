/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Test Bench                                                 ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  D/L from: http://www.opencores.org/cores/minirisc/         ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: test.v,v 1.1 2002-09-27 15:35:41 rudi Exp $
//
//  $Date: 2002-09-27 15:35:41 $
//  $Revision: 1.1 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//
//
//
//
//
//
//
//
//
//

`timescale 1ns / 10ps

module test;

reg		clk;
reg		reset;
reg		tcki;

// Declare I/O Port connections
wire [7:0]	porta; // I/O Port A
wire [7:0]	portb; // I/O Port B
wire [7:0]	portc; // I/O Port C

wire [7:0]	portain;
wire [7:0]	portbin;
wire [7:0]	portcin;

wire [7:0]	portaout;
wire [7:0]	portbout;
wire [7:0]	portcout;

wire [7:0]	trisa;
wire [7:0]	trisb;
wire [7:0]	trisc;

// Declare ROM and rom signals
wire [10:0]	inst_addr;
wire [11:0]	inst_data;


always #10 clk = ~clk;
always #20 tcki = ~tcki;

// Instantiate one CPU to be tested.
mrisc u0(
   .clk		(clk),
   .rst_in	(reset),
   .inst_addr	(inst_addr),
   .inst_data	(inst_data),

   .portain	(portain),
   .portbin	(portbin),
   .portcin	(portcin),

   .portaout	(portaout),
   .portbout	(portbout),
   .portcout	(portcout),

   .trisa	(trisa),
   .trisb	(trisb),
   .trisc	(trisc),
   
   .tcki	(tcki),
   .wdt_en	(1'b1)

   );

// IO buffers for IO Ports
assign porta = trisa ? 8'bz : portaout;
assign portain = porta;

assign portb = trisb ? 8'bz : portbout;
assign portbin = portb;

assign portc = trisc ? 8'bz : portcout;
assign portcin = portc;

// Pullups for IO Ports
pullup ua0(porta[0]);
pullup ua1(porta[1]);
pullup ua2(porta[2]);
pullup ua3(porta[3]);
pullup ua4(porta[4]);
pullup ua5(porta[5]);
pullup ua6(porta[6]);
pullup ua7(porta[7]);

pullup ub0(portb[0]);
pullup ub1(portb[1]);
pullup ub2(portb[2]);
pullup ub3(portb[3]);
pullup ub4(portb[4]);
pullup ub5(portb[5]);
pullup ub6(portb[6]);
pullup ub7(portb[7]);

pullup uc0(portc[0]);
pullup uc1(portc[1]);
pullup uc2(portc[2]);
pullup uc3(portc[3]);
pullup uc4(portc[4]);
pullup uc5(portc[5]);
pullup uc6(portc[6]);
pullup uc7(portc[7]);


// Instantiate the Program RAM.
prog_mem u1 (
   .clk		(clk),
   .address	(inst_addr),
   .we		(1'b0),			// This testbench doesn't allow writing to PRAM
   .din		(12'b000000000000),	// This testbench doesn't allow writing to PRAM
   .dout	(inst_data)
);

// This is the only initial block in the test module and this is where
// you select what test you want to do.

initial
   begin
	$display ("\n\nMini-RISC.  Version 1.0\n\n");
   
	//$dumpfile ("mini-risc.vcd");
	//$dumpvars (0, test);
      
	clk = 0;
   	tcki = 0;

  	sanity1;
	
	$readmemh ("../scode/sanity2.rom", u1.mem);	run_code("Sanity 2 ");
	
	$readmemh ("../scode/rf1.rom", u1.mem);		run_code("Register File 1 ");
	
	$readmemh ("../scode/rf2.rom", u1.mem);		run_code("Register File 2 ");
	
	$readmemh ("../scode/rf3.rom", u1.mem);		run_code("Register File 3 ");
	
	//$readmemh ("scode/tmr_wdt.rom", u1.mem);	run_code("Timer / WDT ");
	
	//$dumpflush;
	$finish;
   end


task sanity1;

`define		GOOD	12'h0aa
`define		BAD	12'h0af
`define		SANITY1	"../scode/sanity1.rom"

    begin
  	$display ("========== Starting Sanity 1 Test ========== \n");
	reset = 1;
	repeat(10)	@(posedge clk);
	reset = 0;
   
	//$display ("Loading program memory with %s", `SANITY1);
	$readmemh (`SANITY1, u1.mem);
	while(inst_addr != `GOOD & inst_addr != `BAD)	@(posedge clk);
	
	if(inst_addr == `GOOD)
	   begin
		$display("Sanity1 test PASSED !!!");
	   end
	else
	if(inst_addr == `BAD)
	   begin
		$display("Sanity1 test FAILED !!!");
	   end
	else
		$display("Sanity1 test status UNKNOWN !!!");


	repeat(4)	@(posedge clk);
	$display("=============================================\n\n\n");

   end 
endtask

task run_code;
input [16*8-1:0]	str;


    begin
  	$display ("========== Starting %s Test ========== \n",str);
	reset = 1;
	repeat(10)	@(posedge clk);
	reset = 0;
   
	//$display ("Loading program memory with %s", `SANITY2);
	//$readmemh (`SANITY2, u1.mem);
	
	repeat(10)	@(posedge clk);
	while(porta == 8'h00)	@(posedge clk);

	
	if(porta == 8'h01)
	   begin
		$display("Test %s PASSED !!!",str);
	   end
	else
	if(porta == 8'hff)
	   begin
		$display("Test %s FAILED in test %d !!!", str, portb);
	   end
	else
		$display("Test %s status UNKNOWN (%h test: %d) !!!", str, porta, portb);


	repeat(4)	@(posedge clk);
	$display("\n=============================================\n\n\n");

   end 
endtask

/*
always @(posedge clk)
   if(!reset)
      begin
	if( |u0.w ===1'bx )	$display("%t: Warning :W went unknown",$time);
	if( |u0.pc ===1'bx )	$display("%t: Warning :PC went unknown",$time); 
	if( |u0.status ===1'bx )	$display("%t: Warning :STATUS went unknown",$time); 
      end
*/

reg [8*8-1:0] inst_string;

always @(inst_data) begin
   casex (inst_data)
      12'b0000_0000_0000: inst_string = "NOP     ";
      12'b0000_001X_XXXX: inst_string = "MOVWF   ";
      12'b0000_0100_0000: inst_string = "CLRW    ";
      12'b0000_011X_XXXX: inst_string = "CLRF    ";
      12'b0000_10XX_XXXX: inst_string = "SUBWF   ";
      12'b0000_11XX_XXXX: inst_string = "DECF    ";
      12'b0001_00XX_XXXX: inst_string = "IORWF   ";
      12'b0001_01XX_XXXX: inst_string = "ANDWF   ";
      12'b0001_10XX_XXXX: inst_string = "XORWF   ";
      12'b0001_11XX_XXXX: inst_string = "ADDWF   ";
      12'b0010_00XX_XXXX: inst_string = "MOVF    ";
      12'b0010_01XX_XXXX: inst_string = "COMF    ";
      12'b0010_10XX_XXXX: inst_string = "INCF    ";
      12'b0010_11XX_XXXX: inst_string = "DECFSZ  ";
      12'b0011_00XX_XXXX: inst_string = "RRF     ";
      12'b0011_01XX_XXXX: inst_string = "RLF     ";
      12'b0011_10XX_XXXX: inst_string = "SWAPF   ";
      12'b0011_11XX_XXXX: inst_string = "INCFSZ  ";

      // *** Bit-Oriented File Register Operations
      12'b0100_XXXX_XXXX: inst_string = "BCF     ";
      12'b0101_XXXX_XXXX: inst_string = "BSF     ";
      12'b0110_XXXX_XXXX: inst_string = "BTFSC   ";
      12'b0111_XXXX_XXXX: inst_string = "BTFSS   ";

      // *** Literal and Control Operations
      12'b0000_0000_0010: inst_string = "OPTION  ";
      12'b0000_0000_0011: inst_string = "SLEEP   ";
      12'b0000_0000_0100: inst_string = "CLRWDT  ";
      12'b0000_0000_0101: inst_string = "TRIS    ";
      12'b0000_0000_0110: inst_string = "TRIS    ";
      12'b0000_0000_0111: inst_string = "TRIS    ";
      12'b1000_XXXX_XXXX: inst_string = "RETLW   ";
      12'b1001_XXXX_XXXX: inst_string = "CALL    ";
      12'b101X_XXXX_XXXX: inst_string = "GOTO    ";
      12'b1100_XXXX_XXXX: inst_string = "MOVLW   ";
      12'b1101_XXXX_XXXX: inst_string = "IORLW   ";
      12'b1110_XXXX_XXXX: inst_string = "ANDLW   ";
      12'b1111_XXXX_XXXX: inst_string = "XORLW   ";

      default:            inst_string = "-XXXXXX-";
   endcase
   //$display("Executing[%h] %s",inst_addr, inst_string);
end
   

endmodule

