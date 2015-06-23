/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE to OPB interface wrapper                          ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Proprietary and Confidential Information of                ////
////  ASICS World Services, LTD                                  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2004 ASICS World Services, LTD.          ////
////                         www.asics.ws                        ////
////                         info@asics.ws                       ////
////                                                             ////
//// This software is provided under license and contains        ////
//// proprietary and confidential material which are the         ////
//// property of ASICS World Services, LTD.                      ////
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

//  $Id:        $

module wb2opb(	OPB_Clk, rst, 

		// OPB Master Interface (Connect to OPB Slave)
		opb_abus, opb_be, opb_dbus, opb_rnw, opb_select, opb_seqaddr,
		sl_dbus, sl_errack, sl_retry, sl_xferack,

		opb_req, opb_gnt, opb_buslock, 

		// WISHBONE Slave Interface (Connect to WB Master)
		wb_data_o, wb_data_i, wb_addr_i,
		wb_cyc_i, wb_stb_i, wb_sel_i, wb_we_i, wb_ack_o, wb_err_o, wb_rty_o
	);

// --------------------------------------
// System IO
input			OPB_Clk;
input			rst;

// --------------------------------------
// OPB Master Interface (Connect to OPB Slave)
output	[31:0]		opb_abus;
output	[3:0]		opb_be;
output	[31:0]		opb_dbus;
output			opb_rnw;
output			opb_select;
output			opb_seqaddr;

input	[31:0]		sl_dbus;
input			sl_errack;
input			sl_retry;
input			sl_xferack;

output			opb_req, opb_buslock;
input			opb_gnt;

// --------------------------------------
// WISHBONE Slave Interface (Connect to WB Master)
output	[31:0]		wb_data_o;
input	[31:0]		wb_data_i;
input	[31:0]		wb_addr_i;
input			wb_cyc_i, wb_stb_i;
input	[3:0]		wb_sel_i;
input			wb_we_i;
output			wb_ack_o, wb_err_o, wb_rty_o;

endmodule
