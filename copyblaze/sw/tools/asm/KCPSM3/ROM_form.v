////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2004 Xilinx, Inc.
// All Rights Reserved
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: 1.02
//  \   \         Filename: ROM_form.v
//  /   /         Date Last Modified:  September 7 2004
// /___/   /\     Date Created: July 2003
// \   \  /  \
//  \___\/\___\
//
//Device:  	Xilinx
//Purpose: 	
//	This is the Verilog template file for the KCPSM3 assembler.
//	It is used to configure a Spartan-3, Virtex-II or Virtex-IIPRO block 
//	RAM to act as a single port program ROM.
//
//	This Verilog file is not valid as input directly into a synthesis or 
//	simulation tool.	The assembler will read this template and insert the 
//	data required to complete the definition of program ROM and write it out 
//	to a new '.v' file associated with the name of the original '.psm' file 
//	being assembled.
//
//	This template can be modified to define alternative memory definitions 
//	such as dual port.  However, you are responsible for ensuring the template
//	is correct as the assembler does not perform any checking of the Verilog.
//
//	The assembler identifies all text enclosed by {} characters, and replaces 
//	these character strings. All templates should include these {} character 
//	strings for the assembler to work correctly. 
//
//	This template defines a block RAM configured in 1024 x 18-bit single port 
//	mode and conneceted to act as a single port ROM.
//
//Reference:
// 	None
//Revision History:
//    Rev 1.00 - jc - Converted to verilog,  July 2003.
//    Rev 1.01 - sus - Added text to confirm to Xilinx HDL std,  August 4 2004.
//    Rev 1.02 - njs - Added attributes for Synplicity  August 5 2004.
//	Rev 1.03 - sus - Added text to conform to Xilinx generated 
//				HDL spec, September 7 2004
//
////////////////////////////////////////////////////////////////////////////////
// Contact: e-mail  picoblaze@xilinx.com
//////////////////////////////////////////////////////////////////////////////////
//
// Disclaimer: 
// LIMITED WARRANTY AND DISCLAIMER. These designs are
// provided to you "as is". Xilinx and its licensors make and you
// receive no warranties or conditions, express, implied,
// statutory or otherwise, and Xilinx specifically disclaims any
// implied warranties of merchantability, non-infringement, or
// fitness for a particular purpose. Xilinx does not warrant that
// the functions contained in these designs will meet your
// requirements, or that the operation of these designs will be
// uninterrupted or error free, or that defects in the Designs
// will be corrected. Furthermore, Xilinx does not warrant or
// make any representations regarding use or the results of the
// use of the designs in terms of correctness, accuracy,
// reliability, or otherwise.
//
// LIMITATION OF LIABILITY. In no event will Xilinx or its
// licensors be liable for any loss of data, lost profits, cost
// or procurement of substitute goods or services, or for any
// special, incidental, consequential, or indirect damages
// arising from the use or operation of the designs or
// accompanying documentation, however caused and on any theory
// of liability. This limitation will apply even if Xilinx
// has been advised of the possibility of such damage. This
// limitation shall apply not-withstanding the failure of the 
// essential purpose of any limited remedies herein. 
//////////////////////////////////////////////////////////////////////////////////

The next line is used to determine where the template actually starts and must exist.
{begin template}
////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2004 Xilinx, Inc.
// All Rights Reserved
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: v1.30
//  \   \         Application : KCPSM3
//  /   /         Filename: {name}.v
// /___/   /\     
// \   \  /  \
//  \___\/\___\
//
//Command: kcpsm3 {name}.psm
//Device: Spartan-3, Spartan-3E, Virtex-II, and Virtex-II Pro FPGAs
//Design Name: {name}
//Generated {timestamp}.
//Purpose:
//	{name} verilog program definition.
//
//Reference:
//	PicoBlaze 8-bit Embedded Microcontroller User Guide
////////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1ps

module {name} (address, instruction, clk);

input [9:0] address;
input clk;

output [17:0] instruction;

