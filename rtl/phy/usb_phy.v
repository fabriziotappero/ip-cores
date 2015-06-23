/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB 1.1 PHY                                                ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/usb_phy/   ////
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

//-----------------------------------------------------------------
// Module:
//-----------------------------------------------------------------
module usb_phy
(
    // Clock (48MHz) & reset
    clk, 
    rst, 
    
    // PHY Transmit Mode:
    // When phy_tx_mode_i is '0' the outputs are encoded as:
    //  TX- TX+
    // 	 0	0	Differential Logic '0'
    // 	 0	1	Differential Logic '1'
    // 	 1	0	Single Ended '0'
    // 	 1	1	Single Ended '0'
    // When phy_tx_mode_i is '1' the outputs are encoded as:
    //  TX- TX+
    // 	 0	0	Single Ended '0'
    // 	 0	1	Differential Logic '1'
    // 	 1	0	Differential Logic '0'
    // 	 1	1	Illegal State
    phy_tx_mode_i, 
    
    // USB bus reset event
    usb_rst_o,
    usb_rst_i,
	
	// Transciever Interface
	// Tx +/-
	tx_dp_o, 
	tx_dn_o, 
	
	// Tx output enable (active low)
	tx_oen_o,
	
	// Receive data
	rx_rcv_i, 
	
	// Rx +/-
	rx_dp_i, 
	rx_dn_i,

	// UTMI Interface
	
	// Transmit data [7:0]
	utmi_data_i, 
	
	// Transmit data enable
	utmi_txvalid_i, 
	
	// Transmit ready (L=hold,H=load data)
	utmi_txready_o, 
	
	// Receive data [7:0]
	utmi_data_o, 
	
	// Valid data on utmi_data_o
	utmi_rxvalid_o,
	
	// Receive active (SYNC recieved)
	utmi_rxactive_o, 
	
	// Rx error occurred
	utmi_rxerror_o, 	
	
	// Receive line state [1=RX-, 0=RX+]
	utmi_linestate_o
);

//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// I/O
//-----------------------------------------------------------------  
input		clk;
input		rst;
input		phy_tx_mode_i;
output		usb_rst_o;
input		usb_rst_i;
output		tx_dp_o, tx_dn_o, tx_oen_o;
input		rx_rcv_i, rx_dp_i, rx_dn_i;
input	[7:0]	utmi_data_i;
input		utmi_txvalid_i;
output		utmi_txready_o;
output	[7:0]	utmi_data_o;
output		utmi_rxvalid_o;
output		utmi_rxactive_o;
output		utmi_rxerror_o;
output	[1:0]	utmi_linestate_o;

///////////////////////////////////////////////////////////////////
//
// Local Wires and Registers
//

reg	[4:0]	rst_cnt;
reg		    usb_rst_o;
wire		fs_ce;
wire		rst;

wire        tx_dp_int;
wire        tx_dn_int;
wire        tx_oen_int;

///////////////////////////////////////////////////////////////////
//
// Misc Logic
//

///////////////////////////////////////////////////////////////////
//
// TX Phy
//

usb_tx_phy i_tx_phy(
	.clk(		clk		),
	.rst(		rst		),
	.fs_ce(		fs_ce		),
	.phy_mode(	phy_tx_mode_i ),

	// Transciever Interface
	.txdp(		tx_dp_int		),
	.txdn(		tx_dn_int		),
	.txoe(		tx_oen_int		),

	// UTMI Interface
	.DataOut_i(	utmi_data_i	),
	.TxValid_i(	utmi_txvalid_i	),
	.TxReady_o(	utmi_txready_o	)
	);

///////////////////////////////////////////////////////////////////
//
// RX Phy and DPLL
//

usb_rx_phy i_rx_phy(
	.clk(		clk		),
	.rst(		rst		),
	.fs_ce(		fs_ce		),

	// Transciever Interface
	.rxd(		rx_rcv_i		),
	.rxdp(		rx_dp_i		),
	.rxdn(		rx_dn_i		),

	// UTMI Interface
	.DataIn_o(	utmi_data_o	),
	.RxValid_o(	utmi_rxvalid_o	),
	.RxActive_o(	utmi_rxactive_o	),
	.RxError_o(	utmi_rxerror_o	),
	.RxEn_i(	tx_oen_o		),
	.LineState(	utmi_linestate_o	)
	);

///////////////////////////////////////////////////////////////////
//
// Generate an USB Reset is we see SE0 for at least 2.5uS
//

`ifdef USB_ASYNC_REST
always @(posedge clk or negedge rst)
`else
always @(posedge clk)
`endif
	if(!rst)			rst_cnt <= 5'h0;
	else
	if(utmi_linestate_o != 2'h0)  rst_cnt <= 5'h0;
	else	
	if(!usb_rst_o && fs_ce)		rst_cnt <= rst_cnt + 5'h1;

`ifdef CONF_TARGET_SIM
// Disable RST_O
always @(posedge clk)
	usb_rst_o <= 1'b0;
`else
always @(posedge clk)
	usb_rst_o <= (rst_cnt == 5'h1f);
`endif
	
// Host generate USB reset event (SE0)
assign tx_dp_o  = usb_rst_i ? 1'b0 : tx_dp_int;
assign tx_dn_o  = usb_rst_i ? 1'b1 : tx_dn_int;
assign tx_oen_o = usb_rst_i ? 1'b0 : tx_oen_int;
	
endmodule

