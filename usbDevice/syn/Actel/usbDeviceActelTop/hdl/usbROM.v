//////////////////////////////////////////////////////////////////////
////                                                              ////
//// usbROM.v                                                     ////
////                                                              ////
//// This file is part of the usbHostSlave opencores effort.
//// <http://www.opencores.org/cores//>                           ////
////                                                              ////
//// Module Description:                                          ////
//// if you modify this file, be sure to modify usbDevice_define.v
//// Using RAM rather than logic resources might be a more efficient implememtation
//// but this has the advantage of working with FPGAs that do not provide a 
//// mechanism for initialising RAM, eg Actel IGLOO
//// Quartus 7.2 will infer this code as BLOCK RAM, and provide initialisation - nice
////                                                              ////
//// To Do:                                                       ////
//// 
////                                                              ////
//// Author(s):                                                   ////
//// - Steve Fielding, sfielding@base2designs.com                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 Steve Fielding and OPENCORES.ORG          ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from <http://www.opencores.org/lgpl.shtml>                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
`include "usbDevice_define.v"


module usbROM (
  clk,
  addr,
  data
);
input clk;
input [7:0] addr;
output [7:0] data;
reg [7:0] data;

always @(posedge clk) begin
  case (addr)
// ====================================
// =====    DEVICE Descriptor     =====
// ====================================

    8'h00: data <= 8'h12;  //BYTE bLength
    8'h01: data <= 8'h01;  //BYTE bDescriptorType
    8'h02: data <= 8'h10;  //WORD (Lo) bcdUSB version supported
    8'h03: data <= 8'h01;  //WORD (Hi) bcdUSB version supported
    8'h04: data <= 8'h00;  //BYTE bDeviceClass
    8'h05: data <= 8'h00;  //BYTE bDeviceSubClass
    8'h06: data <= 8'h00;  //BYTE bDeviceProtocol
	 8'h07: data <= `MAX_RESP_SIZE;  //BYTE bMaxPacketSize 
    8'h08: data <= 8'hC7;  //WORD (Lo) idVendor
    8'h09: data <= 8'h05;  //WORD (Hi) idVendor
    8'h0a: data <= 8'h13;  //WORD (Lo) idProduct; For Philips Hub mouse
    8'h0b: data <= 8'h01;  //WORD (Hi) idProduct; For Philips Hub mouse
    8'h0c: data <= 8'h01;  //WORD (Lo) bcdDevice
    8'h0d: data <= 8'h00;  //WORD (Hi) bcdDevice
    8'h0e: data <= 8'h01;  //BYTE iManufacturer
    8'h0f: data <= 8'h02;  //BYTE iProduct
    8'h10: data <= 8'h03;  //BYTE iSerialNumber
    8'h11: data <= 8'h01;  //BYTE bNumConfigurations

 
// ====================================
// ===== Configuration Descriptor =====
// ====================================
    8'h12: data <= 8'h09;  //BYTE bLength (Configuration descriptor)
    8'h13: data <= 8'h02;  //BYTE bDescriptorType //Assigned by USB
	 8'h14: data <= 8'd34;  //WORD (Lo) wTotalLength
    8'h15: data <= 8'h00;  //WORD (Hi) wTotalLength
    8'h16: data <= 8'h01;  //BYTE bNumInterfaces
    8'h17: data <= 8'h01;  //BYTE bConfigurationValue
    8'h18: data <= 8'h00;  //BYTE iConfiguration
    8'h19: data <= 8'ha0;  //BYTE bmAttributes, Bus powered and remote wakeup
    8'h1a: data <= 8'h32;  //BYTE MaxPower, 100mA
 
// ====================================
// =====   Interface Descriptor   =====
// ====================================
    8'h1b: data <= 8'h09;  //BYTE bLength (Interface descriptor)
    8'h1c: data <= 8'h04;  //BYTE bDescriptionType; assigned by USB
    8'h1d: data <= 8'h00;  //BYTE bInterfaceNumber
    8'h1e: data <= 8'h00;  //BYTE bAlternateSetting
    8'h1f: data <= 8'h01;  //BYTE bNumEndpoints; uses 1 endpoints
    8'h20: data <= 8'h03;  //BYTE bInterfaceClass; HID Class - 0x03
    8'h21: data <= 8'h01;  //BYTE bInterfaceSubClass
    8'h22: data <= 8'h02;  //BYTE bInterfaceProtocol
    8'h23: data <= 8'h00;  //BYTE iInterface
 
