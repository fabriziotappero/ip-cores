

`define ONE (32'h1 << `SCALE)

`timescale 1ns / 1ps
`include "aDefinitions.v"
/**********************************************************************************
Theia, Ray Cast Programable graphic Processing Unit.
Copyright (C) 2010  Diego Valverde (diego.valverde.g@gmail.com)

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

***********************************************************************************/

/*
I can't synthesize roms, the rom needs to be adapted depending on the 
final target silicon.
*/


//--------------------------------------------------------
module ROM
(
	input  wire[`ROM_ADDRESS_WIDTH-1:0]  		Address,
	`ifdef DEBUG
	input wire [`MAX_CORES-1:0]            iDebug_CoreID,
	`endif
	output reg [`INSTRUCTION_WIDTH-1:0] 		I
);	


always @( Address )
begin
			case (Address)
			
//Hardcoded stuff :(
`define RAY_INSIDE_BOX				`R3
`define CURRENT_LIGHT_POS `CREG_FIRST_LIGTH  //TODO: CAHNEG T 
`define CURRENT_LIGHT_DIFFUSE 16'h6

//-----------------------------------------------------------------
`define TAG_PIXELSHADER 16'd278
`define TAG_USERCONSTANTS 16'd276
`define TAG_PSU_UCODE_ADRESS2 16'd248
`define TAG_PSU_UCODE_ADRESS 16'd232
`define LABEL_TCC_EXIT 16'd231
`define TAG_TCC_UCODE_ADDRESS 16'd190
`define LABEL_BIU4 16'd189
`define LABEL_BIU3 16'd179
`define LABEL_BIU2 16'd176
`define LABEL_BIU1 16'd174
`define TAG_BIU_UCODE_ADDRESS 16'd157
`define LABEL_HIT 16'd155
`define LABEL15 16'd153
`define LABEL14 16'd151
`define LABEL13 16'd149
`define LABEL_TEST_XY_PLANE 16'd144
`define LABEL12 16'd142
`define LABEL11 16'd140
`define LABEL10 16'd138
`define LABEL_TEST_XZ_PLANE 16'd132
`define LABEL9 16'd130
`define LABEL8 16'd128
`define LABEL7 16'd126
`define LABEL_TEST_YZ_PLANE 16'd120
`define LABEL_RAY_INSIDE_BOX 16'd117
`define LABEL_ELSEZ 16'd116
`define LABEL6 16'd113
`define LABEL_ELESE_IFZ 16'd109
`define LABEL5 16'd106
`define LABEL_TEST_RAY_Z_ORIGEN 16'd102
`define LABEL_ELSEY 16'd101
`define LABEL4 16'd98
`define LABEL_ELESE_IFY 16'd94
`define LABEL3 16'd91
`define LABEL_TEST_RAY_Y_ORIGEN 16'd87
`define LABEL_ELSEX 16'd86
`define LABEL2 16'd83
`define LABEL_ELSE_IFX 16'd79
`define LABEL1 16'd76
`define LABEL_TEST_RAY_X_ORIGEN 16'd72
`define TAG_AABBIU_UCODE_ADDRESS 16'd69
`define LABEL_ALLDONE 16'd67
`define LABEL_NPG_NEXT_ROW 16'd63
`define TAG_NPG_UCODE_ADDRESS 16'd55
`define TAG_RGU_UCODE_ADDRESS 16'd47
`define TAG_CPPU_UCODE_ADDRESS 16'd44
`define LABEL_IS_NO_HIT 16'd43
`define LABEL_IS_HIT 16'd39
`define TAG_ADRR_MAIN 16'd37


//-------------------------------------------------------------------------
//Default values for some registers after reset
//-------------------------------------------------------------------------
//This is the first code that gets executed after the machine is
//externally configured ie after the MST_I goes from 1 to zero.
//It sets initial values for some of the internal registers

0: I = { `ZERO ,`CREG_LAST_t ,`VOID ,`VOID }; 
//Set the last 't' to very positive value(500) 
1: I = { `SETX ,`CREG_LAST_t ,32'h1F40000  }; 
2: I = { `ZERO ,`OREG_PIXEL_COLOR ,`VOID ,`VOID }; 
3: I = { `COPY ,`CREG_PIXEL_2D_POSITION ,`CREG_PIXEL_2D_INITIAL_POSITION ,`VOID }; 


//Calculate the initial linear address for ADR_O
//this is: (X_initial + RESOLUTION_Y*Y_intial) * 3.
//Notice that we need to use 'unscaled' ie. integer
//values because the resuts of the multiplication by
//the resoluction is to large to fit a fixed point 
//representation.

4: I = { `COPY ,`R1 ,`CREG_RESOLUTION ,`VOID }; 
5: I = { `UNSCALE ,`R1 ,`R1 ,`VOID }; 
6: I = { `SETX ,`R1 ,32'h1  }; 
7: I = { `SETZ ,`R1 ,32'h0  }; 
8: I = { `COPY ,`R2 ,`CREG_PIXEL_2D_INITIAL_POSITION ,`VOID }; 
9: I = { `UNSCALE ,`R2 ,`R2 ,`VOID }; 

//Ok lets start by calculating RESOLUTION_Y*Y_intial
10: I = { `IMUL ,`R1 ,`R1 ,`R2 }; 
11: I = { `COPY ,`R2 ,`R1 ,`VOID }; 
12: I = { `SWIZZLE3D ,`R2 ,`SWIZZLE_YYY  }; 

//now X_initial + RESOLUTION_Y*Y_intial
13: I = { `ADD ,`R3 ,`R1 ,`R2 }; 
14: I = { `COPY ,`R2 ,`R1 ,`VOID }; 
15: I = { `SWIZZLE3D ,`R2 ,`SWIZZLE_ZZZ  }; 
16: I = { `ADD ,`R3 ,`R3 ,`R2 }; 
17: I = { `SWIZZLE3D ,`R3 ,`SWIZZLE_XXX  }; 

//finally multiply by 3 to get:
//(X_initial + RESOLUTION_Y*Y_intial) * 3 voila!
18: I = { `SETX ,`R2 ,32'h3  }; 
19: I = { `SWIZZLE3D ,`R2 ,`SWIZZLE_XXX  }; 
20: I = { `IMUL ,`CREG_PIXEL_PITCH ,`R3 ,`R2 }; 

//By this point you should be wondering why not
//just do DOT R1 [1 Resolution_Y 0] [X_intial Y_intial 0 ]?
//well because DOT uses fixed point and the result may not
//fit :(

//Transform from fixed point to integer
//UNSCALE CREG_PIXEL_PITCH CREG_PIXEL_PITCH VOID
21: I = { `COPY ,`OREG_ADDR_O ,`CREG_PIXEL_PITCH ,`VOID }; 

22: I = { `SETX ,`CREG_3 ,32'h3  }; 
23: I = { `SWIZZLE3D ,`CREG_3 ,`SWIZZLE_XXX  }; 

24: I = { `SETX ,`CREG_012 ,32'h0  }; 
25: I = { `SETY ,`CREG_012 ,32'h1  }; 
26: I = { `SETZ ,`CREG_012 ,32'h2  }; 
27: I = { `COPY ,`CREG_CURRENT_OUTPUT_PIXEL ,`CREG_012 ,`VOID }; 
28: I = { `ZERO ,`CREG_TEXTURE_COLOR ,`VOID ,`VOID }; 
29: I = { `ZERO ,`CREG_ZERO ,`VOID ,`VOID }; 

30: I = { `ZERO ,`R1 ,`VOID ,`VOID }; 
31: I = { `ZERO ,`R2 ,`VOID ,`VOID }; 
32: I = { `ZERO ,`R3 ,`VOID ,`VOID }; 
33: I = { `ZERO ,`R4 ,`VOID ,`VOID }; 
34: I = { `ZERO ,`R5 ,`VOID ,`VOID }; 
35: I = { `ZERO ,`R99 ,`VOID ,`VOID }; 
36: I = { `RETURN ,`RT_TRUE   }; 

//----------------------------------------------
//TAG_ADRR_MAIN:

37: I = { `CALL ,`ENTRYPOINT_ADRR_BIU ,`VOID ,`VOID }; 
38: I = { `JEQX ,`LABEL_IS_NO_HIT ,`R99 ,`CREG_ZERO }; 

//LABEL_IS_HIT:
39: I = { `CALL ,`ENTRYPOINT_ADRR_TCC ,`VOID ,`VOID }; 
40: I = { `NOP ,`RT_FALSE   }; 
41: I = { `RETURN ,`RT_TRUE   }; 
42: I = { `NOP ,`RT_FALSE   }; 

//LABEL_IS_NO_HIT:
43: I = { `RETURN ,`RT_FALSE   }; 


//----------------------------------------------------------------------	  
//Micro code for CPPU
//TAG_CPPU_UCODE_ADDRESS:


44: I = { `SUB ,`R1 ,`CREG_PROJECTION_WINDOW_MAX ,`CREG_PROJECTION_WINDOW_MIN }; 
45: I = { `DIV ,`CREG_PROJECTION_WINDOW_SCALE ,`R1 ,`CREG_RESOLUTION }; 
46: I = { `RETURN ,`RT_FALSE   }; 

//----------------------------------------------------------------------	  
//Micro code for RGU
//TAG_RGU_UCODE_ADDRESS:


47: I = { `MUL ,`R1 ,`CREG_PIXEL_2D_POSITION ,`CREG_PROJECTION_WINDOW_SCALE }; 
48: I = { `ADD ,`R1 ,`R1 ,`CREG_PROJECTION_WINDOW_MIN }; 
49: I = { `SUB ,`CREG_UNORMALIZED_DIRECTION ,`R1 ,`CREG_CAMERA_POSITION }; 
50: I = { `MAG ,`R2 ,`CREG_UNORMALIZED_DIRECTION ,`VOID }; 
51: I = { `DIV ,`CREG_RAY_DIRECTION ,`CREG_UNORMALIZED_DIRECTION ,`R2 }; 
52: I = { `DEC ,`CREG_LAST_COL ,`CREG_PIXEL_2D_FINAL_POSITION ,`VOID }; 
53: I = { `SETX ,`CREG_LAST_t ,32'h1F40000  }; 
  
54: I = { `RETURN ,`RT_FALSE   }; 
//----------------------------------------------------------------------
//Next Pixel generation Code (NPG)
//TAG_NPG_UCODE_ADDRESS:

55: I = { `ZERO ,`CREG_TEXTURE_COLOR ,`VOID ,`VOID }; 
56: I = { `SETX ,`CREG_TEXTURE_COLOR ,32'h60000  }; 
57: I = { `ADD ,`CREG_CURRENT_OUTPUT_PIXEL ,`CREG_CURRENT_OUTPUT_PIXEL ,`CREG_3 }; 

58: I = { `ADD ,`CREG_PIXEL_PITCH ,`CREG_PIXEL_PITCH ,`CREG_3 }; 
59: I = { `COPY ,`OREG_ADDR_O ,`CREG_PIXEL_PITCH ,`VOID }; 
60: I = { `JGEX ,`LABEL_NPG_NEXT_ROW ,`CREG_PIXEL_2D_POSITION ,`CREG_LAST_COL }; 
61: I = { `INCX ,`CREG_PIXEL_2D_POSITION ,`CREG_PIXEL_2D_POSITION ,`VOID }; 
62: I = { `RETURN ,`RT_TRUE   }; 

//LABEL_NPG_NEXT_ROW:
63: I = { `SETX ,`CREG_PIXEL_2D_POSITION ,32'h0  }; 
64: I = { `INCY ,`CREG_PIXEL_2D_POSITION ,`CREG_PIXEL_2D_POSITION ,`VOID }; 
65: I = { `JGEY ,`LABEL_ALLDONE ,`CREG_PIXEL_2D_POSITION ,`CREG_PIXEL_2D_FINAL_POSITION }; 
66: I = { `RETURN ,`RT_TRUE   }; 

//LABEL_ALLDONE:
67: I = { `NOP ,`VOID ,`VOID  }; 
68: I = { `RETURN ,`RT_FALSE   }; 

//----------------------------------------------------------------------
//Micro code for AABBIU
//TAG_AABBIU_UCODE_ADDRESS:
	  
69: I = { `ZERO ,`R3 ,`VOID ,`VOID }; 
70: I = { `SETX ,`CREG_LAST_t ,32'h1F40000  }; 
71: I = { `RETURN ,`RT_TRUE   }; 

//LABEL_TEST_RAY_X_ORIGEN:
72: I = { `JGEX ,`LABEL_ELSE_IFX ,`CREG_CAMERA_POSITION ,`CREG_AABBMIN }; 
73: I = { `SUB ,`R1 ,`CREG_AABBMIN ,`CREG_CAMERA_POSITION }; 
74: I = { `JLEX ,`LABEL1 ,`R1 ,`CREG_UNORMALIZED_DIRECTION }; 
75: I = { `RETURN ,`RT_FALSE   }; 

//LABEL1:
76: I = { `SETX ,`RAY_INSIDE_BOX ,32'd0  }; 
77: I = { `DIV ,`R6 ,`R1 ,`CREG_UNORMALIZED_DIRECTION }; 
78: I = { `JMP ,`LABEL_TEST_RAY_Y_ORIGEN ,`VOID ,`VOID }; 

//LABEL_ELSE_IFX:
79: I = { `JLEX ,`LABEL_ELSEX ,`CREG_CAMERA_POSITION ,`CREG_AABBMAX }; 
80: I = { `SUB ,`R1 ,`CREG_AABBMAX ,`CREG_CAMERA_POSITION }; 
81: I = { `JGEX ,`LABEL2 ,`R1 ,`CREG_UNORMALIZED_DIRECTION }; 
82: I = { `RETURN ,`RT_FALSE   }; 
 
//LABEL2:
83: I = { `SETX ,`RAY_INSIDE_BOX ,32'd0  }; 
84: I = { `DIV ,`R6 ,`R1 ,`CREG_UNORMALIZED_DIRECTION }; 
85: I = { `JMP ,`LABEL_TEST_RAY_Y_ORIGEN ,`VOID ,`VOID }; 
//LABEL_ELSEX:
86: I = { `SETX ,`R5 ,32'b1  }; 

//LABEL_TEST_RAY_Y_ORIGEN:
87: I = { `JGEY ,`LABEL_ELESE_IFY ,`CREG_CAMERA_POSITION ,`CREG_AABBMIN }; 
88: I = { `SUB ,`R1 ,`CREG_AABBMIN ,`CREG_CAMERA_POSITION }; 
89: I = { `JLEY ,`LABEL3 ,`R1 ,`CREG_UNORMALIZED_DIRECTION }; 
90: I = { `RETURN ,`RT_FALSE   }; 

//LABEL3:
91: I = { `SETX ,`RAY_INSIDE_BOX ,32'd0  }; 
92: I = { `DIV ,`R6 ,`R1 ,`CREG_UNORMALIZED_DIRECTION }; 
93: I = { `JMP ,`LABEL_TEST_RAY_Z_ORIGEN ,`VOID ,`VOID }; 

//LABEL_ELESE_IFY:
94: I = { `JLEY ,`LABEL_ELSEY ,`CREG_CAMERA_POSITION ,`CREG_AABBMAX }; 
95: I = { `SUB ,`R1 ,`CREG_AABBMAX ,`CREG_CAMERA_POSITION }; 
96: I = { `JGEY ,`LABEL4 ,`R1 ,`CREG_UNORMALIZED_DIRECTION }; 
97: I = { `RETURN ,`RT_FALSE   }; 

//LABEL4:
98: I = { `SETX ,`RAY_INSIDE_BOX ,32'd0  }; 
99: I = { `DIV ,`R6 ,`R1 ,`CREG_UNORMALIZED_DIRECTION }; 
100: I = { `JMP ,`LABEL_TEST_RAY_Z_ORIGEN ,`VOID ,`VOID }; 

//LABEL_ELSEY:
101: I = { `SETY ,`R5 ,32'b1  }; 

//LABEL_TEST_RAY_Z_ORIGEN:
102: I = { `JGEZ ,`LABEL_ELESE_IFZ ,`CREG_CAMERA_POSITION ,`CREG_AABBMIN }; 
103: I = { `SUB ,`R1 ,`CREG_AABBMIN ,`CREG_CAMERA_POSITION }; 
104: I = { `JLEZ ,`LABEL5 ,`R1 ,`CREG_UNORMALIZED_DIRECTION }; 
105: I = { `RETURN ,`RT_FALSE   }; 

//LABEL5:
106: I = { `SETX ,`RAY_INSIDE_BOX ,32'd0  }; 
107: I = { `DIV ,`R6 ,`R1 ,`CREG_UNORMALIZED_DIRECTION }; 
108: I = { `JMP ,`LABEL_RAY_INSIDE_BOX ,`VOID ,`VOID }; 

//LABEL_ELESE_IFZ:
109: I = { `JLEZ ,`LABEL_ELSEZ ,`CREG_CAMERA_POSITION ,`CREG_AABBMAX }; 
110: I = { `SUB ,`R1 ,`CREG_AABBMAX ,`CREG_CAMERA_POSITION }; 
111: I = { `JGEZ ,`LABEL6 ,`R1 ,`CREG_UNORMALIZED_DIRECTION }; 
112: I = { `RETURN ,`RT_FALSE   }; 

//LABEL6:
113: I = { `SETX ,`RAY_INSIDE_BOX ,32'd0  }; 
114: I = { `DIV ,`R6 ,`R1 ,`CREG_UNORMALIZED_DIRECTION }; 
115: I = { `JMP ,`LABEL_RAY_INSIDE_BOX ,`VOID ,`VOID }; 

//LABEL_ELSEZ:
116: I = { `SETZ ,`R5 ,32'b1  }; 

//LABEL_RAY_INSIDE_BOX:
117: I = { `ZERO ,`R1 ,`VOID ,`VOID }; 
118: I = { `JEQX ,`LABEL_TEST_YZ_PLANE ,`R1 ,`RAY_INSIDE_BOX }; 
//BUG need a NOP here else pipeline gets confused
119: I = { `RETURN ,`RT_TRUE   }; 

//LABEL_TEST_YZ_PLANE:
120: I = { `JNEX ,`LABEL_TEST_XZ_PLANE ,`R5 ,`R1 }; 
121: I = { `SWIZZLE3D ,`R6 ,`SWIZZLE_XXX  }; 
122: I = { `MUL ,`R2 ,`CREG_UNORMALIZED_DIRECTION ,`R6 }; 
123: I = { `ADD ,`R2 ,`R2 ,`CREG_CAMERA_POSITION }; 
124: I = { `JGEY ,`LABEL7 ,`R2 ,`CREG_AABBMIN }; 
125: I = { `RETURN ,`RT_FALSE   }; 

//LABEL7:
126: I = { `JLEY ,`LABEL8 ,`R2 ,`CREG_AABBMAX }; 
127: I = { `RETURN ,`RT_FALSE   }; 

//LABEL8:
128: I = { `JGEZ ,`LABEL9 ,`R2 ,`CREG_AABBMIN }; 
129: I = { `RETURN ,`RT_FALSE   }; 

//LABEL9:
130: I = { `JLEZ ,`LABEL_TEST_XZ_PLANE ,`R2 ,`CREG_AABBMAX }; 
131: I = { `RETURN ,`RT_FALSE   }; 

//LABEL_TEST_XZ_PLANE:
132: I = { `JNEY ,`LABEL_TEST_XY_PLANE ,`R5 ,`R1 }; 
133: I = { `SWIZZLE3D ,`R6 ,`SWIZZLE_YYY  }; 
134: I = { `MUL ,`R2 ,`CREG_UNORMALIZED_DIRECTION ,`R6 }; 
135: I = { `ADD ,`R2 ,`R2 ,`CREG_CAMERA_POSITION }; 
136: I = { `JGEX ,`LABEL10 ,`R2 ,`CREG_AABBMIN }; 
137: I = { `RETURN ,`RT_FALSE   }; 

//LABEL10:
138: I = { `JLEX ,`LABEL11 ,`R2 ,`CREG_AABBMAX }; 
139: I = { `RETURN ,`RT_FALSE   }; 

//LABEL11:
140: I = { `JGEZ ,`LABEL12 ,`R2 ,`CREG_AABBMIN }; 
141: I = { `RETURN ,`RT_FALSE   }; 

//LABEL12:
142: I = { `JLEZ ,`LABEL_TEST_XY_PLANE ,`R2 ,`CREG_AABBMAX }; 
143: I = { `RETURN ,`RT_FALSE   }; 

//LABEL_TEST_XY_PLANE:
144: I = { `SWIZZLE3D ,`R6 ,`SWIZZLE_ZZZ  }; 
145: I = { `MUL ,`R2 ,`CREG_UNORMALIZED_DIRECTION ,`R6 }; 
146: I = { `ADD ,`R2 ,`R2 ,`CREG_CAMERA_POSITION }; 
147: I = { `JGEX ,`LABEL13 ,`R2 ,`CREG_AABBMIN }; 
148: I = { `RETURN ,`RT_FALSE   }; 

//LABEL13:
149: I = { `JLEX ,`LABEL14 ,`R2 ,`CREG_AABBMAX }; 
150: I = { `RETURN ,`RT_FALSE   }; 

//LABEL14:
151: I = { `JGEY ,`LABEL15 ,`R2 ,`CREG_AABBMIN }; 
152: I = { `RETURN ,`RT_FALSE   }; 

//LABEL15:
153: I = { `JLEY ,`LABEL_HIT ,`R2 ,`CREG_AABBMAX }; 
154: I = { `RETURN ,`RT_FALSE   }; 

//LABEL_HIT:
155: I = { `SETX ,`CREG_LAST_t ,32'h1F40000  }; 
156: I = { `RETURN ,`RT_TRUE   }; 

 //------------------------------------------------------------------------
 //BIU Micro code
//TAG_BIU_UCODE_ADDRESS:
			  
157: I = { `ZERO ,`OREG_PIXEL_COLOR ,`VOID ,`VOID }; 
158: I = { `SETX ,`R3 ,`ONE  }; 
159: I = { `SETX ,`R1 ,32'h00000  }; 
160: I = { `SUB ,`CREG_E1 ,`CREG_V1 ,`CREG_V0 }; 
161: I = { `SUB ,`CREG_E2 ,`CREG_V2 ,`CREG_V0 }; 
162: I = { `SUB ,`CREG_T ,`CREG_CAMERA_POSITION ,`CREG_V0 }; 
163: I = { `CROSS ,`CREG_P ,`CREG_RAY_DIRECTION ,`CREG_E2 }; 
164: I = { `CROSS ,`CREG_Q ,`CREG_T ,`CREG_E1 }; 
165: I = { `DOT ,`CREG_H1 ,`CREG_Q ,`CREG_E2 }; 
166: I = { `DOT ,`CREG_H2 ,`CREG_P ,`CREG_T }; 
167: I = { `DOT ,`CREG_H3 ,`CREG_Q ,`CREG_RAY_DIRECTION }; 
168: I = { `DOT ,`CREG_DELTA ,`CREG_P ,`CREG_E1 }; 
169: I = { `DIV ,`CREG_t ,`CREG_H1 ,`CREG_DELTA }; 
170: I = { `DIV ,`CREG_u ,`CREG_H2 ,`CREG_DELTA }; 
171: I = { `DIV ,`CREG_v ,`CREG_H3 ,`CREG_DELTA }; 
172: I = { `JGEX ,`LABEL_BIU1 ,`CREG_u ,`R1 }; 
173: I = { `RET ,`R99 ,`FALSE  }; 

//LABEL_BIU1:
174: I = { `JGEX ,`LABEL_BIU2 ,`CREG_v ,`R1 }; 
175: I = { `RET ,`R99 ,`FALSE  }; 

//LABEL_BIU2:
176: I = { `ADD ,`R2 ,`CREG_u ,`CREG_v }; 
177: I = { `JLEX ,`LABEL_BIU3 ,`R2 ,`R3 }; 
178: I = { `RET ,`R99 ,`FALSE  }; 

//LABEL_BIU3:
179: I = { `JGEX ,`LABEL_BIU4 ,`CREG_t ,`CREG_LAST_t }; 
180: I = { `COPY ,`CREG_LAST_t ,`CREG_t ,`VOID }; 
181: I = { `COPY ,`CREG_LAST_u ,`CREG_u ,`VOID }; 
182: I = { `COPY ,`CREG_LAST_v ,`CREG_v ,`VOID }; 
183: I = { `COPY ,`CREG_E1_LAST ,`CREG_E1 ,`VOID }; 
184: I = { `COPY ,`CREG_E2_LAST ,`CREG_E2 ,`VOID }; 
185: I = { `COPY ,`CREG_UV0_LAST ,`CREG_UV0 ,`VOID }; 
186: I = { `COPY ,`CREG_UV1_LAST ,`CREG_UV1 ,`VOID }; 
187: I = { `COPY ,`CREG_UV2_LAST ,`CREG_UV2 ,`VOID }; 
188: I = { `COPY ,`CREG_TRI_DIFFUSE_LAST ,`CREG_TRI_DIFFUSE ,`VOID }; 
//LABEL_BIU4:
189: I = { `RET ,`R99 ,`TRUE  }; 


//-------------------------------------------------------------------------
//Calculate the adress of the texure coordiantes.

//TAG_TCC_UCODE_ADDRESS:
//Do this calculation only if this triangle is the one closest to the camera
190: I = { `JGX ,`LABEL_TCC_EXIT ,`CREG_t ,`CREG_LAST_t }; 

//First get the UV coodrinates and store in R1
//R1x: u_coordinate = U0 + last_u * (U1 - U0) + last_v * (U2 - U0)
//R1y: v_coordinate = V0 + last_u * (V1 - V0) + last_v * (V2 - V0)
//R1z: 0

191: I = { `SUB ,`R1 ,`CREG_UV1_LAST ,`CREG_UV0_LAST }; 
192: I = { `SUB ,`R2 ,`CREG_UV2_LAST ,`CREG_UV0_LAST }; 
193: I = { `MUL ,`R1 ,`CREG_LAST_u ,`R1 }; 
194: I = { `MUL ,`R2 ,`CREG_LAST_v ,`R2 }; 
195: I = { `ADD ,`R1 ,`R1 ,`R2 }; 
196: I = { `ADD ,`R1 ,`R1 ,`CREG_UV0_LAST }; 

//R7x : fu = (u_coordinate) * gTexture.mWidth
//R7y : fv = (v_coordinate) * gTexture.mWidth
//R7z : 0
197: I = { `MUL ,`R7 ,`R1 ,`CREG_TEXTURE_SIZE }; 

//R1x: u1 = ((int)fu) % gTexture.mWidth
//R1y: v1 = ((int)fv) % gTexture.mHeight
//R1z: 0
//R2x: u2 = (u1 + 1 ) % gTexture.mWidth
//R2y: v2 = (v2 + 1 ) % gTexture.mHeight
//R2z: 0
// Notice MOD2 only operates over
// numbers that are power of 2 also notice that the
// textures are assumed to be squares!
//x % 2^n == x & (2^n - 1).

198: I = { `MOD ,`R1 ,`R7 ,`CREG_TEXTURE_SIZE }; 
199: I = { `INC ,`R2 ,`R1 ,`VOID }; 
200: I = { `MOD ,`R2 ,`R2 ,`CREG_TEXTURE_SIZE }; 

//Cool now we should store the values in the appropiate registers
//OREG_TEX_COORD1.x = u1 + v1 * gTexture.mWidth
//OREG_TEX_COORD1.y = u2 + v1 * gTexture.mWidth
//OREG_TEX_COORD1.z = 0
//OREG_TEX_COORD2.x = u1 + v2 * gTexture.mWidth
//OREG_TEX_COORD2.y = u2 + v2 * gTexture.mWidth
//OREG_TEX_COORD1.z = 0

//R1= [u1 v1 0]
//R2= [u2 v2 0]

//R2 = [v2 u2 0]
201: I = { `SWIZZLE3D ,`R2 ,`SWIZZLE_YXZ  }; 

//R3 = [v2 v1 0]
202: I = { `XCHANGEX ,`R3 ,`R1 ,`R2 }; 


//R4 = [u1 u2 0]
203: I = { `XCHANGEX ,`R4 ,`R2 ,`R1 }; 

//R2 = [v2*H v1*H 0]
204: I = { `UNSCALE ,`R9 ,`R3 ,`VOID }; 
205: I = { `UNSCALE ,`R8 ,`CREG_TEXTURE_SIZE ,`VOID }; 
206: I = { `IMUL ,`R2 ,`R9 ,`R8 }; 

//OREG_TEX_COORD1 = [u1 + v2*H u2 + v1*H 0]
//R4 = FixedToIinteger(R4)
207: I = { `UNSCALE ,`R4 ,`R4 ,`VOID }; 
208: I = { `ADD ,`R12 ,`R2 ,`R4 }; 
209: I = { `SETX ,`R5 ,32'h3  }; 
210: I = { `SETY ,`R5 ,32'h3  }; 
211: I = { `SETZ ,`R5 ,32'h3  }; 
//Multiply by 3 (the pitch)
//IMUL OREG_TEX_COORD1 R12 R5  
212: I = { `IMUL ,`CREG_TEX_COORD1 ,`R12 ,`R5 }; 

//R4 = [u2 u1 0]
213: I = { `SWIZZLE3D ,`R4 ,`SWIZZLE_YXZ  }; 


//OREG_TEX_COORD2 [u2 + v2*H u1 + v1*H 0]
214: I = { `ADD ,`R12 ,`R2 ,`R4 }; 
//Multiply by 3 (the pitch)
//IMUL OREG_TEX_COORD2 R12 R5  
215: I = { `IMUL ,`CREG_TEX_COORD2 ,`R12 ,`R5 }; 


//Cool now get the weights

//w1 = (1 - fracu) * (1 - fracv)
//w2 = fracu * (1 - fracv)
//w3 = (1 - fracu) * fracv
//w4 = fracu *  fracv

//R4x: fracu 
//R4y: fracv 
//R4z: 0
216: I = { `FRAC ,`R4 ,`R7 ,`VOID }; 

//R5x: fracv 
//R5y: fracu 
//R5z: 0 
217: I = { `COPY ,`R5 ,`R4 ,`VOID }; 
218: I = { `SWIZZLE3D ,`R5 ,`SWIZZLE_YXZ  }; 


//R5x: 1 - fracv 
//R5y: 1 - fracu 
//R5y: 1
219: I = { `NEG ,`R5 ,`R5 ,`VOID }; 
220: I = { `INC ,`R5 ,`R5 ,`VOID }; 

//R5x: 1 - fracv 
//R5y: 1 - fracu 
//R5y: (1 - fracv)(1 - fracu) 
221: I = { `MULP ,`CREG_TEXWEIGHT1 ,`R5 ,`VOID }; 

//CREG_TEXWEIGHT1.x = (1 - fracv)(1 - fracu) 
//CREG_TEXWEIGHT1.y = (1 - fracv)(1 - fracu) 
//CREG_TEXWEIGHT1.z = (1 - fracv)(1 - fracu) 
222: I = { `SWIZZLE3D ,`CREG_TEXWEIGHT1 ,`SWIZZLE_ZZZ  }; 


//R6x: w2: fracu * (1 - fracv )
//R6y: w3: fracv * (1 - fracu )
//R6z: 0
223: I = { `MUL ,`R6 ,`R4 ,`R5 }; 

//CREG_TEXWEIGHT2.x = fracu * (1 - fracv )
//CREG_TEXWEIGHT2.y = fracu * (1 - fracv )
//CREG_TEXWEIGHT2.z = fracu * (1 - fracv )
224: I = { `COPY ,`CREG_TEXWEIGHT2 ,`R6 ,`VOID }; 
225: I = { `SWIZZLE3D ,`CREG_TEXWEIGHT2 ,`SWIZZLE_XXX  }; 

//CREG_TEXWEIGHT3.x = fracv * (1 - fracu )
//CREG_TEXWEIGHT3.y = fracv * (1 - fracu )
//CREG_TEXWEIGHT3.z = fracv * (1 - fracu )
226: I = { `COPY ,`CREG_TEXWEIGHT3 ,`R6 ,`VOID }; 
227: I = { `SWIZZLE3D ,`CREG_TEXWEIGHT3 ,`SWIZZLE_YYY  }; 


//R4x: fracu
//R4y: fracv
//R4z: fracu * fracv
228: I = { `MULP ,`R4 ,`R4 ,`VOID }; 

//CREG_TEXWEIGHT4.x = fracv * fracu 
//CREG_TEXWEIGHT4.y = fracv * fracu 
//CREG_TEXWEIGHT4.z = fracv * fracu 
229: I = { `COPY ,`CREG_TEXWEIGHT4 ,`R4 ,`VOID }; 
230: I = { `SWIZZLE3D ,`CREG_TEXWEIGHT4 ,`SWIZZLE_ZZZ  }; 


//LABEL_TCC_EXIT:
231: I = { `RET ,`R99 ,32'h0  }; 


//-------------------------------------------------------------------------
//TAG_PSU_UCODE_ADRESS:
//Pixel Shader #1
//This pixel shader has diffuse light but no textures

	 
232: I = { `CROSS ,`R1 ,`CREG_E1_LAST ,`CREG_E2_LAST }; 
233: I = { `MAG ,`R2 ,`R1 ,`VOID }; 
234: I = { `DIV ,`R1 ,`R1 ,`R2 }; 
235: I = { `MUL ,`R2 ,`CREG_RAY_DIRECTION ,`CREG_LAST_t }; 
236: I = { `ADD ,`R2 ,`R2 ,`CREG_CAMERA_POSITION }; 
237: I = { `SUB ,`R2 ,`CURRENT_LIGHT_POS ,`R2 }; 
238: I = { `MAG ,`R3 ,`R2 ,`VOID }; 
239: I = { `DIV ,`R2 ,`R2 ,`R3 }; 
240: I = { `DOT ,`R3 ,`R2 ,`R1 }; 
241: I = { `MUL ,`CREG_COLOR_ACC ,`CREG_TRI_DIFFUSE_LAST ,`CURRENT_LIGHT_DIFFUSE }; 
242: I = { `MUL ,`CREG_COLOR_ACC ,`CREG_COLOR_ACC ,`R3 }; 
243: I = { `COPY ,`CREG_TEXTURE_COLOR ,`CREG_COLOR_ACC ,`VOID }; 
244: I = { `NOP ,`RT_FALSE   }; 
245: I = { `NOP ,`RT_FALSE   }; 
246: I = { `NOP ,`RT_FALSE   }; 
247: I = { `RETURN ,`RT_TRUE   }; 

//-------------------------------------------------------------------------
//Pixel Shader #2
//TAG_PSU_UCODE_ADRESS2:
//This Pixel Shader has no light but it does texturinng 
//with bi-linear interpolation



248: I = { `COPY ,`R1 ,`CREG_TEX_COORD1 ,`VOID }; 
249: I = { `COPY ,`R2 ,`CREG_TEX_COORD1 ,`VOID }; 
250: I = { `COPY ,`R3 ,`CREG_TEX_COORD2 ,`VOID }; 
251: I = { `COPY ,`R4 ,`CREG_TEX_COORD2 ,`VOID }; 


252: I = { `SWIZZLE3D ,`R1 ,`SWIZZLE_XXX  }; 
253: I = { `SWIZZLE3D ,`R2 ,`SWIZZLE_YYY  }; 
254: I = { `SWIZZLE3D ,`R3 ,`SWIZZLE_XXX  }; 
255: I = { `SWIZZLE3D ,`R4 ,`SWIZZLE_YYY  }; 
256: I = { `ADD ,`R1 ,`R1 ,`CREG_012 }; 
257: I = { `ADD ,`R2 ,`R2 ,`CREG_012 }; 
258: I = { `ADD ,`R3 ,`R3 ,`CREG_012 }; 
259: I = { `ADD ,`R4 ,`R4 ,`CREG_012 }; 


260: I = { `TMREAD ,`CREG_TEX_COLOR1 ,`R1 ,`VOID }; 
261: I = { `NOP ,`RT_FALSE   }; 
262: I = { `TMREAD ,`CREG_TEX_COLOR2 ,`R2 ,`VOID }; 
263: I = { `NOP ,`RT_FALSE   }; 
264: I = { `TMREAD ,`CREG_TEX_COLOR3 ,`R3 ,`VOID }; 
265: I = { `NOP ,`RT_FALSE   }; 
266: I = { `TMREAD ,`CREG_TEX_COLOR4 ,`R4 ,`VOID }; 
267: I = { `NOP ,`RT_FALSE   }; 




//TextureColor.R = c1.R * w1 + c2.R * w2 + c3.R * w3 + c4.R * w4
//TextureColor.G = c1.G * w1 + c2.G * w2 + c3.G * w3 + c4.G * w4
//TextureColor.B = c1.B * w1 + c2.B * w2 + c3.B * w3 + c4.B * w4


//MUL R1 CREG_TEX_COLOR4 CREG_TEXWEIGHT1  
//MUL R2 CREG_TEX_COLOR2 CREG_TEXWEIGHT2  
//MUL R3 CREG_TEX_COLOR1 CREG_TEXWEIGHT3  
//MUL R4 CREG_TEX_COLOR3 CREG_TEXWEIGHT4  

268: I = { `MUL ,`R1 ,`CREG_TEX_COLOR3 ,`CREG_TEXWEIGHT1 }; 
269: I = { `MUL ,`R2 ,`CREG_TEX_COLOR2 ,`CREG_TEXWEIGHT2 }; 
270: I = { `MUL ,`R3 ,`CREG_TEX_COLOR1 ,`CREG_TEXWEIGHT3 }; 
271: I = { `MUL ,`R4 ,`CREG_TEX_COLOR4 ,`CREG_TEXWEIGHT4 }; 

272: I = { `ADD ,`CREG_TEXTURE_COLOR ,`R1 ,`R2 }; 
273: I = { `ADD ,`CREG_TEXTURE_COLOR ,`CREG_TEXTURE_COLOR ,`R3 }; 
274: I = { `ADD ,`CREG_TEXTURE_COLOR ,`CREG_TEXTURE_COLOR ,`R4 }; 
275: I = { `RETURN ,`RT_TRUE   }; 


//-------------------------------------------------------------------------
//Default User constants
//TAG_USERCONSTANTS:

276: I = { `NOP ,`RT_FALSE   }; 
277: I = { `RETURN ,`RT_TRUE   }; 

//TAG_PIXELSHADER:
//Default Pixel Shader (just outputs texture)
278: I = { `OMWRITE ,`OREG_PIXEL_COLOR ,`CREG_CURRENT_OUTPUT_PIXEL ,`CREG_TEXTURE_COLOR }; 
279: I = { `RETURN ,`RT_TRUE   }; 


//-------------------------------------------------------------------------		
		

			default: 
			begin
			
			`ifdef DEBUG
			$display("%dns CORE %d Error: Reached undefined address in instruction Memory: %d!!!!",$time,iDebug_CoreID,Address);
		//	$stop();
			`endif
			I =  {`INSTRUCTION_OP_LENGTH'hFF,16'hFFFF,32'hFFFFFFFF};
			end
			endcase
	end
endmodule
//--------------------------------------------------------