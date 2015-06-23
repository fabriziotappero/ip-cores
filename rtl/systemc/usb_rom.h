/////////////////////////////////////////////////////////////////////
////                                                             ////
////  USB Descriptor ROM                                         ////
////                                                             ////
////  SystemC Version: usb_rom.h                                 ////
////  Author: Alfredo Luiz Foltran Fialho                        ////
////          alfoltran@ig.com.br                                ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Verilog Version: usb1_rom1.v                                ////
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

#ifndef USB_ROM_H
#define USB_ROM_H

#include "systemc.h"

SC_MODULE(usb_rom) {

  public:

	sc_in<bool>			clk;
	sc_in<sc_uint<8> >	adr;
	sc_out<sc_uint<8> >	dout;

	void dout_update(void) {
		switch (adr.read()) {// synopsys full_case parallel_case
			// ====================================
			// =====    DEVICE Descriptor     =====
			// ====================================
			case 0x00:	dout.write(  18); break;	// this descriptor length
			case 0x01:	dout.write(0x01); break;	// descriptor type
			case 0x02:	dout.write(0x10); break;	// USB version low byte
			case 0x03:	dout.write(0x01); break;	// USB version high byte
			case 0x04:	dout.write(0xff); break;	// device class
			case 0x05:	dout.write(0x00); break;	// device sub class
			case 0x06:	dout.write(0xff); break;	// device protocol
			case 0x07:	dout.write(  64); break;	// max packet size
			case 0x08:	dout.write(0x34); break;	// vendor ID low byte
			case 0x09:	dout.write(0x12); break;	// vendor ID high byte
			case 0x0a:	dout.write(0x78); break;	// product ID low byte
			case 0x0b:	dout.write(0x56); break;	// product ID high byte
			case 0x0c:	dout.write(0x10); break;	// device rel. number low byte
			case 0x0d:	dout.write(0x00); break;	// device rel. number high byte
			case 0x0e:	dout.write(0x01); break;	// Manufacturer String Index
			case 0x0f:	dout.write(0x02); break;	// Product Descr. String Index
			case 0x10:	dout.write(0x03); break;	// S/N String Index
			case 0x11:	dout.write(0x01); break;	// Number of possible config.

			// ====================================
			// ===== Configuration Descriptor =====
			// ====================================
			case 0x12:	dout.write(0x09); break;	// this descriptor length
			case 0x13:	dout.write(0x02); break;	// descriptor type
			case 0x14:	dout.write(  60); break;	// total data length low byte
			case 0x15:	dout.write(   0); break;	// total data length high byte
			case 0x16:	dout.write(0x01); break;	// number of interfaces
			case 0x17:	dout.write(0x01); break;	// number of configurations
			case 0x18:	dout.write(0x00); break;	// Conf. String Index
			case 0x19:	dout.write(0x40); break;	// Config. Characteristics
			case 0x1a:	dout.write(0x00); break;	// Max. Power Consumption

			// ====================================
			// =====   Interface Descriptor   =====
			// ====================================
			case 0x1b:	dout.write(0x09); break;	// this descriptor length
			case 0x1c:	dout.write(0x04); break;	// descriptor type
			case 0x1d:	dout.write(0x00); break;	// interface number
			case 0x1e:	dout.write(0x00); break;	// alternate setting
			case 0x1f:	dout.write(0x06); break;	// number of endpoints
			case 0x20:	dout.write(0xff); break;	// interface class
			case 0x21:	dout.write(0x01); break;	// interface sub class
			case 0x22:	dout.write(0xff); break;	// interface protocol
			case 0x23:	dout.write(0x00); break;	// interface string index

			// ====================================
			// =====   Endpoint 1 Descriptor  =====
			// ====================================
			case 0x24:	dout.write(0x07); break;	// this descriptor length
			case 0x25:	dout.write(0x05); break;	// descriptor type
			case 0x26:	dout.write(0x81); break;	// endpoint address
			case 0x27:	dout.write(0x01); break;	// endpoint attributes
			case 0x28:	dout.write(0x00); break;	// max packet size low byte
			case 0x29:	dout.write(0x01); break;	// max packet size high byte
			case 0x2a:	dout.write(0x01); break;	// polling interval

			// ====================================
			// =====   Endpoint 2 Descriptor  =====
			// ====================================
			case 0x2b:	dout.write(0x07); break;	// this descriptor length
			case 0x2c:	dout.write(0x05); break;	// descriptor type
			case 0x2d:	dout.write(0x02); break;	// endpoint address
			case 0x2e:	dout.write(0x01); break;	// endpoint attributes
			case 0x2f:	dout.write(0x00); break;	// max packet size low byte
			case 0x30:	dout.write(0x01); break;	// max packet size high byte
			case 0x31:	dout.write(0x01); break;	// polling interval

			// ====================================
			// =====   Endpoint 3 Descriptor  =====
			// ====================================
			case 0x32:	dout.write(0x07); break;	// this descriptor length
			case 0x33:	dout.write(0x05); break;	// descriptor type
			case 0x34:	dout.write(0x83); break;	// endpoint address
			case 0x35:	dout.write(0x02); break;	// endpoint attributes
			case 0x36:	dout.write(  64); break;	// max packet size low byte
			case 0x37:	dout.write(   0); break;	// max packet size high byte
			case 0x38:	dout.write(0x01); break;	// polling interval

			// ====================================
			// =====   Endpoint 4 Descriptor  =====
			// ====================================
			case 0x39:	dout.write(0x07); break;	// this descriptor length
			case 0x3a:	dout.write(0x05); break;	// descriptor type
			case 0x3b:	dout.write(0x04); break;	// endpoint address
			case 0x3c:	dout.write(0x02); break;	// endpoint attributes
			case 0x3d:	dout.write(  64); break;	// max packet size low byte
			case 0x3e:	dout.write(   0); break;	// max packet size high byte
			case 0x3f:	dout.write(0x01); break;	// polling interval

			// ====================================
			// =====   Endpoint 5 Descriptor  =====
			// ====================================
			case 0x40:	dout.write(0x07); break;	// this descriptor length
			case 0x41:	dout.write(0x05); break;	// descriptor type
			case 0x42:	dout.write(0x85); break;	// endpoint address
			case 0x43:	dout.write(0x03); break;	// endpoint attributes
			case 0x44:	dout.write(  64); break;	// max packet size low byte
			case 0x45:	dout.write(   0); break;	// max packet size high byte
			case 0x46:	dout.write(0x01); break;	// polling interval

			// ====================================
			// =====   Endpoint 6 Descriptor  =====
			// ====================================
			case 0x47:	dout.write(0x07); break;	// this descriptor length
			case 0x48:	dout.write(0x05); break;	// descriptor type
			case 0x49:	dout.write(0x06); break;	// endpoint address
			case 0x4a:	dout.write(0x03); break;	// endpoint attributes
			case 0x4b:	dout.write(  64); break;	// max packet size low byte
			case 0x4c:	dout.write(   0); break;	// max packet size high byte
			case 0x4d:	dout.write(0x01); break;	// polling interval

			// ====================================
			// ===== String Descriptor Lang ID=====
			// ====================================
			case 0x4e:	dout.write(0x06); break;	// this descriptor length
			case 0x4f:	dout.write(0x03); break;	// descriptor type

						// Brazilian Portuguese
			case 0x50:	dout.write(0x16); break;	// Language ID 0 low byte
			case 0x51:	dout.write(0x04); break;	// Language ID 0 high byte

						// Brazilian Portuguese
			case 0x52:	dout.write(0x16); break;	// Language ID 1 low byte
			case 0x53:	dout.write(0x04); break;	// Language ID 1 high byte

						// Brazilian Portuguese
			case 0x54:	dout.write(0x16); break;	// Language ID 2 low byte
			case 0x55:	dout.write(0x04); break;	// Language ID 2 high byte

			// ====================================
			// =====   String Descriptor 1    =====
			// ====================================
			case 0x56:	dout.write(  26); break;	// this descriptor length
			case 0x57:	dout.write(0x03); break;	// descriptor type

						// "BrazilIP.org"
			case 0x58:	dout.write(   0); break;
			case 0x59:	dout.write( 'g'); break;
			case 0x5a:	dout.write(   0); break;
			case 0x5b:	dout.write( 'r'); break;
			case 0x5c:	dout.write(   0); break;
			case 0x5d:	dout.write( 'o'); break;
			case 0x5e:	dout.write(   0); break;
			case 0x5f:	dout.write( '.'); break;
			case 0x60:	dout.write(   0); break;
			case 0x61:	dout.write( 'P'); break;
			case 0x62:	dout.write(   0); break;
			case 0x63:	dout.write( 'I'); break;
			case 0x64:	dout.write(   0); break;
			case 0x65:	dout.write( 'l'); break;
			case 0x66:	dout.write(   0); break;
			case 0x67:	dout.write( 'i'); break;
			case 0x68:	dout.write(   0); break;
			case 0x69:	dout.write( 'z'); break;
			case 0x6a:	dout.write(   0); break;
			case 0x6b:	dout.write( 'a'); break;
			case 0x6c:	dout.write(   0); break;
			case 0x6d:	dout.write( 'r'); break;
			case 0x6e:	dout.write(   0); break;
			case 0x6f:	dout.write( 'B'); break;

			// ====================================
			// =====   String Descriptor 2    =====
			// ====================================
			case 0x70:	dout.write(  28); break;	// this descriptor length
			case 0x71:	dout.write(0x03); break;	// descriptor type

						// "Projeto Fênix"
			case 0x72:	dout.write(   0); break;
			case 0x73:	dout.write( 'x'); break;
			case 0x74:	dout.write(   0); break;
			case 0x75:	dout.write( 'i'); break;
			case 0x76:	dout.write(   0); break;
			case 0x77:	dout.write( 'n'); break;
			case 0x78:	dout.write(   0); break;
			case 0x79:	dout.write(0xea); break;	//e-circumflex
			case 0x7a:	dout.write(   0); break;
			case 0x7b:	dout.write( 'F'); break;
			case 0x7c:	dout.write(   0); break;
			case 0x7d:	dout.write( ' '); break;
			case 0x7e:	dout.write(   0); break;
			case 0x7f:	dout.write( 'o'); break;
			case 0x80:	dout.write(   0); break;
			case 0x81:	dout.write( 't'); break;
			case 0x82:	dout.write(   0); break;
			case 0x83:	dout.write( 'e'); break;
			case 0x84:	dout.write(   0); break;
			case 0x85:	dout.write( 'j'); break;
			case 0x86:	dout.write(   0); break;
			case 0x87:	dout.write( 'o'); break;
			case 0x88:	dout.write(   0); break;
			case 0x89:	dout.write( 'r'); break;
			case 0x8a:	dout.write(   0); break;
			case 0x8b:	dout.write( 'P'); break;

			// ====================================
			// =====   String Descriptor 3    =====
			// ====================================
			case 0x8c:	dout.write(  54); break;	// this descriptor length
			case 0x8d:	dout.write(0x03); break;	// descriptor type

						// "Versão Experimental (2003)"
			case 0x8e:	dout.write(   0); break;
			case 0x8f:	dout.write( ')'); break;
			case 0x90:	dout.write(   0); break;
			case 0x91:	dout.write( '3'); break;
			case 0x92:	dout.write(   0); break;
			case 0x93:	dout.write( '0'); break;
			case 0x94:	dout.write(   0); break;
			case 0x95:	dout.write( '0'); break;
			case 0x96:	dout.write(   0); break;
			case 0x97:	dout.write( '2'); break;
			case 0x98:	dout.write(   0); break;
			case 0x99:	dout.write( '('); break;
			case 0x9a:	dout.write(   0); break;
			case 0x9b:	dout.write( ' '); break;
			case 0x9c:	dout.write(   0); break;
			case 0x9d:	dout.write( 'l'); break;
			case 0x9e:	dout.write(   0); break;
			case 0x9f:	dout.write( 'a'); break;
			case 0xa0:	dout.write(   0); break;
			case 0xa1:	dout.write( 't'); break;
			case 0xa2:	dout.write(   0); break;
			case 0xa3:	dout.write( 'n'); break;
			case 0xa4:	dout.write(   0); break;
			case 0xa5:	dout.write( 'e'); break;
			case 0xa6:	dout.write(   0); break;
			case 0xa7:	dout.write( 'm'); break;
			case 0xa8:	dout.write(   0); break;
			case 0xa9:	dout.write( 'i'); break;
			case 0xaa:	dout.write(   0); break;
			case 0xab:	dout.write( 'r'); break;
			case 0xac:	dout.write(   0); break;
			case 0xad:	dout.write( 'e'); break;
			case 0xae:	dout.write(   0); break;
			case 0xaf:	dout.write( 'p'); break;
			case 0xb0:	dout.write(   0); break;
			case 0xb1:	dout.write( 'x'); break;
			case 0xb2:	dout.write(   0); break;
			case 0xb3:	dout.write( 'E'); break;
			case 0xb4:	dout.write(   0); break;
			case 0xb5:	dout.write( ' '); break;
			case 0xb6:	dout.write(   0); break;
			case 0xb7:	dout.write( 'o'); break;
			case 0xb8:	dout.write(   0); break;
			case 0xb9:	dout.write(0xe3); break;	//a-tilde
			case 0xba:	dout.write(   0); break;
			case 0xbb:	dout.write( 's'); break;
			case 0xbc:	dout.write(   0); break;
			case 0xbd:	dout.write( 'r'); break;
			case 0xbe:	dout.write(   0); break;
			case 0xbf:	dout.write( 'e'); break;
			case 0xc0:	dout.write(   0); break;
			case 0xc1:	dout.write( 'V'); break;

			default:	dout.write(0x00); break;
		}
	}

	SC_CTOR(usb_rom) {
		SC_METHOD(dout_update);
		sensitive << clk.pos();
	}

};

#endif

