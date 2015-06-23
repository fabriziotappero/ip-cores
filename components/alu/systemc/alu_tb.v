//
`timescale 1ns/1ps

// testbench clock half period					
`define             	CLK_HALF_PERIOD	10000
`define               ZERO	          0
`define               ADD_VERSION

// Use the same defines from the controller
`include  "alu_controller.vh"
`ifdef DECIMAL_DISPLAY
  `define DISPLAY_FORMAT_SELECTED "[%0t ps] A:%d[u%d] S:%s[%b] B:%d[u%d] = Y:%d [u%d]  expected %d [u%d]"
`endif
`ifdef HEX_DISPLAY
  `define DISPLAY_FORMAT_SELECTED "[%0t ps] A:%h[u%h] S:%s[%b] B:%h[u%h] = Y:%h [u%h]  expected %h [u%h]"
`endif
`ifdef BINARY_DISPLAY
  `define DISPLAY_FORMAT_SELECTED "[%0t ps] A:%b[u%b] S:%s[%b] B:%b[u%b] = Y:%b [u%b]  expected %b [u%b]"
`endif

`ifndef DISPLAY_FORMAT_SELECTED 
  `define DISPLAY_FORMAT_SELECTED "[%0t ps] A:%h[u%h] S:%s[%b] B:%h[u%h] = Y:%h [u%h]  expected %h [u%h]"
`endif

`define DISPLAY_FORMAT          `DISPLAY_FORMAT_SELECTED
`define DISPLAY_FORMAT_ERROR    {`DISPLAY_FORMAT_SELECTED, " -- ERROR Output Y is wrong"}

`ifndef verilator
  `define dollar_display_with_error $display(`DISPLAY_FORMAT_ERROR, $time, this_record.A, A_u, this_record.S, S,  this_record.B, B_u, Y, Y_u, result, result_u)
  `define dollar_display_no_error $display(`DISPLAY_FORMAT, $time, this_record.A, A_u, this_record.S, S,  this_record.B, B_u, Y, Y_u, result, result_u)
`else
  `define dollar_display_with_error $display("[%0t ps] A:%h[u%d] S:%s[%b] B:%h[u%d] = Y:%h [u%d]  expected %h [u%d] -- ERROR Output Y is wrong", $time, this_record.A, A_u, this_record.S, S,  this_record.B, B_u, Y, Y_u, result, result_u)
  `define dollar_display_no_error $display("[%0t ps] A:%h[u%h] S:%s[%b] B:%h[u%h] = Y:%h [u%h]  expected %h [u%h]", $time, this_record.A, A_u, this_record.S, S,  this_record.B, B_u, Y, Y_u, result, result_u)
`endif

`ifndef verilator
  `define DOLLAR_RANDOM $random
`else
  `define DOLLAR_RANDOM randomit($time)