// ====================================
// =====   HID Descriptor   =====
// ====================================
    8'h24: data <= 8'h09;  //BYTE bLength (HID Descriptor)
    8'h25: data <= 8'h21;  //BYTE bDescriptorType
    8'h26: data <= 8'h10;  //WORD (Lo) bcdHID
    8'h27: data <= 8'h01;  //WORD (Hi) bcdHID
    8'h28: data <= 8'h00;  //BYTE bCountryCode
    8'h29: data <= 8'h01;  //BYTE bNumDescriptors
    8'h2a: data <= 8'h22;  //BYTE bReportDescriptorType
    8'h2b: data <= 8'h32;  //WORD (Lo) wItemLength
    8'h2c: data <= 8'h00;  //WORD (Hi) wItemLength

// ====================================
// =====   Endpoint 1 Descriptor  =====
// ====================================
    8'h2d: data <= 8'h07;  //BYTE bLength (Endpoint Descriptor)
    8'h2e: data <= 8'h05;  //BYTE bDescriptorType; assigned by USB
    8'h2f: data <= 8'h81;  //BYTE bEndpointAddress; IN endpoint; endpoint 1
    8'h30: data <= 8'h03;  //BYTE bmAttributes; Interrupt endpoint
    8'h31: data <= 8'h10;  //WORD (Lo) wMaxPacketSize
    8'h32: data <= 8'h00;  //WORD (Hi) wMaxPacketSize
    8'h33: data <= 8'hFF;  //BYTE bInterval

 
// ====================================
// =====   Report Descriptor  =====
// ====================================

    8'h3a: data <= 8'h05;     8'h3b: data <= 8'h01;    // USAGE_PAGE (Generic Desktop)
    8'h3c: data <= 8'h09;     8'h3d: data <= 8'h02;    // USAGE (Mouse)
    8'h3e: data <= 8'ha1;     8'h3f: data <= 8'h01;    // COLLECTION (Application)
    8'h40: data <= 8'h09;     8'h41: data <= 8'h01;    //   USAGE (Pointer)
    8'h42: data <= 8'ha1;     8'h43: data <= 8'h00;    //   COLLECTION (Physical)
    8'h44: data <= 8'h05;     8'h45: data <= 8'h09;    //     USAGE_PAGE (Button)
    8'h46: data <= 8'h19;     8'h47: data <= 8'h01;    //     USAGE_MINIMUM (Button 1)
    8'h48: data <= 8'h29;     8'h49: data <= 8'h03;    //     USAGE_MAXIMUM (Button 3)
    8'h4a: data <= 8'h15;     8'h4b: data <= 8'h00;    //     LOGICAL_MINIMUM (0)
    8'h4c: data <= 8'h25;     8'h4d: data <= 8'h01;    //     LOGICAL_MAXIMUM (1)
    8'h4e: data <= 8'h95;     8'h4f: data <= 8'h03;    //     REPORT_COUNT (3)
    8'h50: data <= 8'h75;     8'h51: data <= 8'h01;    //     REPORT_SIZE (1)
    8'h52: data <= 8'h81;     8'h53: data <= 8'h02;    //     INPUT (Data,Var,Abs)
    8'h54: data <= 8'h95;     8'h55: data <= 8'h01;    //     REPORT_COUNT (1)
    8'h56: data <= 8'h75;     8'h57: data <= 8'h05;    //     REPORT_SIZE (5)
    8'h58: data <= 8'h81;     8'h59: data <= 8'h01;    //     INPUT (Cnst,Var,Rel)
    8'h5a: data <= 8'h05;     8'h5b: data <= 8'h01;    //     USAGE_PAGE (Generic Desktop)
    8'h5c: data <= 8'h09;     8'h5d: data <= 8'h30;    //     USAGE (X)
    8'h5e: data <= 8'h09;     8'h5f: data <= 8'h31;    //     USAGE (Y)
    8'h60: data <= 8'h15;     8'h61: data <= 8'h81;    //     LOGICAL_MINIMUM (-127)
    8'h62: data <= 8'h25;     8'h63: data <= 8'h7f;    //     LOGICAL_MAXIMUM (127)
    8'h64: data <= 8'h75;     8'h65: data <= 8'h08;    //     REPORT_SIZE (8)
    8'h66: data <= 8'h95;     8'h67: data <= 8'h02;    //     REPORT_COUNT (2)
    8'h68: data <= 8'h81;     8'h69: data <= 8'h06;    //     INPUT (Data,Var,Rel)
    8'h6a: data <= 8'hc0;                              //END_COLLECTION
    8'h6b: data <= 8'hc0;                              // END_COLLECTION

