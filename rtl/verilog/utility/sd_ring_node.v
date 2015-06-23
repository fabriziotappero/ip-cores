//----------------------------------------------------------------------
// Single Cycle RING Node [sd_ring_node]
//
// Halts timing on all interfaces, no combinational passthrough
// Inputs are used unregistered
// All outputs are registered
// Four Interfaces
//   RP -> Ring Previous : Ring data arrives on this interface
//   RP -> Ring Next : Ring Data leaves on this interface 
//   P  -> Producer : Destination offload interface
//   C  -> Consumer : Data Injection Interface
//----------------------------------------------------------------------
//
//  Author: Awais Nemat
//
// This block is uncopyrighted and released into the public domain.
//----------------------------------------------------------------------

module sd_ring_node
  #(parameter data_width = 8,
    parameter addr_width = 8,
    parameter my_addr    = 8'h1)
  (
   input                   clk,
   input                   reset,

   input                   rp_srdy, 
   output                  rp_drdy,
   input [data_width-1:0]  rp_data,  
   input [addr_width-1:0]  rp_addr,  

   output                  rn_srdy, 
   input                   rn_drdy,
   output [data_width-1:0] rn_data,  
   output [addr_width-1:0] rn_addr,  

   input                   c_srdy, 
   output                  c_drdy,
   input [data_width-1:0]  c_data,  
   input [addr_width-1:0]  c_addr,  
   
   output                  p_srdy, 
   input                   p_drdy,
   output [data_width-1:0] p_data,  
   output [addr_width-1:0] p_addr  
  );

  // All Combinational Signals
  // reg's  are functions of other signals
  // NOT registered though
  
  wire                     rp_srdy_o; 
  reg                      rp_drdy_i;
  wire [data_width-1:0]    rp_data_o;  
  wire [addr_width-1:0]    rp_addr_o;  

  reg                      rn_srdy_i; 
  wire                     rn_drdy_o;

  wire                     s_srdy_o; 
  reg                      s_drdy_i;
  wire [data_width-1:0]    s_data_o;  
  wire [addr_width-1:0]    s_addr_o;  
  
  reg                      d_srdy_i; 
  wire                     d_drdy_o;
  wire [data_width-1:0]    d_data_i = rp_data_o;  
  wire [addr_width-1:0]    d_addr_i = rp_addr_o; 

  reg                      d; // Asserted if address matches
  reg [data_width-1:0]     data_o; // Mux Selected Data,  S:RP  
  reg [addr_width-1:0]     addr_o; // Mux Selected Adda,  S:RP
  
  always @*
    begin
      // Compute if this module is the Destination
      d = rp_srdy_o & (rp_addr_o == my_addr);

      // Pop data from RP destined to this instance when space is available in 'D'
      // OR when not destined to this instance and space is available in RN 
      rp_drdy_i = (d) ? d_drdy_o : rn_drdy_o ;

      // Indicate data availability to RN, when S has data OR when RP has 
      // data that is NOT Destined to D
      rn_srdy_i = s_srdy_o | (rp_srdy_o & ~d);

      // Indicate data availability to D, when it becomes available in RP
      // and it is destined to this instance
      d_srdy_i  = rp_srdy_o & d;

      // Indicate space availability to S, when it becomes available is RN
      // and there is not Data in RP that needs to be passed on to RN. 

      if ( d & rp_srdy_o & rn_drdy_o ) s_drdy_i = 1; 
      // Exception: When data in RP is destined  to this instance and 
      // space in RN is available, S could transmit to RN
      else if ( rp_srdy_o & rn_drdy_o ) s_drdy_i = 0; 
      // When Data is present in RP and is NOT destined to this instance
      // S cannot transmit to RN. RP has absolute priority over S
      else if (rn_drdy_o) s_drdy_i = 1;
      // No Data is Present in RP and RN has space, S could transmit
      else s_drdy_i = 0;
      // this is the default behaviour <MAY CHANGE; DEADLOCK?>

      // Mux the Data and the Address
      data_o = (s_drdy_i) ? s_data_o : rp_data_o;
      addr_o = (s_drdy_i) ? s_addr_o : rp_addr_o;

    end

  // Instantiate the primitives

  sd_output #(.width  (data_width+addr_width))   
  RN_i0 (.clk(clk),
         .reset (reset),
         .srdy_in(rn_srdy_i), 
         .drdy_in(rn_drdy_o),
         .data_in({addr_o,data_o}),
         .srdy_out(rn_srdy),
         .drdy_out(rn_drdy),
         .data_out({rn_addr,rn_data}));
  
  sd_output #(.width  (data_width+addr_width))   
  D_i0 (.clk(clk),
        .reset (reset),
        .srdy_in(d_srdy_i), 
        .drdy_in(d_drdy_o),
        .data_in({d_addr_i,d_data_i}),
        .srdy_out(p_srdy),
        .drdy_out(p_drdy),
        .data_out({p_addr,p_data}));
  
  sd_input  #(.width  (data_width+addr_width))   
  RP_i0 (.clk(clk),
         .reset (reset),
         .srdy_in(rp_srdy),
         .drdy_in(rp_drdy),
         .data_in({rp_addr,rp_data}),
         .srdy_out(rp_srdy_o),
         .drdy_out(rp_drdy_i),
         .data_out({rp_addr_o,rp_data_o}));
  
  sd_input  #(.width  (data_width+addr_width))   
  S_i0 (.clk(clk),
        .reset (reset),
        .srdy_in(c_srdy),
        .drdy_in(c_drdy),
        .data_in({c_addr,c_data}),
        .srdy_out(s_srdy_o),
        .drdy_out(s_drdy_i),
        .data_out({s_addr_o,s_data_o}));

endmodule
