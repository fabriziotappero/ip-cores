// ported from university project for alu in VHDL
module alu_datapath (
                      A                             , 
                      B                             , 
                      Y                             , 
                      
                      add_AB                        ,  
                      inc_A                         ,  
                      inc_B                         ,  
                      sub_AB                        ,  
                      cmp_AB                        ,  
                      sl_AB                         ,  
                      sr_AB                         ,  
                      clr                           ,  
                      dec_A                         ,  
                      dec_B                         ,  
                      mul_AB                        ,  
                      cpl_A                         ,  
                      and_AB                        ,  
                      or_AB                         ,  
                      xor_AB                        ,  
                      cpl_B                         ,

                      clr_Z                         , 
                      clr_V                         , 
                      clr_C                         , 

                      C                             , 
                      V                             , 
                      Z                             , 

                      load_inputs                   ,
                      load_outputs                  ,
                      
                      reset                         ,
                      clk
                    );

  // data input/output width for the ALU
  parameter			      ALU_WIDTH = 8;

  input   [ALU_WIDTH - 1:0]  A           ;
  input   [ALU_WIDTH - 1:0]  B           ;
  output  [ALU_WIDTH - 1:0]  Y           ;

  input                      add_AB      ;  // ALU control commands   
  input                      inc_A       ;
  input                      inc_B       ;
  input                      sub_AB      ;
  input                      cmp_AB      ;
  input                      sl_AB       ;
  input                      sr_AB       ;
  input                      clr         ;
  input                      dec_A       ;
  input                      dec_B       ;
  input                      mul_AB      ; // Not yet implemented
  input                      cpl_A       ;
  input                      and_AB      ;
  input                      or_AB       ;
  input                      xor_AB      ;  // soft reset! via opcode 
  input                      cpl_B       ;

  input                      clr_Z       ;                            
  input                      clr_V       ;                            
  input                      clr_C       ;                            

  output                     C           ;  // carry flag             
  output                     V           ;  // overflow flag          
  output                     Z           ;  // ALU result = 0         

  input                      load_inputs ;                            
  input                      load_outputs;                            

  input                      reset       ;  // hard reset!            

  input                      clk         ;  // clk wire              


  wire	[ALU_WIDTH - 1:0] adder_in_a        ;
  wire	[ALU_WIDTH - 1:0] adder_in_b        ;
  wire	[ALU_WIDTH - 1:0] adder_out         ;
    
  wire	[ALU_WIDTH - 1:0] shifter_inA       ;
  wire	[ALU_WIDTH - 1:0] shifter_inB       ;
  wire	[ALU_WIDTH - 1:0] shifter_out       ;
  
  wire	                  shifter_carry     ;
  wire	                  shifter_direction ;
  
  wire	                  carry_in          ;
  wire	                  carry             ;
  wire	                  adderORsel        ;
  wire	                  adderXORsel       ;
    
  wire	[ALU_WIDTH    :0] carry_out         ;
  
  wire	[ALU_WIDTH - 1:0] AandB             ;
  wire	[ALU_WIDTH - 1:0] AxorB             ;
  wire	[ALU_WIDTH - 1:0] AorB              ;

  wire	[ALU_WIDTH - 1:0]	logic0            ;
  wire	[ALU_WIDTH - 1:0]	logic1            ;

  
  reg	  [ALU_WIDTH - 1:0] Areg              ;
  reg	  [ALU_WIDTH - 1:0] Breg              ;
  reg	  [ALU_WIDTH - 1:0] Yreg              ;
  reg		                  Zreg              ;
  reg		                  Creg              ;
  reg		                  Vreg              ;
  
  wire  [ALU_WIDTH - 1:0] alu_out           ;
  

	assign logic1		= 'd1	;
	assign logic0		= 'd0	;

	// assign registers to outputs
	assign Y = Yreg;
	assign Z = Zreg;
	assign C = Creg;
	assign V = Vreg;
	
	// inputs to adder
	assign adder_in_a	=	(cpl_B) ? 'd0 :	((cpl_A) ? ~Areg : ((inc_B) ? 1'b0 :((dec_B) ? {ALU_WIDTH{1'b1}} :Areg)) );

  assign  adder_in_b = (!sub_AB && !inc_A && !cpl_A && !cpl_B) ? ((dec_A) ? {ALU_WIDTH{1'b1}} : Breg) : 
                          (((sub_AB && !inc_A) || cpl_B) ? ~Breg : 
                            ((!sub_AB && inc_A && !cpl_B) ?'d0     : 
                              ((cpl_A) ? 'd0 : adder_in_b)));
	
	// carry_in to adder is set to 1 during subtract and increment
	// operations
	assign  carry_in  = (sub_AB || inc_A || inc_B) ? 1'b1 : 1'b0;
  				
	// select appropriate alu_output to go to Z depending
	// on control wires
          
  assign alu_out = ((and_AB || or_AB) && (!sl_AB && !sr_AB))  ? carry_out[ALU_WIDTH:1] 
                                        : ((sl_AB || sr_AB) ? shifter_out 
                                                            : adder_out);
					
	// selects use of the Adder as an OR gate
	assign adderORsel	= (or_AB) ? 'b1 : 'b0;
  
	// selects use of the Adder as an XOR gate
	// or as a compare [which uses the XOR function]
	assign adderXORsel	=	(xor_AB || cmp_AB) ? 'b0 : 'b1;
					
	// set/unset carry flag depending on relevant conditions
  assign carry = (add_AB && !and_AB && !or_AB && !xor_AB && !cpl_B && !clr) ? 
                    carry_out[ALU_WIDTH] :  
                      ((and_AB || or_AB || xor_AB || cpl_B || clr) ?
                        'b0 : ((sl_AB ||  sr_AB)  ? shifter_carry :carry));

					
	// barrel shifter wires
	assign shifter_direction	=	(sr_AB) ? 'b1	:	'b0;
							
	assign shifter_inA = Areg;
	assign shifter_inB = Breg;
	
	alu_adder #(ALU_WIDTH) adder            (
					                                  .x	    		(adder_in_a ) ,
					                                  .y			    (adder_in_b )	,
					                                  .carry_in	  (carry_in   )	,
					                                  .ORsel		  (adderORsel )	,
					                                  .XORsel		  (adderXORsel)	,
					                                  .carry_out	(carry_out  )	,
					                                  .z			    (adder_out  )
				                                  );

	alu_barrel_shifter #(ALU_WIDTH) shifter	(
					                                  .x			    (shifter_inA      ) ,
					                                  .y			    (shifter_inB      ) ,
					                                  .z			    (shifter_out      ) ,
					                                  .c			    (shifter_carry    ) ,
					                                  .clk		    (clk              ) ,
					                                  .direction	(shifter_direction)
					                                );

	//registered_ios
  always @(posedge clk or posedge reset)
						begin
							if (reset)
              begin
								Areg	<=	'd0;
								Breg	<=	'd0;
								Yreg	<=	'd0;

								Zreg	<= 	'b1;
								Creg	<= 	'b0;
								Vreg	<= 	'b0;
              end
							else
              begin
								if (load_inputs)
                begin
									Areg	<=	A;
									Breg	<=	B;
                end
								if (load_outputs)
									Yreg	<= alu_out;
								
								//// clear command clears all registers
								//// and the carry bit
								if (clr)
                begin
									Areg	<=	'd0;
									Breg	<=	'd0;
									Yreg	<=	'd0;
	
									Creg	<= 	'b0;
                end


								if (clr_Z)
									Zreg	<= 'b0;
								if (clr_C)
									Creg	<= 'b0;
								if (clr_V)
									Vreg	<= 'b0;
								
								// set the Z register 
								if 		(alu_out == 'd0)
									Zreg	<= 'b1;
								else
									Zreg	<= 'b0;
								
                                
								Creg	<= carry;
							end
						end // end always registered IOs;
	
	
endmodule


