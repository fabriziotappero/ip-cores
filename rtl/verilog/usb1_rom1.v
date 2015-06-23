/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Descriptor ROM                                             ////
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
//  $Id: usb1_rom1.v,v 1.1.1.1 2002-09-19 12:07:29 rudi Exp $
//
//  $Date: 2002-09-19 12:07:29 $
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

`include "usb1_defines.v"

module usb1_rom1(clk, adr, dout);
input		clk;
input	[6:0]	adr;
output	[7:0]	dout;

reg	[7:0]	dout;

always @(posedge clk)
	case(adr)	// synopsys full_case parallel_case

		// ====================================
		// =====    DEVICE Descriptor     =====
		// ====================================

	   7'h00:	dout <= #1 8'd18;	// this descriptor length
	   7'h01:	dout <= #1 8'h01;	// descriptor type
	   7'h02:	dout <= #1 8'h00;	// USB version low byte
	   7'h03:	dout <= #1 8'h01;	// USB version high byte
	   7'h04:	dout <= #1 8'hff;	// device class
	   7'h05:	dout <= #1 8'h00;	// device sub class
	   7'h06:	dout <= #1 8'hff;	// device protocol
	   7'h07:	dout <= #1 8'd64;	// max packet size
	   7'h08:	dout <= #1 8'h34;	// vendor ID low byte
	   7'h09:	dout <= #1 8'h12;	// vendor ID high byte
	   7'h0a:	dout <= #1 8'h78;	// product ID low byte
	   7'h0b:	dout <= #1 8'h56;	// product ID high byte
	   7'h0c:	dout <= #1 8'h10;	// device rel. number low byte
	   7'h0d:	dout <= #1 8'h00;	// device rel. number high byte
	   7'h0e:	dout <= #1 8'h00;	// Manufacturer String Index
	   7'h0f:	dout <= #1 8'h00;	// Product Descr. String Index
	   7'h10:	dout <= #1 8'h00;	// S/N String Index
	   7'h11:	dout <= #1 8'h01;	// Number of possible config.

		// ====================================
		// ===== Configuration Descriptor =====
		// ====================================
	   7'h12:	dout <= #1 8'h09;	// this descriptor length
	   7'h13:	dout <= #1 8'h02;	// descriptor type
	   7'h14:	dout <= #1 8'd53;	// total data length low byte
	   7'h15:	dout <= #1 8'd00;	// total data length high byte
	   7'h16:	dout <= #1 8'h01;	// number of interfaces
	   7'h17:	dout <= #1 8'h01;	// number of configurations
	   7'h18:	dout <= #1 8'h00;	// Conf. String Index
	   7'h19:	dout <= #1 8'h40;	// Config. Characteristics
	   7'h1a:	dout <= #1 8'h00;	// Max. Power Consumption

		// ====================================
		// =====   Interface Descriptor   =====
		// ====================================
	   7'h1b:	dout <= #1 8'h09;	// this descriptor length
	   7'h1c:	dout <= #1 8'h04;	// descriptor type
	   7'h1d:	dout <= #1 8'h00;	// interface number
	   7'h1e:	dout <= #1 8'h00;	// alternate setting
	   7'h1f:	dout <= #1 8'h05;	// number of endpoints
	   7'h20:	dout <= #1 8'hff;	// interface class
	   7'h21:	dout <= #1 8'h01;	// interface sub class
	   7'h22:	dout <= #1 8'hff;	// interface protocol
	   7'h23:	dout <= #1 8'h00;	// interface string index

		// ====================================
		// =====   Endpoint 1 Descriptor  =====
		// ====================================
	   7'h24:	dout <= #1 8'h07;	// this descriptor length
	   7'h25:	dout <= #1 8'h05;	// descriptor type
	   7'h26:	dout <= #1 8'h81;	// endpoint address
	   7'h27:	dout <= #1 8'h01;	// endpoint attributes
	   7'h28:	dout <= #1 8'h00;	// max packet size low byte
	   7'h29:	dout <= #1 8'h01;	// max packet size high byte
	   7'h2a:	dout <= #1 8'h01;	// polling interval

		// ====================================
		// =====   Endpoint 2 Descriptor  =====
		// ====================================
	   7'h2b:	dout <= #1 8'h07;	// this descriptor length
	   7'h2c:	dout <= #1 8'h05;	// descriptor type
	   7'h2d:	dout <= #1 8'h02;	// endpoint address
	   7'h2e:	dout <= #1 8'h01;	// endpoint attributes
	   7'h2f:	dout <= #1 8'h00;	// max packet size low byte
	   7'h30:	dout <= #1 8'h01;	// max packet size high byte
	   7'h31:	dout <= #1 8'h01;	// polling interval

		// ====================================
		// =====   Endpoint 3 Descriptor  =====
		// ====================================
	   7'h32:	dout <= #1 8'h07;	// this descriptor length
	   7'h33:	dout <= #1 8'h05;	// descriptor type
	   7'h34:	dout <= #1 8'h83;	// endpoint address
	   7'h35:	dout <= #1 8'h02;	// endpoint attributes
	   7'h36:	dout <= #1 8'd64;	// max packet size low byte
	   7'h37:	dout <= #1 8'd00;	// max packet size high byte
	   7'h38:	dout <= #1 8'h01;	// polling interval

		// ====================================
		// =====   Endpoint 4 Descriptor  =====
		// ====================================
	   7'h39:	dout <= #1 8'h07;	// this descriptor length
	   7'h3a:	dout <= #1 8'h05;	// descriptor type
	   7'h3b:	dout <= #1 8'h04;	// endpoint address
	   7'h3c:	dout <= #1 8'h02;	// endpoint attributes
	   7'h3d:	dout <= #1 8'd64;	// max packet size low byte
	   7'h3e:	dout <= #1 8'd00;	// max packet size high byte
	   7'h3f:	dout <= #1 8'h01;	// polling interval

		// ====================================
		// =====   Endpoint 5 Descriptor  =====
		// ====================================
	   7'h40:	dout <= #1 8'h07;	// this descriptor length
	   7'h41:	dout <= #1 8'h05;	// descriptor type
	   7'h42:	dout <= #1 8'h85;	// endpoint address
	   7'h43:	dout <= #1 8'h03;	// endpoint attributes
	   7'h44:	dout <= #1 8'd64;	// max packet size low byte
	   7'h45:	dout <= #1 8'd00;	// max packet size high byte
	   7'h46:	dout <= #1 8'h01;	// polling interval

/*
		// ====================================
		// ===== String Descriptor Lang ID=====
		// ====================================

	   7'h47:	dout <= #1 8'd06;	// this descriptor length
	   7'h48:	dout <= #1 8'd03;	// descriptor type

	   7'h49:	dout <= #1 8'd09;	// Language ID 0 low byte
	   7'h4a:	dout <= #1 8'd04;	// Language ID 0 high byte

	   7'h4b:	dout <= #1 8'd09;	// Language ID 1 low byte
	   7'h4c:	dout <= #1 8'd04;	// Language ID 1 high byte

	   7'h4d:	dout <= #1 8'd09;	// Language ID 2 low byte
	   7'h4e:	dout <= #1 8'd04;	// Language ID 2 high byte

		// ====================================
		// =====   String Descriptor 0    =====
		// ====================================

	   7'h50:	dout <= #1 8'd010;	// this descriptor length
	   7'h51:	dout <= #1 8'd03;	// descriptor type
	   7'h52:	dout <= #1 "0";
	   7'h53:	dout <= #1 " ";
	   7'h54:	dout <= #1 "g";
	   7'h55:	dout <= #1 "n";
	   7'h56:	dout <= #1 "i";
	   7'h57:	dout <= #1 "r";
	   7'h58:	dout <= #1 "t";
	   7'h59:	dout <= #1 "S";

		// ====================================
		// =====   String Descriptor 1    =====
		// ====================================

	   7'h60:	dout <= #1 8'd010;	// this descriptor length
	   7'h61:	dout <= #1 8'd03;	// descriptor type
	   7'h62:	dout <= #1 "1";
	   7'h63:	dout <= #1 " ";
	   7'h64:	dout <= #1 "g";
	   7'h65:	dout <= #1 "n";
	   7'h66:	dout <= #1 "i";
	   7'h67:	dout <= #1 "r";
	   7'h68:	dout <= #1 "t";
	   7'h69:	dout <= #1 "S";

		// ====================================
		// =====   String Descriptor 2    =====
		// ====================================

	   7'h70:	dout <= #1 8'd010;	// this descriptor length
	   7'h71:	dout <= #1 8'd03;	// descriptor type
	   7'h72:	dout <= #1 "2";
	   7'h73:	dout <= #1 " ";
	   7'h74:	dout <= #1 "g";
	   7'h75:	dout <= #1 "n";
	   7'h76:	dout <= #1 "i";
	   7'h77:	dout <= #1 "r";
	   7'h78:	dout <= #1 "t";
	   7'h79:	dout <= #1 "S";

*/

		// ====================================
		// ====================================

	   //default:	dout <= #1 8'd00;
	endcase

endmodule
