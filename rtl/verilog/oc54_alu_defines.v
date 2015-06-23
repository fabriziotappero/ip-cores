/////////////////////////////////////////////////////////////////////
////                                                             ////
////  OpenCores54 DSP, ALU defines                               ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////          www.asics.ws                                       ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2002 Richard Herveille                        ////
////                    richard@asics.ws                         ////
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
//  $Id: oc54_alu_defines.v,v 1.1.1.1 2002-04-10 09:34:40 rherveille Exp $														     
//																     
//  $Date: 2002-04-10 09:34:40 $														 
//  $Revision: 1.1.1.1 $													 
//  $Author: rherveille $													     
//  $Locker:  $													     
//  $State: Exp $														 
//																     
// Change History:												     
//               $Log: not supported by cvs2svn $											 
																

//
// Encoding: bit[6] always zero
//           bit[5:4] instuction type
//           - 00: (dual) arithmetic
//           - 01: logical (incl. shift)
//           - 10: bit-test & compare
//           - 11: reserved
// Leonardo-Spectrum seems to like the additional zero bit[6] in
// the encoding scheme. It produces the smallest and fastest code 
// like this. (Why ???)
//

//
// arithmetic instructions
//
`define ABS      7'b000_0000
`define NEG      7'b000_0001
`define ADD      7'b000_0010
`define SUB      7'b000_0011
`define MAX      7'b000_0100
`define SUBC     7'b000_0101

//
// dual arithmetic instructions
//
`define DADD     7'b000_1000
`define DSUB     7'b000_1100
`define DRSUB    7'b000_1101
`define DSUBADD  7'b000_1110
`define DADDSUB  7'b000_1001

//
// logical instructions
//
`define NOT      7'b001_0000
`define AND      7'b001_0001
`define OR       7'b001_0010
`define XOR      7'b001_0011

//
// shift instructions
//
`define ROL      7'b001_0100
`define ROLTC    7'b001_0101
`define ROR      7'b001_0110
`define SHFT_CMP 7'b001_0111

//
// bit test instructions
//
`define BITF     7'b010_0000
`define BTST     7'b010_0001
`define CMP_EQ   7'b010_0100
`define CMP_LT   7'b010_0101
`define CMP_GT   7'b010_0110
`define CMP_NEQ  7'b010_0111

//
// condition codes for CMP-test
//
`define EQ  2'b00
`define LT  2'b01
`define GT  2'b10
`define NEQ 2'b11

