// --------------------------------------------------------------------
//
// --------------------------------------------------------------------


module 
  altera_virtual_jtag(
    output  tck_o,
    input   debug_tdo_i,
    output  tdi_o,
    output  test_logic_reset_o,
    output  run_test_idle_o,
    output  shift_dr_o,
    output  capture_dr_o,
    output  pause_dr_o,
    output  update_dr_o,
    output  debug_select_o
  );
  
  wire [3:0] ir_value;
                     
      
  //---------------------------------------------------
  // 
  amf_sld_virtual_jtag
    i_amf_sld_virtual_jtag (
      .ir_out ( ir_value ),
      .tdo ( debug_tdo_i ),
      .ir_in ( ir_value ),
      .jtag_state_cdr (  ),
      .jtag_state_cir (  ),
      .jtag_state_e1dr (  ),
      .jtag_state_e1ir (  ),
      .jtag_state_e2dr (  ),
      .jtag_state_e2ir (  ),
      .jtag_state_pdr (  ),
      .jtag_state_pir (  ),
      .jtag_state_rti ( run_test_idle_o ),
      .jtag_state_sdr (  ),
      .jtag_state_sdrs (  ),
      .jtag_state_sir (  ),
      .jtag_state_sirs (  ),
      .jtag_state_tlr ( test_logic_reset_o ),
      .jtag_state_udr (  ),
      .jtag_state_uir (  ),
      .tck ( tck_o ),
      .tdi ( tdi_o ),
      .tms ( tms_sig ),
      .virtual_state_cdr ( capture_dr_o ),
      .virtual_state_cir ( capture_ir ),
      .virtual_state_e1dr ( exit1_dr ),
      .virtual_state_e2dr ( exit2_dr ),
      .virtual_state_pdr ( pause_dr_o ),
      .virtual_state_sdr ( shift_dr_o ),
      .virtual_state_udr ( update_dr_o ),
      .virtual_state_uir ( update_ir )
    );
            
           
  //---------------------------------------------------
  // outputs
  
  assign debug_select_o = (ir_value == 4'b1000 ) ? 1'b1 : 1'b0;

endmodule


