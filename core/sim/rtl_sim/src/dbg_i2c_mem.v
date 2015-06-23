/*===========================================================================*/
/* Copyright (C) 2001 Authors                                                */
/*                                                                           */
/* This source file may be used and distributed without restriction provided */
/* that this copyright statement is not removed from the file and that any   */
/* derivative work contains the original copyright notice and the associated */
/* disclaimer.                                                               */
/*                                                                           */
/* This source file is free software; you can redistribute it and/or modify  */
/* it under the terms of the GNU Lesser General Public License as published  */
/* by the Free Software Foundation; either version 2.1 of the License, or    */
/* (at your option) any later version.                                       */
/*                                                                           */
/* This source is distributed in the hope that it will be useful, but WITHOUT*/
/* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or     */
/* FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public       */
/* License for more details.                                                 */
/*                                                                           */
/* You should have received a copy of the GNU Lesser General Public License  */
/* along with this source; if not, write to the Free Software Foundation,    */
/* Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA        */
/*                                                                           */
/*===========================================================================*/
/*                            DEBUG INTERFACE                                */
/*---------------------------------------------------------------------------*/
/* Test the debug interface:                                                 */
/*                        - Check Memory RD/WR features.                     */
/*                                                                           */
/*  Note: The burst features are specific to the selected interface          */
/*    (UART/I2C) and are therefore tested in the dbg_uart/dbg_i2c patterns   */
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev: 86 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2011-01-28 23:53:28 +0100 (Fri, 28 Jan 2011) $          */
/*===========================================================================*/

