//----------------------------------------------------------------------
//  Scoreboard
//
// Keeps track of data regarding N items.  Allows multiple entities
// to track data about a particular item.  Supports masked writes,
// allowing only part of a record to be updated by a particular
// transaction.
//
// Naming convention: c = consumer, p = producer, i = internal interface
//----------------------------------------------------------------------
//  Author: Guy Hutchison
//
// This block is uncopyrighted and released into the public domain.
//----------------------------------------------------------------------

module sd_scoreboard
  #(parameter width=8,
    parameter items=64,
    parameter use_txid=0,
    parameter use_mask=0,
    parameter txid_sz=2,
    parameter asz=6)  //log2(items))
  (input      clk,
   input      reset,

   input      c_srdy,
   output     c_drdy,
   input      c_req_type, // 0=read, 1=write
   input [txid_sz-1:0] c_txid,
   input [width-1:0] c_mask,
   input [width-1:0] c_data,
   input [asz-1:0]   c_itemid,

   output     p_srdy,
   input      p_drdy,
   output [txid_sz-1:0] p_txid,
   output [width-1:0]   p_data
   );

  localparam tot_in_sz = ((use_mask)?width*2:width)+
                         ((use_txid)?txid_sz:0)+asz+1;
  
  wire                  ip_req_type; // 0=read, 1=write
  wire [txid_sz-1:0]    ip_txid;
  wire [width-1:0]      ip_mask;
  wire [width-1:0]      ip_data;
  wire [asz-1:0]        ip_itemid;
  wire [txid_sz-1:0]    ic_txid;
  wire [width-1:0]      ic_data;
  
  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  wire [(asz)-1:0]      addr;                   // From fsm of sd_scoreboard_fsm.v
  wire [(width)-1:0]    d_in;                   // From fsm of sd_scoreboard_fsm.v
  wire [(width)-1:0]    d_out;                  // From sb_mem of behave1p_mem.v
  wire                  ic_drdy;                // From outhold of sd_output.v
  wire                  ic_srdy;                // From fsm of sd_scoreboard_fsm.v
  wire                  ip_drdy;                // From fsm of sd_scoreboard_fsm.v
  wire                  ip_srdy;                // From inhold of sd_input.v
  wire                  rd_en;                  // From fsm of sd_scoreboard_fsm.v
  wire                  wr_en;                  // From fsm of sd_scoreboard_fsm.v
  // End of automatics

  wire [tot_in_sz-1:0]  c_hold_data, p_hold_data;
  
  generate if ((use_txid == 1) && (use_mask == 1))
    begin : txid_and_mask
      assign c_hold_data = {c_txid,c_req_type,c_itemid,c_mask,c_data};
      assign {ip_txid,ip_req_type,ip_itemid,ip_mask,ip_data} = p_hold_data;
    end
  else if ((use_txid == 0) && (use_mask == 1))
    begin : no_txid_and_mask
      assign c_hold_data = {c_req_type,c_itemid,c_mask,c_data};
      assign {ip_req_type,ip_itemid,ip_mask,ip_data} = p_hold_data;
      assign ip_txid = 0;
    end
  else if ((use_txid == 1) && (use_mask == 0))
    begin : txid_and_no_mask
      assign c_hold_data = {c_txid,c_req_type,c_itemid,c_data};
      assign {ip_txid,ip_req_type,ip_itemid,ip_data} = p_hold_data;
      assign ip_mask = 0;
    end
  else if ((use_txid == 0) && (use_mask == 0))
    begin : no_txid_no_mask
      assign c_hold_data = {c_req_type,c_itemid,c_data};
      assign {ip_req_type,ip_itemid,ip_data} = p_hold_data;
      assign ip_mask = 0;
      assign ip_txid = 0;
    end
  endgenerate
  
  sd_input #(.width(tot_in_sz)) inhold
    (
     .c_data     (c_hold_data),
     .ip_data    (p_hold_data),
     /*AUTOINST*/
     // Outputs
     .c_drdy                            (c_drdy),
     .ip_srdy                           (ip_srdy),
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .c_srdy                            (c_srdy),
     .ip_drdy                           (ip_drdy));

  behave1p_mem #(.depth(items),
                 .addr_sz               (asz), /*AUTOINSTPARAM*/
                 // Parameters
                 .width                 (width)) sb_mem
    (
     .addr                              (addr[asz-1:0]),
     /*AUTOINST*/
     // Outputs
     .d_out                             (d_out[(width)-1:0]),
     // Inputs
     .wr_en                             (wr_en),
     .rd_en                             (rd_en),
     .clk                               (clk),
     .d_in                              (d_in[(width)-1:0]));

  sd_scoreboard_fsm #(/*AUTOINSTPARAM*/
                      // Parameters
                      .width            (width),
                      .items            (items),
                      .use_txid         (use_txid),
                      .use_mask         (use_mask),
                      .txid_sz          (txid_sz),
                      .asz              (asz)) fsm
    (/*AUTOINST*/
     // Outputs
     .ip_drdy                           (ip_drdy),
     .ic_srdy                           (ic_srdy),
     .ic_txid                           (ic_txid[(txid_sz)-1:0]),
     .ic_data                           (ic_data[(width)-1:0]),
     .wr_en                             (wr_en),
     .rd_en                             (rd_en),
     .d_in                              (d_in[(width)-1:0]),
     .addr                              (addr[(asz)-1:0]),
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .ip_srdy                           (ip_srdy),
     .ip_req_type                       (ip_req_type),
     .ip_txid                           (ip_txid[(txid_sz)-1:0]),
     .ip_mask                           (ip_mask[(width)-1:0]),
     .ip_data                           (ip_data[(width)-1:0]),
     .ip_itemid                         (ip_itemid[(asz)-1:0]),
     .ic_drdy                           (ic_drdy),
     .d_out                             (d_out[(width)-1:0]));

  sd_output #(.width(width+txid_sz)) outhold
    (
     .p_data                            ({p_txid,p_data}),
     .ic_data                           ({ic_txid,ic_data}),
     /*AUTOINST*/
     // Outputs
     .ic_drdy                           (ic_drdy),
     .p_srdy                            (p_srdy),
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .ic_srdy                           (ic_srdy),
     .p_drdy                            (p_drdy));

endmodule // sd_scoreboard
// Local Variables:
// verilog-library-directories:("." "../closure" "../memory")
// End:  

   
