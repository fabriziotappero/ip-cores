// port from university project for ALU in VHDL
// 
`include "alu_controller.vh"
module alu_controller (
                        add_AB          ,
                        inc_A           ,
                        inc_B           ,
                        sub_AB          ,
                        cmp_AB          ,
                        sl_AB           ,
                        sr_AB           ,
                        clr             ,
                        dec_A           ,
                        dec_B           ,
                        mul_AB          ,
                        cpl_A           ,
                        and_AB          ,
                        or_AB           ,
                        xor_AB          ,
                        cpl_B           ,

                        clr_Z           ,
                        clr_V           ,
                        clr_C           ,

                        load_inputs     ,
                        load_outputs    ,

                        opcode          ,
                        reset           , 
                        clk          
                       );

  // default opcode bit width
  parameter OPWIDTH = 4;
  parameter OPBITS  = 1<<OPWIDTH;
  
  output                    add_AB          ;
  output                    inc_A           ;
  output                    inc_B           ;
  output                    sub_AB          ;
  output                    cmp_AB          ;
  output                    sl_AB           ;
  output                    sr_AB           ;
  output                    clr             ;
  output                    dec_A           ;
  output                    dec_B           ;
  output                    mul_AB          ;
  output                    cpl_A           ;
  output                    and_AB          ;
  output                    or_AB           ;
  output                    xor_AB          ;
  output                    cpl_B           ;
                                  
  output                    clr_Z           ;
  output                    clr_V           ;
  output                    clr_C           ;
                                  
  output                    load_inputs     ;
  output                    load_outputs    ;
                                    
  reg                       load_inputs     ;
  reg                       load_outputs    ;

  input    [OPWIDTH-1:0]    opcode          ;
  input                     reset           ;
  input                     clk             ; 



  reg    [OPWIDTH-1     :0] this_opcode     ;
  reg    [OPWIDTH-1     :0] next_opcode     ;
  
  reg    [(1<<OPBITS)+1:0]  opcode_sel      ;


  assign add_AB =   opcode_sel[ `cADD_AB  ];
  assign inc_A  =   opcode_sel[ `cINC_A   ];
  assign inc_B  =   opcode_sel[ `cINC_B   ];
  assign sub_AB =   opcode_sel[ `cSUB_AB  ];
  assign cmp_AB =   opcode_sel[ `cCMP_AB  ];
  assign sl_AB  =   opcode_sel[ `cASL_AbyB];
  assign sr_AB  =   opcode_sel[ `cASR_AbyB];
  assign clr    =   opcode_sel[ `cCLR     ];
  assign dec_A  =   opcode_sel[ `cDEC_A   ];
  assign dec_B  =   opcode_sel[ `cDEC_B   ];
  assign mul_AB =   opcode_sel[ `cMUL_AB  ];
  assign cpl_A  =   opcode_sel[ `cCPL_A   ];
  assign and_AB =   opcode_sel[ `cAND_AB  ];
  assign or_AB  =   opcode_sel[ `cOR_AB   ];
  assign xor_AB =   opcode_sel[ `cXOR_AB  ];
  assign cpl_B  =   opcode_sel[ `cCPL_B   ];
  
  // [leo 22MAR09 TOREVIEW] to be reviewed
  //assign clr_Z  =   opcode_sel[   `clrZ];
  //assign clr_V  =   opcode_sel[   `clrV];
  //assign clr_C  =   opcode_sel[   `clrC];
  
  // state control
  //always @(posedge clk or reset)
  always @(posedge clk or reset) // for systemc
  begin
    if    (reset)
      this_opcode <= `cCLR;
    else
      this_opcode <= opcode;

  end
        
  // FSM 
  always @(this_opcode)
  begin

    // reset opcode_sel signals
    opcode_sel    <= 'h0;
    load_inputs   <= 'h0;

    case (this_opcode)
      `cCLR     :
			begin
        opcode_sel[`cCLR   ]       <= 1'b1  ;
			end
      `cADD_AB  :
			begin
        opcode_sel[`cADD_AB]       <= 1'b1;
        load_inputs                <= 1'b1;
        load_outputs               <= 1'b1;       

			end
      `cINC_A    :
			begin

        opcode_sel[`cINC_A]        <= 1'b1;
        load_inputs                <= 1'b1;
        load_outputs               <= 1'b1;       

			end
      `cINC_B    :
			begin

        opcode_sel[`cINC_B]        <= 1'b1;
        load_inputs                <= 1'b1;
        load_outputs               <= 1'b1;       

			end
      `cDEC_A    :
			begin

        opcode_sel[`cDEC_A]        <= 1'b1;
        load_inputs                <= 1'b1;
        load_outputs               <= 1'b1;       

			end
      `cDEC_B    :
			begin

        opcode_sel[`cDEC_B]        <= 1'b1;
        load_inputs                <= 1'b1;
        load_outputs               <= 1'b1;       

			end
      `cSUB_AB  :
			begin

        opcode_sel[`cSUB_AB]       <= 1'b1;
        load_inputs                <= 1'b1;
        load_outputs               <= 1'b1;       

			end
      `cCMP_AB  :
			begin

        opcode_sel[`cCMP_AB]       <= 1'b1;
        load_inputs                <= 1'b1;

			end
      `cAND_AB  :
			begin

        opcode_sel[`cAND_AB]       <= 1'b1;
        load_inputs                <= 1'b1;
        load_outputs               <= 1'b1;       

			end
      `cOR_AB    :
			begin

        opcode_sel[`cOR_AB]        <= 1'b1;
        load_inputs                <= 1'b1;
        load_outputs               <= 1'b1;       

			end
      `cXOR_AB  :
			begin

        opcode_sel[`cXOR_AB]       <= 1'b1;
        load_inputs                <= 1'b1;
        load_outputs               <= 1'b1;       

			end
      `cMUL_AB  :
			begin

        opcode_sel[`cMUL_AB]       <= 1'b1;
        load_inputs                <= 1'b1;
        load_outputs               <= 1'b1;       

			end
      `cCPL_A    :
			begin

        opcode_sel[`cCPL_A]        <= 1'b1;
        load_inputs                <= 1'b1;
        load_outputs               <= 1'b1;       

			end
      `cCPL_B    :
			begin

        opcode_sel[`cCPL_B]        <= 1'b1;
        load_inputs                <= 1'b1;
        load_outputs               <= 1'b1;       

			end
      `cASL_AbyB  :
			begin

        opcode_sel[`cASL_AbyB]     <= 1'b1;
        load_inputs                <= 1'b1;
        load_outputs               <= 1'b1;       

			end
      `cASR_AbyB  :
			begin

        opcode_sel[`cASR_AbyB]     <= 1'b1;
        load_inputs                <= 1'b1;
        load_outputs               <= 1'b1;       

			end
      default :
			begin
        next_opcode       <= this_opcode;
      end
			endcase
  end // always begin for FSM
endmodule
