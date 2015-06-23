//Legal Notice: (C)2013 Altera Corporation. All rights reserved.  Your
//use of Altera Corporation's design tools, logic functions and other
//software and tools, and its AMPP partner logic functions, and any
//output files any of the foregoing (including device programming or
//simulation files), and any associated documentation or information are
//expressly subject to the terms and conditions of the Altera Program
//License Subscription Agreement or other applicable license agreement,
//including, without limitation, that your use is for the sole purpose
//of programming logic devices manufactured by Altera and sold by Altera
//or its authorized distributors.  Please refer to the applicable
//agreement for further details.

// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module sdram_sdram_controller_input_efifo_module (
                                                   // inputs:
                                                    clk,
                                                    rd,
                                                    reset_n,
                                                    wr,
                                                    wr_data,

                                                   // outputs:
                                                    almost_empty,
                                                    almost_full,
                                                    empty,
                                                    full,
                                                    rd_data
                                                 )
;

  output           almost_empty;
  output           almost_full;
  output           empty;
  output           full;
  output  [ 61: 0] rd_data;
  input            clk;
  input            rd;
  input            reset_n;
  input            wr;
  input   [ 61: 0] wr_data;

  wire             almost_empty;
  wire             almost_full;
  wire             empty;
  reg     [  1: 0] entries;
  reg     [ 61: 0] entry_0;
  reg     [ 61: 0] entry_1;
  wire             full;
  reg              rd_address;
  reg     [ 61: 0] rd_data;
  wire    [  1: 0] rdwr;
  reg              wr_address;
  assign rdwr = {rd, wr};
  assign full = entries == 2;
  assign almost_full = entries >= 1;
  assign empty = entries == 0;
  assign almost_empty = entries <= 1;
  always @(entry_0 or entry_1 or rd_address)
    begin
      case (rd_address) // synthesis parallel_case full_case
      
          1'd0: begin
              rd_data = entry_0;
          end // 1'd0 
      
          1'd1: begin
              rd_data = entry_1;
          end // 1'd1 
      
          default: begin
          end // default
      
      endcase // rd_address
    end


  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
        begin
          wr_address <= 0;
          rd_address <= 0;
          entries <= 0;
        end
      else 
        case (rdwr) // synthesis parallel_case full_case
        
            2'd1: begin
                // Write data
                if (!full)
                  begin
                    entries <= entries + 1;
                    wr_address <= (wr_address == 1) ? 0 : (wr_address + 1);
                  end
            end // 2'd1 
        
            2'd2: begin
                // Read data
                if (!empty)
                  begin
                    entries <= entries - 1;
                    rd_address <= (rd_address == 1) ? 0 : (rd_address + 1);
                  end
            end // 2'd2 
        
            2'd3: begin
                wr_address <= (wr_address == 1) ? 0 : (wr_address + 1);
                rd_address <= (rd_address == 1) ? 0 : (rd_address + 1);
            end // 2'd3 
        
            default: begin
            end // default
        
        endcase // rdwr
    end


  always @(posedge clk)
    begin
      //Write data
      if (wr & !full)
          case (wr_address) // synthesis parallel_case full_case
          
              1'd0: begin
                  entry_0 <= wr_data;
              end // 1'd0 
          
              1'd1: begin
                  entry_1 <= wr_data;
              end // 1'd1 
          
              default: begin
              end // default
          
          endcase // wr_address
    end



endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module sdram_sdram_controller (
                                // inputs:
                                 az_addr,
                                 az_be_n,
                                 az_cs,
                                 az_data,
                                 az_rd_n,
                                 az_wr_n,
                                 clk,
                                 reset_n,

                                // outputs:
                                 za_data,
                                 za_valid,
                                 za_waitrequest,
                                 zs_addr,
                                 zs_ba,
                                 zs_cas_n,
                                 zs_cke,
                                 zs_cs_n,
                                 zs_dq,
                                 zs_dqm,
                                 zs_ras_n,
                                 zs_we_n
                              )
