
`include "clairisc_def.h"
module ClaiRISC_core (
        input clk,
        input rst,	 
	output [7:0]dvc_wr_addr,
	output [7:0]dvc_rd_addr,
	output  [7:0]data_mem2dvc,
	input [7:0]data_dvc2mem,   
	output dvc_wr  ,
	output dvc_rd 
    );
    
    supply0 GND;
    wire w_c_2alu;
    wire w_c_2mem;
    reg w_c_wr;
    reg w_c_wr_r;
    reg w_mem_wr;
    reg w_mem_wr_r;
    reg w_muxa_ctl;
    reg w_muxa_ctl_r;
    reg w_muxb_ctl;
    reg w_reg_muxb_r;
    reg w_skip;
    reg w_w_wr;
    reg w_w_wr_r; 
	wire w_z;
    reg w_z_wr;
    reg w_z_wr_r;
    reg [7:0] w_alu_in_a;
    reg [7:0] w_alu_in_b;
    reg [4:0] w_alu_op;
    reg [4:0] w_alu_op_r;
    reg [7:0] w_alu_res;  
    wire [1:0] w_bank;
    reg [7:0] w_bd_r;
    reg [1:0] w_brc_ctl;
    reg [1:0] w_br_ctl_r;
    reg [8:0] w_ek_r;
    wire [7:0] w_file_o;
    wire [11:0] w_ins;
    reg [10:0] w_pc;
    reg [2:0] w_pc_gen_ctl;
    reg [10:0] w_pc_nxt;
    wire [4:0] w_rd_addr;
    wire [7:0] w_status;
    reg [1:0] w_stk_op;
    wire [10:0] w_stk_pc;
    reg[4:0] w_wbadd_r;
    wire [4:0] w_wd_addr;
    reg [7:0] w_wreg;
    wire [4:0] w_wr_addr;

    always @(posedge clk)
        w_pc<=w_pc_nxt;
        
    reg	[10:0]	stack1, stack2,stack3, stack4;	 
	
	initial	begin 
	stack1=0;
	stack2=0;
	stack3=0;
	stack4=0;
	end		
	
    assign w_stk_pc = stack1;

    always @(posedge clk)
    begin
        case (w_stk_op)
            `STK_PSH	:// PUSH stack
            begin	  
                stack4 <= stack3;
                stack3 <= stack2;	
                stack2 <= stack1;
                stack1 <= w_pc+1;
            end
            `STK_POP	:// POP stack
            begin
                stack1 <= stack2;	   
				stack2 <= stack3;
                stack3 <= stack4;   
			end
            //  default ://do nothing
        endcase
    end
    
    assign	   w_rd_addr =w_wd_addr[4:0];

    mem_man   mem_man
                 (					   
                     .c_wr(w_c_wr_r),
                     .ci(w_c_2mem),
                     .clk(clk),
                     .co(w_c_2alu),
                     .din(w_alu_res),
                     .dout(w_file_o),
                     .rd_addr(w_rd_addr[4:0]),
                     .rst(rst),
                     .status(w_status),
                     .wr_addr(w_wr_addr[4:0]),
                     .wr_en(w_mem_wr_r),
                     .z_wr(w_z_wr_r),
                     .zi(w_z),		 
					 .dvc_wr_addr(dvc_wr_addr),
	                 .dvc_rd_addr(dvc_rd_addr),
	                 .data_mem2dvc(data_mem2dvc),
	                 .data_dvc2mem(data_dvc2mem),   
	                 .dvc_wr(dvc_wr),
					 .dvc_rd(dvc_rd)
                 );

    always @(posedge clk)	 
        if (w_skip)
            w_alu_op_r<=0;
        else
            w_alu_op_r<=w_alu_op;

    always@(posedge clk)
        if (w_skip)	  w_br_ctl_r<=0;
        else w_br_ctl_r<=w_brc_ctl;

    always@(posedge clk)
        if (w_skip)	  w_z_wr_r<=0;
        else  w_z_wr_r<=w_z_wr;

    always @ (posedge clk)
        if (w_skip)
            w_c_wr_r<=0;
        else
            w_c_wr_r<=w_c_wr;

    always @(posedge clk)
        if(w_skip)
            w_mem_wr_r<=0;
        else					   
            w_mem_wr_r<=w_mem_wr;
 
    always @(posedge clk)
        if (w_w_wr_r)
            w_wreg<=w_alu_res;
	  		   
	always @ (posedge clk)  
		w_bd_r<=1<<w_ins[7:5];

    always @(posedge clk)			 
		w_w_wr_r <=w_w_wr ;

    always @(posedge clk)
        w_ek_r<=w_ins[8:0];

    assign w_wd_addr = w_ins[4:0];

    always@(posedge clk)
        w_wbadd_r<=w_wd_addr;
														   

	   assign w_wr_addr =  w_wbadd_r[4:0];
    reg		addercout;
    always @(*) begin
        case (w_alu_op_r) // synsys parallel_case
            `ALU_ADD:   {addercout,  w_alu_res}  = w_alu_in_a + w_alu_in_b;
            `ALU_SUB:  {addercout,  w_alu_res}  = w_alu_in_b - w_alu_in_a;
            `ALU_ROR:  {addercout,  w_alu_res}  = {w_alu_in_b[0], w_c_2alu, w_alu_in_b[7:1]};
            `ALU_ROL:  {addercout,  w_alu_res}  = {w_alu_in_b[7],w_alu_in_b[6:0], w_c_2alu};
            `ALU_OR:   {addercout,  w_alu_res}  = {1'bx, w_alu_in_a | w_alu_in_b};
            `ALU_XOR:  {addercout,  w_alu_res}  = {1'bx, w_alu_in_a ^ w_alu_in_b};
            `ALU_COM:  {addercout,  w_alu_res}  = {1'bx, ~w_alu_in_b};
            `ALU_SWAP: {addercout,  w_alu_res}  = {1'bx, w_alu_in_b[3:0], w_alu_in_b[7:4]};
            `ALU_AND,//:  {addercout,  y}  = {1'bx, a & b};
            `ALU_BTFSC,//:  {addercout,  y}  = {1'bx, a & b };
            `ALU_BTFSS: {addercout,  w_alu_res}  = {1'bx, w_alu_in_a & w_alu_in_b };
            `ALU_DEC:   {addercout,  w_alu_res}  = {1'bx, w_alu_in_b - 1};
            `ALU_INC:   {addercout,  w_alu_res}  = {1'bx, 1 + w_alu_in_b};
            `ALU_PA :   {addercout,  w_alu_res}  = {1'bx, w_alu_in_a};
            `ALU_PB :   {addercout,  w_alu_res}  = {1'bx, w_alu_in_b};
            `ALU_BSF :  {addercout,  w_alu_res}  = {1'Bx,w_alu_in_a | w_alu_in_b};
            `ALU_BCF :  {addercout,  w_alu_res}  = {1'bx,~w_alu_in_a & w_alu_in_b};
            default:     {addercout, w_alu_res}  = {1'bx, 8'h00};
        endcase
    end
    assign  w_z = (w_alu_res== 8'h00);
    assign  w_c_2mem =  (w_alu_op_r == `ALU_SUB) ?  ~addercout : addercout;

    always @(posedge clk)
        if( w_skip)   	 w_muxa_ctl_r<=0;
        else
            w_muxa_ctl_r<=	 w_muxa_ctl;

    always @ (posedge clk)
        if (w_skip)		 w_reg_muxb_r<=0;
        else
            w_reg_muxb_r<=	w_muxb_ctl;


    always@(*)
        if (w_muxa_ctl_r==`MUXA_W)
            w_alu_in_a=w_wreg;
        else
            w_alu_in_a=w_bd_r;


    always @(*)
        if (w_reg_muxb_r==`MUXB_EK)
            w_alu_in_b=w_ek_r[7:0];
        else w_alu_in_b=w_file_o;

    always @(*)
    case (w_br_ctl_r)
        //Z==1 means the ALU result is 0
        //Z==0 means the ALU result is not 0
        `BG_ZERO :w_skip =  (w_z==1);	//if the ALU result is 0 then the next instrction will be discarded
        `BG_NZERO :w_skip = (w_z==0);	 //if the ALU result is not zero
        //then skip the next instruction
        default w_skip = 0;
    endcase
					  
com_prom program_rom
         (
             .clk(clk),
             .dout(w_ins),
             .rd_addr(w_pc_nxt)
         );	  

    always @ (*)
        if (rst)
            w_pc_nxt=0;//'h1ff;		  //THE RST ENTRY
        else
            if(w_skip)
            begin
                w_pc_nxt = w_pc+1;
            end
            else
            begin
                case(w_pc_gen_ctl)
                    `PC_GOTO,
                    `PC_CALL: 	w_pc_nxt= w_ins[7:0];//{w_status[7:6],1'b0,w_ins[7:0]};
                    `PC_RET :	w_pc_nxt= w_stk_pc;
                    default
                    w_pc_nxt= w_pc+1;
                endcase
            end


	always @(*) begin
        casex (w_ins) 

            12'b0000_001X_XXXX:		   //Checked 2008_11_22
                //REPLACE ID = MOVWF
                //REPLACE ID = MOVWF
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_W;
                w_muxb_ctl = `MUXB_IGN;		  //check 2008_11_22
                w_alu_op = `ALU_PA;
                w_mem_wr = `EN;
                w_w_wr = `DIS;
                w_z_wr = `DIS;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_NOP;
            end //end of MOVWF ;

            12'b0000_0100_0000:
                //REPLACE ID = CLRW
                //REPLACE ID = CLRW
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_IGN;
                w_muxb_ctl = `MUXB_IGN;		 //check 2008_11_22
                w_alu_op = `ALU_ZERO;
                w_mem_wr = `DIS;
                w_w_wr = `EN;
                w_z_wr = `EN;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_NOP;
            end //end of CLRW ;

            12'b0000_011X_XXXX:
                //REPLACE ID = CLRF
                //REPLACE ID = CLRF
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_IGN;
                w_muxb_ctl = `MUXB_IGN;	    //check 2008_11_22
                w_alu_op = `ALU_ZERO;
                w_mem_wr = `EN;
                w_w_wr = `DIS;
                w_z_wr = `EN;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_NOP;
            end //end of CLRF ;

            12'b0000_100X_XXXX:
                //REPLACE ID = SUBWF_W
                //REPLACE ID = SUBWF_W
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_W;
                w_muxb_ctl = `MUXB_REG;	    //check 2008_11_22
                w_alu_op = `ALU_SUB;
                w_mem_wr = `DIS;
                w_w_wr = `EN;
                w_z_wr = `EN;
                w_c_wr = `EN;
                w_brc_ctl = `BG_NOP;
            end //end of SUBWF_W ;

            12'b0000_101X_XXXX:
                //REPLACE ID = SUBWF_F
                //REPLACE ID = SUBWF_F
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_W;
                w_muxb_ctl = `MUXB_REG;		  //check 2008_11_22
                w_alu_op = `ALU_SUB;
                w_mem_wr = `EN;
                w_w_wr = `DIS;
                w_z_wr = `EN;
                w_c_wr = `EN;
                w_brc_ctl = `BG_NOP;
            end //end of SUBWF_F ;

            12'b0000_110X_XXXX:
                //REPLACE ID = DECF_W
                //REPLACE ID = DECF_W
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_IGN;
                w_muxb_ctl = `MUXB_REG;		  //check 2008_11_22
                w_alu_op = `ALU_DEC;
                w_mem_wr = `DIS;
                w_w_wr = `EN;
                w_z_wr = `EN;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_NOP;
            end //end of DECF_W ;


            12'b0000_111X_XXXX:
                //REPLACE ID = DECF_F
                //REPLACE ID = DECF_F
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_IGN;
                w_muxb_ctl = `MUXB_REG;		  //check 2008_11_22
                w_alu_op = `ALU_DEC;
                w_mem_wr = `EN;
                w_w_wr = `DIS;
                w_z_wr = `EN;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_NOP;
            end //end of DECF_F ;

            12'b0001_000X_XXXX:
                //REPLACE ID = IORWF_W
                //REPLACE ID = IORWF_W
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_W;
                w_muxb_ctl = `MUXB_REG;	// `MUXB_EK;			 //fixed 2008_11_22
                w_alu_op = `ALU_OR;
                w_mem_wr = `DIS;
                w_w_wr = `EN;
                w_z_wr = `EN;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_NOP;
            end //end of IORWF_W ;



            12'b0001_001X_XXXX:
                //REPLACE ID = IORWF_F
                //REPLACE ID = IORWF_F
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_W;
                w_muxb_ctl = `MUXB_REG;	// `MUXB_EK;			 //fixed 2008_11_22
                w_alu_op = `ALU_OR;
                w_mem_wr = `EN;
                w_w_wr = `DIS;
                w_z_wr = `EN;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_NOP;
            end //end of IORWF_F ;

            12'b0001_010X_XXXX:
                //REPLACE ID = ANDWF_W
                //REPLACE ID = ANDWF_W
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_W;
                w_muxb_ctl =`MUXB_REG;// `MUXB_EK;			 //fixed 2008_11_22
                w_alu_op = `ALU_AND;
                w_mem_wr = `DIS;
                w_w_wr = `EN;
                w_z_wr = `EN;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_NOP;
            end //end of ANDWF_W ;

            12'b0001_011X_XXXX:
                //REPLACE ID = ANDWF_F
                //REPLACE ID = ANDWF_F
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_W;
                w_muxb_ctl =`MUXB_REG;// `MUXB_EK;			 //fixed 2008_11_22
                w_alu_op = `ALU_AND;
                w_mem_wr = `EN;
                w_w_wr = `DIS;
                w_z_wr = `EN;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_NOP;
            end //end of ANDWF_F ;

            12'b0001_100X_XXXX:
                //REPLACE ID = XORWF_W
                //REPLACE ID = XORWF_W
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_W;
                w_muxb_ctl = `MUXB_REG;	    //check 2008_11_22
                w_alu_op = `ALU_XOR;
                w_mem_wr = `DIS;
                w_w_wr = `EN;
                w_z_wr = `EN;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_NOP;
            end //end of XORWF_W ;

            12'b0001_101X_XXXX:
                //REPLACE ID = XORWF_F
                //REPLACE ID = XORWF_F
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_W;
                w_muxb_ctl = `MUXB_REG;	   //check 2008_11_22
                w_alu_op = `ALU_XOR;
                w_mem_wr = `EN;
                w_w_wr = `DIS;
                w_z_wr = `EN;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_NOP;
            end //end of XORWF_F ;

            12'b0001_110X_XXXX:
                //REPLACE ID = ADDWF_W
                //REPLACE ID = ADDWF_W
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_W;
                w_muxb_ctl = `MUXB_REG;		 //check 2008_11_22
                w_alu_op = `ALU_ADD;
                w_mem_wr = `DIS;
                w_w_wr = `EN;
                w_z_wr = `EN;
                w_c_wr = `EN;
                w_brc_ctl = `BG_NOP;
            end //end of ADDWF_W ;

            12'b0001_111X_XXXX:
                //REPLACE ID = ADDWF_F
                //REPLACE ID = ADDWF_F
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_W;
                w_muxb_ctl = `MUXB_REG;
                w_alu_op = `ALU_ADD;
                w_mem_wr = `EN;
                w_w_wr = `DIS;
                w_z_wr = `EN;
                w_c_wr = `EN;
                w_brc_ctl = `BG_NOP;
            end //end of ADDWF_F ;

            12'b0010_000X_XXXX:
                //REPLACE ID = MOVF_W
                //REPLACE ID = MOVF_W
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_IGN;
                w_muxb_ctl = `MUXB_REG;	   //check 2008_11_22
                w_alu_op = `ALU_PB;
                w_mem_wr = `DIS;
                w_w_wr = `EN;
                w_z_wr = `EN;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_NOP;
            end //end of MOVF_W ;


            12'b0010_001X_XXXX:
                //REPLACE ID = MOVF_F
                //REPLACE ID = MOVF_F
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_W;
                w_muxb_ctl = `MUXB_REG;		  //check 2008_11_22
                w_alu_op = `ALU_PB;
                w_mem_wr = `DIS;//Also can be set as EN
                w_w_wr = `DIS;
                w_z_wr = `EN;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_NOP;
            end //end of MOVF_F ;

            12'b0010_010X_XXXX:
                //REPLACE ID = COMF_W
                //REPLACE ID = COMF_W
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_W;
                w_muxb_ctl = `MUXB_REG;		//check 2008_11_22
                w_alu_op = `ALU_COM;
                w_mem_wr = `DIS;
                w_w_wr = `EN;
                w_z_wr = `EN;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_NOP;
            end //end of COMF_W ;

            12'b0010_011X_XXXX:
                //REPLACE ID = COMF_F
                //REPLACE ID = COMF_F
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_IGN;
                w_muxb_ctl = `MUXB_REG;		   //check 2008_11_22
                w_alu_op = `ALU_COM;
                w_mem_wr = `EN;
                w_w_wr = `DIS;
                w_z_wr = `EN;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_NOP;
            end //end of COMF_F ;

            12'b0010_100X_XXXX:
                //REPLACE ID = INCF_W
                //REPLACE ID = INCF_W
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_IGN;
                w_muxb_ctl = `MUXB_REG;		//check 2008_11_22
                w_alu_op = `ALU_INC;
                w_mem_wr = `DIS;
                w_w_wr = `EN;
                w_z_wr = `EN;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_NOP;
            end //end of INCF_W ;

            12'b0010_101X_XXXX:
                //REPLACE ID = INCF_F
                //REPLACE ID = INCF_F
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_IGN;
                w_muxb_ctl = `MUXB_REG;		 //check 2008_11_22
                w_alu_op = `ALU_INC;
                w_mem_wr = `EN;
                w_w_wr = `DIS;
                w_z_wr = `EN;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_NOP;
            end //end of INCF_F ;

            12'b0010_110X_XXXX:
                //REPLACE ID = DECFSZ_W
                //REPLACE ID = DECFSZ_W
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_IGN;
                w_muxb_ctl = `MUXB_REG;			  //check 2008_11_22
                w_alu_op = `ALU_DEC;
                w_mem_wr = `DIS;
                w_w_wr = `EN;
                w_z_wr = `DIS;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_ZERO;		 //if the result is 0 then the next w_insrction will be discarded
            end //end of DECFSZ_W ;

            12'b0010_111X_XXXX:
                //REPLACE ID = DECFSZ_F
                //REPLACE ID = DECFSZ_F
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_IGN;
                w_muxb_ctl = `MUXB_REG;		   //check 2008_11_22
                w_alu_op = `ALU_DEC;
                w_mem_wr = `EN;
                w_w_wr = `DIS;
                w_z_wr = `DIS;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_ZERO;		  //if the result is 0 then the next w_insrction will be discarded
            end //end of DECFSZ_F ;
            //checked

            12'b0011_000X_XXXX:
                //REPLACE ID = RRF_W
                //REPLACE ID = RRF_W
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_IGN;
                w_muxb_ctl = `MUXB_REG;			//check 2008_11_22
                w_alu_op = `ALU_ROR;
                w_mem_wr = `DIS;
                w_w_wr = `EN;
                w_z_wr = `DIS;
                w_c_wr = `EN;
                w_brc_ctl = `BG_NOP;
            end //end of RRF_W ;
            //checked

            12'b0011_001X_XXXX:
                //REPLACE ID = RRF_F
                //REPLACE ID = RRF_F
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_IGN;
                w_muxb_ctl = `MUXB_REG;	  //check 2008_11_22
                w_alu_op = `ALU_ROR;
                w_mem_wr = `EN;
                w_w_wr = `DIS;
                w_z_wr = `DIS;
                w_c_wr = `EN;
                w_brc_ctl = `BG_NOP;
            end //end of RRF_F ;

            //
            12'b0011_010X_XXXX:
                //REPLACE ID = RLF_W
                //REPLACE ID = RLF_W
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_IGN;
                w_muxb_ctl = `MUXB_REG;	 //check 2008_11_22
                w_alu_op = `ALU_ROL;
                w_mem_wr = `DIS;
                w_w_wr = `EN;
                w_z_wr = `DIS;
                w_c_wr = `EN;
                w_brc_ctl = `BG_NOP;
            end //end of RLF_W ;

            12'b0011_011X_XXXX:
                //REPLACE ID = RLF_F
                //REPLACE ID = RLF_F
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_IGN;
                w_muxb_ctl = `MUXB_REG;	   //check 2008_11_22
                w_alu_op = `ALU_ROL;
                w_mem_wr = `EN;
                w_w_wr = `DIS;
                w_z_wr = `DIS;
                w_c_wr = `EN;
                w_brc_ctl = `BG_NOP;
            end //end of RLF_F ;

            12'b0011_100X_XXXX:
                //REPLACE ID = SWAPF_W
                //REPLACE ID = SWAPF_W
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_IGN;
                w_muxb_ctl = `MUXB_REG;		//check 2008_11_22
                w_alu_op = `ALU_SWAP;
                w_mem_wr = `DIS;
                w_w_wr = `EN;
                w_z_wr = `DIS;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_NOP;
            end //end of SWAPF_F ;

            12'b0011_101X_XXXX:
                //REPLACE ID = SWAPF_F
                //REPLACE ID = SWAPF_F
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_IGN;
                w_muxb_ctl = `MUXB_REG;		//check 2008_11_22
                w_alu_op = `ALU_SWAP;
                w_mem_wr = `EN;
                w_w_wr = `DIS;
                w_z_wr = `DIS;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_NOP;
            end //end of SWAPF_F ;

            12'b0011_110X_XXXX:
                //REPLACE ID = INCFSZ_W
                //REPLACE ID = INCFSZ_W
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_W;
                w_muxb_ctl = `MUXB_REG;	   //check 2008_11_22
                w_alu_op = `ALU_INC;
                w_mem_wr = `DIS;
                w_w_wr = `EN;
                w_z_wr = `DIS;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_ZERO;
            end //end of INCFSZ_W ;

            12'b0011_111X_XXXX:
                //REPLACE ID = INCFSZ_F
                //REPLACE ID = INCFSZ_F
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_W;
                w_muxb_ctl = `MUXB_REG;	  //check 2008_11_22
                w_alu_op = `ALU_INC;
                w_mem_wr = `EN;
                w_w_wr = `DIS;
                w_z_wr = `DIS;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_ZERO;
            end //end of INCFSZ_F ;

            12'b0100_XXXX_XXXX:
                //REPLACE ID = BCF
                //REPLACE ID = BCF
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_BD;
                w_muxb_ctl = `MUXB_REG;		 //check 2008_11_22
                w_alu_op = `ALU_BCF;
                w_mem_wr = `EN;
                w_w_wr = `DIS;
                w_z_wr = `DIS;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_NOP;
            end //end of BCF ;

            12'b0101_XXXX_XXXX:
                //REPLACE ID = BSF
                //REPLACE ID = BSF
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_BD;
                w_muxb_ctl = `MUXB_REG;		//check 2008_11_22
                w_alu_op = `ALU_BSF;
                w_mem_wr = `EN;
                w_w_wr = `DIS;
                w_z_wr = `DIS;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_NOP;
            end //end of BSF ;
            /**/

            12'b0110_XXXX_XXXX:
                //REPLACE ID = BTFSC
                //REPLACE ID = BTFSC
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_BD;
                w_muxb_ctl = `MUXB_REG;
                w_alu_op = `ALU_BTFSC;      //check 2008_11_22
                w_mem_wr = `DIS;
                w_w_wr = `DIS;
                w_z_wr = `DIS;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_ZERO;
            end //end of BTFSC ;

            12'b0111_XXXX_XXXX:
                //REPLACE ID = BTFSS
                //REPLACE ID = BTFSS
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_BD;
                w_muxb_ctl = `MUXB_REG;
                w_alu_op = `ALU_BTFSS;
                w_mem_wr = `DIS;
                w_w_wr = `DIS;
                w_z_wr = `DIS;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_NZERO;
            end //end of BTFSS ;

            12'b1000_XXXX_XXXX:
                //REPLACE ID = RETLW
                //REPLACE ID = RETLW
            begin
                w_pc_gen_ctl = `PC_RET ;
                w_stk_op = `STK_POP;
                w_muxa_ctl = `MUXA_IGN;
                w_muxb_ctl = `MUXB_EK;			   //check 2008_11_22
                w_alu_op = `ALU_PB;
                w_mem_wr = `DIS;
                w_w_wr = `EN;
                w_z_wr = `DIS;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_NOP;
            end //end of RETLW ;

            12'b1001_XXXX_XXXX:
                //REPLACE ID = CALL
                //REPLACE ID = CALL
            begin
                w_pc_gen_ctl = `PC_GOTO;
                w_stk_op = `STK_PSH;
                w_muxa_ctl = `MUXA_IGN;
                w_muxb_ctl = `MUXB_IGN;		 //check 2008_11_22
                w_alu_op = `ALU_NOP;
                w_mem_wr = `DIS;
                w_w_wr = `DIS;
                w_z_wr = `DIS;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_NOP;
            end //end of CALL ;

            12'b101X_XXXX_XXXX:
                //REPLACE ID = GOTO
                //REPLACE ID = GOTO
            begin
                w_pc_gen_ctl = `PC_GOTO;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_IGN;
                w_muxb_ctl = `MUXB_IGN;	   //check 2008_11_22
                w_alu_op = `ALU_NOP;
                w_mem_wr = `DIS;
                w_w_wr = `DIS;
                w_z_wr = `DIS;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_NOP;
            end //end of GOTO ;

            12'b1100_XXXX_XXXX:
                //REPLACE ID = MOVLW
                //REPLACE ID = MOVLW
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_IGN;
                w_muxb_ctl = `MUXB_EK;	  //check 2008_11_22
                w_alu_op = `ALU_PB;
                w_mem_wr = `DIS;
                w_w_wr = `EN;
                w_z_wr = `DIS;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_NOP;
            end //end of MOVLW ;

            12'b1101_XXXX_XXXX:
                //REPLACE ID = IORLW
                //REPLACE ID = IORLW
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_W;
                w_muxb_ctl = `MUXB_EK;	//check 2008_11_22
                w_alu_op = `ALU_OR;
                w_mem_wr = `DIS;
                w_w_wr = `EN;
                w_z_wr = `EN;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_NOP;
            end //end of IORLW ;

            12'b1110_XXXX_XXXX:
                //REPLACE ID = ANDLW
                //REPLACE ID = ANDLW
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_W;
                w_muxb_ctl = `MUXB_EK;	//check 2008_11_22
                w_alu_op = `ALU_AND;
                w_mem_wr = `DIS;
                w_w_wr = `EN;
                w_z_wr = `EN;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_NOP;
            end //end of ANDLW ;

            12'b1111_XXXX_XXXX:
                //REPLACE ID = XORLW
                //REPLACE ID = XORLW
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_W;
                w_muxb_ctl = `MUXB_EK;	  //check 2008_11_22
                w_alu_op = `ALU_XOR;
                w_mem_wr = `DIS;
                w_w_wr = `EN;
                w_z_wr = `EN;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_NOP;
            end //end of XORLW ;


            default:
                //REPLACE ID = NOP
            begin
                w_pc_gen_ctl = `PC_NEXT;
                w_stk_op = `STK_NOP;
                w_muxa_ctl = `MUXA_IGN;
                w_muxb_ctl = `MUXB_IGN;	  //check 2008_11_22
                w_alu_op = `ALU_NOP;
                w_mem_wr = `DIS;
                w_w_wr = `DIS;
                w_z_wr = `DIS;
                w_c_wr = `DIS;
                w_brc_ctl = `BG_NOP;
            end //end of NOP ;
        endcase
    end	
endmodule
