`define HIGH_RAM 13'h00fd

module sram_dump (
    input      sys_clk_in,
    output     trx,

    output            sram_clk,
    output     [20:0] sram_flash_addr,
    inout      [15:0] sram_flash_data,
    output     [ 3:0] sram_bw,

    output            sram_cen,
    output            sram_flash_oe_n,
    output            sram_flash_we_n,
		output            flash_ce
  );

  reg       clk_9600;
  reg [11:0] count_uart;
  reg [ 6:0] dada_wr;
  reg [ 7:0] estat;
  reg [ 7:0] addr;
  reg [ 2:0] espacios;
  reg [ 6:0] char;
  reg [ 3:0] nibble;
  reg [ 7:0] col;
  reg        trx_req;
  reg [ 8:0] adr0;

  wire        clk_60M;
  wire        rst, lock;
  wire        trx_ack;
  wire [15:0] rd_data;

  reg [15:0] ram[0:255];
  reg [15:0] dades;

  reg [ 3:0] count;

  // Instanciacions de mòduls
  clocks c0 (
    .CLKIN_IN   (sys_clk_in),
    .CLKFX_OUT  (clk_60M),
    .LOCKED_OUT (lock)
  );

  uart_ctrl u0 (dada_wr, trx_req, trx_ack, trx,
                rst, clk_9600);

  // Assignacions contínues
  assign rst = ~lock;

  assign sram_clk        = clk_60M;
  assign sram_flash_addr = { `HIGH_RAM, adr0[7:0] };
  assign rd_data         = sram_flash_data;
  assign sram_bw         = 4'b00;
  //assign SRAM_ADV_LB = 1'b0;
  assign sram_cen        = 1'b0;
  assign sram_flash_oe_n = 1'b0;
  assign sram_flash_we_n = 1'b1;
  assign flash_ce        = 1'b0;

  // Descripció del comportament
  // count_uart
  always @(posedge clk_60M)
    if (rst) count_uart <= 12'h0;
    else count_uart <= (count_uart==12'd3124) ?
      12'd0 : count_uart + 12'd1;

  // clk_9600
  always @(posedge clk_60M)
    if (rst) clk_9600 <= 1'b0;
    else clk_9600 <= (count_uart==12'd0) ?
      !clk_9600 : clk_9600;

  // adr0
  always @(posedge clk_60M)
    if (rst) adr0 <= 9'h000;
    else adr0 <= (adr0==9'h1ff || count!=4'hf) ? adr0
                             : (adr0 + 8'h01);
  // count
  always @(posedge clk_60M)
    if (rst) count <= 4'h0;
    else count <= count + 4'h1;

  // ram
  always @(posedge clk_60M) ram[adr0] <= rd_data;

  // dades
  always @(posedge clk_60M)
    if (rst) dades <= 16'h0;
    else dades <= ram[addr];

  always @(posedge clk_60M)
    if (adr0!=9'h1ff)
      begin
        dada_wr <= 7'h30;
        trx_req <= 0;
        estat <= 8'd0;
        addr <= 8'h00;
        espacios <= 3'd2;
        char <= 7'd00;
        nibble <= 4'd0;
        col <= 8'd79;
      end
    else
      case (estat)
        8'd00: if (~trx_ack)
                begin estat <= 8'd01;
                 if (espacios > 3'd0)
                 begin char <= 7'h20; espacios <= espacios - 3'd1; end
                else
                 begin
                   char <= ascii(nibble); espacios <= 3'd4;
                   nibble <= nibble + 4'd1;
                 end
                end
        8'd01: begin dada_wr <= char; trx_req <= 1; estat <= 8'd2; end
        8'd02: if (trx_ack) begin trx_req <= 0; estat <= 8'd3; end
        8'd03: if (col > 8'd0) begin col <= col - 8'd1; estat <= 8'd0; end
               else estat <= 8'd04;

        8'd04: if (~trx_ack) estat <= 8'd05;
        8'd05: begin dada_wr <= ascii(addr[7:4]); trx_req <= 1; estat <= 8'd10; end
        8'd10: if (trx_ack) begin trx_req <= 0; estat <= 8'd15; end

        8'd15: if (~trx_ack) estat <= 8'd20;
        8'd20: begin dada_wr <= ascii(dades[15:12]); trx_req <= 1; estat <= 8'd25; end
        8'd25: if (trx_ack) begin trx_req <= 0; estat <= 8'd30; end

        8'd30: if (~trx_ack) estat <= 8'd35;
        8'd35: begin dada_wr <= ascii(dades[11:8]); trx_req <= 1; estat <= 8'd40; end
        8'd40: if (trx_ack) begin trx_req <= 0; estat <= 8'd45; end

        8'd45: if (~trx_ack) estat <= 8'd50;
        8'd50: begin dada_wr <= ascii(dades[7:4]); trx_req <= 1; estat <= 8'd55; end
        8'd55: if (trx_ack) begin trx_req <= 0; estat <= 8'd60; end

        8'd60: if (~trx_ack) estat <= 8'd65;
        8'd65: begin dada_wr <= ascii(dades[3:0]); trx_req <= 1; estat <= 8'd70; end
        8'd70: if (trx_ack) begin trx_req <= 0; estat <= 8'd75; end

        8'd75: if (addr[3:0] == 4'hf) estat <= 8'd90;
               else if (~trx_ack) estat <= 8'd80;
        8'd80: begin dada_wr <= 7'h20; trx_req <= 1; estat <= 8'd85; end
        8'd85: if (trx_ack) begin trx_req <= 0; estat <= 8'd90; end

        8'd90: if (addr < 9'h0ff) begin addr <= addr + 8'd1; estat <= 8'd91; end
               else estat <= 8'd95;
        8'd91: estat <= (addr[3:0]==4'h0) ? 8'd4 : 8'd15;
      endcase

  function [6:0] ascii(input [3:0] num);
    if (num <= 4'd9) ascii = 7'h30 + num;
    else ascii = 7'd87 + num;
  endfunction
endmodule
