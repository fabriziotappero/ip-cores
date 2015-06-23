//Jun.28.2004
//Jun.30.2004 jump bug fix
//Jul.11.2004 target special zero 
//Jan.20.2005 apply @*
`include "define.h"
//`define ALTERA
module decoder(clock,sync_reset,MWriteD1,RegWriteD2,A_Right_SELD1,RF_inputD2,
RF_input_addr,M_signD1,M_signD2,M_access_modeD1,M_access_modeD2,
ALU_FuncD2,Shift_FuncD2,source_addrD1,target_addrD1,IMMD2,
source_addrD2,target_addrD2,Shift_amountD2,PC_commandD1,IMMD1,IRD1,takenD3,takenD2,beqQ,bneQ,blezQ,bgtzQ,
DAddress,PC,memory_indata,MOUT,IMM,branchQQ,jumpQ,int_req,clear_int,int_address,
A_Left_SELD1,RRegSelD1,MWriteD2,NOP_Signal,mul_alu_selD2,mul_div_funcD2,
pause_out,control_state,Shift_Amount_selD2,uread_port,int_stateD1,bgezQ,bltzQ,write_busy);

	input clock,sync_reset;
	input takenD3,takenD2;
	output MWriteD1,RegWriteD2;
	output [1:0] A_Right_SELD1;
	output [1:0] RF_inputD2;
	output M_signD1,M_signD2;
	output [1:0] M_access_modeD1,M_access_modeD2;
	output [3:0] ALU_FuncD2;
	output [1:0] Shift_FuncD2;
	output [25:0] IMMD2,IMMD1;
	output [4:0] source_addrD2,target_addrD2;
	output [4:0] source_addrD1,target_addrD1,Shift_amountD2;
	output [4:0] RF_input_addr;
	output [2:0] PC_commandD1;
	output [31:0] IRD1;
	output beqQ,bneQ,blezQ,bgtzQ;
	output bgezQ,bltzQ;
	input [7:0] uread_port;
	output int_stateD1;
	input write_busy;//Apr.2.2005

`ifdef RAM4K
	input  [11:0] DAddress,PC;
	input [11:0] int_address;
`else	
	input  [25:0] DAddress,PC;
	input [25:0] int_address;