// ZERO_ZERO
    8'h6c: data <= 8'h00; 
    8'h6d: data <= 8'h00; 
// ONE_ZERO
    8'h6e: data <= 8'h01; 
    8'h6f: data <= 8'h00; 
// Vendor data
    8'h70: data <= 8'h00; 
    8'h71: data <= 8'h00; 

// =============================================
// =====   Language ID Descriptor(String0) =====
// =============================================
    8'h80: data <= 8'h04;  // bLength
    8'h81: data <= 8'h03;  // bDescriptorType = String Desc
    8'h82: data <= 8'h09;  // wLangID (Lo) (Lang ID for English = 0x0409)
    8'h83: data <= 8'h04;  // wLangID (Hi) (Lang ID for English = 0x0409)

// ====================================
// =====   string 1 Descriptor  =====
// ====================================
    8'h90: data <= 8'd26;  	// bLength
    8'h91: data <= 8'h03;     // bDescriptorType = String Desc
	// Noting that text is always unicode, hence the 'padding'
    8'h92: data <= "B";  8'h93: data <= 8'h00;
    8'h94: data <= "a";  8'h95: data <= 8'h00;
    8'h96: data <= "s";  8'h97: data <= 8'h00;
    8'h98: data <= "e";  8'h99: data <= 8'h00;
    8'h9a: data <= "2";  8'h9b: data <= 8'h00;
    8'h9c: data <= "D";  8'h9d: data <= 8'h00;
    8'h9e: data <= "e";  8'h9f: data <= 8'h00;
    8'ha0: data <= "s";  8'ha1: data <= 8'h00;
    8'ha2: data <= "i";  8'ha3: data <= 8'h00;
    8'ha4: data <= "g";  8'ha5: data <= 8'h00;
    8'ha6: data <= "n";  8'ha7: data <= 8'h00;
    8'ha8: data <= "s";  8'ha9: data <= 8'h00;



// ====================================
// =====   string 2 Descriptor  =====
// ====================================
	 8'hb0: data <= 8'd20;   // bLength
    8'hb1: data <= 8'h03;   // bDescriptorType = String Desc
	// Noting that text is always unicode, hence the 'padding'
    8'hb2: data <= "B";  8'hb3: data <= 8'h00;
    8'hb4: data <= "2";  8'hb5: data <= 8'h00;
    8'hb6: data <= "D";  8'hb7: data <= 8'h00;
    8'hb8: data <= " ";  8'hb9: data <= 8'h00;
    8'hba: data <= "M";  8'hbb: data <= 8'h00;
    8'hbc: data <= "o";  8'hbd: data <= 8'h00;
    8'hbe: data <= "u";  8'hbf: data <= 8'h00;
    8'hc0: data <= "s";  8'hc1: data <= 8'h00;
    8'hc2: data <= "e";  8'hc3: data <= 8'h00;

// ====================================
// =====   string 3 Descriptor  =====
// ====================================
	 8'hd0: data <= 8'd30;   // bLength
    8'hd1: data <= 8'h03;   // bDescriptorType = String Desc
	// Noting that text is always unicode, hence the 'padding'
    8'hd2: data <= "L";  8'hd3: data <= 8'h00;
    8'hd4: data <= "i";  8'hd5: data <= 8'h00;
    8'hd6: data <= "m";  8'hd7: data <= 8'h00;
    8'hd8: data <= "i";  8'hd9: data <= 8'h00;
    8'hda: data <= "t";  8'hdb: data <= 8'h00;
    8'hdc: data <= "e";  8'hdd: data <= 8'h00;
    8'hde: data <= "d";  8'hdf: data <= 8'h00;
    8'he0: data <= "E";  8'he1: data <= 8'h00;
    8'he2: data <= "d";  8'he3: data <= 8'h00;
    8'he4: data <= "i";  8'he5: data <= 8'h00;
    8'he6: data <= "t";  8'he7: data <= 8'h00;
    8'he8: data <= "i";  8'he9: data <= 8'h00;
    8'hea: data <= "o";  8'heb: data <= 8'h00;
    8'hec: data <= "n";  8'hed: data <= 8'h00;



    default: data <= 8'h00;
  endcase
end

endmodule


 
