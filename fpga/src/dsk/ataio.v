//
// ataio.v -- parallel ATA I/O
//


module ata_io (clk, reset,
               bus_en, bus_wr, bus_addr, bus_din, bus_dout, bus_wait,
               ata_d, ata_a, ata_cs0_n, ata_cs1_n,
               ata_dior_n, ata_diow_n, ata_iordy);
    input clk;
    input reset;
    //
    input bus_en;
    input bus_wr;
    input [3:0] bus_addr;
    input [15:0] bus_din;
    output reg [15:0] bus_dout;
    output bus_wait;
    //
    inout [15:0] ata_d;
    output reg [2:0] ata_a;
    output reg ata_cs0_n;
    output reg ata_cs1_n;
    output reg ata_dior_n;
    output reg ata_diow_n;
    input ata_iordy;

  reg [2:0] state;
  reg [4:0] delay_counter;
  reg ata_d_drive;

  assign ata_d = ata_d_drive ? bus_din : 16'bzzzzzzzzzzzzzzzz;
  assign bus_wait = bus_en & (state != 3'd5);

  always @(posedge clk) begin
    if (reset == 1'b1) begin
      state <= 3'd0;
      delay_counter <= 5'd31;
      ata_d_drive <= 1'b0;
      ata_a <= 3'b000;
      ata_cs0_n <= 1'b1;
      ata_cs1_n <= 1'b1;
      ata_dior_n <= 1'b1;
      ata_diow_n <= 1'b1;
      bus_dout <= 16'd0;
    end else begin
      if (delay_counter == 5'd0) begin
        case (state)

          // ready - wait for request from the bus
          3'd0: begin
            if (bus_en & ata_iordy) begin
              // assert address and -> state 1, wait 3+1
              // address mapping
              //   0xxx : control block registers
              //   1xxx : command block registers
              ata_a[2:0] <= bus_addr[2:0];
              ata_cs0_n <= ~bus_addr[3];
              ata_cs1_n <= bus_addr[3];
              state <= 3'd1;
              delay_counter <= 5'd3;
            end
          end

          // assert data-out and RW strobes, then -> state 2, wait 14+1
          3'd1: begin
            ata_d_drive <= bus_wr;
            ata_dior_n <= bus_wr;
            ata_diow_n <= ~bus_wr;
            state <= 3'd2;
            delay_counter <= 5'd14;
          end

          // de-assert RW strobes and sample data-in,
          // then -> state 3, wait 1+1
          3'd2: begin
            bus_dout <= ata_d;
            ata_dior_n <= 1'b1;
            ata_diow_n <= 1'b1;
            state <= 3'd3;
            delay_counter <= 5'd1;
          end

          // de-assert data and address, then -> state 4, wait 7+1
          // (such that 600 ns min cycle time is satisfied)
          3'd3: begin
            ata_d_drive <= 1'b0;
            ata_cs0_n <= 1'b1;
            ata_cs1_n <= 1'b1;
            state <= 3'd4;
            delay_counter <= 5'd7;
          end

          // auxiliary state, for necessity see comment in state 5
          3'd4: begin
            state <= 3'd5;
            delay_counter <= 5'd0;
          end

          // finish - used to release bus wait
          // WARNING: This state must not be entered with a delay!
          // Otherwise bus wait will be released too early and
          // subsequent bus cycles will not work properly.
          3'd5: begin
            state <= 3'd0;
            delay_counter <= 5'd0;
          end

        endcase
      end else begin
        delay_counter <= delay_counter - 1;
      end
    end
  end

endmodule
