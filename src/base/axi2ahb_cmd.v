<##//////////////////////////////////////////////////////////////////
////                                                             ////
////  Author: Eyal Hochberg                                      ////
////          eyal@provartec.com                                 ////
////                                                             ////
////  Downloaded from: http://www.opencores.org                  ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2010 Provartec LTD                            ////
//// www.provartec.com                                           ////
//// info@provartec.com                                          ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
//// This source file is free software; you can redistribute it  ////
//// and/or modify it under the terms of the GNU Lesser General  ////
//// Public License as published by the Free Software Foundation.////
////                                                             ////
//// This source is distributed in the hope that it will be      ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied  ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR     ////
//// PURPOSE.  See the GNU Lesser General Public License for more////
//// details. http://www.gnu.org/licenses/lgpl.html              ////
////                                                             ////
//////////////////////////////////////////////////////////////////##>

OUTFILE PREFIX_cmd.v
  
INCLUDE def_axi2ahb.txt

module  PREFIX_cmd (PORTS);

   input 		  clk;
   input                  reset;

   port                   AWGROUP_AXI_A;
   port                   ARGROUP_AXI_A;
   input                  GROUP_AHB;
         
   input                  ahb_finish;
   output                 cmd_empty;
   output                 cmd_read;
   output [ID_BITS-1:0]   cmd_id;
   output [ADDR_BITS-1:0] cmd_addr;
   output [3:0]           cmd_len;
   output [1:0]           cmd_size;
   output                 cmd_err;
    
   
   wire                   AGROUP_AXI_A;
   
   wire                   cmd_push;
   wire                   cmd_pop;
   wire                   cmd_empty;
   wire                   cmd_full;
   reg                    read;
   wire                   err;

   
   wire                   wreq, rreq;
   wire                   wack, rack;
   wire                   AERR;
   
   assign                 wreq = AWVALID;
   assign                 rreq = ARVALID;
   assign                 wack = AWVALID & AWREADY;
   assign                 rack = ARVALID & ARREADY;
        
   always @(posedge clk or posedge reset)
     if (reset)
       read <= #FFD 1'b1;
     else if (wreq & (rack | (~rreq)))
       read <= #FFD 1'b0;
     else if (rreq & (wack | (~wreq)))
       read <= #FFD 1'b1;

	//command mux
	assign AGROUP_AXI_A = read ? ARGROUP_AXI_A : AWGROUP_AXI_A;
   
   assign ARREADY = (~cmd_full) & read;
   assign AWREADY = (~cmd_full) & (~read);

   assign err = 
          ((ALEN != 4'd0) & 
           (ALEN != 4'd3) & 
           (ALEN != 4'd7) & 
           (ALEN != 4'd15)) |
          (((ASIZE == 2'b01) & (AADDR[0] != 1'b0)) |
           ((ASIZE == 2'b10) & (AADDR[1:0] != 2'b00)) |
           ((ASIZE == 2'b11) & (AADDR[2:0] != 3'b000)));
   
   
   
    assign 		      cmd_push  = AVALID & AREADY;
    assign 		      cmd_pop   = ahb_finish;
   
CREATE prgen_fifo.v DEFCMD(SWAP CONST(#FFD) #FFD)
   prgen_fifo #(ID_BITS+ADDR_BITS+4+2+1+1, CMD_DEPTH) 
   cmd_fifo(
	    .clk(clk),
	    .reset(reset),
	    .push(cmd_push),
	    .pop(cmd_pop),
	    .din({
		  AID,
		  AADDR,
                  ALEN,
                  ASIZE,
		  read,
                  err
		  }
		 ),
	    .dout({
		   cmd_id,
		   cmd_addr,
                   cmd_len,
                   cmd_size,
		   cmd_read,
                   cmd_err
		   }
		  ),
	    .empty(cmd_empty),
	    .full(cmd_full)
	    );

		
   
endmodule


