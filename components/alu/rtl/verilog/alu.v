// port from university ALU VHDL project
//
// ECPU ALU version 0.1.alpha
module alu (A, B, S, Y, CLR, CLK, C, V, Z);

  parameter DWIDTH  = 16;
  parameter OPWIDTH =  4;
  
	input	  [(DWIDTH -1):0]  A     ; 
	input 	[(DWIDTH -1):0]  B     ; 
	input 	[(OPWIDTH-1):0]  S     ; 
	output	[(DWIDTH -1):0]  Y     ; 
	input 	                 CLR   ;
	input	                   CLK   ;
	output	                 C     ;
	output	                 V     ;
	output	                 Z     ;

  wire					           add_AB        ;
  wire					           inc_A         ;
  wire					           inc_B         ;
  wire					           sub_AB        ;
  wire					           cmp_AB        ;
  wire					           sl_AB         ;
  wire					           sr_AB         ;
  wire					           clr_ALL       ;
  wire					           dec_A         ;
  wire					           dec_B         ;
  wire					           mul_AB        ;
  wire					           cpl_A         ;
  wire					           and_AB        ;
  wire					           or_AB         ;
  wire					           xor_AB        ;
  wire					           cpl_B         ;

  wire					           clr_Z          ;
  wire					           clr_V          ;
  wire					           clr_C          ;

  wire					           reset          ;
  wire					           load_inputs    ;
  wire					           load_outputs   ;

  `ifdef ADD_VERSION
    wire                   VERSION        ;
    assign VERSION = "0.1.alpha";
  `endif
  
	// clear is the same as reset
	assign reset	=	CLR;
  
  // controller instance
	alu_controller #(OPWIDTH) controller     (
                                            add_AB      ,
                                            inc_A       ,
                                            inc_B       ,
                                            sub_AB      ,
                                            cmp_AB      ,
                                            sl_AB       ,
                                            sr_AB       ,
                                            clr_ALL     ,
                                            dec_A       ,
                                            dec_B       ,
                                            mul_AB      ,
                                            cpl_A       ,
                                            and_AB      ,
                                            or_AB       ,
                                            xor_AB      ,
                                            cpl_B       ,

                                            clr_Z		    ,
                                            clr_V		    ,
                                            clr_C		    ,

                                            load_inputs	,
                                            load_outputs,

                                            S			      ,

                                            reset		    ,
                                            CLK
					                                );
                                
  // datapath instance                              
	alu_datapath #(DWIDTH) datapath	        (
					                                  A			        ,
					                                  B			        ,
					                                  Y			        ,

					                                  add_AB        ,
					                                  inc_A         ,
					                                  inc_B         ,
					                                  sub_AB        ,
					                                  cmp_AB        ,
					                                  sl_AB         ,
					                                  sr_AB         ,
					                                  clr_ALL       ,
					                                  dec_A         ,
					                                  dec_B         ,
					                                  mul_AB        ,
					                                  cpl_A         ,
					                                  and_AB        ,
					                                  or_AB         ,
					                                  xor_AB        ,
                                            cpl_B         ,

					                                  clr_Z		      ,
					                                  clr_V		      ,
					                                  clr_C		      ,

					                                  C			        ,
					                                  V			        ,
					                                  Z			        ,

					                                  load_inputs	  ,
					                                  load_outputs  ,

					                                  reset         ,

					                                  CLK
					                                );
endmodule
