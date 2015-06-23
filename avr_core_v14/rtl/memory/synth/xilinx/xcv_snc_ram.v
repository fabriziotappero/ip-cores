//****************************************************************************************************
// RAM for Xilinx Virtex(Virtex-E)
// Version 0.2
// Designed by Ruslan Lepetenok (lepetenokr@yahoo.com)
// Modified 13.09.2008
// Modified 27.05.12(Verilog version)
//**************************************************************************************************

`timescale 1 ns / 1 ns

// use WORK.x_ram_comp_pack.all;

module xcv_snc_ram(
   clk,
   en,
   we,
   adr,
   din,
   dout
);
   parameter                 adr_width = 10;
   parameter                 data_width = 8;
   input                     clk;
   input                     en;
   input                     we;
   input [(adr_width-1):0]   adr;
   input [(data_width-1):0]  din;
   output [(data_width-1):0] dout;
   
   wire                      gnd;
   wire                      vcc;
   wire [129:0]              din_tmp;
   wire [129:0]              dout_tmp;
   wire [19:0]               adr_tmp_a;
   wire [19:0]               adr_tmp_b;
   
   assign gnd = 1'b0;
   assign vcc = 1'b1;
   
   assign dout = dout_tmp[data_width - 1:0];
   assign din_tmp[data_width - 1:0] = din;
   assign din_tmp[129:data_width] = {9{1'b0}};
   assign adr_tmp_a[adr_width - 1:0] = adr;
   assign adr_tmp_a[19:adr_width] = {11{1'b0}};
   assign adr_tmp_b[adr_width - 1:0] = adr;
   assign adr_tmp_b[19:adr_width] = {11{1'b1}};
   
   generate
    genvar                    i;

      if ((adr_width <= 7) & (data_width <= 32))
      begin : adr_width_7
         
         RAMB4_S16_S16 RAMB4_S16_S16_inst(
            .DOA   (dout_tmp[31:16]),
            .DOB   (dout_tmp[15:0]),
            .ADDRA (adr_tmp_a[7:0]),
            .ADDRB (adr_tmp_b[7:0]),
            .CLKA  (clk),
            .CLKB  (clk),
            .DIA   (din_tmp[31:16]),
            .DIB   (din_tmp[15:0]),
            .ENA   (en),
            .ENB   (en),
            .RSTA  (gnd),
            .RSTB  (gnd),
            .WEA   (we),
            .WEB   (we)
         );
      end

      if (((adr_width <= 7) & (data_width > 32)) | (adr_width == 8))
      begin : adr_width_8
            for (i = 0; i <= ((data_width - 1)/16); i = i + 1)
            begin : db_inst
               
               RAMB4_S16 RAMB4_S16_inst(
                  .DO   (dout_tmp[((i + 1) * 16) - 1:i * 16]),
                  .ADDR (adr_tmp_a[7:0]),
                  .CLK  (clk),
                  .DI   (din_tmp[((i + 1) * 16) - 1:i * 16]),
                  .EN   (en),
                  .RST  (gnd),
                  .WE   (we)
               );
            end
      end

      if (adr_width == 9)
      begin : adr_width_9
            for (i = 0; i <= ((data_width - 1)/8); i = i + 1)
            begin : b_inst
               
               RAMB4_S8 RAMB4_S8_inst(
                  .DO   (dout_tmp[((i + 1) * 8) - 1:i * 8]),
                  .ADDR (adr_tmp_a[8:0]),
                  .CLK  (clk),
                  .DI   (din_tmp[((i + 1) * 8) - 1:i * 8]),
                  .EN   (en),
                  .RST  (gnd),
                  .WE   (we)
               );
            end
      end

      if (adr_width == 10)
      begin : adr_width_10
            for (i = 0; i <= ((data_width - 1)/4); i = i + 1)
            begin : hb_inst
               
               RAMB4_S4 RAMB4_S4_inst(
                  .DO   (dout_tmp[((i + 1) * 4) - 1:i * 4]),
                  .ADDR (adr_tmp_a[9:0]),
                  .CLK  (clk),
                  .DI   (din_tmp[((i + 1) * 4) - 1:i * 4]),
                  .EN   (en),
                  .RST  (gnd),
                  .WE   (we)
               );
            end
      end

      if (adr_width == 11)
      begin : adr_width_11
            for (i = 0; i <= ((data_width - 1)/2); i = i + 1)
            begin : tb_inst
               
               RAMB4_S2 RAMB4_S2_inst(
                  .DO   (dout_tmp[((i + 1) * 2) - 1:i * 2]),
                  .ADDR (adr_tmp_a[10:0]),
                  .CLK  (clk),
                  .DI   (din_tmp[((i + 1) * 2) - 1:i * 2]),
                  .EN   (en),
                  .RST  (gnd),
                  .WE   (we)
               );
            end
      end

      if (adr_width == 12)
      begin : adr_width_12
            for (i = 0; i <= (data_width - 1); i = i + 1)
            begin : bit_inst
               
               RAMB4_S1 RAMB4_S1_inst(
                  .DO   (dout_tmp[i:i]),
                  .ADDR (adr_tmp_a[11:0]),
                  .CLK  (clk),
                  .DI   (din_tmp[i:i]),
                  .EN   (en),
                  .RST  (gnd),
                  .WE   (we)
               );
            end
      end
   endgenerate
   
endmodule
