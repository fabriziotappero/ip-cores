module packet_buffer
  (
   input          clk,
   input          reset,

   input [3:0]    pbra_srdy,
   output [3:0]   pbra_drdy,
   input [`PBR_SZ-1:0] pbra_data_0,            // From p0 of port_macro.v
   input [`PBR_SZ-1:0] pbra_data_1,            // From p1 of port_macro.v
   input [`PBR_SZ-1:0] pbra_data_2,            // From p2 of port_macro.v
   input [`PBR_SZ-1:0] pbra_data_3,            // From p3 of port_macro.v
   input [`PBR_SZ-1:0] pbrd_data_0,            // From p0 of port_macro.v
   input [`PBR_SZ-1:0] pbrd_data_1,            // From p1 of port_macro.v
   input [`PBR_SZ-1:0] pbrd_data_2,            // From p2 of port_macro.v
   input [`PBR_SZ-1:0] pbrd_data_3,            // From p3 of port_macro.v
   input [3:0]    pbrd_srdy,
   output [3:0]   pbrd_drdy,

   output [3:0]   pbrr_srdy,
   input [3:0]    pbrr_drdy,
   output [`PFW_SZ-1:0]  pbrr_data
   );

  wire [`PBR_SZ-1:0]     pbi_data;
  wire [`NUM_PORTS*2-1:0] pbi_grant;
  wire                    pbi_srdy;
  wire                    pbi_drdy;

  wire                    pbo_srdy;
  wire                    pbo_drdy;
  wire [`PORT_ASZ-1:0]    pbo_portnum;
  wire [`PFW_SZ-1:0]      pbo_data;
  wire [`NUM_PORTS-1:0]   pbo_portsel;

  assign pbo_portsel = 1 << pbo_portnum;

  sd_rrmux #(
              // Parameters
              .width                    (`PBR_SZ),
              .inputs                   (`NUM_PORTS*2),
              .mode                     (0),
              .fast_arb                 (1)) fib_arb
    (
     // Outputs
     .p_data                            (pbi_data[`PBR_SZ-1:0]),
     .p_grant                           (pbi_grant[(`NUM_PORTS*2)-1:0]),
     .p_srdy                            (pbi_srdy),
     // Inputs
     .clk                               (clk),
     .reset                             (reset),

     .c_data   ({pbra_data_3,pbra_data_2,pbra_data_1,pbra_data_0,
                 pbrd_data_3,pbrd_data_2,pbrd_data_1,pbrd_data_0}),
     .c_srdy                            ({pbra_srdy,pbrd_srdy}),
     .c_drdy                            ({pbra_drdy,pbrd_drdy}),
     
     .c_rearb                           (1'b1),
     .p_drdy                            (pbi_drdy));
  
  sd_scoreboard #(
                  // Parameters
                  .width                (`PFW_SZ),
                  .items                (`PB_DEPTH),
                  .use_txid             (1),
                  .use_mask             (0),
                  .txid_sz              (`PORT_ASZ),
                  .asz                  (`PB_ASZ)) pbmem
    (
     // Outputs
     .c_drdy                            (pbi_drdy),
     .p_srdy                            (pbo_srdy),
     .p_txid                            (pbo_portnum),
     .p_data                            (pbo_data),
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .c_srdy                            (pbi_srdy),
     .c_req_type                        (pbi_data[`PBR_WRITE]),
     .c_txid                            (pbi_data[`PBR_PORT]),
     .c_mask                            ({`PFW_SZ{1'b1}}),
     .c_data                            (pbi_data[`PBR_DATA]),
     .c_itemid                          (pbi_data[`PBR_ADDR]),
     .p_drdy                            (pbo_drdy));

  sd_mirror #(.mirror (`NUM_PORTS), .width(`PFW_SZ)) pbo_mirror
    (
     // Outputs
     .c_drdy                            (pbo_drdy),
     .p_srdy                            (pbrr_srdy),
     .p_data                            (pbrr_data),
     // Inputs
     .clk                               (clk),
     .reset                             (reset),
     .c_srdy                            (pbo_srdy),
     .c_data                            (pbo_data),
     .c_dst_vld                         (pbo_portsel),
     .p_drdy                            (pbrr_drdy));

endmodule // packet_buffer
// Local Variables:
// verilog-library-directories:("." "../../../rtl/verilog/closure" "../../../rtl/verilog/buffers" "../../../rtl/verilog/utility" "../../../rtl/verilog/forks")
// End:  