`endif


	input [31:0] memory_indata;
	output [31:0] MOUT;
	output [25:0] IMM;
	output branchQQ,jumpQ;
	input int_req;
	output clear_int;

	output  A_Left_SELD1;
	output [1:0] RRegSelD1;
	output MWriteD2;
	output NOP_Signal;
	output [1:0] mul_alu_selD2;
	output [3:0] mul_div_funcD2;
	input pause_out;
	output [7:0] control_state;
	output Shift_Amount_selD2;
//For Debug Use
	localparam [4:0] zero_=0,
				     at_=1,
				     v0_=2,
				     v1_=3,
				     a0_=4,
				     a1_=5,
				     a2_=6,
				     a3_=7,
				     t0_=8, t1_=9,t2_=10,t3_=11,t4_=12,t5_=13,t6_=14,t7_=15,
				     s0_=16,s1_=17,s2_=18,s3_=19,s4_=20,s5_=21,s6_=22,s7_=23,t8_=24,t9_=25,
				     k0_=26,k1_=27,gp_=28,sp_=29,s8_=30,ra_=31;	


//regsiters
	reg [31:0] IRD1;
	reg [31:0] IRD2;
	reg [1:0] RF_input_addr_selD1;
	reg [4:0] RF_input_addr;
	reg [1:0] Shift_FuncD1,Shift_FuncD2;
	reg [3:0] ALU_FuncD2;
	reg [1:0] A_Right_SELD1;
	reg [1:0] RF_inputD2,RF_inputD1;
	reg [1:0] M_access_modeD1,M_access_modeD2;
	reg M_signD1,M_signD2;
	
	reg MWriteD1,RegWriteD2,RegWriteD1,MWriteD2;
	reg [2:0] PC_commandD1;
	reg beqQ,bneQ,blezQ,bgtzQ;
	reg bltzQ,bgezQ;//Jul.11.2004
	reg branchQ,branchQQ,jumpQ;
	reg [7:0] control_state;
	reg sync_resetD1;
	reg [31:0] memory_indataD2;
	reg  A_Left_SELD1;
	reg  [1:0] RRegSelD1;
	reg takenD4,takenD5;
	reg nop_bit;
	reg [1:0] mul_alu_selD2;
	reg mul_div_funcD1;
	reg div_mode_ff;
	reg [3:0] mul_div_funcD2;
	reg excuting_flag;
	reg excuting_flagD,excuting_flagDD;
	reg Shift_Amount_selD2;
	reg int_seqD1;
//wires					
  	wire [31:0] IR;

	wire [5:0] opecode=IR[31:26];
	wire [5:0] opecodeD1=IRD1[31:26];
	wire [5:0] opefuncD1=IRD1[5:0];
	wire [5:0] opefunc=IR[5:0];
	wire [4:0] destination_addrD1;//Apr.8.2005

	wire NOP_Signal;
	wire finish_operation;

	

	assign int_stateD1=control_state==5;

	assign IMMD2=IRD2[25:0];
	assign IMMD1=IRD1[25:0];
	assign source_addrD2=IRD2[25:21];
	assign target_addrD2=IRD2[20:16];
	assign source_addrD1=IRD1[25:21];
	assign target_addrD1=IRD1[20:16];
	assign destination_addrD1=IRD1[15:11];
	assign Shift_amountD2=IRD2[10:6];
	assign IMM=IR[25:0];

`ifdef  Veritak //Disassenblar
	reg [30*8:1] inst;
	wire [5:0] op=IR[31:26];
	wire [25:0] bra=PC+{{10{IR[15]}},IR[15:0]}*4;//+4;
	wire [4:0] rs=IR[25:21];
	wire [4:0] rt=IR[20:16];
	wire [4:0] rd=IR[15:11];
	wire [4:0] sh=IR[10:6];
	reg [5*8:1] reg_name="abcd";

     reg [30*8:1] instD1,instD2;

	function [4*8:1] get_reg_name;
		input [4:0] field;
		begin
			case (field)
				0: get_reg_name="$z0";
				1: get_reg_name="$at";
				2: get_reg_name="$v0";
				3: get_reg_name="$v1";
				4: get_reg_name="$a0";
				5: get_reg_name="$a1";
				6: get_reg_name="$a2";
				7: get_reg_name="$a3";
				8,9,10,11,12,13,14,15:
				   $sprintf(get_reg_name,"$t%1d",field-8);
				16,17,18,19,20,21,22,23,24,25: $sprintf(get_reg_name,"$s%1d",field-16);
				26:get_reg_name="$k0";
				27:get_reg_name="$k1";
				28:get_reg_name="$gp";
				29:get_reg_name="$sp";
				30:get_reg_name="$s8";
				31:get_reg_name="$ra";
			endcase
		end
	endfunction

	always @(posedge clock) begin
		instD1<=inst;
		instD2<=instD1;
	end

	always @*begin:sprintf //Jan.20.2005  @ (IR,op,bra,rs,rt,rd,sh) begin :sprintf
	  reg [4*8:1] rdn;//Mar.15.2005 =get_reg_name(rd);//
	  reg [4*8:1] rsn;//Mar.15.2005=get_reg_name(rs);
	  reg [4*8:1] rtn;//Mar.15.2005 =get_reg_name(rt);
	  rdn=get_reg_name(rd);	
	  rsn=get_reg_name(rs);
	  rtn=get_reg_name(rt);
	  case (op)
	   0:	
		case (IR[5:0])
			0: if (rd==0 && rt==0 && rs==0 ) $sprintf(inst,"nop");
			   else $sprintf(inst,"sll %s,%s,%2d\n",rdn,rtn,sh);
			2:
				$sprintf(inst," srl %s,%s,%2d\n",rdn,rtn,sh);
			
		      3:
				$sprintf(inst," sra %s,%s,%2d\n",rdn,rtn,sh);
			
		       4:
				$sprintf(inst," sllv %s,%s,%s\n",rdn,rtn,rsn);
			
		       6:
				$sprintf(inst," srlv %s,%s,%s\n",rdn,rtn,rsn);
			
		 7:
			$sprintf(inst," srav %s,%s,%s\n",rdn,rtn,rsn);
			
		 8:
			$sprintf(inst," jr %s\n",rsn);
			
		 9:
			$sprintf(inst," jalr %s\n",rsn);
			
		 12:
			$sprintf(inst," syscall\n");
			
		 13:
			$sprintf(inst," break");
			
		 16:
			$sprintf(inst," mfhi %s\n",rdn);
			
		 17:
			$sprintf(inst," mthi %s\n",rsn);
			
		 18:
			$sprintf(inst," mflo %s\n",rdn);
			
		 19:
			$sprintf(inst," mtlo %s\n",rsn);
			
		 24:
			$sprintf(inst," mult %s,%s\n",rsn,rtn);
			
		 25:
			$sprintf(inst," multu %s,%s\n",rsn,rtn);
			
		 26:
			$sprintf(inst," div %s,%s\n",rsn,rtn);
			
		 27:
			$sprintf(inst," divu %s,%s\n",rsn,rtn);
			
		 32:
			
			$sprintf(inst," add %s,%s,%s",rdn,rsn,rtn);
			
		 33:
			if(rt==0)
				$sprintf(inst," move %s,%s\n",rdn,rsn);
			else
				$sprintf(inst," addu %s,%s,%s\n",rdn,rsn,rtn);
			
		 34:
			$sprintf(inst," sub %s,%s,%s\n",rdn,rsn,rtn);
			
		 35:
			$sprintf(inst," subu %s,%s,%s\n",rdn,rsn,rtn);
			
		 36:
			$sprintf(inst," and %s,%s,%s\n",rdn,rsn,rtn);
			
		 37:
			if(rt==0) 
				$sprintf(inst," move %s,%s\n",rdn,rsn);
			 else
				$sprintf(inst," or %s,%s,%s\n",rdn,rsn,rtn);
			
		 38:
			$sprintf(inst," xor %s,%s,%s\n",rdn,rsn,rtn);
			
		 39:
			$sprintf(inst," nor %s,%s,%s\n",rdn,rsn,rtn);
			
		 42:
			$sprintf(inst," slt %s,%s,%s\n",rdn,rsn,rtn);
			
		 43:
			$sprintf(inst," sltu %s,%s,%s\n",rdn,rsn,rtn);
			
		default:
			$sprintf(inst,"Unknown Func. %08h\n",IR);
			
		
		

		endcase
	    1:
		case (IR[20:16])
		 0:
			$sprintf(inst," bltz %s,$%08h\n",rsn,bra);
			
		 1:
			$sprintf(inst," bgez %s,$%08h\n",rsn,bra);
			
		 16:
			$sprintf(inst," bltzal %s,$%08h\n",rsn,bra);
			
		 17:
			$sprintf(inst," bgezal %s,$%08h\n",rsn,bra);
			
		default:
			$sprintf(inst,"Unknown1 %08h\n",IR);
			
		endcase
		
	 2:
		$sprintf(inst," j $%08h\n",((IR*4)&32'h0ffffffc)+(PC&32'hf0000000));
		
	 3:
		$sprintf(inst," jal $%08h\n",((IR*4)&32'h0ffffffc)+(PC&32'hf0000000));
		
	 4:
		if(rs==0 && rt==0)
			$sprintf(inst," bra $%08h\n",bra);
		else
			$sprintf(inst," beq %s,%s,$%08h\n",rsn,rtn,bra);
		
	 5:
		$sprintf(inst," bne %s,%s,$%08h\n",rsn,rtn,bra);
		
	 6:
		$sprintf(inst," blez %s,$%08h\n",rsn,bra);
		
	 7:
		$sprintf(inst," bgtz %s,$%08h\n",rsn,bra);
		
	 8:
		$sprintf(inst," addi %s,%s,#$%04h\n",rtn,rsn,IR[15:0]);
		
	 9:
		if(rs==0)
			$sprintf(inst," li %s,#$%08h\n",rtn,IR[15:0]);
		else
			$sprintf(inst," addiu %s,%s,#$%04h\n",rtn,rsn,IR[15:0]);
		
	 10:
		$sprintf(inst," slti %s,%s,#$%04h\n",rtn,rsn,IR[15:0]);
		
	 11:
		$sprintf(inst," sltiu %s,%s,#$%04h\n",rtn,rsn,IR[15:0]);
		
	 12:
		$sprintf(inst," andi %s,%s,#$%04h\n",rtn,rsn,IR[15:0]);
		
	 13:
		if(rs==0)
			$sprintf(inst," li %s,#$%08h\n",rtn,IR[15:0]);
		else
			$sprintf(inst," ori %s,%s,#$%04h\n",rtn,rsn,IR[15:0]);
		
	 14:
		$sprintf(inst," xori %s,%s,#$%04h\n",rtn,rsn,IR[15:0]);
		
	 15://load upper immediate

			$sprintf(inst," lui %s,#$%04h",rtn,IR[15:0]);
		
	 16, 17, 18, 19: begin
		if(rs>=16)
			$sprintf(inst," cop%d $%08h\n",op&3,IR[25:0]);
		 else
		case(rsn)
		 0:
			$sprintf(inst," mfc%d %s,%s\n",op&3,rtn,rdn);
			
		 2:
			$sprintf(inst," cfc%d %s,%s\n",op&3,rtn,rdn);
			
		 4:
			$sprintf(inst," mtc%d %s,%s\n",op&3,rtn,rdn);
			
		 6:
			$sprintf(inst," ctc%d %s,%s\n",op&3,rtn,rdn);
			
		 8, 12:
			if(rt&1)
				$sprintf(inst," bc%dt %d,%08h\n",op&3,rs*32+rt,bra);
			 else 
				$sprintf(inst," bc%df %d,%08h\n",op&3,rs*32+rt,bra);
			
			
		 default:
			$sprintf(inst,"Unknown16 %08h\n",IR);
		 endcase
		end
	 32:
		$sprintf(inst," lb %s,$%04h(%s)\n",rtn,IR[15:0],rsn);
		
	 33:
		$sprintf(inst," lh %s,$%04h(%s)\n",rtn,IR[15:0],rsn);
		
	 34:
		$sprintf(inst," lwl %s,$%04h(%s)\n",IR[15:0],rsn);
		
	 35:
		$sprintf(inst," lw %s,$%04h(%s)\n",rtn,IR[15:0],rsn);
		
	 36:
		$sprintf(inst," lbu %s,$%04h(%s)\n",rtn,IR[15:0],rsn);
		
	 37:
		$sprintf(inst," lhu %s,$%04h(%s)\n",rtn,IR[15:0],rsn);
		
	 38:
		$sprintf(inst," lwr %s,$%04h(%s)\n",rtn,IR[15:0],rsn);
		
	 40:
		$sprintf(inst," sb %s,$%04h(%s)\n",rtn,IR[15:0],rsn);
		
	 41:
		$sprintf(inst," sh %s,$%04h(%s)\n",rtn,IR[15:0],rsn);
		
	 42:
		$sprintf(inst," swl %s,$%04h(%s)\n",rtn,IR[15:0],rsn);
		
	 43:
		$sprintf(inst," sw %s,$%04h(%s)\n",rtn,IR[15:0],rsn);
		
	 46:
		$sprintf(inst," swr %s,$%04h(%s)\n",rtn,IR[15:0],rsn);
		
	 48, 49, 50, 51:
		$sprintf(inst," lwc%d %s,$%04h(%s)\n",op&3,rtn,IR[15:0],rsn);
		
	 56, 57, 58, 59:
		$sprintf(inst," swc%d %s,$%04h(%s)\n",op&3,rtn,IR[15:0],rsn);
		
	default:
		$sprintf(inst,"UnknownOp %08h\n",IR);
		
	

	 
	endcase
   end


