/////////////////////////////////////////////////////////////////////
////                                                             ////
////  AES Test Bench                                             ////
////                                                             ////
////                                                             ////
////  Author: Javier Castillo                                    ////
////                                                             ////
////                                                             ////
////  Adapted to SystemC                                         ////
////  AES project by: jcastillo@opensocdesign.com                ////
////                                                             ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2005 Javier Castillo                     ////
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
//
//  CVS Log
//
//      $Log: not supported by cvs2svn $

`timescale 10ns/1ns

module top;



reg clk, reset, load_i, decrypt_i;
reg [127:0] data_i;
reg [191:0] key_i;
wire [127:0] data_o;
wire ready_o;


aes192 d1 (clk,reset,load_i,decrypt_i,data_i,key_i,ready_o,data_o);

   initial

   begin
	clk = 'b1;
	reset = 'b1;  
	key_i = 192'h000102030405060708090A0B0C0D0E0F1011121314151617;
	data_i = 128'h000102030405060708090A0B0C0D0E0F;
	
	//key_i = 192'h8765F4765A8594E74635D86950B78432C756365A15326D0E;
	//data_i = 128'h7563957A7C6E92746E87F937A2F4AB04;
	load_i = 'b0;
	decrypt_i = 'b0;
	
	reset = #6 'b0;
	reset = #12 'b1;
	load_i = #17 'b1;
	load_i = #22 'b0;
	
        $display("Running");
        wait(ready_o);	
	$display("%H",data_o);
	$finish;
	
   end
   
   always #5 clk = !clk;

endmodule