RAMB16_S18 ram_1024_x_18(
	.DI 	(16'h0000),
	.DIP 	(2'b00),
	.EN	(1'b1),
	.WE	(1'b0),
	.SSR	(1'b0),
	.CLK	(clk),
	.ADDR	(address),
	.DO	(instruction[15:0]),
	.DOP	(instruction[17:16]))
/*synthesis 
init_00 = "{INIT_00}" 
init_01 = "{INIT_01}" 
init_02 = "{INIT_02}" 
init_03 = "{INIT_03}" 
init_04 = "{INIT_04}" 
init_05 = "{INIT_05}" 
init_06 = "{INIT_06}" 
init_07 = "{INIT_07}" 
init_08 = "{INIT_08}" 
init_09 = "{INIT_09}" 
init_0A = "{INIT_0A}" 
init_0B = "{INIT_0B}" 
init_0C = "{INIT_0C}" 
init_0D = "{INIT_0D}" 
init_0E = "{INIT_0E}" 
init_0F = "{INIT_0F}" 
init_10 = "{INIT_10}" 
init_11 = "{INIT_11}" 
init_12 = "{INIT_12}" 
init_13 = "{INIT_13}" 
init_14 = "{INIT_14}" 
init_15 = "{INIT_15}" 
init_16 = "{INIT_16}" 
init_17 = "{INIT_17}" 
init_18 = "{INIT_18}" 
init_19 = "{INIT_19}" 
init_1A = "{INIT_1A}" 
init_1B = "{INIT_1B}" 
init_1C = "{INIT_1C}" 
init_1D = "{INIT_1D}" 
init_1E = "{INIT_1E}" 
init_1F = "{INIT_1F}" 
init_20 = "{INIT_20}" 
init_21 = "{INIT_21}" 
init_22 = "{INIT_22}" 
init_23 = "{INIT_23}" 
init_24 = "{INIT_24}" 
init_25 = "{INIT_25}" 
init_26 = "{INIT_26}" 
init_27 = "{INIT_27}" 
init_28 = "{INIT_28}" 
init_29 = "{INIT_29}" 
init_2A = "{INIT_2A}" 
init_2B = "{INIT_2B}" 
init_2C = "{INIT_2C}" 
init_2D = "{INIT_2D}" 
init_2E = "{INIT_2E}" 
init_2F = "{INIT_2F}" 
init_30 = "{INIT_30}" 
init_31 = "{INIT_31}" 
init_32 = "{INIT_32}" 
init_33 = "{INIT_33}" 
init_34 = "{INIT_34}" 
init_35 = "{INIT_35}" 
init_36 = "{INIT_36}" 
init_37 = "{INIT_37}" 
init_38 = "{INIT_38}" 
init_39 = "{INIT_39}" 
init_3A = "{INIT_3A}" 
init_3B = "{INIT_3B}" 
init_3C = "{INIT_3C}" 
init_3D = "{INIT_3D}" 
init_3E = "{INIT_3E}" 
init_3F = "{INIT_3F}" 
initp_00 = "{INITP_00}" 
initp_01 = "{INITP_01}" 
initp_02 = "{INITP_02}" 
initp_03 = "{INITP_03}" 
initp_04 = "{INITP_04}" 
initp_05 = "{INITP_05}" 
initp_06 = "{INITP_06}" 
initp_07 = "{INITP_07}" */;

// synthesis translate_off
// Attributes for Simulation
defparam ram_1024_x_18.INIT_00  = 256'h{INIT_00};
defparam ram_1024_x_18.INIT_01  = 256'h{INIT_01};
defparam ram_1024_x_18.INIT_02  = 256'h{INIT_02};
defparam ram_1024_x_18.INIT_03  = 256'h{INIT_03};
defparam ram_1024_x_18.INIT_04  = 256'h{INIT_04};
defparam ram_1024_x_18.INIT_05  = 256'h{INIT_05};
defparam ram_1024_x_18.INIT_06  = 256'h{INIT_06};
defparam ram_1024_x_18.INIT_07  = 256'h{INIT_07};
defparam ram_1024_x_18.INIT_08  = 256'h{INIT_08};
defparam ram_1024_x_18.INIT_09  = 256'h{INIT_09};
defparam ram_1024_x_18.INIT_0A  = 256'h{INIT_0A};
defparam ram_1024_x_18.INIT_0B  = 256'h{INIT_0B};
defparam ram_1024_x_18.INIT_0C  = 256'h{INIT_0C};
defparam ram_1024_x_18.INIT_0D  = 256'h{INIT_0D};
defparam ram_1024_x_18.INIT_0E  = 256'h{INIT_0E};
defparam ram_1024_x_18.INIT_0F  = 256'h{INIT_0F};
defparam ram_1024_x_18.INIT_10  = 256'h{INIT_10};
defparam ram_1024_x_18.INIT_11  = 256'h{INIT_11};
defparam ram_1024_x_18.INIT_12  = 256'h{INIT_12};
defparam ram_1024_x_18.INIT_13  = 256'h{INIT_13};
defparam ram_1024_x_18.INIT_14  = 256'h{INIT_14};
defparam ram_1024_x_18.INIT_15  = 256'h{INIT_15};
defparam ram_1024_x_18.INIT_16  = 256'h{INIT_16};
defparam ram_1024_x_18.INIT_17  = 256'h{INIT_17};
defparam ram_1024_x_18.INIT_18  = 256'h{INIT_18};
defparam ram_1024_x_18.INIT_19  = 256'h{INIT_19};
defparam ram_1024_x_18.INIT_1A  = 256'h{INIT_1A};
defparam ram_1024_x_18.INIT_1B  = 256'h{INIT_1B};
defparam ram_1024_x_18.INIT_1C  = 256'h{INIT_1C};
defparam ram_1024_x_18.INIT_1D  = 256'h{INIT_1D};
defparam ram_1024_x_18.INIT_1E  = 256'h{INIT_1E};
defparam ram_1024_x_18.INIT_1F  = 256'h{INIT_1F};
defparam ram_1024_x_18.INIT_20  = 256'h{INIT_20};
defparam ram_1024_x_18.INIT_21  = 256'h{INIT_21};
defparam ram_1024_x_18.INIT_22  = 256'h{INIT_22};
defparam ram_1024_x_18.INIT_23  = 256'h{INIT_23};
defparam ram_1024_x_18.INIT_24  = 256'h{INIT_24};
defparam ram_1024_x_18.INIT_25  = 256'h{INIT_25};
defparam ram_1024_x_18.INIT_26  = 256'h{INIT_26};
defparam ram_1024_x_18.INIT_27  = 256'h{INIT_27};
defparam ram_1024_x_18.INIT_28  = 256'h{INIT_28};
defparam ram_1024_x_18.INIT_29  = 256'h{INIT_29};
defparam ram_1024_x_18.INIT_2A  = 256'h{INIT_2A};
defparam ram_1024_x_18.INIT_2B  = 256'h{INIT_2B};
defparam ram_1024_x_18.INIT_2C  = 256'h{INIT_2C};
defparam ram_1024_x_18.INIT_2D  = 256'h{INIT_2D};
defparam ram_1024_x_18.INIT_2E  = 256'h{INIT_2E};
defparam ram_1024_x_18.INIT_2F  = 256'h{INIT_2F};
defparam ram_1024_x_18.INIT_30  = 256'h{INIT_30};
defparam ram_1024_x_18.INIT_31  = 256'h{INIT_31};
defparam ram_1024_x_18.INIT_32  = 256'h{INIT_32};
defparam ram_1024_x_18.INIT_33  = 256'h{INIT_33};
defparam ram_1024_x_18.INIT_34  = 256'h{INIT_34};
defparam ram_1024_x_18.INIT_35  = 256'h{INIT_35};
defparam ram_1024_x_18.INIT_36  = 256'h{INIT_36};
defparam ram_1024_x_18.INIT_37  = 256'h{INIT_37};
defparam ram_1024_x_18.INIT_38  = 256'h{INIT_38};
defparam ram_1024_x_18.INIT_39  = 256'h{INIT_39};
defparam ram_1024_x_18.INIT_3A  = 256'h{INIT_3A};
defparam ram_1024_x_18.INIT_3B  = 256'h{INIT_3B};
defparam ram_1024_x_18.INIT_3C  = 256'h{INIT_3C};
defparam ram_1024_x_18.INIT_3D  = 256'h{INIT_3D};
defparam ram_1024_x_18.INIT_3E  = 256'h{INIT_3E};
defparam ram_1024_x_18.INIT_3F  = 256'h{INIT_3F};
defparam ram_1024_x_18.INITP_00 = 256'h{INITP_00};
defparam ram_1024_x_18.INITP_01 = 256'h{INITP_01};
defparam ram_1024_x_18.INITP_02 = 256'h{INITP_02};
defparam ram_1024_x_18.INITP_03 = 256'h{INITP_03};
defparam ram_1024_x_18.INITP_04 = 256'h{INITP_04};
defparam ram_1024_x_18.INITP_05 = 256'h{INITP_05};
defparam ram_1024_x_18.INITP_06 = 256'h{INITP_06};
defparam ram_1024_x_18.INITP_07 = 256'h{INITP_07};

// synthesis translate_on
// Attributes for XST (Synplicity attributes are in-line)
// synthesis attribute INIT_00  of ram_1024_x_18 is "{INIT_00}"
// synthesis attribute INIT_01  of ram_1024_x_18 is "{INIT_01}"
// synthesis attribute INIT_02  of ram_1024_x_18 is "{INIT_02}"
// synthesis attribute INIT_03  of ram_1024_x_18 is "{INIT_03}"
// synthesis attribute INIT_04  of ram_1024_x_18 is "{INIT_04}"
// synthesis attribute INIT_05  of ram_1024_x_18 is "{INIT_05}"
// synthesis attribute INIT_06  of ram_1024_x_18 is "{INIT_06}"
// synthesis attribute INIT_07  of ram_1024_x_18 is "{INIT_07}"
// synthesis attribute INIT_08  of ram_1024_x_18 is "{INIT_08}"
// synthesis attribute INIT_09  of ram_1024_x_18 is "{INIT_09}"
// synthesis attribute INIT_0A  of ram_1024_x_18 is "{INIT_0A}"
// synthesis attribute INIT_0B  of ram_1024_x_18 is "{INIT_0B}"
// synthesis attribute INIT_0C  of ram_1024_x_18 is "{INIT_0C}"
// synthesis attribute INIT_0D  of ram_1024_x_18 is "{INIT_0D}"
// synthesis attribute INIT_0E  of ram_1024_x_18 is "{INIT_0E}"
// synthesis attribute INIT_0F  of ram_1024_x_18 is "{INIT_0F}"
// synthesis attribute INIT_10  of ram_1024_x_18 is "{INIT_10}"
// synthesis attribute INIT_11  of ram_1024_x_18 is "{INIT_11}"
// synthesis attribute INIT_12  of ram_1024_x_18 is "{INIT_12}"
// synthesis attribute INIT_13  of ram_1024_x_18 is "{INIT_13}"
// synthesis attribute INIT_14  of ram_1024_x_18 is "{INIT_14}"
// synthesis attribute INIT_15  of ram_1024_x_18 is "{INIT_15}"
// synthesis attribute INIT_16  of ram_1024_x_18 is "{INIT_16}"
// synthesis attribute INIT_17  of ram_1024_x_18 is "{INIT_17}"
// synthesis attribute INIT_18  of ram_1024_x_18 is "{INIT_18}"
// synthesis attribute INIT_19  of ram_1024_x_18 is "{INIT_19}"
// synthesis attribute INIT_1A  of ram_1024_x_18 is "{INIT_1A}"
// synthesis attribute INIT_1B  of ram_1024_x_18 is "{INIT_1B}"
// synthesis attribute INIT_1C  of ram_1024_x_18 is "{INIT_1C}"
// synthesis attribute INIT_1D  of ram_1024_x_18 is "{INIT_1D}"
// synthesis attribute INIT_1E  of ram_1024_x_18 is "{INIT_1E}"
// synthesis attribute INIT_1F  of ram_1024_x_18 is "{INIT_1F}"
// synthesis attribute INIT_20  of ram_1024_x_18 is "{INIT_20}"
// synthesis attribute INIT_21  of ram_1024_x_18 is "{INIT_21}"
// synthesis attribute INIT_22  of ram_1024_x_18 is "{INIT_22}"
// synthesis attribute INIT_23  of ram_1024_x_18 is "{INIT_23}"
// synthesis attribute INIT_24  of ram_1024_x_18 is "{INIT_24}"
// synthesis attribute INIT_25  of ram_1024_x_18 is "{INIT_25}"
// synthesis attribute INIT_26  of ram_1024_x_18 is "{INIT_26}"
// synthesis attribute INIT_27  of ram_1024_x_18 is "{INIT_27}"
// synthesis attribute INIT_28  of ram_1024_x_18 is "{INIT_28}"
// synthesis attribute INIT_29  of ram_1024_x_18 is "{INIT_29}"
// synthesis attribute INIT_2A  of ram_1024_x_18 is "{INIT_2A}"
// synthesis attribute INIT_2B  of ram_1024_x_18 is "{INIT_2B}"
// synthesis attribute INIT_2C  of ram_1024_x_18 is "{INIT_2C}"
// synthesis attribute INIT_2D  of ram_1024_x_18 is "{INIT_2D}"
// synthesis attribute INIT_2E  of ram_1024_x_18 is "{INIT_2E}"
// synthesis attribute INIT_2F  of ram_1024_x_18 is "{INIT_2F}"
// synthesis attribute INIT_30  of ram_1024_x_18 is "{INIT_30}"
// synthesis attribute INIT_31  of ram_1024_x_18 is "{INIT_31}"
// synthesis attribute INIT_32  of ram_1024_x_18 is "{INIT_32}"
// synthesis attribute INIT_33  of ram_1024_x_18 is "{INIT_33}"
// synthesis attribute INIT_34  of ram_1024_x_18 is "{INIT_34}"
// synthesis attribute INIT_35  of ram_1024_x_18 is "{INIT_35}"
// synthesis attribute INIT_36  of ram_1024_x_18 is "{INIT_36}"
// synthesis attribute INIT_37  of ram_1024_x_18 is "{INIT_37}"
// synthesis attribute INIT_38  of ram_1024_x_18 is "{INIT_38}"
// synthesis attribute INIT_39  of ram_1024_x_18 is "{INIT_39}"
// synthesis attribute INIT_3A  of ram_1024_x_18 is "{INIT_3A}"
// synthesis attribute INIT_3B  of ram_1024_x_18 is "{INIT_3B}"
// synthesis attribute INIT_3C  of ram_1024_x_18 is "{INIT_3C}"
// synthesis attribute INIT_3D  of ram_1024_x_18 is "{INIT_3D}"
// synthesis attribute INIT_3E  of ram_1024_x_18 is "{INIT_3E}"
// synthesis attribute INIT_3F  of ram_1024_x_18 is "{INIT_3F}"
// synthesis attribute INITP_00 of ram_1024_x_18 is "{INITP_00}"
// synthesis attribute INITP_01 of ram_1024_x_18 is "{INITP_01}"
// synthesis attribute INITP_02 of ram_1024_x_18 is "{INITP_02}"
// synthesis attribute INITP_03 of ram_1024_x_18 is "{INITP_03}"
// synthesis attribute INITP_04 of ram_1024_x_18 is "{INITP_04}"
// synthesis attribute INITP_05 of ram_1024_x_18 is "{INITP_05}"
// synthesis attribute INITP_06 of ram_1024_x_18 is "{INITP_06}"
// synthesis attribute INITP_07 of ram_1024_x_18 is "{INITP_07}"

endmodule

// END OF FILE {name}.v