//****************************************************************************************************
// RAM for Xilinx Virtex-II/Virtex-4/Spartan-3
// Version 0.2
// Designed by Ruslan Lepetenok (lepetenokr@yahoo.com)
// Modified 13.09.2008
// Modified 27.05.12(Verilog version)
//**************************************************************************************************

`timescale 1 ns / 1 ns

// use WORK.x_ram_comp_pack.all;

module xcv24s3_snc_ram(
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
      if (adr_width <= 8)
      begin : adr_width_8
            for (i = 0; i <= ((data_width - 1)/72); i = i + 1)
            begin : eb_inst
               
               RAMB16_S36_S36 RAMB16_S36_S36_inst(
                  .DOA   (dout_tmp[i * 72 + 36 + 31:i * 72 + 36]),
                  .DOB   (dout_tmp[i * 72 + 31:i * 72]),
                  .DOPA  (dout_tmp[i * 72 + 36 + 32 + 3:i * 72 + 36 + 32]),
                  .DOPB  (dout_tmp[i * 72 + 32 + 3:i * 72 + 32]),
                  .ADDRA (adr_tmp_a[8:0]),
                  .ADDRB (adr_tmp_b[8:0]),
                  .CLKA  (clk),
                  .CLKB  (clk),
                  .DIA   (din_tmp[i * 72 + 36 + 31:i * 72 + 36]),
                  .DIB   (din_tmp[i * 72 + 31:i * 72]),
                  .DIPA  (din_tmp[i * 72 + 36 + 32 + 3:i * 72 + 36 + 32]),
                  .DIPB  (din_tmp[i * 72 + 32 + 3:i * 72 + 32]),
                  .ENA   (en),
                  .ENB   (en),
                  .SSRA  (gnd),
                  .SSRB  (gnd),
                  .WEA   (we),
                  .WEB   (we)
               );
            end
      end

      if (adr_width == 9)
      begin : adr_width_9
            for (i = 0; i <= ((data_width - 1)/36); i = i + 1)
            begin : qb_inst
               
               RAMB16_S36 RAMB16_S36_inst(
                  .DO   (dout_tmp[((i + 1) * 36) - 5:i * 36]),
                  .DOP  (dout_tmp[((i + 1) * 36) - 1:i * 36 + 32]),
                  .ADDR (adr_tmp_a[8:0]),
                  .CLK  (clk),
                  .DI   (din_tmp[((i + 1) * 36) - 5:i * 36]),
                  .DIP  (din_tmp[((i + 1) * 36) - 1:i * 36 + 32]),
                  .EN   (en),
                  .SSR  (gnd),
                  .WE   (we)
               );
            end
      end

      if (adr_width == 10)
      begin : adr_width_10
            for (i = 0; i <= ((data_width - 1)/18); i = i + 1)
            begin : db_inst
               
               RAMB16_S18 RAMB16_S18_inst(
                  .DO   (dout_tmp[((i + 1) * 18) - 3:i * 18]),
                  .DOP  (dout_tmp[((i + 1) * 18) - 1:i * 18 + 16]),
                  .ADDR (adr_tmp_a[9:0]),
                  .CLK  (clk),
                  .DI   (din_tmp[((i + 1) * 18) - 3:i * 18]),
                  .DIP  (din_tmp[((i + 1) * 18) - 1:i * 18 + 16]),
                  .EN   (en),
                  .SSR  (gnd),
                  .WE   (we)
               );
            end
      end

      if (adr_width == 11)
      begin : adr_width_11
            for (i = 0; i <= ((data_width - 1)/9); i = i + 1)
            begin : b_inst
               
               RAMB16_S9 RAMB16_S9_inst(
                  .DO   (dout_tmp[((i + 1) * 9) - 2:i * 9]),
                  .DOP  (dout_tmp[((i + 1) * 9) - 1:i * 9 + 8]),
                  .ADDR (adr_tmp_a[10:0]),
                  .CLK  (clk),
                  .DI   (din_tmp[((i + 1) * 9) - 2:i * 9]),
                  .DIP  (din_tmp[((i + 1) * 9) - 1:i * 9 + 8]),
                  .EN   (en),
                  .SSR  (gnd),
                  .WE   (we)
               );
            end
      end

      if (adr_width == 12)
      begin : adr_width_12
            for (i = 0; i <= ((data_width - 1)/4); i = i + 1)
            begin : fbi_inst
               
               RAMB16_S4 RAMB16_S4_inst(
                  .DO   (dout_tmp[((i + 1) * 4) - 1:i * 4]),
                  .ADDR (adr_tmp_a[11:0]),
                  .CLK  (clk),
                  .DI   (din_tmp[((i + 1) * 4) - 1:i * 4]),
                  .EN   (en),
                  .SSR  (gnd),
                  .WE   (we)
               );
            end
      end

      if (adr_width == 13)
      begin : adr_width_13
            for (i = 0; i <= ((data_width - 1)/2); i = i + 1)
            begin : tbi_inst
               
               RAMB16_S2 RAMB16_S2_inst(
                  .DO   (dout_tmp[((i + 1) * 2) - 1:i * 2]),
                  .ADDR (adr_tmp_a[12:0]),
                  .CLK  (clk),
                  .DI   (din_tmp[((i + 1) * 2) - 1:i * 2]),
                  .EN   (en),
                  .SSR  (gnd),
                  .WE   (we)
               );
            end
      end

      if (adr_width == 14)
      begin : adr_width_14
            for (i = 0; i <= (data_width - 1); i = i + 1)
            begin : obi_inst
               
               RAMB16_S1 RAMB16_S1_inst(
                  .DO   (dout_tmp[(i + 1) - 1:i]),
                  .ADDR (adr_tmp_a[13:0]),
                  .CLK  (clk),
                  .DI   (din_tmp[(i + 1) - 1:i]),
                  .EN   (en),
                  .SSR  (gnd),
                  .WE   (we)
               );
            end
      end
   endgenerate
   
endmodule