`endif
//
		always @ (posedge clock) 	sync_resetD1 <=sync_reset; 


//IRD1
	always @ (posedge clock) begin
		if (sync_resetD1) IRD1 <=32'h00;
		else if ((control_state[5:0]==6'b00_0000 && int_req)  ) IRD1<=int_address>>2;
		else if (opecode==6'b000_001) IRD1<={IR[31:21],5'b00000,IR[15:0]};//Jul.11.2004 target ‚ªSpecial zero
 		else IRD1 <=IR;
	end

//IRD2
	always @ (posedge clock) begin
	  IRD2 <=IRD1;
	end

//RF_input_addr [4:0]
	always @ (posedge clock) begin
		 case (RF_input_addr_selD1)
			`RF_Ert_sel: RF_input_addr <=target_addrD1;
			`RF_Erd_sel: RF_input_addr <=destination_addrD1;
			`RF_R15_SEL: RF_input_addr <=`Last_Reg;
			`RF_INTR_SEL:RF_input_addr <=`Intr_Reg;
			 default   : RF_input_addr <=target_addrD1;
		     endcase
	end

//int_seqD1	
	always @(posedge clock) begin
		if (sync_reset) int_seqD1<=0;
		else  int_seqD1<=control_state[5:0]==6'b00_0000 && int_req;

	end


// [1:0] Shift_FuncD1,Shift_FuncD2;
	always @ (posedge clock) begin
		Shift_FuncD2<=Shift_FuncD1;
	end

// [3:0] ALU_FuncD1,ALU_FuncD2;



	always @ (posedge clock) begin
		M_access_modeD2<=M_access_modeD1;
	end

//M_signD1,M_signD2;
	always @ (posedge clock) begin
		M_signD2<=M_signD1;
	end

//takenD4
	always @ (posedge clock) begin
		if (sync_resetD1) takenD4<=1'b0;
		else if (NOP_Signal) takenD4<=1'b0;//TRY
		else		      takenD4<=takenD3;
	end
//takenD5
	always @ (posedge clock) begin
		if (sync_resetD1) takenD5<=1'b0;
		else		  takenD5<=takenD4;
	end
//RegWriteD2,RegWriteD1;
	always @ (posedge clock) begin
		if (sync_resetD1) begin
			RegWriteD2<=1'b0;
		end else if (takenD4 ||takenD5  || NOP_Signal ) RegWriteD2<=1'b0;//NOP
		else	RegWriteD2<=RegWriteD1;
		
	end




//Combination logics
//RegWrite;
	always @ (posedge clock) begin
		if (sync_resetD1)			   RegWriteD1<=1'b0;
	        else if (control_state[5:0]==6'b00_0000 && int_req) RegWriteD1<=1'b1;
		else case (opecode)
			`loadbyte_signed    :	   RegWriteD1<=1'b1;		
                   `loadbyte_unsigned :       RegWriteD1<=1'b1;
                   `loadword_signed    :       RegWriteD1<=1'b1;
                   `loadword_unsigned :      RegWriteD1<=1'b1;
                   `loadlong  	   :            RegWriteD1<=1'b1;
			`jump_and_link_im: 	   RegWriteD1<=1'b1;
			`andi	          : 	   RegWriteD1<=1'b1;		
                   `addi             : 	   RegWriteD1<=1'b1 ;
			`addiu           : 	   RegWriteD1<=1'b1;
                    `ori              : 	   RegWriteD1<=1'b1;
			`xori		  : 	   RegWriteD1<=1'b1;
			`lui		  :	          RegWriteD1<=1'b1;
	             `comp_im_signed    : RegWriteD1<=1'b1;
		      `comp_im_unsigned : RegWriteD1<=1'b1;
			6'b00_0000:
					 case (opefunc)
							`divs: RegWriteD1<=1'b0;
							`divu: RegWriteD1<=1'b0;
							`muls: RegWriteD1<=1'b0;
							`mulu: RegWriteD1<=1'b0;
						      default:   RegWriteD1<=1'b1;
					 endcase	
			default:		   RegWriteD1<=1'b0;
		endcase
	end
//
	always @ (posedge clock) begin
		if (sync_resetD1)			   mul_div_funcD1<=1'b0;
	        else if (control_state[5:0]==6'b00_0000 && int_req) mul_div_funcD1<=1'b0;
		else case (opecode)
		
			6'b00_0000:
					 case (opefunc)
							`divs: begin
									mul_div_funcD1<=1'b1;
									div_mode_ff<=1'b1;
								   end	
							`divu: begin 
									mul_div_funcD1<=1'b1;
									div_mode_ff<=1'b1;
								   end
							`muls: begin 
									mul_div_funcD1<=1'b1;
									div_mode_ff<=1'b0;
								   end
							`mulu: begin 
									mul_div_funcD1<=1'b1;
									div_mode_ff<=1'b0;
								    end
						      default:   mul_div_funcD1<=1'b0;
					 endcase	
			default:		   mul_div_funcD1<=1'b0;
		endcase
	end

//mu_div_func
//mul_alu_selD2/excuting_flag
always @ (posedge clock) begin
		if (sync_resetD1)	begin
				mul_div_funcD2 <=`mult_nothing;
				mul_alu_selD2<=2'b00;
	    	end else if ( mul_div_funcD2 [3] ) mul_div_funcD2[3]<=1'b0;////

                else if( !NOP_Signal) //
 				case (opecodeD1)
			       6'b00_0000:
				case   (opefuncD1)
				`divs:	begin
						mul_div_funcD2<=`mult_signed_divide;

						end
				`divu:	begin
						mul_div_funcD2<=`mult_divide;
						end	
                         `muls:	begin
						mul_div_funcD2<=`mult_signed_mult;
						end
                         `mulu:	begin
						mul_div_funcD2<=`mult_mult;
						end

				`mfhi : begin
							if (!pause_out)mul_div_funcD2<=`mult_read_hi;
							mul_alu_selD2<=`MUL_hi_SEL;
						   end
				`mflo : begin 
							if(!pause_out) mul_div_funcD2<=`mult_read_lo;
							mul_alu_selD2<=`MUL_lo_SEL;
						   end
				 default: 	begin 
							mul_div_funcD2 <=`mult_read_lo;
					       	mul_alu_selD2<=2'b00;
						end
				endcase
				default: 	      mul_alu_selD2<=2'b00;
		     endcase

end

always @ (posedge clock) begin
		if (sync_resetD1) excuting_flagD<=1'b0;
		else		      excuting_flagD<=excuting_flag;
end

always @ (posedge clock) begin
		if (sync_resetD1) excuting_flagDD<=1'b0;
		else		      excuting_flagDD<=excuting_flagD;
end
	assign finish_operation=excuting_flag && !pause_out;


//MWrite
	always @ (posedge clock) begin
		if (sync_resetD1)		MWriteD1<=1'b0;
	
		else case (opecode)
			`storebyte: 	MWriteD1<=1'b1;	
			`storeword: 	MWriteD1<=1'b1;
                  	`storelong: 	MWriteD1<=1'b1;
			default:	MWriteD1<=1'b0;
		     endcase
     end

	always @ (posedge clock) begin
		if (sync_resetD1)		MWriteD2<=1'b0;
		else if (  NOP_Signal ) MWriteD2<=1'b0;
		else				MWriteD2<=MWriteD1;//taken NOP 
	end


