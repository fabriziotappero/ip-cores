/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB 1.1 Top Module                                         ////
////  Function Interface                                         ////
////  OCP Interface                                              ////
////                                                             ////
////  SystemC Version: usb_ocp.cpp                               ////
////  Author: Alfredo Luiz Foltran Fialho                        ////
////          alfoltran@ig.com.br                                ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Verilog Version: usb_ocp_if.v                               ////
//// Copyright (C) 2004      Alfredo Luiz Foltran Fialho         ////
////                         alfoltran@ig.com.br                 ////
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

#include "systemc.h"
#include "usb_ocp.h"

void usb_ocp::sflag_up(void) {
	SFlag.write((	(sc_uint<1>)SF_feature.read(),
					(sc_uint<4>)SF_sel.read(),
					(sc_uint<1>)SF_busy.read(),
					(sc_uint<1>)full.read(),
					(sc_uint<1>)empty.read()));
}

void usb_ocp::sresp_up(void) {
	if ((MCmd.read() == OCP_RD) && SCmdAccept.read())
		SResp.write(OCP_DVA);
	else if (MCmd.read() == OCP_RD)
		SResp.write(OCP_ERR);
	else
		SResp.write(OCP_NULL);
}

void usb_ocp::mux(void) {
	sc_uint<9> sel;

	SData.write(0);
	empty.write(false);
	full.write(false);
	ep1_f_we.write(false);
	ep2_f_re.write(false);
	ep3_f_we.write(false);
	ep4_f_re.write(false);
	ep5_f_we.write(false);
	ep6_f_re.write(false);
	SCmdAccept.write(false);

	sel = ((sc_uint<1>)MCmd.read()[2], (sc_uint<8>)MAddr.read().range(7, 0));

	switch (sel) {// synopsys full_case parallel_case
		case 0:	SData.write(0);
				full.write(false);
				empty.write(false);
				SCmdAccept.write(false);
				break;
		case 1:	ep1_f_din.write(MData.read());
				ep1_f_we.write(MCmd.read() == OCP_WR);
				full.write(ep1_f_full.read());
				SCmdAccept.write(MCmd.read() == OCP_WR);
				break;
		case 2:	SData.write(ep2_f_dout.read());
				ep2_f_re.write(MCmd.read() == OCP_RD);
				empty.write(ep2_f_empty.read());
				SCmdAccept.write(MCmd.read() == OCP_RD);
				break;
		case 3:	ep3_f_din.write(MData.read());
				ep3_f_we.write(MCmd.read() == OCP_WR);
				full.write(ep3_f_full.read());
				SCmdAccept.write(MCmd.read() == OCP_WR);
				break;
		case 4:	SData.write(ep4_f_dout.read());
				ep4_f_re.write(MCmd.read() == OCP_RD);
				empty.write(ep4_f_empty.read());
				SCmdAccept.write(MCmd.read() == OCP_RD);
				break;
		case 5:	ep5_f_din.write(MData.read());
				ep5_f_we.write(MCmd.read() == OCP_WR);
				full.write(ep5_f_full.read());
				SCmdAccept.write(MCmd.read() == OCP_WR);
				break;
		case 6:	SData.write(ep6_f_dout.read());
				ep6_f_re.write(MCmd.read() == OCP_RD);
				empty.write(ep6_f_empty.read());
				SCmdAccept.write(MCmd.read() == OCP_RD);
				break;
		case 8:	SData.write(0);
				full.write(false);
				empty.write(false);
				SCmdAccept.write(false);
				break;
		case 16:if (MCmd.read() == OCP_RD)
					SData.write(wValue.read().range(7, 0));
				SCmdAccept.write(MCmd.read() == OCP_RD);
				break;
		case 17:if (MCmd.read() == OCP_RD)
					SData.write(wValue.read().range(15, 8));
				SCmdAccept.write(MCmd.read() == OCP_RD);
				break;
		case 18:if (MCmd.read() == OCP_RD)
					SData.write(wIndex.read().range(7, 0));
				SCmdAccept.write(MCmd.read() == OCP_RD);
				break;
		case 19:if (MCmd.read() == OCP_RD)
					SData.write(wIndex.read().range(15, 8));
				SCmdAccept.write(MCmd.read() == OCP_RD);
				break;
		case 20:if (MCmd.read() == OCP_WR)
					vendor_data.write((vendor_data.read().range(15, 8), MData.read()));
				SCmdAccept.write(MCmd.read() == OCP_WR);
				break;
		case 21:if (MCmd.read() == OCP_WR)
					vendor_data.write((MData.read(), vendor_data.read().range(7, 0)));
				SCmdAccept.write(MCmd.read() == OCP_WR);
				break;
	}
}
/*
usb_ocp::~usb_ocp(void) {
	if (i_usb)
		delete i_usb;
}
*/
