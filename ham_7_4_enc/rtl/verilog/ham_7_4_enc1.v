/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Hamming (7,4) Encoder                                      ////
////                                                             ////
////                                                             ////
////  Author: Soner Yesil                                        ////
////          soneryesil@opencores.org                           ////
////                                                             ////
////                                                             ////
////  D/L from: http://www.opencores.org/cores/ham_7_4_enc/      ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2004      Soner Yesil                         ////
////                         soneryesil@opencores.org            ////
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

/*

Description
===========

1.Hamming (7,4) Encoder:
----------------------
This core encodes every 4-bit message into
7-bit codewords in such a way that the decoder
can correct any single-bit error.

The encoding is performed by matrix multiplication 
of the 4-bit message vector with the generator matrix, G.

C=M*G,

where 
*M is the 4-bit message M=[m1 m2 m3 m4]
*G is the generator matrix
	
		1110000
	G =   1001100
		0101010
		1101001
*and C is the corresponding codeword C=[c1 c2 c3 c4 c5 c6];


2.Functionality:
----------------

CLK : posedge clock.
RESET: active low asynchronous reset.
DATA_IN[3:0]: Message input, valid when DVIN is LOW.
DVIN: when LOW, data seen at the DATA_IN input is registered at rising edge of the CLK.
CODE[6:0]: corresponding codeword. It is valid when DVOUT is LOW.
DVOUT: when LOW, data at the output CODE is valid codeword.

 
*/
///////////////////////////////////

module ham_7_4_enc (
clk,
reset,
data_in,
dvin,
code,
dvout);

input clk, reset;
input [3:0] data_in;
input dvin;

output [6:0] code;
output dvout;
reg [6:0] code;
reg dvout;

reg [3:0] datareg;
reg dvinreg;

////////////////////////////////////////////
////// matrix multiplication ///////////////
////////////////////////////////////////////

wire c0 = datareg[3]^datareg[2]^datareg[0];
wire c1 = datareg[3]^datareg[1]^datareg[0];
wire c2 = datareg[3];
wire c3 = datareg[2]^datareg[1]^datareg[0];
wire c4 = datareg[2];
wire c5 = datareg[1];
wire c6 = datareg[0];

////////////////////////////////////////////
///////////// Getting inputs ///////////////
////////////////////////////////////////////

always@(posedge clk or negedge reset) 
if (!reset)
	dvinreg<=1;
else
	dvinreg<=dvin;

always@(posedge clk)
if (reset)
	datareg<=0;
else if (!dvin)
	datareg<=data_in;



////////////////////////////////////////////
// Codeword is generated 1-clock cycle /////
// after the inputs are registered.    /////
////////////////////////////////////////////

always@(posedge clk)
if (reset)
	dvout<=1;
else
	dvout<=dvinreg;

always@(posedge clk)
if (reset)
	code<=0;
else
	code<={c6, c5, c4, c3, c2, c1, c0};


endmodule

////////////////////////////////////////////