`define LONG_TIMEOUT

initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
`ifdef DBG_EN
`ifdef DBG_I2C
      #1 dbg_en = 1;
      repeat(30) @(posedge mclk);
      stimulus_done = 0;

   `ifdef DBG_RST_BRK_EN
      dbg_i2c_wr(CPU_CTL,  16'h0002);  // RUN
   `endif

      // RD/WR ACCESS: CPU REGISTERS (16b)
      //--------------------------------------------------------

      // READ CPU REGISTERS
      dbg_i2c_wr(MEM_ADDR, 16'h0005);  // select register
      dbg_i2c_wr(MEM_CTL,  16'h0005);  // read register
      dbg_i2c_rd(MEM_DATA);            // read data
      if (dbg_i2c_buf !== 16'haaaa)  tb_error("====== CPU REGISTERS (16b): Read R5 =====");
      dbg_i2c_wr(MEM_ADDR, 16'h0006);  // select register
      dbg_i2c_wr(MEM_CTL,  16'h0005);  // read register
      dbg_i2c_rd(MEM_DATA);            // read data
      if (dbg_i2c_buf !== 16'hbbbb)  tb_error("====== CPU REGISTERS (16b): Read R6 =====");

      // WRITE CPU REGISTERS
      dbg_i2c_wr(MEM_ADDR, 16'h0005);  // select register
      dbg_i2c_wr(MEM_DATA, 16'hed32);  // write data
      dbg_i2c_wr(MEM_CTL,  16'h0007);  // write register
      repeat(20) @(posedge mclk);
      if (r5 !== 16'hed32)  tb_error("====== CPU REGISTERS (16b): Write R5 =====");
      dbg_i2c_wr(MEM_ADDR, 16'h0006);  // select register
      dbg_i2c_wr(MEM_DATA, 16'hcb54);  // write data
      dbg_i2c_wr(MEM_CTL,  16'h0007);  // write register
      repeat(20) @(posedge mclk);
      if (r6 !== 16'hcb54)  tb_error("====== CPU REGISTERS (16b): Write R6 =====");


      // RD/WR ACCESS: RAM (16b)
      //--------------------------------------------------------

      // READ RAM
      dbg_i2c_wr(MEM_ADDR, (`PER_SIZE+16'h0010));  // select memory address
      dbg_i2c_wr(MEM_CTL,  16'h0001);  // read memory
      dbg_i2c_rd(MEM_DATA);            // read data
      if (dbg_i2c_buf !== 16'h1122)  tb_error("====== RAM (16b): Read @0x210 =====");
      dbg_i2c_wr(MEM_ADDR, (`PER_SIZE+16'h0012));  // select memory address
      dbg_i2c_wr(MEM_CTL,  16'h0001);  // read memory
      dbg_i2c_rd(MEM_DATA);            // read data
      if (dbg_i2c_buf !== 16'h3344)  tb_error("====== RAM (16b): Read @0x212 =====");

      // WRITE RAM
      dbg_i2c_wr(MEM_ADDR, (`PER_SIZE+16'h0010));  // select memory address
      dbg_i2c_wr(MEM_DATA, 16'ha976);  // write data
      dbg_i2c_wr(MEM_CTL,  16'h0003);  // write memory
      repeat(20) @(posedge mclk);
      if (mem210 !== 16'ha976)  tb_error("====== RAM (16b): Write @0x210 =====");
      dbg_i2c_wr(MEM_ADDR, (`PER_SIZE+16'h0012));  // select register
      dbg_i2c_wr(MEM_DATA, 16'h8798);  // write data
      dbg_i2c_wr(MEM_CTL,  16'h0003);  // write register
      repeat(20) @(posedge mclk);
      if (mem212 !== 16'h8798)  tb_error("====== RAM (16b): Write @0x212 =====");


      // RD/WR ACCESS: RAM (8b)
      //--------------------------------------------------------

      // READ RAM
      dbg_i2c_wr(MEM_ADDR, (`PER_SIZE+16'h0010));  // select memory address
      dbg_i2c_wr(MEM_CTL,  16'h0009);  // read memory
      dbg_i2c_rd(MEM_DATA);            // read data
      if (dbg_i2c_buf !== 16'h0076)  tb_error("====== RAM (8b): Read @0x210 =====");
      dbg_i2c_wr(MEM_ADDR, (`PER_SIZE+16'h0011));  // select memory address
      dbg_i2c_wr(MEM_CTL,  16'h0009);  // read memory
      dbg_i2c_rd(MEM_DATA);            // read data
      if (dbg_i2c_buf !== 16'h00a9)  tb_error("====== RAM (8b): Read @0x211 =====");

      // WRITE RAM
      dbg_i2c_wr(MEM_ADDR, (`PER_SIZE+16'h0010));  // select memory address
      dbg_i2c_wr(MEM_DATA, 16'h14b3);  // write data
      dbg_i2c_wr(MEM_CTL,  16'h000b);  // write memory
      repeat(20) @(posedge mclk);
      if (mem210 !== 16'ha9b3)  tb_error("====== RAM (8b): Write @0x210 =====");
      dbg_i2c_wr(MEM_ADDR, (`PER_SIZE+16'h0011));  // select register
      dbg_i2c_wr(MEM_DATA, 16'h25c4);  // write data
      dbg_i2c_wr(MEM_CTL,  16'h000b);  // write register
      repeat(20) @(posedge mclk);
      if (mem210 !== 16'hc4b3)  tb_error("====== RAM (8b): Write @0x211 =====");


      // RD/WR ACCESS: ROM (16b)
      //--------------------------------------------------------

      // READ ROM
      dbg_i2c_wr(MEM_ADDR, ('h10000-`PMEM_SIZE+'h00));  // select memory address
      dbg_i2c_wr(MEM_CTL,  16'h0001);  // read memory
      dbg_i2c_rd(MEM_DATA);            // read data
      if (dbg_i2c_buf !== 16'h5ab7)  tb_error("====== ROM (16b): Read @0xf834 =====");
      dbg_i2c_wr(MEM_ADDR, ('h10000-`PMEM_SIZE+'h02));  // select memory address
      dbg_i2c_wr(MEM_CTL,  16'h0001);  // read memory
      dbg_i2c_rd(MEM_DATA);            // read data
      if (dbg_i2c_buf !== 16'h6bc8)  tb_error("====== ROM (16b): Read @0xf836 =====");

      // WRITE ROM
      dbg_i2c_wr(MEM_ADDR, 16'hffe0);  // select memory address
      dbg_i2c_wr(MEM_DATA, 16'h7cd9);  // write data
      dbg_i2c_wr(MEM_CTL,  16'h0003);  // write memory
      repeat(20) @(posedge mclk);
      if (irq_vect_00 !== 16'h7cd9)  tb_error("====== ROM (16b): Write @0xffe0 =====");
      dbg_i2c_wr(MEM_ADDR, 16'hffe2);  // select register
      dbg_i2c_wr(MEM_DATA, 16'h8dea);  // write data
      dbg_i2c_wr(MEM_CTL,  16'h0003);  // write register
      repeat(20) @(posedge mclk);
      if (irq_vect_01 !== 16'h8dea)  tb_error("====== ROM (16b): Write @0xffe2 =====");


      // RD/WR ACCESS: ROM (8b)
      //--------------------------------------------------------

      // READ ROM
      dbg_i2c_wr(MEM_ADDR, ('h10000-`PMEM_SIZE+'h00));  // select memory address
      dbg_i2c_wr(MEM_CTL,  16'h0009);  // read memory
      dbg_i2c_rd(MEM_DATA);            // read data
      if (dbg_i2c_buf !== 16'h00b7)  tb_error("====== ROM (8b): Read @0xf834 =====");
      dbg_i2c_wr(MEM_ADDR, ('h10000-`PMEM_SIZE+'h01));  // select memory address
      dbg_i2c_wr(MEM_CTL,  16'h0009);  // read memory
      dbg_i2c_rd(MEM_DATA);            // read data
      if (dbg_i2c_buf !== 16'h005a)  tb_error("====== ROM (8b): Read @0xf835 =====");

      // WRITE ROM
      dbg_i2c_wr(MEM_ADDR, 16'hffe0);  // select memory address
      dbg_i2c_wr(MEM_DATA, 16'hb314);  // write data
      dbg_i2c_wr(MEM_CTL,  16'h000b);  // write memory
      repeat(20) @(posedge mclk);
      if (irq_vect_00 !== 16'h7c14)  tb_error("====== ROM (8b): Write @0xffe0 =====");
      dbg_i2c_wr(MEM_ADDR, 16'hffe1);  // select register
      dbg_i2c_wr(MEM_DATA, 16'hc425);  // write data
      dbg_i2c_wr(MEM_CTL,  16'h000b);  // write register
      repeat(20) @(posedge mclk);
      if (irq_vect_00 !== 16'h2514)  tb_error("====== ROM (8b): Write @0xffe1 =====");


      // RD/WR ACCESS: PERIPHERALS (16b)
      //--------------------------------------------------------

      // WRITE PERIPHERAL
      dbg_i2c_wr(MEM_ADDR, 16'h0170);                        // select memory address
      dbg_i2c_wr(MEM_DATA, 16'h9dc7);                        // write data
      dbg_i2c_wr(MEM_CTL,  16'h0003);                        // write memory
      repeat(20) @(posedge mclk);
      if (timerA_0.tar !== 16'h9dc7)  tb_error("====== Peripheral (16b): Write @0x0170 =====");
      dbg_i2c_wr(MEM_ADDR, 16'h0172);                        // select register
      dbg_i2c_wr(MEM_DATA, 16'haed8);                        // write data
      dbg_i2c_wr(MEM_CTL,  16'h0003);                        // write register
      repeat(20) @(posedge mclk);
      if (timerA_0.taccr0 !== 16'haed8)  tb_error("====== Peripheral (16b): Write @0x0172 =====");
      dbg_i2c_wr(MEM_ADDR, (((`DMEM_BASE-16'h0070)&16'h7ff8)+16'h0002));  // select memory address
      dbg_i2c_wr(MEM_DATA, 16'hdead);                        // write data
      dbg_i2c_wr(MEM_CTL,  16'h0003);                        // write memory
      repeat(20) @(posedge mclk);
      if (template_periph_16b_0.cntrl2 !== 16'hdead)  tb_error("====== Peripheral (16b): Write @(DMEM_BASE-0x0070+0x0002) =====");
      dbg_i2c_wr(MEM_ADDR, (((`DMEM_BASE-16'h0070)&16'h7ff8)+16'h0006));  // select memory address
      dbg_i2c_wr(MEM_DATA, 16'hbeef);                        // write data
      dbg_i2c_wr(MEM_CTL,  16'h0003);                        // write memory
      repeat(20) @(posedge mclk);
      if (template_periph_16b_0.cntrl4 !== 16'hbeef)  tb_error("====== Peripheral (16b): Write @(DMEM_BASE-0x0070+0x0006) =====");

      // READ PERIPHERAL
      dbg_i2c_wr(MEM_ADDR, 16'h0170);                        // select memory address
      dbg_i2c_wr(MEM_CTL,  16'h0001);                        // read memory
      dbg_i2c_rd(MEM_DATA);                                  // read data
      if (dbg_i2c_buf !== 16'h9dc7)  tb_error("====== Peripheral (16b): Read @0x0170 =====");
      dbg_i2c_wr(MEM_ADDR, 16'h0172);                        // select memory address
      dbg_i2c_wr(MEM_CTL,  16'h0001);                        // read memory
      dbg_i2c_rd(MEM_DATA);                                  // read data
      if (dbg_i2c_buf !== 16'haed8)  tb_error("====== Peripheral (16b): Read @0x0172 =====");
      dbg_i2c_wr(MEM_ADDR, (((`DMEM_BASE-16'h0070)&16'h7ff8)+16'h0002));  // select memory address
      dbg_i2c_wr(MEM_CTL,  16'h0001);                        // read memory
      dbg_i2c_rd(MEM_DATA);                                  // read data
      repeat(20) @(posedge mclk);
      if (dbg_i2c_buf !== 16'hdead)  tb_error("====== Peripheral (16b): Read @(DMEM_BASE-0x0070+0x0002) =====");
      dbg_i2c_wr(MEM_ADDR, (((`DMEM_BASE-16'h0070)&16'h7ff8)+16'h0006));  // select memory address
      dbg_i2c_wr(MEM_CTL,  16'h0001);                        // read memory
      dbg_i2c_rd(MEM_DATA);                                  // read data
      repeat(20) @(posedge mclk);
      if (dbg_i2c_buf !== 16'hbeef)  tb_error("====== Peripheral (16b): Read @(DMEM_BASE-0x0070+0x0006) =====");


      // RD/WR ACCESS: PERIPHERAL (8b)
      //--------------------------------------------------------

      // WRITE PERIPHERAL
      dbg_i2c_wr(MEM_ADDR, 16'h0022);  // select memory address
      dbg_i2c_wr(MEM_DATA, 16'hbfe9);  // write data
      dbg_i2c_wr(MEM_CTL,  16'h000b);  // write memory
      repeat(20) @(posedge mclk);
      if (gpio_0.p1dir !== 8'he9)  tb_error("====== Peripheral (8b): Write @0x0022 - test 1 =====");
      if (gpio_0.p1ifg !== 8'h00)  tb_error("====== Peripheral (8b): Write @0x0022 - test 2=====");
      dbg_i2c_wr(MEM_ADDR, 16'h0023);  // select register
      dbg_i2c_wr(MEM_DATA, 16'hc0fa);  // write data
      dbg_i2c_wr(MEM_CTL,  16'h000b);  // write register
      repeat(20) @(posedge mclk);
      if (gpio_0.p1dir !== 8'he9)  tb_error("====== Peripheral (8b): Write @0x0023 - test 1 =====");
      if (gpio_0.p1ifg !== 8'hfa)  tb_error("====== Peripheral (8b): Write @0x0023 - test 2=====");

      // READ PERIPHERAL
      dbg_i2c_wr(MEM_ADDR, 16'h0022);  // select memory address
      dbg_i2c_wr(MEM_CTL,  16'h0009);  // read memory
      dbg_i2c_rd(MEM_DATA);            // read data
      if (dbg_i2c_buf !== 16'h00e9)  tb_error("====== Peripheral (8b): Read @0x0022 =====");
      dbg_i2c_wr(MEM_ADDR, 16'h0023);  // select memory address
      dbg_i2c_wr(MEM_CTL,  16'h0009);  // read memory
      dbg_i2c_rd(MEM_DATA);            // read data
      if (dbg_i2c_buf !== 16'h00fa)  tb_error("====== Peripheral (8b): Read @0x0023 =====");


      stimulus_done = 1;
`else

       $display(" ===============================================");
       $display("|               SIMULATION SKIPPED              |");
       $display("|   (serial debug interface I2C not included)   |");
       $display(" ===============================================");
       $finish;
`endif
`else

       $display(" ===============================================");
       $display("|               SIMULATION SKIPPED              |");
       $display("|      (serial debug interface not included)    |");
       $display(" ===============================================");
       $finish;
`endif
   end
