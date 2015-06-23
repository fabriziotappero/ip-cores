/////////////////////////////////////////////////////////////////////
////                                                             ////
////  UTMI Interface                                             ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/usb1_funct/////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: usb1_utmi_if.v,v 1.1.1.1 2002-09-19 12:07:14 rudi Exp $
//
//  $Date: 2002-09-19 12:07:14 $
//  $Revision: 1.1.1.1 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//
//
//
//
//
//
//

`include "usb1_defines.v"

module usb1_utmi_if( // UTMI Interface (EXTERNAL)
		phy_clk, rst,
		DataOut, TxValid, TxReady,
		RxValid, RxActive, RxError, DataIn,

		// Internal Interface
		rx_data, rx_valid, rx_active, rx_err,
		tx_data, tx_valid, tx_valid_last, tx_ready,
		tx_first

		);

input		phy_clk;
input		rst;

output	[7:0]	DataOut;
output		TxValid;
input		TxReady;

input	[7:0]	DataIn;
input		RxValid;
input		RxActive;
input		RxError;


output	[7:0]	rx_data;
output		rx_valid, rx_active, rx_err;
input	[7:0]	tx_data;
input		tx_valid;
input		tx_valid_last;
output		tx_ready;
input		tx_first;

///////////////////////////////////////////////////////////////////
//
// Local Wires and Registers
//
reg	[7:0]	rx_data;
reg		rx_valid, rx_active, rx_err;
reg	[7:0]	DataOut;
reg		tx_ready;
reg		TxValid;

///////////////////////////////////////////////////////////////////
//
// Misc Logic
//


///////////////////////////////////////////////////////////////////
//
// RX Interface Input registers
//

always @(posedge phy_clk or negedge rst)
	if(!rst)	rx_valid <= #1 1'b0;
	else		rx_valid <= #1 RxValid;

always @(posedge phy_clk or negedge rst)
	if(!rst)	rx_active <= #1 1'b0;
	else		rx_active <= #1 RxActive;

always @(posedge phy_clk or negedge rst)
	if(!rst)	rx_err <= #1 1'b0;
	else		rx_err <= #1 RxError;

always @(posedge phy_clk)
		rx_data <= #1 DataIn;

///////////////////////////////////////////////////////////////////
//
// TX Interface Output/Input registers
//

always @(posedge phy_clk)
	if(TxReady | tx_first)	DataOut <= #1 tx_data;

always @(posedge phy_clk)
	tx_ready <= #1 TxReady;

always @(posedge phy_clk or negedge rst)
	if(!rst)	TxValid <= #1 1'b0;
	else
	TxValid <= #1 tx_valid | tx_valid_last | (TxValid & !TxReady);

endmodule

