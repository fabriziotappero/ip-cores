/******************************************************************
 *                                                                * 
 *    Author: Liwei                                               * 
 *                                                                * 
 *    This file is part of the "mips789" project.                 * 
 *    Downloaded from:                                            * 
 *    http://www.opencores.org/pdownloads.cgi/list/mips789        * 
 *                                                                * 
 *    If you encountered any problem, please contact me via       * 
 *    Email:mcupro@opencores.org  or mcupro@163.com               * 
 *                                                                * 
 ******************************************************************/

`include "mips789_defs.v"

 module exec_stage
    (
        clk,rst,spc_cls_i,alu_func,
        dmem_fw_ctl,ext_i,fw_alu,fw_dmem,
        muxa_ctl_i,muxa_fw_ctl,muxb_ctl_i,
        muxb_fw_ctl,pc_i,rs_i,rt_i,alu_ur_o,
        dmem_data_ur_o,zz_spc_o,hold
    );

    input clk;
    wire clk;
    input rst;
    wire rst;
    input spc_cls_i;
    wire spc_cls_i;
    input [4:0] alu_func;
    wire [4:0] alu_func;
    input [2:0] dmem_fw_ctl;
    wire [2:0] dmem_fw_ctl;
    input [31:0] ext_i;
    wire [31:0] ext_i;
    input [31:0] fw_alu;
    wire [31:0] fw_alu;
    input [31:0] fw_dmem;
    wire [31:0] fw_dmem;
    input [1:0] muxa_ctl_i;
    wire [1:0] muxa_ctl_i;
    input [2:0] muxa_fw_ctl;
    wire [2:0] muxa_fw_ctl;
    input [1:0] muxb_ctl_i;
    wire [1:0] muxb_ctl_i;
    input [2:0] muxb_fw_ctl;
    wire [2:0] muxb_fw_ctl;
    input [31:0] pc_i;
    wire [31:0] pc_i;
    input [31:0] rs_i;
    wire [31:0] rs_i;
    input [31:0] rt_i;
    wire [31:0] rt_i;
    output [31:0] alu_ur_o;
    wire [31:0] alu_ur_o;
    output [31:0] dmem_data_ur_o;
    wire [31:0] dmem_data_ur_o;
    output [31:0] zz_spc_o;
    wire [31:0] zz_spc_o;
	 input hold;
	 wire hold;

    wire [31:0] BUS2332;
    wire [31:0] BUS2446;
    wire [31:0] BUS468;
    wire [31:0] BUS476;


    mips_alu MIPS_alu
            (
                .a(BUS476),
                .b(BUS468),
                .c(alu_ur_o),
                .clk(clk),
                .ctl(alu_func),
                .rst(rst)
            );

    add32 add4
          (
              .d_i(pc_i),
              .d_o(BUS2446)
          );


    fwd_mux dmem_fw_mux
            (
                .dout(dmem_data_ur_o),
                .fw_alu(fw_alu),
                .fw_ctl(dmem_fw_ctl),
                .fw_dmem(fw_dmem),
                .din(rt_i)
            );



    alu_muxa i_alu_muxa
             (
                 .a_o(BUS476),
                 .ctl(muxa_ctl_i),
                 .ext(ext_i),
                 .fw_alu(fw_alu),
                 .fw_ctl(muxa_fw_ctl),
                 .fw_mem(fw_dmem),
                 .pc(BUS2332),
                 .rs(rs_i),
                 .spc(zz_spc_o)
             );



    alu_muxb i_alu_muxb
             (
                 .b_o(BUS468),
                 .ctl(muxb_ctl_i),
                 .ext(ext_i),
                 .fw_alu(fw_alu),
                 .fw_ctl(muxb_fw_ctl),
                 .fw_mem(fw_dmem),
                 .rt(rt_i)
             );



    r32_reg pc_nxt
            (
                .clk(clk),
                .r32_i(BUS2446),
                .r32_o(BUS2332),
					 .hold(hold)
            );



    r32_reg_cls spc
                (
                    .clk(clk),
                    .cls(spc_cls_i),
                    .r32_i(pc_i),
						  .hold(hold),
                    .r32_o(zz_spc_o)
                );

endmodule

module mips_alu(clk,rst,a,b,c,ctl);
    input  clk,rst ;
    input  [31:0] a,b ;
    output [31:0] c ;
    input  [4:0]ctl ;

    wire [31:0] mul_div_c;
    wire [31:0] alu_c;
    wire [31:0] shift_c;

    assign c = mul_div_c | alu_c | shift_c ;

    muldiv_ff muldiv_ff(
                  .clk_i(clk),
                  .rst_i(rst),//sys signal
                  .op_type(ctl),
                  .op1(a),
                  .op2(b),
                  //    .busy_o(busy),
                  .res(mul_div_c)
              );

    /*
    	muldiv mips_muldiv(
                   .ready(busy),
                   .rst(rst),
                   .op1(a),
                   .op2(b),
                   .clk(clk),
                   .dout(mul_div_c),
                   .func(ctl)
               );
    */
    shifter_tak mips_shifter(
                    .a(b),
                    .shift_out(shift_c),
                    .shift_func(ctl),
                    .shift_amount(a)
                );


    alu mips_alu(
            .a(a),
            .b(b),
            .alu_out(alu_c),
            .alu_func(ctl)
        );

endmodule

module alu_muxa(
        input [31:0]spc,
        input [31:0]pc,
        input [31:0]fw_mem,
        input [31:0]rs,
        input [31:0]fw_alu,
        input [31:0]ext,
        input [1:0] ctl,
        input [2:0] fw_ctl,
        output reg [31:0]a_o
    );

    always @(*)
    begin
        case (ctl)
            `MUXA_RS:   a_o = (fw_ctl ==`FW_ALU )?fw_alu:(fw_ctl==`FW_MEM)?fw_mem:rs;
            `MUXA_PC:   a_o = pc;
            `MUXA_EXT:  a_o = ext;
            `MUXA_SPC:  a_o = spc;
            default :   a_o = rs;
        endcase
    end
endmodule

module alu_muxb(
        input [31:0] rt,
        input [31:0]fw_alu,
        input [31:0]fw_mem,
        input [31:0]ext ,
        input [1:0]ctl ,
        input [2:0]fw_ctl ,
        output reg [31:0] b_o
    );
    always@(*)
    case (ctl)
        `MUXB_RT :b_o = (fw_ctl ==`FW_ALU )?fw_alu:(fw_ctl==`FW_MEM)?fw_mem:rt;
        `MUXB_EXT :	b_o=ext;
        default b_o=rt;
    endcase
endmodule



//This file is based on YACC ->alu.v and  UCORE ->alu.v

module alu (
    input [31:0] a,
	input [31:0]b,
    output reg [31:0] alu_out,
    input [4:0]	alu_func
	);

    reg [32:0] sum;

    always @(*)
    begin
        case (alu_func)

            `ALU_PA     : alu_out=a;
            `ALU_PB     : alu_out=b;
            `ALU_ADD    : alu_out=a+b;
            `ALU_SUB  ,
            `ALU_SUBU   : alu_out=a + (~b)+1;
            `ALU_OR     : alu_out=a | b;
            `ALU_AND    : alu_out=a & b;
            `ALU_XOR    : alu_out=a ^ b;
            `ALU_NOR    : alu_out=~(a | b);
            `ALU_SLTU   : alu_out=(a < b)?1:0;
            `ALU_SLT :
            begin
                sum={a[31],a}+~{b[31],b}+33'h0_0000_0001;
                alu_out={31'h0000_0000,sum[32]};
            end

            /*
            			`ALU_SLL:	alu_out = a<<b[4:0];
                    	`ALU_SRL:   alu_out = a>>b[4:0];
            			`ALU_SRA:	alu_out=~(~a>>b[4:0]);
            			//the three operations is done in shifter_tak or shift_ff
            */

            default : alu_out=32'h0;
        endcase
    end
endmodule


module shifter_ff(
        input [31:0] a,
        output reg [31:0] shift_out,
        input [4:0] shift_func,//connect to alu_func_ctl
        input [31:0] shift_amount//connect to b
    );

    always @ (*)
    begin
        case( shift_func )
            `ALU_SLL:	shift_out = a<<shift_amount;
            `ALU_SRL:   shift_out = a>>shift_amount;
            `ALU_SRA:	shift_out=~(~a>> shift_amount);
            default		shift_out='d0;
        endcase
    end
endmodule


module  shifter_tak(
            input [31:0] a,
            output reg [31:0] shift_out,
            input [4:0] shift_func,//connect to alu_func_ctl
            input [31:0] shift_amount//connect to b
        );

    always @ (*)
    case( shift_func )
        `ALU_SLL:
        begin
            case ( shift_amount[4:0] )
                5'b00000: shift_out=a;
                5'b00001: shift_out={a[30:0],1'b0};
                5'b00010: shift_out={a[29:0],2'b0};
                5'b00011: shift_out={a[28:0],3'b0};
                5'b00100: shift_out={a[27:0],4'b0};
                5'b00101: shift_out={a[26:0],5'b0};
                5'b00110: shift_out={a[25:0],6'b0};
                5'b00111: shift_out={a[24:0],7'b0};
                5'b01000: shift_out={a[23:0],8'b0};
                5'b01001: shift_out={a[22:0],9'b0};
                5'b01010: shift_out={a[21:0],10'b0};
                5'b01011: shift_out={a[20:0],11'b0};
                5'b01100: shift_out={a[19:0],12'b0};
                5'b01101: shift_out={a[18:0],13'b0};
                5'b01110: shift_out={a[17:0],14'b0};
                5'b01111: shift_out={a[16:0],15'b0};
                5'b10000: shift_out={a[15:0],16'b0};
                5'b10001: shift_out={a[14:0],17'b0};
                5'b10010: shift_out={a[13:0],18'b0};
                5'b10011: shift_out={a[12:0],19'b0};
                5'b10100: shift_out={a[11:0],20'b0};
                5'b10101: shift_out={a[10:0],21'b0};
                5'b10110: shift_out={a[9:0],22'b0};
                5'b10111: shift_out={a[8:0],23'b0};
                5'b11000: shift_out={a[7:0],24'b0};
                5'b11001: shift_out={a[6:0],25'b0};
                5'b11010: shift_out={a[5:0],26'b0};
                5'b11011: shift_out={a[4:0],27'b0};
                5'b11100: shift_out={a[3:0],28'b0};
                5'b11101: shift_out={a[2:0],29'b0};
                5'b11110: shift_out={a[1:0],30'b0};
                5'b11111: shift_out={a[0],31'b0};
                default shift_out =32'bx;//never in this case
            endcase
        end
        `ALU_SRL :
        begin
            case (shift_amount[4:0])
                5'b00000: shift_out=a;
                5'b00001: shift_out={1'b0,a[31:1]};
                5'b00010: shift_out={2'b0,a[31:2]};
                5'b00011: shift_out={3'b0,a[31:3]};
                5'b00100: shift_out={4'b0,a[31:4]};
                5'b00101: shift_out={5'b0,a[31:5]};
                5'b00110: shift_out={6'b0,a[31:6]};
                5'b00111: shift_out={7'b0,a[31:7]};
                5'b01000: shift_out={8'b0,a[31:8]};
                5'b01001: shift_out={9'b0,a[31:9]};
                5'b01010: shift_out={10'b0,a[31:10]};
                5'b01011: shift_out={11'b0,a[31:11]};
                5'b01100: shift_out={12'b0,a[31:12]};
                5'b01101: shift_out={13'b0,a[31:13]};
                5'b01110: shift_out={14'b0,a[31:14]};
                5'b01111: shift_out={15'b0,a[31:15]};
                5'b10000: shift_out={16'b0,a[31:16]};
                5'b10001: shift_out={17'b0,a[31:17]};
                5'b10010: shift_out={18'b0,a[31:18]};
                5'b10011: shift_out={19'b0,a[31:19]};
                5'b10100: shift_out={20'b0,a[31:20]};
                5'b10101: shift_out={21'b0,a[31:21]};
                5'b10110: shift_out={22'b0,a[31:22]};
                5'b10111: shift_out={23'b0,a[31:23]};
                5'b11000: shift_out={24'b0,a[31:24]};
                5'b11001: shift_out={25'b0,a[31:25]};
                5'b11010: shift_out={26'b0,a[31:26]};
                5'b11011: shift_out={27'b0,a[31:27]};
                5'b11100: shift_out={28'b0,a[31:28]};
                5'b11101: shift_out={29'b0,a[31:29]};
                5'b11110: shift_out={30'b0,a[31:30]};
                5'b11111: shift_out={31'b0,a[31:31]};
                default : shift_out = 32'bx;//never in this case
            endcase
        end
        `ALU_SRA:
        begin// SHIFT_RIGHT_SIGNED
            case ( shift_amount[4:0])
                5'b00000: shift_out=a;
                5'b00001: shift_out={a[31],a[31:1]};
                5'b00010: shift_out={{2{a[31]}},a[31:2]};
                5'b00011: shift_out={{3{a[31]}},a[31:3]};
                5'b00100: shift_out={{4{a[31]}},a[31:4]};
                5'b00101: shift_out={{5{a[31]}},a[31:5]};
                5'b00110: shift_out={{6{a[31]}},a[31:6]};
                5'b00111: shift_out={{7{a[31]}},a[31:7]};
                5'b01000: shift_out={{8{a[31]}},a[31:8]};
                5'b01001: shift_out={{9{a[31]}},a[31:9]};
                5'b01010: shift_out={{10{a[31]}},a[31:10]};
                5'b01011: shift_out={{11{a[31]}},a[31:11]};
                5'b01100: shift_out={{12{a[31]}},a[31:12]};
                5'b01101: shift_out={{13{a[31]}},a[31:13]};
                5'b01110: shift_out={{14{a[31]}},a[31:14]};
                5'b01111: shift_out={{15{a[31]}},a[31:15]};
                5'b10000: shift_out={{16{a[31]}},a[31:16]};
                5'b10001: shift_out={{17{a[31]}},a[31:17]};
                5'b10010: shift_out={{18{a[31]}},a[31:18]};
                5'b10011: shift_out={{19{a[31]}},a[31:19]};
                5'b10100: shift_out={{20{a[31]}},a[31:20]};
                5'b10101: shift_out={{21{a[31]}},a[31:21]};
                5'b10110: shift_out={{22{a[31]}},a[31:22]};
                5'b10111: shift_out={{23{a[31]}},a[31:23]};
                5'b11000: shift_out={{24{a[31]}},a[31:24]};
                5'b11001: shift_out={{25{a[31]}},a[31:25]};
                5'b11010: shift_out={{26{a[31]}},a[31:26]};
                5'b11011: shift_out={{27{a[31]}},a[31:27]};
                5'b11100: shift_out={{28{a[31]}},a[31:28]};
                5'b11101: shift_out={{29{a[31]}},a[31:29]};
                5'b11110: shift_out={{30{a[31]}},a[31:30]};
                5'b11111: shift_out={{31{a[31]}},a[31:31]};
                default shift_out=32'bx;//never in this case
            endcase
        end
        default			shift_out='d0;
    endcase
