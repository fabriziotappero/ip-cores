///////////////////////////////////////////////////////////////////////////////////////////////
////                                                                                           
////   file name:    z80_sram.v                                                                             
////   description: simple static SRAM                                                                                    
////   project:     wb_z80
////
////
////   Author: B.J. Porcella                                                                   
////          bporcella@sbcglobal.net                                                          
////                                                                                           
////                                                                                           
////                                                                                           
///////////////////////////////////////////////////////////////////////////////////////////////
////                                                                                           
//// Copyright (C) 2000-2002 B.J. Porcella                                                     
////                         Real Time Solutions                                               
////                                                                                           
////                                                                                           
//// This source file may be used and distributed without                                      
//// restriction provided that this copyright statement is not                                 
//// removed from the file and that any derivative work contains                               
//// the original copyright notice and the associated disclaimer.                              
////                                                                                           
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY                                   
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED                                 
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS                                 
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR                                    
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,                                       
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES                                  
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE                                 
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR                                      
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF                                
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT                                
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT                                
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE                                       
//// POSSIBILITY OF SUCH DAMAGE.                                                               
////                                                                                           
///////////////////////////////////////////////////////////////////////////////////////////////
//
//  DESCRIPTION:
//  This file was intended to be a generic sram module  -- and started out as generic_spram.v
//  However,  the generic_spram.v device contained not only an address register, but also a 
//  data register.   I guess in retrospect that I could design around that ----   by deleting the
//  address register of the z80 and also the data output register of the z80 and use the 
//  registers of the "generic_spram" for those functions.   
//
//  I have opted to hack my own model of a register array.  
//  (which I know can be reasonably synthesized in most technologies).   
//  Accordingly, I decided to re-name the file   -- it is very different 
//  in its behavior  --  there should be no mis-understanding here.
//
//  If this actually causes synthesis problems, please let me know.  I will try to help.
//   bj
//  
//
//
//  CVS Log
//
//  $Id: z80_sram.v,v 1.1 2004-05-27 14:28:55 bporcella Exp $
//
//  $Date: 2004-05-27 14:28:55 $
//  $Revision: 1.1 $
//  $Author: bporcella $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//      $Log: not supported by cvs2svn $
//      Revision 1.1.1.1  2004/04/13 23:47:42  bporcella
//      import first files
//
//
//
//-------1---------2---------3--------Module Name and Port List------7---------8---------9--------0

module z80_sram(
    // Generic synchronous single-port RAM interface
    clk, rst, ce, we, oe, addr, di, do
);

    //
    // Default address and data buses width
    //
    parameter aw = 15; //number of address-bits
    parameter dw = 8; //number of data-bits

    //
    // Generic synchronous single-port RAM interface
    //


//-------1---------2---------3--------Output Ports---------6---------7---------8---------9--------0
    output [dw-1:0] do;   // output data bus

//-------1---------2---------3--------Input Ports----------6---------7---------8---------9--------0
    input           clk;  // Clock, rising edge
    input           rst;  // Reset, active high
    input           ce;   // Chip enable input, active high
    input           we;   // Write enable input, active high
    input           oe;   // Output enable input, active high
    input  [aw-1:0] addr; // address bus inputs
    input  [dw-1:0] di;   // input data bus
//-------1---------2---------3--------Parameters-----------6---------7---------8---------9--------0
//-------1---------2---------3--------Wires------5---------6---------7---------8---------9--------0
//-------1---------2---------3--------Registers--5---------6---------7---------8---------9--------0
//-------1---------2---------3--------Assignments----------6---------7---------8---------9--------0
//-------1---------2---------3--------State Machines-------6---------7---------8---------9--------0


reg  [dw-1:0] mem [(1<<aw)-1:0];    // RAM content

// bjp  change  was
//reg  [aw-1:0] raddr;             // RAM read address
//wire raddr = addr;
//
// Data output drivers
//
assign do =  mem[addr];



// write operation
always@(posedge clk)
    if (ce && we)
        mem[addr] <=  di;



endmodule
