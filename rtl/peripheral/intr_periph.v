//-----------------------------------------------------------------
//                           AltOR32 
//                Alternative Lightweight OpenRisc 
//                            V2.0
//                     Ultra-Embedded.com
//                   Copyright 2011 - 2013
//
//               Email: admin@ultra-embedded.com
//
//                       License: LGPL
//-----------------------------------------------------------------
//
// Copyright (C) 2011 - 2013 Ultra-Embedded.com
//
// This source file may be used and distributed without         
// restriction provided that this copyright statement is not    
// removed from the file and that any derivative work contains  
// the original copyright notice and the associated disclaimer. 
//
// This source file is free software; you can redistribute it   
// and/or modify it under the terms of the GNU Lesser General   
// Public License as published by the Free Software Foundation; 
// either version 2.1 of the License, or (at your option) any   
// later version.
//
// This source is distributed in the hope that it will be       
// useful, but WITHOUT ANY WARRANTY; without even the implied   
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
// PURPOSE.  See the GNU Lesser General Public License for more 
// details.
//
// You should have received a copy of the GNU Lesser General    
// Public License along with this source; if not, write to the 
// Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
// Boston, MA  02111-1307  USA
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// Includes
//-----------------------------------------------------------------
`include "intr_defs.v"

//-----------------------------------------------------------------
// Module:
//-----------------------------------------------------------------
module intr_periph
(
    // General - Clocking & Reset
    clk_i,
    rst_i,
    intr_o,

    // Interrupts
    intr0_i,
    intr1_i,
    intr2_i,
    intr3_i,
    intr4_i,
    intr5_i,
    intr6_i,
    intr7_i,
    intr_ext_i,

    // Peripheral bus
    addr_i,
    data_o,
    data_i,
    we_i,
    stb_i
);

//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
parameter           EXTERNAL_INTERRUPTS = 1;
parameter           INTERRUPT_COUNT     = EXTERNAL_INTERRUPTS + 8;

//-----------------------------------------------------------------
// I/O
//-----------------------------------------------------------------
input               clk_i /*verilator public*/;
input               rst_i /*verilator public*/;
output              intr_o /*verilator public*/;

input               intr0_i /*verilator public*/;
input               intr1_i /*verilator public*/;
input               intr2_i /*verilator public*/;
input               intr3_i /*verilator public*/;
input               intr4_i /*verilator public*/;
input               intr5_i /*verilator public*/;
input               intr6_i /*verilator public*/;
input               intr7_i /*verilator public*/;
input [(EXTERNAL_INTERRUPTS - 1):0] intr_ext_i /*verilator public*/;
input [7:0]         addr_i /*verilator public*/;
output [31:0]       data_o /*verilator public*/;
input [31:0]        data_i /*verilator public*/;
input               we_i /*verilator public*/;
input               stb_i /*verilator public*/;

//-----------------------------------------------------------------
// Registers / Wires
//-----------------------------------------------------------------
reg [31:0]                  data_o;
reg                         intr_o;

// IRQ Status
wire                        intr_in;
reg [INTERRUPT_COUNT-1:0]   irq_status;
reg [INTERRUPT_COUNT-1:0]   irq_mask;
reg [INTERRUPT_COUNT-1:0]   v_irq_status;

//-----------------------------------------------------------------
// Peripheral Register Write
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
   begin
       irq_status       <= {(INTERRUPT_COUNT){1'b0}};
       irq_mask         <= {(INTERRUPT_COUNT){1'b0}};
       intr_o           <= 1'b0;
   end
   else
   begin

       // Get current IRQ status
       v_irq_status = irq_status;

       // IRQ0
       if (intr0_i == 1'b1)
           v_irq_status[0] = 1'b1;

       // IRQ1
       if (intr1_i == 1'b1)
           v_irq_status[1] = 1'b1;

       // IRQ2
       if (intr2_i == 1'b1)
           v_irq_status[2] = 1'b1;

       // IRQ3
       if (intr3_i == 1'b1)
           v_irq_status[3] = 1'b1;

       // IRQ4
       if (intr4_i == 1'b1)
           v_irq_status[4] = 1'b1;

       // IRQ5
       if (intr5_i == 1'b1)
           v_irq_status[5] = 1'b1;

       // IRQ6
       if (intr6_i == 1'b1)
           v_irq_status[6] = 1'b1;

       // IRQ7
       if (intr7_i == 1'b1)
           v_irq_status[7] = 1'b1;

       // External interrupts
       begin : ext_ints_loop
           integer i;
           for (i=0; i< EXTERNAL_INTERRUPTS; i=i+1)
           begin
               if (intr_ext_i[i] == 1'b1)
                   v_irq_status[(`IRQ_EXT_FIRST + i)] = 1'b1;
           end
       end      

       // Update IRQ status
       irq_status <= v_irq_status;
       
       // Generate interrupt based on masked status
       intr_o <= ((v_irq_status & irq_mask) != {(INTERRUPT_COUNT){1'b0}}) ? 1'b1 : 1'b0;       

       // Write Cycle
       if (we_i & stb_i)
       begin
           case (addr_i)

           `IRQ_MASK_SET :
                irq_mask    <= (irq_mask | data_i[INTERRUPT_COUNT-1:0]);

           `IRQ_MASK_CLR :
                irq_mask    <= (irq_mask & ~ (data_i[INTERRUPT_COUNT-1:0]));

           `IRQ_STATUS : // (IRQ Acknowledge)
                irq_status  <= (v_irq_status & ~ (data_i[INTERRUPT_COUNT-1:0]));

           default :
               ;
           endcase
        end
   end
end

//-----------------------------------------------------------------
// Peripheral Register Read
//-----------------------------------------------------------------
always @ *
begin
   case (addr_i[7:0])

   `IRQ_MASK_SET :
        data_o = {{(32-INTERRUPT_COUNT){1'b0}}, irq_mask};

   `IRQ_MASK_CLR :
        data_o = {{(32-INTERRUPT_COUNT){1'b0}}, irq_mask};

   `IRQ_STATUS :
        data_o = {{(32-INTERRUPT_COUNT){1'b0}}, irq_status};

   default :
        data_o = 32'h00000000;
   endcase
end

endmodule