;

  output  [ 31: 0] za_data;
  output           za_valid;
  output           za_waitrequest;
  output  [ 12: 0] zs_addr;
  output  [  1: 0] zs_ba;
  output           zs_cas_n;
  output           zs_cke;
  output           zs_cs_n;
  inout   [ 31: 0] zs_dq;
  output  [  3: 0] zs_dqm;
  output           zs_ras_n;
  output           zs_we_n;
  input   [ 24: 0] az_addr;
  input   [  3: 0] az_be_n;
  input            az_cs;
  input   [ 31: 0] az_data;
  input            az_rd_n;
  input            az_wr_n;
  input            clk;
  input            reset_n;

  wire    [ 23: 0] CODE;
  reg              ack_refresh_request;
  reg     [ 24: 0] active_addr;
  wire    [  1: 0] active_bank;
  reg              active_cs_n;
  reg     [ 31: 0] active_data;
  reg     [  3: 0] active_dqm;
  reg              active_rnw;
  wire             almost_empty;
  wire             almost_full;
  wire             bank_match;
  wire    [  9: 0] cas_addr;
  wire             clk_en;
  wire    [  3: 0] cmd_all;
  wire    [  2: 0] cmd_code;
  wire             cs_n;
  wire             csn_decode;
  wire             csn_match;
  wire    [ 24: 0] f_addr;
  wire    [  1: 0] f_bank;
  wire             f_cs_n;
  wire    [ 31: 0] f_data;
  wire    [  3: 0] f_dqm;
  wire             f_empty;
  reg              f_pop;
  wire             f_rnw;
  wire             f_select;
  wire    [ 61: 0] fifo_read_data;
  reg     [ 12: 0] i_addr;
  reg     [  3: 0] i_cmd;
  reg     [  2: 0] i_count;
  reg     [  2: 0] i_next;
  reg     [  2: 0] i_refs;
  reg     [  2: 0] i_state;
  reg              init_done;
  reg     [ 12: 0] m_addr /* synthesis ALTERA_ATTRIBUTE = "FAST_OUTPUT_REGISTER=ON"  */;
  reg     [  1: 0] m_bank /* synthesis ALTERA_ATTRIBUTE = "FAST_OUTPUT_REGISTER=ON"  */;
  reg     [  3: 0] m_cmd /* synthesis ALTERA_ATTRIBUTE = "FAST_OUTPUT_REGISTER=ON"  */;
  reg     [  2: 0] m_count;
  reg     [ 31: 0] m_data /* synthesis ALTERA_ATTRIBUTE = "FAST_OUTPUT_REGISTER=ON ; FAST_OUTPUT_ENABLE_REGISTER=ON"  */;
  reg     [  3: 0] m_dqm /* synthesis ALTERA_ATTRIBUTE = "FAST_OUTPUT_REGISTER=ON"  */;
  reg     [  8: 0] m_next;
  reg     [  8: 0] m_state;
  reg              oe /* synthesis ALTERA_ATTRIBUTE = "FAST_OUTPUT_ENABLE_REGISTER=ON"  */;
  wire             pending;
  wire             rd_strobe;
  reg     [  2: 0] rd_valid;
  reg     [ 13: 0] refresh_counter;
  reg              refresh_request;
  wire             rnw_match;
  wire             row_match;
  wire    [ 23: 0] txt_code;
  reg              za_cannotrefresh;
  reg     [ 31: 0] za_data /* synthesis ALTERA_ATTRIBUTE = "FAST_INPUT_REGISTER=ON"  */;
  reg              za_valid;
  wire             za_waitrequest;
  wire    [ 12: 0] zs_addr;
  wire    [  1: 0] zs_ba;
  wire             zs_cas_n;
  wire             zs_cke;
  wire             zs_cs_n;
  wire    [ 31: 0] zs_dq;
  wire    [  3: 0] zs_dqm;
  wire             zs_ras_n;
  wire             zs_we_n;
  assign clk_en = 1;
  //s1, which is an e_avalon_slave
  assign {zs_cs_n, zs_ras_n, zs_cas_n, zs_we_n} = m_cmd;
  assign zs_addr = m_addr;
  assign zs_cke = clk_en;
  assign zs_dq = oe?m_data:{32{1'bz}};
  assign zs_dqm = m_dqm;
  assign zs_ba = m_bank;
  assign f_select = f_pop & pending;
  assign f_cs_n = 1'b0;
  assign cs_n = f_select ? f_cs_n : active_cs_n;
  assign csn_decode = cs_n;
  assign {f_rnw, f_addr, f_dqm, f_data} = fifo_read_data;
  sdram_sdram_controller_input_efifo_module the_sdram_sdram_controller_input_efifo_module
    (
      .almost_empty (almost_empty),
      .almost_full  (almost_full),
      .clk          (clk),
      .empty        (f_empty),
      .full         (za_waitrequest),
      .rd           (f_select),
      .rd_data      (fifo_read_data),
      .reset_n      (reset_n),
      .wr           ((~az_wr_n | ~az_rd_n) & !za_waitrequest),
      .wr_data      ({az_wr_n, az_addr, az_wr_n ? 4'b0 : az_be_n, az_data})
    );

  assign f_bank = {f_addr[24],f_addr[10]};
  // Refresh/init counter.
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          refresh_counter <= 10000;
      else if (refresh_counter == 0)
          refresh_counter <= 390;
      else 
        refresh_counter <= refresh_counter - 1'b1;
    end


  // Refresh request signal.
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          refresh_request <= 0;
		else
          refresh_request <= ((refresh_counter == 0) | refresh_request) & ~ack_refresh_request & init_done;
    end


  // Generate an Interrupt if two ref_reqs occur before one ack_refresh_request
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          za_cannotrefresh <= 0;
      else 
          za_cannotrefresh <= (refresh_counter == 0) & refresh_request;
    end


  // Initialization-done flag.
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          init_done <= 0;
      else 
			init_done <= init_done | (i_state == 3'b101);
    end


  // **** Init FSM ****
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
        begin
          i_state <= 3'b000;
          i_next <= 3'b000;
          i_cmd <= 4'b1111;
          i_addr <= {13{1'b1}};
          i_count <= {3{1'b0}};
        end
      else 
        begin
          i_addr <= {13{1'b1}};
          case (i_state) // synthesis parallel_case full_case
          
              3'b000: begin
                  i_cmd <= 4'b1111;
                  i_refs <= 3'b0;
                  //Wait for refresh count-down after reset
                  if (refresh_counter == 0)
                      i_state <= 3'b001;
              end // 3'b000 
          
              3'b001: begin
                  i_state <= 3'b011;
                  i_cmd <= {{1{1'b0}},3'h2};
                  i_count <= 0;
                  i_next <= 3'b010;
              end // 3'b001 
          
              3'b010: begin
                  i_cmd <= {{1{1'b0}},3'h1};
                  i_refs <= i_refs + 1'b1;
                  i_state <= 3'b011;
                  i_count <= 3;
                  // Count up init_refresh_commands
                  if (i_refs == 3'h1)
                      i_next <= 3'b111;
                  else 
                    i_next <= 3'b010;
              end // 3'b010 
          
              3'b011: begin
                  i_cmd <= {{1{1'b0}},3'h7};
                  //WAIT til safe to Proceed...
                  if (i_count > 1)
                      i_count <= i_count - 1'b1;
                  else 
                    i_state <= i_next;
              end // 3'b011 
          
              3'b101: begin
                  i_state <= 3'b101;
              end // 3'b101 
          
              3'b111: begin
                  i_state <= 3'b011;
                  i_cmd <= {{1{1'b0}},3'h0};
                  i_addr <= {{3{1'b0}},1'b0,2'b00,3'h3,4'h0};
                  i_count <= 4;
                  i_next <= 3'b101;
              end // 3'b111 
          
              default: begin
                  i_state <= 3'b000;
              end // default
          
          endcase // i_state
        end
    end


  assign active_bank = {active_addr[24],active_addr[10]};
  assign csn_match = active_cs_n == f_cs_n;
  assign rnw_match = active_rnw == f_rnw;
  assign bank_match = active_bank == f_bank;
  assign row_match = {active_addr[23 : 11]} == {f_addr[23 : 11]};
  assign pending = csn_match && rnw_match && bank_match && row_match && !f_empty;
  assign cas_addr = f_select ? { {3{1'b0}},f_addr[9 : 0] } : { {3{1'b0}},active_addr[9 : 0] };
  // **** Main FSM ****
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
        begin
          m_state <= 9'b000000001;
          m_next <= 9'b000000001;
          m_cmd <= 4'b1111;
          m_bank <= 2'b00;
          m_addr <= 13'b0000000000000;
          m_data <= 32'b00000000000000000000000000000000;
          m_dqm <= 4'b0000;
          m_count <= 3'b000;
          ack_refresh_request <= 1'b0;
          f_pop <= 1'b0;
          oe <= 1'b0;
        end
      else 
        begin
          f_pop <= 1'b0;
          oe <= 1'b0;
          case (m_state) // synthesis parallel_case full_case
          
              9'b000000001: begin
                  //Wait for init-fsm to be done...
                  if (init_done)
                    begin
                      //Hold bus if another cycle ended to arf.
                      if (refresh_request)
                          m_cmd <= {{1{1'b0}},3'h7};
                      else 
                        m_cmd <= 4'b1111;
                      ack_refresh_request <= 1'b0;
                      //Wait for a read/write request.
                      if (refresh_request)
                        begin
                          m_state <= 9'b001000000;
                          m_next <= 9'b010000000;
                          m_count <= 0;
                          active_cs_n <= 1'b1;
                        end
                      else if (!f_empty)
                        begin
                          f_pop <= 1'b1;
                          active_cs_n <= f_cs_n;
                          active_rnw <= f_rnw;
                          active_addr <= f_addr;
                          active_data <= f_data;
                          active_dqm <= f_dqm;
                          m_state <= 9'b000000010;
                        end
                    end
                  else 
                    begin
                      m_addr <= i_addr;
                      m_state <= 9'b000000001;
                      m_next <= 9'b000000001;
                      m_cmd <= i_cmd;
                    end
              end // 9'b000000001 
          
              9'b000000010: begin
                  m_state <= 9'b000000100;
                  m_cmd <= {csn_decode,3'h3};
                  m_bank <= active_bank;
                  m_addr <= active_addr[23 : 11];
                  m_data <= active_data;
                  m_dqm <= active_dqm;
                  m_count <= 1;
                  m_next <= active_rnw ? 9'b000001000 : 9'b000010000;
              end // 9'b000000010 
          
              9'b000000100: begin
                  // precharge all if arf, else precharge csn_decode
                  if (m_next == 9'b010000000)
                      m_cmd <= {{1{1'b0}},3'h7};
                  else 
                    m_cmd <= {csn_decode,3'h7};
                  //Count down til safe to Proceed...
                  if (m_count > 1)
                      m_count <= m_count - 1'b1;
                  else 
                    m_state <= m_next;
              end // 9'b000000100 
          
              9'b000001000: begin
                  m_cmd <= {csn_decode,3'h5};
                  m_bank <= f_select ? f_bank : active_bank;
                  m_dqm <= f_select ? f_dqm  : active_dqm;
                  m_addr <= cas_addr;
                  //Do we have a transaction pending?
                  if (pending)
                    begin
                      //if we need to ARF, bail, else spin
                      if (refresh_request)
                        begin
                          m_state <= 9'b000000100;
                          m_next <= 9'b000000001;
                          m_count <= 2;
                        end
                      else 
                        begin
                          f_pop <= 1'b1;
                          active_cs_n <= f_cs_n;
                          active_rnw <= f_rnw;
                          active_addr <= f_addr;
                          active_data <= f_data;
                          active_dqm <= f_dqm;
                        end
                    end
                  else 
                    begin
                      //correctly end RD spin cycle if fifo mt
                      if (~pending & f_pop)
                          m_cmd <= {csn_decode,3'h7};
                      m_state <= 9'b100000000;
                    end
              end // 9'b000001000 
          
              9'b000010000: begin
                  m_cmd <= {csn_decode,3'h4};
                  oe <= 1'b1;
                  m_data <= f_select ? f_data : active_data;
                  m_dqm <= f_select ? f_dqm  : active_dqm;
                  m_bank <= f_select ? f_bank : active_bank;
                  m_addr <= cas_addr;
                  //Do we have a transaction pending?
                  if (pending)
                    begin
                      //if we need to ARF, bail, else spin
                      if (refresh_request)
                        begin
                          m_state <= 9'b000000100;
                          m_next <= 9'b000000001;
                          m_count <= 1;
                        end
                      else 
                        begin
                          f_pop <= 1'b1;
                          active_cs_n <= f_cs_n;
                          active_rnw <= f_rnw;
                          active_addr <= f_addr;
                          active_data <= f_data;
                          active_dqm <= f_dqm;
                        end
                    end
                  else 
                    begin
                      //correctly end WR spin cycle if fifo empty
                      if (~pending & f_pop)
                        begin
                          m_cmd <= {csn_decode,3'h7};
                          oe <= 1'b0;
                        end
                      m_state <= 9'b100000000;
                    end
              end // 9'b000010000 
          
              9'b000100000: begin
                  m_cmd <= {csn_decode,3'h7};
                  //Count down til safe to Proceed...
                  if (m_count > 1)
                      m_count <= m_count - 1'b1;
                  else 
                    begin
                      m_state <= 9'b001000000;
                      m_count <= 0;
                    end
              end // 9'b000100000 
          
              9'b001000000: begin
                  m_state <= 9'b000000100;
                  m_addr <= {13{1'b1}};
                  // precharge all if arf, else precharge csn_decode
                  if (refresh_request)
                      m_cmd <= {{1{1'b0}},3'h2};
                  else 
                    m_cmd <= {csn_decode,3'h2};
              end // 9'b001000000 
          
              9'b010000000: begin
                  ack_refresh_request <= 1'b1;
                  m_state <= 9'b000000100;
                  m_cmd <= {{1{1'b0}},3'h1};
                  m_count <= 3;
                  m_next <= 9'b000000001;
              end // 9'b010000000 
          
              9'b100000000: begin
                  m_cmd <= {csn_decode,3'h7};
                  //if we need to ARF, bail, else spin
                  if (refresh_request)
                    begin
                      m_state <= 9'b000000100;
                      m_next <= 9'b000000001;
                      m_count <= 1;
                    end
                  else //wait for fifo to have contents
                  if (!f_empty)
                      //Are we 'pending' yet?
                      if (csn_match && rnw_match && bank_match && row_match)
                        begin
                          m_state <= f_rnw ? 9'b000001000 : 9'b000010000;
                          f_pop <= 1'b1;
                          active_cs_n <= f_cs_n;
                          active_rnw <= f_rnw;
                          active_addr <= f_addr;
                          active_data <= f_data;
                          active_dqm <= f_dqm;
                        end
                      else 
                        begin
                          m_state <= 9'b000100000;
                          m_next <= 9'b000000001;
                          m_count <= 1;
                        end
              end // 9'b100000000 
          
              // synthesis translate_off
          
              default: begin
                  m_state <= m_state;
                  m_cmd <= 4'b1111;
                  f_pop <= 1'b0;
                  oe <= 1'b0;
              end // default
          
              // synthesis translate_on
          endcase // m_state
        end
    end


  assign rd_strobe = m_cmd[2 : 0] == 3'h5;
  //Track RD Req's based on cas_latency w/shift reg
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          rd_valid <= {3{1'b0}};
      else 
        rd_valid <= (rd_valid << 1) | { {2{1'b0}}, rd_strobe };
    end


  // Register dq data.
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          za_data <= 0;
      else 
        za_data <= zs_dq;
    end


  // Delay za_valid to match registered data.
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          za_valid <= 0;
      else 
          za_valid <= rd_valid[2];
    end


  assign cmd_code = m_cmd[2 : 0];
  assign cmd_all = m_cmd;

//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  assign txt_code = (cmd_code == 3'h0)? 24'h4c4d52 :
    (cmd_code == 3'h1)? 24'h415246 :
    (cmd_code == 3'h2)? 24'h505245 :
    (cmd_code == 3'h3)? 24'h414354 :
    (cmd_code == 3'h4)? 24'h205752 :
    (cmd_code == 3'h5)? 24'h205244 :
    (cmd_code == 3'h6)? 24'h425354 :
    (cmd_code == 3'h7)? 24'h4e4f50 :
    24'h424144;

  assign CODE = &(cmd_all|4'h7) ? 24'h494e48 : txt_code;

//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule

