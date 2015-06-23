//megafunction wizard: %Altera SOPC Builder%
//GENERATION: STANDARD
//VERSION: WM1.0


//Legal Notice: (C)2012 Altera Corporation. All rights reserved.  Your
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

module cpu_1_jtag_debug_module_arbitrator (
                                            // inputs:
                                             clk,
                                             cpu_1_data_master_address_to_slave,
                                             cpu_1_data_master_byteenable,
                                             cpu_1_data_master_debugaccess,
                                             cpu_1_data_master_latency_counter,
                                             cpu_1_data_master_read,
                                             cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register,
                                             cpu_1_data_master_write,
                                             cpu_1_data_master_writedata,
                                             cpu_1_instruction_master_address_to_slave,
                                             cpu_1_instruction_master_latency_counter,
                                             cpu_1_instruction_master_read,
                                             cpu_1_instruction_master_read_data_valid_sdram_1_s1_shift_register,
                                             cpu_1_jtag_debug_module_readdata,
                                             cpu_1_jtag_debug_module_resetrequest,
                                             reset_n,

                                            // outputs:
                                             cpu_1_data_master_granted_cpu_1_jtag_debug_module,
                                             cpu_1_data_master_qualified_request_cpu_1_jtag_debug_module,
                                             cpu_1_data_master_read_data_valid_cpu_1_jtag_debug_module,
                                             cpu_1_data_master_requests_cpu_1_jtag_debug_module,
                                             cpu_1_instruction_master_granted_cpu_1_jtag_debug_module,
                                             cpu_1_instruction_master_qualified_request_cpu_1_jtag_debug_module,
                                             cpu_1_instruction_master_read_data_valid_cpu_1_jtag_debug_module,
                                             cpu_1_instruction_master_requests_cpu_1_jtag_debug_module,
                                             cpu_1_jtag_debug_module_address,
                                             cpu_1_jtag_debug_module_begintransfer,
                                             cpu_1_jtag_debug_module_byteenable,
                                             cpu_1_jtag_debug_module_chipselect,
                                             cpu_1_jtag_debug_module_debugaccess,
                                             cpu_1_jtag_debug_module_readdata_from_sa,
                                             cpu_1_jtag_debug_module_reset_n,
                                             cpu_1_jtag_debug_module_resetrequest_from_sa,
                                             cpu_1_jtag_debug_module_write,
                                             cpu_1_jtag_debug_module_writedata,
                                             d1_cpu_1_jtag_debug_module_end_xfer
                                          )
