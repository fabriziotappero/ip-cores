// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
//
// Revision Control Information
//
// $RCSfile: altera_tse_gxb_gige_inst.v,v $
// $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/RTL/Top_level_modules/altera_tse_gxb_gige_phyip_inst.v,v $
//
// $Revision: #23 $
// $Date: 2010/09/05 $
// Check in by : $Author: sxsaw $
// Author      : Siew Kong NG
//
// Project     : Triple Speed Ethernet - 1000 BASE-X PCS
//
// Description : 
//
// Instantiation for Alt2gxb, Alt4gxb

// 
// ALTERA Confidential and Proprietary
// Copyright 2007 (c) Altera Corporation
// All rights reserved
//
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------

//Legal Notice: (C)2007 Altera Corporation. All rights reserved.  Your
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

module altera_tse_gxb_gige_phyip_inst (
        phy_mgmt_clk,
        phy_mgmt_clk_reset,
        phy_mgmt_address,
        phy_mgmt_read,
        phy_mgmt_readdata,
        phy_mgmt_waitrequest,
        phy_mgmt_write,
        phy_mgmt_writedata,
        tx_ready,
        rx_ready,
        pll_ref_clk,
        pll_locked,
        tx_serial_data,
        rx_serial_data,
        rx_runningdisp,
        rx_disperr,
        rx_errdetect,
        rx_patterndetect,
        rx_syncstatus,
        tx_clkout,
        rx_clkout,
        tx_parallel_data,
        tx_datak,
        rx_parallel_data,
        rx_datak,
        rx_rlv,
        rx_recovclkout,
        rx_rmfifodatadeleted,
        rx_rmfifodatainserted,
        reconfig_togxb,
        reconfig_fromgxb
);
parameter DEVICE_FAMILY           = "STRATIXV";    //  The device family the the core is targetted for.
parameter ENABLE_ALT_RECONFIG     = 0;
parameter ENABLE_SGMII            = 1;            //  Use to determine rate match FIFO in ALTGX GIGE mode
parameter ENABLE_DET_LATENCY      = 0;

input phy_mgmt_clk;
input phy_mgmt_clk_reset;
input [8:0]phy_mgmt_address;
input phy_mgmt_read;
output [31:0]phy_mgmt_readdata;
output phy_mgmt_waitrequest;
input phy_mgmt_write;
input [31:0]phy_mgmt_writedata;
output tx_ready;
output rx_ready;
input pll_ref_clk;
output pll_locked;
output tx_serial_data;
input rx_serial_data;
output rx_runningdisp;
output rx_disperr;
output rx_errdetect;
output rx_patterndetect;
output rx_syncstatus;
output tx_clkout;
output rx_clkout;
input [7:0] tx_parallel_data;
input  tx_datak;
output [7:0] rx_parallel_data;
output rx_datak;
output rx_rlv;
output rx_recovclkout;
output rx_rmfifodatadeleted;
output rx_rmfifodatainserted;
input [139:0]reconfig_togxb;
output [91:0]reconfig_fromgxb;

  wire    [91:0] reconfig_fromgxb;
  wire    [139:0] wire_reconfig_togxb;

  (* altera_attribute = "-name MESSAGE_DISABLE 10036" *) 
  wire    [91:0] wire_reconfig_fromgxb;


  generate if (ENABLE_ALT_RECONFIG == 0)
                begin
        
                         assign wire_reconfig_togxb = 140'd0;
                         assign reconfig_fromgxb = 92'd0;        
 
                end
  else
                begin
        
                         assign wire_reconfig_togxb = reconfig_togxb;
                         assign reconfig_fromgxb = wire_reconfig_fromgxb;
 
                end
  endgenerate

        generate if (ENABLE_SGMII == 0)
        begin
        
         altera_tse_phyip_gxb the_altera_tse_phyip_gxb (
        .phy_mgmt_clk(phy_mgmt_clk),                 //       phy_mgmt_clk.clk
        .phy_mgmt_clk_reset(phy_mgmt_clk_reset),     // phy_mgmt_clk_reset.reset
        .phy_mgmt_address(phy_mgmt_address),         //           phy_mgmt.address
        .phy_mgmt_read(phy_mgmt_read),               //                   .read
        .phy_mgmt_readdata(phy_mgmt_readdata),       //                   .readdata
        .phy_mgmt_waitrequest(phy_mgmt_waitrequest), //                   .waitrequest
        .phy_mgmt_write(phy_mgmt_write),             //                   .write
        .phy_mgmt_writedata(phy_mgmt_writedata),     //                   .writedata
        .tx_ready(tx_ready),                         //           tx_ready.export
        .rx_ready(rx_ready),                         //           rx_ready.export
        .pll_ref_clk(pll_ref_clk),                   //        pll_ref_clk.clk
        .pll_locked(pll_locked),                     //         pll_locked.export
        .tx_serial_data(tx_serial_data),             //     tx_serial_data.export
        .rx_serial_data(rx_serial_data),             //     rx_serial_data.export
        .rx_runningdisp(rx_runningdisp),             //     rx_runningdisp.export
        .rx_disperr(rx_disperr),                     //         rx_disperr.export
        .rx_errdetect(rx_errdetect),                 //       rx_errdetect.export
        .rx_patterndetect(rx_patterndetect),         //   rx_patterndetect.export
        .rx_syncstatus(rx_syncstatus),               //       rx_syncstatus.export
        .tx_clkout(tx_clkout),                       //          tx_clkout.clk
        .tx_parallel_data(tx_parallel_data),         //  tx_parallel_data.data
        .tx_datak(tx_datak),                         //          tx_datak.data
        .rx_parallel_data(rx_parallel_data),         //  rx_parallel_data.data
        .rx_datak(rx_datak),                         //          rx_datak.data
        .rx_rlv(rx_rlv),
        .rx_recovered_clk(rx_recovclkout),
        .rx_rmfifodatadeleted(rx_rmfifodatadeleted),
        .rx_rmfifodatainserted(rx_rmfifodatainserted),
        .reconfig_to_xcvr(wire_reconfig_togxb),
        .reconfig_from_xcvr(wire_reconfig_fromgxb)
    );
        assign rx_clkout  = tx_clkout;

        end
        endgenerate
    
   generate if ((ENABLE_SGMII == 1) && (ENABLE_DET_LATENCY == 0))
        begin
        
        altera_tse_phyip_gxb_wo_rmfifo the_altera_tse_phyip_gxb_wo_rmfifo (
        .phy_mgmt_clk(phy_mgmt_clk),                 //       phy_mgmt_clk.clk
        .phy_mgmt_clk_reset(phy_mgmt_clk_reset),     // phy_mgmt_clk_reset.reset
        .phy_mgmt_address(phy_mgmt_address),         //           phy_mgmt.address
        .phy_mgmt_read(phy_mgmt_read),               //                   .read
        .phy_mgmt_readdata(phy_mgmt_readdata),       //                   .readdata
        .phy_mgmt_waitrequest(phy_mgmt_waitrequest), //                   .waitrequest
        .phy_mgmt_write(phy_mgmt_write),             //                   .write
        .phy_mgmt_writedata(phy_mgmt_writedata),     //                   .writedata
        .tx_ready(tx_ready),                         //           tx_ready.export
        .rx_ready(rx_ready),                         //           rx_ready.export
        .pll_ref_clk(pll_ref_clk),                   //        pll_ref_clk.clk
        .pll_locked(pll_locked),                     //         pll_locked.export
        .tx_serial_data(tx_serial_data),             //     tx_serial_data.export
        .rx_serial_data(rx_serial_data),             //     rx_serial_data.export
        .rx_runningdisp(rx_runningdisp),             //     rx_runningdisp.export
        .rx_disperr(rx_disperr),                     //         rx_disperr.export
        .rx_errdetect(rx_errdetect),                 //       rx_errdetect.export
        .rx_patterndetect(rx_patterndetect),         //   rx_patterndetect.export
        .rx_syncstatus(rx_syncstatus),               //      rx_syncstatus.export
        .tx_clkout(tx_clkout),                       //         tx_clkout.clk
        .rx_clkout(rx_clkout),                       //         rx_clkout.clk
        .tx_parallel_data(tx_parallel_data),         //  tx_parallel_data.data
        .tx_datak(tx_datak),                         //          tx_datak.data
        .rx_parallel_data(rx_parallel_data),         //  rx_parallel_data.data
        .rx_datak(rx_datak),                         //          rx_datak.data
        .rx_rlv(rx_rlv), 
        .rx_recovered_clk(rx_recovclkout),
        .reconfig_to_xcvr(wire_reconfig_togxb),
        .reconfig_from_xcvr(wire_reconfig_fromgxb)   
    );


        assign rx_rmfifodatadeleted = 1'b0;
        assign rx_rmfifodatainserted = 1'b0;

    end
    endgenerate
    
    
    
    generate if ((ENABLE_SGMII == 1) && (ENABLE_DET_LATENCY == 1))
        begin
        
        altera_tse_phyip_det_latency the_altera_tse_phyip_gxb_wo_rmfifo (
        .phy_mgmt_clk(phy_mgmt_clk),                 //       phy_mgmt_clk.clk
        .phy_mgmt_clk_reset(phy_mgmt_clk_reset),     // phy_mgmt_clk_reset.reset
        .phy_mgmt_address(phy_mgmt_address),         //           phy_mgmt.address
        .phy_mgmt_read(phy_mgmt_read),               //                   .read
        .phy_mgmt_readdata(phy_mgmt_readdata),       //                   .readdata
        .phy_mgmt_waitrequest(phy_mgmt_waitrequest), //                   .waitrequest
        .phy_mgmt_write(phy_mgmt_write),             //                   .write
        .phy_mgmt_writedata(phy_mgmt_writedata),     //                   .writedata
        .tx_ready(tx_ready),                         //           tx_ready.export
        .rx_ready(rx_ready),                         //           rx_ready.export
        .pll_ref_clk(pll_ref_clk),                   //        pll_ref_clk.clk
        .pll_locked(pll_locked),                     //         pll_locked.export
        .tx_serial_data(tx_serial_data),             //     tx_serial_data.export
        .rx_serial_data(rx_serial_data),             //     rx_serial_data.export
        .rx_runningdisp(rx_runningdisp),             //     rx_runningdisp.export
        .rx_disperr(rx_disperr),                     //         rx_disperr.export
        .rx_errdetect(rx_errdetect),                 //       rx_errdetect.export
        .rx_patterndetect(rx_patterndetect),         //   rx_patterndetect.export
        .rx_syncstatus(rx_syncstatus),               //      rx_syncstatus.export
        .tx_clkout(tx_clkout),                       //         tx_clkout.clk
        .rx_clkout(rx_clkout),                       //         rx_clkout.clk
        .tx_parallel_data(tx_parallel_data),         //  tx_parallel_data.data
        .tx_datak(tx_datak),                         //          tx_datak.data
        .rx_parallel_data(rx_parallel_data),         //  rx_parallel_data.data
        .rx_datak(rx_datak),                         //          rx_datak.data
        .rx_rlv(rx_rlv), 
        .reconfig_to_xcvr(wire_reconfig_togxb),
        .reconfig_from_xcvr(wire_reconfig_fromgxb),
        .rx_bitslipboundaryselectout()
        //.rx_recovered_clk(rx_recovclkout),
    );


        assign rx_rmfifodatadeleted = 1'b0;
        assign rx_rmfifodatainserted = 1'b0;
        assign rx_recovclkout = rx_clkout; // work around since this port is not available in Deterministic Latency PHY IP

    end
    endgenerate

endmodule
