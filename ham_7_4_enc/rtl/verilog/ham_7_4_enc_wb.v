/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Hamming (7,4) Encoder                                      ////
////                                                             ////
////                                                             ////
////  Authors: Soner Yesil & Burak Okcan                         ////
////          soneryesil@opencores.org                           ////
////          burakokcan@opencores.org                           ////
////                                                             ////
////  D/L from: http://www.opencores.org/cores/hamming/          ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2004      Soner Yesil & Burak Okcan           ////
////                         soneryesil@opencores.org            ////
////                         burakokcan@opencores.org		 ////
////		                                    		 ////
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
M is the 4-bit message M=[m1 m2 m3 m4]
G is the generator matrix
	
		1110000
	G =   1001100
		0101010
		1101001
and C is the corresponding codeword C=[c1 c2 c3 c4 c5 c6 c7];


2.Functionality:
================

WISHBONE SIGNALS
----------------

CLK_I		: Posedge clock.
RST_I  	: Active HIGH synchronous reset.

#Slave signals:

STB_I		: Active HIGH.
DAT_I[7:0]	: Message input, valid when STB_I, CYC_I and WE_I are HIGH. DAT_I[7:4] is ignored.
DAT_O[7:0]	: Codeword. Can be monitored by a master module when WE_I is LOW. DAT_O[7] is not used.
ADR_I		: Not Used
ACK_O		: Acknowledge signal: Ready for new data when ACK_O is HIGH.
WE_I		: Encoding is performed when WE_I is HIGH. 
CYC_I		: Active HIGH.

NON-WISHBONE SIGNALS
--------------------

CODEWORD[7:0] 	: Codeword. Can be monitored by a master module when WE_I is LOW. CODEWORD[7] is not used.
DV_OUT		: Indicates valid codeword when HIGH.

*/
//////////////////////////////////////////////

module ham_7_4_enc (
CLK_I,
RST_I,

STB_I,
DAT_I,
ADR_I,
WE_I,
CYC_I,
ACK_O,
DAT_O,

CODEWORD,
DV_OUT);

input CLK_I, RST_I;
input STB_I, WE_I, CYC_I;
input [7:0] DAT_I;
input ADR_I;

output [7:0] DAT_O;
output ACK_O;
output [7:0] CODEWORD;
output DV_OUT;


reg DV_OUT;
reg [7:0] DAT_O;


assign CODEWORD = DAT_O;
assign ACK_O = STB_I;

////////////////////////////////////////////////

always@(posedge CLK_I)

if (RST_I)

	DAT_O <= 0;

else 
	if ( (STB_I) && (WE_I) && (CYC_I) )
	begin
	DAT_O[6] <= DAT_I[3] ^ DAT_I[2] ^ DAT_I[0]; 
	DAT_O[5] <= DAT_I[3] ^ DAT_I[1] ^ DAT_I[0];
	DAT_O[4] <= DAT_I[3];
	DAT_O[3] <= DAT_I[2] ^ DAT_I[1] ^ DAT_I[0];
	DAT_O[2] <= DAT_I[2];
	DAT_O[1] <= DAT_I[1];
	DAT_O[0] <= DAT_I[0];
	end

/////////////////////////////////////////////////

always@(posedge CLK_I)
if (RST_I)
	DV_OUT<=0;
else
	DV_OUT<=STB_I;
 
endmodule