//M_sign
	always @ (posedge clock) begin
		if (sync_resetD1)			    M_signD1<=`M_unsigned;
		else case (opecode)
			     `loadbyte_signed  :     M_signD1<=`M_signed;		
                        `loadbyte_unsigned :   M_signD1<=`M_unsigned;
                        `loadword_signed  :     M_signD1<=`M_signed;
                        `loadword_unsigned :  M_signD1<=`M_unsigned;
                        `loadlong  	   :       M_signD1<=`M_unsigned;
			     `storebyte: 		    M_signD1<=`M_unsigned;	
			     `storeword: 		    M_signD1<=`M_unsigned;
                        `storelong: 		    M_signD1<=`M_unsigned;
				default:		          M_signD1<=`M_unsigned;
		     endcase
	end




// [1:0] M_access_mode
	always @ (posedge clock) begin
		if (sync_resetD1)			  M_access_modeD1<=`LONG_ACCESS;
		else case (opecode)
			`loadbyte_signed  :	  M_access_modeD1<=`BYTE_ACCESS;		
                   `loadbyte_unsigned :     M_access_modeD1<=`BYTE_ACCESS;
                   `loadword_signed  :       M_access_modeD1<=`WORD_ACCESS;
                   `loadword_unsigned :    M_access_modeD1<=`WORD_ACCESS;
                   `loadlong  	   :          M_access_modeD1<=`LONG_ACCESS;
		      `storebyte: 		       M_access_modeD1<=`BYTE_ACCESS;	
			`storeword: 		       M_access_modeD1<=`WORD_ACCESS;
                   `storelong: 		       M_access_modeD1<=`LONG_ACCESS;
			default:		             M_access_modeD1<=`LONG_ACCESS;
		     endcase
	end




