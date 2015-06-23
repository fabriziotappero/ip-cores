//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//*****************************************************************************************************************
// Copyright (c) 2007 TooMuch Semiconductor Solutions Pvt Ltd.
//
//File name		:	ahb_wb_master.sv	
//Designer		: 	Sanjay kumar	
//Date			: 	3rd Aug'2007		
//Description		: 	stimulus_gen:This module perform reset and initial signal setup for the testbench.	
//Revision		:	1.0
//*****************************************************************************************************************
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

import global::*;
`timescale 1 ns/1 ps

module stimulus_gen( ahb_wb_if.master_ab m_ab,
                     input bit clk,
                     input bit reset);


//****************************************** 
// assign input clk and reset to stimulus gen
//******************************************

  assign m_ab.hclk = clk;
  assign m_ab.hresetn = reset;

always@(posedge m_ab.hclk)   
	if (!m_ab.hresetn)
		begin
		m_ab.htrans='b00;
		m_ab.haddr='bx;
		m_ab.hwdata='bx;
		end
	
		
//******************************************
// initial signal setups
//******************************************
task initial_setup; 
     	begin
        @(posedge m_ab.hclk);
     #2 m_ab.hsel   ='b1;    // slave selected (only one)
        m_ab.hburst ='b000;  // single transfer 
        m_ab.hsize  ='b010;  // 32 bit size bursting
        m_ab.hwrite ='b0;
        m_ab.htrans ='b10;
	end
endtask
	
	
                            
endmodule
    
