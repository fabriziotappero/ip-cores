//----------------------------------------------------------------------
// File       : rx_elastic_buffer.v
// Author     : Xilinx Inc.																	 
//----------------------------------------------------------------------
// Copyright (c) 2008 by Xilinx, Inc. All rights reserved.
// This text/file contains proprietary, confidential
// information of Xilinx, Inc., is distributed under license
// from Xilinx, Inc., and may be used, copied and/or
// disclosed only pursuant to the terms of a valid license
// agreement with Xilinx, Inc. Xilinx hereby grants you
// a license to use this text/file solely for design, simulation,
// implementation and creation of design files limited
// to Xilinx devices or technologies. Use with non-Xilinx
// devices or technologies is expressly prohibited and
// immediately terminates your license unless covered by
// a separate agreement.
//
// Xilinx is providing this design, code, or information
// "as is" solely for use in developing programs and
// solutions for Xilinx devices. By providing this design,
// code, or information as one possible implementation of
// this feature, application or standard, Xilinx is making no
// representation that this implementation is free from any
// claims of infringement. You are responsible for
// obtaining any rights you may require for your implementation.
// Xilinx expressly disclaims any warranty whatsoever with
// respect to the adequacy of the implementation, including
// but not limited to any warranties or representations that this
// implementation is free from claims of infringement, implied
// warranties of merchantability or fitness for a particular
// purpose.
//
// Xilinx products are not intended for use in life support
// appliances, devices, or systems. Use in such applications are
// expressly prohibited.
//
// This copyright and support notice must be retained as part
// of this text at all times. (c) Copyright 2008 Xilinx, Inc.
// All rights reserved.
//----------------------------------------------------------------------
// Description: This is the Receiver Elastic Buffer for the design 
//              example of the Virtex-5 Ethernet MAC Wrappers. 
//
//              The FIFO is created from Block Memory, is of data width
//              32 (2 characters wide plus status) and is of depth 64 
//              words.  This is twice the size of the elastic buffer in
//              the RocketIO which has been bypassed,
//
//              When the write clock is a few parts per million faster 
//              than the read clock, the occupancy of the FIFO will
//              increase and Idles should be removed. 
//              
//              When the read clock is a few parts per million faster 
//              than the write clock, the occupancy of the FIFO will
//              decrease and Idles should be inserted.  The logic in  
//              this example design will always insert as many idles as  
//              necessary in every Inter-frame Gap period to restore the
//              FIFO occupancy.
//
//              Note: the Idle /I2/ sequence is used as the clock
//              correction character.  This is made up from a /K28.5/
//              followed by a /D16.2/ character.

																							 
																							 