`endif
module test_vector;
  parameter DWIDTH  = 8;
  parameter OPWIDTH = 4;
  
	reg signed [DWIDTH-1:0]    A	; // ALU input operand 1
	reg signed [DWIDTH-1:0]    B	; // ALU input operand 2
	reg [8*OPWIDTH-1:0] S	; // ALU input opcode
	reg [DWIDTH-1:0]    Y	; // ALU output
  
endmodule

module alu_tb (systemc_clk);

  // ALU test vector record
  parameter DWIDTH  = 8;
  parameter OPWIDTH = 4;

  input                        systemc_clk      ;
  wire clk;
  // ALU access regs
  reg	        [DWIDTH-1:0 ]    A        /*verilator public*/;
  reg	        [DWIDTH-1:0 ]    B        /*verilator public*/;
  reg	        [OPWIDTH-1:0]    S        ;
  wire signed [DWIDTH-1:0 ]    Y	      ;
  reg			                     CLR      ;

  wire			                   C        ;
  wire			                   V        ;
  wire			                   Z        ;

  // keep a copy of the previous CLR
  reg                          last_CLR ;
  
  // unsigned local copies for the "recorded" copies for stimulus
  // 
  reg	        [DWIDTH-1:0 ]    A_u      ;
  reg	        [DWIDTH-1:0 ]    B_u      ;
  reg         [DWIDTH-1:0 ]    Y_u      ;

  // finished = '1' indicates end of test run
  reg                     finished        ;

  // used to synchronise verification with stimulus
  reg               		  started			    ;

  integer                 infile , success       ;
  integer                 outfile                 ;
  integer                 count                   ;

  reg            	        cc, vv, zz, clrc, space ;
  reg     [DWIDTH-1:0]    aa, bb, yy              ;

  reg     [8*OPWIDTH-1:0] ss, last_ss             ;
	
  reg                     random_mode             ;								
  integer                 random_count            ;
  integer                 random_number           ;
  
  integer                 errors_found            ;
  
  reg [8*OPWIDTH:1]       opcode_list [0:15]      ;
  
 test_vector #(DWIDTH, OPWIDTH) this_record ();
 test_vector #(DWIDTH, OPWIDTH) this_record_reg ();
  test_vector #(DWIDTH, OPWIDTH) next_record (); 
  
  initial
  begin
		opcode_list[`cADD_AB  ] =   "add";
		opcode_list[`cINC_A   ] =  "inca";
		opcode_list[`cINC_B   ] =  "incb";
		opcode_list[`cSUB_AB  ] =   "sub";
		opcode_list[`cCMP_AB  ] =   "cmp";
		opcode_list[`cASL_AbyB] =   "asl";
		opcode_list[`cASR_AbyB] =   "asr";  
	
		opcode_list[`cCLR     ] =   "clr";
		opcode_list[`cDEC_A   ] =  "deca";
		opcode_list[`cDEC_B   ] =  "decb";
		opcode_list[`cMUL_AB  ] =   "mul";
		opcode_list[`cCPL_A   ] =  "cpla";
    opcode_list[`cAND_AB  ] =   "and";
    opcode_list[`cOR_AB   ] =    "or";
    opcode_list[`cXOR_AB  ] =   "xor";
    opcode_list[`cCPL_B   ] =  "cplb";
                     
  end
  
	// instantiate ALU
	alu #(DWIDTH, OPWIDTH) alu_inst0  (
					                            A			,
					                            B			,
					                            S			,
					                            Y			,
					                            CLR		,
					                            clk		,
					                            C			,
					                            V			,
					                            Z
					                          );

	// apply clock stimulus
	//clock_stim	: 	process
  //initial
	//begin
	//	clk	= 1'b0;
  //  forever #100 clk = ~clk;
	//end
  assign clk = ~systemc_clk;
  initial   $display ("START OF VERILOG");
  always @(clk)
  begin
    //`ifdef DEBUG_TB
    $display("Time has reached [%0t] ",$time);
    //`endif
  end
  always @(systemc_clk)
  begin
    //`ifdef DEBUG_TB
    $display("SYSTEMC_CLK Time has reached [%0t] ",$time);
    //`endif
  end
  
  initial errors_found = 0;
  
  // end test
  always @(posedge clk or posedge finished)
  begin
    if (finished)
    begin
      if (errors_found > 0)
        $display("Test FAILED with %d ERRORs [%0t] ", errors_found, $time);
      else
        $display("Test PASSED ");
        
      // close files  and finish
      $finish;
    end
  end

          
	        // apply_test_vectors
          initial
	        begin			
            #1;
					  //file		infile	:	text is in "alu_test.txt";
            `ifdef RANDOM
					    random_count = `RANDOM;
            `else
              random_count = 10;
            `endif
						finished  = 1'b0;
						count	    =    0;
            
						CLR	      = 1'b1;
            
						started   = 1'b0;
            $display ("Generating %0d random inputs", random_count);
          end  
            
						always @(negedge clk)
            begin
							
              count = count + 1;
							
              // verify outputs are as expected
				      
             // `ifdef DEBUG_ALU_TB
             // `endif

                random_number = `DOLLAR_RANDOM                   ;
                `ifdef FORCE_A
                  aa    = `FORCE_A                        ;
                `else
                  aa    = random_number                   ;
                `endif
                
                random_number = `DOLLAR_RANDOM                   ;
                `ifdef FORCE_B
                  bb    = `FORCE_B                        ;
                `else
                  bb    = random_number                   ;
                `endif
                
                random_number = `DOLLAR_RANDOM                   ;
                `ifdef FORCE_OPCODE
                  ss    = `FORCE_OPCODE                   ;
                `else
                  ss    = get_random_opcode(random_number);
                `endif
                
                random_number = `DOLLAR_RANDOM                   ;
                `ifdef FORCE_CLR
                  clrc  = `FORCE_CLR                      ;
                `else
                  clrc  = 0                   ;
                `endif
                
                random_count = random_count - 1;
              
              if (count == 1)
                $display("**** Start of Test ****");
              //$display("[%0t ps] A=%h B=%h SS=%s clrc=%b rand=%d", $time, aa, bb, ss, clrc, random_number);
              //$display("%b %b %s %b", aa, bb, ss, clrc);
              `ifdef DEBUG_ALU_TB
              
                $stop;
              `endif
							
							// wait for falling edge of CLK
							`ifndef verilator
                @(negedge clk);
               `endif
              
              `ifdef DEBUG_ALU_TB
                $display("**** stage2 of Test ****");
                $stop;
              `endif
							// wait for half of half a period
              `ifndef verilator
							  #(`CLK_HALF_PERIOD / 2);
              `endif
							
  
							// apply stimulus to inputs
              `ifdef DEBUG_ALU_TB
                $display("**** stage3 of Test ****");
                $stop;
              `endif
							A	  =	aa                ;
							B	  =	bb                ;
							S	  =	string2opcode(ss) ;
							CLR	=	clrc              ;
							
              `ifdef DEBUG_ALU_TB
                $display("**** stage4 of Test ****");
                $stop;
              `endif
							// store stimulus for use when verifying outputs
							//if (last_ss == "clr")
              //begin
							//	next_record.A	= `ZERO;
							//	next_record.B	= `ZERO;
              //end
							//else
              //begin
								next_record.A	= aa;
								next_record.B	= bb;
							//end
							
              next_record.S	= ss;
              
							// wait for rising edge of clock when data 
							// should be loaded from registers into ALU
							`ifndef verilator
                @(posedge clk);
              `endif
							
							// set local 'started' flag so verification can
							// start
							// grace period of 2 clock cycles for ALU to read
							// first set of data
							
              `ifdef DEBUG_ALU_TB
                $stop;
              `endif
              
              if (!CLR && !started)
              begin
							`ifndef verilator
                @(posedge clk);
								@(posedge clk);
              `endif
								if (count > 3) 
                  started = 1'b1;
							end
              
              if (random_count <= 0)
                finished = 1'b1;
						end // while $feof
					
          function integer randomit ;
          input integer t;
          begin
            randomit = $c("vsc->randomit()");
          end
          endfunction
						// end test
						//finished = 1'b1;
						
					//end // process apply_test_vectors

	        reg signed  [DWIDTH-1:0] result   ;
          reg         [DWIDTH-1:0] result_u ;
          reg         [DWIDTH-1:0] op1      ;
          reg         [DWIDTH-1:0] op2      ;
          
          
          reg check_here;
          initial check_here = 1'b0;
          // verify_test
          always @(negedge clk)
					begin
						// wait a little more after results appear
            `ifndef verilator
						  #(`CLK_HALF_PERIOD/2);
            `endif
						
						// get expected record
						this_record_reg.A <= next_record.A;
            this_record_reg.B <= next_record.B;
            this_record_reg.S <= next_record.S;
            this_record_reg.Y <= next_record.Y;

						this_record.A <= this_record_reg.A;
            this_record.B <= this_record_reg.B;
            this_record.S <= this_record_reg.S;
            this_record.Y <= this_record_reg.Y;

						if (started && !CLR)
            begin
							// convert string operands from this_record
							// into std_logic_vectors
							op1	= this_record.A;
							op2	= this_record.B;

							// depending on opcode command string...perform
							// high level equivalent of ALU operation and store
							// in 'result'
							if 	      (this_record.S ==  opcode_list[`cADD_AB  ]  )  result = op1 + op2          ;
							else if 	(this_record.S ==  opcode_list[`cINC_A   ]  )  result = op1 + 1            ;
							else if 	(this_record.S ==  opcode_list[`cINC_B   ]  )  result = op2 + 1            ;
							else if 	(this_record.S ==  opcode_list[`cSUB_AB  ]  )  result = op1 - op2          ;
							else if 	(this_record.S ==  opcode_list[`cCMP_AB  ]  )  result = Y                  ;
							else if 	(this_record.S ==  opcode_list[`cASL_AbyB]  )  result = bas(op1, op2, 1'b0);
							else if 	(this_record.S ==  opcode_list[`cASR_AbyB]  )  result = bas(op1, op2, 1'b1);
							else if 	(this_record.S ==  opcode_list[`cCLR     ]  )  result = (op1==op2) ? 'd0: Y;
							else if 	(this_record.S ==  opcode_list[`cDEC_A   ]  )  result = op1 - 1            ;
							else if 	(this_record.S ==  opcode_list[`cDEC_B   ]  )  result = op2 - 1            ;
              else if 	(this_record.S ==  opcode_list[`cMUL_AB  ]  )  result = Y                  ;
              else if 	(this_record.S ==  opcode_list[`cCPL_A   ]  )  result = ~op1               ;
              else if 	(this_record.S ==  opcode_list[`cAND_AB  ]  )  result = op1 & op2          ;
              else if 	(this_record.S ==  opcode_list[`cOR_AB   ]  )  result = op1 | op2          ;
              else if 	(this_record.S ==  opcode_list[`cXOR_AB  ]  )  result = op1 ^ op2          ;
              else if 	(this_record.S ==  opcode_list[`cCPL_B   ]  )  result = ~op2               ;
							
								
							// WORKAROUND for bug wher clr lasts for two cycles
              if (last_ss == "clr" || last_CLR)
                result = Y;
 							last_ss			  = this_record.S;
              
              // create signed and unsigned copies of
              // ALU output Y, stimulus values and the expected result
              A_u       = this_record.A ;
              B_u       = this_record.B ;
              Y_u       = Y             ;
              result_u  = result        ;
              
              check_here = ~ check_here; //  for debug
							if( Y != result  || (&result === 1'bx) || (|result === 1'bz)
                  || (&Y === 1'bx) || (|Y === 1'bz))
              begin
                `dollar_display_with_error;
                errors_found = errors_found + 1;
              end
              else
                `dollar_display_no_error;
              
              `ifdef STOP_ON_ERROR
                if (errors_found > `STOP_ON_ERROR)
                begin
                  $display("Maximum error count of %d reached...Terminating simulation", errors_found);
                  $finish;
                end
              `endif
                                
						end // end if (started and !CLR)
            
            last_CLR = CLR;
            
					end // process verify_test


  // function to return the opcode as a std_logic_vector
  // from the given string
  function	[OPWIDTH-1:0] string2opcode;
  input [8*OPWIDTH-1:0] s;
  reg   [8*OPWIDTH:1] t;
	reg [OPWIDTH-1:0]	opcode;
	begin
    
    
		if 		    (s == opcode_list[`cADD_AB   ]) opcode = `cADD_AB   ;
		else if 	(s == opcode_list[`cINC_A    ]) opcode = `cINC_A    ;
		else if 	(s == opcode_list[`cINC_B    ]) opcode = `cINC_B    ;
		else if 	(s == opcode_list[`cSUB_AB   ]) opcode = `cSUB_AB   ;
		else if 	(s == opcode_list[`cCMP_AB   ]) opcode = `cCMP_AB   ;
		else if 	(s == opcode_list[`cASL_AbyB ]) opcode = `cASL_AbyB ;
		else if 	(s == opcode_list[`cASR_AbyB ]) opcode = `cASR_AbyB ;
		else if 	(s == opcode_list[`cCLR      ]) opcode = `cCLR      ;
		else if 	(s == opcode_list[`cDEC_A    ]) opcode = `cDEC_A    ;
		else if 	(s == opcode_list[`cDEC_B    ]) opcode = `cDEC_B    ;
		else if 	(s == opcode_list[`cMUL_AB   ]) opcode = `cMUL_AB   ;
		else if 	(s == opcode_list[`cCPL_A    ]) opcode = `cCPL_A    ;
		else if 	(s == opcode_list[`cAND_AB   ]) opcode = `cAND_AB   ;
		else if 	(s == opcode_list[`cOR_AB    ]) opcode = `cOR_AB    ;
		else if 	(s == opcode_list[`cXOR_AB   ]) opcode = `cXOR_AB   ;
		else if 	(s == opcode_list[`cCPL_B    ]) opcode = `cCPL_B    ;

		string2opcode = opcode;
  end
	endfunction

  
  function [8*OPWIDTH:1] get_random_opcode;
  input integer myseed;
  integer tmp;
  begin
    `ifndef verilator
      tmp = `DOLLAR_RANDOM(myseed);
    `else
      tmp = `DOLLAR_RANDOM;
    `endif
    get_random_opcode = opcode_list[({tmp} % 11)];
  end
  endfunction
  
  function [DWIDTH-1:0] bas ;
  input [DWIDTH-1:0]    a1          ;
  input [DWIDTH-1:0]    shift_size  ;
  input                 direction   ;
  reg   [DWIDTH-1:0]    tmp         ;
  integer               tmp2        ;
  begin
    tmp = a1;
    tmp2 = shift_size[2:0];
    while (tmp2 > 0)
    begin
      if (direction)
        tmp = {tmp[0], tmp[DWIDTH-1:1]};
      else
        tmp = {tmp[DWIDTH-2:0], tmp[DWIDTH-1]};
      tmp2 = tmp2 - 1;
    end
    bas = tmp;
  end
  endfunction
  
  `ifndef NO_WAVES
    initial
    begin
      `ifndef verilator
      $dumpfile("alu_tb.vcd");
      $dumpvars;
      `endif
    end
  `endif

`ifdef verilator

 `systemc_header
#include "verilog_sc.h"	// Header for contained object
 `systemc_interface
   verilog_sc* vsc;	// Pointer to object we are embedding
 `systemc_ctor
   vsc = new verilog_sc();	// Construct contained object
 `systemc_dtor
   delete vsc;	// Destruct contained object
 `verilog
 
`endif

endmodule

