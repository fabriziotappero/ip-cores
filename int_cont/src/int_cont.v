/* Processor Interupt Controller
   SXP Processor
   Sam Gladstone

   See int_cont.txt in doc directory for more information.

*/

module int_cont (
		clk,		// system clock
		reset_b,	// system reset
                halt,		// processor halt signal
                int_req,	// signal that an interupt is requested
		int_num,	// interupt number that is being requested
                nop_detect,	// signal that the processor just executed a NOP instruction

                int_rdy,	// 1 when int req will be serviced when requested 
                idle,		// signal to idle processor;
                jal_req,	// signal to fetch to insert the JAL instruction
		int_srv_req,	// signal that the interupt was serviced 
                int_srv_num);	// interupt number that was serviced


input clk;
input reset_b;
input halt;
input int_req;
input [15:0] int_num;
input nop_detect;

output int_rdy;
output idle;
output int_srv_req;
output jal_req;
output [15:0] int_srv_num;


// Internal signals

reg [1:0] state;
reg [1:0] next_state;
reg [1:0] nop_cnt;
reg [15:0] r_int_num;

// Sets int_rdy low if we are servicing an interupt (no additional interupts will be serviced at this time)
assign int_rdy = !state;

// Sets the idle signal when state is in idle mode
assign idle = (state == 2'b 01) ? 1'b 1 : 1'b 0;

// Counts the number of NOPs when we are in idle mode
always @(posedge clk or negedge reset_b)
  begin
    if (!reset_b)
      nop_cnt <= 'b 0;
    else
      if (!idle)
        nop_cnt <= 'b 0;
      else
        if (nop_detect && !halt)
          if (nop_cnt != 2'b 11)
            nop_cnt <= nop_cnt + 1'b 1;
  end
 
// Records the interupt that we are working on
always @(posedge clk or negedge reset_b)
  begin
    if (!reset_b)
      r_int_num <= 'b 0;
    else
      if (int_req) 
        r_int_num <= int_num;
  end 

// Signals external interupt controller that int_cont is servicing an interupt
assign int_srv_num = r_int_num;
assign int_srv_req = |state; 

// Submit JAL instruction request to processor
assign jal_req = (state == 2'b 10) ? 1'b 1 : 1'b 0;


// assign next state to state 
always @(posedge clk or negedge reset_b)
  begin
    if (!reset_b)
      state <= 'b 0;
    else
      if (!halt)
        state <= next_state;
  end

always @(int_req or nop_cnt or state)
  begin
    case (state)
      // init state
      2'b 00 : if (int_req)
                 next_state = 2'b 01;
               else
                 next_state = 2'b 00;

      // start idleling of processor (wait for 4 NOPs)             
      2'b 01 : if (&nop_cnt)
                 next_state = 2'b 10;
               else
                 next_state = 2'b 01;

      // submit JAL instruction
      2'b 10 : next_state = 2'b 00;
 
      // If unknown state is found then go to init state 
      default : next_state = 2'b 00;
    endcase
  end

endmodule
     
/*    
 *  $Id: int_cont.v,v 1.3 2001-12-14 17:04:52 samg Exp $ 
 *  Module : int_cont
 *  Author : Sam Gladstone
 *  Function : SXP internal interupt controller
 *             (An external one might be needed as well) 
 *  $Log: not supported by cvs2svn $
 *  Revision 1.2  2001/12/05 05:44:26  samg
 *  changed prefix from ~| to ! (same thing)
 *
 *  Revision 1.1  2001/10/26 21:53:55  samg
 *  interupt controller module
 *
 */