`timescale 1 ns/1 ps

module rx_elastic_buffer
  ( 

    // Signals received from the RocketIO on RXRECCLK.

    rxrecclk,
    reset,
    rxchariscomma_rec,
    rxcharisk_rec,
    rxdisperr_rec,
    rxnotintable_rec,
    rxrundisp_rec,
    rxdata_rec,

    // Signals reclocked onto RXUSRCLK2.

    rxusrclk2,
    rxreset,
    rxchariscomma_usr,
    rxcharisk_usr,
    rxdisperr_usr,
    rxnotintable_usr,
    rxrundisp_usr,
    rxclkcorcnt_usr,
    rxbuferr,
    rxdata_usr
  );



  // port declarations

  input         rxrecclk;
  input         reset;
  input         rxchariscomma_rec;
  input         rxcharisk_rec;
  input         rxdisperr_rec;
  input         rxnotintable_rec;
  input         rxrundisp_rec;
  input  [7:0]  rxdata_rec;

  input         rxusrclk2;
  input         rxreset;
  output        rxchariscomma_usr;
  output        rxcharisk_usr;
  output        rxdisperr_usr;
  output        rxnotintable_usr;
  output        rxrundisp_usr;
  output [2:0]  rxclkcorcnt_usr;
  output        rxbuferr;
  output [7:0]  rxdata_usr;

  reg           rxchariscomma_usr;
  reg           rxcharisk_usr;
  reg           rxdisperr_usr;
  reg           rxnotintable_usr;
  reg           rxrundisp_usr;
  reg           rxbuferr;
  reg    [7:0]  rxdata_usr;

  //--------------------------------------------------------------------
  // Constants to set FIFO thresholds
  //--------------------------------------------------------------------

  // FIFO occupancy over this level: clock correct to remove Idles
  wire   [6:0]  upper_threshold;        
  assign upper_threshold     = 7'b1000001;  

  // FIFO occupancy less than this level: clock correct to insert Idles
  wire   [6:0]  lower_threshold;
  assign lower_threshold     = 7'b0111111;  

  // FIFO occupancy less than this, we consider it to be an underflow
  wire   [6:0]  underflow_threshold;
  assign underflow_threshold = 7'b0000011;  

  // FIFO occupancy greater than this, we consider it to be an overflow
  wire   [6:0]  overflow_threshold;
  assign overflow_threshold  = 7'b1111100;  



  //--------------------------------------------------------------------
  // Signal Declarations
  //--------------------------------------------------------------------

  // Write domain logic (RXRECCLK) 

  reg    [15:0] wr_data;               // Formatted the data word from RocketIO signals.
  reg    [15:0] wr_data_reg;           // wr_data registered and formatting completed.
  reg    [15:0] wr_data_reg_reg;       // wr_data_reg registered : to be written to the BRAM.  
  reg    [6:0]  next_wr_addr;          // Next FIFO write address (to reduce latency in gray code logic).
  reg    [6:0]  wr_addr;               // FIFO write address.
  wire          wr_enable;             // write enable for FIFO.
  reg    [6:0]  wr_addr_gray;          // wr_addr is converted to a gray code. 

  reg    [6:0]  wr_rd_addr_gray;       // read address pointer (gray coded) reclocked onto the write clock domain).
  reg    [6:0]  wr_rd_addr_gray_reg;   // read address pointer (gray coded) registered on write clock for the 2nd time.
  wire   [6:0]  wr_rd_addr;            // wr_rd_addr_gray converted back to binary (on the write clock domain). 
  reg    [6:0]  wr_occupancy;          // The occupancy of the FIFO in write clock domain.
  wire          filling;               // FIFO is filling up: Idles should be removed.

  // synthesis attribute ASYNC_REG of wr_rd_addr_gray  is "TRUE";

  wire          k28p5_wr;              // /K28.5/ character is detected on data prior to FIFO.
  wire          d16p2_wr;              // /D16.2/ character is detected on data prior to FIFO.
  reg    [2:0]  d16p2_wr_pipe;         // k28p5_wr registered.
  reg    [2:0]  k28p5_wr_pipe;         // d16p2_wr registered.
  reg           remove_idle;           // An Idle is removed before writing it into the FIFO.
  reg           remove_idle_reg;       // remove_idle registered.


  // Read domain logic (RXUSRCLK2) 

  wire   [15:0] rd_data;               // Date read out of the block RAM.
  reg    [15:0] rd_data_reg;           // rd_data is registered for logic pipeline.
  reg    [6:0]  next_rd_addr;          // Next FIFO read address (to reduce latency in gray code logic).
  reg    [6:0]  rd_addr;               // FIFO read address.
  wire          rd_enable;             // read enable for FIFO.
  reg    [6:0]  rd_addr_gray;          // rd_addr is converted to a gray code. 

  reg    [6:0]  rd_wr_addr_gray;       // write address pointer (gray coded) reclocked onto the read clock domain).
  reg    [6:0]  rd_wr_addr_gray_reg;   // write address pointer (gray coded) registered on read clock for the 2nd time.
  wire   [6:0]  rd_wr_addr;            // rd_wr_addr_gray converted back to binary (on the read clock domain). 
  reg    [6:0]  rd_occupancy;          // The occupancy of the FIFO in read clock domain.
  wire          emptying;              // FIFO is emptying: Idles should be inserted.
  wire          overflow;              // FIFO has filled up to overflow.
  wire          underflow;             // FIFO has emptied to underflow

  // synthesis attribute ASYNC_REG of rd_wr_addr_gray  is "TRUE";

  reg           even;                  // To control reading of data from upper or lower half of FIFO word.
  wire          k28p5_rd;              // /K28.5/ character is detected on data post FIFO.
  wire          d16p2_rd;              // /D16.2/ character is detected on data post FIFO.
  reg           insert_idle;           // An Idle is inserted whilst reading it out of the FIFO.
  reg           insert_idle_reg;       // insert_idle is registered.
  reg           rd_enable_reg;         // Read enable is registered.
  reg   [2:0]   rxclkcorcnt;           // derive RXCLKCORCNT to mimic RocketIO behaviour.    

  //--------------------------------------------------------------------
  // FIFO write logic (Idles are removed as necessary).
  //--------------------------------------------------------------------

  // Reclock the RocketIO data and format for storing in the BRAM.
  always @(posedge rxrecclk)
  begin : gen_wr_data
    if (reset === 1'b1)
    begin
      wr_data            <= 16'b0;
      wr_data_reg        <= 16'b0;
      wr_data_reg_reg    <= 16'b0;
    end
    else
    begin

      wr_data_reg_reg    <= wr_data_reg;

      wr_data_reg[15:14] <= wr_data[15:14];
      wr_data_reg[13]    <= remove_idle;
      wr_data_reg[12:0]  <= wr_data[12:0]; 

      // format the lower word
      wr_data[15:13]     <= 3'b0;   // unused
      wr_data[12]        <= rxchariscomma_rec;
      wr_data[11]        <= rxcharisk_rec;
      wr_data[10]        <= rxdisperr_rec;
      wr_data[9]         <= rxnotintable_rec;
      wr_data[8]         <= rxrundisp_rec;
      wr_data[7:0]       <= rxdata_rec[7:0];

    end
  end // gen_wr_data



  // Detect /K28.5/ character in upper half of the word from RocketIO
  assign k28p5_wr = (wr_data[7:0] == 8'b10111100 && 
                     wr_data[11] == 1'b1) ? 1'b1 : 1'b0;   

  // Detect /D16.2/ character in upper half of the word from RocketIO
  assign d16p2_wr = (wr_data[7:0] == 8'b01010000 && 
                     wr_data[11] == 1'b0) ? 1'b1 : 1'b0;
                     
  always @(posedge rxrecclk)
  begin : gen_k_d_pipe
    if (reset === 1'b1)
    begin
      k28p5_wr_pipe      <= 3'b000;
      d16p2_wr_pipe      <= 3'b000;
    end
    else
    begin
      k28p5_wr_pipe[2:1] <= k28p5_wr_pipe[1:0];
      d16p2_wr_pipe[2:1] <= d16p2_wr_pipe[1:0];
      k28p5_wr_pipe[0]   <= k28p5_wr;
      d16p2_wr_pipe[0]   <= d16p2_wr;
    end
  end // gen_k_d_pipe    


  // Create the FIFO write enable: Idles are removed by deasserting the
  // FIFO write_enable whilst an Idle is present on the data.
  always @(posedge rxrecclk)
  begin : gen_wr_enable
    if (reset === 1'b1)
    begin
      remove_idle       <= 1'b0;
      remove_idle_reg   <= 1'b0;
    end
    else
    begin

      remove_idle_reg <= remove_idle;
       
      // Idle removal (always leave the first /I2/ Idle, then every
      // alternate Idle can be removed.
      if (d16p2_wr == 1'b1 && k28p5_wr_pipe[0] == 1'b1 &&
          d16p2_wr_pipe[1] == 1'b1 && k28p5_wr_pipe[2] == 1'b1 &&
          filling == 1'b1 && remove_idle == 1'b0)

      begin
        remove_idle <= 1'b1;
      end

      // Else write new word on every clock edge.
      else
      begin
        remove_idle <= 1'b0;
	  end
    end
  end // gen_wr_enable

  assign wr_enable   = ~(remove_idle | remove_idle_reg);
 
  // Create the FIFO write address pointer.
  always @(posedge rxrecclk)
  begin : gen_wr_addr
    if (reset === 1'b1)
    begin
      next_wr_addr <= 7'b1000001;
      wr_addr      <= 7'b1000000;
    end
    else if (wr_enable == 1'b1)
    begin
      next_wr_addr <= next_wr_addr + 7'b1;           
      wr_addr      <= next_wr_addr;
	end
  end // gen_wr_addr
		 


  // Convert write address pointer into a gray code
  always @(posedge rxrecclk)
  begin : wr_addrgray_bits
    if (reset === 1'b1)
      wr_addr_gray <= 7'b1100001;
    else
    begin
      wr_addr_gray[6] <= next_wr_addr[6];
      wr_addr_gray[5] <= next_wr_addr[6] ^ next_wr_addr[5];
      wr_addr_gray[4] <= next_wr_addr[5] ^ next_wr_addr[4];
      wr_addr_gray[3] <= next_wr_addr[4] ^ next_wr_addr[3];
      wr_addr_gray[2] <= next_wr_addr[3] ^ next_wr_addr[2];
      wr_addr_gray[1] <= next_wr_addr[2] ^ next_wr_addr[1];
      wr_addr_gray[0] <= next_wr_addr[1] ^ next_wr_addr[0];
    end
  end // wr_addrgray_bits;



  //--------------------------------------------------------------------
  // Instantiate a dual port Block RAM    
  //--------------------------------------------------------------------

  RAMB16_S18_S18 dual_port_block_ram0
  (
    .ADDRA       ({3'b0, wr_addr}),
    .DIA         (wr_data_reg_reg[15:0]),
    .DIPA        (2'b00),
    .DOA         (),
    .DOPA        (),
    .WEA         (wr_enable),
    .ENA         (1'b1),
    .SSRA        (1'b0), 
    .CLKA        (rxrecclk),
    
    .ADDRB       ({3'b0, rd_addr}),
    .DIB         (16'b0),
    .DIPB        (2'b00),
    .DOB         (rd_data[15:0]),  
    .DOPB        (), 
    .WEB         (1'b0),
    .ENB         (1'b1),
    .SSRB        (rxreset),
    .CLKB        (rxusrclk2)       
  );


  //--------------------------------------------------------------------
  // FIFO read logic (Idles are insterted as necessary).
  //--------------------------------------------------------------------

  // Register the BRAM data.
  always @(posedge rxusrclk2)
  begin : reg_rd_data
    if (rxreset == 1'b1)
      rd_data_reg   <= 16'b0;

    else if (rd_enable_reg == 1'b1)
      rd_data_reg   <= rd_data;

  end // reg_rd_data

  //--------------------------------------------------------------------
  // FIFO read logic (Idles are insterted as necessary).
  //--------------------------------------------------------------------



  // Detect /K28.5/ character in upper half of the word read from FIFO
  assign k28p5_rd = (rd_data_reg[7:0] == 8'b10111100 && 
                     rd_data_reg[11] == 1'b1) ? 1'b1 : 1'b0;   

  // Detect /D16.2/ character in lower half of the word read from FIFO
  assign d16p2_rd = (rd_data[7:0] == 8'b01010000 && 
                     rd_data[11] == 1'b0) ? 1'b1 : 1'b0;
                     

  // Create the FIFO read enable: Idles are inserted by pausing the
  // FIFO read_enable whilst an Idle is present on the data.
  always @(posedge rxusrclk2)
  begin : gen_rd_enable
    if (rxreset == 1'b1)
    begin
      even            <= 1'b1;
      insert_idle     <= 1'b0;
      insert_idle_reg <= 1'b0;
      rd_enable_reg   <= 1'b1;
    end
    else
    begin
  
      insert_idle_reg <= insert_idle;
      rd_enable_reg   <= rd_enable;
  
      // Repeat as many /I2/ code groups as required if nearly
      // empty by pausing rd_enable.
      if ((k28p5_rd == 1'b1 && d16p2_rd == 1'b1) && emptying == 1'b1 && insert_idle == 1'b0)
      begin
        insert_idle   <= 1'b1;
        even          <= 1'b0;
      end
  
      // Else read out a new word on every alternative clock edge.
      else 
      begin
         insert_idle  <= 1'b0;
         even         <= ~(even);
  	  end
  	end
  end // gen_rd_enable
  
  assign rd_enable = ~(insert_idle | insert_idle_reg);

           
  // Create the FIFO read address pointer.
  always @(posedge rxusrclk2)
  begin : gen_rd_addr
    if (rxreset == 1'b1)
    begin
      next_rd_addr <= 7'b0000001;
      rd_addr      <= 7'b0000000;
    end
    else if (rd_enable == 1'b1)
    begin
      next_rd_addr <= next_rd_addr + 7'b1;           
      rd_addr      <= next_rd_addr;
    end			  
  end // gen_rd_addr
		 


  // Convert read address pointer into a gray code
  always @(posedge rxusrclk2)
  begin : rd_addrgray_bits
    if (rxreset == 1'b1)
      rd_addr_gray <= 7'b0;
    else if (rd_enable == 1'b1)
    begin
      rd_addr_gray[6] <= next_rd_addr[6];
      rd_addr_gray[5] <= next_rd_addr[6] ^ next_rd_addr[5];
      rd_addr_gray[4] <= next_rd_addr[5] ^ next_rd_addr[4];
      rd_addr_gray[3] <= next_rd_addr[4] ^ next_rd_addr[3];
      rd_addr_gray[2] <= next_rd_addr[3] ^ next_rd_addr[2];
      rd_addr_gray[1] <= next_rd_addr[2] ^ next_rd_addr[1];
      rd_addr_gray[0] <= next_rd_addr[1] ^ next_rd_addr[0];
    end
  end // rd_addrgray_bits

  // Create the output data signals.
  always @(posedge rxusrclk2)
  begin : gen_mux
    if (rxreset == 1'b1)
    begin
      rxchariscomma_usr   <= 1'b0;
      rxcharisk_usr       <= 1'b0;
      rxdisperr_usr       <= 1'b0;
      rxnotintable_usr    <= 1'b0;
      rxrundisp_usr       <= 1'b0;
      rxdata_usr          <= 8'b0;
    end
    else
    begin
      if (rd_enable_reg == 1'b0 && even == 1'b0)
      begin			  
        rxchariscomma_usr <= 1'b0;
        rxcharisk_usr     <= 1'b0;
        rxdisperr_usr     <= 1'b0;
        rxnotintable_usr  <= 1'b0;
        rxrundisp_usr     <= rd_data_reg[8];
        rxdata_usr        <= 8'b01010000;
      end
      else if (rd_enable_reg == 1'b0 && even == 1'b1)
      begin			  
        rxchariscomma_usr <= 1'b1;
        rxcharisk_usr     <= 1'b1;
        rxdisperr_usr     <= 1'b0;
        rxnotintable_usr  <= 1'b0;
        rxrundisp_usr     <= rd_data[8];
        rxdata_usr        <= 8'b10111100;
      end			  
      else			  
      begin			  
        rxchariscomma_usr <= rd_data_reg[12];
        rxcharisk_usr     <= rd_data_reg[11];
        rxdisperr_usr     <= rd_data_reg[10];
        rxnotintable_usr  <= rd_data_reg[9];
        rxrundisp_usr     <= rd_data_reg[8];
        rxdata_usr        <= rd_data_reg[7:0];
      end			  
    end			  
  end // gen_mux

  // Create RocketIO style clock correction status when inserting /
  // removing Idles.
  always @(posedge rxusrclk2)
  begin : gen_rxclkcorcnt
    if (rxreset == 1'b1)
      rxclkcorcnt   <= 3'b0;
    else
    begin
      if (rd_data_reg[13] == 1'b1 && rxclkcorcnt[0] == 1'b0)
         rxclkcorcnt   <= 3'b001;
      else if (insert_idle_reg == 1'b1 && rxclkcorcnt != 3'b111)
         rxclkcorcnt   <= 3'b111;
      else
         rxclkcorcnt   <= 3'b000;
    end			  
  end // gen_rxclkcorcnt

  assign rxclkcorcnt_usr = rxclkcorcnt;



  //--------------------------------------------------------------------
  // Create emptying/full thresholds in read clock domain.
  //--------------------------------------------------------------------



  // Reclock the write address pointer (gray code) onto the read domain.
  // By reclocking the gray code, the worst case senario is that 
  // the reclocked value is only in error by -1, since only 1 bit at a  
  // time changes between gray code increments. 
  always @(posedge rxusrclk2)
  begin : reclock_wr_addrgray
    if (rxreset === 1'b1)
    begin
      rd_wr_addr_gray     <= 7'b1100001;
      rd_wr_addr_gray_reg <= 7'b1100000;
    end
    else
    begin
      rd_wr_addr_gray     <= wr_addr_gray;
      rd_wr_addr_gray_reg <= rd_wr_addr_gray;
    end
  end // reclock_wr_addrgray

   

  // Convert the resync'd Write Address Pointer grey code back to binary
  assign rd_wr_addr[6] = rd_wr_addr_gray_reg[6];

  assign rd_wr_addr[5] = rd_wr_addr_gray_reg[6] ^ rd_wr_addr_gray_reg[5];

  assign rd_wr_addr[4] = rd_wr_addr_gray_reg[6] ^ rd_wr_addr_gray_reg[5] 
                         ^ rd_wr_addr_gray_reg[4];

  assign rd_wr_addr[3] = rd_wr_addr_gray_reg[6] ^ rd_wr_addr_gray_reg[5] 
                         ^ rd_wr_addr_gray_reg[4] ^ rd_wr_addr_gray_reg[3];

  assign rd_wr_addr[2] = rd_wr_addr_gray_reg[6] ^ rd_wr_addr_gray_reg[5] 
                         ^ rd_wr_addr_gray_reg[4] ^ rd_wr_addr_gray_reg[3] 
                         ^ rd_wr_addr_gray_reg[2];

  assign rd_wr_addr[1] = rd_wr_addr_gray_reg[6] ^ rd_wr_addr_gray_reg[5] 
                         ^ rd_wr_addr_gray_reg[4] ^ rd_wr_addr_gray_reg[3] 
                         ^ rd_wr_addr_gray_reg[2] ^ rd_wr_addr_gray_reg[1];

  assign rd_wr_addr[0] = rd_wr_addr_gray_reg[6] ^ rd_wr_addr_gray_reg[5] 
                         ^ rd_wr_addr_gray_reg[4] ^ rd_wr_addr_gray_reg[3] 
                         ^ rd_wr_addr_gray_reg[2] ^ rd_wr_addr_gray_reg[1] 
                         ^ rd_wr_addr_gray_reg[0];



  // Determine the occupancy of the FIFO as observed in the read domain.
  always @(posedge rxusrclk2)
  begin : gen_rd_occupancy
    if (rxreset === 1'b1)
      rd_occupancy <= 7'b1000000;
    else
      rd_occupancy <= rd_wr_addr - rd_addr;
  end // gen_rd_occupancy



  // Set emptying flag if FIFO occupancy is less than LOWER_THRESHOLD. 
  assign emptying = (rd_occupancy < lower_threshold) ? 1'b1 : 1'b0;   



  // Set underflow if FIFO occupancy is less than UNDERFLOW_THRESHOLD. 
  assign underflow = (rd_occupancy < underflow_threshold) ? 1'b1 : 1'b0;   



  // Set overflow if FIFO occupancy is less than OVERFLOW_THRESHOLD. 
  assign overflow = (rd_occupancy > overflow_threshold) ? 1'b1 : 1'b0;   



  // If either an underflow or overflow, assert the buffer error signal.
  // Like the RocketIO, this will persist until a reset is issued.
  always @(posedge rxusrclk2)
  begin : gen_buffer_error
    if (rxreset === 1'b1)
      rxbuferr <= 1'b0;
    else if (overflow == 1'b1 || underflow == 1'b1)
      rxbuferr <= 1'b1;
  end // gen_buffer_error



  //--------------------------------------------------------------------
  // Create emptying/full thresholds in write clock domain.
  //--------------------------------------------------------------------



  // Reclock the read address pointer (gray code) onto the write domain.
  // By reclocking the gray code, the worst case senario is that 
  // the reclocked value is only in error by -1, since only 1 bit at a  
  // time changes between gray code increments. 
  always @(posedge rxrecclk)
  begin : reclock_rd_addrgray
    if (reset === 1'b1)
    begin
      wr_rd_addr_gray     <= 7'b0;
      wr_rd_addr_gray_reg <= 7'b0;
    end
    else
    begin
      wr_rd_addr_gray     <= rd_addr_gray;
      wr_rd_addr_gray_reg <= wr_rd_addr_gray;
    end
  end // reclock_rd_addrgray

   

  // Convert the resync'd Read Address Pointer grey code back to binary

  assign wr_rd_addr[6] = wr_rd_addr_gray_reg[6];

  assign wr_rd_addr[5] = wr_rd_addr_gray_reg[6] ^ wr_rd_addr_gray_reg[5];

  assign wr_rd_addr[4] = wr_rd_addr_gray_reg[6] ^ wr_rd_addr_gray_reg[5] 
                         ^ wr_rd_addr_gray_reg[4];

  assign wr_rd_addr[3] = wr_rd_addr_gray_reg[6] ^ wr_rd_addr_gray_reg[5] 
                         ^ wr_rd_addr_gray_reg[4] ^ wr_rd_addr_gray_reg[3];

  assign wr_rd_addr[2] = wr_rd_addr_gray_reg[6] ^ wr_rd_addr_gray_reg[5] 
                         ^ wr_rd_addr_gray_reg[4] ^ wr_rd_addr_gray_reg[3] 
                         ^ wr_rd_addr_gray_reg[2];

  assign wr_rd_addr[1] = wr_rd_addr_gray_reg[6] ^ wr_rd_addr_gray_reg[5] 
                         ^ wr_rd_addr_gray_reg[4] ^ wr_rd_addr_gray_reg[3] 
                         ^ wr_rd_addr_gray_reg[2] ^ wr_rd_addr_gray_reg[1];

  assign wr_rd_addr[0] = wr_rd_addr_gray_reg[6] ^ wr_rd_addr_gray_reg[5] 
                         ^ wr_rd_addr_gray_reg[4] ^ wr_rd_addr_gray_reg[3] 
                         ^ wr_rd_addr_gray_reg[2] ^ wr_rd_addr_gray_reg[1] 
                         ^ wr_rd_addr_gray_reg[0];
															   


  // Determine the occupancy of the FIFO as observed in the write domain.
  always @(posedge rxrecclk)
  begin : gen_wr_occupancy
    if (reset === 1'b1)
      wr_occupancy <= 7'b1000000;
    else
      wr_occupancy <= wr_addr[6:0] - wr_rd_addr[6:0];
  end // gen_wr_occupancy



  // Set filling flag if FIFO occupancy is greated than UPPER_THRESHOLD. 
  assign filling = (wr_occupancy > upper_threshold) ? 1'b1 : 1'b0;   



endmodule
