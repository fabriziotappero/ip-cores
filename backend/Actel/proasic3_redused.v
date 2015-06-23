/********************************************************************
        Actel ProASIC3 Verilog Library
        NAME: proasic3.v
        DATE: Oct 31, 2006
*********************************************************************/

`timescale 1 ns / 100 ps

//----------------------------------------------------------------------
//---             VERILOG LIBRRAY PRIMITIVE SECTION                     
//----------------------------------------------------------------------



primitive Dffpr (Q, D, CLK, CLR, PRE, E, NOTIFIER_REG);
  output Q;
  input  NOTIFIER_REG;
  input  D, CLK, E, CLR, PRE;
  reg Q;

	table

	//  D   CLK   CLR  PRE   E  NOTIFIER_REG  :   Qt  :  Qt+1

	    1   (01)    1   1    0      ?         :   ?   :   1;  // clocked data
	    0   (01)    1   1    0      ?         :   ?   :   0;  // clocked data
	    1   (01)    1   1    x      ?         :   1   :   1;  // clocked data
	    0   (01)    1   1    x      ?         :   0   :   0; 
	    0   (01)    1   1    x      ?         :   1   :   x;
	    1   (01)    1   1    x      ?         :   0   :   x;
	    0   (01)    x   1    0      ?         :   ?   :   0;  // pessimism
	    1   (01)    1   x    0      ?         :   ?   :   1;  // pessimism
	    ?    ?      1   x    ?      ?         :   1   :   1;  // pessimism
	    0    ?      1   x    ?      ?         :   x   :   x;  // pessimism
	    ?    ?      1   x    ?      ?         :   0   :   x;
	    ?    ?      x   x    ?      ?         :   ?   :   x;
	    ?    ?      x   0    ?      ?         :   ?   :   x;
	    ?    ?      x   1    ?      ?         :   0   :   0;
	    ?    ?      x   1    ?      ?         :   1   :   x;
	    ?    ?      0   ?    ?      ?         :   ?   :   0;
	    ?    ?      1   0    ?      ?         :   ?   :   1;
	    1   (x1)    1   1    0      ?         :   1   :   1;  // reducing pessimism
	    0   (x1)    1   1    0      ?         :   0   :   0;
	    1   (0x)    1   1    0      ?         :   1   :   1;
     0   (0x)    1   1    0      ?         :   0   :   0;
	    1   (x1)    1   1    x      ?         :   1   :   1;  // reducing pessimism
	    0   (x1)    1   1    x      ?         :   0   :   0;
	    1   (0x)    1   1    x      ?         :   1   :   1;
	    0   (0x)    1   1    x      ?         :   0   :   0;
	    ?  (?1)     1   1    1      ?         :   ?   :   -;  //no action for CE = 1
	    ?  (0x)     1   1    1      ?         :   ?   :   -;  //no action for CE = 1
	    ?   ?       ?   ?    *      ?         :   ?   :   -;
	    ?   (?0)    ?   ?    ?      ?         :   ?   :   -;  // ignore falling clock
	    ?   (1x)    ?   ?    ?      ?         :   ?   :   -;  // ignore falling clock
	    *    ?      ?   ?    ?      ?         :   ?   :   -;  // ignore data edges
	    ?   ?     (?1)  ?    ?      ?         :   ?   :   -;  // ignore the edges on
	    ?   ?       ?  (?1)  ?      ?         :   ?   :   -;  //       set and clear
	    ?   ?       ?   ?    ?      *         :   ?   :   x;

	endtable
 endprimitive


primitive UDP_MUX2 (Q, A, B, SL);
output Q;
input A, B, SL;

// FUNCTION :  TWO TO ONE MULTIPLEXER

    table
    //  A   B   SL  :   Q
        0   0   ?   :   0 ;
        1   1   ?   :   1 ;

        0   ?   1   :   0 ;
        1   ?   1   :   1 ;

        ?   0   0   :   0 ;
        ?   1   0   :   1 ;

    endtable
endprimitive



primitive UDPN_MUX2 (Q, A, B, SL);
output Q;
input A, B, SL;

// FUNCTION :  TWO TO ONE MULTIPLEXER

    table
    //  A   B   SL  :   Q
        0   0   ?   :   1 ;
        1   1   ?   :   0 ;

        0   ?   1   :   1 ;
        1   ?   1   :   0 ;

        ?   0   0   :   1 ;
        ?   1   0   :   0 ;

    endtable
endprimitive


primitive UFPRB (Q, D, CP, RB, NOTIFIER_REG);

    output Q;
    input  NOTIFIER_REG,
           D, CP, RB;
    reg    Q;

// FUNCTION : POSITIVE EDGE TRIGGERED D FLIP-FLOP WITH ACTIVE LOW
//            ASYNCHRONOUS CLEAR ( Q OUTPUT UDP ).

    table
    //  D   CP      RB     NOTIFIER_REG  :   Qt  :   Qt+1

        1   (01)    1         ?          :   ?   :   1;  // clocked data
        0   (01)    1         ?          :   ?   :   0;

        0   (01)    x         ?          :   ?   :   0;  // pessimism
        0    ?      x         ?          :   0   :   0;  // pessimism

        1    0      x         ?          :   0   :   0;  // pessimism
        1    x    (?x)        ?          :   0   :   0;  // pessimism
        1    1    (?x)        ?          :   0   :   0;  // pessimism
        x    0      x         ?          :   0   :   0;  // pessimism
        x    x    (?x)        ?          :   0   :   0;  // pessimism
        x    1    (?x)        ?          :   0   :   0;  // pessimism
        1   (x1)    1         ?          :   1   :   1;  // reducing pessimism
        0   (x1)    1         ?          :   0   :   0;
        1   (0x)    1         ?          :   1   :   1;
        0   (0x)    1         ?          :   0   :   0;
        ?   ?       0         ?          :   ?   :   0;  // asynchronous clear
        ?   (?0)    ?         ?          :   ?   :   -;  // ignore falling clock
        ?   (1x)    ?         ?          :   ?   :   -;  // ignore falling clock
        *    ?      ?         ?          :   ?   :   -;  // ignore the edges on data
        ?    ?    (?1)        ?          :   ?   :   -;  // ignore the edges on clear
        ?    ?      ?         *          :   ?   :   x;
    endtable
endprimitive




//----------------------------------------------------------------------
//---             VERILOG LIBRRAY MODULES SECTION                     
//----------------------------------------------------------------------




/*--------------------------------------------------------------------
 CELL NAME : AND2
 CELL TYPE : comb
 CELL LOGIC : Y = A & B
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module AND2(Y,A,B);
 input A,B;
 output Y;

 and      U2(Y, A, B);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults





/*--------------------------------------------------------------------
 CELL NAME : AO1
 CELL TYPE : comb
 CELL LOGIC : Y = (A & B) + C
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module AO1(Y,A,B,C);
 input A,B,C;
 output Y;
 wire NET_0_0;

 and      U142(NET_0_0, A, B);
 or       U143(Y, NET_0_0, C);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_C_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_C_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
		(C => Y ) = ( tpdLH_C_to_Y, tpdHL_C_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults



/*--------------------------------------------------------------------
 CELL NAME : AO1A
 CELL TYPE : comb
 CELL LOGIC : Y = (!A & B) + C
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module AO1A(Y,A,B,C);
 input A,B,C;
 output Y;
 wire NET_0_0;

 not	INV_31(A_, A);
 and      U147(NET_0_0, A_, B);
 or       U148(Y, NET_0_0, C);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_C_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_C_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
		(C => Y ) = ( tpdLH_C_to_Y, tpdHL_C_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults


/*--------------------------------------------------------------------
 CELL NAME : AO1B
 CELL TYPE : comb
 CELL LOGIC : Y = (A & B) + !C
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module AO1B(Y,A,B,C);
 input A,B,C;
 output Y;
 wire NET_0_0;

 not	INV_32(C_, C);
 and      U152(NET_0_0, A, B);
 or       U153(Y, NET_0_0, C_);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_C_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_C_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
		(C => Y ) = ( tpdLH_C_to_Y, tpdHL_C_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults



/*--------------------------------------------------------------------
 CELL NAME : AO1D
 CELL TYPE : comb
 CELL LOGIC : Y = (!A & !B) + C
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module AO1D(Y,A,B,C);
 input A,B,C;
 output Y;
 wire NET_0_0;

 not	INV_35(A_, A);
 not	INV_36(B_, B);
 and      U162(NET_0_0, A_, B_);
 or       U163(Y, NET_0_0, C);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_C_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_C_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
		(C => Y ) = ( tpdLH_C_to_Y, tpdHL_C_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults



/*--------------------------------------------------------------------
 CELL NAME : AOI1
 CELL TYPE : comb
 CELL LOGIC : Y = !(A & B + C)
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module AOI1(Y,A,B,C);
 input A,B,C;
 output Y;
 wire NET_0_0;

 and      U192(NET_0_0, A, B);
 nor      U193(Y, NET_0_0, C);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_C_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_C_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
		(C => Y ) = ( tpdLH_C_to_Y, tpdHL_C_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults




/*--------------------------------------------------------------------
 CELL NAME : AOI1B
 CELL TYPE : comb
 CELL LOGIC : Y = !(A & B + !C)
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module AOI1B(Y,A,B,C);
 input A,B,C;
 output Y;
 wire NET_0_0;

 not	INV_45(C_, C);
 and      U202(NET_0_0, A, B);
 nor      U203(Y, NET_0_0, C_);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_C_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_C_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
		(C => Y ) = ( tpdLH_C_to_Y, tpdHL_C_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults



/*--------------------------------------------------------------------
 CELL NAME : AO1C
 CELL TYPE : comb
 CELL LOGIC : Y = (!A & B) + !C
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module AO1C(Y,A,B,C);
 input A,B,C;
 output Y;
 wire NET_0_0;

 not	INV_33(A_, A);
 not	INV_34(C_, C);
 and      U157(NET_0_0, A_, B);
 or       U158(Y, NET_0_0, C_);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_C_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_C_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
		(C => Y ) = ( tpdLH_C_to_Y, tpdHL_C_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults


/*--------------------------------------------------------------------
 CELL NAME : AX1
 CELL TYPE : comb
 CELL LOGIC : Y = (!A & B) ^ C
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module AX1(Y,A,B,C);
 input A,B,C;
 output Y;
 wire NET_0_0;

 not	INV_57(A_, A);
 and      U245(NET_0_0, A_, B);
 xor      U246(Y, NET_0_0, C);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_C_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_C_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
		(C => Y ) = ( tpdLH_C_to_Y, tpdHL_C_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults




/*--------------------------------------------------------------------
 CELL NAME : AX1B
 CELL TYPE : comb
 CELL LOGIC : Y = (!A & !B) ^ C
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module AX1B(Y,A,B,C);
 input A,B,C;
 output Y;
 wire NET_0_0;

 not	INV_59(A_, A);
 not	INV_60(B_, B);
 and      U255(NET_0_0, A_, B_);
 xor      U256(Y, NET_0_0, C);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_C_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_C_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
		(C => Y ) = ( tpdLH_C_to_Y, tpdHL_C_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults






/*--------------------------------------------------------------------
 CELL NAME : AX1C
 CELL TYPE : comb
 CELL LOGIC : Y = (A & B) ^ C
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module AX1C(Y,A,B,C);
 input A,B,C;
 output Y;
 wire NET_0_0;

 and      U260(NET_0_0, A, B);
 xor      U261(Y, NET_0_0, C);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_C_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_C_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
		(C => Y ) = ( tpdLH_C_to_Y, tpdHL_C_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults



/*--------------------------------------------------------------------
 CELL NAME : AX1D
 CELL TYPE : comb
 CELL LOGIC : Y = !((!A & !B) ^ C)
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module AX1D(Y,A,B,C);
 input A,B,C;
 output Y;
 wire NET_0_0;

 not	INV_61(A_, A);
 not	INV_62(B_, B);
 and      U265(NET_0_0, A_, B_);
 xnor     U266(Y, NET_0_0, C);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_C_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_C_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
		(C => Y ) = ( tpdLH_C_to_Y, tpdHL_C_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults



/*--------------------------------------------------------------------
 CELL NAME : AX1E
 CELL TYPE : comb
 CELL LOGIC : Y = !((A & B) ^ C)
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module AX1E(Y,A,B,C);
 input A,B,C;
 output Y;
 wire NET_0_0;

 and      U270(NET_0_0, A, B);
 xnor     U271(Y, NET_0_0, C);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_C_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_C_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
		(C => Y ) = ( tpdLH_C_to_Y, tpdHL_C_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults


/*--------------------------------------------------------------------
 CELL NAME : CLKINT
 CELL TYPE : comb
 CELL LOGIC : Y = A
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module CLKINT(Y,A);
 input A;
 output Y;

 assign Y = A;

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults





/*--------------------------------------------------------------
 CELL NAME : DFN1C1
 CELL TYPE : sequential Logic
 CELL SEQ EQN : DFF[Q=Q,CLK =CLK, CLR=CLR, D=D ];
----------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module DFN1C1(CLR, CLK, Q,D);
 input D,CLR,CLK;
 output Q;
 reg NOTIFY_REG;

 not INV_CLR_0(CLR_0, CLR);

 UFPRB DF_0( Q, D, CLK, CLR_0, NOTIFY_REG );

// some temp signals created for timing checking sections

      not U0_I2 (_CLR0, CLR);
      buf U_c0 (Enable01,_CLR0);
       buf U_c2 (Enable02, _CLR0);
      buf U_c6 (Enable05, _CLR0);

//--------------------------------------------------------------
//              Timing Checking Section 
//-------------------------------------------------------------

 specify

	specparam   tpdLH_CLK_to_Q = (0.1:0.1:0.1);
	specparam   tpdHL_CLK_to_Q = (0.1:0.1:0.1);
	specparam   tpdLH_CLR_to_Q = (0.1:0.1:0.1);
	specparam   tpdHL_CLR_to_Q = (0.1:0.1:0.1);



	//check timing delay for output

	(posedge CLK => (Q +: D))=(tpdLH_CLK_to_Q, tpdHL_CLK_to_Q);
	(posedge CLR => (Q +: 1'b0)) = (tpdLH_CLR_to_Q, tpdHL_CLR_to_Q);

	//checking setup and hold timing for inputs

	$setup(posedge D,posedge CLK &&& Enable01, 0.0, NOTIFY_REG);
	$setup(negedge D,posedge CLK &&& Enable01, 0.0, NOTIFY_REG);
	$hold(posedge CLK &&& Enable01, posedge D,0.0, NOTIFY_REG);
	$hold(posedge CLK &&& Enable01, negedge D,0.0, NOTIFY_REG);

	//checking timing for control signals

	$hold(posedge CLK, negedge CLR,0.0, NOTIFY_REG);

	//checking the pulse width

	$width(posedge CLK &&& Enable05 ,0,  0, NOTIFY_REG);
	$width(negedge CLK &&& Enable05, 0, 0, NOTIFY_REG);
	$width(posedge CLR, 0.0, 0, NOTIFY_REG);

	//checing the recovery data

	$recovery(negedge CLR, posedge CLK, 0.0, NOTIFY_REG);

 endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults


/*--------------------------------------------------------------
 CELL NAME : DFN1E1C1
 CELL TYPE : sequential Logic
 CELL SEQ EQN : DFF[Q=Q,CLK =CLK, E=E, CLR=CLR, D=D ];
----------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module DFN1E1C1(CLR, E, CLK, Q,D);
 input D,CLR,E,CLK;
 output Q;
 supply1 VCC_0;
 reg NOTIFY_REG;

 not INV_CLR_0(CLR_0, CLR);
 not INV_EN_0(E_0, E);

 Dffpr DF_0(Q, D,CLK,CLR_0, VCC_0, E_0, NOTIFY_REG);

// some temp signals created for timing checking sections

      not U0_I2 (_CLR0, CLR);
      and U_c0 (Enable01, E, _CLR0);
      and U_c2 (Enable02, E, _CLR0);
      buf U_c4 (Enable04, E);
      buf U_c6 (Enable05, _CLR0);

//--------------------------------------------------------------
//              Timing Checking Section 
//-------------------------------------------------------------

 specify

	specparam   tpdLH_CLK_to_Q = (0.1:0.1:0.1);
	specparam   tpdHL_CLK_to_Q = (0.1:0.1:0.1);
	specparam   tpdLH_CLR_to_Q = (0.1:0.1:0.1);
	specparam   tpdHL_CLR_to_Q = (0.1:0.1:0.1);



	//check timing delay for output

	(posedge CLK => (Q +: D))=(tpdLH_CLK_to_Q, tpdHL_CLK_to_Q);
	(posedge CLR => (Q +: 1'b0)) = (tpdLH_CLR_to_Q, tpdHL_CLR_to_Q);

	//checking setup and hold timing for inputs

	$setup(posedge D,posedge CLK &&& Enable01, 0.0, NOTIFY_REG);
	$setup(negedge D,posedge CLK &&& Enable01, 0.0, NOTIFY_REG);
	$hold(posedge CLK &&& Enable01, posedge D,0.0, NOTIFY_REG);
	$hold(posedge CLK &&& Enable01, negedge D,0.0, NOTIFY_REG);

	//checking timing for control signals

	$setup(posedge E,posedge CLK &&& Enable05,  0.0, NOTIFY_REG);
	$hold(posedge CLK &&& Enable05, posedge E,0.0, NOTIFY_REG);
	$setup(negedge E,posedge CLK &&& Enable05, 0.0, NOTIFY_REG);
	$hold(posedge CLK &&& Enable05, negedge E,0.0, NOTIFY_REG);
	$hold(posedge CLK &&& Enable04, negedge CLR,0.0, NOTIFY_REG);

	//checking the pulse width

	$width(posedge CLK &&& Enable05 ,0,  0, NOTIFY_REG);
	$width(negedge CLK &&& Enable05, 0, 0, NOTIFY_REG);
	$width(posedge CLR, 0.0, 0, NOTIFY_REG);

	//checing the recovery data

	$recovery(negedge CLR, posedge CLK &&& Enable04, 0.0, NOTIFY_REG);

 endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults




/*--------------------------------------------------------------
 CELL NAME : DFN1E0C1
 CELL TYPE : sequential Logic
 CELL SEQ EQN : DFF[Q=Q,CLK =CLK, _E=E, CLR=CLR, D=D ];
----------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module DFN1E0C1(CLR, E, CLK, Q,D);
 input D,CLR,E,CLK;
 output Q;
 supply1 VCC_0;
 reg NOTIFY_REG;

 not INV_CLR_0(CLR_0, CLR);

 Dffpr DF_0(Q, D,CLK,CLR_0, VCC_0, E, NOTIFY_REG);

// some temp signals created for timing checking sections

      not U0_I2 (_CLR0, CLR);
      not U0_I3 (_E0, E);
      and U_c0 (Enable01, _E0, _CLR0);
      and U_c2 (Enable02, _E0, _CLR0);
      buf U_c4 (Enable04, _E0);
      buf U_c6 (Enable05, _CLR0);

//--------------------------------------------------------------
//              Timing Checking Section 
//-------------------------------------------------------------

 specify

	specparam   tpdLH_CLK_to_Q = (0.1:0.1:0.1);
	specparam   tpdHL_CLK_to_Q = (0.1:0.1:0.1);
	specparam   tpdLH_CLR_to_Q = (0.1:0.1:0.1);
	specparam   tpdHL_CLR_to_Q = (0.1:0.1:0.1);



	//check timing delay for output

	(posedge CLK => (Q +: D))=(tpdLH_CLK_to_Q, tpdHL_CLK_to_Q);
	(posedge CLR => (Q +: 1'b0)) = (tpdLH_CLR_to_Q, tpdHL_CLR_to_Q);

	//checking setup and hold timing for inputs

	$setup(posedge D,posedge CLK &&& Enable01, 0.0, NOTIFY_REG);
	$setup(negedge D,posedge CLK &&& Enable01, 0.0, NOTIFY_REG);
	$hold(posedge CLK &&& Enable01, posedge D,0.0, NOTIFY_REG);
	$hold(posedge CLK &&& Enable01, negedge D,0.0, NOTIFY_REG);

	//checking timing for control signals

	$setup(posedge E,posedge CLK &&& Enable05,  0.0, NOTIFY_REG);
	$hold(posedge CLK &&& Enable05, posedge E,0.0, NOTIFY_REG);
	$setup(negedge E,posedge CLK &&& Enable05, 0.0, NOTIFY_REG);
	$hold(posedge CLK &&& Enable05, negedge E,0.0, NOTIFY_REG);
	$hold(posedge CLK &&& Enable04, negedge CLR,0.0, NOTIFY_REG);

	//checking the pulse width

	$width(posedge CLK &&& Enable05 ,0,  0, NOTIFY_REG);
	$width(negedge CLK &&& Enable05, 0, 0, NOTIFY_REG);
	$width(posedge CLR, 0.0, 0, NOTIFY_REG);

	//checing the recovery data

	$recovery(negedge CLR, posedge CLK &&& Enable04, 0.0, NOTIFY_REG);

 endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults




/*--------------------------------------------------------------
 CELL NAME : DFN1E1P1
 CELL TYPE : sequential Logic
 CELL SEQ EQN : DFF[Q=Q,CLK =CLK, E=E, PRE=PRE, D=D ];
----------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module DFN1E1P1(PRE, E, CLK, Q,D);
 input D,PRE,E,CLK;
 output Q;
 supply1 VCC_0;
 reg NOTIFY_REG;

 not INV_PRE_0(PRE_0, PRE);
 not INV_EN_0(E_0, E);

 Dffpr DF_0(Q, D,CLK,VCC_0, PRE_0, E_0, NOTIFY_REG);

// some temp signals created for timing checking sections

      not U0_I1 (_PRE0, PRE);
      and U_c0 (Enable01, E, _PRE0);
      buf U_c2 (Enable02, E);
      and U_c4 (Enable04, E, _PRE0);
       buf U_c6 (Enable05, _PRE0);

//--------------------------------------------------------------
//              Timing Checking Section 
//-------------------------------------------------------------

 specify

	specparam   tpdLH_CLK_to_Q = (0.1:0.1:0.1);
	specparam   tpdHL_CLK_to_Q = (0.1:0.1:0.1);
	specparam   tpdLH_PRE_to_Q = (0.1:0.1:0.1);
	specparam   tpdHL_PRE_to_Q = (0.1:0.1:0.1);



	//check timing delay for output

	(posedge CLK => (Q +: D))=(tpdLH_CLK_to_Q, tpdHL_CLK_to_Q);
	(posedge PRE => (Q +: 1'b1)) = (tpdLH_PRE_to_Q, tpdHL_PRE_to_Q);

	//checking setup and hold timing for inputs

	$setup(posedge D,posedge CLK &&& Enable01, 0.0, NOTIFY_REG);
	$setup(negedge D,posedge CLK &&& Enable01, 0.0, NOTIFY_REG);
	$hold(posedge CLK &&& Enable01, posedge D,0.0, NOTIFY_REG);
	$hold(posedge CLK &&& Enable01, negedge D,0.0, NOTIFY_REG);

	//checking timing for control signals

	$setup(posedge E,posedge CLK &&& Enable05,  0.0, NOTIFY_REG);
	$hold(posedge CLK &&& Enable05, posedge E,0.0, NOTIFY_REG);
	$setup(negedge E,posedge CLK &&& Enable05, 0.0, NOTIFY_REG);
	$hold(posedge CLK &&& Enable05, negedge E,0.0, NOTIFY_REG);

	$hold(posedge CLK &&& Enable02, negedge PRE,0.0, NOTIFY_REG);

	//checking the pulse width

	$width(posedge CLK &&& Enable05 ,0,  0, NOTIFY_REG);
	$width(negedge CLK &&& Enable05, 0, 0, NOTIFY_REG);
	$width(posedge PRE,  0.0, 0, NOTIFY_REG);

	//checing the recovery data

	$recovery(negedge PRE, posedge CLK &&& Enable02, 0.0, NOTIFY_REG);

 endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults





/*--------------------------------------------------------------
 CELL NAME : DFN1P1
 CELL TYPE : sequential Logic
 CELL SEQ EQN : DFF[Q=Q,CLK =CLK, PRE=PRE, D=D ];
----------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module DFN1P1(PRE, CLK, Q,D);
 input D,PRE,CLK;
 output Q;
 supply1 VCC_0;
 supply0 GND_0;
 reg NOTIFY_REG;

 not INV_PRE_0(PRE_0, PRE);

 Dffpr DF_0(Q, D,CLK,VCC_0, PRE_0, GND_0, NOTIFY_REG);

// some temp signals created for timing checking sections

      not U0_I1 (_PRE0, PRE);
      buf U_c0 (Enable01, _PRE0);
       buf U_c4 (Enable04, _PRE0);
       buf U_c6 (Enable05, _PRE0);

//--------------------------------------------------------------
//              Timing Checking Section 
//-------------------------------------------------------------

 specify

	specparam   tpdLH_CLK_to_Q = (0.1:0.1:0.1);
	specparam   tpdHL_CLK_to_Q = (0.1:0.1:0.1);
	specparam   tpdLH_PRE_to_Q = (0.1:0.1:0.1);
	specparam   tpdHL_PRE_to_Q = (0.1:0.1:0.1);



	//check timing delay for output

	(posedge CLK => (Q +: D))=(tpdLH_CLK_to_Q, tpdHL_CLK_to_Q);
	(posedge PRE => (Q +: 1'b1)) = (tpdLH_PRE_to_Q, tpdHL_PRE_to_Q);

	//checking setup and hold timing for inputs

	$setup(posedge D,posedge CLK &&& Enable01, 0.0, NOTIFY_REG);
	$setup(negedge D,posedge CLK &&& Enable01, 0.0, NOTIFY_REG);
	$hold(posedge CLK &&& Enable01, posedge D,0.0, NOTIFY_REG);
	$hold(posedge CLK &&& Enable01, negedge D,0.0, NOTIFY_REG);

	//checking timing for control signals


	$hold(posedge CLK, negedge PRE,0.0, NOTIFY_REG);

	//checking the pulse width

	$width(posedge CLK &&& Enable05 ,0,  0, NOTIFY_REG);
	$width(negedge CLK &&& Enable05, 0, 0, NOTIFY_REG);
	$width(posedge PRE,  0.0, 0, NOTIFY_REG);

	//checing the recovery data

	$recovery(negedge PRE, posedge CLK, 0.0, NOTIFY_REG);

 endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults


/*--------------------------------------------------------------------
 CELL NAME : GND
 CELL TYPE : comb
 CELL LOGIC : Y=0
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module GND(Y);
 output Y;

 supply0	Y;

       specify

		specparam MacroType = "comb";

		//pin to pin path delay 

   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults




/*--------------------------------------------------------------------
 CELL NAME : MX2
 CELL TYPE : comb
 CELL LOGIC : Y = (A & !S) + (B & S)
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module MX2(Y,A,S,B);
 input A,S,B;
 output Y;
 wire NET_0_0, NET_0_1;

 not	INV_110(S_, S);
 UDP_MUX2   U594(Y, A, B, S_);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_S_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_S_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(S => Y ) = ( tpdLH_S_to_Y, tpdHL_S_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults



/*--------------------------------------------------------------------
 CELL NAME : NAND2
 CELL TYPE : comb
 CELL LOGIC : Y = !(A & B)
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module NAND2(Y,A,B);
 input A,B;
 output Y;

 nand     U610(Y, A, B);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults





/*--------------------------------------------------------------------
 CELL NAME : NOR2
 CELL TYPE : comb
 CELL LOGIC : Y = !(A + B)
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module NOR2(Y,A,B);
 input A,B;
 output Y;

 nor      U649(Y, A, B);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults



/*--------------------------------------------------------------------
 CELL NAME : NOR2A
 CELL TYPE : comb
 CELL LOGIC : Y = !(!A + B)
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module NOR2A(Y,A,B);
 input A,B;
 output Y;

 not	INV_130(A_, A);
 nor      U652(Y, A_, B);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults



/*--------------------------------------------------------------------
 CELL NAME : NOR2B
 CELL TYPE : comb
 CELL LOGIC : Y = !(!A + !B)
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module NOR2B(Y,A,B);
 input A,B;
 output Y;

 not	INV_131(A_, A);
 not	INV_132(B_, B);
 nor      U655(Y, A_, B_);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults



/*--------------------------------------------------------------------
 CELL NAME : NOR3
 CELL TYPE : comb
 CELL LOGIC : Y = !(A + B + C)
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module NOR3(Y,A,B,C);
 input A,B,C;
 output Y;
 wire NET_0_0;

 or       U662(NET_0_0, A, B);
 nor      U663(Y, NET_0_0, C);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_C_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_C_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
		(C => Y ) = ( tpdLH_C_to_Y, tpdHL_C_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults



/*--------------------------------------------------------------------
 CELL NAME : NOR3A
 CELL TYPE : comb
 CELL LOGIC : Y = !(!A + B + C)
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module NOR3A(Y,A,B,C);
 input A,B,C;
 output Y;
 wire NET_0_0;

 not	INV_134(A_, A);
 or       U667(NET_0_0, A_, B);
 nor      U668(Y, NET_0_0, C);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_C_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_C_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
		(C => Y ) = ( tpdLH_C_to_Y, tpdHL_C_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults



/*--------------------------------------------------------------------
 CELL NAME : NOR3B
 CELL TYPE : comb
 CELL LOGIC : Y = !(!A + !B + C)
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module NOR3B(Y,A,B,C);
 input A,B,C;
 output Y;
 wire NET_0_0;

 not	INV_135(A_, A);
 not	INV_136(B_, B);
 or       U672(NET_0_0, A_, B_);
 nor      U673(Y, NET_0_0, C);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_C_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_C_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
		(C => Y ) = ( tpdLH_C_to_Y, tpdHL_C_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults



/*--------------------------------------------------------------------
 CELL NAME : NOR3C
 CELL TYPE : comb
 CELL LOGIC : Y = !(!A + !B + !C)
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module NOR3C(Y,A,B,C);
 input A,B,C;
 output Y;
 wire NET_0_0;

 not	INV_137(A_, A);
 not	INV_138(B_, B);
 not	INV_139(C_, C);
 or       U677(NET_0_0, A_, B_);
 nor      U678(Y, NET_0_0, C_);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_C_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_C_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
		(C => Y ) = ( tpdLH_C_to_Y, tpdHL_C_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults



/*--------------------------------------------------------------------
 CELL NAME : OA1
 CELL TYPE : comb
 CELL LOGIC : Y = (A + B) & C
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module OA1(Y,A,B,C);
 input A,B,C;
 output Y;
 wire NET_0_0;

 or       U692(NET_0_0, A, B);
 and      U693(Y, NET_0_0, C);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_C_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_C_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
		(C => Y ) = ( tpdLH_C_to_Y, tpdHL_C_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults



/*--------------------------------------------------------------------
 CELL NAME : OA1A
 CELL TYPE : comb
 CELL LOGIC : Y = (!A + B) & C
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module OA1A(Y,A,B,C);
 input A,B,C;
 output Y;
 wire NET_0_0;

 not	INV_143(A_, A);
 or       U697(NET_0_0, A_, B);
 and      U698(Y, NET_0_0, C);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_C_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_C_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
		(C => Y ) = ( tpdLH_C_to_Y, tpdHL_C_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults



/*--------------------------------------------------------------------
 CELL NAME : OA1B
 CELL TYPE : comb
 CELL LOGIC : Y = !C & (A + B)
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module OA1B(Y,C,A,B);
 input C,A,B;
 output Y;
 wire NET_0_0;

 not	INV_144(C_, C);
 and      U701(Y, C_, NET_0_0);
 or       U703(NET_0_0, A, B);

       specify

		specparam tpdLH_C_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_C_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(C => Y ) = ( tpdLH_C_to_Y, tpdHL_C_to_Y );
		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults



/*--------------------------------------------------------------------
 CELL NAME : OA1C
 CELL TYPE : comb
 CELL LOGIC : Y = (!A + B) & !C
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module OA1C(Y,A,B,C);
 input A,B,C;
 output Y;
 wire NET_0_0;

 not	INV_145(A_, A);
 not	INV_146(C_, C);
 or       U707(NET_0_0, A_, B);
 and      U708(Y, NET_0_0, C_);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_C_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_C_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
		(C => Y ) = ( tpdLH_C_to_Y, tpdHL_C_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults



/*--------------------------------------------------------------------
 CELL NAME : OR2
 CELL TYPE : comb
 CELL LOGIC : Y = A + B
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module OR2(Y,A,B);
 input A,B;
 output Y;

 or       U756(Y, A, B);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults



/*--------------------------------------------------------------------
 CELL NAME : OR2A
 CELL TYPE : comb
 CELL LOGIC : Y = !A + B
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module OR2A(Y,A,B);
 input A,B;
 output Y;

 not	INV_156(A_, A);
 or       U759(Y, A_, B);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults



/*--------------------------------------------------------------------
 CELL NAME : OR2B
 CELL TYPE : comb
 CELL LOGIC : Y = !A + !B
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module OR2B(Y,A,B);
 input A,B;
 output Y;

 not	INV_157(A_, A);
 not	INV_158(B_, B);
 or       U762(Y, A_, B_);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults



/*--------------------------------------------------------------------
 CELL NAME : OR3
 CELL TYPE : comb
 CELL LOGIC : Y = A + B + C
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module OR3(Y,A,B,C);
 input A,B,C;
 output Y;
 wire NET_0_0;

 or       U769(NET_0_0, A, B);
 or       U770(Y, NET_0_0, C);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_C_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_C_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
		(C => Y ) = ( tpdLH_C_to_Y, tpdHL_C_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults



/*--------------------------------------------------------------------
 CELL NAME : OR3A
 CELL TYPE : comb
 CELL LOGIC : Y = !A + B + C
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module OR3A(Y,A,B,C);
 input A,B,C;
 output Y;
 wire NET_0_0;

 not	INV_160(A_, A);
 or       U774(NET_0_0, A_, B);
 or       U775(Y, NET_0_0, C);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_C_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_C_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
		(C => Y ) = ( tpdLH_C_to_Y, tpdHL_C_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults



/*--------------------------------------------------------------------
 CELL NAME : OR3B
 CELL TYPE : comb
 CELL LOGIC : Y = !A + !B + C
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module OR3B(Y,A,B,C);
 input A,B,C;
 output Y;
 wire NET_0_0;

 not	INV_161(A_, A);
 not	INV_162(B_, B);
 or       U779(NET_0_0, A_, B_);
 or       U780(Y, NET_0_0, C);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_C_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_C_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
		(C => Y ) = ( tpdLH_C_to_Y, tpdHL_C_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults



/*--------------------------------------------------------------------
 CELL NAME : OR3C
 CELL TYPE : comb
 CELL LOGIC : Y = !A + !B + !C
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module OR3C(Y,A,B,C);
 input A,B,C;
 output Y;
 wire NET_0_0;

 not	INV_163(A_, A);
 not	INV_164(B_, B);
 not	INV_165(C_, C);
 or       U784(NET_0_0, A_, B_);
 or       U785(Y, NET_0_0, C_);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_C_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_C_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
		(C => Y ) = ( tpdLH_C_to_Y, tpdHL_C_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults





/*--------------------------------------------------------------------
 CELL NAME : OAI1
 CELL TYPE : comb
 CELL LOGIC : Y = !((A + B) & C)
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module OAI1(Y,A,B,C);
 input A,B,C;
 output Y;
 wire NET_0_0;

 or       U732(NET_0_0, A, B);
 nand     U733(Y, NET_0_0, C);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_C_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_C_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
		(C => Y ) = ( tpdLH_C_to_Y, tpdHL_C_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults





/*--------------------------------------------------------------------
 CELL NAME : VCC
 CELL TYPE : comb
 CELL LOGIC : Y=1
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module VCC(Y);
 output Y;

 supply1    Y;

       specify

		specparam MacroType = "comb";

		//pin to pin path delay 

   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults



/*--------------------------------------------------------------------
 CELL NAME : XA1B
 CELL TYPE : comb
 CELL LOGIC : Y = (A ^ B) & !C
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module XA1B(Y,A,B,C);
 input A,B,C;
 output Y;
 wire NET_0_0;

 not	INV_173(A_, A);
 not	INV_174(B_, B);
 not	INV_175(C_, C);
 UDP_MUX2   U949(NET_0_0, B, B_, A_);
 and      U951(Y, NET_0_0, C_);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_C_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_C_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
		(C => Y ) = ( tpdLH_C_to_Y, tpdHL_C_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults




/*--------------------------------------------------------------------
 CELL NAME : XNOR2
 CELL TYPE : comb
 CELL LOGIC : Y = !(A ^ B)
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module XNOR2(Y,A,B);
 input A,B;
 output Y;

 not	INV_183(A_, A);
 not	INV_184(B_, B);
 UDPN_MUX2  U972(Y, B, B_, A_);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults



/*--------------------------------------------------------------------
 CELL NAME : XNOR3
 CELL TYPE : comb
 CELL LOGIC : Y = !(A ^ B ^ C)
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module XNOR3(Y,A,B,C);
 input A,B,C;
 output Y;
 wire NET_0_0;

 not	INV_187(A_, A);
 not	INV_188(B_, B);
 UDP_MUX2   U981(NET_0_0, B, B_, A_);
 xnor     U983(Y, NET_0_0, C);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_C_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_C_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
		(C => Y ) = ( tpdLH_C_to_Y, tpdHL_C_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults



/*--------------------------------------------------------------------
 CELL NAME : XOR2
 CELL TYPE : comb
 CELL LOGIC : Y = A ^ B
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module XOR2(Y,A,B);
 input A,B;
 output Y;

 not	INV_193(A_, A);
 not	INV_194(B_, B);
 UDP_MUX2   U998(Y, B, B_, A_);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults



/*--------------------------------------------------------------------
 CELL NAME : ZOR3
 CELL TYPE : comb
 CELL LOGIC : Y = A & B & C + !A & !B & !C
---------------------------------------------------------------------*/

`suppress_faults
`enable_portfaults
`celldefine
`delay_mode_path
`timescale 1 ns / 100 ps

module ZOR3(Y,A,B,C);
 input A,B,C;
 output Y;
 wire NET_0_0, NET_0_1, NET_0_2, NET_0_3;

 not	INV_199(A_, A);
 not	INV_200(B_, B);
 not	INV_201(C_, C);
 and      U1013(NET_0_0, A, B);
 UDP_MUX2   U1014(Y, NET_0_0, NET_0_2, C);
 and      U1017(NET_0_2, A_, B_);

       specify

		specparam tpdLH_A_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_A_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_B_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_B_to_Y = (0.1:0.1:0.1);
		specparam tpdLH_C_to_Y = (0.1:0.1:0.1);
		specparam tpdHL_C_to_Y = (0.1:0.1:0.1);
		specparam MacroType = "comb";

		//pin to pin path delay 

		(A => Y ) = ( tpdLH_A_to_Y, tpdHL_A_to_Y );
		(B => Y ) = ( tpdLH_B_to_Y, tpdHL_B_to_Y );
		(C => Y ) = ( tpdLH_C_to_Y, tpdHL_C_to_Y );
   endspecify

endmodule

`endcelldefine
`disable_portfaults
`nosuppress_faults


