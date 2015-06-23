/////////////////////////////////////////////////////////////////////
////                                                             ////
////  OPB to WISHBONE interface wrapper                          ////
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

module opb2wb(	OPB_Clk, rst, 

		// OPB Slave Interface (Connect to OPB Master)
		opb_abus, opb_be, opb_dbus, opb_rnw, opb_select, opb_seqaddr,
		sl_dbus, sl_errack, sl_retry, sl_toutsup, sl_xferack,

		// WISHBONE Master Interface (Connect to WB Slave)
		wb_data_o, wb_data_i, wb_addr_o,
		wb_cyc_o, wb_stb_o, wb_sel_o, wb_we_o, wb_ack_i, wb_err_i, wb_rty_i
	);

////////////////////////////////////////////////////////////////////
//
// Parameter
//

parameter	C_BASEADDR	= 32'h8000_0000,
		C_HIGHADDR	= 32'h8000_00ff;

////////////////////////////////////////////////////////////////////
//
// Inputs & Outputs
//

// --------------------------------------
// System IO
input				OPB_Clk;
input				rst;

// --------------------------------------
// OPB Slave Interface (Connect to OPB Master)
input	[31:0]		opb_abus;
input	[3:0]		opb_be;
input	[31:0]		opb_dbus;
input			opb_rnw;
input			opb_select;
input			opb_seqaddr;

output	[31:0]		sl_dbus;
output			sl_errack;
output			sl_retry;
output			sl_toutsup;
output			sl_xferack;

// --------------------------------------
// WISHBONE Master Interface (Connect to WB Slave)
output	[31:0]		wb_data_o;
input	[31:0]		wb_data_i;
output	[31:0]		wb_addr_o;
output			wb_cyc_o, wb_stb_o;
output	[3:0]		wb_sel_o;
output			wb_we_o;
input			wb_ack_i, wb_err_i, wb_rty_i;

endmodule