endmodule

module muldiv(ready,rst,op1,op2,clk,dout,func);
    input         clk,rst;
    wire       sign;
    input [4:0] func ;
    input [31:0] op2, op1;
    output [31:0] dout;
    output        ready;
    reg [31:0]    quotient, quotient_temp;
    reg [63:0]    dividend_copy, divider_copy, diff;
    reg           negative_output;

    reg [63:0]    product, product_temp;

    reg [31:0]    multiplier_copy;
    reg [63:0]    multiplicand_copy;

    reg [6:0]     mul_bit,div_bit;
    wire          ready = ((mul_bit==0)&&(div_bit==0));

    wire  [31:0]  dividend, divider;

    wire [31:0]  remainder;
    wire [31:0] multiplier,multiplicand;

    reg [31:0] hi,lo;

    assign dout = (func==`ALU_MFHI)?hi:(func==`ALU_MFLO)?lo:0;

    assign  remainder = (!negative_output) ?
            dividend_copy[31:0] :
            ~dividend_copy[31:0] + 1'b1;

    assign multiplier=op2;
    assign multiplicand=op1;
    assign dividend=op1;
    assign  divider = op2;
    assign sign = ((func==`ALU_MULT)||(func==`ALU_DIV));

    initial
    begin
        hi=0;
        lo=0;
    end
    always @( posedge clk /*or negedge rst */)
        if (~rst)
        begin
            mul_bit=0;
            div_bit=0;
            /*
            hi=0;
            lo=0;
            */
            negative_output = 0;
        end
        else
        begin
            if((ready)&&((func==`ALU_MULT)||(func==`ALU_MULTTU)))
            begin
                mul_bit               = 33;
                product           = 0;
                product_temp      = 0;
                multiplicand_copy = (!sign || !multiplicand[31]) ?
                                  { 32'd0, multiplicand } :
                                  { 32'd0, ~multiplicand + 1'b1};
                multiplier_copy   = (!sign || !multiplier[31]) ?multiplier :~multiplier + 1'b1;

                negative_output = sign &&
                                ((multiplier[31] && !multiplicand[31])
                                 ||(!multiplier[31] && multiplicand[31]));
            end
            if ( mul_bit > 1 )
            begin

                if( multiplier_copy[0] == 1'b1 )
                    product_temp = product_temp +multiplicand_copy;


                product = (!negative_output) ?
                        product_temp :
                        ~product_temp + 1'b1;

                multiplier_copy = multiplier_copy >> 1;
                multiplicand_copy = multiplicand_copy << 1;
                mul_bit = mul_bit - 1'b1;
            end
            else if (mul_bit == 1)
            begin
                hi =  product[63:32];
                lo =  product[31:0];
                mul_bit=0;
            end

            if((ready)&&((func==`ALU_DIV)||(func==`ALU_DIVU)))
            begin
                div_bit = 33;
                quotient = 0;
                quotient_temp = 0;
                dividend_copy = (!sign || !dividend[31]) ?
                              {32'd0,dividend} :
                              {32'd0,~dividend + 1'b1};

                divider_copy = (!sign || !divider[31]) ?
                             {1'b0,divider,31'd0} :
                             {1'b0,~divider + 1'b1,31'd0};

                negative_output = sign &&
                                ((divider[31] && !dividend[31])
                                 ||(!divider[31] && dividend[31]));
            end
            else if (div_bit > 1)
            begin
                diff = dividend_copy - divider_copy;
                quotient_temp = quotient_temp << 1;
                if( !diff[63] )
                begin
                    dividend_copy = diff;
                    quotient_temp[0] = 1'd1;
                end
                quotient = (!negative_output) ?quotient_temp :~quotient_temp + 1'b1;
                divider_copy = divider_copy >> 1;
                div_bit = div_bit - 1'b1;
            end
            else if (div_bit == 1)
            begin
                lo =  quotient;
                hi =  remainder;
                div_bit=0;
            end
        end

endmodule

//creatied by Zhangfeifei
//modified by Liwei
module muldiv_ff
    (        clk_i,rst_i,
             op_type,op1,op2,
             rdy,res

    );

    parameter  OP_MULT  = `ALU_MULT;
    parameter  OP_MULTU = `ALU_MULTU;
    parameter  OP_DIV   = `ALU_DIV;
    parameter  OP_DIVU  = `ALU_DIVU;
    parameter  OP_MFHI  = `ALU_MFHI;
    parameter  OP_MFLO  = `ALU_MFLO;
    parameter  OP_MTHI  = `ALU_MTHI;
    parameter  OP_MTLO  = `ALU_MTLO;
    parameter  OP_NONE  = `ALU_NOP;

    input         clk_i;
    input         rst_i;
    input  [4:0]  op_type;
    input  [31:0] op1;
    input  [31:0] op2;
    output [31:0] res;
    output        rdy;

    reg           rdy;
    reg    [64:0] hilo;
    reg    [32:0] op2_reged;
    reg    [5:0]  count;
    reg           op1_sign_reged;
    reg           op2_sign_reged;
    reg           sub_or_yn;

    wire   [32:0] nop2_reged;
    assign nop2_reged = ~op2_reged +1;

    reg           sign;
    reg           mul;
    reg           start;

    assign res = (op_type == OP_MFLO )?hilo[31:0]:((op_type == OP_MFHI))?hilo[63:32]:0;//op_type == OP_MFHI or other

    reg           overflow;
    reg           finish;
    reg           add1;  //if the quotient will add 1 at the end of the divide operation
    reg           addop2; //if the remainder will add op2 at the end of the divide operation
    reg           addnop2;//if the remainder will add ~op2+1 at the end of the divide operation


    always @( posedge clk_i  /*or negedge rst_i*/)
    begin
        if(~rst_i)
        begin
            count          = 6'bx;
            hilo           = 65'b0;
            op2_reged      = 33'bx;
            op1_sign_reged = 1'bx;
            op2_sign_reged = 1'bx;
            sub_or_yn      = 1'bx;
            rdy            = 1'b1;
            start          = 1'bx;
            sign           = 1'bx;
            mul            = 1'bx;
            finish         = 1'bx;
            add1           = 1'bx;
            addop2         = 1'bx;
            addnop2        = 1'bx;
        end
        else begin

            if(op_type == OP_MTHI || op_type == OP_MTLO)
            begin
                if(op_type == OP_MTHI) hilo[64:32] = {1'b0,op1};
                if(op_type == OP_MTLO) hilo[31:0]  = op1;
                rdy = 1;
            end
            else if(rdy)
            begin
                start = (op_type == OP_MULT) || (op_type == OP_MULTU) || (op_type == OP_DIV)  || (op_type == OP_DIVU);
                mul   = (op_type == OP_MULT) || (op_type == OP_MULTU);
                sign  = (op_type == OP_MULT) || (op_type == OP_DIV);

                if(start)
                begin:START_SECTION
                    reg [32:0] over;

                    op2_reged       = {sign        ?op2[31]      :1'b0 ,op2};
                    hilo            = {~mul && sign?{33{op1[31]}}:33'b0,op1};
                    count           = 6'b000000;
                    rdy             = 0;
                    op1_sign_reged  = sign?op1[31]:0;
                    op2_sign_reged  = sign?op2[31]:0;
                    sub_or_yn       = 0;

                    over            = ~op2_reged + {op1[31],op1};
                    overflow        = sign && ~mul ? op1_sign_reged && op2_sign_reged && ~over[32] : 0;

                    finish          = 0;
                end
            end
            else if(start)
            begin
                if(overflow)
                begin
                    hilo[63:0] = {hilo[31:0],32'b0};
                    rdy        = 1;
                end
                else if(!count[5])
                begin
                    if(mul)
                    begin
                        if(sign)
                        begin
                            case({hilo[0],sub_or_yn})
                                2'b10:hilo[64:32] = hilo[64:32] + nop2_reged;
                                2'b01:hilo[64:32] = hilo[64:32] + op2_reged;
                                default:;
                            endcase
                            {hilo[63:0],sub_or_yn} = hilo[64:0];
                        end
                        else begin
                            if(hilo[0]) hilo[64:32] = hilo[64:32] + op2_reged;
                            hilo      = {1'b0,hilo[64:1]};
                        end
                    end
                    else begin
                        sub_or_yn  = hilo[64]== op2_sign_reged;
                        hilo[64:1] = hilo[63:0];

                        hilo[64:32] = sub_or_yn ? hilo[64:32] + nop2_reged : hilo[64:32] + op2_reged;

                        hilo[0]    = hilo[64]== op2_sign_reged;
                    end

                    count        = count + 1'b1;
                end
                else begin
                    if(finish)
                    begin
                        if(add1)   hilo[31:0]  = hilo[31:0] + 1;
                        case({addop2,addnop2})
                            2'b10:   hilo[64:32] = hilo[64:32] + op2_reged;
                            2'b01:   hilo[64:32] = hilo[64:32] + nop2_reged;
                            default: ;
                        endcase
                        rdy = 1;
                    end
                    else begin
                        {add1,addop2,addnop2} = 3'b000;
                        finish                = 1;

                        if(~mul)
                        begin:LAST_CYCLE_DEAL_SECTION
                            reg eqz,eqop2,eqnop2;
                            eqz    = hilo[64:32] == 0;
                            eqop2  = hilo[64:32] == op2_reged;
                            eqnop2 = hilo[64:32] == nop2_reged;
                            casex({op1_sign_reged,op2_sign_reged,eqz,eqop2,eqnop2})
                                5'b101xx : {add1,addop2,addnop2} = 3'b000;
                                5'b100x1 : {add1,addop2,addnop2} = 3'b010;
                                5'b111xx : {add1,addop2,addnop2} = 3'b100;
                                5'b1101x : {add1,addop2,addnop2} = 3'b101;
                                default :
                                begin:LAST_CYCLE_DEAL_SECTION_DEFAULT

                                    reg op1s_eq_op2s,op1s_eq_h64;
                                    op1s_eq_op2s = op1_sign_reged == op2_sign_reged;
                                    op1s_eq_h64  = op1_sign_reged == hilo[64];

                                    add1 = ~op1s_eq_op2s;
                                    case({op1s_eq_op2s,op1s_eq_h64})//synthesis parallel_case
                                        2'b00:   {addop2,addnop2} = 2'b01;
                                        2'b10:   {addop2,addnop2} = 2'b10;
                                        default: {addop2,addnop2} = 2'b00;
                                    endcase
                                end
                            endcase
                        end
                    end
                end
            end
        end
    end
endmodule