// [2:0] RF_input Shift_Amount_sel
	always @ (posedge clock) begin
		if (sync_resetD1)		begin 
			RF_inputD2 <=`RF_ALU_sel;
			Shift_Amount_selD2<=`SHIFT_AMOUNT_IMM_SEL;
		end
	     else if ((int_seqD1)  || NOP_Signal ) RF_inputD2<=`RF_PC_SEL;//Jul.7.2004
	     else 	
                 case (opecodeD1)
			`lui	:RF_inputD2	<=`SHIFT16_SEL;
			`jump_and_link_im: 	RF_inputD2<=`RF_PC_SEL;
			
                        6'b00_0000:
				case   (opefuncD1)
				     `jump_and_link_register : RF_inputD2<=`RF_PC_SEL;
				           `lsl	             :    begin
										 RF_inputD2<=`RF_Shifter_sel ;
										 Shift_Amount_selD2<=`SHIFT_AMOUNT_IMM_SEL;
										end 
						`sllv		:      begin
										  RF_inputD2<=`RF_Shifter_sel ;
										  Shift_Amount_selD2<=`SHIFT_AMOUNT_REG_SEL;
										 end 		
		                  	     `asr                    : begin
										    RF_inputD2<=`RF_Shifter_sel ;
										    Shift_Amount_selD2<=`SHIFT_AMOUNT_IMM_SEL;
										 end
      					`srav                    : begin
										    RF_inputD2<=`RF_Shifter_sel ;
										    Shift_Amount_selD2<=`SHIFT_AMOUNT_REG_SEL;
										 end
   
               		   	     `lsr                    :  begin
										     RF_inputD2<=`RF_Shifter_sel;
										     Shift_Amount_selD2<=`SHIFT_AMOUNT_IMM_SEL;
										 end
  						`srlv                    :  begin
										     RF_inputD2<=`RF_Shifter_sel;
										     Shift_Amount_selD2<=`SHIFT_AMOUNT_REG_SEL;
										 end


						`mfhi 		:	RF_inputD2<=`RF_PC_SEL;
						`mflo		:	RF_inputD2<=`RF_PC_SEL;
	  				default              :      begin
									RF_inputD2<=`RF_ALU_sel;
 									Shift_Amount_selD2<=`SHIFT_AMOUNT_IMM_SEL;
									end
				endcase
			default: begin
						RF_inputD2<=`RF_ALU_sel;
						 Shift_Amount_selD2<=`SHIFT_AMOUNT_IMM_SEL;
					end
		     endcase
	end


//[1:0] A_Right_SEL
	always @ (posedge clock) begin
		 casex (opecode)	
			`storebyte: 	A_Right_SELD1<=`A_RIGHT_ERT;
			`storeword: 	A_Right_SELD1<=`A_RIGHT_ERT;
			`storelong: 	A_Right_SELD1<=`A_RIGHT_ERT;
			`andi	  : 	A_Right_SELD1<=`Imm_unsigned ;		
                  `addi     :       A_Right_SELD1<=`Imm_signed  ;
			`addiu    :     A_Right_SELD1<=`Imm_signed;
                  `ori      :         A_Right_SELD1<=`Imm_unsigned;
			`xori	  :     A_Right_SELD1<=`Imm_unsigned;

			`beq	     :  	A_Right_SELD1<=`A_RIGHT_ERT;  
			`bgtz	     :  	A_Right_SELD1<=`A_RIGHT_ERT;  		
                 	`blez        :     	A_Right_SELD1<=`A_RIGHT_ERT; 
                  	`bne         :      	A_Right_SELD1<=`A_RIGHT_ERT;


			`comp_im_signed   : A_Right_SELD1<=`Imm_signed;
			`comp_im_unsigned : A_Right_SELD1<=`Imm_signed;

			//6'b00_0000:
			6'b00_000?://Jul.11.2004 target select
				case   (opefunc)
					
	  				default           : A_Right_SELD1<=`A_RIGHT_ERT;
				endcase
			default: A_Right_SELD1<=`Imm_signed;
		    endcase
	end


//Interim A_Left_SELD1RRegSelD1
	always @ (posedge clock) begin
		 case (opecode)	
			default: A_Left_SELD1<=0;//always Left_latch
		    endcase
	end

	always @ (posedge clock) begin
		if ((control_state[5:0]==6'b00__0000 && int_req)  )  RRegSelD1<=`NREG_SEL;//Jul.13.2004
		else case (opecode)	
			    `loadbyte_signed  :	RRegSelD1<=`MOUT_SEL;		
                        `loadbyte_unsigned :    RRegSelD1<=`MOUT_SEL;
                        `loadword_signed  :     RRegSelD1<=`MOUT_SEL;
                        `loadword_unsigned :    RRegSelD1<=`MOUT_SEL;
                        `loadlong  	   :    RRegSelD1<=`MOUT_SEL;
			default: 	        RRegSelD1<=`NREG_SEL;//Interim MULSEL
		  endcase
	end

// [3:0] ALU_Func[1:0] ;
	always @ (posedge clock) begin
		
		case (opecodeD1)
				`andi    : ALU_FuncD2<=`ALU_AND;
   				`addi    : ALU_FuncD2<=`ALU_ADD  ;
				`addiu  :  ALU_FuncD2<=`ALU_ADD;
				`ori     : ALU_FuncD2<=`ALU_OR;
    				`xori    : ALU_FuncD2<=`ALU_XOR;
				 `comp_im_signed     : ALU_FuncD2<=`ALU_LESS_THAN_SIGNED;
                         `comp_im_unsigned   : ALU_FuncD2<=`ALU_LESS_THAN_UNSIGNED;
				6'b00_0000: 
				case   (opefuncD1)
					`add    : ALU_FuncD2<=`ALU_ADD ;
					`addu   :	 ALU_FuncD2<=`ALU_ADD ;		
                       	     	`sub     : ALU_FuncD2<=`ALU_SUBTRACT;
					`subu   : ALU_FuncD2<=`ALU_SUBTRACT;
					`and     : ALU_FuncD2<=`ALU_AND;
					`nor     : ALU_FuncD2<=`ALU_NOR;
	   				`or      : ALU_FuncD2<=`ALU_OR;
					`xor     : ALU_FuncD2<=`ALU_XOR;
                     	       `comp_signed      : ALU_FuncD2<=`ALU_LESS_THAN_SIGNED;  	
                              `comp_unsigned     : ALU_FuncD2<=`ALU_LESS_THAN_UNSIGNED;	
                            
			 		default           : ALU_FuncD2<=`ALU_NOTHING;//Jul.6.2004 ALU_NOTHING;
				endcase
			      default: ALU_FuncD2<=`ALU_NOTHING;//Jul.6.2004 ALU_NOTHING;
		endcase
	end


// [1:0] Shift_Func;
	always @ (posedge clock) begin
		 case (opecode)
			6'b00_0000: 
				case   (opefunc)
					`lsl	         : Shift_FuncD1<=`SHIFT_LEFT;
				      `sllv         : Shift_FuncD1<=`SHIFT_LEFT;
                       		`asr             : Shift_FuncD1<=`SHIFT_RIGHT_SIGNED;
					`srav		: Shift_FuncD1<=`SHIFT_RIGHT_SIGNED;
                        		`lsr             : Shift_FuncD1<=`SHIFT_RIGHT_UNSIGNED;
					`srlv		: Shift_FuncD1<=`SHIFT_RIGHT_UNSIGNED;
			 		default          : Shift_FuncD1<=`SHIFT_LEFT;//Jul.5.2004 `SHIFT_NOTHING;
				endcase
			default: Shift_FuncD1<=`SHIFT_LEFT;//Jul.5.2004`SHIFT_NOTHING;
		     endcase
	end



