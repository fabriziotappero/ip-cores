///////////////////////////////////////////////////////////////////////////////
// vim:set shiftwidth=3 softtabstop=3 expandtab:
// $Id: input_arbiter.v 2075 2007-08-02 01:40:11Z grg $
//
// Module: input_arbiter.v
// Project: NF2.1
// Description: Goes round-robin around the input queues and services one pkt
//              out of each (if available). Note that this is unfair for queues
//              that always receive small packets since they pile up!
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
  module classifier_arbiter
    #(parameter DATA_WIDTH = 64,
      parameter CTRL_WIDTH=DATA_WIDTH/8,
      parameter UDP_REG_SRC_WIDTH = 2,
      parameter STAGE_NUMBER = 2,
      parameter NUM_QUEUES = 8
      )

   (// --- data path interface
    output reg [63:0]        out_data,
    output reg [7:0]        out_ctrl,
    output reg                         out_wr,
    input                              out_rdy,

    // interface to rx queues
    input  [63:0]            in_data_0,
    input  [7:0]            in_ctrl_0,
    input                              in_wr_0,
    output                             in_rdy_0,

    input  [63:0]            in_data_1,
    input  [7:0]            in_ctrl_1,
    input                              in_wr_1,
    output                             in_rdy_1,

    input  [63:0]            in_data_2,
    input  [7:0]            in_ctrl_2,
    input                              in_wr_2,
    output                             in_rdy_2,

    input  [63:0]            in_data_3,
    input  [7:0]            in_ctrl_3,
    input                              in_wr_3,
    output                             in_rdy_3,

    input  [63:0]            in_data_4,
    input  [7:0]            in_ctrl_4,
    input                              in_wr_4,
    output                             in_rdy_4,

    input  [63:0]            in_data_5,
    input  [7:0]            in_ctrl_5,
    input                              in_wr_5,
    output                             in_rdy_5,

    input  [63:0]            in_data_6,
    input  [7:0]            in_ctrl_6,
    input                              in_wr_6,
    output                             in_rdy_6,

    input  [63:0]            in_data_7,
    input  [7:0]            in_ctrl_7,
    input                              in_wr_7,
    output                             in_rdy_7,


    
    
  
    // --- Misc
    
    input                              reset,
    input                              clk
   );
   

   function integer log2;
      input integer number;
      begin
         log2=0;
         while(2**log2<number) begin
            log2=log2+1;
         end
      end
   endfunction // log2

   // ------------ Internal Params --------
   parameter NUM_QUEUES_WIDTH = log2(NUM_QUEUES);

   parameter NUM_STATES = 1;
   parameter IDLE = 0;
   parameter WR_PKT = 1;

   // ------------- Regs/ wires -----------
   wire [NUM_QUEUES-1:0]               nearly_full;
   wire [NUM_QUEUES-1:0]               empty;
   wire [DATA_WIDTH-1:0]               in_data      [NUM_QUEUES-1:0];
   wire [CTRL_WIDTH-1:0]               in_ctrl      [NUM_QUEUES-1:0];
   wire [NUM_QUEUES-1:0]               in_wr;
   wire [CTRL_WIDTH-1:0]               fifo_out_ctrl[NUM_QUEUES-1:0];
   wire [DATA_WIDTH-1:0]               fifo_out_data[NUM_QUEUES-1:0];
   reg [NUM_QUEUES-1:0]                rd_en;

   wire [NUM_QUEUES_WIDTH-1:0]         cur_queue_plus1;
   reg [NUM_QUEUES_WIDTH-1:0]          cur_queue;
   reg [NUM_QUEUES_WIDTH-1:0]          cur_queue_next;

   reg [NUM_STATES-1:0]                state;
   reg [NUM_STATES-1:0]                state_next;

   reg [CTRL_WIDTH-1:0]                fifo_out_ctrl_prev;
   reg [CTRL_WIDTH-1:0]                fifo_out_ctrl_prev_next;

   wire [CTRL_WIDTH-1:0]               fifo_out_ctrl_sel;
   wire [DATA_WIDTH-1:0]               fifo_out_data_sel;

   reg [DATA_WIDTH-1:0]                out_data_next;
   reg [CTRL_WIDTH-1:0]                out_ctrl_next;
   reg                                 out_wr_next;

   reg                                 eop;

   // ------------ Modules -------------

   generate 
   genvar i;
   for(i=0; i<NUM_QUEUES; i=i+1) begin: in_arb_queues
      small_fifo
        #( .WIDTH(DATA_WIDTH+CTRL_WIDTH),
           .MAX_DEPTH_BITS(8),
           .NEARLY_FULL(8**2-4))
      in_arb_fifo
        (// Outputs
         .dout                           ({fifo_out_ctrl[i], fifo_out_data[i]}),
         .full                           (),
         .nearly_full                    (nearly_full[i]),
         .empty                          (empty[i]),
         // Inputs
         .din                            ({in_ctrl[i], in_data[i]}),
         .wr_en                          (in_wr[i]),
         .rd_en                          (rd_en[i]),
         .reset                          (reset),
         .clk                            (clk));
   end // block: in_arb_queues
   endgenerate

  
   // ------------- Logic ------------

   assign in_data[0]         = in_data_0;
   assign in_ctrl[0]         = in_ctrl_0;
   assign in_wr[0]           = in_wr_0;
   assign in_rdy_0           = !nearly_full[0];

   assign in_data[1]         = in_data_1;
   assign in_ctrl[1]         = in_ctrl_1;
   assign in_wr[1]           = in_wr_1;
   assign in_rdy_1           = !nearly_full[1];

   assign in_data[2]         = in_data_2;
   assign in_ctrl[2]         = in_ctrl_2;
   assign in_wr[2]           = in_wr_2;
   assign in_rdy_2           = !nearly_full[2];

   assign in_data[3]         = in_data_3;
   assign in_ctrl[3]         = in_ctrl_3;
   assign in_wr[3]           = in_wr_3;
   assign in_rdy_3           = !nearly_full[3];

   assign in_data[4]         = in_data_4;
   assign in_ctrl[4]         = in_ctrl_4;
   assign in_wr[4]           = in_wr_4;
   assign in_rdy_4           = !nearly_full[4];

   assign in_data[5]         = in_data_5;
   assign in_ctrl[5]         = in_ctrl_5;
   assign in_wr[5]           = in_wr_5;
   assign in_rdy_5           = !nearly_full[5];

   assign in_data[6]         = in_data_6;
   assign in_ctrl[6]         = in_ctrl_6;
   assign in_wr[6]           = in_wr_6;
   assign in_rdy_6           = !nearly_full[6];

   assign in_data[7]         = in_data_7;
   assign in_ctrl[7]         = in_ctrl_7;
   assign in_wr[7]           = in_wr_7;
   assign in_rdy_7           = !nearly_full[7];

   /* disable regs for this module */
   assign cur_queue_plus1    = (cur_queue == NUM_QUEUES-1) ? 0 : cur_queue + 1;

   assign fifo_out_ctrl_sel  = fifo_out_ctrl[cur_queue];
   assign fifo_out_data_sel  = fifo_out_data[cur_queue];

   always @(*) begin
      state_next     = state;
      cur_queue_next = cur_queue;
      fifo_out_ctrl_prev_next = fifo_out_ctrl_prev;
      out_wr_next    = 0;
      out_ctrl_next  = fifo_out_ctrl_sel;
      out_data_next  = fifo_out_data_sel;
      rd_en          = 0;
      eop            = 0;
      
      case(state)

        /* cycle between input queues until one is not empty */
        IDLE: begin
           if(!empty[cur_queue] && out_rdy) begin
              state_next = WR_PKT;
              rd_en[cur_queue] = 1;
              fifo_out_ctrl_prev_next = STAGE_NUMBER;
           end
           if(empty[cur_queue] && out_rdy) begin
              cur_queue_next = cur_queue_plus1;
           end
        end

        /* wait until eop */
        WR_PKT: begin
           /* if this is the last word then write it and get out */
           if(out_rdy & |fifo_out_ctrl_sel & (fifo_out_ctrl_prev==0) ) begin
              out_wr_next = 1;
              state_next = IDLE;
              cur_queue_next = cur_queue_plus1;
              eop = 1;
           end
           /* otherwise read and write as usual */
           else if (out_rdy & !empty[cur_queue]) begin
              fifo_out_ctrl_prev_next = fifo_out_ctrl_sel;
              out_wr_next = 1;
              rd_en[cur_queue] = 1;
           end
        end // case: WR_PKT

      endcase // case(state)
   end // always @ (*)

   always @(posedge clk) begin
      if(reset) begin
         state <= IDLE;
         cur_queue <= 0;
         fifo_out_ctrl_prev <= 1;
         out_wr <= 0;
         out_ctrl <= 1;
         out_data <= 0;
      end
      else begin
         state <= state_next;
         cur_queue <= cur_queue_next;
         fifo_out_ctrl_prev <= fifo_out_ctrl_prev_next;
         out_wr <= out_wr_next;
         out_ctrl <= out_ctrl_next;
         out_data <= out_data_next;
      end
   end

endmodule // input_arbiter

// Local Variables:
// verilog-library-directories:(".")
// End:
