// $Header: /home/marcus/revision_ctrl_test/oc_cvs/cvs/m1_core/hdl/behav/xilinx_unisim/BUFG.v,v 1.1 2008-11-07 13:12:06 fafa1971 Exp $
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Global Clock Buffer
// /___/   /\     Filename : BUFG.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:14 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
// End Revision

`timescale  100 ps / 10 ps


module BUFG (O, I);

    output O;

    input  I;

	buf B1 (O, I);


endmodule

