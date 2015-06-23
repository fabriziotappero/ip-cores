//
// ram_2.v -- main memory, using DDR SDRAM
//


module ram(ddr_clk_0, ddr_clk_90, ddr_clk_180,
           ddr_clk_270, ddr_clk_ok, clk, reset,
           en, wr, size, addr,
           data_in, data_out, wt,
           sdram_ck_p, sdram_ck_n, sdram_cke,
           sdram_cs_n, sdram_ras_n, sdram_cas_n,
           sdram_we_n, sdram_ba, sdram_a,
           sdram_udm, sdram_ldm,
           sdram_udqs, sdram_ldqs, sdram_dq);
    // internal interface signals
    input ddr_clk_0;
    input ddr_clk_90;
    input ddr_clk_180;
    input ddr_clk_270;
    input ddr_clk_ok;
    input clk;
    input reset;
    input en;
    input wr;
    input [1:0] size;
    input [25:0] addr;
    input [31:0] data_in;
    output reg [31:0] data_out;
    output wt;
    // DDR SDRAM interface signals
    output sdram_ck_p;
    output sdram_ck_n;
    output sdram_cke;
    output sdram_cs_n;
    output sdram_ras_n;
    output sdram_cas_n;
    output sdram_we_n;
    output [1:0] sdram_ba;
    output [12:0] sdram_a;
    output sdram_udm;
    output sdram_ldm;
    inout sdram_udqs;
    inout sdram_ldqs;
    inout [15:0] sdram_dq;

  wire [31:0] do;
  reg [31:0] di;
  reg [3:0] wb;
  wire ack;

  ddr_sdram ddr_sdram1(
    .sd_CK_P(sdram_ck_p),
    .sd_CK_N(sdram_ck_n),
    .sd_A_O(sdram_a[12:0]),
    .sd_BA_O(sdram_ba[1:0]),
    .sd_D_IO(sdram_dq[15:0]),
    .sd_RAS_O(sdram_ras_n),
    .sd_CAS_O(sdram_cas_n),
    .sd_WE_O(sdram_we_n),
    .sd_UDM_O(sdram_udm),
    .sd_LDM_O(sdram_ldm),
    .sd_UDQS_IO(sdram_udqs),
    .sd_LDQS_IO(sdram_ldqs),
    .sd_CS_O(sdram_cs_n),
    .sd_CKE_O(sdram_cke),
    .clk0(ddr_clk_0),
    .clk90(ddr_clk_90),
    .clk180(ddr_clk_180),
    .clk270(ddr_clk_270),
    .reset(~ddr_clk_ok),
    .wADR_I(addr[25:2]),
    .wSTB_I(en),
    .wWE_I(wr),
    .wWRB_I(wb[3:0]),
    .wDAT_I(di[31:0]),
    .wDAT_O(do[31:0]),
    .wACK_O(ack)
  );

  // read multiplexer
  always @(*) begin
    case (size[1:0])
      2'b00:
        // byte
        begin
          data_out[31:24] = 8'hxx;
          data_out[23:16] = 8'hxx;
          data_out[15: 8] = 8'hxx;
          if (addr[1] == 0) begin
            if (addr[0] == 0) begin
              data_out[ 7: 0] = do[31:24];
            end else begin
              data_out[ 7: 0] = do[23:16];
            end
          end else begin
            if (addr[0] == 0) begin
              data_out[ 7: 0] = do[15: 8];
            end else begin
              data_out[ 7: 0] = do[ 7: 0];
            end
          end
        end
      2'b01:
        // halfword
        begin
          data_out[31:24] = 8'hxx;
          data_out[23:16] = 8'hxx;
          if (addr[1] == 0) begin
            data_out[15: 8] = do[31:24];
            data_out[ 7: 0] = do[23:16];
          end else begin
            data_out[15: 8] = do[15: 8];
            data_out[ 7: 0] = do[ 7: 0];
          end
        end
      2'b10:
        // word
        begin
          data_out[31:24] = do[31:24];
          data_out[23:16] = do[23:16];
          data_out[15: 8] = do[15: 8];
          data_out[ 7: 0] = do[ 7: 0];
        end
      default:
        // illegal
        begin
          data_out[31:24] = 8'hxx;
          data_out[23:16] = 8'hxx;
          data_out[15: 8] = 8'hxx;
          data_out[ 7: 0] = 8'hxx;
        end
    endcase
  end

  // write multiplexer & data masks
  always @(*) begin
    case (size[1:0])
      2'b00:
        // byte
        begin
          di[31:24] = data_in[ 7: 0];
          di[23:16] = data_in[ 7: 0];
          di[15: 8] = data_in[ 7: 0];
          di[ 7: 0] = data_in[ 7: 0];
          wb[3] = ~addr[1] & ~addr[0];
          wb[2] = ~addr[1] &  addr[0];
          wb[1] =  addr[1] & ~addr[0];
          wb[0] =  addr[1] &  addr[0];
        end
      2'b01:
        // halfword
        begin
          di[31:24] = data_in[15: 8];
          di[23:16] = data_in[ 7: 0];
          di[15: 8] = data_in[15: 8];
          di[ 7: 0] = data_in[ 7: 0];
          wb[3] = ~addr[1];
          wb[2] = ~addr[1];
          wb[1] =  addr[1];
          wb[0] =  addr[1];
        end
      2'b10:
        // word
        begin
          di[31:24] = data_in[31:24];
          di[23:16] = data_in[23:16];
          di[15: 8] = data_in[15: 8];
          di[ 7: 0] = data_in[ 7: 0];
          wb[3] = 1'b1;
          wb[2] = 1'b1;
          wb[1] = 1'b1;
          wb[0] = 1'b1;
        end
      default:
        // illegal
        begin
          di[31:24] = 8'hxx;
          di[23:16] = 8'hxx;
          di[15: 8] = 8'hxx;
          di[ 7: 0] = 8'hxx;
          wb[3] = 1'b0;
          wb[2] = 1'b0;
          wb[1] = 1'b0;
          wb[0] = 1'b0;
        end
    endcase
  end

  assign wt = ~ack;

endmodule
