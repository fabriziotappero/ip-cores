/*
   fetch module (program flow control)
   SXP processor
   Sam Gladstone

*/

module fetch 
		(clk,			// system clock
		 reset_b,		// system reset
    		 stall,			// stall for fetch
		 set_pc,		// signal to set the program counter
		 pc_init,		// value to set the program counter to 
		 mem_inst,		// instruction that was read from memory
		 idle,			// idles the processor with NOP instructions 
                 jal_req,		// request to JAL for an interupt
                 int_srv_num,		// interupt number for vector jump

		 int_jal_req,		// interupt JAL request signal (for instructions)
		 mem_pc,		// address to get from memory 
 		 pcn,			// pc + 1 (used for jump arithmetic)
		 flush_pipeline,	// invalidate all pipelines (jumps need to cause this do this)
    		 inst_vld,		// nstruction valid flag
		 inst);			// instruction to be sent to pipeline


input clk;
input reset_b;
input stall;
input set_pc;
input [31:0] pc_init;
input [31:0] mem_inst;
input idle;
input jal_req;
input [15:0] int_srv_num;

output [31:0] mem_pc;
output flush_pipeline;

output int_jal_req;
reg int_jal_req;

output inst_vld;
reg inst_vld;

output [31:0] inst;
reg [31:0] inst;

output [31:0] pcn;
reg [31:0] pcn;

// Internal signals

reg fetch_rdy;
reg [1:0] pc_reset_cnt;
reg inst_rdy;

reg [31:0] old_pc;
reg [31:0] pc;
reg [31:0] pc_lat;

wire [31:0] stall_pc;
wire pc_incr;
reg idle_lat;		// idle latency to insue proper 


// Count to four after reset before begining pc count
always @(posedge clk or negedge reset_b)
  begin
    if (!reset_b)
      begin
        pc_reset_cnt <= 'b 00;
        fetch_rdy <= 'b 0;
      end
    else
      if (&pc_reset_cnt)
        fetch_rdy <= 1'b 1;
      else
        pc_reset_cnt <= pc_reset_cnt + 1'b 1;
  end

// Fast jump wiring
assign mem_pc = (set_pc) ? pc_init : stall_pc;

// Stall memory code handler (Always needed when dealing non-stallable memories)
assign stall_pc = (stall) ? old_pc : pc;
always @(posedge clk or negedge reset_b)
  begin
    if (!reset_b)
      old_pc <= 'b 0;
    else
      if (set_pc)
        old_pc <= pc_init;	// no use keeping the old one (jump is happening)
      else
        if (!stall)
          old_pc <= mem_pc;
  end
// End stall memory code handler

// PC latency register (pcn = pc_lat + 1) 
always @(posedge clk or negedge reset_b)
  begin
    if (!reset_b)
      pc_lat <= 'b 0;
    else 
      pc_lat <= mem_pc;
  end
    

// Set PC or Increment PC 
always @(posedge clk or negedge reset_b)
  begin
    if (!reset_b)
      begin
        pc <= 'b 0;
        inst_rdy <= 1'b 0;
      end
    else
      if (fetch_rdy)
        begin
          inst_rdy <= 1'b 1;
          if (set_pc)
            pc <= pc_init + pc_incr;
          else 
            if (!stall)
              pc <= pc + pc_incr;
        end
  end

assign pc_incr = (idle) ? 1'b 0 : 1'b 1;

always @(posedge clk or negedge reset_b)
  begin
    if (!reset_b)
      idle_lat <= 'b 0;
    else
      if (!stall)
        idle_lat <= idle;
  end

assign flush_pipeline = set_pc;

// set instruction and valid flag 
always @(posedge clk or negedge reset_b)
  begin
    if (!reset_b)
      begin
        inst_vld <= 'b 0;
        inst <= 'b 0;
        pcn <= 'b 0; 
      end
    else
      if (fetch_rdy)
        if (flush_pipeline)
          inst_vld <= 'b 0;
        else
          if (inst_rdy && !stall)
            begin
              inst_vld <= 'b 1;
              if (jal_req)
                inst <= {16'h 581f, int_srv_num};
              else
                if (idle_lat)
                  inst <= 32'h 5800_0000;
                else
                  inst <= mem_inst; 
              int_jal_req <= jal_req; 
              if (jal_req)
                pcn <= pc_lat;
              else
                pcn <= pc_lat + 1'b 1; 
            end
  end

endmodule


/*
 *  $Id: fetch.v,v 1.2 2001-12-12 02:02:21 samg Exp $ 
 *  Module : fetch
 *  Author : Sam Gladstone 
 *  Function : program flow control module
 * 
 *  $Log: not supported by cvs2svn $
 *  Revision 1.1  2001/10/26 21:45:45  samg
 *  fetch module
 *
 * 
 */