;

  output           cpu_1_data_master_granted_cpu_1_jtag_debug_module;
  output           cpu_1_data_master_qualified_request_cpu_1_jtag_debug_module;
  output           cpu_1_data_master_read_data_valid_cpu_1_jtag_debug_module;
  output           cpu_1_data_master_requests_cpu_1_jtag_debug_module;
  output           cpu_1_instruction_master_granted_cpu_1_jtag_debug_module;
  output           cpu_1_instruction_master_qualified_request_cpu_1_jtag_debug_module;
  output           cpu_1_instruction_master_read_data_valid_cpu_1_jtag_debug_module;
  output           cpu_1_instruction_master_requests_cpu_1_jtag_debug_module;
  output  [  8: 0] cpu_1_jtag_debug_module_address;
  output           cpu_1_jtag_debug_module_begintransfer;
  output  [  3: 0] cpu_1_jtag_debug_module_byteenable;
  output           cpu_1_jtag_debug_module_chipselect;
  output           cpu_1_jtag_debug_module_debugaccess;
  output  [ 31: 0] cpu_1_jtag_debug_module_readdata_from_sa;
  output           cpu_1_jtag_debug_module_reset_n;
  output           cpu_1_jtag_debug_module_resetrequest_from_sa;
  output           cpu_1_jtag_debug_module_write;
  output  [ 31: 0] cpu_1_jtag_debug_module_writedata;
  output           d1_cpu_1_jtag_debug_module_end_xfer;
  input            clk;
  input   [ 24: 0] cpu_1_data_master_address_to_slave;
  input   [  3: 0] cpu_1_data_master_byteenable;
  input            cpu_1_data_master_debugaccess;
  input            cpu_1_data_master_latency_counter;
  input            cpu_1_data_master_read;
  input            cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register;
  input            cpu_1_data_master_write;
  input   [ 31: 0] cpu_1_data_master_writedata;
  input   [ 24: 0] cpu_1_instruction_master_address_to_slave;
  input            cpu_1_instruction_master_latency_counter;
  input            cpu_1_instruction_master_read;
  input            cpu_1_instruction_master_read_data_valid_sdram_1_s1_shift_register;
  input   [ 31: 0] cpu_1_jtag_debug_module_readdata;
  input            cpu_1_jtag_debug_module_resetrequest;
  input            reset_n;

  wire             cpu_1_data_master_arbiterlock;
  wire             cpu_1_data_master_arbiterlock2;
  wire             cpu_1_data_master_continuerequest;
  wire             cpu_1_data_master_granted_cpu_1_jtag_debug_module;
  wire             cpu_1_data_master_qualified_request_cpu_1_jtag_debug_module;
  wire             cpu_1_data_master_read_data_valid_cpu_1_jtag_debug_module;
  wire             cpu_1_data_master_requests_cpu_1_jtag_debug_module;
  wire             cpu_1_data_master_saved_grant_cpu_1_jtag_debug_module;
  wire             cpu_1_instruction_master_arbiterlock;
  wire             cpu_1_instruction_master_arbiterlock2;
  wire             cpu_1_instruction_master_continuerequest;
  wire             cpu_1_instruction_master_granted_cpu_1_jtag_debug_module;
  wire             cpu_1_instruction_master_qualified_request_cpu_1_jtag_debug_module;
  wire             cpu_1_instruction_master_read_data_valid_cpu_1_jtag_debug_module;
  wire             cpu_1_instruction_master_requests_cpu_1_jtag_debug_module;
  wire             cpu_1_instruction_master_saved_grant_cpu_1_jtag_debug_module;
  wire    [  8: 0] cpu_1_jtag_debug_module_address;
  wire             cpu_1_jtag_debug_module_allgrants;
  wire             cpu_1_jtag_debug_module_allow_new_arb_cycle;
  wire             cpu_1_jtag_debug_module_any_bursting_master_saved_grant;
  wire             cpu_1_jtag_debug_module_any_continuerequest;
  reg     [  1: 0] cpu_1_jtag_debug_module_arb_addend;
  wire             cpu_1_jtag_debug_module_arb_counter_enable;
  reg     [  1: 0] cpu_1_jtag_debug_module_arb_share_counter;
  wire    [  1: 0] cpu_1_jtag_debug_module_arb_share_counter_next_value;
  wire    [  1: 0] cpu_1_jtag_debug_module_arb_share_set_values;
  wire    [  1: 0] cpu_1_jtag_debug_module_arb_winner;
  wire             cpu_1_jtag_debug_module_arbitration_holdoff_internal;
  wire             cpu_1_jtag_debug_module_beginbursttransfer_internal;
  wire             cpu_1_jtag_debug_module_begins_xfer;
  wire             cpu_1_jtag_debug_module_begintransfer;
  wire    [  3: 0] cpu_1_jtag_debug_module_byteenable;
  wire             cpu_1_jtag_debug_module_chipselect;
  wire    [  3: 0] cpu_1_jtag_debug_module_chosen_master_double_vector;
  wire    [  1: 0] cpu_1_jtag_debug_module_chosen_master_rot_left;
  wire             cpu_1_jtag_debug_module_debugaccess;
  wire             cpu_1_jtag_debug_module_end_xfer;
  wire             cpu_1_jtag_debug_module_firsttransfer;
  wire    [  1: 0] cpu_1_jtag_debug_module_grant_vector;
  wire             cpu_1_jtag_debug_module_in_a_read_cycle;
  wire             cpu_1_jtag_debug_module_in_a_write_cycle;
  wire    [  1: 0] cpu_1_jtag_debug_module_master_qreq_vector;
  wire             cpu_1_jtag_debug_module_non_bursting_master_requests;
  wire    [ 31: 0] cpu_1_jtag_debug_module_readdata_from_sa;
  reg              cpu_1_jtag_debug_module_reg_firsttransfer;
  wire             cpu_1_jtag_debug_module_reset_n;
  wire             cpu_1_jtag_debug_module_resetrequest_from_sa;
  reg     [  1: 0] cpu_1_jtag_debug_module_saved_chosen_master_vector;
  reg              cpu_1_jtag_debug_module_slavearbiterlockenable;
  wire             cpu_1_jtag_debug_module_slavearbiterlockenable2;
  wire             cpu_1_jtag_debug_module_unreg_firsttransfer;
  wire             cpu_1_jtag_debug_module_waits_for_read;
  wire             cpu_1_jtag_debug_module_waits_for_write;
  wire             cpu_1_jtag_debug_module_write;
  wire    [ 31: 0] cpu_1_jtag_debug_module_writedata;
  reg              d1_cpu_1_jtag_debug_module_end_xfer;
  reg              d1_reasons_to_wait;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_cpu_1_jtag_debug_module;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  reg              last_cycle_cpu_1_data_master_granted_slave_cpu_1_jtag_debug_module;
  reg              last_cycle_cpu_1_instruction_master_granted_slave_cpu_1_jtag_debug_module;
  wire    [ 24: 0] shifted_address_to_cpu_1_jtag_debug_module_from_cpu_1_data_master;
  wire    [ 24: 0] shifted_address_to_cpu_1_jtag_debug_module_from_cpu_1_instruction_master;
  wire             wait_for_cpu_1_jtag_debug_module_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~cpu_1_jtag_debug_module_end_xfer;
    end


  assign cpu_1_jtag_debug_module_begins_xfer = ~d1_reasons_to_wait & ((cpu_1_data_master_qualified_request_cpu_1_jtag_debug_module | cpu_1_instruction_master_qualified_request_cpu_1_jtag_debug_module));
  //assign cpu_1_jtag_debug_module_readdata_from_sa = cpu_1_jtag_debug_module_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign cpu_1_jtag_debug_module_readdata_from_sa = cpu_1_jtag_debug_module_readdata;

  assign cpu_1_data_master_requests_cpu_1_jtag_debug_module = ({cpu_1_data_master_address_to_slave[24 : 11] , 11'b0} == 25'h1000800) & (cpu_1_data_master_read | cpu_1_data_master_write);
  //cpu_1_jtag_debug_module_arb_share_counter set values, which is an e_mux
  assign cpu_1_jtag_debug_module_arb_share_set_values = 1;

  //cpu_1_jtag_debug_module_non_bursting_master_requests mux, which is an e_mux
  assign cpu_1_jtag_debug_module_non_bursting_master_requests = cpu_1_data_master_requests_cpu_1_jtag_debug_module |
    cpu_1_instruction_master_requests_cpu_1_jtag_debug_module |
    cpu_1_data_master_requests_cpu_1_jtag_debug_module |
    cpu_1_instruction_master_requests_cpu_1_jtag_debug_module;

  //cpu_1_jtag_debug_module_any_bursting_master_saved_grant mux, which is an e_mux
  assign cpu_1_jtag_debug_module_any_bursting_master_saved_grant = 0;

  //cpu_1_jtag_debug_module_arb_share_counter_next_value assignment, which is an e_assign
  assign cpu_1_jtag_debug_module_arb_share_counter_next_value = cpu_1_jtag_debug_module_firsttransfer ? (cpu_1_jtag_debug_module_arb_share_set_values - 1) : |cpu_1_jtag_debug_module_arb_share_counter ? (cpu_1_jtag_debug_module_arb_share_counter - 1) : 0;

  //cpu_1_jtag_debug_module_allgrants all slave grants, which is an e_mux
  assign cpu_1_jtag_debug_module_allgrants = (|cpu_1_jtag_debug_module_grant_vector) |
    (|cpu_1_jtag_debug_module_grant_vector) |
    (|cpu_1_jtag_debug_module_grant_vector) |
    (|cpu_1_jtag_debug_module_grant_vector);

  //cpu_1_jtag_debug_module_end_xfer assignment, which is an e_assign
  assign cpu_1_jtag_debug_module_end_xfer = ~(cpu_1_jtag_debug_module_waits_for_read | cpu_1_jtag_debug_module_waits_for_write);

  //end_xfer_arb_share_counter_term_cpu_1_jtag_debug_module arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_cpu_1_jtag_debug_module = cpu_1_jtag_debug_module_end_xfer & (~cpu_1_jtag_debug_module_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //cpu_1_jtag_debug_module_arb_share_counter arbitration counter enable, which is an e_assign
  assign cpu_1_jtag_debug_module_arb_counter_enable = (end_xfer_arb_share_counter_term_cpu_1_jtag_debug_module & cpu_1_jtag_debug_module_allgrants) | (end_xfer_arb_share_counter_term_cpu_1_jtag_debug_module & ~cpu_1_jtag_debug_module_non_bursting_master_requests);

  //cpu_1_jtag_debug_module_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_1_jtag_debug_module_arb_share_counter <= 0;
      else if (cpu_1_jtag_debug_module_arb_counter_enable)
          cpu_1_jtag_debug_module_arb_share_counter <= cpu_1_jtag_debug_module_arb_share_counter_next_value;
    end


  //cpu_1_jtag_debug_module_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_1_jtag_debug_module_slavearbiterlockenable <= 0;
      else if ((|cpu_1_jtag_debug_module_master_qreq_vector & end_xfer_arb_share_counter_term_cpu_1_jtag_debug_module) | (end_xfer_arb_share_counter_term_cpu_1_jtag_debug_module & ~cpu_1_jtag_debug_module_non_bursting_master_requests))
          cpu_1_jtag_debug_module_slavearbiterlockenable <= |cpu_1_jtag_debug_module_arb_share_counter_next_value;
    end


  //cpu_1/data_master cpu_1/jtag_debug_module arbiterlock, which is an e_assign
  assign cpu_1_data_master_arbiterlock = cpu_1_jtag_debug_module_slavearbiterlockenable & cpu_1_data_master_continuerequest;

  //cpu_1_jtag_debug_module_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign cpu_1_jtag_debug_module_slavearbiterlockenable2 = |cpu_1_jtag_debug_module_arb_share_counter_next_value;

  //cpu_1/data_master cpu_1/jtag_debug_module arbiterlock2, which is an e_assign
  assign cpu_1_data_master_arbiterlock2 = cpu_1_jtag_debug_module_slavearbiterlockenable2 & cpu_1_data_master_continuerequest;

  //cpu_1/instruction_master cpu_1/jtag_debug_module arbiterlock, which is an e_assign
  assign cpu_1_instruction_master_arbiterlock = cpu_1_jtag_debug_module_slavearbiterlockenable & cpu_1_instruction_master_continuerequest;

  //cpu_1/instruction_master cpu_1/jtag_debug_module arbiterlock2, which is an e_assign
  assign cpu_1_instruction_master_arbiterlock2 = cpu_1_jtag_debug_module_slavearbiterlockenable2 & cpu_1_instruction_master_continuerequest;

  //cpu_1/instruction_master granted cpu_1/jtag_debug_module last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          last_cycle_cpu_1_instruction_master_granted_slave_cpu_1_jtag_debug_module <= 0;
      else 
        last_cycle_cpu_1_instruction_master_granted_slave_cpu_1_jtag_debug_module <= cpu_1_instruction_master_saved_grant_cpu_1_jtag_debug_module ? 1 : (cpu_1_jtag_debug_module_arbitration_holdoff_internal | ~cpu_1_instruction_master_requests_cpu_1_jtag_debug_module) ? 0 : last_cycle_cpu_1_instruction_master_granted_slave_cpu_1_jtag_debug_module;
    end


  //cpu_1_instruction_master_continuerequest continued request, which is an e_mux
  assign cpu_1_instruction_master_continuerequest = last_cycle_cpu_1_instruction_master_granted_slave_cpu_1_jtag_debug_module & cpu_1_instruction_master_requests_cpu_1_jtag_debug_module;

  //cpu_1_jtag_debug_module_any_continuerequest at least one master continues requesting, which is an e_mux
  assign cpu_1_jtag_debug_module_any_continuerequest = cpu_1_instruction_master_continuerequest |
    cpu_1_data_master_continuerequest;

  assign cpu_1_data_master_qualified_request_cpu_1_jtag_debug_module = cpu_1_data_master_requests_cpu_1_jtag_debug_module & ~((cpu_1_data_master_read & ((cpu_1_data_master_latency_counter != 0) | (|cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register))) | cpu_1_instruction_master_arbiterlock);
  //local readdatavalid cpu_1_data_master_read_data_valid_cpu_1_jtag_debug_module, which is an e_mux
  assign cpu_1_data_master_read_data_valid_cpu_1_jtag_debug_module = cpu_1_data_master_granted_cpu_1_jtag_debug_module & cpu_1_data_master_read & ~cpu_1_jtag_debug_module_waits_for_read;

  //cpu_1_jtag_debug_module_writedata mux, which is an e_mux
  assign cpu_1_jtag_debug_module_writedata = cpu_1_data_master_writedata;

  assign cpu_1_instruction_master_requests_cpu_1_jtag_debug_module = (({cpu_1_instruction_master_address_to_slave[24 : 11] , 11'b0} == 25'h1000800) & (cpu_1_instruction_master_read)) & cpu_1_instruction_master_read;
  //cpu_1/data_master granted cpu_1/jtag_debug_module last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          last_cycle_cpu_1_data_master_granted_slave_cpu_1_jtag_debug_module <= 0;
      else 
        last_cycle_cpu_1_data_master_granted_slave_cpu_1_jtag_debug_module <= cpu_1_data_master_saved_grant_cpu_1_jtag_debug_module ? 1 : (cpu_1_jtag_debug_module_arbitration_holdoff_internal | ~cpu_1_data_master_requests_cpu_1_jtag_debug_module) ? 0 : last_cycle_cpu_1_data_master_granted_slave_cpu_1_jtag_debug_module;
    end


  //cpu_1_data_master_continuerequest continued request, which is an e_mux
  assign cpu_1_data_master_continuerequest = last_cycle_cpu_1_data_master_granted_slave_cpu_1_jtag_debug_module & cpu_1_data_master_requests_cpu_1_jtag_debug_module;

  assign cpu_1_instruction_master_qualified_request_cpu_1_jtag_debug_module = cpu_1_instruction_master_requests_cpu_1_jtag_debug_module & ~((cpu_1_instruction_master_read & ((cpu_1_instruction_master_latency_counter != 0) | (|cpu_1_instruction_master_read_data_valid_sdram_1_s1_shift_register))) | cpu_1_data_master_arbiterlock);
  //local readdatavalid cpu_1_instruction_master_read_data_valid_cpu_1_jtag_debug_module, which is an e_mux
  assign cpu_1_instruction_master_read_data_valid_cpu_1_jtag_debug_module = cpu_1_instruction_master_granted_cpu_1_jtag_debug_module & cpu_1_instruction_master_read & ~cpu_1_jtag_debug_module_waits_for_read;

  //allow new arb cycle for cpu_1/jtag_debug_module, which is an e_assign
  assign cpu_1_jtag_debug_module_allow_new_arb_cycle = ~cpu_1_data_master_arbiterlock & ~cpu_1_instruction_master_arbiterlock;

  //cpu_1/instruction_master assignment into master qualified-requests vector for cpu_1/jtag_debug_module, which is an e_assign
  assign cpu_1_jtag_debug_module_master_qreq_vector[0] = cpu_1_instruction_master_qualified_request_cpu_1_jtag_debug_module;

  //cpu_1/instruction_master grant cpu_1/jtag_debug_module, which is an e_assign
  assign cpu_1_instruction_master_granted_cpu_1_jtag_debug_module = cpu_1_jtag_debug_module_grant_vector[0];

  //cpu_1/instruction_master saved-grant cpu_1/jtag_debug_module, which is an e_assign
  assign cpu_1_instruction_master_saved_grant_cpu_1_jtag_debug_module = cpu_1_jtag_debug_module_arb_winner[0] && cpu_1_instruction_master_requests_cpu_1_jtag_debug_module;

  //cpu_1/data_master assignment into master qualified-requests vector for cpu_1/jtag_debug_module, which is an e_assign
  assign cpu_1_jtag_debug_module_master_qreq_vector[1] = cpu_1_data_master_qualified_request_cpu_1_jtag_debug_module;

  //cpu_1/data_master grant cpu_1/jtag_debug_module, which is an e_assign
  assign cpu_1_data_master_granted_cpu_1_jtag_debug_module = cpu_1_jtag_debug_module_grant_vector[1];

  //cpu_1/data_master saved-grant cpu_1/jtag_debug_module, which is an e_assign
  assign cpu_1_data_master_saved_grant_cpu_1_jtag_debug_module = cpu_1_jtag_debug_module_arb_winner[1] && cpu_1_data_master_requests_cpu_1_jtag_debug_module;

  //cpu_1/jtag_debug_module chosen-master double-vector, which is an e_assign
  assign cpu_1_jtag_debug_module_chosen_master_double_vector = {cpu_1_jtag_debug_module_master_qreq_vector, cpu_1_jtag_debug_module_master_qreq_vector} & ({~cpu_1_jtag_debug_module_master_qreq_vector, ~cpu_1_jtag_debug_module_master_qreq_vector} + cpu_1_jtag_debug_module_arb_addend);

  //stable onehot encoding of arb winner
  assign cpu_1_jtag_debug_module_arb_winner = (cpu_1_jtag_debug_module_allow_new_arb_cycle & | cpu_1_jtag_debug_module_grant_vector) ? cpu_1_jtag_debug_module_grant_vector : cpu_1_jtag_debug_module_saved_chosen_master_vector;

  //saved cpu_1_jtag_debug_module_grant_vector, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_1_jtag_debug_module_saved_chosen_master_vector <= 0;
      else if (cpu_1_jtag_debug_module_allow_new_arb_cycle)
          cpu_1_jtag_debug_module_saved_chosen_master_vector <= |cpu_1_jtag_debug_module_grant_vector ? cpu_1_jtag_debug_module_grant_vector : cpu_1_jtag_debug_module_saved_chosen_master_vector;
    end


  //onehot encoding of chosen master
  assign cpu_1_jtag_debug_module_grant_vector = {(cpu_1_jtag_debug_module_chosen_master_double_vector[1] | cpu_1_jtag_debug_module_chosen_master_double_vector[3]),
    (cpu_1_jtag_debug_module_chosen_master_double_vector[0] | cpu_1_jtag_debug_module_chosen_master_double_vector[2])};

  //cpu_1/jtag_debug_module chosen master rotated left, which is an e_assign
  assign cpu_1_jtag_debug_module_chosen_master_rot_left = (cpu_1_jtag_debug_module_arb_winner << 1) ? (cpu_1_jtag_debug_module_arb_winner << 1) : 1;

  //cpu_1/jtag_debug_module's addend for next-master-grant
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_1_jtag_debug_module_arb_addend <= 1;
      else if (|cpu_1_jtag_debug_module_grant_vector)
          cpu_1_jtag_debug_module_arb_addend <= cpu_1_jtag_debug_module_end_xfer? cpu_1_jtag_debug_module_chosen_master_rot_left : cpu_1_jtag_debug_module_grant_vector;
    end


  assign cpu_1_jtag_debug_module_begintransfer = cpu_1_jtag_debug_module_begins_xfer;
  //cpu_1_jtag_debug_module_reset_n assignment, which is an e_assign
  assign cpu_1_jtag_debug_module_reset_n = reset_n;

  //assign cpu_1_jtag_debug_module_resetrequest_from_sa = cpu_1_jtag_debug_module_resetrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign cpu_1_jtag_debug_module_resetrequest_from_sa = cpu_1_jtag_debug_module_resetrequest;

  assign cpu_1_jtag_debug_module_chipselect = cpu_1_data_master_granted_cpu_1_jtag_debug_module | cpu_1_instruction_master_granted_cpu_1_jtag_debug_module;
  //cpu_1_jtag_debug_module_firsttransfer first transaction, which is an e_assign
  assign cpu_1_jtag_debug_module_firsttransfer = cpu_1_jtag_debug_module_begins_xfer ? cpu_1_jtag_debug_module_unreg_firsttransfer : cpu_1_jtag_debug_module_reg_firsttransfer;

  //cpu_1_jtag_debug_module_unreg_firsttransfer first transaction, which is an e_assign
  assign cpu_1_jtag_debug_module_unreg_firsttransfer = ~(cpu_1_jtag_debug_module_slavearbiterlockenable & cpu_1_jtag_debug_module_any_continuerequest);

  //cpu_1_jtag_debug_module_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_1_jtag_debug_module_reg_firsttransfer <= 1'b1;
      else if (cpu_1_jtag_debug_module_begins_xfer)
          cpu_1_jtag_debug_module_reg_firsttransfer <= cpu_1_jtag_debug_module_unreg_firsttransfer;
    end


  //cpu_1_jtag_debug_module_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign cpu_1_jtag_debug_module_beginbursttransfer_internal = cpu_1_jtag_debug_module_begins_xfer;

  //cpu_1_jtag_debug_module_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  assign cpu_1_jtag_debug_module_arbitration_holdoff_internal = cpu_1_jtag_debug_module_begins_xfer & cpu_1_jtag_debug_module_firsttransfer;

  //cpu_1_jtag_debug_module_write assignment, which is an e_mux
  assign cpu_1_jtag_debug_module_write = cpu_1_data_master_granted_cpu_1_jtag_debug_module & cpu_1_data_master_write;

  assign shifted_address_to_cpu_1_jtag_debug_module_from_cpu_1_data_master = cpu_1_data_master_address_to_slave;
  //cpu_1_jtag_debug_module_address mux, which is an e_mux
  assign cpu_1_jtag_debug_module_address = (cpu_1_data_master_granted_cpu_1_jtag_debug_module)? (shifted_address_to_cpu_1_jtag_debug_module_from_cpu_1_data_master >> 2) :
    (shifted_address_to_cpu_1_jtag_debug_module_from_cpu_1_instruction_master >> 2);

  assign shifted_address_to_cpu_1_jtag_debug_module_from_cpu_1_instruction_master = cpu_1_instruction_master_address_to_slave;
  //d1_cpu_1_jtag_debug_module_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_cpu_1_jtag_debug_module_end_xfer <= 1;
      else 
        d1_cpu_1_jtag_debug_module_end_xfer <= cpu_1_jtag_debug_module_end_xfer;
    end


  //cpu_1_jtag_debug_module_waits_for_read in a cycle, which is an e_mux
  assign cpu_1_jtag_debug_module_waits_for_read = cpu_1_jtag_debug_module_in_a_read_cycle & cpu_1_jtag_debug_module_begins_xfer;

  //cpu_1_jtag_debug_module_in_a_read_cycle assignment, which is an e_assign
  assign cpu_1_jtag_debug_module_in_a_read_cycle = (cpu_1_data_master_granted_cpu_1_jtag_debug_module & cpu_1_data_master_read) | (cpu_1_instruction_master_granted_cpu_1_jtag_debug_module & cpu_1_instruction_master_read);

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = cpu_1_jtag_debug_module_in_a_read_cycle;

  //cpu_1_jtag_debug_module_waits_for_write in a cycle, which is an e_mux
  assign cpu_1_jtag_debug_module_waits_for_write = cpu_1_jtag_debug_module_in_a_write_cycle & 0;

  //cpu_1_jtag_debug_module_in_a_write_cycle assignment, which is an e_assign
  assign cpu_1_jtag_debug_module_in_a_write_cycle = cpu_1_data_master_granted_cpu_1_jtag_debug_module & cpu_1_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = cpu_1_jtag_debug_module_in_a_write_cycle;

  assign wait_for_cpu_1_jtag_debug_module_counter = 0;
  //cpu_1_jtag_debug_module_byteenable byte enable port mux, which is an e_mux
  assign cpu_1_jtag_debug_module_byteenable = (cpu_1_data_master_granted_cpu_1_jtag_debug_module)? cpu_1_data_master_byteenable :
    -1;

  //debugaccess mux, which is an e_mux
  assign cpu_1_jtag_debug_module_debugaccess = (cpu_1_data_master_granted_cpu_1_jtag_debug_module)? cpu_1_data_master_debugaccess :
    0;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //cpu_1/jtag_debug_module enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end


  //grant signals are active simultaneously, which is an e_process
  always @(posedge clk)
    begin
      if (cpu_1_data_master_granted_cpu_1_jtag_debug_module + cpu_1_instruction_master_granted_cpu_1_jtag_debug_module > 1)
        begin
          $write("%0d ns: > 1 of grant signals are active simultaneously", $time);
          $stop;
        end
    end


  //saved_grant signals are active simultaneously, which is an e_process
  always @(posedge clk)
    begin
      if (cpu_1_data_master_saved_grant_cpu_1_jtag_debug_module + cpu_1_instruction_master_saved_grant_cpu_1_jtag_debug_module > 1)
        begin
          $write("%0d ns: > 1 of saved_grant signals are active simultaneously", $time);
          $stop;
        end
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module cpu_1_data_master_arbitrator (
                                      // inputs:
                                       clk,
                                       cpu_1_data_master_address,
                                       cpu_1_data_master_byteenable,
                                       cpu_1_data_master_byteenable_sdram_1_s1,
                                       cpu_1_data_master_granted_cpu_1_jtag_debug_module,
                                       cpu_1_data_master_granted_hibi_pe_dma_1_avalon_slave_0,
                                       cpu_1_data_master_granted_jtag_uart_1_avalon_jtag_slave,
                                       cpu_1_data_master_granted_onchip_memory_1_s2,
                                       cpu_1_data_master_granted_sdram_1_s1,
                                       cpu_1_data_master_granted_timer_1_s1,
                                       cpu_1_data_master_qualified_request_cpu_1_jtag_debug_module,
                                       cpu_1_data_master_qualified_request_hibi_pe_dma_1_avalon_slave_0,
                                       cpu_1_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave,
                                       cpu_1_data_master_qualified_request_onchip_memory_1_s2,
                                       cpu_1_data_master_qualified_request_sdram_1_s1,
                                       cpu_1_data_master_qualified_request_timer_1_s1,
                                       cpu_1_data_master_read,
                                       cpu_1_data_master_read_data_valid_cpu_1_jtag_debug_module,
                                       cpu_1_data_master_read_data_valid_hibi_pe_dma_1_avalon_slave_0,
                                       cpu_1_data_master_read_data_valid_jtag_uart_1_avalon_jtag_slave,
                                       cpu_1_data_master_read_data_valid_onchip_memory_1_s2,
                                       cpu_1_data_master_read_data_valid_sdram_1_s1,
                                       cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register,
                                       cpu_1_data_master_read_data_valid_timer_1_s1,
                                       cpu_1_data_master_requests_cpu_1_jtag_debug_module,
                                       cpu_1_data_master_requests_hibi_pe_dma_1_avalon_slave_0,
                                       cpu_1_data_master_requests_jtag_uart_1_avalon_jtag_slave,
                                       cpu_1_data_master_requests_onchip_memory_1_s2,
                                       cpu_1_data_master_requests_sdram_1_s1,
                                       cpu_1_data_master_requests_timer_1_s1,
                                       cpu_1_data_master_write,
                                       cpu_1_data_master_writedata,
                                       cpu_1_jtag_debug_module_readdata_from_sa,
                                       d1_cpu_1_jtag_debug_module_end_xfer,
                                       d1_hibi_pe_dma_1_avalon_slave_0_end_xfer,
                                       d1_jtag_uart_1_avalon_jtag_slave_end_xfer,
                                       d1_onchip_memory_1_s2_end_xfer,
                                       d1_sdram_1_s1_end_xfer,
                                       d1_timer_1_s1_end_xfer,
                                       hibi_pe_dma_1_avalon_slave_0_irq_from_sa,
                                       hibi_pe_dma_1_avalon_slave_0_readdata_from_sa,
                                       hibi_pe_dma_1_avalon_slave_0_waitrequest_from_sa,
                                       jtag_uart_1_avalon_jtag_slave_irq_from_sa,
                                       jtag_uart_1_avalon_jtag_slave_readdata_from_sa,
                                       jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa,
                                       onchip_memory_1_s2_readdata_from_sa,
                                       reset_n,
                                       sdram_1_s1_readdata_from_sa,
                                       sdram_1_s1_waitrequest_from_sa,
                                       timer_1_s1_irq_from_sa,
                                       timer_1_s1_readdata_from_sa,

                                      // outputs:
                                       cpu_1_data_master_address_to_slave,
                                       cpu_1_data_master_dbs_address,
                                       cpu_1_data_master_dbs_write_16,
                                       cpu_1_data_master_irq,
                                       cpu_1_data_master_latency_counter,
                                       cpu_1_data_master_readdata,
                                       cpu_1_data_master_readdatavalid,
                                       cpu_1_data_master_waitrequest
                                    )
;

  output  [ 24: 0] cpu_1_data_master_address_to_slave;
  output  [  1: 0] cpu_1_data_master_dbs_address;
  output  [ 15: 0] cpu_1_data_master_dbs_write_16;
  output  [ 31: 0] cpu_1_data_master_irq;
  output           cpu_1_data_master_latency_counter;
  output  [ 31: 0] cpu_1_data_master_readdata;
  output           cpu_1_data_master_readdatavalid;
  output           cpu_1_data_master_waitrequest;
  input            clk;
  input   [ 24: 0] cpu_1_data_master_address;
  input   [  3: 0] cpu_1_data_master_byteenable;
  input   [  1: 0] cpu_1_data_master_byteenable_sdram_1_s1;
  input            cpu_1_data_master_granted_cpu_1_jtag_debug_module;
  input            cpu_1_data_master_granted_hibi_pe_dma_1_avalon_slave_0;
  input            cpu_1_data_master_granted_jtag_uart_1_avalon_jtag_slave;
  input            cpu_1_data_master_granted_onchip_memory_1_s2;
  input            cpu_1_data_master_granted_sdram_1_s1;
  input            cpu_1_data_master_granted_timer_1_s1;
  input            cpu_1_data_master_qualified_request_cpu_1_jtag_debug_module;
  input            cpu_1_data_master_qualified_request_hibi_pe_dma_1_avalon_slave_0;
  input            cpu_1_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave;
  input            cpu_1_data_master_qualified_request_onchip_memory_1_s2;
  input            cpu_1_data_master_qualified_request_sdram_1_s1;
  input            cpu_1_data_master_qualified_request_timer_1_s1;
  input            cpu_1_data_master_read;
  input            cpu_1_data_master_read_data_valid_cpu_1_jtag_debug_module;
  input            cpu_1_data_master_read_data_valid_hibi_pe_dma_1_avalon_slave_0;
  input            cpu_1_data_master_read_data_valid_jtag_uart_1_avalon_jtag_slave;
  input            cpu_1_data_master_read_data_valid_onchip_memory_1_s2;
  input            cpu_1_data_master_read_data_valid_sdram_1_s1;
  input            cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register;
  input            cpu_1_data_master_read_data_valid_timer_1_s1;
  input            cpu_1_data_master_requests_cpu_1_jtag_debug_module;
  input            cpu_1_data_master_requests_hibi_pe_dma_1_avalon_slave_0;
  input            cpu_1_data_master_requests_jtag_uart_1_avalon_jtag_slave;
  input            cpu_1_data_master_requests_onchip_memory_1_s2;
  input            cpu_1_data_master_requests_sdram_1_s1;
  input            cpu_1_data_master_requests_timer_1_s1;
  input            cpu_1_data_master_write;
  input   [ 31: 0] cpu_1_data_master_writedata;
  input   [ 31: 0] cpu_1_jtag_debug_module_readdata_from_sa;
  input            d1_cpu_1_jtag_debug_module_end_xfer;
  input            d1_hibi_pe_dma_1_avalon_slave_0_end_xfer;
  input            d1_jtag_uart_1_avalon_jtag_slave_end_xfer;
  input            d1_onchip_memory_1_s2_end_xfer;
  input            d1_sdram_1_s1_end_xfer;
  input            d1_timer_1_s1_end_xfer;
  input            hibi_pe_dma_1_avalon_slave_0_irq_from_sa;
  input   [ 31: 0] hibi_pe_dma_1_avalon_slave_0_readdata_from_sa;
  input            hibi_pe_dma_1_avalon_slave_0_waitrequest_from_sa;
  input            jtag_uart_1_avalon_jtag_slave_irq_from_sa;
  input   [ 31: 0] jtag_uart_1_avalon_jtag_slave_readdata_from_sa;
  input            jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa;
  input   [ 31: 0] onchip_memory_1_s2_readdata_from_sa;
  input            reset_n;
  input   [ 15: 0] sdram_1_s1_readdata_from_sa;
  input            sdram_1_s1_waitrequest_from_sa;
  input            timer_1_s1_irq_from_sa;
  input   [ 15: 0] timer_1_s1_readdata_from_sa;

  reg              active_and_waiting_last_time;
  reg     [ 24: 0] cpu_1_data_master_address_last_time;
  wire    [ 24: 0] cpu_1_data_master_address_to_slave;
  reg     [  3: 0] cpu_1_data_master_byteenable_last_time;
  reg     [  1: 0] cpu_1_data_master_dbs_address;
  wire    [  1: 0] cpu_1_data_master_dbs_increment;
  reg     [  1: 0] cpu_1_data_master_dbs_rdv_counter;
  wire    [  1: 0] cpu_1_data_master_dbs_rdv_counter_inc;
  wire    [ 15: 0] cpu_1_data_master_dbs_write_16;
  wire    [ 31: 0] cpu_1_data_master_irq;
  wire             cpu_1_data_master_is_granted_some_slave;
  reg              cpu_1_data_master_latency_counter;
  wire    [  1: 0] cpu_1_data_master_next_dbs_rdv_counter;
  reg              cpu_1_data_master_read_but_no_slave_selected;
  reg              cpu_1_data_master_read_last_time;
  wire    [ 31: 0] cpu_1_data_master_readdata;
  wire             cpu_1_data_master_readdatavalid;
  wire             cpu_1_data_master_run;
  wire             cpu_1_data_master_waitrequest;
  reg              cpu_1_data_master_write_last_time;
  reg     [ 31: 0] cpu_1_data_master_writedata_last_time;
  wire             dbs_count_enable;
  wire             dbs_counter_overflow;
  reg     [ 15: 0] dbs_latent_16_reg_segment_0;
  wire             dbs_rdv_count_enable;
  wire             dbs_rdv_counter_overflow;
  wire             latency_load_value;
  wire    [  1: 0] next_dbs_address;
  wire             p1_cpu_1_data_master_latency_counter;
  wire    [ 15: 0] p1_dbs_latent_16_reg_segment_0;
  wire             pre_dbs_count_enable;
  wire             pre_flush_cpu_1_data_master_readdatavalid;
  wire             r_0;
  wire             r_1;
  //r_0 master_run cascaded wait assignment, which is an e_assign
  assign r_0 = 1 & (cpu_1_data_master_qualified_request_cpu_1_jtag_debug_module | ~cpu_1_data_master_requests_cpu_1_jtag_debug_module) & (cpu_1_data_master_granted_cpu_1_jtag_debug_module | ~cpu_1_data_master_qualified_request_cpu_1_jtag_debug_module) & ((~cpu_1_data_master_qualified_request_cpu_1_jtag_debug_module | ~cpu_1_data_master_read | (1 & ~d1_cpu_1_jtag_debug_module_end_xfer & cpu_1_data_master_read))) & ((~cpu_1_data_master_qualified_request_cpu_1_jtag_debug_module | ~cpu_1_data_master_write | (1 & cpu_1_data_master_write))) & 1 & (cpu_1_data_master_qualified_request_hibi_pe_dma_1_avalon_slave_0 | ~cpu_1_data_master_requests_hibi_pe_dma_1_avalon_slave_0) & ((~cpu_1_data_master_qualified_request_hibi_pe_dma_1_avalon_slave_0 | ~(cpu_1_data_master_read | cpu_1_data_master_write) | (1 & ~hibi_pe_dma_1_avalon_slave_0_waitrequest_from_sa & (cpu_1_data_master_read | cpu_1_data_master_write)))) & ((~cpu_1_data_master_qualified_request_hibi_pe_dma_1_avalon_slave_0 | ~(cpu_1_data_master_read | cpu_1_data_master_write) | (1 & ~hibi_pe_dma_1_avalon_slave_0_waitrequest_from_sa & (cpu_1_data_master_read | cpu_1_data_master_write)))) & 1 & (cpu_1_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave | ~cpu_1_data_master_requests_jtag_uart_1_avalon_jtag_slave) & ((~cpu_1_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave | ~(cpu_1_data_master_read | cpu_1_data_master_write) | (1 & ~jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa & (cpu_1_data_master_read | cpu_1_data_master_write)))) & ((~cpu_1_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave | ~(cpu_1_data_master_read | cpu_1_data_master_write) | (1 & ~jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa & (cpu_1_data_master_read | cpu_1_data_master_write)))) & 1 & (cpu_1_data_master_qualified_request_onchip_memory_1_s2 | ~cpu_1_data_master_requests_onchip_memory_1_s2) & ((~cpu_1_data_master_qualified_request_onchip_memory_1_s2 | ~(cpu_1_data_master_read | cpu_1_data_master_write) | (1 & (cpu_1_data_master_read | cpu_1_data_master_write)))) & ((~cpu_1_data_master_qualified_request_onchip_memory_1_s2 | ~(cpu_1_data_master_read | cpu_1_data_master_write) | (1 & (cpu_1_data_master_read | cpu_1_data_master_write)))) & 1 & (cpu_1_data_master_qualified_request_sdram_1_s1 | (cpu_1_data_master_write & !cpu_1_data_master_byteenable_sdram_1_s1 & cpu_1_data_master_dbs_address[1]) | ~cpu_1_data_master_requests_sdram_1_s1) & (cpu_1_data_master_granted_sdram_1_s1 | ~cpu_1_data_master_qualified_request_sdram_1_s1);

  //cascaded wait assignment, which is an e_assign
  assign cpu_1_data_master_run = r_0 & r_1;

  //r_1 master_run cascaded wait assignment, which is an e_assign
  assign r_1 = ((~cpu_1_data_master_qualified_request_sdram_1_s1 | ~cpu_1_data_master_read | (1 & ~sdram_1_s1_waitrequest_from_sa & (cpu_1_data_master_dbs_address[1]) & cpu_1_data_master_read))) & ((~cpu_1_data_master_qualified_request_sdram_1_s1 | ~cpu_1_data_master_write | (1 & ~sdram_1_s1_waitrequest_from_sa & (cpu_1_data_master_dbs_address[1]) & cpu_1_data_master_write))) & 1 & (cpu_1_data_master_qualified_request_timer_1_s1 | ~cpu_1_data_master_requests_timer_1_s1) & ((~cpu_1_data_master_qualified_request_timer_1_s1 | ~cpu_1_data_master_read | (1 & ~d1_timer_1_s1_end_xfer & cpu_1_data_master_read))) & ((~cpu_1_data_master_qualified_request_timer_1_s1 | ~cpu_1_data_master_write | (1 & cpu_1_data_master_write)));

  //optimize select-logic by passing only those address bits which matter.
  assign cpu_1_data_master_address_to_slave = cpu_1_data_master_address[24 : 0];

  //cpu_1_data_master_read_but_no_slave_selected assignment, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_1_data_master_read_but_no_slave_selected <= 0;
      else 
        cpu_1_data_master_read_but_no_slave_selected <= cpu_1_data_master_read & cpu_1_data_master_run & ~cpu_1_data_master_is_granted_some_slave;
    end


  //some slave is getting selected, which is an e_mux
  assign cpu_1_data_master_is_granted_some_slave = cpu_1_data_master_granted_cpu_1_jtag_debug_module |
    cpu_1_data_master_granted_hibi_pe_dma_1_avalon_slave_0 |
    cpu_1_data_master_granted_jtag_uart_1_avalon_jtag_slave |
    cpu_1_data_master_granted_onchip_memory_1_s2 |
    cpu_1_data_master_granted_sdram_1_s1 |
    cpu_1_data_master_granted_timer_1_s1;

  //latent slave read data valids which may be flushed, which is an e_mux
  assign pre_flush_cpu_1_data_master_readdatavalid = cpu_1_data_master_read_data_valid_onchip_memory_1_s2 |
    (cpu_1_data_master_read_data_valid_sdram_1_s1 & dbs_rdv_counter_overflow);

  //latent slave read data valid which is not flushed, which is an e_mux
  assign cpu_1_data_master_readdatavalid = cpu_1_data_master_read_but_no_slave_selected |
    pre_flush_cpu_1_data_master_readdatavalid |
    cpu_1_data_master_read_data_valid_cpu_1_jtag_debug_module |
    cpu_1_data_master_read_but_no_slave_selected |
    pre_flush_cpu_1_data_master_readdatavalid |
    cpu_1_data_master_read_data_valid_hibi_pe_dma_1_avalon_slave_0 |
    cpu_1_data_master_read_but_no_slave_selected |
    pre_flush_cpu_1_data_master_readdatavalid |
    cpu_1_data_master_read_data_valid_jtag_uart_1_avalon_jtag_slave |
    cpu_1_data_master_read_but_no_slave_selected |
    pre_flush_cpu_1_data_master_readdatavalid |
    cpu_1_data_master_read_but_no_slave_selected |
    pre_flush_cpu_1_data_master_readdatavalid |
    cpu_1_data_master_read_but_no_slave_selected |
    pre_flush_cpu_1_data_master_readdatavalid |
    cpu_1_data_master_read_data_valid_timer_1_s1;

  //cpu_1/data_master readdata mux, which is an e_mux
  assign cpu_1_data_master_readdata = ({32 {~(cpu_1_data_master_qualified_request_cpu_1_jtag_debug_module & cpu_1_data_master_read)}} | cpu_1_jtag_debug_module_readdata_from_sa) &
    ({32 {~(cpu_1_data_master_qualified_request_hibi_pe_dma_1_avalon_slave_0 & cpu_1_data_master_read)}} | hibi_pe_dma_1_avalon_slave_0_readdata_from_sa) &
    ({32 {~(cpu_1_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave & cpu_1_data_master_read)}} | jtag_uart_1_avalon_jtag_slave_readdata_from_sa) &
    ({32 {~cpu_1_data_master_read_data_valid_onchip_memory_1_s2}} | onchip_memory_1_s2_readdata_from_sa) &
    ({32 {~cpu_1_data_master_read_data_valid_sdram_1_s1}} | {sdram_1_s1_readdata_from_sa[15 : 0],
    dbs_latent_16_reg_segment_0}) &
    ({32 {~(cpu_1_data_master_qualified_request_timer_1_s1 & cpu_1_data_master_read)}} | timer_1_s1_readdata_from_sa);

  //actual waitrequest port, which is an e_assign
  assign cpu_1_data_master_waitrequest = ~cpu_1_data_master_run;

  //latent max counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_1_data_master_latency_counter <= 0;
      else 
        cpu_1_data_master_latency_counter <= p1_cpu_1_data_master_latency_counter;
    end


  //latency counter load mux, which is an e_mux
  assign p1_cpu_1_data_master_latency_counter = ((cpu_1_data_master_run & cpu_1_data_master_read))? latency_load_value :
    (cpu_1_data_master_latency_counter)? cpu_1_data_master_latency_counter - 1 :
    0;

  //read latency load values, which is an e_mux
  assign latency_load_value = {1 {cpu_1_data_master_requests_onchip_memory_1_s2}} & 1;

  //irq assign, which is an e_assign
  assign cpu_1_data_master_irq = {1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    jtag_uart_1_avalon_jtag_slave_irq_from_sa,
    timer_1_s1_irq_from_sa,
    hibi_pe_dma_1_avalon_slave_0_irq_from_sa};

  //pre dbs count enable, which is an e_mux
  assign pre_dbs_count_enable = (((~0) & cpu_1_data_master_requests_sdram_1_s1 & cpu_1_data_master_write & !cpu_1_data_master_byteenable_sdram_1_s1)) |
    (cpu_1_data_master_granted_sdram_1_s1 & cpu_1_data_master_read & 1 & 1 & ~sdram_1_s1_waitrequest_from_sa) |
    (cpu_1_data_master_granted_sdram_1_s1 & cpu_1_data_master_write & 1 & 1 & ~sdram_1_s1_waitrequest_from_sa);

  //input to latent dbs-16 stored 0, which is an e_mux
  assign p1_dbs_latent_16_reg_segment_0 = sdram_1_s1_readdata_from_sa;

  //dbs register for latent dbs-16 segment 0, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          dbs_latent_16_reg_segment_0 <= 0;
      else if (dbs_rdv_count_enable & ((cpu_1_data_master_dbs_rdv_counter[1]) == 0))
          dbs_latent_16_reg_segment_0 <= p1_dbs_latent_16_reg_segment_0;
    end


  //mux write dbs 1, which is an e_mux
  assign cpu_1_data_master_dbs_write_16 = (cpu_1_data_master_dbs_address[1])? cpu_1_data_master_writedata[31 : 16] :
    cpu_1_data_master_writedata[15 : 0];

  //dbs count increment, which is an e_mux
  assign cpu_1_data_master_dbs_increment = (cpu_1_data_master_requests_sdram_1_s1)? 2 :
    0;

  //dbs counter overflow, which is an e_assign
  assign dbs_counter_overflow = cpu_1_data_master_dbs_address[1] & !(next_dbs_address[1]);

  //next master address, which is an e_assign
  assign next_dbs_address = cpu_1_data_master_dbs_address + cpu_1_data_master_dbs_increment;

  //dbs count enable, which is an e_mux
  assign dbs_count_enable = pre_dbs_count_enable;

  //dbs counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_1_data_master_dbs_address <= 0;
      else if (dbs_count_enable)
          cpu_1_data_master_dbs_address <= next_dbs_address;
    end


  //p1 dbs rdv counter, which is an e_assign
  assign cpu_1_data_master_next_dbs_rdv_counter = cpu_1_data_master_dbs_rdv_counter + cpu_1_data_master_dbs_rdv_counter_inc;

  //cpu_1_data_master_rdv_inc_mux, which is an e_mux
  assign cpu_1_data_master_dbs_rdv_counter_inc = 2;

  //master any slave rdv, which is an e_mux
  assign dbs_rdv_count_enable = cpu_1_data_master_read_data_valid_sdram_1_s1;

  //dbs rdv counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_1_data_master_dbs_rdv_counter <= 0;
      else if (dbs_rdv_count_enable)
          cpu_1_data_master_dbs_rdv_counter <= cpu_1_data_master_next_dbs_rdv_counter;
    end


  //dbs rdv counter overflow, which is an e_assign
  assign dbs_rdv_counter_overflow = cpu_1_data_master_dbs_rdv_counter[1] & ~cpu_1_data_master_next_dbs_rdv_counter[1];


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //cpu_1_data_master_address check against wait, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_1_data_master_address_last_time <= 0;
      else 
        cpu_1_data_master_address_last_time <= cpu_1_data_master_address;
    end


  //cpu_1/data_master waited last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          active_and_waiting_last_time <= 0;
      else 
        active_and_waiting_last_time <= cpu_1_data_master_waitrequest & (cpu_1_data_master_read | cpu_1_data_master_write);
    end


  //cpu_1_data_master_address matches last port_name, which is an e_process
  always @(posedge clk)
    begin
      if (active_and_waiting_last_time & (cpu_1_data_master_address != cpu_1_data_master_address_last_time))
        begin
          $write("%0d ns: cpu_1_data_master_address did not heed wait!!!", $time);
          $stop;
        end
    end


  //cpu_1_data_master_byteenable check against wait, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_1_data_master_byteenable_last_time <= 0;
      else 
        cpu_1_data_master_byteenable_last_time <= cpu_1_data_master_byteenable;
    end


  //cpu_1_data_master_byteenable matches last port_name, which is an e_process
  always @(posedge clk)
    begin
      if (active_and_waiting_last_time & (cpu_1_data_master_byteenable != cpu_1_data_master_byteenable_last_time))
        begin
          $write("%0d ns: cpu_1_data_master_byteenable did not heed wait!!!", $time);
          $stop;
        end
    end


  //cpu_1_data_master_read check against wait, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_1_data_master_read_last_time <= 0;
      else 
        cpu_1_data_master_read_last_time <= cpu_1_data_master_read;
    end


  //cpu_1_data_master_read matches last port_name, which is an e_process
  always @(posedge clk)
    begin
      if (active_and_waiting_last_time & (cpu_1_data_master_read != cpu_1_data_master_read_last_time))
        begin
          $write("%0d ns: cpu_1_data_master_read did not heed wait!!!", $time);
          $stop;
        end
    end


  //cpu_1_data_master_write check against wait, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_1_data_master_write_last_time <= 0;
      else 
        cpu_1_data_master_write_last_time <= cpu_1_data_master_write;
    end


  //cpu_1_data_master_write matches last port_name, which is an e_process
  always @(posedge clk)
    begin
      if (active_and_waiting_last_time & (cpu_1_data_master_write != cpu_1_data_master_write_last_time))
        begin
          $write("%0d ns: cpu_1_data_master_write did not heed wait!!!", $time);
          $stop;
        end
    end


  //cpu_1_data_master_writedata check against wait, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_1_data_master_writedata_last_time <= 0;
      else 
        cpu_1_data_master_writedata_last_time <= cpu_1_data_master_writedata;
    end


  //cpu_1_data_master_writedata matches last port_name, which is an e_process
  always @(posedge clk)
    begin
      if (active_and_waiting_last_time & (cpu_1_data_master_writedata != cpu_1_data_master_writedata_last_time) & cpu_1_data_master_write)
        begin
          $write("%0d ns: cpu_1_data_master_writedata did not heed wait!!!", $time);
          $stop;
        end
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module cpu_1_instruction_master_arbitrator (
                                             // inputs:
                                              clk,
                                              cpu_1_instruction_master_address,
                                              cpu_1_instruction_master_granted_cpu_1_jtag_debug_module,
                                              cpu_1_instruction_master_granted_sdram_1_s1,
                                              cpu_1_instruction_master_qualified_request_cpu_1_jtag_debug_module,
                                              cpu_1_instruction_master_qualified_request_sdram_1_s1,
                                              cpu_1_instruction_master_read,
                                              cpu_1_instruction_master_read_data_valid_cpu_1_jtag_debug_module,
                                              cpu_1_instruction_master_read_data_valid_sdram_1_s1,
                                              cpu_1_instruction_master_read_data_valid_sdram_1_s1_shift_register,
                                              cpu_1_instruction_master_requests_cpu_1_jtag_debug_module,
                                              cpu_1_instruction_master_requests_sdram_1_s1,
                                              cpu_1_jtag_debug_module_readdata_from_sa,
                                              d1_cpu_1_jtag_debug_module_end_xfer,
                                              d1_sdram_1_s1_end_xfer,
                                              reset_n,
                                              sdram_1_s1_readdata_from_sa,
                                              sdram_1_s1_waitrequest_from_sa,

                                             // outputs:
                                              cpu_1_instruction_master_address_to_slave,
                                              cpu_1_instruction_master_dbs_address,
                                              cpu_1_instruction_master_latency_counter,
                                              cpu_1_instruction_master_readdata,
                                              cpu_1_instruction_master_readdatavalid,
                                              cpu_1_instruction_master_waitrequest
                                           )
;

  output  [ 24: 0] cpu_1_instruction_master_address_to_slave;
  output  [  1: 0] cpu_1_instruction_master_dbs_address;
  output           cpu_1_instruction_master_latency_counter;
  output  [ 31: 0] cpu_1_instruction_master_readdata;
  output           cpu_1_instruction_master_readdatavalid;
  output           cpu_1_instruction_master_waitrequest;
  input            clk;
  input   [ 24: 0] cpu_1_instruction_master_address;
  input            cpu_1_instruction_master_granted_cpu_1_jtag_debug_module;
  input            cpu_1_instruction_master_granted_sdram_1_s1;
  input            cpu_1_instruction_master_qualified_request_cpu_1_jtag_debug_module;
  input            cpu_1_instruction_master_qualified_request_sdram_1_s1;
  input            cpu_1_instruction_master_read;
  input            cpu_1_instruction_master_read_data_valid_cpu_1_jtag_debug_module;
  input            cpu_1_instruction_master_read_data_valid_sdram_1_s1;
  input            cpu_1_instruction_master_read_data_valid_sdram_1_s1_shift_register;
  input            cpu_1_instruction_master_requests_cpu_1_jtag_debug_module;
  input            cpu_1_instruction_master_requests_sdram_1_s1;
  input   [ 31: 0] cpu_1_jtag_debug_module_readdata_from_sa;
  input            d1_cpu_1_jtag_debug_module_end_xfer;
  input            d1_sdram_1_s1_end_xfer;
  input            reset_n;
  input   [ 15: 0] sdram_1_s1_readdata_from_sa;
  input            sdram_1_s1_waitrequest_from_sa;

  reg              active_and_waiting_last_time;
  reg     [ 24: 0] cpu_1_instruction_master_address_last_time;
  wire    [ 24: 0] cpu_1_instruction_master_address_to_slave;
  reg     [  1: 0] cpu_1_instruction_master_dbs_address;
  wire    [  1: 0] cpu_1_instruction_master_dbs_increment;
  reg     [  1: 0] cpu_1_instruction_master_dbs_rdv_counter;
  wire    [  1: 0] cpu_1_instruction_master_dbs_rdv_counter_inc;
  wire             cpu_1_instruction_master_is_granted_some_slave;
  reg              cpu_1_instruction_master_latency_counter;
  wire    [  1: 0] cpu_1_instruction_master_next_dbs_rdv_counter;
  reg              cpu_1_instruction_master_read_but_no_slave_selected;
  reg              cpu_1_instruction_master_read_last_time;
  wire    [ 31: 0] cpu_1_instruction_master_readdata;
  wire             cpu_1_instruction_master_readdatavalid;
  wire             cpu_1_instruction_master_run;
  wire             cpu_1_instruction_master_waitrequest;
  wire             dbs_count_enable;
  wire             dbs_counter_overflow;
  reg     [ 15: 0] dbs_latent_16_reg_segment_0;
  wire             dbs_rdv_count_enable;
  wire             dbs_rdv_counter_overflow;
  wire             latency_load_value;
  wire    [  1: 0] next_dbs_address;
  wire             p1_cpu_1_instruction_master_latency_counter;
  wire    [ 15: 0] p1_dbs_latent_16_reg_segment_0;
  wire             pre_dbs_count_enable;
  wire             pre_flush_cpu_1_instruction_master_readdatavalid;
  wire             r_0;
  wire             r_1;
  //r_0 master_run cascaded wait assignment, which is an e_assign
  assign r_0 = 1 & (cpu_1_instruction_master_qualified_request_cpu_1_jtag_debug_module | ~cpu_1_instruction_master_requests_cpu_1_jtag_debug_module) & (cpu_1_instruction_master_granted_cpu_1_jtag_debug_module | ~cpu_1_instruction_master_qualified_request_cpu_1_jtag_debug_module) & ((~cpu_1_instruction_master_qualified_request_cpu_1_jtag_debug_module | ~cpu_1_instruction_master_read | (1 & ~d1_cpu_1_jtag_debug_module_end_xfer & cpu_1_instruction_master_read))) & 1 & (cpu_1_instruction_master_qualified_request_sdram_1_s1 | ~cpu_1_instruction_master_requests_sdram_1_s1);

  //cascaded wait assignment, which is an e_assign
  assign cpu_1_instruction_master_run = r_0 & r_1;

  //r_1 master_run cascaded wait assignment, which is an e_assign
  assign r_1 = (cpu_1_instruction_master_granted_sdram_1_s1 | ~cpu_1_instruction_master_qualified_request_sdram_1_s1) & ((~cpu_1_instruction_master_qualified_request_sdram_1_s1 | ~cpu_1_instruction_master_read | (1 & ~sdram_1_s1_waitrequest_from_sa & (cpu_1_instruction_master_dbs_address[1]) & cpu_1_instruction_master_read)));

  //optimize select-logic by passing only those address bits which matter.
  assign cpu_1_instruction_master_address_to_slave = cpu_1_instruction_master_address[24 : 0];

  //cpu_1_instruction_master_read_but_no_slave_selected assignment, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_1_instruction_master_read_but_no_slave_selected <= 0;
      else 
        cpu_1_instruction_master_read_but_no_slave_selected <= cpu_1_instruction_master_read & cpu_1_instruction_master_run & ~cpu_1_instruction_master_is_granted_some_slave;
    end


  //some slave is getting selected, which is an e_mux
  assign cpu_1_instruction_master_is_granted_some_slave = cpu_1_instruction_master_granted_cpu_1_jtag_debug_module |
    cpu_1_instruction_master_granted_sdram_1_s1;

  //latent slave read data valids which may be flushed, which is an e_mux
  assign pre_flush_cpu_1_instruction_master_readdatavalid = cpu_1_instruction_master_read_data_valid_sdram_1_s1 & dbs_rdv_counter_overflow;

  //latent slave read data valid which is not flushed, which is an e_mux
  assign cpu_1_instruction_master_readdatavalid = cpu_1_instruction_master_read_but_no_slave_selected |
    pre_flush_cpu_1_instruction_master_readdatavalid |
    cpu_1_instruction_master_read_data_valid_cpu_1_jtag_debug_module |
    cpu_1_instruction_master_read_but_no_slave_selected |
    pre_flush_cpu_1_instruction_master_readdatavalid;

  //cpu_1/instruction_master readdata mux, which is an e_mux
  assign cpu_1_instruction_master_readdata = ({32 {~(cpu_1_instruction_master_qualified_request_cpu_1_jtag_debug_module & cpu_1_instruction_master_read)}} | cpu_1_jtag_debug_module_readdata_from_sa) &
    ({32 {~cpu_1_instruction_master_read_data_valid_sdram_1_s1}} | {sdram_1_s1_readdata_from_sa[15 : 0],
    dbs_latent_16_reg_segment_0});

  //actual waitrequest port, which is an e_assign
  assign cpu_1_instruction_master_waitrequest = ~cpu_1_instruction_master_run;

  //latent max counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_1_instruction_master_latency_counter <= 0;
      else 
        cpu_1_instruction_master_latency_counter <= p1_cpu_1_instruction_master_latency_counter;
    end


  //latency counter load mux, which is an e_mux
  assign p1_cpu_1_instruction_master_latency_counter = ((cpu_1_instruction_master_run & cpu_1_instruction_master_read))? latency_load_value :
    (cpu_1_instruction_master_latency_counter)? cpu_1_instruction_master_latency_counter - 1 :
    0;

  //read latency load values, which is an e_mux
  assign latency_load_value = 0;

  //input to latent dbs-16 stored 0, which is an e_mux
  assign p1_dbs_latent_16_reg_segment_0 = sdram_1_s1_readdata_from_sa;

  //dbs register for latent dbs-16 segment 0, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          dbs_latent_16_reg_segment_0 <= 0;
      else if (dbs_rdv_count_enable & ((cpu_1_instruction_master_dbs_rdv_counter[1]) == 0))
          dbs_latent_16_reg_segment_0 <= p1_dbs_latent_16_reg_segment_0;
    end


  //dbs count increment, which is an e_mux
  assign cpu_1_instruction_master_dbs_increment = (cpu_1_instruction_master_requests_sdram_1_s1)? 2 :
    0;

  //dbs counter overflow, which is an e_assign
  assign dbs_counter_overflow = cpu_1_instruction_master_dbs_address[1] & !(next_dbs_address[1]);

  //next master address, which is an e_assign
  assign next_dbs_address = cpu_1_instruction_master_dbs_address + cpu_1_instruction_master_dbs_increment;

  //dbs count enable, which is an e_mux
  assign dbs_count_enable = pre_dbs_count_enable;

  //dbs counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_1_instruction_master_dbs_address <= 0;
      else if (dbs_count_enable)
          cpu_1_instruction_master_dbs_address <= next_dbs_address;
    end


  //p1 dbs rdv counter, which is an e_assign
  assign cpu_1_instruction_master_next_dbs_rdv_counter = cpu_1_instruction_master_dbs_rdv_counter + cpu_1_instruction_master_dbs_rdv_counter_inc;

  //cpu_1_instruction_master_rdv_inc_mux, which is an e_mux
  assign cpu_1_instruction_master_dbs_rdv_counter_inc = 2;

  //master any slave rdv, which is an e_mux
  assign dbs_rdv_count_enable = cpu_1_instruction_master_read_data_valid_sdram_1_s1;

  //dbs rdv counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_1_instruction_master_dbs_rdv_counter <= 0;
      else if (dbs_rdv_count_enable)
          cpu_1_instruction_master_dbs_rdv_counter <= cpu_1_instruction_master_next_dbs_rdv_counter;
    end


  //dbs rdv counter overflow, which is an e_assign
  assign dbs_rdv_counter_overflow = cpu_1_instruction_master_dbs_rdv_counter[1] & ~cpu_1_instruction_master_next_dbs_rdv_counter[1];

  //pre dbs count enable, which is an e_mux
  assign pre_dbs_count_enable = cpu_1_instruction_master_granted_sdram_1_s1 & cpu_1_instruction_master_read & 1 & 1 & ~sdram_1_s1_waitrequest_from_sa;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //cpu_1_instruction_master_address check against wait, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_1_instruction_master_address_last_time <= 0;
      else 
        cpu_1_instruction_master_address_last_time <= cpu_1_instruction_master_address;
    end


  //cpu_1/instruction_master waited last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          active_and_waiting_last_time <= 0;
      else 
        active_and_waiting_last_time <= cpu_1_instruction_master_waitrequest & (cpu_1_instruction_master_read);
    end


  //cpu_1_instruction_master_address matches last port_name, which is an e_process
  always @(posedge clk)
    begin
      if (active_and_waiting_last_time & (cpu_1_instruction_master_address != cpu_1_instruction_master_address_last_time))
        begin
          $write("%0d ns: cpu_1_instruction_master_address did not heed wait!!!", $time);
          $stop;
        end
    end


  //cpu_1_instruction_master_read check against wait, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_1_instruction_master_read_last_time <= 0;
      else 
        cpu_1_instruction_master_read_last_time <= cpu_1_instruction_master_read;
    end


  //cpu_1_instruction_master_read matches last port_name, which is an e_process
  always @(posedge clk)
    begin
      if (active_and_waiting_last_time & (cpu_1_instruction_master_read != cpu_1_instruction_master_read_last_time))
        begin
          $write("%0d ns: cpu_1_instruction_master_read did not heed wait!!!", $time);
          $stop;
        end
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module hibi_pe_dma_1_avalon_slave_0_arbitrator (
                                                 // inputs:
                                                  clk,
                                                  cpu_1_data_master_address_to_slave,
                                                  cpu_1_data_master_latency_counter,
                                                  cpu_1_data_master_read,
                                                  cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register,
                                                  cpu_1_data_master_write,
                                                  cpu_1_data_master_writedata,
                                                  hibi_pe_dma_1_avalon_slave_0_irq,
                                                  hibi_pe_dma_1_avalon_slave_0_readdata,
                                                  hibi_pe_dma_1_avalon_slave_0_waitrequest,
                                                  reset_n,

                                                 // outputs:
                                                  cpu_1_data_master_granted_hibi_pe_dma_1_avalon_slave_0,
                                                  cpu_1_data_master_qualified_request_hibi_pe_dma_1_avalon_slave_0,
                                                  cpu_1_data_master_read_data_valid_hibi_pe_dma_1_avalon_slave_0,
                                                  cpu_1_data_master_requests_hibi_pe_dma_1_avalon_slave_0,
                                                  d1_hibi_pe_dma_1_avalon_slave_0_end_xfer,
                                                  hibi_pe_dma_1_avalon_slave_0_address,
                                                  hibi_pe_dma_1_avalon_slave_0_chipselect,
                                                  hibi_pe_dma_1_avalon_slave_0_irq_from_sa,
                                                  hibi_pe_dma_1_avalon_slave_0_read,
                                                  hibi_pe_dma_1_avalon_slave_0_readdata_from_sa,
                                                  hibi_pe_dma_1_avalon_slave_0_reset_n,
                                                  hibi_pe_dma_1_avalon_slave_0_waitrequest_from_sa,
                                                  hibi_pe_dma_1_avalon_slave_0_write,
                                                  hibi_pe_dma_1_avalon_slave_0_writedata
                                               )
;

  output           cpu_1_data_master_granted_hibi_pe_dma_1_avalon_slave_0;
  output           cpu_1_data_master_qualified_request_hibi_pe_dma_1_avalon_slave_0;
  output           cpu_1_data_master_read_data_valid_hibi_pe_dma_1_avalon_slave_0;
  output           cpu_1_data_master_requests_hibi_pe_dma_1_avalon_slave_0;
  output           d1_hibi_pe_dma_1_avalon_slave_0_end_xfer;
  output  [  6: 0] hibi_pe_dma_1_avalon_slave_0_address;
  output           hibi_pe_dma_1_avalon_slave_0_chipselect;
  output           hibi_pe_dma_1_avalon_slave_0_irq_from_sa;
  output           hibi_pe_dma_1_avalon_slave_0_read;
  output  [ 31: 0] hibi_pe_dma_1_avalon_slave_0_readdata_from_sa;
  output           hibi_pe_dma_1_avalon_slave_0_reset_n;
  output           hibi_pe_dma_1_avalon_slave_0_waitrequest_from_sa;
  output           hibi_pe_dma_1_avalon_slave_0_write;
  output  [ 31: 0] hibi_pe_dma_1_avalon_slave_0_writedata;
  input            clk;
  input   [ 24: 0] cpu_1_data_master_address_to_slave;
  input            cpu_1_data_master_latency_counter;
  input            cpu_1_data_master_read;
  input            cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register;
  input            cpu_1_data_master_write;
  input   [ 31: 0] cpu_1_data_master_writedata;
  input            hibi_pe_dma_1_avalon_slave_0_irq;
  input   [ 31: 0] hibi_pe_dma_1_avalon_slave_0_readdata;
  input            hibi_pe_dma_1_avalon_slave_0_waitrequest;
  input            reset_n;

  wire             cpu_1_data_master_arbiterlock;
  wire             cpu_1_data_master_arbiterlock2;
  wire             cpu_1_data_master_continuerequest;
  wire             cpu_1_data_master_granted_hibi_pe_dma_1_avalon_slave_0;
  wire             cpu_1_data_master_qualified_request_hibi_pe_dma_1_avalon_slave_0;
  wire             cpu_1_data_master_read_data_valid_hibi_pe_dma_1_avalon_slave_0;
  wire             cpu_1_data_master_requests_hibi_pe_dma_1_avalon_slave_0;
  wire             cpu_1_data_master_saved_grant_hibi_pe_dma_1_avalon_slave_0;
  reg              d1_hibi_pe_dma_1_avalon_slave_0_end_xfer;
  reg              d1_reasons_to_wait;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_hibi_pe_dma_1_avalon_slave_0;
  wire    [  6: 0] hibi_pe_dma_1_avalon_slave_0_address;
  wire             hibi_pe_dma_1_avalon_slave_0_allgrants;
  wire             hibi_pe_dma_1_avalon_slave_0_allow_new_arb_cycle;
  wire             hibi_pe_dma_1_avalon_slave_0_any_bursting_master_saved_grant;
  wire             hibi_pe_dma_1_avalon_slave_0_any_continuerequest;
  wire             hibi_pe_dma_1_avalon_slave_0_arb_counter_enable;
  reg     [  1: 0] hibi_pe_dma_1_avalon_slave_0_arb_share_counter;
  wire    [  1: 0] hibi_pe_dma_1_avalon_slave_0_arb_share_counter_next_value;
  wire    [  1: 0] hibi_pe_dma_1_avalon_slave_0_arb_share_set_values;
  wire             hibi_pe_dma_1_avalon_slave_0_beginbursttransfer_internal;
  wire             hibi_pe_dma_1_avalon_slave_0_begins_xfer;
  wire             hibi_pe_dma_1_avalon_slave_0_chipselect;
  wire             hibi_pe_dma_1_avalon_slave_0_end_xfer;
  wire             hibi_pe_dma_1_avalon_slave_0_firsttransfer;
  wire             hibi_pe_dma_1_avalon_slave_0_grant_vector;
  wire             hibi_pe_dma_1_avalon_slave_0_in_a_read_cycle;
  wire             hibi_pe_dma_1_avalon_slave_0_in_a_write_cycle;
  wire             hibi_pe_dma_1_avalon_slave_0_irq_from_sa;
  wire             hibi_pe_dma_1_avalon_slave_0_master_qreq_vector;
  wire             hibi_pe_dma_1_avalon_slave_0_non_bursting_master_requests;
  wire             hibi_pe_dma_1_avalon_slave_0_read;
  wire    [ 31: 0] hibi_pe_dma_1_avalon_slave_0_readdata_from_sa;
  reg              hibi_pe_dma_1_avalon_slave_0_reg_firsttransfer;
  wire             hibi_pe_dma_1_avalon_slave_0_reset_n;
  reg              hibi_pe_dma_1_avalon_slave_0_slavearbiterlockenable;
  wire             hibi_pe_dma_1_avalon_slave_0_slavearbiterlockenable2;
  wire             hibi_pe_dma_1_avalon_slave_0_unreg_firsttransfer;
  wire             hibi_pe_dma_1_avalon_slave_0_waitrequest_from_sa;
  wire             hibi_pe_dma_1_avalon_slave_0_waits_for_read;
  wire             hibi_pe_dma_1_avalon_slave_0_waits_for_write;
  wire             hibi_pe_dma_1_avalon_slave_0_write;
  wire    [ 31: 0] hibi_pe_dma_1_avalon_slave_0_writedata;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  wire    [ 24: 0] shifted_address_to_hibi_pe_dma_1_avalon_slave_0_from_cpu_1_data_master;
  wire             wait_for_hibi_pe_dma_1_avalon_slave_0_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~hibi_pe_dma_1_avalon_slave_0_end_xfer;
    end


  assign hibi_pe_dma_1_avalon_slave_0_begins_xfer = ~d1_reasons_to_wait & ((cpu_1_data_master_qualified_request_hibi_pe_dma_1_avalon_slave_0));
  //assign hibi_pe_dma_1_avalon_slave_0_readdata_from_sa = hibi_pe_dma_1_avalon_slave_0_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign hibi_pe_dma_1_avalon_slave_0_readdata_from_sa = hibi_pe_dma_1_avalon_slave_0_readdata;

  assign cpu_1_data_master_requests_hibi_pe_dma_1_avalon_slave_0 = ({cpu_1_data_master_address_to_slave[24 : 9] , 9'b0} == 25'h1001800) & (cpu_1_data_master_read | cpu_1_data_master_write);
  //assign hibi_pe_dma_1_avalon_slave_0_waitrequest_from_sa = hibi_pe_dma_1_avalon_slave_0_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign hibi_pe_dma_1_avalon_slave_0_waitrequest_from_sa = hibi_pe_dma_1_avalon_slave_0_waitrequest;

  //hibi_pe_dma_1_avalon_slave_0_arb_share_counter set values, which is an e_mux
  assign hibi_pe_dma_1_avalon_slave_0_arb_share_set_values = 1;

  //hibi_pe_dma_1_avalon_slave_0_non_bursting_master_requests mux, which is an e_mux
  assign hibi_pe_dma_1_avalon_slave_0_non_bursting_master_requests = cpu_1_data_master_requests_hibi_pe_dma_1_avalon_slave_0;

  //hibi_pe_dma_1_avalon_slave_0_any_bursting_master_saved_grant mux, which is an e_mux
  assign hibi_pe_dma_1_avalon_slave_0_any_bursting_master_saved_grant = 0;

  //hibi_pe_dma_1_avalon_slave_0_arb_share_counter_next_value assignment, which is an e_assign
  assign hibi_pe_dma_1_avalon_slave_0_arb_share_counter_next_value = hibi_pe_dma_1_avalon_slave_0_firsttransfer ? (hibi_pe_dma_1_avalon_slave_0_arb_share_set_values - 1) : |hibi_pe_dma_1_avalon_slave_0_arb_share_counter ? (hibi_pe_dma_1_avalon_slave_0_arb_share_counter - 1) : 0;

  //hibi_pe_dma_1_avalon_slave_0_allgrants all slave grants, which is an e_mux
  assign hibi_pe_dma_1_avalon_slave_0_allgrants = |hibi_pe_dma_1_avalon_slave_0_grant_vector;

  //hibi_pe_dma_1_avalon_slave_0_end_xfer assignment, which is an e_assign
  assign hibi_pe_dma_1_avalon_slave_0_end_xfer = ~(hibi_pe_dma_1_avalon_slave_0_waits_for_read | hibi_pe_dma_1_avalon_slave_0_waits_for_write);

  //end_xfer_arb_share_counter_term_hibi_pe_dma_1_avalon_slave_0 arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_hibi_pe_dma_1_avalon_slave_0 = hibi_pe_dma_1_avalon_slave_0_end_xfer & (~hibi_pe_dma_1_avalon_slave_0_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //hibi_pe_dma_1_avalon_slave_0_arb_share_counter arbitration counter enable, which is an e_assign
  assign hibi_pe_dma_1_avalon_slave_0_arb_counter_enable = (end_xfer_arb_share_counter_term_hibi_pe_dma_1_avalon_slave_0 & hibi_pe_dma_1_avalon_slave_0_allgrants) | (end_xfer_arb_share_counter_term_hibi_pe_dma_1_avalon_slave_0 & ~hibi_pe_dma_1_avalon_slave_0_non_bursting_master_requests);

  //hibi_pe_dma_1_avalon_slave_0_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          hibi_pe_dma_1_avalon_slave_0_arb_share_counter <= 0;
      else if (hibi_pe_dma_1_avalon_slave_0_arb_counter_enable)
          hibi_pe_dma_1_avalon_slave_0_arb_share_counter <= hibi_pe_dma_1_avalon_slave_0_arb_share_counter_next_value;
    end


  //hibi_pe_dma_1_avalon_slave_0_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          hibi_pe_dma_1_avalon_slave_0_slavearbiterlockenable <= 0;
      else if ((|hibi_pe_dma_1_avalon_slave_0_master_qreq_vector & end_xfer_arb_share_counter_term_hibi_pe_dma_1_avalon_slave_0) | (end_xfer_arb_share_counter_term_hibi_pe_dma_1_avalon_slave_0 & ~hibi_pe_dma_1_avalon_slave_0_non_bursting_master_requests))
          hibi_pe_dma_1_avalon_slave_0_slavearbiterlockenable <= |hibi_pe_dma_1_avalon_slave_0_arb_share_counter_next_value;
    end


  //cpu_1/data_master hibi_pe_dma_1/avalon_slave_0 arbiterlock, which is an e_assign
  assign cpu_1_data_master_arbiterlock = hibi_pe_dma_1_avalon_slave_0_slavearbiterlockenable & cpu_1_data_master_continuerequest;

  //hibi_pe_dma_1_avalon_slave_0_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign hibi_pe_dma_1_avalon_slave_0_slavearbiterlockenable2 = |hibi_pe_dma_1_avalon_slave_0_arb_share_counter_next_value;

  //cpu_1/data_master hibi_pe_dma_1/avalon_slave_0 arbiterlock2, which is an e_assign
  assign cpu_1_data_master_arbiterlock2 = hibi_pe_dma_1_avalon_slave_0_slavearbiterlockenable2 & cpu_1_data_master_continuerequest;

  //hibi_pe_dma_1_avalon_slave_0_any_continuerequest at least one master continues requesting, which is an e_assign
  assign hibi_pe_dma_1_avalon_slave_0_any_continuerequest = 1;

  //cpu_1_data_master_continuerequest continued request, which is an e_assign
  assign cpu_1_data_master_continuerequest = 1;

  assign cpu_1_data_master_qualified_request_hibi_pe_dma_1_avalon_slave_0 = cpu_1_data_master_requests_hibi_pe_dma_1_avalon_slave_0 & ~((cpu_1_data_master_read & ((cpu_1_data_master_latency_counter != 0) | (|cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register))));
  //local readdatavalid cpu_1_data_master_read_data_valid_hibi_pe_dma_1_avalon_slave_0, which is an e_mux
  assign cpu_1_data_master_read_data_valid_hibi_pe_dma_1_avalon_slave_0 = cpu_1_data_master_granted_hibi_pe_dma_1_avalon_slave_0 & cpu_1_data_master_read & ~hibi_pe_dma_1_avalon_slave_0_waits_for_read;

  //hibi_pe_dma_1_avalon_slave_0_writedata mux, which is an e_mux
  assign hibi_pe_dma_1_avalon_slave_0_writedata = cpu_1_data_master_writedata;

  //master is always granted when requested
  assign cpu_1_data_master_granted_hibi_pe_dma_1_avalon_slave_0 = cpu_1_data_master_qualified_request_hibi_pe_dma_1_avalon_slave_0;

  //cpu_1/data_master saved-grant hibi_pe_dma_1/avalon_slave_0, which is an e_assign
  assign cpu_1_data_master_saved_grant_hibi_pe_dma_1_avalon_slave_0 = cpu_1_data_master_requests_hibi_pe_dma_1_avalon_slave_0;

  //allow new arb cycle for hibi_pe_dma_1/avalon_slave_0, which is an e_assign
  assign hibi_pe_dma_1_avalon_slave_0_allow_new_arb_cycle = 1;

  //placeholder chosen master
  assign hibi_pe_dma_1_avalon_slave_0_grant_vector = 1;

  //placeholder vector of master qualified-requests
  assign hibi_pe_dma_1_avalon_slave_0_master_qreq_vector = 1;

  //hibi_pe_dma_1_avalon_slave_0_reset_n assignment, which is an e_assign
  assign hibi_pe_dma_1_avalon_slave_0_reset_n = reset_n;

  assign hibi_pe_dma_1_avalon_slave_0_chipselect = cpu_1_data_master_granted_hibi_pe_dma_1_avalon_slave_0;
  //hibi_pe_dma_1_avalon_slave_0_firsttransfer first transaction, which is an e_assign
  assign hibi_pe_dma_1_avalon_slave_0_firsttransfer = hibi_pe_dma_1_avalon_slave_0_begins_xfer ? hibi_pe_dma_1_avalon_slave_0_unreg_firsttransfer : hibi_pe_dma_1_avalon_slave_0_reg_firsttransfer;

  //hibi_pe_dma_1_avalon_slave_0_unreg_firsttransfer first transaction, which is an e_assign
  assign hibi_pe_dma_1_avalon_slave_0_unreg_firsttransfer = ~(hibi_pe_dma_1_avalon_slave_0_slavearbiterlockenable & hibi_pe_dma_1_avalon_slave_0_any_continuerequest);

  //hibi_pe_dma_1_avalon_slave_0_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          hibi_pe_dma_1_avalon_slave_0_reg_firsttransfer <= 1'b1;
      else if (hibi_pe_dma_1_avalon_slave_0_begins_xfer)
          hibi_pe_dma_1_avalon_slave_0_reg_firsttransfer <= hibi_pe_dma_1_avalon_slave_0_unreg_firsttransfer;
    end


  //hibi_pe_dma_1_avalon_slave_0_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign hibi_pe_dma_1_avalon_slave_0_beginbursttransfer_internal = hibi_pe_dma_1_avalon_slave_0_begins_xfer;

  //hibi_pe_dma_1_avalon_slave_0_read assignment, which is an e_mux
  assign hibi_pe_dma_1_avalon_slave_0_read = cpu_1_data_master_granted_hibi_pe_dma_1_avalon_slave_0 & cpu_1_data_master_read;

  //hibi_pe_dma_1_avalon_slave_0_write assignment, which is an e_mux
  assign hibi_pe_dma_1_avalon_slave_0_write = cpu_1_data_master_granted_hibi_pe_dma_1_avalon_slave_0 & cpu_1_data_master_write;

  assign shifted_address_to_hibi_pe_dma_1_avalon_slave_0_from_cpu_1_data_master = cpu_1_data_master_address_to_slave;
  //hibi_pe_dma_1_avalon_slave_0_address mux, which is an e_mux
  assign hibi_pe_dma_1_avalon_slave_0_address = shifted_address_to_hibi_pe_dma_1_avalon_slave_0_from_cpu_1_data_master >> 2;

  //d1_hibi_pe_dma_1_avalon_slave_0_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_hibi_pe_dma_1_avalon_slave_0_end_xfer <= 1;
      else 
        d1_hibi_pe_dma_1_avalon_slave_0_end_xfer <= hibi_pe_dma_1_avalon_slave_0_end_xfer;
    end


  //hibi_pe_dma_1_avalon_slave_0_waits_for_read in a cycle, which is an e_mux
  assign hibi_pe_dma_1_avalon_slave_0_waits_for_read = hibi_pe_dma_1_avalon_slave_0_in_a_read_cycle & hibi_pe_dma_1_avalon_slave_0_waitrequest_from_sa;

  //hibi_pe_dma_1_avalon_slave_0_in_a_read_cycle assignment, which is an e_assign
  assign hibi_pe_dma_1_avalon_slave_0_in_a_read_cycle = cpu_1_data_master_granted_hibi_pe_dma_1_avalon_slave_0 & cpu_1_data_master_read;

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = hibi_pe_dma_1_avalon_slave_0_in_a_read_cycle;

  //hibi_pe_dma_1_avalon_slave_0_waits_for_write in a cycle, which is an e_mux
  assign hibi_pe_dma_1_avalon_slave_0_waits_for_write = hibi_pe_dma_1_avalon_slave_0_in_a_write_cycle & hibi_pe_dma_1_avalon_slave_0_waitrequest_from_sa;

  //hibi_pe_dma_1_avalon_slave_0_in_a_write_cycle assignment, which is an e_assign
  assign hibi_pe_dma_1_avalon_slave_0_in_a_write_cycle = cpu_1_data_master_granted_hibi_pe_dma_1_avalon_slave_0 & cpu_1_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = hibi_pe_dma_1_avalon_slave_0_in_a_write_cycle;

  assign wait_for_hibi_pe_dma_1_avalon_slave_0_counter = 0;
  //assign hibi_pe_dma_1_avalon_slave_0_irq_from_sa = hibi_pe_dma_1_avalon_slave_0_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign hibi_pe_dma_1_avalon_slave_0_irq_from_sa = hibi_pe_dma_1_avalon_slave_0_irq;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //hibi_pe_dma_1/avalon_slave_0 enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module hibi_pe_dma_1_avalon_master_arbitrator (
                                                // inputs:
                                                 clk,
                                                 d1_onchip_memory_1_s1_end_xfer,
                                                 hibi_pe_dma_1_avalon_master_address,
                                                 hibi_pe_dma_1_avalon_master_byteenable,
                                                 hibi_pe_dma_1_avalon_master_granted_onchip_memory_1_s1,
                                                 hibi_pe_dma_1_avalon_master_qualified_request_onchip_memory_1_s1,
                                                 hibi_pe_dma_1_avalon_master_requests_onchip_memory_1_s1,
                                                 hibi_pe_dma_1_avalon_master_write,
                                                 hibi_pe_dma_1_avalon_master_writedata,
                                                 reset_n,

                                                // outputs:
                                                 hibi_pe_dma_1_avalon_master_address_to_slave,
                                                 hibi_pe_dma_1_avalon_master_waitrequest
                                              )
;

  output  [ 31: 0] hibi_pe_dma_1_avalon_master_address_to_slave;
  output           hibi_pe_dma_1_avalon_master_waitrequest;
  input            clk;
  input            d1_onchip_memory_1_s1_end_xfer;
  input   [ 31: 0] hibi_pe_dma_1_avalon_master_address;
  input   [  3: 0] hibi_pe_dma_1_avalon_master_byteenable;
  input            hibi_pe_dma_1_avalon_master_granted_onchip_memory_1_s1;
  input            hibi_pe_dma_1_avalon_master_qualified_request_onchip_memory_1_s1;
  input            hibi_pe_dma_1_avalon_master_requests_onchip_memory_1_s1;
  input            hibi_pe_dma_1_avalon_master_write;
  input   [ 31: 0] hibi_pe_dma_1_avalon_master_writedata;
  input            reset_n;

  reg              active_and_waiting_last_time;
  reg     [ 31: 0] hibi_pe_dma_1_avalon_master_address_last_time;
  wire    [ 31: 0] hibi_pe_dma_1_avalon_master_address_to_slave;
  reg     [  3: 0] hibi_pe_dma_1_avalon_master_byteenable_last_time;
  wire             hibi_pe_dma_1_avalon_master_run;
  wire             hibi_pe_dma_1_avalon_master_waitrequest;
  reg              hibi_pe_dma_1_avalon_master_write_last_time;
  reg     [ 31: 0] hibi_pe_dma_1_avalon_master_writedata_last_time;
  wire             r_0;
  //r_0 master_run cascaded wait assignment, which is an e_assign
  assign r_0 = 1 & (hibi_pe_dma_1_avalon_master_qualified_request_onchip_memory_1_s1 | ~hibi_pe_dma_1_avalon_master_requests_onchip_memory_1_s1) & (hibi_pe_dma_1_avalon_master_granted_onchip_memory_1_s1 | ~hibi_pe_dma_1_avalon_master_qualified_request_onchip_memory_1_s1) & ((~hibi_pe_dma_1_avalon_master_qualified_request_onchip_memory_1_s1 | ~(hibi_pe_dma_1_avalon_master_write) | (1 & (hibi_pe_dma_1_avalon_master_write))));

  //cascaded wait assignment, which is an e_assign
  assign hibi_pe_dma_1_avalon_master_run = r_0;

  //optimize select-logic by passing only those address bits which matter.
  assign hibi_pe_dma_1_avalon_master_address_to_slave = {21'b0,
    hibi_pe_dma_1_avalon_master_address[10 : 0]};

  //actual waitrequest port, which is an e_assign
  assign hibi_pe_dma_1_avalon_master_waitrequest = ~hibi_pe_dma_1_avalon_master_run;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //hibi_pe_dma_1_avalon_master_address check against wait, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          hibi_pe_dma_1_avalon_master_address_last_time <= 0;
      else 
        hibi_pe_dma_1_avalon_master_address_last_time <= hibi_pe_dma_1_avalon_master_address;
    end


  //hibi_pe_dma_1/avalon_master waited last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          active_and_waiting_last_time <= 0;
      else 
        active_and_waiting_last_time <= hibi_pe_dma_1_avalon_master_waitrequest & (hibi_pe_dma_1_avalon_master_write);
    end


  //hibi_pe_dma_1_avalon_master_address matches last port_name, which is an e_process
  always @(posedge clk)
    begin
      if (active_and_waiting_last_time & (hibi_pe_dma_1_avalon_master_address != hibi_pe_dma_1_avalon_master_address_last_time))
        begin
          $write("%0d ns: hibi_pe_dma_1_avalon_master_address did not heed wait!!!", $time);
          $stop;
        end
    end


  //hibi_pe_dma_1_avalon_master_byteenable check against wait, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          hibi_pe_dma_1_avalon_master_byteenable_last_time <= 0;
      else 
        hibi_pe_dma_1_avalon_master_byteenable_last_time <= hibi_pe_dma_1_avalon_master_byteenable;
    end


  //hibi_pe_dma_1_avalon_master_byteenable matches last port_name, which is an e_process
  always @(posedge clk)
    begin
      if (active_and_waiting_last_time & (hibi_pe_dma_1_avalon_master_byteenable != hibi_pe_dma_1_avalon_master_byteenable_last_time))
        begin
          $write("%0d ns: hibi_pe_dma_1_avalon_master_byteenable did not heed wait!!!", $time);
          $stop;
        end
    end


  //hibi_pe_dma_1_avalon_master_write check against wait, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          hibi_pe_dma_1_avalon_master_write_last_time <= 0;
      else 
        hibi_pe_dma_1_avalon_master_write_last_time <= hibi_pe_dma_1_avalon_master_write;
    end


  //hibi_pe_dma_1_avalon_master_write matches last port_name, which is an e_process
  always @(posedge clk)
    begin
      if (active_and_waiting_last_time & (hibi_pe_dma_1_avalon_master_write != hibi_pe_dma_1_avalon_master_write_last_time))
        begin
          $write("%0d ns: hibi_pe_dma_1_avalon_master_write did not heed wait!!!", $time);
          $stop;
        end
    end


  //hibi_pe_dma_1_avalon_master_writedata check against wait, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          hibi_pe_dma_1_avalon_master_writedata_last_time <= 0;
      else 
        hibi_pe_dma_1_avalon_master_writedata_last_time <= hibi_pe_dma_1_avalon_master_writedata;
    end


  //hibi_pe_dma_1_avalon_master_writedata matches last port_name, which is an e_process
  always @(posedge clk)
    begin
      if (active_and_waiting_last_time & (hibi_pe_dma_1_avalon_master_writedata != hibi_pe_dma_1_avalon_master_writedata_last_time) & hibi_pe_dma_1_avalon_master_write)
        begin
          $write("%0d ns: hibi_pe_dma_1_avalon_master_writedata did not heed wait!!!", $time);
          $stop;
        end
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module hibi_pe_dma_1_avalon_master_1_arbitrator (
                                                  // inputs:
                                                   clk,
                                                   d1_onchip_memory_1_s1_end_xfer,
                                                   hibi_pe_dma_1_avalon_master_1_address,
                                                   hibi_pe_dma_1_avalon_master_1_granted_onchip_memory_1_s1,
                                                   hibi_pe_dma_1_avalon_master_1_qualified_request_onchip_memory_1_s1,
                                                   hibi_pe_dma_1_avalon_master_1_read,
                                                   hibi_pe_dma_1_avalon_master_1_read_data_valid_onchip_memory_1_s1,
                                                   hibi_pe_dma_1_avalon_master_1_requests_onchip_memory_1_s1,
                                                   onchip_memory_1_s1_readdata_from_sa,
                                                   reset_n,

                                                  // outputs:
                                                   hibi_pe_dma_1_avalon_master_1_address_to_slave,
                                                   hibi_pe_dma_1_avalon_master_1_latency_counter,
                                                   hibi_pe_dma_1_avalon_master_1_readdata,
                                                   hibi_pe_dma_1_avalon_master_1_readdatavalid,
                                                   hibi_pe_dma_1_avalon_master_1_waitrequest
                                                )
;

  output  [ 31: 0] hibi_pe_dma_1_avalon_master_1_address_to_slave;
  output           hibi_pe_dma_1_avalon_master_1_latency_counter;
  output  [ 31: 0] hibi_pe_dma_1_avalon_master_1_readdata;
  output           hibi_pe_dma_1_avalon_master_1_readdatavalid;
  output           hibi_pe_dma_1_avalon_master_1_waitrequest;
  input            clk;
  input            d1_onchip_memory_1_s1_end_xfer;
  input   [ 31: 0] hibi_pe_dma_1_avalon_master_1_address;
  input            hibi_pe_dma_1_avalon_master_1_granted_onchip_memory_1_s1;
  input            hibi_pe_dma_1_avalon_master_1_qualified_request_onchip_memory_1_s1;
  input            hibi_pe_dma_1_avalon_master_1_read;
  input            hibi_pe_dma_1_avalon_master_1_read_data_valid_onchip_memory_1_s1;
  input            hibi_pe_dma_1_avalon_master_1_requests_onchip_memory_1_s1;
  input   [ 31: 0] onchip_memory_1_s1_readdata_from_sa;
  input            reset_n;

  reg              active_and_waiting_last_time;
  reg     [ 31: 0] hibi_pe_dma_1_avalon_master_1_address_last_time;
  wire    [ 31: 0] hibi_pe_dma_1_avalon_master_1_address_to_slave;
  wire             hibi_pe_dma_1_avalon_master_1_is_granted_some_slave;
  reg              hibi_pe_dma_1_avalon_master_1_latency_counter;
  reg              hibi_pe_dma_1_avalon_master_1_read_but_no_slave_selected;
  reg              hibi_pe_dma_1_avalon_master_1_read_last_time;
  wire    [ 31: 0] hibi_pe_dma_1_avalon_master_1_readdata;
  wire             hibi_pe_dma_1_avalon_master_1_readdatavalid;
  wire             hibi_pe_dma_1_avalon_master_1_run;
  wire             hibi_pe_dma_1_avalon_master_1_waitrequest;
  wire             latency_load_value;
  wire             p1_hibi_pe_dma_1_avalon_master_1_latency_counter;
  wire             pre_flush_hibi_pe_dma_1_avalon_master_1_readdatavalid;
  wire             r_0;
  //r_0 master_run cascaded wait assignment, which is an e_assign
  assign r_0 = 1 & (hibi_pe_dma_1_avalon_master_1_qualified_request_onchip_memory_1_s1 | ~hibi_pe_dma_1_avalon_master_1_requests_onchip_memory_1_s1) & (hibi_pe_dma_1_avalon_master_1_granted_onchip_memory_1_s1 | ~hibi_pe_dma_1_avalon_master_1_qualified_request_onchip_memory_1_s1) & ((~hibi_pe_dma_1_avalon_master_1_qualified_request_onchip_memory_1_s1 | ~(hibi_pe_dma_1_avalon_master_1_read) | (1 & (hibi_pe_dma_1_avalon_master_1_read))));

  //cascaded wait assignment, which is an e_assign
  assign hibi_pe_dma_1_avalon_master_1_run = r_0;

  //optimize select-logic by passing only those address bits which matter.
  assign hibi_pe_dma_1_avalon_master_1_address_to_slave = {21'b0,
    hibi_pe_dma_1_avalon_master_1_address[10 : 0]};

  //hibi_pe_dma_1_avalon_master_1_read_but_no_slave_selected assignment, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          hibi_pe_dma_1_avalon_master_1_read_but_no_slave_selected <= 0;
      else 
        hibi_pe_dma_1_avalon_master_1_read_but_no_slave_selected <= hibi_pe_dma_1_avalon_master_1_read & hibi_pe_dma_1_avalon_master_1_run & ~hibi_pe_dma_1_avalon_master_1_is_granted_some_slave;
    end


  //some slave is getting selected, which is an e_mux
  assign hibi_pe_dma_1_avalon_master_1_is_granted_some_slave = hibi_pe_dma_1_avalon_master_1_granted_onchip_memory_1_s1;

  //latent slave read data valids which may be flushed, which is an e_mux
  assign pre_flush_hibi_pe_dma_1_avalon_master_1_readdatavalid = hibi_pe_dma_1_avalon_master_1_read_data_valid_onchip_memory_1_s1;

  //latent slave read data valid which is not flushed, which is an e_mux
  assign hibi_pe_dma_1_avalon_master_1_readdatavalid = hibi_pe_dma_1_avalon_master_1_read_but_no_slave_selected |
    pre_flush_hibi_pe_dma_1_avalon_master_1_readdatavalid;

  //hibi_pe_dma_1/avalon_master_1 readdata mux, which is an e_mux
  assign hibi_pe_dma_1_avalon_master_1_readdata = onchip_memory_1_s1_readdata_from_sa;

  //actual waitrequest port, which is an e_assign
  assign hibi_pe_dma_1_avalon_master_1_waitrequest = ~hibi_pe_dma_1_avalon_master_1_run;

  //latent max counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          hibi_pe_dma_1_avalon_master_1_latency_counter <= 0;
      else 
        hibi_pe_dma_1_avalon_master_1_latency_counter <= p1_hibi_pe_dma_1_avalon_master_1_latency_counter;
    end


  //latency counter load mux, which is an e_mux
  assign p1_hibi_pe_dma_1_avalon_master_1_latency_counter = ((hibi_pe_dma_1_avalon_master_1_run & hibi_pe_dma_1_avalon_master_1_read))? latency_load_value :
    (hibi_pe_dma_1_avalon_master_1_latency_counter)? hibi_pe_dma_1_avalon_master_1_latency_counter - 1 :
    0;

  //read latency load values, which is an e_mux
  assign latency_load_value = {1 {hibi_pe_dma_1_avalon_master_1_requests_onchip_memory_1_s1}} & 1;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //hibi_pe_dma_1_avalon_master_1_address check against wait, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          hibi_pe_dma_1_avalon_master_1_address_last_time <= 0;
      else 
        hibi_pe_dma_1_avalon_master_1_address_last_time <= hibi_pe_dma_1_avalon_master_1_address;
    end


  //hibi_pe_dma_1/avalon_master_1 waited last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          active_and_waiting_last_time <= 0;
      else 
        active_and_waiting_last_time <= hibi_pe_dma_1_avalon_master_1_waitrequest & (hibi_pe_dma_1_avalon_master_1_read);
    end


  //hibi_pe_dma_1_avalon_master_1_address matches last port_name, which is an e_process
  always @(posedge clk)
    begin
      if (active_and_waiting_last_time & (hibi_pe_dma_1_avalon_master_1_address != hibi_pe_dma_1_avalon_master_1_address_last_time))
        begin
          $write("%0d ns: hibi_pe_dma_1_avalon_master_1_address did not heed wait!!!", $time);
          $stop;
        end
    end


  //hibi_pe_dma_1_avalon_master_1_read check against wait, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          hibi_pe_dma_1_avalon_master_1_read_last_time <= 0;
      else 
        hibi_pe_dma_1_avalon_master_1_read_last_time <= hibi_pe_dma_1_avalon_master_1_read;
    end


  //hibi_pe_dma_1_avalon_master_1_read matches last port_name, which is an e_process
  always @(posedge clk)
    begin
      if (active_and_waiting_last_time & (hibi_pe_dma_1_avalon_master_1_read != hibi_pe_dma_1_avalon_master_1_read_last_time))
        begin
          $write("%0d ns: hibi_pe_dma_1_avalon_master_1_read did not heed wait!!!", $time);
          $stop;
        end
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module jtag_uart_1_avalon_jtag_slave_arbitrator (
                                                  // inputs:
                                                   clk,
                                                   cpu_1_data_master_address_to_slave,
                                                   cpu_1_data_master_latency_counter,
                                                   cpu_1_data_master_read,
                                                   cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register,
                                                   cpu_1_data_master_write,
                                                   cpu_1_data_master_writedata,
                                                   jtag_uart_1_avalon_jtag_slave_dataavailable,
                                                   jtag_uart_1_avalon_jtag_slave_irq,
                                                   jtag_uart_1_avalon_jtag_slave_readdata,
                                                   jtag_uart_1_avalon_jtag_slave_readyfordata,
                                                   jtag_uart_1_avalon_jtag_slave_waitrequest,
                                                   reset_n,

                                                  // outputs:
                                                   cpu_1_data_master_granted_jtag_uart_1_avalon_jtag_slave,
                                                   cpu_1_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave,
                                                   cpu_1_data_master_read_data_valid_jtag_uart_1_avalon_jtag_slave,
                                                   cpu_1_data_master_requests_jtag_uart_1_avalon_jtag_slave,
                                                   d1_jtag_uart_1_avalon_jtag_slave_end_xfer,
                                                   jtag_uart_1_avalon_jtag_slave_address,
                                                   jtag_uart_1_avalon_jtag_slave_chipselect,
                                                   jtag_uart_1_avalon_jtag_slave_dataavailable_from_sa,
                                                   jtag_uart_1_avalon_jtag_slave_irq_from_sa,
                                                   jtag_uart_1_avalon_jtag_slave_read_n,
                                                   jtag_uart_1_avalon_jtag_slave_readdata_from_sa,
                                                   jtag_uart_1_avalon_jtag_slave_readyfordata_from_sa,
                                                   jtag_uart_1_avalon_jtag_slave_reset_n,
                                                   jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa,
                                                   jtag_uart_1_avalon_jtag_slave_write_n,
                                                   jtag_uart_1_avalon_jtag_slave_writedata
                                                )
;

  output           cpu_1_data_master_granted_jtag_uart_1_avalon_jtag_slave;
  output           cpu_1_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave;
  output           cpu_1_data_master_read_data_valid_jtag_uart_1_avalon_jtag_slave;
  output           cpu_1_data_master_requests_jtag_uart_1_avalon_jtag_slave;
  output           d1_jtag_uart_1_avalon_jtag_slave_end_xfer;
  output           jtag_uart_1_avalon_jtag_slave_address;
  output           jtag_uart_1_avalon_jtag_slave_chipselect;
  output           jtag_uart_1_avalon_jtag_slave_dataavailable_from_sa;
  output           jtag_uart_1_avalon_jtag_slave_irq_from_sa;
  output           jtag_uart_1_avalon_jtag_slave_read_n;
  output  [ 31: 0] jtag_uart_1_avalon_jtag_slave_readdata_from_sa;
  output           jtag_uart_1_avalon_jtag_slave_readyfordata_from_sa;
  output           jtag_uart_1_avalon_jtag_slave_reset_n;
  output           jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa;
  output           jtag_uart_1_avalon_jtag_slave_write_n;
  output  [ 31: 0] jtag_uart_1_avalon_jtag_slave_writedata;
  input            clk;
  input   [ 24: 0] cpu_1_data_master_address_to_slave;
  input            cpu_1_data_master_latency_counter;
  input            cpu_1_data_master_read;
  input            cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register;
  input            cpu_1_data_master_write;
  input   [ 31: 0] cpu_1_data_master_writedata;
  input            jtag_uart_1_avalon_jtag_slave_dataavailable;
  input            jtag_uart_1_avalon_jtag_slave_irq;
  input   [ 31: 0] jtag_uart_1_avalon_jtag_slave_readdata;
  input            jtag_uart_1_avalon_jtag_slave_readyfordata;
  input            jtag_uart_1_avalon_jtag_slave_waitrequest;
  input            reset_n;

  wire             cpu_1_data_master_arbiterlock;
  wire             cpu_1_data_master_arbiterlock2;
  wire             cpu_1_data_master_continuerequest;
  wire             cpu_1_data_master_granted_jtag_uart_1_avalon_jtag_slave;
  wire             cpu_1_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave;
  wire             cpu_1_data_master_read_data_valid_jtag_uart_1_avalon_jtag_slave;
  wire             cpu_1_data_master_requests_jtag_uart_1_avalon_jtag_slave;
  wire             cpu_1_data_master_saved_grant_jtag_uart_1_avalon_jtag_slave;
  reg              d1_jtag_uart_1_avalon_jtag_slave_end_xfer;
  reg              d1_reasons_to_wait;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_jtag_uart_1_avalon_jtag_slave;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  wire             jtag_uart_1_avalon_jtag_slave_address;
  wire             jtag_uart_1_avalon_jtag_slave_allgrants;
  wire             jtag_uart_1_avalon_jtag_slave_allow_new_arb_cycle;
  wire             jtag_uart_1_avalon_jtag_slave_any_bursting_master_saved_grant;
  wire             jtag_uart_1_avalon_jtag_slave_any_continuerequest;
  wire             jtag_uart_1_avalon_jtag_slave_arb_counter_enable;
  reg     [  1: 0] jtag_uart_1_avalon_jtag_slave_arb_share_counter;
  wire    [  1: 0] jtag_uart_1_avalon_jtag_slave_arb_share_counter_next_value;
  wire    [  1: 0] jtag_uart_1_avalon_jtag_slave_arb_share_set_values;
  wire             jtag_uart_1_avalon_jtag_slave_beginbursttransfer_internal;
  wire             jtag_uart_1_avalon_jtag_slave_begins_xfer;
  wire             jtag_uart_1_avalon_jtag_slave_chipselect;
  wire             jtag_uart_1_avalon_jtag_slave_dataavailable_from_sa;
  wire             jtag_uart_1_avalon_jtag_slave_end_xfer;
  wire             jtag_uart_1_avalon_jtag_slave_firsttransfer;
  wire             jtag_uart_1_avalon_jtag_slave_grant_vector;
  wire             jtag_uart_1_avalon_jtag_slave_in_a_read_cycle;
  wire             jtag_uart_1_avalon_jtag_slave_in_a_write_cycle;
  wire             jtag_uart_1_avalon_jtag_slave_irq_from_sa;
  wire             jtag_uart_1_avalon_jtag_slave_master_qreq_vector;
  wire             jtag_uart_1_avalon_jtag_slave_non_bursting_master_requests;
  wire             jtag_uart_1_avalon_jtag_slave_read_n;
  wire    [ 31: 0] jtag_uart_1_avalon_jtag_slave_readdata_from_sa;
  wire             jtag_uart_1_avalon_jtag_slave_readyfordata_from_sa;
  reg              jtag_uart_1_avalon_jtag_slave_reg_firsttransfer;
  wire             jtag_uart_1_avalon_jtag_slave_reset_n;
  reg              jtag_uart_1_avalon_jtag_slave_slavearbiterlockenable;
  wire             jtag_uart_1_avalon_jtag_slave_slavearbiterlockenable2;
  wire             jtag_uart_1_avalon_jtag_slave_unreg_firsttransfer;
  wire             jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa;
  wire             jtag_uart_1_avalon_jtag_slave_waits_for_read;
  wire             jtag_uart_1_avalon_jtag_slave_waits_for_write;
  wire             jtag_uart_1_avalon_jtag_slave_write_n;
  wire    [ 31: 0] jtag_uart_1_avalon_jtag_slave_writedata;
  wire    [ 24: 0] shifted_address_to_jtag_uart_1_avalon_jtag_slave_from_cpu_1_data_master;
  wire             wait_for_jtag_uart_1_avalon_jtag_slave_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~jtag_uart_1_avalon_jtag_slave_end_xfer;
    end


  assign jtag_uart_1_avalon_jtag_slave_begins_xfer = ~d1_reasons_to_wait & ((cpu_1_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave));
  //assign jtag_uart_1_avalon_jtag_slave_readdata_from_sa = jtag_uart_1_avalon_jtag_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign jtag_uart_1_avalon_jtag_slave_readdata_from_sa = jtag_uart_1_avalon_jtag_slave_readdata;

  assign cpu_1_data_master_requests_jtag_uart_1_avalon_jtag_slave = ({cpu_1_data_master_address_to_slave[24 : 3] , 3'b0} == 25'h1001a20) & (cpu_1_data_master_read | cpu_1_data_master_write);
  //assign jtag_uart_1_avalon_jtag_slave_dataavailable_from_sa = jtag_uart_1_avalon_jtag_slave_dataavailable so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign jtag_uart_1_avalon_jtag_slave_dataavailable_from_sa = jtag_uart_1_avalon_jtag_slave_dataavailable;

  //assign jtag_uart_1_avalon_jtag_slave_readyfordata_from_sa = jtag_uart_1_avalon_jtag_slave_readyfordata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign jtag_uart_1_avalon_jtag_slave_readyfordata_from_sa = jtag_uart_1_avalon_jtag_slave_readyfordata;

  //assign jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa = jtag_uart_1_avalon_jtag_slave_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa = jtag_uart_1_avalon_jtag_slave_waitrequest;

  //jtag_uart_1_avalon_jtag_slave_arb_share_counter set values, which is an e_mux
  assign jtag_uart_1_avalon_jtag_slave_arb_share_set_values = 1;

  //jtag_uart_1_avalon_jtag_slave_non_bursting_master_requests mux, which is an e_mux
  assign jtag_uart_1_avalon_jtag_slave_non_bursting_master_requests = cpu_1_data_master_requests_jtag_uart_1_avalon_jtag_slave;

  //jtag_uart_1_avalon_jtag_slave_any_bursting_master_saved_grant mux, which is an e_mux
  assign jtag_uart_1_avalon_jtag_slave_any_bursting_master_saved_grant = 0;

  //jtag_uart_1_avalon_jtag_slave_arb_share_counter_next_value assignment, which is an e_assign
  assign jtag_uart_1_avalon_jtag_slave_arb_share_counter_next_value = jtag_uart_1_avalon_jtag_slave_firsttransfer ? (jtag_uart_1_avalon_jtag_slave_arb_share_set_values - 1) : |jtag_uart_1_avalon_jtag_slave_arb_share_counter ? (jtag_uart_1_avalon_jtag_slave_arb_share_counter - 1) : 0;

  //jtag_uart_1_avalon_jtag_slave_allgrants all slave grants, which is an e_mux
  assign jtag_uart_1_avalon_jtag_slave_allgrants = |jtag_uart_1_avalon_jtag_slave_grant_vector;

  //jtag_uart_1_avalon_jtag_slave_end_xfer assignment, which is an e_assign
  assign jtag_uart_1_avalon_jtag_slave_end_xfer = ~(jtag_uart_1_avalon_jtag_slave_waits_for_read | jtag_uart_1_avalon_jtag_slave_waits_for_write);

  //end_xfer_arb_share_counter_term_jtag_uart_1_avalon_jtag_slave arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_jtag_uart_1_avalon_jtag_slave = jtag_uart_1_avalon_jtag_slave_end_xfer & (~jtag_uart_1_avalon_jtag_slave_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //jtag_uart_1_avalon_jtag_slave_arb_share_counter arbitration counter enable, which is an e_assign
  assign jtag_uart_1_avalon_jtag_slave_arb_counter_enable = (end_xfer_arb_share_counter_term_jtag_uart_1_avalon_jtag_slave & jtag_uart_1_avalon_jtag_slave_allgrants) | (end_xfer_arb_share_counter_term_jtag_uart_1_avalon_jtag_slave & ~jtag_uart_1_avalon_jtag_slave_non_bursting_master_requests);

  //jtag_uart_1_avalon_jtag_slave_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          jtag_uart_1_avalon_jtag_slave_arb_share_counter <= 0;
      else if (jtag_uart_1_avalon_jtag_slave_arb_counter_enable)
          jtag_uart_1_avalon_jtag_slave_arb_share_counter <= jtag_uart_1_avalon_jtag_slave_arb_share_counter_next_value;
    end


  //jtag_uart_1_avalon_jtag_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          jtag_uart_1_avalon_jtag_slave_slavearbiterlockenable <= 0;
      else if ((|jtag_uart_1_avalon_jtag_slave_master_qreq_vector & end_xfer_arb_share_counter_term_jtag_uart_1_avalon_jtag_slave) | (end_xfer_arb_share_counter_term_jtag_uart_1_avalon_jtag_slave & ~jtag_uart_1_avalon_jtag_slave_non_bursting_master_requests))
          jtag_uart_1_avalon_jtag_slave_slavearbiterlockenable <= |jtag_uart_1_avalon_jtag_slave_arb_share_counter_next_value;
    end


  //cpu_1/data_master jtag_uart_1/avalon_jtag_slave arbiterlock, which is an e_assign
  assign cpu_1_data_master_arbiterlock = jtag_uart_1_avalon_jtag_slave_slavearbiterlockenable & cpu_1_data_master_continuerequest;

  //jtag_uart_1_avalon_jtag_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign jtag_uart_1_avalon_jtag_slave_slavearbiterlockenable2 = |jtag_uart_1_avalon_jtag_slave_arb_share_counter_next_value;

  //cpu_1/data_master jtag_uart_1/avalon_jtag_slave arbiterlock2, which is an e_assign
  assign cpu_1_data_master_arbiterlock2 = jtag_uart_1_avalon_jtag_slave_slavearbiterlockenable2 & cpu_1_data_master_continuerequest;

  //jtag_uart_1_avalon_jtag_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  assign jtag_uart_1_avalon_jtag_slave_any_continuerequest = 1;

  //cpu_1_data_master_continuerequest continued request, which is an e_assign
  assign cpu_1_data_master_continuerequest = 1;

  assign cpu_1_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave = cpu_1_data_master_requests_jtag_uart_1_avalon_jtag_slave & ~((cpu_1_data_master_read & ((cpu_1_data_master_latency_counter != 0) | (|cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register))));
  //local readdatavalid cpu_1_data_master_read_data_valid_jtag_uart_1_avalon_jtag_slave, which is an e_mux
  assign cpu_1_data_master_read_data_valid_jtag_uart_1_avalon_jtag_slave = cpu_1_data_master_granted_jtag_uart_1_avalon_jtag_slave & cpu_1_data_master_read & ~jtag_uart_1_avalon_jtag_slave_waits_for_read;

  //jtag_uart_1_avalon_jtag_slave_writedata mux, which is an e_mux
  assign jtag_uart_1_avalon_jtag_slave_writedata = cpu_1_data_master_writedata;

  //master is always granted when requested
  assign cpu_1_data_master_granted_jtag_uart_1_avalon_jtag_slave = cpu_1_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave;

  //cpu_1/data_master saved-grant jtag_uart_1/avalon_jtag_slave, which is an e_assign
  assign cpu_1_data_master_saved_grant_jtag_uart_1_avalon_jtag_slave = cpu_1_data_master_requests_jtag_uart_1_avalon_jtag_slave;

  //allow new arb cycle for jtag_uart_1/avalon_jtag_slave, which is an e_assign
  assign jtag_uart_1_avalon_jtag_slave_allow_new_arb_cycle = 1;

  //placeholder chosen master
  assign jtag_uart_1_avalon_jtag_slave_grant_vector = 1;

  //placeholder vector of master qualified-requests
  assign jtag_uart_1_avalon_jtag_slave_master_qreq_vector = 1;

  //jtag_uart_1_avalon_jtag_slave_reset_n assignment, which is an e_assign
  assign jtag_uart_1_avalon_jtag_slave_reset_n = reset_n;

  assign jtag_uart_1_avalon_jtag_slave_chipselect = cpu_1_data_master_granted_jtag_uart_1_avalon_jtag_slave;
  //jtag_uart_1_avalon_jtag_slave_firsttransfer first transaction, which is an e_assign
  assign jtag_uart_1_avalon_jtag_slave_firsttransfer = jtag_uart_1_avalon_jtag_slave_begins_xfer ? jtag_uart_1_avalon_jtag_slave_unreg_firsttransfer : jtag_uart_1_avalon_jtag_slave_reg_firsttransfer;

  //jtag_uart_1_avalon_jtag_slave_unreg_firsttransfer first transaction, which is an e_assign
  assign jtag_uart_1_avalon_jtag_slave_unreg_firsttransfer = ~(jtag_uart_1_avalon_jtag_slave_slavearbiterlockenable & jtag_uart_1_avalon_jtag_slave_any_continuerequest);

  //jtag_uart_1_avalon_jtag_slave_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          jtag_uart_1_avalon_jtag_slave_reg_firsttransfer <= 1'b1;
      else if (jtag_uart_1_avalon_jtag_slave_begins_xfer)
          jtag_uart_1_avalon_jtag_slave_reg_firsttransfer <= jtag_uart_1_avalon_jtag_slave_unreg_firsttransfer;
    end


  //jtag_uart_1_avalon_jtag_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign jtag_uart_1_avalon_jtag_slave_beginbursttransfer_internal = jtag_uart_1_avalon_jtag_slave_begins_xfer;

  //~jtag_uart_1_avalon_jtag_slave_read_n assignment, which is an e_mux
  assign jtag_uart_1_avalon_jtag_slave_read_n = ~(cpu_1_data_master_granted_jtag_uart_1_avalon_jtag_slave & cpu_1_data_master_read);

  //~jtag_uart_1_avalon_jtag_slave_write_n assignment, which is an e_mux
  assign jtag_uart_1_avalon_jtag_slave_write_n = ~(cpu_1_data_master_granted_jtag_uart_1_avalon_jtag_slave & cpu_1_data_master_write);

  assign shifted_address_to_jtag_uart_1_avalon_jtag_slave_from_cpu_1_data_master = cpu_1_data_master_address_to_slave;
  //jtag_uart_1_avalon_jtag_slave_address mux, which is an e_mux
  assign jtag_uart_1_avalon_jtag_slave_address = shifted_address_to_jtag_uart_1_avalon_jtag_slave_from_cpu_1_data_master >> 2;

  //d1_jtag_uart_1_avalon_jtag_slave_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_jtag_uart_1_avalon_jtag_slave_end_xfer <= 1;
      else 
        d1_jtag_uart_1_avalon_jtag_slave_end_xfer <= jtag_uart_1_avalon_jtag_slave_end_xfer;
    end


  //jtag_uart_1_avalon_jtag_slave_waits_for_read in a cycle, which is an e_mux
  assign jtag_uart_1_avalon_jtag_slave_waits_for_read = jtag_uart_1_avalon_jtag_slave_in_a_read_cycle & jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa;

  //jtag_uart_1_avalon_jtag_slave_in_a_read_cycle assignment, which is an e_assign
  assign jtag_uart_1_avalon_jtag_slave_in_a_read_cycle = cpu_1_data_master_granted_jtag_uart_1_avalon_jtag_slave & cpu_1_data_master_read;

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = jtag_uart_1_avalon_jtag_slave_in_a_read_cycle;

  //jtag_uart_1_avalon_jtag_slave_waits_for_write in a cycle, which is an e_mux
  assign jtag_uart_1_avalon_jtag_slave_waits_for_write = jtag_uart_1_avalon_jtag_slave_in_a_write_cycle & jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa;

  //jtag_uart_1_avalon_jtag_slave_in_a_write_cycle assignment, which is an e_assign
  assign jtag_uart_1_avalon_jtag_slave_in_a_write_cycle = cpu_1_data_master_granted_jtag_uart_1_avalon_jtag_slave & cpu_1_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = jtag_uart_1_avalon_jtag_slave_in_a_write_cycle;

  assign wait_for_jtag_uart_1_avalon_jtag_slave_counter = 0;
  //assign jtag_uart_1_avalon_jtag_slave_irq_from_sa = jtag_uart_1_avalon_jtag_slave_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign jtag_uart_1_avalon_jtag_slave_irq_from_sa = jtag_uart_1_avalon_jtag_slave_irq;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //jtag_uart_1/avalon_jtag_slave enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module onchip_memory_1_s1_arbitrator (
                                       // inputs:
                                        clk,
                                        hibi_pe_dma_1_avalon_master_1_address_to_slave,
                                        hibi_pe_dma_1_avalon_master_1_latency_counter,
                                        hibi_pe_dma_1_avalon_master_1_read,
                                        hibi_pe_dma_1_avalon_master_address_to_slave,
                                        hibi_pe_dma_1_avalon_master_byteenable,
                                        hibi_pe_dma_1_avalon_master_write,
                                        hibi_pe_dma_1_avalon_master_writedata,
                                        onchip_memory_1_s1_readdata,
                                        reset_n,

                                       // outputs:
                                        d1_onchip_memory_1_s1_end_xfer,
                                        hibi_pe_dma_1_avalon_master_1_granted_onchip_memory_1_s1,
                                        hibi_pe_dma_1_avalon_master_1_qualified_request_onchip_memory_1_s1,
                                        hibi_pe_dma_1_avalon_master_1_read_data_valid_onchip_memory_1_s1,
                                        hibi_pe_dma_1_avalon_master_1_requests_onchip_memory_1_s1,
                                        hibi_pe_dma_1_avalon_master_granted_onchip_memory_1_s1,
                                        hibi_pe_dma_1_avalon_master_qualified_request_onchip_memory_1_s1,
                                        hibi_pe_dma_1_avalon_master_requests_onchip_memory_1_s1,
                                        onchip_memory_1_s1_address,
                                        onchip_memory_1_s1_byteenable,
                                        onchip_memory_1_s1_chipselect,
                                        onchip_memory_1_s1_clken,
                                        onchip_memory_1_s1_readdata_from_sa,
                                        onchip_memory_1_s1_reset,
                                        onchip_memory_1_s1_write,
                                        onchip_memory_1_s1_writedata
                                     )
;

  output           d1_onchip_memory_1_s1_end_xfer;
  output           hibi_pe_dma_1_avalon_master_1_granted_onchip_memory_1_s1;
  output           hibi_pe_dma_1_avalon_master_1_qualified_request_onchip_memory_1_s1;
  output           hibi_pe_dma_1_avalon_master_1_read_data_valid_onchip_memory_1_s1;
  output           hibi_pe_dma_1_avalon_master_1_requests_onchip_memory_1_s1;
  output           hibi_pe_dma_1_avalon_master_granted_onchip_memory_1_s1;
  output           hibi_pe_dma_1_avalon_master_qualified_request_onchip_memory_1_s1;
  output           hibi_pe_dma_1_avalon_master_requests_onchip_memory_1_s1;
  output  [  8: 0] onchip_memory_1_s1_address;
  output  [  3: 0] onchip_memory_1_s1_byteenable;
  output           onchip_memory_1_s1_chipselect;
  output           onchip_memory_1_s1_clken;
  output  [ 31: 0] onchip_memory_1_s1_readdata_from_sa;
  output           onchip_memory_1_s1_reset;
  output           onchip_memory_1_s1_write;
  output  [ 31: 0] onchip_memory_1_s1_writedata;
  input            clk;
  input   [ 31: 0] hibi_pe_dma_1_avalon_master_1_address_to_slave;
  input            hibi_pe_dma_1_avalon_master_1_latency_counter;
  input            hibi_pe_dma_1_avalon_master_1_read;
  input   [ 31: 0] hibi_pe_dma_1_avalon_master_address_to_slave;
  input   [  3: 0] hibi_pe_dma_1_avalon_master_byteenable;
  input            hibi_pe_dma_1_avalon_master_write;
  input   [ 31: 0] hibi_pe_dma_1_avalon_master_writedata;
  input   [ 31: 0] onchip_memory_1_s1_readdata;
  input            reset_n;

  reg              d1_onchip_memory_1_s1_end_xfer;
  reg              d1_reasons_to_wait;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_onchip_memory_1_s1;
  wire             hibi_pe_dma_1_avalon_master_1_arbiterlock;
  wire             hibi_pe_dma_1_avalon_master_1_arbiterlock2;
  wire             hibi_pe_dma_1_avalon_master_1_continuerequest;
  wire             hibi_pe_dma_1_avalon_master_1_granted_onchip_memory_1_s1;
  wire             hibi_pe_dma_1_avalon_master_1_qualified_request_onchip_memory_1_s1;
  wire             hibi_pe_dma_1_avalon_master_1_read_data_valid_onchip_memory_1_s1;
  reg              hibi_pe_dma_1_avalon_master_1_read_data_valid_onchip_memory_1_s1_shift_register;
  wire             hibi_pe_dma_1_avalon_master_1_read_data_valid_onchip_memory_1_s1_shift_register_in;
  wire             hibi_pe_dma_1_avalon_master_1_requests_onchip_memory_1_s1;
  wire             hibi_pe_dma_1_avalon_master_1_saved_grant_onchip_memory_1_s1;
  wire             hibi_pe_dma_1_avalon_master_arbiterlock;
  wire             hibi_pe_dma_1_avalon_master_arbiterlock2;
  wire             hibi_pe_dma_1_avalon_master_continuerequest;
  wire             hibi_pe_dma_1_avalon_master_granted_onchip_memory_1_s1;
  wire             hibi_pe_dma_1_avalon_master_qualified_request_onchip_memory_1_s1;
  wire             hibi_pe_dma_1_avalon_master_requests_onchip_memory_1_s1;
  wire             hibi_pe_dma_1_avalon_master_saved_grant_onchip_memory_1_s1;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  reg              last_cycle_hibi_pe_dma_1_avalon_master_1_granted_slave_onchip_memory_1_s1;
  reg              last_cycle_hibi_pe_dma_1_avalon_master_granted_slave_onchip_memory_1_s1;
  wire    [  8: 0] onchip_memory_1_s1_address;
  wire             onchip_memory_1_s1_allgrants;
  wire             onchip_memory_1_s1_allow_new_arb_cycle;
  wire             onchip_memory_1_s1_any_bursting_master_saved_grant;
  wire             onchip_memory_1_s1_any_continuerequest;
  reg     [  1: 0] onchip_memory_1_s1_arb_addend;
  wire             onchip_memory_1_s1_arb_counter_enable;
  reg              onchip_memory_1_s1_arb_share_counter;
  wire             onchip_memory_1_s1_arb_share_counter_next_value;
  wire             onchip_memory_1_s1_arb_share_set_values;
  wire    [  1: 0] onchip_memory_1_s1_arb_winner;
  wire             onchip_memory_1_s1_arbitration_holdoff_internal;
  wire             onchip_memory_1_s1_beginbursttransfer_internal;
  wire             onchip_memory_1_s1_begins_xfer;
  wire    [  3: 0] onchip_memory_1_s1_byteenable;
  wire             onchip_memory_1_s1_chipselect;
  wire    [  3: 0] onchip_memory_1_s1_chosen_master_double_vector;
  wire    [  1: 0] onchip_memory_1_s1_chosen_master_rot_left;
  wire             onchip_memory_1_s1_clken;
  wire             onchip_memory_1_s1_end_xfer;
  wire             onchip_memory_1_s1_firsttransfer;
  wire    [  1: 0] onchip_memory_1_s1_grant_vector;
  wire             onchip_memory_1_s1_in_a_read_cycle;
  wire             onchip_memory_1_s1_in_a_write_cycle;
  wire    [  1: 0] onchip_memory_1_s1_master_qreq_vector;
  wire             onchip_memory_1_s1_non_bursting_master_requests;
  wire    [ 31: 0] onchip_memory_1_s1_readdata_from_sa;
  reg              onchip_memory_1_s1_reg_firsttransfer;
  wire             onchip_memory_1_s1_reset;
  reg     [  1: 0] onchip_memory_1_s1_saved_chosen_master_vector;
  reg              onchip_memory_1_s1_slavearbiterlockenable;
  wire             onchip_memory_1_s1_slavearbiterlockenable2;
  wire             onchip_memory_1_s1_unreg_firsttransfer;
  wire             onchip_memory_1_s1_waits_for_read;
  wire             onchip_memory_1_s1_waits_for_write;
  wire             onchip_memory_1_s1_write;
  wire    [ 31: 0] onchip_memory_1_s1_writedata;
  wire             p1_hibi_pe_dma_1_avalon_master_1_read_data_valid_onchip_memory_1_s1_shift_register;
  wire    [ 31: 0] shifted_address_to_onchip_memory_1_s1_from_hibi_pe_dma_1_avalon_master;
  wire    [ 31: 0] shifted_address_to_onchip_memory_1_s1_from_hibi_pe_dma_1_avalon_master_1;
  wire             wait_for_onchip_memory_1_s1_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~onchip_memory_1_s1_end_xfer;
    end


  assign onchip_memory_1_s1_begins_xfer = ~d1_reasons_to_wait & ((hibi_pe_dma_1_avalon_master_qualified_request_onchip_memory_1_s1 | hibi_pe_dma_1_avalon_master_1_qualified_request_onchip_memory_1_s1));
  //assign onchip_memory_1_s1_readdata_from_sa = onchip_memory_1_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign onchip_memory_1_s1_readdata_from_sa = onchip_memory_1_s1_readdata;

  assign hibi_pe_dma_1_avalon_master_requests_onchip_memory_1_s1 = (({hibi_pe_dma_1_avalon_master_address_to_slave[31 : 11] , 11'b0} == 32'h0) & (hibi_pe_dma_1_avalon_master_write)) & hibi_pe_dma_1_avalon_master_write;
  //onchip_memory_1_s1_arb_share_counter set values, which is an e_mux
  assign onchip_memory_1_s1_arb_share_set_values = 1;

  //onchip_memory_1_s1_non_bursting_master_requests mux, which is an e_mux
  assign onchip_memory_1_s1_non_bursting_master_requests = hibi_pe_dma_1_avalon_master_requests_onchip_memory_1_s1 |
    hibi_pe_dma_1_avalon_master_1_requests_onchip_memory_1_s1 |
    hibi_pe_dma_1_avalon_master_requests_onchip_memory_1_s1 |
    hibi_pe_dma_1_avalon_master_1_requests_onchip_memory_1_s1;

  //onchip_memory_1_s1_any_bursting_master_saved_grant mux, which is an e_mux
  assign onchip_memory_1_s1_any_bursting_master_saved_grant = 0;

  //onchip_memory_1_s1_arb_share_counter_next_value assignment, which is an e_assign
  assign onchip_memory_1_s1_arb_share_counter_next_value = onchip_memory_1_s1_firsttransfer ? (onchip_memory_1_s1_arb_share_set_values - 1) : |onchip_memory_1_s1_arb_share_counter ? (onchip_memory_1_s1_arb_share_counter - 1) : 0;

  //onchip_memory_1_s1_allgrants all slave grants, which is an e_mux
  assign onchip_memory_1_s1_allgrants = (|onchip_memory_1_s1_grant_vector) |
    (|onchip_memory_1_s1_grant_vector) |
    (|onchip_memory_1_s1_grant_vector) |
    (|onchip_memory_1_s1_grant_vector);

  //onchip_memory_1_s1_end_xfer assignment, which is an e_assign
  assign onchip_memory_1_s1_end_xfer = ~(onchip_memory_1_s1_waits_for_read | onchip_memory_1_s1_waits_for_write);

  //end_xfer_arb_share_counter_term_onchip_memory_1_s1 arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_onchip_memory_1_s1 = onchip_memory_1_s1_end_xfer & (~onchip_memory_1_s1_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //onchip_memory_1_s1_arb_share_counter arbitration counter enable, which is an e_assign
  assign onchip_memory_1_s1_arb_counter_enable = (end_xfer_arb_share_counter_term_onchip_memory_1_s1 & onchip_memory_1_s1_allgrants) | (end_xfer_arb_share_counter_term_onchip_memory_1_s1 & ~onchip_memory_1_s1_non_bursting_master_requests);

  //onchip_memory_1_s1_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          onchip_memory_1_s1_arb_share_counter <= 0;
      else if (onchip_memory_1_s1_arb_counter_enable)
          onchip_memory_1_s1_arb_share_counter <= onchip_memory_1_s1_arb_share_counter_next_value;
    end


  //onchip_memory_1_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          onchip_memory_1_s1_slavearbiterlockenable <= 0;
      else if ((|onchip_memory_1_s1_master_qreq_vector & end_xfer_arb_share_counter_term_onchip_memory_1_s1) | (end_xfer_arb_share_counter_term_onchip_memory_1_s1 & ~onchip_memory_1_s1_non_bursting_master_requests))
          onchip_memory_1_s1_slavearbiterlockenable <= |onchip_memory_1_s1_arb_share_counter_next_value;
    end


  //hibi_pe_dma_1/avalon_master onchip_memory_1/s1 arbiterlock, which is an e_assign
  assign hibi_pe_dma_1_avalon_master_arbiterlock = onchip_memory_1_s1_slavearbiterlockenable & hibi_pe_dma_1_avalon_master_continuerequest;

  //onchip_memory_1_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign onchip_memory_1_s1_slavearbiterlockenable2 = |onchip_memory_1_s1_arb_share_counter_next_value;

  //hibi_pe_dma_1/avalon_master onchip_memory_1/s1 arbiterlock2, which is an e_assign
  assign hibi_pe_dma_1_avalon_master_arbiterlock2 = onchip_memory_1_s1_slavearbiterlockenable2 & hibi_pe_dma_1_avalon_master_continuerequest;

  //hibi_pe_dma_1/avalon_master_1 onchip_memory_1/s1 arbiterlock, which is an e_assign
  assign hibi_pe_dma_1_avalon_master_1_arbiterlock = onchip_memory_1_s1_slavearbiterlockenable & hibi_pe_dma_1_avalon_master_1_continuerequest;

  //hibi_pe_dma_1/avalon_master_1 onchip_memory_1/s1 arbiterlock2, which is an e_assign
  assign hibi_pe_dma_1_avalon_master_1_arbiterlock2 = onchip_memory_1_s1_slavearbiterlockenable2 & hibi_pe_dma_1_avalon_master_1_continuerequest;

  //hibi_pe_dma_1/avalon_master_1 granted onchip_memory_1/s1 last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          last_cycle_hibi_pe_dma_1_avalon_master_1_granted_slave_onchip_memory_1_s1 <= 0;
      else 
        last_cycle_hibi_pe_dma_1_avalon_master_1_granted_slave_onchip_memory_1_s1 <= hibi_pe_dma_1_avalon_master_1_saved_grant_onchip_memory_1_s1 ? 1 : (onchip_memory_1_s1_arbitration_holdoff_internal | ~hibi_pe_dma_1_avalon_master_1_requests_onchip_memory_1_s1) ? 0 : last_cycle_hibi_pe_dma_1_avalon_master_1_granted_slave_onchip_memory_1_s1;
    end


  //hibi_pe_dma_1_avalon_master_1_continuerequest continued request, which is an e_mux
  assign hibi_pe_dma_1_avalon_master_1_continuerequest = last_cycle_hibi_pe_dma_1_avalon_master_1_granted_slave_onchip_memory_1_s1 & hibi_pe_dma_1_avalon_master_1_requests_onchip_memory_1_s1;

  //onchip_memory_1_s1_any_continuerequest at least one master continues requesting, which is an e_mux
  assign onchip_memory_1_s1_any_continuerequest = hibi_pe_dma_1_avalon_master_1_continuerequest |
    hibi_pe_dma_1_avalon_master_continuerequest;

  assign hibi_pe_dma_1_avalon_master_qualified_request_onchip_memory_1_s1 = hibi_pe_dma_1_avalon_master_requests_onchip_memory_1_s1 & ~(hibi_pe_dma_1_avalon_master_1_arbiterlock);
  //onchip_memory_1_s1_writedata mux, which is an e_mux
  assign onchip_memory_1_s1_writedata = hibi_pe_dma_1_avalon_master_writedata;

  //mux onchip_memory_1_s1_clken, which is an e_mux
  assign onchip_memory_1_s1_clken = 1'b1;

  assign hibi_pe_dma_1_avalon_master_1_requests_onchip_memory_1_s1 = (({hibi_pe_dma_1_avalon_master_1_address_to_slave[31 : 11] , 11'b0} == 32'h0) & (hibi_pe_dma_1_avalon_master_1_read)) & hibi_pe_dma_1_avalon_master_1_read;
  //hibi_pe_dma_1/avalon_master granted onchip_memory_1/s1 last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          last_cycle_hibi_pe_dma_1_avalon_master_granted_slave_onchip_memory_1_s1 <= 0;
      else 
        last_cycle_hibi_pe_dma_1_avalon_master_granted_slave_onchip_memory_1_s1 <= hibi_pe_dma_1_avalon_master_saved_grant_onchip_memory_1_s1 ? 1 : (onchip_memory_1_s1_arbitration_holdoff_internal | ~hibi_pe_dma_1_avalon_master_requests_onchip_memory_1_s1) ? 0 : last_cycle_hibi_pe_dma_1_avalon_master_granted_slave_onchip_memory_1_s1;
    end


  //hibi_pe_dma_1_avalon_master_continuerequest continued request, which is an e_mux
  assign hibi_pe_dma_1_avalon_master_continuerequest = last_cycle_hibi_pe_dma_1_avalon_master_granted_slave_onchip_memory_1_s1 & hibi_pe_dma_1_avalon_master_requests_onchip_memory_1_s1;

  assign hibi_pe_dma_1_avalon_master_1_qualified_request_onchip_memory_1_s1 = hibi_pe_dma_1_avalon_master_1_requests_onchip_memory_1_s1 & ~(hibi_pe_dma_1_avalon_master_arbiterlock);
  //hibi_pe_dma_1_avalon_master_1_read_data_valid_onchip_memory_1_s1_shift_register_in mux for readlatency shift register, which is an e_mux
  assign hibi_pe_dma_1_avalon_master_1_read_data_valid_onchip_memory_1_s1_shift_register_in = hibi_pe_dma_1_avalon_master_1_granted_onchip_memory_1_s1 & hibi_pe_dma_1_avalon_master_1_read & ~onchip_memory_1_s1_waits_for_read;

  //shift register p1 hibi_pe_dma_1_avalon_master_1_read_data_valid_onchip_memory_1_s1_shift_register in if flush, otherwise shift left, which is an e_mux
  assign p1_hibi_pe_dma_1_avalon_master_1_read_data_valid_onchip_memory_1_s1_shift_register = {hibi_pe_dma_1_avalon_master_1_read_data_valid_onchip_memory_1_s1_shift_register, hibi_pe_dma_1_avalon_master_1_read_data_valid_onchip_memory_1_s1_shift_register_in};

  //hibi_pe_dma_1_avalon_master_1_read_data_valid_onchip_memory_1_s1_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          hibi_pe_dma_1_avalon_master_1_read_data_valid_onchip_memory_1_s1_shift_register <= 0;
      else 
        hibi_pe_dma_1_avalon_master_1_read_data_valid_onchip_memory_1_s1_shift_register <= p1_hibi_pe_dma_1_avalon_master_1_read_data_valid_onchip_memory_1_s1_shift_register;
    end


  //local readdatavalid hibi_pe_dma_1_avalon_master_1_read_data_valid_onchip_memory_1_s1, which is an e_mux
  assign hibi_pe_dma_1_avalon_master_1_read_data_valid_onchip_memory_1_s1 = hibi_pe_dma_1_avalon_master_1_read_data_valid_onchip_memory_1_s1_shift_register;

  //allow new arb cycle for onchip_memory_1/s1, which is an e_assign
  assign onchip_memory_1_s1_allow_new_arb_cycle = ~hibi_pe_dma_1_avalon_master_arbiterlock & ~hibi_pe_dma_1_avalon_master_1_arbiterlock;

  //hibi_pe_dma_1/avalon_master_1 assignment into master qualified-requests vector for onchip_memory_1/s1, which is an e_assign
  assign onchip_memory_1_s1_master_qreq_vector[0] = hibi_pe_dma_1_avalon_master_1_qualified_request_onchip_memory_1_s1;

  //hibi_pe_dma_1/avalon_master_1 grant onchip_memory_1/s1, which is an e_assign
  assign hibi_pe_dma_1_avalon_master_1_granted_onchip_memory_1_s1 = onchip_memory_1_s1_grant_vector[0];

  //hibi_pe_dma_1/avalon_master_1 saved-grant onchip_memory_1/s1, which is an e_assign
  assign hibi_pe_dma_1_avalon_master_1_saved_grant_onchip_memory_1_s1 = onchip_memory_1_s1_arb_winner[0] && hibi_pe_dma_1_avalon_master_1_requests_onchip_memory_1_s1;

  //hibi_pe_dma_1/avalon_master assignment into master qualified-requests vector for onchip_memory_1/s1, which is an e_assign
  assign onchip_memory_1_s1_master_qreq_vector[1] = hibi_pe_dma_1_avalon_master_qualified_request_onchip_memory_1_s1;

  //hibi_pe_dma_1/avalon_master grant onchip_memory_1/s1, which is an e_assign
  assign hibi_pe_dma_1_avalon_master_granted_onchip_memory_1_s1 = onchip_memory_1_s1_grant_vector[1];

  //hibi_pe_dma_1/avalon_master saved-grant onchip_memory_1/s1, which is an e_assign
  assign hibi_pe_dma_1_avalon_master_saved_grant_onchip_memory_1_s1 = onchip_memory_1_s1_arb_winner[1] && hibi_pe_dma_1_avalon_master_requests_onchip_memory_1_s1;

  //onchip_memory_1/s1 chosen-master double-vector, which is an e_assign
  assign onchip_memory_1_s1_chosen_master_double_vector = {onchip_memory_1_s1_master_qreq_vector, onchip_memory_1_s1_master_qreq_vector} & ({~onchip_memory_1_s1_master_qreq_vector, ~onchip_memory_1_s1_master_qreq_vector} + onchip_memory_1_s1_arb_addend);

  //stable onehot encoding of arb winner
  assign onchip_memory_1_s1_arb_winner = (onchip_memory_1_s1_allow_new_arb_cycle & | onchip_memory_1_s1_grant_vector) ? onchip_memory_1_s1_grant_vector : onchip_memory_1_s1_saved_chosen_master_vector;

  //saved onchip_memory_1_s1_grant_vector, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          onchip_memory_1_s1_saved_chosen_master_vector <= 0;
      else if (onchip_memory_1_s1_allow_new_arb_cycle)
          onchip_memory_1_s1_saved_chosen_master_vector <= |onchip_memory_1_s1_grant_vector ? onchip_memory_1_s1_grant_vector : onchip_memory_1_s1_saved_chosen_master_vector;
    end


  //onehot encoding of chosen master
  assign onchip_memory_1_s1_grant_vector = {(onchip_memory_1_s1_chosen_master_double_vector[1] | onchip_memory_1_s1_chosen_master_double_vector[3]),
    (onchip_memory_1_s1_chosen_master_double_vector[0] | onchip_memory_1_s1_chosen_master_double_vector[2])};

  //onchip_memory_1/s1 chosen master rotated left, which is an e_assign
  assign onchip_memory_1_s1_chosen_master_rot_left = (onchip_memory_1_s1_arb_winner << 1) ? (onchip_memory_1_s1_arb_winner << 1) : 1;

  //onchip_memory_1/s1's addend for next-master-grant
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          onchip_memory_1_s1_arb_addend <= 1;
      else if (|onchip_memory_1_s1_grant_vector)
          onchip_memory_1_s1_arb_addend <= onchip_memory_1_s1_end_xfer? onchip_memory_1_s1_chosen_master_rot_left : onchip_memory_1_s1_grant_vector;
    end


  //~onchip_memory_1_s1_reset assignment, which is an e_assign
  assign onchip_memory_1_s1_reset = ~reset_n;

  assign onchip_memory_1_s1_chipselect = hibi_pe_dma_1_avalon_master_granted_onchip_memory_1_s1 | hibi_pe_dma_1_avalon_master_1_granted_onchip_memory_1_s1;
  //onchip_memory_1_s1_firsttransfer first transaction, which is an e_assign
  assign onchip_memory_1_s1_firsttransfer = onchip_memory_1_s1_begins_xfer ? onchip_memory_1_s1_unreg_firsttransfer : onchip_memory_1_s1_reg_firsttransfer;

  //onchip_memory_1_s1_unreg_firsttransfer first transaction, which is an e_assign
  assign onchip_memory_1_s1_unreg_firsttransfer = ~(onchip_memory_1_s1_slavearbiterlockenable & onchip_memory_1_s1_any_continuerequest);

  //onchip_memory_1_s1_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          onchip_memory_1_s1_reg_firsttransfer <= 1'b1;
      else if (onchip_memory_1_s1_begins_xfer)
          onchip_memory_1_s1_reg_firsttransfer <= onchip_memory_1_s1_unreg_firsttransfer;
    end


  //onchip_memory_1_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign onchip_memory_1_s1_beginbursttransfer_internal = onchip_memory_1_s1_begins_xfer;

  //onchip_memory_1_s1_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  assign onchip_memory_1_s1_arbitration_holdoff_internal = onchip_memory_1_s1_begins_xfer & onchip_memory_1_s1_firsttransfer;

  //onchip_memory_1_s1_write assignment, which is an e_mux
  assign onchip_memory_1_s1_write = hibi_pe_dma_1_avalon_master_granted_onchip_memory_1_s1 & hibi_pe_dma_1_avalon_master_write;

  assign shifted_address_to_onchip_memory_1_s1_from_hibi_pe_dma_1_avalon_master = hibi_pe_dma_1_avalon_master_address_to_slave;
  //onchip_memory_1_s1_address mux, which is an e_mux
  assign onchip_memory_1_s1_address = (hibi_pe_dma_1_avalon_master_granted_onchip_memory_1_s1)? (shifted_address_to_onchip_memory_1_s1_from_hibi_pe_dma_1_avalon_master >> 2) :
    (shifted_address_to_onchip_memory_1_s1_from_hibi_pe_dma_1_avalon_master_1 >> 2);

  assign shifted_address_to_onchip_memory_1_s1_from_hibi_pe_dma_1_avalon_master_1 = hibi_pe_dma_1_avalon_master_1_address_to_slave;
  //d1_onchip_memory_1_s1_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_onchip_memory_1_s1_end_xfer <= 1;
      else 
        d1_onchip_memory_1_s1_end_xfer <= onchip_memory_1_s1_end_xfer;
    end


  //onchip_memory_1_s1_waits_for_read in a cycle, which is an e_mux
  assign onchip_memory_1_s1_waits_for_read = onchip_memory_1_s1_in_a_read_cycle & 0;

  //onchip_memory_1_s1_in_a_read_cycle assignment, which is an e_assign
  assign onchip_memory_1_s1_in_a_read_cycle = hibi_pe_dma_1_avalon_master_1_granted_onchip_memory_1_s1 & hibi_pe_dma_1_avalon_master_1_read;

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = onchip_memory_1_s1_in_a_read_cycle;

  //onchip_memory_1_s1_waits_for_write in a cycle, which is an e_mux
  assign onchip_memory_1_s1_waits_for_write = onchip_memory_1_s1_in_a_write_cycle & 0;

  //onchip_memory_1_s1_in_a_write_cycle assignment, which is an e_assign
  assign onchip_memory_1_s1_in_a_write_cycle = hibi_pe_dma_1_avalon_master_granted_onchip_memory_1_s1 & hibi_pe_dma_1_avalon_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = onchip_memory_1_s1_in_a_write_cycle;

  assign wait_for_onchip_memory_1_s1_counter = 0;
  //onchip_memory_1_s1_byteenable byte enable port mux, which is an e_mux
  assign onchip_memory_1_s1_byteenable = (hibi_pe_dma_1_avalon_master_granted_onchip_memory_1_s1)? hibi_pe_dma_1_avalon_master_byteenable :
    -1;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //onchip_memory_1/s1 enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end


  //grant signals are active simultaneously, which is an e_process
  always @(posedge clk)
    begin
      if (hibi_pe_dma_1_avalon_master_1_granted_onchip_memory_1_s1 + hibi_pe_dma_1_avalon_master_granted_onchip_memory_1_s1 > 1)
        begin
          $write("%0d ns: > 1 of grant signals are active simultaneously", $time);
          $stop;
        end
    end


  //saved_grant signals are active simultaneously, which is an e_process
  always @(posedge clk)
    begin
      if (hibi_pe_dma_1_avalon_master_1_saved_grant_onchip_memory_1_s1 + hibi_pe_dma_1_avalon_master_saved_grant_onchip_memory_1_s1 > 1)
        begin
          $write("%0d ns: > 1 of saved_grant signals are active simultaneously", $time);
          $stop;
        end
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module onchip_memory_1_s2_arbitrator (
                                       // inputs:
                                        clk,
                                        cpu_1_data_master_address_to_slave,
                                        cpu_1_data_master_byteenable,
                                        cpu_1_data_master_latency_counter,
                                        cpu_1_data_master_read,
                                        cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register,
                                        cpu_1_data_master_write,
                                        cpu_1_data_master_writedata,
                                        onchip_memory_1_s2_readdata,
                                        reset_n,

                                       // outputs:
                                        cpu_1_data_master_granted_onchip_memory_1_s2,
                                        cpu_1_data_master_qualified_request_onchip_memory_1_s2,
                                        cpu_1_data_master_read_data_valid_onchip_memory_1_s2,
                                        cpu_1_data_master_requests_onchip_memory_1_s2,
                                        d1_onchip_memory_1_s2_end_xfer,
                                        onchip_memory_1_s2_address,
                                        onchip_memory_1_s2_byteenable,
                                        onchip_memory_1_s2_chipselect,
                                        onchip_memory_1_s2_clken,
                                        onchip_memory_1_s2_readdata_from_sa,
                                        onchip_memory_1_s2_reset,
                                        onchip_memory_1_s2_write,
                                        onchip_memory_1_s2_writedata
                                     )
;

  output           cpu_1_data_master_granted_onchip_memory_1_s2;
  output           cpu_1_data_master_qualified_request_onchip_memory_1_s2;
  output           cpu_1_data_master_read_data_valid_onchip_memory_1_s2;
  output           cpu_1_data_master_requests_onchip_memory_1_s2;
  output           d1_onchip_memory_1_s2_end_xfer;
  output  [  8: 0] onchip_memory_1_s2_address;
  output  [  3: 0] onchip_memory_1_s2_byteenable;
  output           onchip_memory_1_s2_chipselect;
  output           onchip_memory_1_s2_clken;
  output  [ 31: 0] onchip_memory_1_s2_readdata_from_sa;
  output           onchip_memory_1_s2_reset;
  output           onchip_memory_1_s2_write;
  output  [ 31: 0] onchip_memory_1_s2_writedata;
  input            clk;
  input   [ 24: 0] cpu_1_data_master_address_to_slave;
  input   [  3: 0] cpu_1_data_master_byteenable;
  input            cpu_1_data_master_latency_counter;
  input            cpu_1_data_master_read;
  input            cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register;
  input            cpu_1_data_master_write;
  input   [ 31: 0] cpu_1_data_master_writedata;
  input   [ 31: 0] onchip_memory_1_s2_readdata;
  input            reset_n;

  wire             cpu_1_data_master_arbiterlock;
  wire             cpu_1_data_master_arbiterlock2;
  wire             cpu_1_data_master_continuerequest;
  wire             cpu_1_data_master_granted_onchip_memory_1_s2;
  wire             cpu_1_data_master_qualified_request_onchip_memory_1_s2;
  wire             cpu_1_data_master_read_data_valid_onchip_memory_1_s2;
  reg              cpu_1_data_master_read_data_valid_onchip_memory_1_s2_shift_register;
  wire             cpu_1_data_master_read_data_valid_onchip_memory_1_s2_shift_register_in;
  wire             cpu_1_data_master_requests_onchip_memory_1_s2;
  wire             cpu_1_data_master_saved_grant_onchip_memory_1_s2;
  reg              d1_onchip_memory_1_s2_end_xfer;
  reg              d1_reasons_to_wait;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_onchip_memory_1_s2;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  wire    [  8: 0] onchip_memory_1_s2_address;
  wire             onchip_memory_1_s2_allgrants;
  wire             onchip_memory_1_s2_allow_new_arb_cycle;
  wire             onchip_memory_1_s2_any_bursting_master_saved_grant;
  wire             onchip_memory_1_s2_any_continuerequest;
  wire             onchip_memory_1_s2_arb_counter_enable;
  reg     [  1: 0] onchip_memory_1_s2_arb_share_counter;
  wire    [  1: 0] onchip_memory_1_s2_arb_share_counter_next_value;
  wire    [  1: 0] onchip_memory_1_s2_arb_share_set_values;
  wire             onchip_memory_1_s2_beginbursttransfer_internal;
  wire             onchip_memory_1_s2_begins_xfer;
  wire    [  3: 0] onchip_memory_1_s2_byteenable;
  wire             onchip_memory_1_s2_chipselect;
  wire             onchip_memory_1_s2_clken;
  wire             onchip_memory_1_s2_end_xfer;
  wire             onchip_memory_1_s2_firsttransfer;
  wire             onchip_memory_1_s2_grant_vector;
  wire             onchip_memory_1_s2_in_a_read_cycle;
  wire             onchip_memory_1_s2_in_a_write_cycle;
  wire             onchip_memory_1_s2_master_qreq_vector;
  wire             onchip_memory_1_s2_non_bursting_master_requests;
  wire    [ 31: 0] onchip_memory_1_s2_readdata_from_sa;
  reg              onchip_memory_1_s2_reg_firsttransfer;
  wire             onchip_memory_1_s2_reset;
  reg              onchip_memory_1_s2_slavearbiterlockenable;
  wire             onchip_memory_1_s2_slavearbiterlockenable2;
  wire             onchip_memory_1_s2_unreg_firsttransfer;
  wire             onchip_memory_1_s2_waits_for_read;
  wire             onchip_memory_1_s2_waits_for_write;
  wire             onchip_memory_1_s2_write;
  wire    [ 31: 0] onchip_memory_1_s2_writedata;
  wire             p1_cpu_1_data_master_read_data_valid_onchip_memory_1_s2_shift_register;
  wire    [ 24: 0] shifted_address_to_onchip_memory_1_s2_from_cpu_1_data_master;
  wire             wait_for_onchip_memory_1_s2_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~onchip_memory_1_s2_end_xfer;
    end


  assign onchip_memory_1_s2_begins_xfer = ~d1_reasons_to_wait & ((cpu_1_data_master_qualified_request_onchip_memory_1_s2));
  //assign onchip_memory_1_s2_readdata_from_sa = onchip_memory_1_s2_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign onchip_memory_1_s2_readdata_from_sa = onchip_memory_1_s2_readdata;

  assign cpu_1_data_master_requests_onchip_memory_1_s2 = ({cpu_1_data_master_address_to_slave[24 : 11] , 11'b0} == 25'h1001000) & (cpu_1_data_master_read | cpu_1_data_master_write);
  //onchip_memory_1_s2_arb_share_counter set values, which is an e_mux
  assign onchip_memory_1_s2_arb_share_set_values = 1;

  //onchip_memory_1_s2_non_bursting_master_requests mux, which is an e_mux
  assign onchip_memory_1_s2_non_bursting_master_requests = cpu_1_data_master_requests_onchip_memory_1_s2;

  //onchip_memory_1_s2_any_bursting_master_saved_grant mux, which is an e_mux
  assign onchip_memory_1_s2_any_bursting_master_saved_grant = 0;

  //onchip_memory_1_s2_arb_share_counter_next_value assignment, which is an e_assign
  assign onchip_memory_1_s2_arb_share_counter_next_value = onchip_memory_1_s2_firsttransfer ? (onchip_memory_1_s2_arb_share_set_values - 1) : |onchip_memory_1_s2_arb_share_counter ? (onchip_memory_1_s2_arb_share_counter - 1) : 0;

  //onchip_memory_1_s2_allgrants all slave grants, which is an e_mux
  assign onchip_memory_1_s2_allgrants = |onchip_memory_1_s2_grant_vector;

  //onchip_memory_1_s2_end_xfer assignment, which is an e_assign
  assign onchip_memory_1_s2_end_xfer = ~(onchip_memory_1_s2_waits_for_read | onchip_memory_1_s2_waits_for_write);

  //end_xfer_arb_share_counter_term_onchip_memory_1_s2 arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_onchip_memory_1_s2 = onchip_memory_1_s2_end_xfer & (~onchip_memory_1_s2_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //onchip_memory_1_s2_arb_share_counter arbitration counter enable, which is an e_assign
  assign onchip_memory_1_s2_arb_counter_enable = (end_xfer_arb_share_counter_term_onchip_memory_1_s2 & onchip_memory_1_s2_allgrants) | (end_xfer_arb_share_counter_term_onchip_memory_1_s2 & ~onchip_memory_1_s2_non_bursting_master_requests);

  //onchip_memory_1_s2_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          onchip_memory_1_s2_arb_share_counter <= 0;
      else if (onchip_memory_1_s2_arb_counter_enable)
          onchip_memory_1_s2_arb_share_counter <= onchip_memory_1_s2_arb_share_counter_next_value;
    end


  //onchip_memory_1_s2_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          onchip_memory_1_s2_slavearbiterlockenable <= 0;
      else if ((|onchip_memory_1_s2_master_qreq_vector & end_xfer_arb_share_counter_term_onchip_memory_1_s2) | (end_xfer_arb_share_counter_term_onchip_memory_1_s2 & ~onchip_memory_1_s2_non_bursting_master_requests))
          onchip_memory_1_s2_slavearbiterlockenable <= |onchip_memory_1_s2_arb_share_counter_next_value;
    end


  //cpu_1/data_master onchip_memory_1/s2 arbiterlock, which is an e_assign
  assign cpu_1_data_master_arbiterlock = onchip_memory_1_s2_slavearbiterlockenable & cpu_1_data_master_continuerequest;

  //onchip_memory_1_s2_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign onchip_memory_1_s2_slavearbiterlockenable2 = |onchip_memory_1_s2_arb_share_counter_next_value;

  //cpu_1/data_master onchip_memory_1/s2 arbiterlock2, which is an e_assign
  assign cpu_1_data_master_arbiterlock2 = onchip_memory_1_s2_slavearbiterlockenable2 & cpu_1_data_master_continuerequest;

  //onchip_memory_1_s2_any_continuerequest at least one master continues requesting, which is an e_assign
  assign onchip_memory_1_s2_any_continuerequest = 1;

  //cpu_1_data_master_continuerequest continued request, which is an e_assign
  assign cpu_1_data_master_continuerequest = 1;

  assign cpu_1_data_master_qualified_request_onchip_memory_1_s2 = cpu_1_data_master_requests_onchip_memory_1_s2 & ~((cpu_1_data_master_read & ((1 < cpu_1_data_master_latency_counter) | (|cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register))));
  //cpu_1_data_master_read_data_valid_onchip_memory_1_s2_shift_register_in mux for readlatency shift register, which is an e_mux
  assign cpu_1_data_master_read_data_valid_onchip_memory_1_s2_shift_register_in = cpu_1_data_master_granted_onchip_memory_1_s2 & cpu_1_data_master_read & ~onchip_memory_1_s2_waits_for_read;

  //shift register p1 cpu_1_data_master_read_data_valid_onchip_memory_1_s2_shift_register in if flush, otherwise shift left, which is an e_mux
  assign p1_cpu_1_data_master_read_data_valid_onchip_memory_1_s2_shift_register = {cpu_1_data_master_read_data_valid_onchip_memory_1_s2_shift_register, cpu_1_data_master_read_data_valid_onchip_memory_1_s2_shift_register_in};

  //cpu_1_data_master_read_data_valid_onchip_memory_1_s2_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_1_data_master_read_data_valid_onchip_memory_1_s2_shift_register <= 0;
      else 
        cpu_1_data_master_read_data_valid_onchip_memory_1_s2_shift_register <= p1_cpu_1_data_master_read_data_valid_onchip_memory_1_s2_shift_register;
    end


  //local readdatavalid cpu_1_data_master_read_data_valid_onchip_memory_1_s2, which is an e_mux
  assign cpu_1_data_master_read_data_valid_onchip_memory_1_s2 = cpu_1_data_master_read_data_valid_onchip_memory_1_s2_shift_register;

  //onchip_memory_1_s2_writedata mux, which is an e_mux
  assign onchip_memory_1_s2_writedata = cpu_1_data_master_writedata;

  //mux onchip_memory_1_s2_clken, which is an e_mux
  assign onchip_memory_1_s2_clken = 1'b1;

  //master is always granted when requested
  assign cpu_1_data_master_granted_onchip_memory_1_s2 = cpu_1_data_master_qualified_request_onchip_memory_1_s2;

  //cpu_1/data_master saved-grant onchip_memory_1/s2, which is an e_assign
  assign cpu_1_data_master_saved_grant_onchip_memory_1_s2 = cpu_1_data_master_requests_onchip_memory_1_s2;

  //allow new arb cycle for onchip_memory_1/s2, which is an e_assign
  assign onchip_memory_1_s2_allow_new_arb_cycle = 1;

  //placeholder chosen master
  assign onchip_memory_1_s2_grant_vector = 1;

  //placeholder vector of master qualified-requests
  assign onchip_memory_1_s2_master_qreq_vector = 1;

  //~onchip_memory_1_s2_reset assignment, which is an e_assign
  assign onchip_memory_1_s2_reset = ~reset_n;

  assign onchip_memory_1_s2_chipselect = cpu_1_data_master_granted_onchip_memory_1_s2;
  //onchip_memory_1_s2_firsttransfer first transaction, which is an e_assign
  assign onchip_memory_1_s2_firsttransfer = onchip_memory_1_s2_begins_xfer ? onchip_memory_1_s2_unreg_firsttransfer : onchip_memory_1_s2_reg_firsttransfer;

  //onchip_memory_1_s2_unreg_firsttransfer first transaction, which is an e_assign
  assign onchip_memory_1_s2_unreg_firsttransfer = ~(onchip_memory_1_s2_slavearbiterlockenable & onchip_memory_1_s2_any_continuerequest);

  //onchip_memory_1_s2_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          onchip_memory_1_s2_reg_firsttransfer <= 1'b1;
      else if (onchip_memory_1_s2_begins_xfer)
          onchip_memory_1_s2_reg_firsttransfer <= onchip_memory_1_s2_unreg_firsttransfer;
    end


  //onchip_memory_1_s2_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign onchip_memory_1_s2_beginbursttransfer_internal = onchip_memory_1_s2_begins_xfer;

  //onchip_memory_1_s2_write assignment, which is an e_mux
  assign onchip_memory_1_s2_write = cpu_1_data_master_granted_onchip_memory_1_s2 & cpu_1_data_master_write;

  assign shifted_address_to_onchip_memory_1_s2_from_cpu_1_data_master = cpu_1_data_master_address_to_slave;
  //onchip_memory_1_s2_address mux, which is an e_mux
  assign onchip_memory_1_s2_address = shifted_address_to_onchip_memory_1_s2_from_cpu_1_data_master >> 2;

  //d1_onchip_memory_1_s2_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_onchip_memory_1_s2_end_xfer <= 1;
      else 
        d1_onchip_memory_1_s2_end_xfer <= onchip_memory_1_s2_end_xfer;
    end


  //onchip_memory_1_s2_waits_for_read in a cycle, which is an e_mux
  assign onchip_memory_1_s2_waits_for_read = onchip_memory_1_s2_in_a_read_cycle & 0;

  //onchip_memory_1_s2_in_a_read_cycle assignment, which is an e_assign
  assign onchip_memory_1_s2_in_a_read_cycle = cpu_1_data_master_granted_onchip_memory_1_s2 & cpu_1_data_master_read;

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = onchip_memory_1_s2_in_a_read_cycle;

  //onchip_memory_1_s2_waits_for_write in a cycle, which is an e_mux
  assign onchip_memory_1_s2_waits_for_write = onchip_memory_1_s2_in_a_write_cycle & 0;

  //onchip_memory_1_s2_in_a_write_cycle assignment, which is an e_assign
  assign onchip_memory_1_s2_in_a_write_cycle = cpu_1_data_master_granted_onchip_memory_1_s2 & cpu_1_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = onchip_memory_1_s2_in_a_write_cycle;

  assign wait_for_onchip_memory_1_s2_counter = 0;
  //onchip_memory_1_s2_byteenable byte enable port mux, which is an e_mux
  assign onchip_memory_1_s2_byteenable = (cpu_1_data_master_granted_onchip_memory_1_s2)? cpu_1_data_master_byteenable :
    -1;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //onchip_memory_1/s2 enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module rdv_fifo_for_cpu_1_data_master_to_sdram_1_s1_module (
                                                             // inputs:
                                                              clear_fifo,
                                                              clk,
                                                              data_in,
                                                              read,
                                                              reset_n,
                                                              sync_reset,
                                                              write,

                                                             // outputs:
                                                              data_out,
                                                              empty,
                                                              fifo_contains_ones_n,
                                                              full
                                                           )
;

  output           data_out;
  output           empty;
  output           fifo_contains_ones_n;
  output           full;
  input            clear_fifo;
  input            clk;
  input            data_in;
  input            read;
  input            reset_n;
  input            sync_reset;
  input            write;

  wire             data_out;
  wire             empty;
  reg              fifo_contains_ones_n;
  wire             full;
  reg              full_0;
  reg              full_1;
  reg              full_2;
  reg              full_3;
  reg              full_4;
  reg              full_5;
  reg              full_6;
  wire             full_7;
  reg     [  3: 0] how_many_ones;
  wire    [  3: 0] one_count_minus_one;
  wire    [  3: 0] one_count_plus_one;
  wire             p0_full_0;
  wire             p0_stage_0;
  wire             p1_full_1;
  wire             p1_stage_1;
  wire             p2_full_2;
  wire             p2_stage_2;
  wire             p3_full_3;
  wire             p3_stage_3;
  wire             p4_full_4;
  wire             p4_stage_4;
  wire             p5_full_5;
  wire             p5_stage_5;
  wire             p6_full_6;
  wire             p6_stage_6;
  reg              stage_0;
  reg              stage_1;
  reg              stage_2;
  reg              stage_3;
  reg              stage_4;
  reg              stage_5;
  reg              stage_6;
  wire    [  3: 0] updated_one_count;
  assign data_out = stage_0;
  assign full = full_6;
  assign empty = !full_0;
  assign full_7 = 0;
  //data_6, which is an e_mux
  assign p6_stage_6 = ((full_7 & ~clear_fifo) == 0)? data_in :
    data_in;

  //data_reg_6, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_6 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_6))
          if (sync_reset & full_6 & !((full_7 == 0) & read & write))
              stage_6 <= 0;
          else 
            stage_6 <= p6_stage_6;
    end


  //control_6, which is an e_mux
  assign p6_full_6 = ((read & !write) == 0)? full_5 :
    0;

  //control_reg_6, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_6 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_6 <= 0;
          else 
            full_6 <= p6_full_6;
    end


  //data_5, which is an e_mux
  assign p5_stage_5 = ((full_6 & ~clear_fifo) == 0)? data_in :
    stage_6;

  //data_reg_5, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_5 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_5))
          if (sync_reset & full_5 & !((full_6 == 0) & read & write))
              stage_5 <= 0;
          else 
            stage_5 <= p5_stage_5;
    end


  //control_5, which is an e_mux
  assign p5_full_5 = ((read & !write) == 0)? full_4 :
    full_6;

  //control_reg_5, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_5 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_5 <= 0;
          else 
            full_5 <= p5_full_5;
    end


  //data_4, which is an e_mux
  assign p4_stage_4 = ((full_5 & ~clear_fifo) == 0)? data_in :
    stage_5;

  //data_reg_4, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_4 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_4))
          if (sync_reset & full_4 & !((full_5 == 0) & read & write))
              stage_4 <= 0;
          else 
            stage_4 <= p4_stage_4;
    end


  //control_4, which is an e_mux
  assign p4_full_4 = ((read & !write) == 0)? full_3 :
    full_5;

  //control_reg_4, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_4 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_4 <= 0;
          else 
            full_4 <= p4_full_4;
    end


  //data_3, which is an e_mux
  assign p3_stage_3 = ((full_4 & ~clear_fifo) == 0)? data_in :
    stage_4;

  //data_reg_3, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_3 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_3))
          if (sync_reset & full_3 & !((full_4 == 0) & read & write))
              stage_3 <= 0;
          else 
            stage_3 <= p3_stage_3;
    end


  //control_3, which is an e_mux
  assign p3_full_3 = ((read & !write) == 0)? full_2 :
    full_4;

  //control_reg_3, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_3 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_3 <= 0;
          else 
            full_3 <= p3_full_3;
    end


  //data_2, which is an e_mux
  assign p2_stage_2 = ((full_3 & ~clear_fifo) == 0)? data_in :
    stage_3;

  //data_reg_2, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_2 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_2))
          if (sync_reset & full_2 & !((full_3 == 0) & read & write))
              stage_2 <= 0;
          else 
            stage_2 <= p2_stage_2;
    end


  //control_2, which is an e_mux
  assign p2_full_2 = ((read & !write) == 0)? full_1 :
    full_3;

  //control_reg_2, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_2 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_2 <= 0;
          else 
            full_2 <= p2_full_2;
    end


  //data_1, which is an e_mux
  assign p1_stage_1 = ((full_2 & ~clear_fifo) == 0)? data_in :
    stage_2;

  //data_reg_1, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_1 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_1))
          if (sync_reset & full_1 & !((full_2 == 0) & read & write))
              stage_1 <= 0;
          else 
            stage_1 <= p1_stage_1;
    end


  //control_1, which is an e_mux
  assign p1_full_1 = ((read & !write) == 0)? full_0 :
    full_2;

  //control_reg_1, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_1 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_1 <= 0;
          else 
            full_1 <= p1_full_1;
    end


  //data_0, which is an e_mux
  assign p0_stage_0 = ((full_1 & ~clear_fifo) == 0)? data_in :
    stage_1;

  //data_reg_0, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_0 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_0))
          if (sync_reset & full_0 & !((full_1 == 0) & read & write))
              stage_0 <= 0;
          else 
            stage_0 <= p0_stage_0;
    end


  //control_0, which is an e_mux
  assign p0_full_0 = ((read & !write) == 0)? 1 :
    full_1;

  //control_reg_0, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_0 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo & ~write)
              full_0 <= 0;
          else 
            full_0 <= p0_full_0;
    end


  assign one_count_plus_one = how_many_ones + 1;
  assign one_count_minus_one = how_many_ones - 1;
  //updated_one_count, which is an e_mux
  assign updated_one_count = ((((clear_fifo | sync_reset) & !write)))? 0 :
    ((((clear_fifo | sync_reset) & write)))? |data_in :
    ((read & (|data_in) & write & (|stage_0)))? how_many_ones :
    ((write & (|data_in)))? one_count_plus_one :
    ((read & (|stage_0)))? one_count_minus_one :
    how_many_ones;

  //counts how many ones in the data pipeline, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          how_many_ones <= 0;
      else if (clear_fifo | sync_reset | read | write)
          how_many_ones <= updated_one_count;
    end


  //this fifo contains ones in the data pipeline, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          fifo_contains_ones_n <= 1;
      else if (clear_fifo | sync_reset | read | write)
          fifo_contains_ones_n <= ~(|updated_one_count);
    end



endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module rdv_fifo_for_cpu_1_instruction_master_to_sdram_1_s1_module (
                                                                    // inputs:
                                                                     clear_fifo,
                                                                     clk,
                                                                     data_in,
                                                                     read,
                                                                     reset_n,
                                                                     sync_reset,
                                                                     write,

                                                                    // outputs:
                                                                     data_out,
                                                                     empty,
                                                                     fifo_contains_ones_n,
                                                                     full
                                                                  )
;

  output           data_out;
  output           empty;
  output           fifo_contains_ones_n;
  output           full;
  input            clear_fifo;
  input            clk;
  input            data_in;
  input            read;
  input            reset_n;
  input            sync_reset;
  input            write;

  wire             data_out;
  wire             empty;
  reg              fifo_contains_ones_n;
  wire             full;
  reg              full_0;
  reg              full_1;
  reg              full_2;
  reg              full_3;
  reg              full_4;
  reg              full_5;
  reg              full_6;
  wire             full_7;
  reg     [  3: 0] how_many_ones;
  wire    [  3: 0] one_count_minus_one;
  wire    [  3: 0] one_count_plus_one;
  wire             p0_full_0;
  wire             p0_stage_0;
  wire             p1_full_1;
  wire             p1_stage_1;
  wire             p2_full_2;
  wire             p2_stage_2;
  wire             p3_full_3;
  wire             p3_stage_3;
  wire             p4_full_4;
  wire             p4_stage_4;
  wire             p5_full_5;
  wire             p5_stage_5;
  wire             p6_full_6;
  wire             p6_stage_6;
  reg              stage_0;
  reg              stage_1;
  reg              stage_2;
  reg              stage_3;
  reg              stage_4;
  reg              stage_5;
  reg              stage_6;
  wire    [  3: 0] updated_one_count;
  assign data_out = stage_0;
  assign full = full_6;
  assign empty = !full_0;
  assign full_7 = 0;
  //data_6, which is an e_mux
  assign p6_stage_6 = ((full_7 & ~clear_fifo) == 0)? data_in :
    data_in;

  //data_reg_6, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_6 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_6))
          if (sync_reset & full_6 & !((full_7 == 0) & read & write))
              stage_6 <= 0;
          else 
            stage_6 <= p6_stage_6;
    end


  //control_6, which is an e_mux
  assign p6_full_6 = ((read & !write) == 0)? full_5 :
    0;

  //control_reg_6, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_6 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_6 <= 0;
          else 
            full_6 <= p6_full_6;
    end


  //data_5, which is an e_mux
  assign p5_stage_5 = ((full_6 & ~clear_fifo) == 0)? data_in :
    stage_6;

  //data_reg_5, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_5 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_5))
          if (sync_reset & full_5 & !((full_6 == 0) & read & write))
              stage_5 <= 0;
          else 
            stage_5 <= p5_stage_5;
    end


  //control_5, which is an e_mux
  assign p5_full_5 = ((read & !write) == 0)? full_4 :
    full_6;

  //control_reg_5, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_5 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_5 <= 0;
          else 
            full_5 <= p5_full_5;
    end


  //data_4, which is an e_mux
  assign p4_stage_4 = ((full_5 & ~clear_fifo) == 0)? data_in :
    stage_5;

  //data_reg_4, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_4 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_4))
          if (sync_reset & full_4 & !((full_5 == 0) & read & write))
              stage_4 <= 0;
          else 
            stage_4 <= p4_stage_4;
    end


  //control_4, which is an e_mux
  assign p4_full_4 = ((read & !write) == 0)? full_3 :
    full_5;

  //control_reg_4, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_4 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_4 <= 0;
          else 
            full_4 <= p4_full_4;
    end


  //data_3, which is an e_mux
  assign p3_stage_3 = ((full_4 & ~clear_fifo) == 0)? data_in :
    stage_4;

  //data_reg_3, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_3 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_3))
          if (sync_reset & full_3 & !((full_4 == 0) & read & write))
              stage_3 <= 0;
          else 
            stage_3 <= p3_stage_3;
    end


  //control_3, which is an e_mux
  assign p3_full_3 = ((read & !write) == 0)? full_2 :
    full_4;

  //control_reg_3, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_3 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_3 <= 0;
          else 
            full_3 <= p3_full_3;
    end


  //data_2, which is an e_mux
  assign p2_stage_2 = ((full_3 & ~clear_fifo) == 0)? data_in :
    stage_3;

  //data_reg_2, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_2 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_2))
          if (sync_reset & full_2 & !((full_3 == 0) & read & write))
              stage_2 <= 0;
          else 
            stage_2 <= p2_stage_2;
    end


  //control_2, which is an e_mux
  assign p2_full_2 = ((read & !write) == 0)? full_1 :
    full_3;

  //control_reg_2, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_2 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_2 <= 0;
          else 
            full_2 <= p2_full_2;
    end


  //data_1, which is an e_mux
  assign p1_stage_1 = ((full_2 & ~clear_fifo) == 0)? data_in :
    stage_2;

  //data_reg_1, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_1 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_1))
          if (sync_reset & full_1 & !((full_2 == 0) & read & write))
              stage_1 <= 0;
          else 
            stage_1 <= p1_stage_1;
    end


  //control_1, which is an e_mux
  assign p1_full_1 = ((read & !write) == 0)? full_0 :
    full_2;

  //control_reg_1, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_1 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_1 <= 0;
          else 
            full_1 <= p1_full_1;
    end


  //data_0, which is an e_mux
  assign p0_stage_0 = ((full_1 & ~clear_fifo) == 0)? data_in :
    stage_1;

  //data_reg_0, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_0 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_0))
          if (sync_reset & full_0 & !((full_1 == 0) & read & write))
              stage_0 <= 0;
          else 
            stage_0 <= p0_stage_0;
    end


  //control_0, which is an e_mux
  assign p0_full_0 = ((read & !write) == 0)? 1 :
    full_1;

  //control_reg_0, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_0 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo & ~write)
              full_0 <= 0;
          else 
            full_0 <= p0_full_0;
    end


  assign one_count_plus_one = how_many_ones + 1;
  assign one_count_minus_one = how_many_ones - 1;
  //updated_one_count, which is an e_mux
  assign updated_one_count = ((((clear_fifo | sync_reset) & !write)))? 0 :
    ((((clear_fifo | sync_reset) & write)))? |data_in :
    ((read & (|data_in) & write & (|stage_0)))? how_many_ones :
    ((write & (|data_in)))? one_count_plus_one :
    ((read & (|stage_0)))? one_count_minus_one :
    how_many_ones;

  //counts how many ones in the data pipeline, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          how_many_ones <= 0;
      else if (clear_fifo | sync_reset | read | write)
          how_many_ones <= updated_one_count;
    end


  //this fifo contains ones in the data pipeline, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          fifo_contains_ones_n <= 1;
      else if (clear_fifo | sync_reset | read | write)
          fifo_contains_ones_n <= ~(|updated_one_count);
    end



endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module sdram_1_s1_arbitrator (
                               // inputs:
                                clk,
                                cpu_1_data_master_address_to_slave,
                                cpu_1_data_master_byteenable,
                                cpu_1_data_master_dbs_address,
                                cpu_1_data_master_dbs_write_16,
                                cpu_1_data_master_latency_counter,
                                cpu_1_data_master_read,
                                cpu_1_data_master_write,
                                cpu_1_instruction_master_address_to_slave,
                                cpu_1_instruction_master_dbs_address,
                                cpu_1_instruction_master_latency_counter,
                                cpu_1_instruction_master_read,
                                reset_n,
                                sdram_1_s1_readdata,
                                sdram_1_s1_readdatavalid,
                                sdram_1_s1_waitrequest,

                               // outputs:
                                cpu_1_data_master_byteenable_sdram_1_s1,
                                cpu_1_data_master_granted_sdram_1_s1,
                                cpu_1_data_master_qualified_request_sdram_1_s1,
                                cpu_1_data_master_read_data_valid_sdram_1_s1,
                                cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register,
                                cpu_1_data_master_requests_sdram_1_s1,
                                cpu_1_instruction_master_granted_sdram_1_s1,
                                cpu_1_instruction_master_qualified_request_sdram_1_s1,
                                cpu_1_instruction_master_read_data_valid_sdram_1_s1,
                                cpu_1_instruction_master_read_data_valid_sdram_1_s1_shift_register,
                                cpu_1_instruction_master_requests_sdram_1_s1,
                                d1_sdram_1_s1_end_xfer,
                                sdram_1_s1_address,
                                sdram_1_s1_byteenable_n,
                                sdram_1_s1_chipselect,
                                sdram_1_s1_read_n,
                                sdram_1_s1_readdata_from_sa,
                                sdram_1_s1_reset_n,
                                sdram_1_s1_waitrequest_from_sa,
                                sdram_1_s1_write_n,
                                sdram_1_s1_writedata
                             )
;

  output  [  1: 0] cpu_1_data_master_byteenable_sdram_1_s1;
  output           cpu_1_data_master_granted_sdram_1_s1;
  output           cpu_1_data_master_qualified_request_sdram_1_s1;
  output           cpu_1_data_master_read_data_valid_sdram_1_s1;
  output           cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register;
  output           cpu_1_data_master_requests_sdram_1_s1;
  output           cpu_1_instruction_master_granted_sdram_1_s1;
  output           cpu_1_instruction_master_qualified_request_sdram_1_s1;
  output           cpu_1_instruction_master_read_data_valid_sdram_1_s1;
  output           cpu_1_instruction_master_read_data_valid_sdram_1_s1_shift_register;
  output           cpu_1_instruction_master_requests_sdram_1_s1;
  output           d1_sdram_1_s1_end_xfer;
  output  [ 21: 0] sdram_1_s1_address;
  output  [  1: 0] sdram_1_s1_byteenable_n;
  output           sdram_1_s1_chipselect;
  output           sdram_1_s1_read_n;
  output  [ 15: 0] sdram_1_s1_readdata_from_sa;
  output           sdram_1_s1_reset_n;
  output           sdram_1_s1_waitrequest_from_sa;
  output           sdram_1_s1_write_n;
  output  [ 15: 0] sdram_1_s1_writedata;
  input            clk;
  input   [ 24: 0] cpu_1_data_master_address_to_slave;
  input   [  3: 0] cpu_1_data_master_byteenable;
  input   [  1: 0] cpu_1_data_master_dbs_address;
  input   [ 15: 0] cpu_1_data_master_dbs_write_16;
  input            cpu_1_data_master_latency_counter;
  input            cpu_1_data_master_read;
  input            cpu_1_data_master_write;
  input   [ 24: 0] cpu_1_instruction_master_address_to_slave;
  input   [  1: 0] cpu_1_instruction_master_dbs_address;
  input            cpu_1_instruction_master_latency_counter;
  input            cpu_1_instruction_master_read;
  input            reset_n;
  input   [ 15: 0] sdram_1_s1_readdata;
  input            sdram_1_s1_readdatavalid;
  input            sdram_1_s1_waitrequest;

  wire             cpu_1_data_master_arbiterlock;
  wire             cpu_1_data_master_arbiterlock2;
  wire    [  1: 0] cpu_1_data_master_byteenable_sdram_1_s1;
  wire    [  1: 0] cpu_1_data_master_byteenable_sdram_1_s1_segment_0;
  wire    [  1: 0] cpu_1_data_master_byteenable_sdram_1_s1_segment_1;
  wire             cpu_1_data_master_continuerequest;
  wire             cpu_1_data_master_granted_sdram_1_s1;
  wire             cpu_1_data_master_qualified_request_sdram_1_s1;
  wire             cpu_1_data_master_rdv_fifo_empty_sdram_1_s1;
  wire             cpu_1_data_master_rdv_fifo_output_from_sdram_1_s1;
  wire             cpu_1_data_master_read_data_valid_sdram_1_s1;
  wire             cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register;
  wire             cpu_1_data_master_requests_sdram_1_s1;
  wire             cpu_1_data_master_saved_grant_sdram_1_s1;
  wire             cpu_1_instruction_master_arbiterlock;
  wire             cpu_1_instruction_master_arbiterlock2;
  wire             cpu_1_instruction_master_continuerequest;
  wire             cpu_1_instruction_master_granted_sdram_1_s1;
  wire             cpu_1_instruction_master_qualified_request_sdram_1_s1;
  wire             cpu_1_instruction_master_rdv_fifo_empty_sdram_1_s1;
  wire             cpu_1_instruction_master_rdv_fifo_output_from_sdram_1_s1;
  wire             cpu_1_instruction_master_read_data_valid_sdram_1_s1;
  wire             cpu_1_instruction_master_read_data_valid_sdram_1_s1_shift_register;
  wire             cpu_1_instruction_master_requests_sdram_1_s1;
  wire             cpu_1_instruction_master_saved_grant_sdram_1_s1;
  reg              d1_reasons_to_wait;
  reg              d1_sdram_1_s1_end_xfer;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_sdram_1_s1;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  reg              last_cycle_cpu_1_data_master_granted_slave_sdram_1_s1;
  reg              last_cycle_cpu_1_instruction_master_granted_slave_sdram_1_s1;
  wire    [ 21: 0] sdram_1_s1_address;
  wire             sdram_1_s1_allgrants;
  wire             sdram_1_s1_allow_new_arb_cycle;
  wire             sdram_1_s1_any_bursting_master_saved_grant;
  wire             sdram_1_s1_any_continuerequest;
  reg     [  1: 0] sdram_1_s1_arb_addend;
  wire             sdram_1_s1_arb_counter_enable;
  reg     [  1: 0] sdram_1_s1_arb_share_counter;
  wire    [  1: 0] sdram_1_s1_arb_share_counter_next_value;
  wire    [  1: 0] sdram_1_s1_arb_share_set_values;
  wire    [  1: 0] sdram_1_s1_arb_winner;
  wire             sdram_1_s1_arbitration_holdoff_internal;
  wire             sdram_1_s1_beginbursttransfer_internal;
  wire             sdram_1_s1_begins_xfer;
  wire    [  1: 0] sdram_1_s1_byteenable_n;
  wire             sdram_1_s1_chipselect;
  wire    [  3: 0] sdram_1_s1_chosen_master_double_vector;
  wire    [  1: 0] sdram_1_s1_chosen_master_rot_left;
  wire             sdram_1_s1_end_xfer;
  wire             sdram_1_s1_firsttransfer;
  wire    [  1: 0] sdram_1_s1_grant_vector;
  wire             sdram_1_s1_in_a_read_cycle;
  wire             sdram_1_s1_in_a_write_cycle;
  wire    [  1: 0] sdram_1_s1_master_qreq_vector;
  wire             sdram_1_s1_move_on_to_next_transaction;
  wire             sdram_1_s1_non_bursting_master_requests;
  wire             sdram_1_s1_read_n;
  wire    [ 15: 0] sdram_1_s1_readdata_from_sa;
  wire             sdram_1_s1_readdatavalid_from_sa;
  reg              sdram_1_s1_reg_firsttransfer;
  wire             sdram_1_s1_reset_n;
  reg     [  1: 0] sdram_1_s1_saved_chosen_master_vector;
  reg              sdram_1_s1_slavearbiterlockenable;
  wire             sdram_1_s1_slavearbiterlockenable2;
  wire             sdram_1_s1_unreg_firsttransfer;
  wire             sdram_1_s1_waitrequest_from_sa;
  wire             sdram_1_s1_waits_for_read;
  wire             sdram_1_s1_waits_for_write;
  wire             sdram_1_s1_write_n;
  wire    [ 15: 0] sdram_1_s1_writedata;
  wire    [ 24: 0] shifted_address_to_sdram_1_s1_from_cpu_1_data_master;
  wire    [ 24: 0] shifted_address_to_sdram_1_s1_from_cpu_1_instruction_master;
  wire             wait_for_sdram_1_s1_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~sdram_1_s1_end_xfer;
    end


  assign sdram_1_s1_begins_xfer = ~d1_reasons_to_wait & ((cpu_1_data_master_qualified_request_sdram_1_s1 | cpu_1_instruction_master_qualified_request_sdram_1_s1));
  //assign sdram_1_s1_readdatavalid_from_sa = sdram_1_s1_readdatavalid so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign sdram_1_s1_readdatavalid_from_sa = sdram_1_s1_readdatavalid;

  //assign sdram_1_s1_readdata_from_sa = sdram_1_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign sdram_1_s1_readdata_from_sa = sdram_1_s1_readdata;

  assign cpu_1_data_master_requests_sdram_1_s1 = ({cpu_1_data_master_address_to_slave[24 : 23] , 23'b0} == 25'h800000) & (cpu_1_data_master_read | cpu_1_data_master_write);
  //assign sdram_1_s1_waitrequest_from_sa = sdram_1_s1_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign sdram_1_s1_waitrequest_from_sa = sdram_1_s1_waitrequest;

  //sdram_1_s1_arb_share_counter set values, which is an e_mux
  assign sdram_1_s1_arb_share_set_values = (cpu_1_data_master_granted_sdram_1_s1)? 2 :
    (cpu_1_instruction_master_granted_sdram_1_s1)? 2 :
    (cpu_1_data_master_granted_sdram_1_s1)? 2 :
    (cpu_1_instruction_master_granted_sdram_1_s1)? 2 :
    1;

  //sdram_1_s1_non_bursting_master_requests mux, which is an e_mux
  assign sdram_1_s1_non_bursting_master_requests = cpu_1_data_master_requests_sdram_1_s1 |
    cpu_1_instruction_master_requests_sdram_1_s1 |
    cpu_1_data_master_requests_sdram_1_s1 |
    cpu_1_instruction_master_requests_sdram_1_s1;

  //sdram_1_s1_any_bursting_master_saved_grant mux, which is an e_mux
  assign sdram_1_s1_any_bursting_master_saved_grant = 0;

  //sdram_1_s1_arb_share_counter_next_value assignment, which is an e_assign
  assign sdram_1_s1_arb_share_counter_next_value = sdram_1_s1_firsttransfer ? (sdram_1_s1_arb_share_set_values - 1) : |sdram_1_s1_arb_share_counter ? (sdram_1_s1_arb_share_counter - 1) : 0;

  //sdram_1_s1_allgrants all slave grants, which is an e_mux
  assign sdram_1_s1_allgrants = (|sdram_1_s1_grant_vector) |
    (|sdram_1_s1_grant_vector) |
    (|sdram_1_s1_grant_vector) |
    (|sdram_1_s1_grant_vector);

  //sdram_1_s1_end_xfer assignment, which is an e_assign
  assign sdram_1_s1_end_xfer = ~(sdram_1_s1_waits_for_read | sdram_1_s1_waits_for_write);

  //end_xfer_arb_share_counter_term_sdram_1_s1 arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_sdram_1_s1 = sdram_1_s1_end_xfer & (~sdram_1_s1_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //sdram_1_s1_arb_share_counter arbitration counter enable, which is an e_assign
  assign sdram_1_s1_arb_counter_enable = (end_xfer_arb_share_counter_term_sdram_1_s1 & sdram_1_s1_allgrants) | (end_xfer_arb_share_counter_term_sdram_1_s1 & ~sdram_1_s1_non_bursting_master_requests);

  //sdram_1_s1_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          sdram_1_s1_arb_share_counter <= 0;
      else if (sdram_1_s1_arb_counter_enable)
          sdram_1_s1_arb_share_counter <= sdram_1_s1_arb_share_counter_next_value;
    end


  //sdram_1_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          sdram_1_s1_slavearbiterlockenable <= 0;
      else if ((|sdram_1_s1_master_qreq_vector & end_xfer_arb_share_counter_term_sdram_1_s1) | (end_xfer_arb_share_counter_term_sdram_1_s1 & ~sdram_1_s1_non_bursting_master_requests))
          sdram_1_s1_slavearbiterlockenable <= |sdram_1_s1_arb_share_counter_next_value;
    end


  //cpu_1/data_master sdram_1/s1 arbiterlock, which is an e_assign
  assign cpu_1_data_master_arbiterlock = sdram_1_s1_slavearbiterlockenable & cpu_1_data_master_continuerequest;

  //sdram_1_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign sdram_1_s1_slavearbiterlockenable2 = |sdram_1_s1_arb_share_counter_next_value;

  //cpu_1/data_master sdram_1/s1 arbiterlock2, which is an e_assign
  assign cpu_1_data_master_arbiterlock2 = sdram_1_s1_slavearbiterlockenable2 & cpu_1_data_master_continuerequest;

  //cpu_1/instruction_master sdram_1/s1 arbiterlock, which is an e_assign
  assign cpu_1_instruction_master_arbiterlock = sdram_1_s1_slavearbiterlockenable & cpu_1_instruction_master_continuerequest;

  //cpu_1/instruction_master sdram_1/s1 arbiterlock2, which is an e_assign
  assign cpu_1_instruction_master_arbiterlock2 = sdram_1_s1_slavearbiterlockenable2 & cpu_1_instruction_master_continuerequest;

  //cpu_1/instruction_master granted sdram_1/s1 last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          last_cycle_cpu_1_instruction_master_granted_slave_sdram_1_s1 <= 0;
      else 
        last_cycle_cpu_1_instruction_master_granted_slave_sdram_1_s1 <= cpu_1_instruction_master_saved_grant_sdram_1_s1 ? 1 : (sdram_1_s1_arbitration_holdoff_internal | ~cpu_1_instruction_master_requests_sdram_1_s1) ? 0 : last_cycle_cpu_1_instruction_master_granted_slave_sdram_1_s1;
    end


  //cpu_1_instruction_master_continuerequest continued request, which is an e_mux
  assign cpu_1_instruction_master_continuerequest = last_cycle_cpu_1_instruction_master_granted_slave_sdram_1_s1 & cpu_1_instruction_master_requests_sdram_1_s1;

  //sdram_1_s1_any_continuerequest at least one master continues requesting, which is an e_mux
  assign sdram_1_s1_any_continuerequest = cpu_1_instruction_master_continuerequest |
    cpu_1_data_master_continuerequest;

  assign cpu_1_data_master_qualified_request_sdram_1_s1 = cpu_1_data_master_requests_sdram_1_s1 & ~((cpu_1_data_master_read & ((cpu_1_data_master_latency_counter != 0) | (1 < cpu_1_data_master_latency_counter))) | ((!cpu_1_data_master_byteenable_sdram_1_s1) & cpu_1_data_master_write) | cpu_1_instruction_master_arbiterlock);
  //unique name for sdram_1_s1_move_on_to_next_transaction, which is an e_assign
  assign sdram_1_s1_move_on_to_next_transaction = sdram_1_s1_readdatavalid_from_sa;

  //rdv_fifo_for_cpu_1_data_master_to_sdram_1_s1, which is an e_fifo_with_registered_outputs
  rdv_fifo_for_cpu_1_data_master_to_sdram_1_s1_module rdv_fifo_for_cpu_1_data_master_to_sdram_1_s1
    (
      .clear_fifo           (1'b0),
      .clk                  (clk),
      .data_in              (cpu_1_data_master_granted_sdram_1_s1),
      .data_out             (cpu_1_data_master_rdv_fifo_output_from_sdram_1_s1),
      .empty                (),
      .fifo_contains_ones_n (cpu_1_data_master_rdv_fifo_empty_sdram_1_s1),
      .full                 (),
      .read                 (sdram_1_s1_move_on_to_next_transaction),
      .reset_n              (reset_n),
      .sync_reset           (1'b0),
      .write                (in_a_read_cycle & ~sdram_1_s1_waits_for_read)
    );

  assign cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register = ~cpu_1_data_master_rdv_fifo_empty_sdram_1_s1;
  //local readdatavalid cpu_1_data_master_read_data_valid_sdram_1_s1, which is an e_mux
  assign cpu_1_data_master_read_data_valid_sdram_1_s1 = (sdram_1_s1_readdatavalid_from_sa & cpu_1_data_master_rdv_fifo_output_from_sdram_1_s1) & ~ cpu_1_data_master_rdv_fifo_empty_sdram_1_s1;

  //sdram_1_s1_writedata mux, which is an e_mux
  assign sdram_1_s1_writedata = cpu_1_data_master_dbs_write_16;

  assign cpu_1_instruction_master_requests_sdram_1_s1 = (({cpu_1_instruction_master_address_to_slave[24 : 23] , 23'b0} == 25'h800000) & (cpu_1_instruction_master_read)) & cpu_1_instruction_master_read;
  //cpu_1/data_master granted sdram_1/s1 last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          last_cycle_cpu_1_data_master_granted_slave_sdram_1_s1 <= 0;
      else 
        last_cycle_cpu_1_data_master_granted_slave_sdram_1_s1 <= cpu_1_data_master_saved_grant_sdram_1_s1 ? 1 : (sdram_1_s1_arbitration_holdoff_internal | ~cpu_1_data_master_requests_sdram_1_s1) ? 0 : last_cycle_cpu_1_data_master_granted_slave_sdram_1_s1;
    end


  //cpu_1_data_master_continuerequest continued request, which is an e_mux
  assign cpu_1_data_master_continuerequest = last_cycle_cpu_1_data_master_granted_slave_sdram_1_s1 & cpu_1_data_master_requests_sdram_1_s1;

  assign cpu_1_instruction_master_qualified_request_sdram_1_s1 = cpu_1_instruction_master_requests_sdram_1_s1 & ~((cpu_1_instruction_master_read & ((cpu_1_instruction_master_latency_counter != 0) | (1 < cpu_1_instruction_master_latency_counter))) | cpu_1_data_master_arbiterlock);
  //rdv_fifo_for_cpu_1_instruction_master_to_sdram_1_s1, which is an e_fifo_with_registered_outputs
  rdv_fifo_for_cpu_1_instruction_master_to_sdram_1_s1_module rdv_fifo_for_cpu_1_instruction_master_to_sdram_1_s1
    (
      .clear_fifo           (1'b0),
      .clk                  (clk),
      .data_in              (cpu_1_instruction_master_granted_sdram_1_s1),
      .data_out             (cpu_1_instruction_master_rdv_fifo_output_from_sdram_1_s1),
      .empty                (),
      .fifo_contains_ones_n (cpu_1_instruction_master_rdv_fifo_empty_sdram_1_s1),
      .full                 (),
      .read                 (sdram_1_s1_move_on_to_next_transaction),
      .reset_n              (reset_n),
      .sync_reset           (1'b0),
      .write                (in_a_read_cycle & ~sdram_1_s1_waits_for_read)
    );

  assign cpu_1_instruction_master_read_data_valid_sdram_1_s1_shift_register = ~cpu_1_instruction_master_rdv_fifo_empty_sdram_1_s1;
  //local readdatavalid cpu_1_instruction_master_read_data_valid_sdram_1_s1, which is an e_mux
  assign cpu_1_instruction_master_read_data_valid_sdram_1_s1 = (sdram_1_s1_readdatavalid_from_sa & cpu_1_instruction_master_rdv_fifo_output_from_sdram_1_s1) & ~ cpu_1_instruction_master_rdv_fifo_empty_sdram_1_s1;

  //allow new arb cycle for sdram_1/s1, which is an e_assign
  assign sdram_1_s1_allow_new_arb_cycle = ~cpu_1_data_master_arbiterlock & ~cpu_1_instruction_master_arbiterlock;

  //cpu_1/instruction_master assignment into master qualified-requests vector for sdram_1/s1, which is an e_assign
  assign sdram_1_s1_master_qreq_vector[0] = cpu_1_instruction_master_qualified_request_sdram_1_s1;

  //cpu_1/instruction_master grant sdram_1/s1, which is an e_assign
  assign cpu_1_instruction_master_granted_sdram_1_s1 = sdram_1_s1_grant_vector[0];

  //cpu_1/instruction_master saved-grant sdram_1/s1, which is an e_assign
  assign cpu_1_instruction_master_saved_grant_sdram_1_s1 = sdram_1_s1_arb_winner[0] && cpu_1_instruction_master_requests_sdram_1_s1;

  //cpu_1/data_master assignment into master qualified-requests vector for sdram_1/s1, which is an e_assign
  assign sdram_1_s1_master_qreq_vector[1] = cpu_1_data_master_qualified_request_sdram_1_s1;

  //cpu_1/data_master grant sdram_1/s1, which is an e_assign
  assign cpu_1_data_master_granted_sdram_1_s1 = sdram_1_s1_grant_vector[1];

  //cpu_1/data_master saved-grant sdram_1/s1, which is an e_assign
  assign cpu_1_data_master_saved_grant_sdram_1_s1 = sdram_1_s1_arb_winner[1] && cpu_1_data_master_requests_sdram_1_s1;

  //sdram_1/s1 chosen-master double-vector, which is an e_assign
  assign sdram_1_s1_chosen_master_double_vector = {sdram_1_s1_master_qreq_vector, sdram_1_s1_master_qreq_vector} & ({~sdram_1_s1_master_qreq_vector, ~sdram_1_s1_master_qreq_vector} + sdram_1_s1_arb_addend);

  //stable onehot encoding of arb winner
  assign sdram_1_s1_arb_winner = (sdram_1_s1_allow_new_arb_cycle & | sdram_1_s1_grant_vector) ? sdram_1_s1_grant_vector : sdram_1_s1_saved_chosen_master_vector;

  //saved sdram_1_s1_grant_vector, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          sdram_1_s1_saved_chosen_master_vector <= 0;
      else if (sdram_1_s1_allow_new_arb_cycle)
          sdram_1_s1_saved_chosen_master_vector <= |sdram_1_s1_grant_vector ? sdram_1_s1_grant_vector : sdram_1_s1_saved_chosen_master_vector;
    end


  //onehot encoding of chosen master
  assign sdram_1_s1_grant_vector = {(sdram_1_s1_chosen_master_double_vector[1] | sdram_1_s1_chosen_master_double_vector[3]),
    (sdram_1_s1_chosen_master_double_vector[0] | sdram_1_s1_chosen_master_double_vector[2])};

  //sdram_1/s1 chosen master rotated left, which is an e_assign
  assign sdram_1_s1_chosen_master_rot_left = (sdram_1_s1_arb_winner << 1) ? (sdram_1_s1_arb_winner << 1) : 1;

  //sdram_1/s1's addend for next-master-grant
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          sdram_1_s1_arb_addend <= 1;
      else if (|sdram_1_s1_grant_vector)
          sdram_1_s1_arb_addend <= sdram_1_s1_end_xfer? sdram_1_s1_chosen_master_rot_left : sdram_1_s1_grant_vector;
    end


  //sdram_1_s1_reset_n assignment, which is an e_assign
  assign sdram_1_s1_reset_n = reset_n;

  assign sdram_1_s1_chipselect = cpu_1_data_master_granted_sdram_1_s1 | cpu_1_instruction_master_granted_sdram_1_s1;
  //sdram_1_s1_firsttransfer first transaction, which is an e_assign
  assign sdram_1_s1_firsttransfer = sdram_1_s1_begins_xfer ? sdram_1_s1_unreg_firsttransfer : sdram_1_s1_reg_firsttransfer;

  //sdram_1_s1_unreg_firsttransfer first transaction, which is an e_assign
  assign sdram_1_s1_unreg_firsttransfer = ~(sdram_1_s1_slavearbiterlockenable & sdram_1_s1_any_continuerequest);

  //sdram_1_s1_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          sdram_1_s1_reg_firsttransfer <= 1'b1;
      else if (sdram_1_s1_begins_xfer)
          sdram_1_s1_reg_firsttransfer <= sdram_1_s1_unreg_firsttransfer;
    end


  //sdram_1_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign sdram_1_s1_beginbursttransfer_internal = sdram_1_s1_begins_xfer;

  //sdram_1_s1_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  assign sdram_1_s1_arbitration_holdoff_internal = sdram_1_s1_begins_xfer & sdram_1_s1_firsttransfer;

  //~sdram_1_s1_read_n assignment, which is an e_mux
  assign sdram_1_s1_read_n = ~((cpu_1_data_master_granted_sdram_1_s1 & cpu_1_data_master_read) | (cpu_1_instruction_master_granted_sdram_1_s1 & cpu_1_instruction_master_read));

  //~sdram_1_s1_write_n assignment, which is an e_mux
  assign sdram_1_s1_write_n = ~(cpu_1_data_master_granted_sdram_1_s1 & cpu_1_data_master_write);

  assign shifted_address_to_sdram_1_s1_from_cpu_1_data_master = {cpu_1_data_master_address_to_slave >> 2,
    cpu_1_data_master_dbs_address[1],
    {1 {1'b0}}};

  //sdram_1_s1_address mux, which is an e_mux
  assign sdram_1_s1_address = (cpu_1_data_master_granted_sdram_1_s1)? (shifted_address_to_sdram_1_s1_from_cpu_1_data_master >> 1) :
    (shifted_address_to_sdram_1_s1_from_cpu_1_instruction_master >> 1);

  assign shifted_address_to_sdram_1_s1_from_cpu_1_instruction_master = {cpu_1_instruction_master_address_to_slave >> 2,
    cpu_1_instruction_master_dbs_address[1],
    {1 {1'b0}}};

  //d1_sdram_1_s1_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_sdram_1_s1_end_xfer <= 1;
      else 
        d1_sdram_1_s1_end_xfer <= sdram_1_s1_end_xfer;
    end


  //sdram_1_s1_waits_for_read in a cycle, which is an e_mux
  assign sdram_1_s1_waits_for_read = sdram_1_s1_in_a_read_cycle & sdram_1_s1_waitrequest_from_sa;

  //sdram_1_s1_in_a_read_cycle assignment, which is an e_assign
  assign sdram_1_s1_in_a_read_cycle = (cpu_1_data_master_granted_sdram_1_s1 & cpu_1_data_master_read) | (cpu_1_instruction_master_granted_sdram_1_s1 & cpu_1_instruction_master_read);

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = sdram_1_s1_in_a_read_cycle;

  //sdram_1_s1_waits_for_write in a cycle, which is an e_mux
  assign sdram_1_s1_waits_for_write = sdram_1_s1_in_a_write_cycle & sdram_1_s1_waitrequest_from_sa;

  //sdram_1_s1_in_a_write_cycle assignment, which is an e_assign
  assign sdram_1_s1_in_a_write_cycle = cpu_1_data_master_granted_sdram_1_s1 & cpu_1_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = sdram_1_s1_in_a_write_cycle;

  assign wait_for_sdram_1_s1_counter = 0;
  //~sdram_1_s1_byteenable_n byte enable port mux, which is an e_mux
  assign sdram_1_s1_byteenable_n = ~((cpu_1_data_master_granted_sdram_1_s1)? cpu_1_data_master_byteenable_sdram_1_s1 :
    -1);

  assign {cpu_1_data_master_byteenable_sdram_1_s1_segment_1,
cpu_1_data_master_byteenable_sdram_1_s1_segment_0} = cpu_1_data_master_byteenable;
  assign cpu_1_data_master_byteenable_sdram_1_s1 = ((cpu_1_data_master_dbs_address[1] == 0))? cpu_1_data_master_byteenable_sdram_1_s1_segment_0 :
    cpu_1_data_master_byteenable_sdram_1_s1_segment_1;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //sdram_1/s1 enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end


  //grant signals are active simultaneously, which is an e_process
  always @(posedge clk)
    begin
      if (cpu_1_data_master_granted_sdram_1_s1 + cpu_1_instruction_master_granted_sdram_1_s1 > 1)
        begin
          $write("%0d ns: > 1 of grant signals are active simultaneously", $time);
          $stop;
        end
    end


  //saved_grant signals are active simultaneously, which is an e_process
  always @(posedge clk)
    begin
      if (cpu_1_data_master_saved_grant_sdram_1_s1 + cpu_1_instruction_master_saved_grant_sdram_1_s1 > 1)
        begin
          $write("%0d ns: > 1 of saved_grant signals are active simultaneously", $time);
          $stop;
        end
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module timer_1_s1_arbitrator (
                               // inputs:
                                clk,
                                cpu_1_data_master_address_to_slave,
                                cpu_1_data_master_latency_counter,
                                cpu_1_data_master_read,
                                cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register,
                                cpu_1_data_master_write,
                                cpu_1_data_master_writedata,
                                reset_n,
                                timer_1_s1_irq,
                                timer_1_s1_readdata,

                               // outputs:
                                cpu_1_data_master_granted_timer_1_s1,
                                cpu_1_data_master_qualified_request_timer_1_s1,
                                cpu_1_data_master_read_data_valid_timer_1_s1,
                                cpu_1_data_master_requests_timer_1_s1,
                                d1_timer_1_s1_end_xfer,
                                timer_1_s1_address,
                                timer_1_s1_chipselect,
                                timer_1_s1_irq_from_sa,
                                timer_1_s1_readdata_from_sa,
                                timer_1_s1_reset_n,
                                timer_1_s1_write_n,
                                timer_1_s1_writedata
                             )
;

  output           cpu_1_data_master_granted_timer_1_s1;
  output           cpu_1_data_master_qualified_request_timer_1_s1;
  output           cpu_1_data_master_read_data_valid_timer_1_s1;
  output           cpu_1_data_master_requests_timer_1_s1;
  output           d1_timer_1_s1_end_xfer;
  output  [  2: 0] timer_1_s1_address;
  output           timer_1_s1_chipselect;
  output           timer_1_s1_irq_from_sa;
  output  [ 15: 0] timer_1_s1_readdata_from_sa;
  output           timer_1_s1_reset_n;
  output           timer_1_s1_write_n;
  output  [ 15: 0] timer_1_s1_writedata;
  input            clk;
  input   [ 24: 0] cpu_1_data_master_address_to_slave;
  input            cpu_1_data_master_latency_counter;
  input            cpu_1_data_master_read;
  input            cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register;
  input            cpu_1_data_master_write;
  input   [ 31: 0] cpu_1_data_master_writedata;
  input            reset_n;
  input            timer_1_s1_irq;
  input   [ 15: 0] timer_1_s1_readdata;

  wire             cpu_1_data_master_arbiterlock;
  wire             cpu_1_data_master_arbiterlock2;
  wire             cpu_1_data_master_continuerequest;
  wire             cpu_1_data_master_granted_timer_1_s1;
  wire             cpu_1_data_master_qualified_request_timer_1_s1;
  wire             cpu_1_data_master_read_data_valid_timer_1_s1;
  wire             cpu_1_data_master_requests_timer_1_s1;
  wire             cpu_1_data_master_saved_grant_timer_1_s1;
  reg              d1_reasons_to_wait;
  reg              d1_timer_1_s1_end_xfer;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_timer_1_s1;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  wire    [ 24: 0] shifted_address_to_timer_1_s1_from_cpu_1_data_master;
  wire    [  2: 0] timer_1_s1_address;
  wire             timer_1_s1_allgrants;
  wire             timer_1_s1_allow_new_arb_cycle;
  wire             timer_1_s1_any_bursting_master_saved_grant;
  wire             timer_1_s1_any_continuerequest;
  wire             timer_1_s1_arb_counter_enable;
  reg     [  1: 0] timer_1_s1_arb_share_counter;
  wire    [  1: 0] timer_1_s1_arb_share_counter_next_value;
  wire    [  1: 0] timer_1_s1_arb_share_set_values;
  wire             timer_1_s1_beginbursttransfer_internal;
  wire             timer_1_s1_begins_xfer;
  wire             timer_1_s1_chipselect;
  wire             timer_1_s1_end_xfer;
  wire             timer_1_s1_firsttransfer;
  wire             timer_1_s1_grant_vector;
  wire             timer_1_s1_in_a_read_cycle;
  wire             timer_1_s1_in_a_write_cycle;
  wire             timer_1_s1_irq_from_sa;
  wire             timer_1_s1_master_qreq_vector;
  wire             timer_1_s1_non_bursting_master_requests;
  wire    [ 15: 0] timer_1_s1_readdata_from_sa;
  reg              timer_1_s1_reg_firsttransfer;
  wire             timer_1_s1_reset_n;
  reg              timer_1_s1_slavearbiterlockenable;
  wire             timer_1_s1_slavearbiterlockenable2;
  wire             timer_1_s1_unreg_firsttransfer;
  wire             timer_1_s1_waits_for_read;
  wire             timer_1_s1_waits_for_write;
  wire             timer_1_s1_write_n;
  wire    [ 15: 0] timer_1_s1_writedata;
  wire             wait_for_timer_1_s1_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~timer_1_s1_end_xfer;
    end


  assign timer_1_s1_begins_xfer = ~d1_reasons_to_wait & ((cpu_1_data_master_qualified_request_timer_1_s1));
  //assign timer_1_s1_readdata_from_sa = timer_1_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign timer_1_s1_readdata_from_sa = timer_1_s1_readdata;

  assign cpu_1_data_master_requests_timer_1_s1 = ({cpu_1_data_master_address_to_slave[24 : 5] , 5'b0} == 25'h1001a00) & (cpu_1_data_master_read | cpu_1_data_master_write);
  //timer_1_s1_arb_share_counter set values, which is an e_mux
  assign timer_1_s1_arb_share_set_values = 1;

  //timer_1_s1_non_bursting_master_requests mux, which is an e_mux
  assign timer_1_s1_non_bursting_master_requests = cpu_1_data_master_requests_timer_1_s1;

  //timer_1_s1_any_bursting_master_saved_grant mux, which is an e_mux
  assign timer_1_s1_any_bursting_master_saved_grant = 0;

  //timer_1_s1_arb_share_counter_next_value assignment, which is an e_assign
  assign timer_1_s1_arb_share_counter_next_value = timer_1_s1_firsttransfer ? (timer_1_s1_arb_share_set_values - 1) : |timer_1_s1_arb_share_counter ? (timer_1_s1_arb_share_counter - 1) : 0;

  //timer_1_s1_allgrants all slave grants, which is an e_mux
  assign timer_1_s1_allgrants = |timer_1_s1_grant_vector;

  //timer_1_s1_end_xfer assignment, which is an e_assign
  assign timer_1_s1_end_xfer = ~(timer_1_s1_waits_for_read | timer_1_s1_waits_for_write);

  //end_xfer_arb_share_counter_term_timer_1_s1 arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_timer_1_s1 = timer_1_s1_end_xfer & (~timer_1_s1_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //timer_1_s1_arb_share_counter arbitration counter enable, which is an e_assign
  assign timer_1_s1_arb_counter_enable = (end_xfer_arb_share_counter_term_timer_1_s1 & timer_1_s1_allgrants) | (end_xfer_arb_share_counter_term_timer_1_s1 & ~timer_1_s1_non_bursting_master_requests);

  //timer_1_s1_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          timer_1_s1_arb_share_counter <= 0;
      else if (timer_1_s1_arb_counter_enable)
          timer_1_s1_arb_share_counter <= timer_1_s1_arb_share_counter_next_value;
    end


  //timer_1_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          timer_1_s1_slavearbiterlockenable <= 0;
      else if ((|timer_1_s1_master_qreq_vector & end_xfer_arb_share_counter_term_timer_1_s1) | (end_xfer_arb_share_counter_term_timer_1_s1 & ~timer_1_s1_non_bursting_master_requests))
          timer_1_s1_slavearbiterlockenable <= |timer_1_s1_arb_share_counter_next_value;
    end


  //cpu_1/data_master timer_1/s1 arbiterlock, which is an e_assign
  assign cpu_1_data_master_arbiterlock = timer_1_s1_slavearbiterlockenable & cpu_1_data_master_continuerequest;

  //timer_1_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign timer_1_s1_slavearbiterlockenable2 = |timer_1_s1_arb_share_counter_next_value;

  //cpu_1/data_master timer_1/s1 arbiterlock2, which is an e_assign
  assign cpu_1_data_master_arbiterlock2 = timer_1_s1_slavearbiterlockenable2 & cpu_1_data_master_continuerequest;

  //timer_1_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  assign timer_1_s1_any_continuerequest = 1;

  //cpu_1_data_master_continuerequest continued request, which is an e_assign
  assign cpu_1_data_master_continuerequest = 1;

  assign cpu_1_data_master_qualified_request_timer_1_s1 = cpu_1_data_master_requests_timer_1_s1 & ~((cpu_1_data_master_read & ((cpu_1_data_master_latency_counter != 0) | (|cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register))));
  //local readdatavalid cpu_1_data_master_read_data_valid_timer_1_s1, which is an e_mux
  assign cpu_1_data_master_read_data_valid_timer_1_s1 = cpu_1_data_master_granted_timer_1_s1 & cpu_1_data_master_read & ~timer_1_s1_waits_for_read;

  //timer_1_s1_writedata mux, which is an e_mux
  assign timer_1_s1_writedata = cpu_1_data_master_writedata;

  //master is always granted when requested
  assign cpu_1_data_master_granted_timer_1_s1 = cpu_1_data_master_qualified_request_timer_1_s1;

  //cpu_1/data_master saved-grant timer_1/s1, which is an e_assign
  assign cpu_1_data_master_saved_grant_timer_1_s1 = cpu_1_data_master_requests_timer_1_s1;

  //allow new arb cycle for timer_1/s1, which is an e_assign
  assign timer_1_s1_allow_new_arb_cycle = 1;

  //placeholder chosen master
  assign timer_1_s1_grant_vector = 1;

  //placeholder vector of master qualified-requests
  assign timer_1_s1_master_qreq_vector = 1;

  //timer_1_s1_reset_n assignment, which is an e_assign
  assign timer_1_s1_reset_n = reset_n;

  assign timer_1_s1_chipselect = cpu_1_data_master_granted_timer_1_s1;
  //timer_1_s1_firsttransfer first transaction, which is an e_assign
  assign timer_1_s1_firsttransfer = timer_1_s1_begins_xfer ? timer_1_s1_unreg_firsttransfer : timer_1_s1_reg_firsttransfer;

  //timer_1_s1_unreg_firsttransfer first transaction, which is an e_assign
  assign timer_1_s1_unreg_firsttransfer = ~(timer_1_s1_slavearbiterlockenable & timer_1_s1_any_continuerequest);

  //timer_1_s1_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          timer_1_s1_reg_firsttransfer <= 1'b1;
      else if (timer_1_s1_begins_xfer)
          timer_1_s1_reg_firsttransfer <= timer_1_s1_unreg_firsttransfer;
    end


  //timer_1_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign timer_1_s1_beginbursttransfer_internal = timer_1_s1_begins_xfer;

  //~timer_1_s1_write_n assignment, which is an e_mux
  assign timer_1_s1_write_n = ~(cpu_1_data_master_granted_timer_1_s1 & cpu_1_data_master_write);

  assign shifted_address_to_timer_1_s1_from_cpu_1_data_master = cpu_1_data_master_address_to_slave;
  //timer_1_s1_address mux, which is an e_mux
  assign timer_1_s1_address = shifted_address_to_timer_1_s1_from_cpu_1_data_master >> 2;

  //d1_timer_1_s1_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_timer_1_s1_end_xfer <= 1;
      else 
        d1_timer_1_s1_end_xfer <= timer_1_s1_end_xfer;
    end


  //timer_1_s1_waits_for_read in a cycle, which is an e_mux
  assign timer_1_s1_waits_for_read = timer_1_s1_in_a_read_cycle & timer_1_s1_begins_xfer;

  //timer_1_s1_in_a_read_cycle assignment, which is an e_assign
  assign timer_1_s1_in_a_read_cycle = cpu_1_data_master_granted_timer_1_s1 & cpu_1_data_master_read;

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = timer_1_s1_in_a_read_cycle;

  //timer_1_s1_waits_for_write in a cycle, which is an e_mux
  assign timer_1_s1_waits_for_write = timer_1_s1_in_a_write_cycle & 0;

  //timer_1_s1_in_a_write_cycle assignment, which is an e_assign
  assign timer_1_s1_in_a_write_cycle = cpu_1_data_master_granted_timer_1_s1 & cpu_1_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = timer_1_s1_in_a_write_cycle;

  assign wait_for_timer_1_s1_counter = 0;
  //assign timer_1_s1_irq_from_sa = timer_1_s1_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign timer_1_s1_irq_from_sa = timer_1_s1_irq;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //timer_1/s1 enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module nios_ii_sdram_reset_clk_0_domain_synch_module (
                                                       // inputs:
                                                        clk,
                                                        data_in,
                                                        reset_n,

                                                       // outputs:
                                                        data_out
                                                     )
;

  output           data_out;
  input            clk;
  input            data_in;
  input            reset_n;

  reg              data_in_d1 /* synthesis ALTERA_ATTRIBUTE = "{-from \"*\"} CUT=ON ; PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101"  */;
  reg              data_out /* synthesis ALTERA_ATTRIBUTE = "PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101"  */;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          data_in_d1 <= 0;
      else 
        data_in_d1 <= data_in;
    end


  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          data_out <= 0;
      else 
        data_out <= data_in_d1;
    end



endmodule


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module nios_ii_sdram (
                       // 1) global signals:
                        clk_0,
                        reset_n,

                       // the_hibi_pe_dma_1
                        hibi_av_in_to_the_hibi_pe_dma_1,
                        hibi_av_out_from_the_hibi_pe_dma_1,
                        hibi_comm_in_to_the_hibi_pe_dma_1,
                        hibi_comm_out_from_the_hibi_pe_dma_1,
                        hibi_data_in_to_the_hibi_pe_dma_1,
                        hibi_data_out_from_the_hibi_pe_dma_1,
                        hibi_empty_in_to_the_hibi_pe_dma_1,
                        hibi_full_in_to_the_hibi_pe_dma_1,
                        hibi_re_out_from_the_hibi_pe_dma_1,
                        hibi_we_out_from_the_hibi_pe_dma_1,

                       // the_sdram_1
                        zs_addr_from_the_sdram_1,
                        zs_ba_from_the_sdram_1,
                        zs_cas_n_from_the_sdram_1,
                        zs_cke_from_the_sdram_1,
                        zs_cs_n_from_the_sdram_1,
                        zs_dq_to_and_from_the_sdram_1,
                        zs_dqm_from_the_sdram_1,
                        zs_ras_n_from_the_sdram_1,
                        zs_we_n_from_the_sdram_1
                     )
;

  output           hibi_av_out_from_the_hibi_pe_dma_1;
  output  [  4: 0] hibi_comm_out_from_the_hibi_pe_dma_1;
  output  [ 31: 0] hibi_data_out_from_the_hibi_pe_dma_1;
  output           hibi_re_out_from_the_hibi_pe_dma_1;
  output           hibi_we_out_from_the_hibi_pe_dma_1;
  output  [ 11: 0] zs_addr_from_the_sdram_1;
  output  [  1: 0] zs_ba_from_the_sdram_1;
  output           zs_cas_n_from_the_sdram_1;
  output           zs_cke_from_the_sdram_1;
  output           zs_cs_n_from_the_sdram_1;
  inout   [ 15: 0] zs_dq_to_and_from_the_sdram_1;
  output  [  1: 0] zs_dqm_from_the_sdram_1;
  output           zs_ras_n_from_the_sdram_1;
  output           zs_we_n_from_the_sdram_1;
  input            clk_0;
  input            hibi_av_in_to_the_hibi_pe_dma_1;
  input   [  4: 0] hibi_comm_in_to_the_hibi_pe_dma_1;
  input   [ 31: 0] hibi_data_in_to_the_hibi_pe_dma_1;
  input            hibi_empty_in_to_the_hibi_pe_dma_1;
  input            hibi_full_in_to_the_hibi_pe_dma_1;
  input            reset_n;

  wire             clk_0_reset_n;
  wire    [ 24: 0] cpu_1_data_master_address;
  wire    [ 24: 0] cpu_1_data_master_address_to_slave;
  wire    [  3: 0] cpu_1_data_master_byteenable;
  wire    [  1: 0] cpu_1_data_master_byteenable_sdram_1_s1;
  wire    [  1: 0] cpu_1_data_master_dbs_address;
  wire    [ 15: 0] cpu_1_data_master_dbs_write_16;
  wire             cpu_1_data_master_debugaccess;
  wire             cpu_1_data_master_granted_cpu_1_jtag_debug_module;
  wire             cpu_1_data_master_granted_hibi_pe_dma_1_avalon_slave_0;
  wire             cpu_1_data_master_granted_jtag_uart_1_avalon_jtag_slave;
  wire             cpu_1_data_master_granted_onchip_memory_1_s2;
  wire             cpu_1_data_master_granted_sdram_1_s1;
  wire             cpu_1_data_master_granted_timer_1_s1;
  wire    [ 31: 0] cpu_1_data_master_irq;
  wire             cpu_1_data_master_latency_counter;
  wire             cpu_1_data_master_qualified_request_cpu_1_jtag_debug_module;
  wire             cpu_1_data_master_qualified_request_hibi_pe_dma_1_avalon_slave_0;
  wire             cpu_1_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave;
  wire             cpu_1_data_master_qualified_request_onchip_memory_1_s2;
  wire             cpu_1_data_master_qualified_request_sdram_1_s1;
  wire             cpu_1_data_master_qualified_request_timer_1_s1;
  wire             cpu_1_data_master_read;
  wire             cpu_1_data_master_read_data_valid_cpu_1_jtag_debug_module;
  wire             cpu_1_data_master_read_data_valid_hibi_pe_dma_1_avalon_slave_0;
  wire             cpu_1_data_master_read_data_valid_jtag_uart_1_avalon_jtag_slave;
  wire             cpu_1_data_master_read_data_valid_onchip_memory_1_s2;
  wire             cpu_1_data_master_read_data_valid_sdram_1_s1;
  wire             cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register;
  wire             cpu_1_data_master_read_data_valid_timer_1_s1;
  wire    [ 31: 0] cpu_1_data_master_readdata;
  wire             cpu_1_data_master_readdatavalid;
  wire             cpu_1_data_master_requests_cpu_1_jtag_debug_module;
  wire             cpu_1_data_master_requests_hibi_pe_dma_1_avalon_slave_0;
  wire             cpu_1_data_master_requests_jtag_uart_1_avalon_jtag_slave;
  wire             cpu_1_data_master_requests_onchip_memory_1_s2;
  wire             cpu_1_data_master_requests_sdram_1_s1;
  wire             cpu_1_data_master_requests_timer_1_s1;
  wire             cpu_1_data_master_waitrequest;
  wire             cpu_1_data_master_write;
  wire    [ 31: 0] cpu_1_data_master_writedata;
  wire    [ 24: 0] cpu_1_instruction_master_address;
  wire    [ 24: 0] cpu_1_instruction_master_address_to_slave;
  wire    [  1: 0] cpu_1_instruction_master_dbs_address;
  wire             cpu_1_instruction_master_granted_cpu_1_jtag_debug_module;
  wire             cpu_1_instruction_master_granted_sdram_1_s1;
  wire             cpu_1_instruction_master_latency_counter;
  wire             cpu_1_instruction_master_qualified_request_cpu_1_jtag_debug_module;
  wire             cpu_1_instruction_master_qualified_request_sdram_1_s1;
  wire             cpu_1_instruction_master_read;
  wire             cpu_1_instruction_master_read_data_valid_cpu_1_jtag_debug_module;
  wire             cpu_1_instruction_master_read_data_valid_sdram_1_s1;
  wire             cpu_1_instruction_master_read_data_valid_sdram_1_s1_shift_register;
  wire    [ 31: 0] cpu_1_instruction_master_readdata;
  wire             cpu_1_instruction_master_readdatavalid;
  wire             cpu_1_instruction_master_requests_cpu_1_jtag_debug_module;
  wire             cpu_1_instruction_master_requests_sdram_1_s1;
  wire             cpu_1_instruction_master_waitrequest;
  wire    [  8: 0] cpu_1_jtag_debug_module_address;
  wire             cpu_1_jtag_debug_module_begintransfer;
  wire    [  3: 0] cpu_1_jtag_debug_module_byteenable;
  wire             cpu_1_jtag_debug_module_chipselect;
  wire             cpu_1_jtag_debug_module_debugaccess;
  wire    [ 31: 0] cpu_1_jtag_debug_module_readdata;
  wire    [ 31: 0] cpu_1_jtag_debug_module_readdata_from_sa;
  wire             cpu_1_jtag_debug_module_reset_n;
  wire             cpu_1_jtag_debug_module_resetrequest;
  wire             cpu_1_jtag_debug_module_resetrequest_from_sa;
  wire             cpu_1_jtag_debug_module_write;
  wire    [ 31: 0] cpu_1_jtag_debug_module_writedata;
  wire             d1_cpu_1_jtag_debug_module_end_xfer;
  wire             d1_hibi_pe_dma_1_avalon_slave_0_end_xfer;
  wire             d1_jtag_uart_1_avalon_jtag_slave_end_xfer;
  wire             d1_onchip_memory_1_s1_end_xfer;
  wire             d1_onchip_memory_1_s2_end_xfer;
  wire             d1_sdram_1_s1_end_xfer;
  wire             d1_timer_1_s1_end_xfer;
  wire             hibi_av_out_from_the_hibi_pe_dma_1;
  wire    [  4: 0] hibi_comm_out_from_the_hibi_pe_dma_1;
  wire    [ 31: 0] hibi_data_out_from_the_hibi_pe_dma_1;
  wire    [ 31: 0] hibi_pe_dma_1_avalon_master_1_address;
  wire    [ 31: 0] hibi_pe_dma_1_avalon_master_1_address_to_slave;
  wire             hibi_pe_dma_1_avalon_master_1_granted_onchip_memory_1_s1;
  wire             hibi_pe_dma_1_avalon_master_1_latency_counter;
  wire             hibi_pe_dma_1_avalon_master_1_qualified_request_onchip_memory_1_s1;
  wire             hibi_pe_dma_1_avalon_master_1_read;
  wire             hibi_pe_dma_1_avalon_master_1_read_data_valid_onchip_memory_1_s1;
  wire    [ 31: 0] hibi_pe_dma_1_avalon_master_1_readdata;
  wire             hibi_pe_dma_1_avalon_master_1_readdatavalid;
  wire             hibi_pe_dma_1_avalon_master_1_requests_onchip_memory_1_s1;
  wire             hibi_pe_dma_1_avalon_master_1_waitrequest;
  wire    [ 31: 0] hibi_pe_dma_1_avalon_master_address;
  wire    [ 31: 0] hibi_pe_dma_1_avalon_master_address_to_slave;
  wire    [  3: 0] hibi_pe_dma_1_avalon_master_byteenable;
  wire             hibi_pe_dma_1_avalon_master_granted_onchip_memory_1_s1;
  wire             hibi_pe_dma_1_avalon_master_qualified_request_onchip_memory_1_s1;
  wire             hibi_pe_dma_1_avalon_master_requests_onchip_memory_1_s1;
  wire             hibi_pe_dma_1_avalon_master_waitrequest;
  wire             hibi_pe_dma_1_avalon_master_write;
  wire    [ 31: 0] hibi_pe_dma_1_avalon_master_writedata;
  wire    [  6: 0] hibi_pe_dma_1_avalon_slave_0_address;
  wire             hibi_pe_dma_1_avalon_slave_0_chipselect;
  wire             hibi_pe_dma_1_avalon_slave_0_irq;
  wire             hibi_pe_dma_1_avalon_slave_0_irq_from_sa;
  wire             hibi_pe_dma_1_avalon_slave_0_read;
  wire    [ 31: 0] hibi_pe_dma_1_avalon_slave_0_readdata;
  wire    [ 31: 0] hibi_pe_dma_1_avalon_slave_0_readdata_from_sa;
  wire             hibi_pe_dma_1_avalon_slave_0_reset_n;
  wire             hibi_pe_dma_1_avalon_slave_0_waitrequest;
  wire             hibi_pe_dma_1_avalon_slave_0_waitrequest_from_sa;
  wire             hibi_pe_dma_1_avalon_slave_0_write;
  wire    [ 31: 0] hibi_pe_dma_1_avalon_slave_0_writedata;
  wire             hibi_re_out_from_the_hibi_pe_dma_1;
  wire             hibi_we_out_from_the_hibi_pe_dma_1;
  wire             jtag_uart_1_avalon_jtag_slave_address;
  wire             jtag_uart_1_avalon_jtag_slave_chipselect;
  wire             jtag_uart_1_avalon_jtag_slave_dataavailable;
  wire             jtag_uart_1_avalon_jtag_slave_dataavailable_from_sa;
  wire             jtag_uart_1_avalon_jtag_slave_irq;
  wire             jtag_uart_1_avalon_jtag_slave_irq_from_sa;
  wire             jtag_uart_1_avalon_jtag_slave_read_n;
  wire    [ 31: 0] jtag_uart_1_avalon_jtag_slave_readdata;
  wire    [ 31: 0] jtag_uart_1_avalon_jtag_slave_readdata_from_sa;
  wire             jtag_uart_1_avalon_jtag_slave_readyfordata;
  wire             jtag_uart_1_avalon_jtag_slave_readyfordata_from_sa;
  wire             jtag_uart_1_avalon_jtag_slave_reset_n;
  wire             jtag_uart_1_avalon_jtag_slave_waitrequest;
  wire             jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa;
  wire             jtag_uart_1_avalon_jtag_slave_write_n;
  wire    [ 31: 0] jtag_uart_1_avalon_jtag_slave_writedata;
  wire    [  8: 0] onchip_memory_1_s1_address;
  wire    [  3: 0] onchip_memory_1_s1_byteenable;
  wire             onchip_memory_1_s1_chipselect;
  wire             onchip_memory_1_s1_clken;
  wire    [ 31: 0] onchip_memory_1_s1_readdata;
  wire    [ 31: 0] onchip_memory_1_s1_readdata_from_sa;
  wire             onchip_memory_1_s1_reset;
  wire             onchip_memory_1_s1_write;
  wire    [ 31: 0] onchip_memory_1_s1_writedata;
  wire    [  8: 0] onchip_memory_1_s2_address;
  wire    [  3: 0] onchip_memory_1_s2_byteenable;
  wire             onchip_memory_1_s2_chipselect;
  wire             onchip_memory_1_s2_clken;
  wire    [ 31: 0] onchip_memory_1_s2_readdata;
  wire    [ 31: 0] onchip_memory_1_s2_readdata_from_sa;
  wire             onchip_memory_1_s2_reset;
  wire             onchip_memory_1_s2_write;
  wire    [ 31: 0] onchip_memory_1_s2_writedata;
  wire             reset_n_sources;
  wire    [ 21: 0] sdram_1_s1_address;
  wire    [  1: 0] sdram_1_s1_byteenable_n;
  wire             sdram_1_s1_chipselect;
  wire             sdram_1_s1_read_n;
  wire    [ 15: 0] sdram_1_s1_readdata;
  wire    [ 15: 0] sdram_1_s1_readdata_from_sa;
  wire             sdram_1_s1_readdatavalid;
  wire             sdram_1_s1_reset_n;
  wire             sdram_1_s1_waitrequest;
  wire             sdram_1_s1_waitrequest_from_sa;
  wire             sdram_1_s1_write_n;
  wire    [ 15: 0] sdram_1_s1_writedata;
  wire    [  2: 0] timer_1_s1_address;
  wire             timer_1_s1_chipselect;
  wire             timer_1_s1_irq;
  wire             timer_1_s1_irq_from_sa;
  wire    [ 15: 0] timer_1_s1_readdata;
  wire    [ 15: 0] timer_1_s1_readdata_from_sa;
  wire             timer_1_s1_reset_n;
  wire             timer_1_s1_write_n;
  wire    [ 15: 0] timer_1_s1_writedata;
  wire    [ 11: 0] zs_addr_from_the_sdram_1;
  wire    [  1: 0] zs_ba_from_the_sdram_1;
  wire             zs_cas_n_from_the_sdram_1;
  wire             zs_cke_from_the_sdram_1;
  wire             zs_cs_n_from_the_sdram_1;
  wire    [ 15: 0] zs_dq_to_and_from_the_sdram_1;
  wire    [  1: 0] zs_dqm_from_the_sdram_1;
  wire             zs_ras_n_from_the_sdram_1;
  wire             zs_we_n_from_the_sdram_1;
  cpu_1_jtag_debug_module_arbitrator the_cpu_1_jtag_debug_module
    (
      .clk                                                                (clk_0),
      .cpu_1_data_master_address_to_slave                                 (cpu_1_data_master_address_to_slave),
      .cpu_1_data_master_byteenable                                       (cpu_1_data_master_byteenable),
      .cpu_1_data_master_debugaccess                                      (cpu_1_data_master_debugaccess),
      .cpu_1_data_master_granted_cpu_1_jtag_debug_module                  (cpu_1_data_master_granted_cpu_1_jtag_debug_module),
      .cpu_1_data_master_latency_counter                                  (cpu_1_data_master_latency_counter),
      .cpu_1_data_master_qualified_request_cpu_1_jtag_debug_module        (cpu_1_data_master_qualified_request_cpu_1_jtag_debug_module),
      .cpu_1_data_master_read                                             (cpu_1_data_master_read),
      .cpu_1_data_master_read_data_valid_cpu_1_jtag_debug_module          (cpu_1_data_master_read_data_valid_cpu_1_jtag_debug_module),
      .cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register        (cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register),
      .cpu_1_data_master_requests_cpu_1_jtag_debug_module                 (cpu_1_data_master_requests_cpu_1_jtag_debug_module),
      .cpu_1_data_master_write                                            (cpu_1_data_master_write),
      .cpu_1_data_master_writedata                                        (cpu_1_data_master_writedata),
      .cpu_1_instruction_master_address_to_slave                          (cpu_1_instruction_master_address_to_slave),
      .cpu_1_instruction_master_granted_cpu_1_jtag_debug_module           (cpu_1_instruction_master_granted_cpu_1_jtag_debug_module),
      .cpu_1_instruction_master_latency_counter                           (cpu_1_instruction_master_latency_counter),
      .cpu_1_instruction_master_qualified_request_cpu_1_jtag_debug_module (cpu_1_instruction_master_qualified_request_cpu_1_jtag_debug_module),
      .cpu_1_instruction_master_read                                      (cpu_1_instruction_master_read),
      .cpu_1_instruction_master_read_data_valid_cpu_1_jtag_debug_module   (cpu_1_instruction_master_read_data_valid_cpu_1_jtag_debug_module),
      .cpu_1_instruction_master_read_data_valid_sdram_1_s1_shift_register (cpu_1_instruction_master_read_data_valid_sdram_1_s1_shift_register),
      .cpu_1_instruction_master_requests_cpu_1_jtag_debug_module          (cpu_1_instruction_master_requests_cpu_1_jtag_debug_module),
      .cpu_1_jtag_debug_module_address                                    (cpu_1_jtag_debug_module_address),
      .cpu_1_jtag_debug_module_begintransfer                              (cpu_1_jtag_debug_module_begintransfer),
      .cpu_1_jtag_debug_module_byteenable                                 (cpu_1_jtag_debug_module_byteenable),
      .cpu_1_jtag_debug_module_chipselect                                 (cpu_1_jtag_debug_module_chipselect),
      .cpu_1_jtag_debug_module_debugaccess                                (cpu_1_jtag_debug_module_debugaccess),
      .cpu_1_jtag_debug_module_readdata                                   (cpu_1_jtag_debug_module_readdata),
      .cpu_1_jtag_debug_module_readdata_from_sa                           (cpu_1_jtag_debug_module_readdata_from_sa),
      .cpu_1_jtag_debug_module_reset_n                                    (cpu_1_jtag_debug_module_reset_n),
      .cpu_1_jtag_debug_module_resetrequest                               (cpu_1_jtag_debug_module_resetrequest),
      .cpu_1_jtag_debug_module_resetrequest_from_sa                       (cpu_1_jtag_debug_module_resetrequest_from_sa),
      .cpu_1_jtag_debug_module_write                                      (cpu_1_jtag_debug_module_write),
      .cpu_1_jtag_debug_module_writedata                                  (cpu_1_jtag_debug_module_writedata),
      .d1_cpu_1_jtag_debug_module_end_xfer                                (d1_cpu_1_jtag_debug_module_end_xfer),
      .reset_n                                                            (clk_0_reset_n)
    );

  cpu_1_data_master_arbitrator the_cpu_1_data_master
    (
      .clk                                                               (clk_0),
      .cpu_1_data_master_address                                         (cpu_1_data_master_address),
      .cpu_1_data_master_address_to_slave                                (cpu_1_data_master_address_to_slave),
      .cpu_1_data_master_byteenable                                      (cpu_1_data_master_byteenable),
      .cpu_1_data_master_byteenable_sdram_1_s1                           (cpu_1_data_master_byteenable_sdram_1_s1),
      .cpu_1_data_master_dbs_address                                     (cpu_1_data_master_dbs_address),
      .cpu_1_data_master_dbs_write_16                                    (cpu_1_data_master_dbs_write_16),
      .cpu_1_data_master_granted_cpu_1_jtag_debug_module                 (cpu_1_data_master_granted_cpu_1_jtag_debug_module),
      .cpu_1_data_master_granted_hibi_pe_dma_1_avalon_slave_0            (cpu_1_data_master_granted_hibi_pe_dma_1_avalon_slave_0),
      .cpu_1_data_master_granted_jtag_uart_1_avalon_jtag_slave           (cpu_1_data_master_granted_jtag_uart_1_avalon_jtag_slave),
      .cpu_1_data_master_granted_onchip_memory_1_s2                      (cpu_1_data_master_granted_onchip_memory_1_s2),
      .cpu_1_data_master_granted_sdram_1_s1                              (cpu_1_data_master_granted_sdram_1_s1),
      .cpu_1_data_master_granted_timer_1_s1                              (cpu_1_data_master_granted_timer_1_s1),
      .cpu_1_data_master_irq                                             (cpu_1_data_master_irq),
      .cpu_1_data_master_latency_counter                                 (cpu_1_data_master_latency_counter),
      .cpu_1_data_master_qualified_request_cpu_1_jtag_debug_module       (cpu_1_data_master_qualified_request_cpu_1_jtag_debug_module),
      .cpu_1_data_master_qualified_request_hibi_pe_dma_1_avalon_slave_0  (cpu_1_data_master_qualified_request_hibi_pe_dma_1_avalon_slave_0),
      .cpu_1_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave (cpu_1_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave),
      .cpu_1_data_master_qualified_request_onchip_memory_1_s2            (cpu_1_data_master_qualified_request_onchip_memory_1_s2),
      .cpu_1_data_master_qualified_request_sdram_1_s1                    (cpu_1_data_master_qualified_request_sdram_1_s1),
      .cpu_1_data_master_qualified_request_timer_1_s1                    (cpu_1_data_master_qualified_request_timer_1_s1),
      .cpu_1_data_master_read                                            (cpu_1_data_master_read),
      .cpu_1_data_master_read_data_valid_cpu_1_jtag_debug_module         (cpu_1_data_master_read_data_valid_cpu_1_jtag_debug_module),
      .cpu_1_data_master_read_data_valid_hibi_pe_dma_1_avalon_slave_0    (cpu_1_data_master_read_data_valid_hibi_pe_dma_1_avalon_slave_0),
      .cpu_1_data_master_read_data_valid_jtag_uart_1_avalon_jtag_slave   (cpu_1_data_master_read_data_valid_jtag_uart_1_avalon_jtag_slave),
      .cpu_1_data_master_read_data_valid_onchip_memory_1_s2              (cpu_1_data_master_read_data_valid_onchip_memory_1_s2),
      .cpu_1_data_master_read_data_valid_sdram_1_s1                      (cpu_1_data_master_read_data_valid_sdram_1_s1),
      .cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register       (cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register),
      .cpu_1_data_master_read_data_valid_timer_1_s1                      (cpu_1_data_master_read_data_valid_timer_1_s1),
      .cpu_1_data_master_readdata                                        (cpu_1_data_master_readdata),
      .cpu_1_data_master_readdatavalid                                   (cpu_1_data_master_readdatavalid),
      .cpu_1_data_master_requests_cpu_1_jtag_debug_module                (cpu_1_data_master_requests_cpu_1_jtag_debug_module),
      .cpu_1_data_master_requests_hibi_pe_dma_1_avalon_slave_0           (cpu_1_data_master_requests_hibi_pe_dma_1_avalon_slave_0),
      .cpu_1_data_master_requests_jtag_uart_1_avalon_jtag_slave          (cpu_1_data_master_requests_jtag_uart_1_avalon_jtag_slave),
      .cpu_1_data_master_requests_onchip_memory_1_s2                     (cpu_1_data_master_requests_onchip_memory_1_s2),
      .cpu_1_data_master_requests_sdram_1_s1                             (cpu_1_data_master_requests_sdram_1_s1),
      .cpu_1_data_master_requests_timer_1_s1                             (cpu_1_data_master_requests_timer_1_s1),
      .cpu_1_data_master_waitrequest                                     (cpu_1_data_master_waitrequest),
      .cpu_1_data_master_write                                           (cpu_1_data_master_write),
      .cpu_1_data_master_writedata                                       (cpu_1_data_master_writedata),
      .cpu_1_jtag_debug_module_readdata_from_sa                          (cpu_1_jtag_debug_module_readdata_from_sa),
      .d1_cpu_1_jtag_debug_module_end_xfer                               (d1_cpu_1_jtag_debug_module_end_xfer),
      .d1_hibi_pe_dma_1_avalon_slave_0_end_xfer                          (d1_hibi_pe_dma_1_avalon_slave_0_end_xfer),
      .d1_jtag_uart_1_avalon_jtag_slave_end_xfer                         (d1_jtag_uart_1_avalon_jtag_slave_end_xfer),
      .d1_onchip_memory_1_s2_end_xfer                                    (d1_onchip_memory_1_s2_end_xfer),
      .d1_sdram_1_s1_end_xfer                                            (d1_sdram_1_s1_end_xfer),
      .d1_timer_1_s1_end_xfer                                            (d1_timer_1_s1_end_xfer),
      .hibi_pe_dma_1_avalon_slave_0_irq_from_sa                          (hibi_pe_dma_1_avalon_slave_0_irq_from_sa),
      .hibi_pe_dma_1_avalon_slave_0_readdata_from_sa                     (hibi_pe_dma_1_avalon_slave_0_readdata_from_sa),
      .hibi_pe_dma_1_avalon_slave_0_waitrequest_from_sa                  (hibi_pe_dma_1_avalon_slave_0_waitrequest_from_sa),
      .jtag_uart_1_avalon_jtag_slave_irq_from_sa                         (jtag_uart_1_avalon_jtag_slave_irq_from_sa),
      .jtag_uart_1_avalon_jtag_slave_readdata_from_sa                    (jtag_uart_1_avalon_jtag_slave_readdata_from_sa),
      .jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa                 (jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa),
      .onchip_memory_1_s2_readdata_from_sa                               (onchip_memory_1_s2_readdata_from_sa),
      .reset_n                                                           (clk_0_reset_n),
      .sdram_1_s1_readdata_from_sa                                       (sdram_1_s1_readdata_from_sa),
      .sdram_1_s1_waitrequest_from_sa                                    (sdram_1_s1_waitrequest_from_sa),
      .timer_1_s1_irq_from_sa                                            (timer_1_s1_irq_from_sa),
      .timer_1_s1_readdata_from_sa                                       (timer_1_s1_readdata_from_sa)
    );

  cpu_1_instruction_master_arbitrator the_cpu_1_instruction_master
    (
      .clk                                                                (clk_0),
      .cpu_1_instruction_master_address                                   (cpu_1_instruction_master_address),
      .cpu_1_instruction_master_address_to_slave                          (cpu_1_instruction_master_address_to_slave),
      .cpu_1_instruction_master_dbs_address                               (cpu_1_instruction_master_dbs_address),
      .cpu_1_instruction_master_granted_cpu_1_jtag_debug_module           (cpu_1_instruction_master_granted_cpu_1_jtag_debug_module),
      .cpu_1_instruction_master_granted_sdram_1_s1                        (cpu_1_instruction_master_granted_sdram_1_s1),
      .cpu_1_instruction_master_latency_counter                           (cpu_1_instruction_master_latency_counter),
      .cpu_1_instruction_master_qualified_request_cpu_1_jtag_debug_module (cpu_1_instruction_master_qualified_request_cpu_1_jtag_debug_module),
      .cpu_1_instruction_master_qualified_request_sdram_1_s1              (cpu_1_instruction_master_qualified_request_sdram_1_s1),
      .cpu_1_instruction_master_read                                      (cpu_1_instruction_master_read),
      .cpu_1_instruction_master_read_data_valid_cpu_1_jtag_debug_module   (cpu_1_instruction_master_read_data_valid_cpu_1_jtag_debug_module),
      .cpu_1_instruction_master_read_data_valid_sdram_1_s1                (cpu_1_instruction_master_read_data_valid_sdram_1_s1),
      .cpu_1_instruction_master_read_data_valid_sdram_1_s1_shift_register (cpu_1_instruction_master_read_data_valid_sdram_1_s1_shift_register),
      .cpu_1_instruction_master_readdata                                  (cpu_1_instruction_master_readdata),
      .cpu_1_instruction_master_readdatavalid                             (cpu_1_instruction_master_readdatavalid),
      .cpu_1_instruction_master_requests_cpu_1_jtag_debug_module          (cpu_1_instruction_master_requests_cpu_1_jtag_debug_module),
      .cpu_1_instruction_master_requests_sdram_1_s1                       (cpu_1_instruction_master_requests_sdram_1_s1),
      .cpu_1_instruction_master_waitrequest                               (cpu_1_instruction_master_waitrequest),
      .cpu_1_jtag_debug_module_readdata_from_sa                           (cpu_1_jtag_debug_module_readdata_from_sa),
      .d1_cpu_1_jtag_debug_module_end_xfer                                (d1_cpu_1_jtag_debug_module_end_xfer),
      .d1_sdram_1_s1_end_xfer                                             (d1_sdram_1_s1_end_xfer),
      .reset_n                                                            (clk_0_reset_n),
      .sdram_1_s1_readdata_from_sa                                        (sdram_1_s1_readdata_from_sa),
      .sdram_1_s1_waitrequest_from_sa                                     (sdram_1_s1_waitrequest_from_sa)
    );

  cpu_1 the_cpu_1
    (
      .clk                                   (clk_0),
      .d_address                             (cpu_1_data_master_address),
      .d_byteenable                          (cpu_1_data_master_byteenable),
      .d_irq                                 (cpu_1_data_master_irq),
      .d_read                                (cpu_1_data_master_read),
      .d_readdata                            (cpu_1_data_master_readdata),
      .d_readdatavalid                       (cpu_1_data_master_readdatavalid),
      .d_waitrequest                         (cpu_1_data_master_waitrequest),
      .d_write                               (cpu_1_data_master_write),
      .d_writedata                           (cpu_1_data_master_writedata),
      .i_address                             (cpu_1_instruction_master_address),
      .i_read                                (cpu_1_instruction_master_read),
      .i_readdata                            (cpu_1_instruction_master_readdata),
      .i_readdatavalid                       (cpu_1_instruction_master_readdatavalid),
      .i_waitrequest                         (cpu_1_instruction_master_waitrequest),
      .jtag_debug_module_address             (cpu_1_jtag_debug_module_address),
      .jtag_debug_module_begintransfer       (cpu_1_jtag_debug_module_begintransfer),
      .jtag_debug_module_byteenable          (cpu_1_jtag_debug_module_byteenable),
      .jtag_debug_module_debugaccess         (cpu_1_jtag_debug_module_debugaccess),
      .jtag_debug_module_debugaccess_to_roms (cpu_1_data_master_debugaccess),
      .jtag_debug_module_readdata            (cpu_1_jtag_debug_module_readdata),
      .jtag_debug_module_resetrequest        (cpu_1_jtag_debug_module_resetrequest),
      .jtag_debug_module_select              (cpu_1_jtag_debug_module_chipselect),
      .jtag_debug_module_write               (cpu_1_jtag_debug_module_write),
      .jtag_debug_module_writedata           (cpu_1_jtag_debug_module_writedata),
      .reset_n                               (cpu_1_jtag_debug_module_reset_n)
    );

  hibi_pe_dma_1_avalon_slave_0_arbitrator the_hibi_pe_dma_1_avalon_slave_0
    (
      .clk                                                              (clk_0),
      .cpu_1_data_master_address_to_slave                               (cpu_1_data_master_address_to_slave),
      .cpu_1_data_master_granted_hibi_pe_dma_1_avalon_slave_0           (cpu_1_data_master_granted_hibi_pe_dma_1_avalon_slave_0),
      .cpu_1_data_master_latency_counter                                (cpu_1_data_master_latency_counter),
      .cpu_1_data_master_qualified_request_hibi_pe_dma_1_avalon_slave_0 (cpu_1_data_master_qualified_request_hibi_pe_dma_1_avalon_slave_0),
      .cpu_1_data_master_read                                           (cpu_1_data_master_read),
      .cpu_1_data_master_read_data_valid_hibi_pe_dma_1_avalon_slave_0   (cpu_1_data_master_read_data_valid_hibi_pe_dma_1_avalon_slave_0),
      .cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register      (cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register),
      .cpu_1_data_master_requests_hibi_pe_dma_1_avalon_slave_0          (cpu_1_data_master_requests_hibi_pe_dma_1_avalon_slave_0),
      .cpu_1_data_master_write                                          (cpu_1_data_master_write),
      .cpu_1_data_master_writedata                                      (cpu_1_data_master_writedata),
      .d1_hibi_pe_dma_1_avalon_slave_0_end_xfer                         (d1_hibi_pe_dma_1_avalon_slave_0_end_xfer),
      .hibi_pe_dma_1_avalon_slave_0_address                             (hibi_pe_dma_1_avalon_slave_0_address),
      .hibi_pe_dma_1_avalon_slave_0_chipselect                          (hibi_pe_dma_1_avalon_slave_0_chipselect),
      .hibi_pe_dma_1_avalon_slave_0_irq                                 (hibi_pe_dma_1_avalon_slave_0_irq),
      .hibi_pe_dma_1_avalon_slave_0_irq_from_sa                         (hibi_pe_dma_1_avalon_slave_0_irq_from_sa),
      .hibi_pe_dma_1_avalon_slave_0_read                                (hibi_pe_dma_1_avalon_slave_0_read),
      .hibi_pe_dma_1_avalon_slave_0_readdata                            (hibi_pe_dma_1_avalon_slave_0_readdata),
      .hibi_pe_dma_1_avalon_slave_0_readdata_from_sa                    (hibi_pe_dma_1_avalon_slave_0_readdata_from_sa),
      .hibi_pe_dma_1_avalon_slave_0_reset_n                             (hibi_pe_dma_1_avalon_slave_0_reset_n),
      .hibi_pe_dma_1_avalon_slave_0_waitrequest                         (hibi_pe_dma_1_avalon_slave_0_waitrequest),
      .hibi_pe_dma_1_avalon_slave_0_waitrequest_from_sa                 (hibi_pe_dma_1_avalon_slave_0_waitrequest_from_sa),
      .hibi_pe_dma_1_avalon_slave_0_write                               (hibi_pe_dma_1_avalon_slave_0_write),
      .hibi_pe_dma_1_avalon_slave_0_writedata                           (hibi_pe_dma_1_avalon_slave_0_writedata),
      .reset_n                                                          (clk_0_reset_n)
    );

  hibi_pe_dma_1_avalon_master_arbitrator the_hibi_pe_dma_1_avalon_master
    (
      .clk                                                              (clk_0),
      .d1_onchip_memory_1_s1_end_xfer                                   (d1_onchip_memory_1_s1_end_xfer),
      .hibi_pe_dma_1_avalon_master_address                              (hibi_pe_dma_1_avalon_master_address),
      .hibi_pe_dma_1_avalon_master_address_to_slave                     (hibi_pe_dma_1_avalon_master_address_to_slave),
      .hibi_pe_dma_1_avalon_master_byteenable                           (hibi_pe_dma_1_avalon_master_byteenable),
      .hibi_pe_dma_1_avalon_master_granted_onchip_memory_1_s1           (hibi_pe_dma_1_avalon_master_granted_onchip_memory_1_s1),
      .hibi_pe_dma_1_avalon_master_qualified_request_onchip_memory_1_s1 (hibi_pe_dma_1_avalon_master_qualified_request_onchip_memory_1_s1),
      .hibi_pe_dma_1_avalon_master_requests_onchip_memory_1_s1          (hibi_pe_dma_1_avalon_master_requests_onchip_memory_1_s1),
      .hibi_pe_dma_1_avalon_master_waitrequest                          (hibi_pe_dma_1_avalon_master_waitrequest),
      .hibi_pe_dma_1_avalon_master_write                                (hibi_pe_dma_1_avalon_master_write),
      .hibi_pe_dma_1_avalon_master_writedata                            (hibi_pe_dma_1_avalon_master_writedata),
      .reset_n                                                          (clk_0_reset_n)
    );

  hibi_pe_dma_1_avalon_master_1_arbitrator the_hibi_pe_dma_1_avalon_master_1
    (
      .clk                                                                (clk_0),
      .d1_onchip_memory_1_s1_end_xfer                                     (d1_onchip_memory_1_s1_end_xfer),
      .hibi_pe_dma_1_avalon_master_1_address                              (hibi_pe_dma_1_avalon_master_1_address),
      .hibi_pe_dma_1_avalon_master_1_address_to_slave                     (hibi_pe_dma_1_avalon_master_1_address_to_slave),
      .hibi_pe_dma_1_avalon_master_1_granted_onchip_memory_1_s1           (hibi_pe_dma_1_avalon_master_1_granted_onchip_memory_1_s1),
      .hibi_pe_dma_1_avalon_master_1_latency_counter                      (hibi_pe_dma_1_avalon_master_1_latency_counter),
      .hibi_pe_dma_1_avalon_master_1_qualified_request_onchip_memory_1_s1 (hibi_pe_dma_1_avalon_master_1_qualified_request_onchip_memory_1_s1),
      .hibi_pe_dma_1_avalon_master_1_read                                 (hibi_pe_dma_1_avalon_master_1_read),
      .hibi_pe_dma_1_avalon_master_1_read_data_valid_onchip_memory_1_s1   (hibi_pe_dma_1_avalon_master_1_read_data_valid_onchip_memory_1_s1),
      .hibi_pe_dma_1_avalon_master_1_readdata                             (hibi_pe_dma_1_avalon_master_1_readdata),
      .hibi_pe_dma_1_avalon_master_1_readdatavalid                        (hibi_pe_dma_1_avalon_master_1_readdatavalid),
      .hibi_pe_dma_1_avalon_master_1_requests_onchip_memory_1_s1          (hibi_pe_dma_1_avalon_master_1_requests_onchip_memory_1_s1),
      .hibi_pe_dma_1_avalon_master_1_waitrequest                          (hibi_pe_dma_1_avalon_master_1_waitrequest),
      .onchip_memory_1_s1_readdata_from_sa                                (onchip_memory_1_s1_readdata_from_sa),
      .reset_n                                                            (clk_0_reset_n)
    );

  hibi_pe_dma_1 the_hibi_pe_dma_1
    (
      .avalon_addr_out_rx         (hibi_pe_dma_1_avalon_master_address),
      .avalon_addr_out_tx         (hibi_pe_dma_1_avalon_master_1_address),
      .avalon_be_out_rx           (hibi_pe_dma_1_avalon_master_byteenable),
      .avalon_cfg_addr_in         (hibi_pe_dma_1_avalon_slave_0_address),
      .avalon_cfg_cs_in           (hibi_pe_dma_1_avalon_slave_0_chipselect),
      .avalon_cfg_re_in           (hibi_pe_dma_1_avalon_slave_0_read),
      .avalon_cfg_readdata_out    (hibi_pe_dma_1_avalon_slave_0_readdata),
      .avalon_cfg_waitrequest_out (hibi_pe_dma_1_avalon_slave_0_waitrequest),
      .avalon_cfg_we_in           (hibi_pe_dma_1_avalon_slave_0_write),
      .avalon_cfg_writedata_in    (hibi_pe_dma_1_avalon_slave_0_writedata),
      .avalon_re_out_tx           (hibi_pe_dma_1_avalon_master_1_read),
      .avalon_readdata_in_tx      (hibi_pe_dma_1_avalon_master_1_readdata),
      .avalon_readdatavalid_in_tx (hibi_pe_dma_1_avalon_master_1_readdatavalid),
      .avalon_waitrequest_in_rx   (hibi_pe_dma_1_avalon_master_waitrequest),
      .avalon_waitrequest_in_tx   (hibi_pe_dma_1_avalon_master_1_waitrequest),
      .avalon_we_out_rx           (hibi_pe_dma_1_avalon_master_write),
      .avalon_writedata_out_rx    (hibi_pe_dma_1_avalon_master_writedata),
      .clk                        (clk_0),
      .hibi_av_in                 (hibi_av_in_to_the_hibi_pe_dma_1),
      .hibi_av_out                (hibi_av_out_from_the_hibi_pe_dma_1),
      .hibi_comm_in               (hibi_comm_in_to_the_hibi_pe_dma_1),
      .hibi_comm_out              (hibi_comm_out_from_the_hibi_pe_dma_1),
      .hibi_data_in               (hibi_data_in_to_the_hibi_pe_dma_1),
      .hibi_data_out              (hibi_data_out_from_the_hibi_pe_dma_1),
      .hibi_empty_in              (hibi_empty_in_to_the_hibi_pe_dma_1),
      .hibi_full_in               (hibi_full_in_to_the_hibi_pe_dma_1),
      .hibi_re_out                (hibi_re_out_from_the_hibi_pe_dma_1),
      .hibi_we_out                (hibi_we_out_from_the_hibi_pe_dma_1),
      .rst_n                      (hibi_pe_dma_1_avalon_slave_0_reset_n),
      .rx_irq_out                 (hibi_pe_dma_1_avalon_slave_0_irq)
    );

  jtag_uart_1_avalon_jtag_slave_arbitrator the_jtag_uart_1_avalon_jtag_slave
    (
      .clk                                                               (clk_0),
      .cpu_1_data_master_address_to_slave                                (cpu_1_data_master_address_to_slave),
      .cpu_1_data_master_granted_jtag_uart_1_avalon_jtag_slave           (cpu_1_data_master_granted_jtag_uart_1_avalon_jtag_slave),
      .cpu_1_data_master_latency_counter                                 (cpu_1_data_master_latency_counter),
      .cpu_1_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave (cpu_1_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave),
      .cpu_1_data_master_read                                            (cpu_1_data_master_read),
      .cpu_1_data_master_read_data_valid_jtag_uart_1_avalon_jtag_slave   (cpu_1_data_master_read_data_valid_jtag_uart_1_avalon_jtag_slave),
      .cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register       (cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register),
      .cpu_1_data_master_requests_jtag_uart_1_avalon_jtag_slave          (cpu_1_data_master_requests_jtag_uart_1_avalon_jtag_slave),
      .cpu_1_data_master_write                                           (cpu_1_data_master_write),
      .cpu_1_data_master_writedata                                       (cpu_1_data_master_writedata),
      .d1_jtag_uart_1_avalon_jtag_slave_end_xfer                         (d1_jtag_uart_1_avalon_jtag_slave_end_xfer),
      .jtag_uart_1_avalon_jtag_slave_address                             (jtag_uart_1_avalon_jtag_slave_address),
      .jtag_uart_1_avalon_jtag_slave_chipselect                          (jtag_uart_1_avalon_jtag_slave_chipselect),
      .jtag_uart_1_avalon_jtag_slave_dataavailable                       (jtag_uart_1_avalon_jtag_slave_dataavailable),
      .jtag_uart_1_avalon_jtag_slave_dataavailable_from_sa               (jtag_uart_1_avalon_jtag_slave_dataavailable_from_sa),
      .jtag_uart_1_avalon_jtag_slave_irq                                 (jtag_uart_1_avalon_jtag_slave_irq),
      .jtag_uart_1_avalon_jtag_slave_irq_from_sa                         (jtag_uart_1_avalon_jtag_slave_irq_from_sa),
      .jtag_uart_1_avalon_jtag_slave_read_n                              (jtag_uart_1_avalon_jtag_slave_read_n),
      .jtag_uart_1_avalon_jtag_slave_readdata                            (jtag_uart_1_avalon_jtag_slave_readdata),
      .jtag_uart_1_avalon_jtag_slave_readdata_from_sa                    (jtag_uart_1_avalon_jtag_slave_readdata_from_sa),
      .jtag_uart_1_avalon_jtag_slave_readyfordata                        (jtag_uart_1_avalon_jtag_slave_readyfordata),
      .jtag_uart_1_avalon_jtag_slave_readyfordata_from_sa                (jtag_uart_1_avalon_jtag_slave_readyfordata_from_sa),
      .jtag_uart_1_avalon_jtag_slave_reset_n                             (jtag_uart_1_avalon_jtag_slave_reset_n),
      .jtag_uart_1_avalon_jtag_slave_waitrequest                         (jtag_uart_1_avalon_jtag_slave_waitrequest),
      .jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa                 (jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa),
      .jtag_uart_1_avalon_jtag_slave_write_n                             (jtag_uart_1_avalon_jtag_slave_write_n),
      .jtag_uart_1_avalon_jtag_slave_writedata                           (jtag_uart_1_avalon_jtag_slave_writedata),
      .reset_n                                                           (clk_0_reset_n)
    );

  jtag_uart_1 the_jtag_uart_1
    (
      .av_address     (jtag_uart_1_avalon_jtag_slave_address),
      .av_chipselect  (jtag_uart_1_avalon_jtag_slave_chipselect),
      .av_irq         (jtag_uart_1_avalon_jtag_slave_irq),
      .av_read_n      (jtag_uart_1_avalon_jtag_slave_read_n),
      .av_readdata    (jtag_uart_1_avalon_jtag_slave_readdata),
      .av_waitrequest (jtag_uart_1_avalon_jtag_slave_waitrequest),
      .av_write_n     (jtag_uart_1_avalon_jtag_slave_write_n),
      .av_writedata   (jtag_uart_1_avalon_jtag_slave_writedata),
      .clk            (clk_0),
      .dataavailable  (jtag_uart_1_avalon_jtag_slave_dataavailable),
      .readyfordata   (jtag_uart_1_avalon_jtag_slave_readyfordata),
      .rst_n          (jtag_uart_1_avalon_jtag_slave_reset_n)
    );

  onchip_memory_1_s1_arbitrator the_onchip_memory_1_s1
    (
      .clk                                                                (clk_0),
      .d1_onchip_memory_1_s1_end_xfer                                     (d1_onchip_memory_1_s1_end_xfer),
      .hibi_pe_dma_1_avalon_master_1_address_to_slave                     (hibi_pe_dma_1_avalon_master_1_address_to_slave),
      .hibi_pe_dma_1_avalon_master_1_granted_onchip_memory_1_s1           (hibi_pe_dma_1_avalon_master_1_granted_onchip_memory_1_s1),
      .hibi_pe_dma_1_avalon_master_1_latency_counter                      (hibi_pe_dma_1_avalon_master_1_latency_counter),
      .hibi_pe_dma_1_avalon_master_1_qualified_request_onchip_memory_1_s1 (hibi_pe_dma_1_avalon_master_1_qualified_request_onchip_memory_1_s1),
      .hibi_pe_dma_1_avalon_master_1_read                                 (hibi_pe_dma_1_avalon_master_1_read),
      .hibi_pe_dma_1_avalon_master_1_read_data_valid_onchip_memory_1_s1   (hibi_pe_dma_1_avalon_master_1_read_data_valid_onchip_memory_1_s1),
      .hibi_pe_dma_1_avalon_master_1_requests_onchip_memory_1_s1          (hibi_pe_dma_1_avalon_master_1_requests_onchip_memory_1_s1),
      .hibi_pe_dma_1_avalon_master_address_to_slave                       (hibi_pe_dma_1_avalon_master_address_to_slave),
      .hibi_pe_dma_1_avalon_master_byteenable                             (hibi_pe_dma_1_avalon_master_byteenable),
      .hibi_pe_dma_1_avalon_master_granted_onchip_memory_1_s1             (hibi_pe_dma_1_avalon_master_granted_onchip_memory_1_s1),
      .hibi_pe_dma_1_avalon_master_qualified_request_onchip_memory_1_s1   (hibi_pe_dma_1_avalon_master_qualified_request_onchip_memory_1_s1),
      .hibi_pe_dma_1_avalon_master_requests_onchip_memory_1_s1            (hibi_pe_dma_1_avalon_master_requests_onchip_memory_1_s1),
      .hibi_pe_dma_1_avalon_master_write                                  (hibi_pe_dma_1_avalon_master_write),
      .hibi_pe_dma_1_avalon_master_writedata                              (hibi_pe_dma_1_avalon_master_writedata),
      .onchip_memory_1_s1_address                                         (onchip_memory_1_s1_address),
      .onchip_memory_1_s1_byteenable                                      (onchip_memory_1_s1_byteenable),
      .onchip_memory_1_s1_chipselect                                      (onchip_memory_1_s1_chipselect),
      .onchip_memory_1_s1_clken                                           (onchip_memory_1_s1_clken),
      .onchip_memory_1_s1_readdata                                        (onchip_memory_1_s1_readdata),
      .onchip_memory_1_s1_readdata_from_sa                                (onchip_memory_1_s1_readdata_from_sa),
      .onchip_memory_1_s1_reset                                           (onchip_memory_1_s1_reset),
      .onchip_memory_1_s1_write                                           (onchip_memory_1_s1_write),
      .onchip_memory_1_s1_writedata                                       (onchip_memory_1_s1_writedata),
      .reset_n                                                            (clk_0_reset_n)
    );

  onchip_memory_1_s2_arbitrator the_onchip_memory_1_s2
    (
      .clk                                                         (clk_0),
      .cpu_1_data_master_address_to_slave                          (cpu_1_data_master_address_to_slave),
      .cpu_1_data_master_byteenable                                (cpu_1_data_master_byteenable),
      .cpu_1_data_master_granted_onchip_memory_1_s2                (cpu_1_data_master_granted_onchip_memory_1_s2),
      .cpu_1_data_master_latency_counter                           (cpu_1_data_master_latency_counter),
      .cpu_1_data_master_qualified_request_onchip_memory_1_s2      (cpu_1_data_master_qualified_request_onchip_memory_1_s2),
      .cpu_1_data_master_read                                      (cpu_1_data_master_read),
      .cpu_1_data_master_read_data_valid_onchip_memory_1_s2        (cpu_1_data_master_read_data_valid_onchip_memory_1_s2),
      .cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register (cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register),
      .cpu_1_data_master_requests_onchip_memory_1_s2               (cpu_1_data_master_requests_onchip_memory_1_s2),
      .cpu_1_data_master_write                                     (cpu_1_data_master_write),
      .cpu_1_data_master_writedata                                 (cpu_1_data_master_writedata),
      .d1_onchip_memory_1_s2_end_xfer                              (d1_onchip_memory_1_s2_end_xfer),
      .onchip_memory_1_s2_address                                  (onchip_memory_1_s2_address),
      .onchip_memory_1_s2_byteenable                               (onchip_memory_1_s2_byteenable),
      .onchip_memory_1_s2_chipselect                               (onchip_memory_1_s2_chipselect),
      .onchip_memory_1_s2_clken                                    (onchip_memory_1_s2_clken),
      .onchip_memory_1_s2_readdata                                 (onchip_memory_1_s2_readdata),
      .onchip_memory_1_s2_readdata_from_sa                         (onchip_memory_1_s2_readdata_from_sa),
      .onchip_memory_1_s2_reset                                    (onchip_memory_1_s2_reset),
      .onchip_memory_1_s2_write                                    (onchip_memory_1_s2_write),
      .onchip_memory_1_s2_writedata                                (onchip_memory_1_s2_writedata),
      .reset_n                                                     (clk_0_reset_n)
    );

  onchip_memory_1 the_onchip_memory_1
    (
      .address     (onchip_memory_1_s1_address),
      .address2    (onchip_memory_1_s2_address),
      .byteenable  (onchip_memory_1_s1_byteenable),
      .byteenable2 (onchip_memory_1_s2_byteenable),
      .chipselect  (onchip_memory_1_s1_chipselect),
      .chipselect2 (onchip_memory_1_s2_chipselect),
      .clk         (clk_0),
      .clk2        (clk_0),
      .clken       (onchip_memory_1_s1_clken),
      .clken2      (onchip_memory_1_s2_clken),
      .readdata    (onchip_memory_1_s1_readdata),
      .readdata2   (onchip_memory_1_s2_readdata),
      .reset       (onchip_memory_1_s1_reset),
      .reset2      (onchip_memory_1_s2_reset),
      .write       (onchip_memory_1_s1_write),
      .write2      (onchip_memory_1_s2_write),
      .writedata   (onchip_memory_1_s1_writedata),
      .writedata2  (onchip_memory_1_s2_writedata)
    );

  sdram_1_s1_arbitrator the_sdram_1_s1
    (
      .clk                                                                (clk_0),
      .cpu_1_data_master_address_to_slave                                 (cpu_1_data_master_address_to_slave),
      .cpu_1_data_master_byteenable                                       (cpu_1_data_master_byteenable),
      .cpu_1_data_master_byteenable_sdram_1_s1                            (cpu_1_data_master_byteenable_sdram_1_s1),
      .cpu_1_data_master_dbs_address                                      (cpu_1_data_master_dbs_address),
      .cpu_1_data_master_dbs_write_16                                     (cpu_1_data_master_dbs_write_16),
      .cpu_1_data_master_granted_sdram_1_s1                               (cpu_1_data_master_granted_sdram_1_s1),
      .cpu_1_data_master_latency_counter                                  (cpu_1_data_master_latency_counter),
      .cpu_1_data_master_qualified_request_sdram_1_s1                     (cpu_1_data_master_qualified_request_sdram_1_s1),
      .cpu_1_data_master_read                                             (cpu_1_data_master_read),
      .cpu_1_data_master_read_data_valid_sdram_1_s1                       (cpu_1_data_master_read_data_valid_sdram_1_s1),
      .cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register        (cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register),
      .cpu_1_data_master_requests_sdram_1_s1                              (cpu_1_data_master_requests_sdram_1_s1),
      .cpu_1_data_master_write                                            (cpu_1_data_master_write),
      .cpu_1_instruction_master_address_to_slave                          (cpu_1_instruction_master_address_to_slave),
      .cpu_1_instruction_master_dbs_address                               (cpu_1_instruction_master_dbs_address),
      .cpu_1_instruction_master_granted_sdram_1_s1                        (cpu_1_instruction_master_granted_sdram_1_s1),
      .cpu_1_instruction_master_latency_counter                           (cpu_1_instruction_master_latency_counter),
      .cpu_1_instruction_master_qualified_request_sdram_1_s1              (cpu_1_instruction_master_qualified_request_sdram_1_s1),
      .cpu_1_instruction_master_read                                      (cpu_1_instruction_master_read),
      .cpu_1_instruction_master_read_data_valid_sdram_1_s1                (cpu_1_instruction_master_read_data_valid_sdram_1_s1),
      .cpu_1_instruction_master_read_data_valid_sdram_1_s1_shift_register (cpu_1_instruction_master_read_data_valid_sdram_1_s1_shift_register),
      .cpu_1_instruction_master_requests_sdram_1_s1                       (cpu_1_instruction_master_requests_sdram_1_s1),
      .d1_sdram_1_s1_end_xfer                                             (d1_sdram_1_s1_end_xfer),
      .reset_n                                                            (clk_0_reset_n),
      .sdram_1_s1_address                                                 (sdram_1_s1_address),
      .sdram_1_s1_byteenable_n                                            (sdram_1_s1_byteenable_n),
      .sdram_1_s1_chipselect                                              (sdram_1_s1_chipselect),
      .sdram_1_s1_read_n                                                  (sdram_1_s1_read_n),
      .sdram_1_s1_readdata                                                (sdram_1_s1_readdata),
      .sdram_1_s1_readdata_from_sa                                        (sdram_1_s1_readdata_from_sa),
      .sdram_1_s1_readdatavalid                                           (sdram_1_s1_readdatavalid),
      .sdram_1_s1_reset_n                                                 (sdram_1_s1_reset_n),
      .sdram_1_s1_waitrequest                                             (sdram_1_s1_waitrequest),
      .sdram_1_s1_waitrequest_from_sa                                     (sdram_1_s1_waitrequest_from_sa),
      .sdram_1_s1_write_n                                                 (sdram_1_s1_write_n),
      .sdram_1_s1_writedata                                               (sdram_1_s1_writedata)
    );

  sdram_1 the_sdram_1
    (
      .az_addr        (sdram_1_s1_address),
      .az_be_n        (sdram_1_s1_byteenable_n),
      .az_cs          (sdram_1_s1_chipselect),
      .az_data        (sdram_1_s1_writedata),
      .az_rd_n        (sdram_1_s1_read_n),
      .az_wr_n        (sdram_1_s1_write_n),
      .clk            (clk_0),
      .reset_n        (sdram_1_s1_reset_n),
      .za_data        (sdram_1_s1_readdata),
      .za_valid       (sdram_1_s1_readdatavalid),
      .za_waitrequest (sdram_1_s1_waitrequest),
      .zs_addr        (zs_addr_from_the_sdram_1),
      .zs_ba          (zs_ba_from_the_sdram_1),
      .zs_cas_n       (zs_cas_n_from_the_sdram_1),
      .zs_cke         (zs_cke_from_the_sdram_1),
      .zs_cs_n        (zs_cs_n_from_the_sdram_1),
      .zs_dq          (zs_dq_to_and_from_the_sdram_1),
      .zs_dqm         (zs_dqm_from_the_sdram_1),
      .zs_ras_n       (zs_ras_n_from_the_sdram_1),
      .zs_we_n        (zs_we_n_from_the_sdram_1)
    );

  timer_1_s1_arbitrator the_timer_1_s1
    (
      .clk                                                         (clk_0),
      .cpu_1_data_master_address_to_slave                          (cpu_1_data_master_address_to_slave),
      .cpu_1_data_master_granted_timer_1_s1                        (cpu_1_data_master_granted_timer_1_s1),
      .cpu_1_data_master_latency_counter                           (cpu_1_data_master_latency_counter),
      .cpu_1_data_master_qualified_request_timer_1_s1              (cpu_1_data_master_qualified_request_timer_1_s1),
      .cpu_1_data_master_read                                      (cpu_1_data_master_read),
      .cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register (cpu_1_data_master_read_data_valid_sdram_1_s1_shift_register),
      .cpu_1_data_master_read_data_valid_timer_1_s1                (cpu_1_data_master_read_data_valid_timer_1_s1),
      .cpu_1_data_master_requests_timer_1_s1                       (cpu_1_data_master_requests_timer_1_s1),
      .cpu_1_data_master_write                                     (cpu_1_data_master_write),
      .cpu_1_data_master_writedata                                 (cpu_1_data_master_writedata),
      .d1_timer_1_s1_end_xfer                                      (d1_timer_1_s1_end_xfer),
      .reset_n                                                     (clk_0_reset_n),
      .timer_1_s1_address                                          (timer_1_s1_address),
      .timer_1_s1_chipselect                                       (timer_1_s1_chipselect),
      .timer_1_s1_irq                                              (timer_1_s1_irq),
      .timer_1_s1_irq_from_sa                                      (timer_1_s1_irq_from_sa),
      .timer_1_s1_readdata                                         (timer_1_s1_readdata),
      .timer_1_s1_readdata_from_sa                                 (timer_1_s1_readdata_from_sa),
      .timer_1_s1_reset_n                                          (timer_1_s1_reset_n),
      .timer_1_s1_write_n                                          (timer_1_s1_write_n),
      .timer_1_s1_writedata                                        (timer_1_s1_writedata)
    );

  timer_1 the_timer_1
    (
      .address    (timer_1_s1_address),
      .chipselect (timer_1_s1_chipselect),
      .clk        (clk_0),
      .irq        (timer_1_s1_irq),
      .readdata   (timer_1_s1_readdata),
      .reset_n    (timer_1_s1_reset_n),
      .write_n    (timer_1_s1_write_n),
      .writedata  (timer_1_s1_writedata)
    );

  //reset is asserted asynchronously and deasserted synchronously
  nios_ii_sdram_reset_clk_0_domain_synch_module nios_ii_sdram_reset_clk_0_domain_synch
    (
      .clk      (clk_0),
      .data_in  (1'b1),
      .data_out (clk_0_reset_n),
      .reset_n  (reset_n_sources)
    );

  //reset sources mux, which is an e_mux
  assign reset_n_sources = ~(~reset_n |
    0 |
    cpu_1_jtag_debug_module_resetrequest_from_sa |
    cpu_1_jtag_debug_module_resetrequest_from_sa);


endmodule


//synthesis translate_off



// <ALTERA_NOTE> CODE INSERTED BETWEEN HERE

// AND HERE WILL BE PRESERVED </ALTERA_NOTE>


// If user logic components use Altsync_Ram with convert_hex2ver.dll,
// set USE_convert_hex2ver in the user comments section above

// `ifdef USE_convert_hex2ver
// `else
// `define NO_PLI 1
// `endif

`include "c:/altera/11.0/quartus/eda/sim_lib/altera_mf.v"
`include "c:/altera/11.0/quartus/eda/sim_lib/220model.v"
`include "c:/altera/11.0/quartus/eda/sim_lib/sgate.v"
// C:/Users/lauri/ncit_summer_school/repos/daci_ip/trunk/ip.hwp.communication/hibi_pe_dma/1.0/vhd/hpd_tx_control.vhd
// C:/Users/lauri/ncit_summer_school/repos/daci_ip/trunk/ip.hwp.communication/hibi_pe_dma/1.0/vhd/hpd_rx_packet.vhd
// C:/Users/lauri/ncit_summer_school/repos/daci_ip/trunk/ip.hwp.communication/hibi_pe_dma/1.0/vhd/hpd_rx_stream.vhd
// C:/Users/lauri/ncit_summer_school/repos/daci_ip/trunk/ip.hwp.communication/hibi_pe_dma/1.0/vhd/hpd_rx_and_conf.vhd
// C:/Users/lauri/ncit_summer_school/repos/daci_ip/trunk/ip.hwp.communication/hibi_pe_dma/1.0/vhd/hibi_pe_dma.vhd
// hibi_pe_dma_1.vhd
`include "jtag_uart_1.v"
`include "onchip_memory_1.v"
`include "sdram_1.v"
`include "timer_1.v"
`include "cpu_1_test_bench.v"
`include "cpu_1_mult_cell.v"
`include "cpu_1_oci_test_bench.v"
`include "cpu_1_jtag_debug_module_tck.v"
`include "cpu_1_jtag_debug_module_sysclk.v"
`include "cpu_1_jtag_debug_module_wrapper.v"
`include "cpu_1.v"

`timescale 1ns / 1ps

module test_bench 
;


  wire             clk;
  reg              clk_0;
  wire             hibi_av_in_to_the_hibi_pe_dma_1;
  wire             hibi_av_out_from_the_hibi_pe_dma_1;
  wire    [  4: 0] hibi_comm_in_to_the_hibi_pe_dma_1;
  wire    [  4: 0] hibi_comm_out_from_the_hibi_pe_dma_1;
  wire    [ 31: 0] hibi_data_in_to_the_hibi_pe_dma_1;
  wire    [ 31: 0] hibi_data_out_from_the_hibi_pe_dma_1;
  wire             hibi_empty_in_to_the_hibi_pe_dma_1;
  wire             hibi_full_in_to_the_hibi_pe_dma_1;
  wire             hibi_re_out_from_the_hibi_pe_dma_1;
  wire             hibi_we_out_from_the_hibi_pe_dma_1;
  wire             jtag_uart_1_avalon_jtag_slave_dataavailable_from_sa;
  wire             jtag_uart_1_avalon_jtag_slave_readyfordata_from_sa;
  reg              reset_n;
  wire    [ 11: 0] zs_addr_from_the_sdram_1;
  wire    [  1: 0] zs_ba_from_the_sdram_1;
  wire             zs_cas_n_from_the_sdram_1;
  wire             zs_cke_from_the_sdram_1;
  wire             zs_cs_n_from_the_sdram_1;
  wire    [ 15: 0] zs_dq_to_and_from_the_sdram_1;
  wire    [  1: 0] zs_dqm_from_the_sdram_1;
  wire             zs_ras_n_from_the_sdram_1;
  wire             zs_we_n_from_the_sdram_1;


// <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
//  add your signals and additional architecture here
// AND HERE WILL BE PRESERVED </ALTERA_NOTE>

  //Set us up the Dut
  nios_ii_sdram DUT
    (
      .clk_0                                (clk_0),
      .hibi_av_in_to_the_hibi_pe_dma_1      (hibi_av_in_to_the_hibi_pe_dma_1),
      .hibi_av_out_from_the_hibi_pe_dma_1   (hibi_av_out_from_the_hibi_pe_dma_1),
      .hibi_comm_in_to_the_hibi_pe_dma_1    (hibi_comm_in_to_the_hibi_pe_dma_1),
      .hibi_comm_out_from_the_hibi_pe_dma_1 (hibi_comm_out_from_the_hibi_pe_dma_1),
      .hibi_data_in_to_the_hibi_pe_dma_1    (hibi_data_in_to_the_hibi_pe_dma_1),
      .hibi_data_out_from_the_hibi_pe_dma_1 (hibi_data_out_from_the_hibi_pe_dma_1),
      .hibi_empty_in_to_the_hibi_pe_dma_1   (hibi_empty_in_to_the_hibi_pe_dma_1),
      .hibi_full_in_to_the_hibi_pe_dma_1    (hibi_full_in_to_the_hibi_pe_dma_1),
      .hibi_re_out_from_the_hibi_pe_dma_1   (hibi_re_out_from_the_hibi_pe_dma_1),
      .hibi_we_out_from_the_hibi_pe_dma_1   (hibi_we_out_from_the_hibi_pe_dma_1),
      .reset_n                              (reset_n),
      .zs_addr_from_the_sdram_1             (zs_addr_from_the_sdram_1),
      .zs_ba_from_the_sdram_1               (zs_ba_from_the_sdram_1),
      .zs_cas_n_from_the_sdram_1            (zs_cas_n_from_the_sdram_1),
      .zs_cke_from_the_sdram_1              (zs_cke_from_the_sdram_1),
      .zs_cs_n_from_the_sdram_1             (zs_cs_n_from_the_sdram_1),
      .zs_dq_to_and_from_the_sdram_1        (zs_dq_to_and_from_the_sdram_1),
      .zs_dqm_from_the_sdram_1              (zs_dqm_from_the_sdram_1),
      .zs_ras_n_from_the_sdram_1            (zs_ras_n_from_the_sdram_1),
      .zs_we_n_from_the_sdram_1             (zs_we_n_from_the_sdram_1)
    );

  initial
    clk_0 = 1'b0;
  always
    #10 clk_0 <= ~clk_0;
  
  initial 
    begin
      reset_n <= 0;
      #200 reset_n <= 1;
    end

endmodule


//synthesis translate_on