//RF_input_addr_sel
	always @ (posedge clock) begin
		 if ((control_state[5:0]==6'b00__0000 && int_req)  ) RF_input_addr_selD1<=`RF_INTR_SEL;
		 else
		 case (opecode)
				`andi	         : RF_input_addr_selD1<=`RF_Ert_sel;		
                        	`addi            : RF_input_addr_selD1<=`RF_Ert_sel;
                        	`ori             : RF_input_addr_selD1<=`RF_Ert_sel;
			 	`xori		 : RF_input_addr_selD1<=`RF_Ert_sel;
				`jump_and_link_im: RF_input_addr_selD1<=`RF_R15_SEL;
		   		`lui		 : RF_input_addr_selD1<=`RF_Ert_sel;
				`comp_im_signed  : RF_input_addr_selD1<=`RF_Ert_sel;
				`comp_im_unsigned: RF_input_addr_selD1<=`RF_Ert_sel;
			6'b00_0000: 
				case   (opefunc)
					`jump_and_link_register: RF_input_addr_selD1<=`RF_R15_SEL;
				
					default          : RF_input_addr_selD1<=`RF_Erd_sel;
				endcase
			default: RF_input_addr_selD1<=`RF_Ert_sel;
		    endcase
	end





//PC_command decoder	
//	always @ (posedge clock) begin
	always @(opecode,control_state,int_req,opefunc,NOP_Signal,takenD3,takenD4) begin//Jul.2.2004	
		 if (takenD3 || takenD4)	 PC_commandD1<=`PC_INC;//
		   else case (opecode)
	
			 6'b00_0000:
					case (opefunc)
					`jmp_register : PC_commandD1<=`PC_REG;
					 default:         PC_commandD1<=`PC_INC;
					endcase
			 default      : PC_commandD1<=`PC_INC;
		endcase
	end
//unsuppurted command detector Jul.11.2004
       always @(posedge clock) begin
		case (opecode)
			6'b000_001://Jul.11.2004 simple decode
				case (IR[20:16]) 
					
					`bltzal  :begin
							$display("unsupported command");
						 	$stop;
						end   
					`bgezal : begin
							$display("unsupported command");
						 	$stop;
						end   
					 
					`bltzall:begin
							$display("unsupported command");
						 	$stop;
						end  
					`bltzl:begin
							$display("unsupported command");
						 	$stop;
						end   
					`bgezall:begin
							$display("unsupported command");
						 	$stop;
						end   
					`bgezl:	begin
							$display("unsupported command");
						 	$stop;
						end   
				endcase
		endcase	
	

	end



	always @ (posedge clock) begin
		   if ((control_state[5:0]==6'b00_0000 && int_req)  ) begin
								jumpQ<=1'b1;
							      branchQ<=1'b0;////Jun.30.2004
		   end else if (takenD3)	begin
								jumpQ<=1'b0;//inhibit jump at delayed slot2
								branchQ<=1'b0;//TRY Jun.30.2004
		   end else 	
		     case (opecode)
			`jump: 		      begin
								jumpQ<=1'b1;
								branchQ<=1'b0;//Jun.30.2004
							end
			`jump_and_link_im:   	begin
								 jumpQ<=1'b1;
								 branchQ<=1'b0;//Jun.30.2004
							end
			`beq	     :	      begin
									jumpQ<=1'b0;//Jun.30.2004
									branchQ<=1'b1;
								end
			`bgtz	     :	      begin
									jumpQ<=1'b0;//Jun.30.2004
									branchQ<=1'b1;
								end		
                 	`blez          :      	begin
									jumpQ<=1'b0;//Jun.30.2004
									branchQ<=1'b1;
								end
                  `bne           :      	begin
									jumpQ<=1'b0;//Jun.30.2004
									branchQ<=1'b1;
								end
			6'b000_001://Jul.11.2004 simple decode
						begin
								jumpQ<=1'b0;
								branchQ<=1'b1;
						end
				
			 default      : begin
				 	 jumpQ<=1'b0;
					 branchQ<=1'b0;
					end		
		     endcase
	end

	 always @ (posedge clock) begin
		if (NOP_Signal) branchQQ<=1'b0;
		else branchQQ<=branchQ;
	end
	 


//For Critical Path
	always @(posedge clock) begin
		if (sync_resetD1)    beqQ<=0;
		else  if ((control_state[5:0]==6'b00_0000 && int_req)  ) beqQ<=1'b0;
		else if (opecode==`beq) beqQ<=1'b1;
		else		   beqQ<=1'b0;
	end

//Jul.11.2004 bltz
	always @(posedge clock) begin
		if (sync_resetD1)    bltzQ<=0;
		else  if ((control_state[5:0]==6'b00_0000 && int_req)  ) bltzQ<=1'b0;
		else if (opecode==6'b000_001 && IR[20:16]==`bltz) bltzQ<=1'b1;//Jul.13.2004
		else		   bltzQ<=1'b0;
	end
//Jul.11.2004 bgez
	always @(posedge clock) begin
		if (sync_resetD1)    bgezQ<=0;
		else  if ((control_state[5:0]==6'b00_0000 && int_req)  ) bgezQ<=1'b0;
		else if (opecode==6'b000_0001 && IR[20:16]==`bgez) bgezQ<=1'b1;//Jul.13.2004
		else		   bgezQ<=1'b0;
	end


	always @(posedge clock) begin
		if (sync_resetD1)     bgtzQ<=0;
		else  if ((control_state[5:0]==6'b00_0000 && int_req)  ) bgtzQ<=1'b0;
		else if (opecode==`bgtz) bgtzQ<=1'b1;
		else		    bgtzQ<=1'b0;
	end
	always @(posedge clock) begin
		if (sync_resetD1)     blezQ<=0;
		else  if ((control_state[5:0]==6'b00_0000 && int_req)   ) blezQ<=1'b0;
		else if (opecode==`blez) blezQ<=1'b1;
		else		    blezQ<=1'b0;
	end
	always @(posedge clock) begin
		if (sync_resetD1)    bneQ<=0;
		else  if ((control_state[5:0]==6'b00_0000 && int_req)  ) bneQ<=1'b0;
		else if (opecode==`bne) bneQ<=1'b1;
		else		   bneQ<=1'b0;
	end

//
      	always @(posedge clock) begin
		if (sync_resetD1)   begin 
				
						 excuting_flag<=1'b0;//
		end else
		 begin
			if (!pause_out && excuting_flagDD) excuting_flag<=1'b0;
			else case (opecode)
						6'b00_0000:
							case (opefunc)
								`divs:			 excuting_flag<=1'b1;
								`divu:			 excuting_flag<=1'b1;	
                                        		`muls:			 excuting_flag<=1'b1;
                                         		`mulu:			 excuting_flag<=1'b1;
					 		endcase
			      endcase
		end		
	end
      
	always @(posedge clock) begin
		if (sync_resetD1)   begin 
						 control_state<=6'b00_0000;
		end else
		 begin
			casex (control_state[5:0])
			6'b00_0000:
				begin
					if(int_req) control_state<=6'b000_101;//
					else 
						case (opecode)
						`jump:		      control_state<=6'b100_000;
						`jump_and_link_im:    control_state<=6'b100_000;
						`beq	     :	      control_state<=6'b110_000;
						`bgtz	     :	      control_state<=6'b110_000;		
                 				`blez        :        control_state<=6'b110_000;
                  		      	`bne         :        control_state<=6'b110_000;
						6'b000_001: 		control_state<=6'b110_000;//Jul.11.2004 Special Branch
			 			6'b00_0000:
							case (opefunc)
							`jump_and_link_register: control_state<=6'b101_000;
							`jmp_register : 	 control_state<=6'b101_000;
				
							`mfhi:			 if (excuting_flag) control_state<=8'b00_000_010;
							`mflo:			 if (excuting_flag) control_state<=8'b00_000_010;
							default:		       control_state<=6'b00_0000;//for safety
					 		endcase
						endcase	



				end
			6'b???_101:	control_state<=6'b000_000;//interrupt_nop state
			6'b100_000:	control_state<=6'b000_000;//fixed_jump state
			6'b101_000:	control_state<=6'b001_100;//jump&link state
			6'b001_100:   control_state<=6'b000_000;//NOP2 state
			6'b110_000:	control_state<=6'b000_100;//delayed branch 
			6'b000_100:    `ifdef RAM4K//Priotiry Area 
					 if (takenD3)	control_state<=6'b001_100;//NOP1 state
					        else	case (opecode)
							`jump:		      control_state<=6'b100_000;
							`jump_and_link_im:    control_state<=6'b100_000;
							`beq	     :	      control_state<=6'b110_000;
							`bgtz	     :	      control_state<=6'b110_000;		
                 					`blez        :        control_state<=6'b110_000;
                  					`bne         :        control_state<=6'b110_000;
							6'b000_001: 		control_state<=6'b110_000;//Jul.11.2004 Special Branch
			 				6'b00_0000:
								case (opefunc)
								`jump_and_link_register: control_state<=6'b101_000;
								`jmp_register : 	 control_state<=6'b101_000;
								`mfhi:			 if (excuting_flag) control_state<=8'b00_000_010;
								`mflo:			 if (excuting_flag) control_state<=8'b00_000_010;
								default:		       control_state<=6'b00_0000;//for safety
					 			endcase
							endcase
					`else//Priority Speed
					        	case (opecode)
							`jump:		if (takenD3)	control_state<=6'b001_100;//NOP1 state      
									else control_state<=6'b100_000;
							`jump_and_link_im:   if (takenD3)	control_state<=6'b001_100;//NOP1 state 
									     else control_state<=6'b100_000;
							`beq	     :	     if (takenD3)	control_state<=6'b001_100;//NOP1 state
									     else control_state<=6'b110_000;
							`bgtz	     :	     if (takenD3)	control_state<=6'b001_100;//NOP1 state
									     else control_state<=6'b110_000;		
                 					`blez        :       if (takenD3)	control_state<=6'b001_100;//NOP1 state
									     else  control_state<=6'b110_000;
                  					`bne         :       if (takenD3)	control_state<=6'b001_100;//NOP1 state
									     else control_state<=6'b110_000;
							6'b000_001: 	     if (takenD3)	control_state<=6'b001_100;//NOP1 state
									     else control_state<=6'b110_000;//Jul.11.2004 Special Branch
			 				6'b00_0000:
								case (opefunc)
								`jump_and_link_register: if (takenD3)	control_state<=6'b001_100;//NOP1 state
											 else control_state<=6'b101_000;
								`jmp_register : 	 if (takenD3)	control_state<=6'b001_100;//NOP1 state
											 else control_state<=6'b101_000;
								`mfhi:			 if (excuting_flag) begin
											  if (takenD3)	control_state<=6'b001_100;//NOP1 state 
											  else control_state<=8'b00_000_010;
											 end else if (takenD3)	control_state<=6'b001_100;//NOP1 state 
								`mflo:			 if (excuting_flag) begin
												if (takenD3)	control_state<=6'b001_100;//NOP1 state
												else  control_state<=8'b00_000_010;
											 end else if (takenD3)	control_state<=6'b001_100;//NOP1 state

								default:		 if (takenD3)	control_state<=6'b001_100;//NOP1 state
											 else   control_state<=6'b00_0000;//for safety
					 			endcase
							default :	 if (takenD3)	control_state<=6'b001_100;//NOP1 state	
							endcase


					`endif		
			6'b???_010:	case (control_state[7:6]) 
						2'b00:   control_state<=8'b01_000_010;
						2'b01:   if (!pause_out) control_state<=8'b11_000_010;//mul/div
						2'b11:   control_state<=8'b10_000_010;
						2'b10:   control_state<=8'b00_000_110;//NOP
						default: control_state<=8'h00;
					      endcase
			6'b???_110:	control_state<=8'h01;//Jul.12.2004 PCC=save_pc;
			6'b???_001:   control_state<=8'h00;	//Jul.12.2004 MUL IDLE avoid interrupt					
			default: 	control_state<=8'h00;//for safety	
		 endcase
		end		
	end

	assign clear_int=control_state[2:0]==3'b101;//Jul.12.2004 interrupt_nop_state

	always @(posedge clock) begin
		if (sync_reset) nop_bit<=1'b0;
		else if (6'b000_100==control_state[5:0] && !takenD3) nop_bit<=1'b0;//Not taken
		else		  nop_bit<=control_state[2];
	end
	assign NOP_Signal=nop_bit |  control_state[1];//Jul.7.2004 int_bit mul_bit
	

	 ram_module_altera
	  


`ifdef RAM4K

ram(.clock(clock),.sync_reset(sync_reset),.IR(IR),.MOUT(MOUT),
	     .Paddr(PC[11:0]),.Daddr(DAddress[11:0]),.wren(MWriteD2),
	     .datain(memory_indata),.access_mode(M_access_modeD2),
	     .M_signed(M_signD2),.uread_port(uread_port),.write_busy(write_busy));
`endif
`ifdef RAM16K
   
	ram(.clock(clock),.sync_reset(sync_reset),.IR(IR),.MOUT(MOUT),
	     .Paddr(PC[13:0]),.Daddr(DAddress[13:0]),.wren(MWriteD2),
	     .datain(memory_indata),.access_mode(M_access_modeD2),
	     .M_signed(M_signD2),.uread_port(uread_port),.write_busy(write_busy));
	 


`endif

`ifdef RAM32K
ram(.clock(clock),.sync_reset(sync_reset),.IR(IR),.MOUT(MOUT),
	     .Paddr(PC[14:0]),.Daddr(DAddress[14:0]),.wren(MWriteD2),
	     .datain(memory_indata),.access_mode(M_access_modeD2),
	     .M_signed(M_signD2),.uread_port(uread_port),.write_busy(write_busy));
`endif




endmodule