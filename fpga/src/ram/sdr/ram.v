//
// ram.v -- main memory, using SDRAM
//


module ram(clk, clk_ok, reset,
           en, wr, size, addr,
           data_in, data_out, wt,
           sdram_cke, sdram_cs_n,
           sdram_ras_n, sdram_cas_n,
           sdram_we_n, sdram_ba, sdram_a,
           sdram_udqm, sdram_ldqm, sdram_dq);
    // internal interface signals
    input clk;
    input clk_ok;
    input reset;
    input en;
    input wr;
    input [1:0] size;
    input [24:0] addr;
    input [31:0] data_in;
    output reg [31:0] data_out;
    output reg wt;
    // SDRAM interface signals
    output sdram_cke;
    output sdram_cs_n;
    output sdram_ras_n;
    output sdram_cas_n;
    output sdram_we_n;
    output [1:0] sdram_ba;
    output [12:0] sdram_a;
    output sdram_udqm;
    output sdram_ldqm;
    inout [15:0] sdram_dq;

  reg [3:0] state;
  reg a0;
  reg cntl_read;
  reg cntl_write;
  wire cntl_done;
  wire [23:0] cntl_addr;
  reg [15:0] cntl_din;
  wire [15:0] cntl_dout;

  wire sd_out_en;
  wire [15:0] sd_out;

//--------------------------------------------------------------

  sdramCntl sdramCntl1(
    // clock
    .clk(clk),
    .clk_ok(clk_ok),
    // host side
    .rd(cntl_read & ~cntl_done),
    .wr(cntl_write & ~cntl_done),
    .done(cntl_done),
    .hAddr(cntl_addr),
    .hDIn(cntl_din),
    .hDOut(cntl_dout),
    // SDRAM side
    .cke(sdram_cke),
    .ce_n(sdram_cs_n),
    .ras_n(sdram_ras_n),
    .cas_n(sdram_cas_n),
    .we_n(sdram_we_n),
    .ba(sdram_ba),
    .sAddr(sdram_a),
    .sDIn(sdram_dq),
    .sDOut(sd_out),
    .sDOutEn(sd_out_en),
    .dqmh(sdram_udqm),
    .dqml(sdram_ldqm)
  );

  assign sdram_dq = (sd_out_en == 1) ? sd_out : 16'hzzzz;

