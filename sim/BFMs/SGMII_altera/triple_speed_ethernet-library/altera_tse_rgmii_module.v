// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
//
// Revision Control Information
//
// $RCSfile: altera_tse_rgmii_module.v,v $
// $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/RTL/MAC/mac/rgmii/altera_tse_rgmii_module.v,v $
//
// $Revision: #1 $
// $Date: 2012/06/21 $
// Check in by : $Author: swbranch $
// Author      : Arul Paniandi
//
// Project     : Triple Speed Ethernet - 10/100/1000 MAC
//
// Description : 
//
// Top level RGMII interface (receive and transmit) module.

// 
// ALTERA Confidential and Proprietary
// Copyright 2006 (c) Altera Corporation
// All rights reserved
//
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------

// synthesis translate_off
`timescale 1ns / 100ps
// synthesis translate_on
module altera_tse_rgmii_module /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=\"D103\"" */ (   // new ports to cater for mii with RGMII interface are added 
                      // inputs
                       rgmii_in,
					   speed,
					   //data
                       gm_tx_d,
					   m_tx_d,  
					   
					   //control
                       gm_tx_en,
					   m_tx_en,
					   
                       gm_tx_err,
					   m_tx_err,
					   
                       reset_rx_clk,
                       reset_tx_clk,
                       rx_clk,
                       rx_control,
                       tx_clk,

                      // outputs:
                       rgmii_out,
                       
					   gm_rx_d,
					   m_rx_d,
					   
                       gm_rx_dv,
					   m_rx_en,
					   
					   
                       gm_rx_err,
                       m_rx_err,
					   
					   m_rx_col,
					   m_rx_crs,
					   tx_control
                    );
					
  parameter SYNCHRONIZER_DEPTH 	= 3;	  	    //  Number of synchronizer
	
  output  [  3: 0] rgmii_out;
  output  [  7: 0] gm_rx_d;
  output  [  3: 0] m_rx_d;
  output           gm_rx_dv;
  output           m_rx_en;
  output           gm_rx_err;
  output           m_rx_err;
  output           m_rx_col;
  output           m_rx_crs;
  output           tx_control;
  
  input   [  3: 0] rgmii_in;
  input            speed;
  input   [  7: 0] gm_tx_d;
  input   [  3: 0] m_tx_d; 
  input            gm_tx_en;
  input            m_tx_en;
  input            gm_tx_err;
  input            m_tx_err;
  input            reset_rx_clk;
  input            reset_tx_clk;
  input            rx_clk;
  input            rx_control;
  input            tx_clk;

  wire    [  3: 0] rgmii_out;
  wire    [  7: 0] gm_rx_d;
  wire             gm_rx_dv;
  wire             m_rx_en;
  wire             gm_rx_err;
  wire             m_rx_err;
  wire 			   m_rx_col;
  reg              m_rx_col_reg;
  reg              m_rx_crs;
  
  reg              rx_dv;
  reg              rx_err;
  wire             tx_control;
  //wire             tx_err;
  reg     [  7: 0] rgmii_out_4_wire;
  reg              rgmii_out_1_wire_inp1;
  reg              rgmii_out_1_wire_inp2;
  
  wire    [  7:0 ] rgmii_in_4_wire;
  reg     [  7:0 ] rgmii_in_4_reg;
  reg     [  7:0 ] rgmii_in_4_temp_reg;
  wire    [  1:0 ] rgmii_in_1_wire;
  reg     [  1:0 ] rgmii_in_1_temp_reg;
  
  reg m_tx_en_reg1;
  reg m_tx_en_reg2;
  reg m_tx_en_reg3;
  reg m_tx_en_reg4;
  
  assign gm_rx_d = rgmii_in_4_reg;
  assign m_rx_d  = rgmii_in_4_reg[3:0];  // mii is only 4 bits, data are duplicated so we only take one nibble
    
  altera_tse_rgmii_in4 the_rgmii_in4
    (
      .aclr (),         //INPUT
      .datain (rgmii_in),           //INPUT     
      .dataout_h (rgmii_in_4_wire[7 : 4]),  //OUTPUT
      .dataout_l (rgmii_in_4_wire[3 : 0]),  //OUTPUT
      .inclock (rx_clk)             //OUTPUT
    );


  altera_tse_rgmii_in1 the_rgmii_in1
    (
      .aclr (),            //INPUT
      .datain (rx_control),            //INPUT
      .dataout_h (rgmii_in_1_wire[1]), //INPUT    rx_err
      .dataout_l (rgmii_in_1_wire[0]), //OUTPUT   rx_dv
      .inclock (rx_clk)                //OUTPUT
    );


always @(posedge rx_clk or posedge reset_rx_clk)
    begin
        if (reset_rx_clk == 1'b1) begin
            rgmii_in_4_temp_reg <= {8{1'b0}};
            rgmii_in_1_temp_reg <= {2{1'b0}};
        end
        else begin
            rgmii_in_4_temp_reg <= rgmii_in_4_wire;
            rgmii_in_1_temp_reg <= rgmii_in_1_wire;
        end
    end


always @(posedge rx_clk or posedge reset_rx_clk)
    begin
        if (reset_rx_clk == 1'b1) begin
            rgmii_in_4_reg <= {8{1'b0}};
            rx_err <= 1'b0;
            rx_dv <= 1'b0;
        end
        else begin
            rgmii_in_4_reg <= {rgmii_in_4_wire[3:0], rgmii_in_4_temp_reg[7:4]};
            rx_err <= rgmii_in_1_wire[0];
            rx_dv <= rgmii_in_1_temp_reg[1];            
        end
    end
	
	
always @(rx_dv or rx_err or rgmii_in_4_reg)
  begin
		m_rx_crs = 1'b0;
		if ((rx_dv == 1'b1) || (rx_dv == 1'b0 && rx_err == 1'b1 && rgmii_in_4_reg == 8'hFF ) || (rx_dv == 1'b0 && rx_err == 1'b1 && rgmii_in_4_reg == 8'h0E ) || (rx_dv == 1'b0 && rx_err == 1'b1 && rgmii_in_4_reg == 8'h0F ) || (rx_dv == 1'b0 && rx_err == 1'b1 && rgmii_in_4_reg == 8'h1F ) )
		begin
			m_rx_crs = 1'b1;   // read RGMII specification data sheet , table 4 for the conditions where CRS should go high
		end
  end

always @(posedge tx_clk or posedge reset_tx_clk)
begin
	if(reset_tx_clk == 1'b1)
	begin
		m_tx_en_reg1 <= 1'b0;
		m_tx_en_reg2 <= 1'b0;
		m_tx_en_reg3 <= 1'b0;
		m_tx_en_reg4 <= 1'b0;

	end
	else
	begin
		m_tx_en_reg1 <= m_tx_en;
		m_tx_en_reg2 <= m_tx_en_reg1;
		m_tx_en_reg3 <= m_tx_en_reg2;
		m_tx_en_reg4 <= m_tx_en_reg3;
	end

end  



always @(m_tx_en_reg4 or m_rx_crs or rx_dv)
begin
	m_rx_col_reg = 1'b0;
	if ( m_tx_en_reg4 == 1'b1 & (m_rx_crs == 1'b1 | rx_dv == 1'b1))
	begin
		m_rx_col_reg = 1'b1;
	end
end
 
altera_std_synchronizer #(SYNCHRONIZER_DEPTH) U_SYNC_1(
			.clk(tx_clk), // INPUT
			.reset_n(~reset_tx_clk), //INPUT
			.din(m_rx_col_reg), //INPUT
			.dout(m_rx_col));// OUTPUT

  assign gm_rx_err = rx_err ^ rx_dv;
  assign gm_rx_dv = rx_dv;
  
  assign m_rx_err = rx_err ^ rx_dv;
  assign m_rx_en = rx_dv;
  
    // mux for Out 4
  always @(*)
  begin
    case (speed)
      1'b1:  rgmii_out_4_wire = gm_tx_d;
      1'b0:  rgmii_out_4_wire = {m_tx_d,m_tx_d};
    endcase
  end
  
   // mux for Out 1
  always @(*)
  begin
    case (speed)
      1'b1: 
		begin
			rgmii_out_1_wire_inp1 = gm_tx_en; // gigabit
			rgmii_out_1_wire_inp2 = gm_tx_en ^ gm_tx_err;
		end	
      1'b0:  
		begin
			rgmii_out_1_wire_inp1 = m_tx_en;
			rgmii_out_1_wire_inp2 = m_tx_en ^ m_tx_err;
		end
    endcase
  end
  
  
  altera_tse_rgmii_out4 the_rgmii_out4
    (
      .aclr (reset_tx_clk),         //INPUT
      .datain_h (rgmii_out_4_wire[3 : 0]),   //INPUT
      .datain_l (rgmii_out_4_wire[7 : 4]),   //INPUT
      .dataout (rgmii_out),         //INPUT
      .outclock (tx_clk)            //OUTPUT
    );


  //assign tx_err = gm_tx_en ^ gm_tx_err;

  altera_tse_rgmii_out1 the_rgmii_out1
    (
      .aclr (reset_tx_clk),         //INPUT
      .datain_h (rgmii_out_1_wire_inp1),         //INPUT
      .datain_l (rgmii_out_1_wire_inp2),           //INPUT     
      .dataout (tx_control),        //INPUT
      .outclock (tx_clk)            //OUTPUT
    );



endmodule