//--------------------------------------------------------------

  // the SDRAM is organized in 16-bit halfwords
  // address line 0 is controlled by the state machine
  // (this is necessary for word accesses)
  assign cntl_addr[23:1] = addr[24:2];
  assign cntl_addr[0] = a0;

  // state machine for SDRAM access
  always @(posedge clk) begin
    if (reset == 1) begin
      state <= 4'b0000;
      wt <= 1;
    end else begin
      case (state)
        4'b0000:
          // wait for access
          begin
            if (en == 1) begin
              // access
              if (wr == 1) begin
                // write
                if (size[1] == 1) begin
                  // write word
                  state <= 4'b0001;
                end else begin
                  if (size[0] == 1) begin
                    // write halfword
                    state <= 4'b0101;
                  end else begin
                    // write byte
                    state <= 4'b0111;
                  end
                end
              end else begin
                // read
                if (size[1] == 1) begin
                  // read word
                  state <= 4'b0011;
                end else begin
                  if (size[0] == 1) begin
                    // read halfword
                    state <= 4'b0110;
                  end else begin
                    // read byte
                    state <= 4'b1001;
                  end
                end
              end
            end
          end
        4'b0001:
          // write word, upper 16 bits
          begin
            if (cntl_done == 1) begin
              state <= 4'b0010;
            end
          end
        4'b0010:
          // write word, lower 16 bits
          begin
            if (cntl_done == 1) begin
              state <= 4'b1111;
              wt <= 0;
            end
          end
        4'b0011:
          // read word, upper 16 bits
          begin
            if (cntl_done == 1) begin
              state <= 4'b0100;
              data_out[31:16] <= cntl_dout;
            end
          end
        4'b0100:
          // read word, lower 16 bits
          begin
            if (cntl_done == 1) begin
              state <= 4'b1111;
              data_out[15:0] <= cntl_dout;
              wt <= 0;
            end
          end
        4'b0101:
          // write halfword
          begin
            if (cntl_done == 1) begin
              state <= 4'b1111;
              wt <= 0;
            end
          end
        4'b0110:
          // read halfword
          begin
            if (cntl_done == 1) begin
              state <= 4'b1111;
              data_out[31:16] <= 16'h0000;
              data_out[15:0] <= cntl_dout;
              wt <= 0;
            end
          end
        4'b0111:
          // write byte (read halfword cycle)
          begin
            if (cntl_done == 1) begin
              state <= 4'b1000;
              data_out[31:16] <= 16'h0000;
              data_out[15:0] <= cntl_dout;
            end
          end
        4'b1000:
          // write byte (write halfword cycle)
          begin
            if (cntl_done == 1) begin
              state <= 4'b1111;
              wt <= 0;
            end
          end
        4'b1001:
          // read byte
          begin
            if (cntl_done == 1) begin
              state <= 4'b1111;
              data_out[31:8] <= 24'h000000;
              if (addr[0] == 0) begin
                data_out[7:0] <= cntl_dout[15:8];
              end else begin
                data_out[7:0] <= cntl_dout[7:0];
              end
              wt <= 0;
            end
          end
        4'b1111:
          // end of bus cycle
          begin
            state <= 4'b0000;
            wt <= 1;
          end
        default:
          // all other states: reset
          begin
            state <= 4'b0000;
            wt <= 1;
          end
      endcase
    end
  end

  // output of state machine
  always @(*) begin
    case (state)
      4'b0000:
        // wait for access
        begin
          a0 = 1'bx;
          cntl_read = 0;
          cntl_write = 0;
          cntl_din = 16'hxxxx;
        end
      4'b0001:
        // write word, upper 16 bits
        begin
          a0 = 1'b0;
          cntl_read = 0;
          cntl_write = 1;
          cntl_din = data_in[31:16];
        end
      4'b0010:
        // write word, lower 16 bits
        begin
          a0 = 1'b1;
          cntl_read = 0;
          cntl_write = 1;
          cntl_din = data_in[15:0];
        end
      4'b0011:
        // read word, upper 16 bits
        begin
          a0 = 1'b0;
          cntl_read = 1;
          cntl_write = 0;
          cntl_din = 16'hxxxx;
        end
      4'b0100:
        // read word, lower 16 bits
        begin
          a0 = 1'b1;
          cntl_read = 1;
          cntl_write = 0;
          cntl_din = 16'hxxxx;
        end
      4'b0101:
        // write halfword
        begin
          a0 = addr[1];
          cntl_read = 0;
          cntl_write = 1;
          cntl_din = data_in[15:0];
        end
      4'b0110:
        // read halfword
        begin
          a0 = addr[1];
          cntl_read = 1;
          cntl_write = 0;
          cntl_din = 16'hxxxx;
        end
      4'b0111:
        // write byte (read halfword cycle)
        begin
          a0 = addr[1];
          cntl_read = 1;
          cntl_write = 0;
          cntl_din = 16'hxxxx;
        end
      4'b1000:
        // write byte (write halfword cycle)
        begin
          a0 = addr[1];
          cntl_read = 0;
          cntl_write = 1;
          if (addr[0] == 0) begin
            cntl_din = { data_in[7:0], data_out[7:0] };
          end else begin
            cntl_din = { data_out[15:8], data_in[7:0] };
          end
        end
      4'b1001:
        // read byte
        begin
          a0 = addr[1];
          cntl_read = 1;
          cntl_write = 0;
          cntl_din = 16'hxxxx;
        end
      4'b1111:
        // end of bus cycle
        begin
          a0 = 1'bx;
          cntl_read = 0;
          cntl_write = 0;
          cntl_din = 16'hxxxx;
        end
      default:
        // all other states: reset
        begin
          a0 = 1'bx;
          cntl_read = 0;
          cntl_write = 0;
          cntl_din = 16'hxxxx;
        end
    endcase
  end

endmodule
