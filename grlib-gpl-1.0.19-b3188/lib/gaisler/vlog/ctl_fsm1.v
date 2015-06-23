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
module ctl_FSM (
    input   clk,
    input   hold,
    input   [2:0] id_cmd,
//  input   irq,
    input   rst,
    output  reg iack,
    output  reg zz_is_nop,
    output  reg id2ra_ctl_clr,
    output  reg id2ra_ctl_cls,
    output  reg id2ra_ins_clr,
    output  reg id2ra_ins_cls,
    output  reg [3:0] pc_prectl,
    output  reg ra2exec_ctl_clr
    );
    parameter
        ID_CUR   = `FSM_CUR,   ID_LD    = `FSM_LD ,
        ID_MUL   = `FSM_MUL,   ID_NOI   = `FSM_NOI,
        ID_RET   = `FSM_RET,
      
        PC_IGN   = `PC_IGN ,   PC_IRQ   = `PC_IRQ,
        PC_KEP   = `PC_KEP ,   PC_RST   = `PC_RST;

    reg [5:0] delay_counter;
    reg [4:0] CurrState ;
    reg [4:0] NextState ;
    reg     riack;
    always @(posedge clk) if (~rst) riack<=0; else riack<=iack;

    always @(*)
    begin //deal with iack
        case (CurrState )
            `IRQ:iack=1'b1;
            `RET:iack=1'b0;
            //onlt this 2 states those will change the iack state
            default iack=riack;
        endcase
    end

    always @ (posedge clk )
        if (~rst)delay_counter  <=0;
        else
        case (CurrState)
            //any delay state can be added here
            `MUL:       delay_counter  <=delay_counter + 1;
            default :     delay_counter  <=0;
        endcase

/////////////////////////////////////////////////////////
//    Finite State Machine 
//
  /*Finite State Machine part1*/
    always @ (posedge clk) if (~rst) CurrState  <= `RST; else if (hold) CurrState  <= NextState ;

    always @ (*)/*Finite State Machine part2*/
    begin
        case (CurrState)
            `IDLE:
            begin
                if (~rst)                    NextState  = `RST;
//                else if ((irq)&&(~riack))    NextState  = `IRQ;
                else if (id_cmd ==ID_NOI)    NextState  = `NOI;
                else if (id_cmd==ID_CUR)     NextState  = `CUR;
                else if (id_cmd==ID_MUL)     NextState  = `MUL;
                else if (id_cmd==ID_LD)      NextState  = `LD;
                else if (id_cmd==ID_RET)     NextState  = `RET;
                else                         NextState  = `IDLE;
            end      
            `NOI:
            begin
                if (id_cmd ==ID_NOI)         NextState  = `NOI;
                else if (id_cmd==ID_CUR)     NextState  = `CUR;
                else if (id_cmd==ID_MUL)     NextState  = `MUL;
                else if (id_cmd==ID_LD)      NextState  = `LD;
                else if (id_cmd==ID_RET)     NextState  = `RET;
                else                         NextState  = `IDLE;
            end
            `CUR:   NextState  = `NOI;         
            `RET:   NextState  = `IDLE;        
            `IRQ:   NextState  = `IDLE;         
            `RST:   NextState  = `IDLE;           
            `LD:    NextState  = `IDLE;   
            `MUL:   NextState  = (delay_counter==32)?`IDLE:`MUL;
            default NextState  =`IDLE;
        endcase
    end

    always @ (*)/*Finite State Machine part3*/
    begin
        case (CurrState )
            `IDLE: begin id2ra_ins_clr  =  1'b0;
                id2ra_ins_cls  =  1'b0;
                id2ra_ctl_clr  =  1'b0;
                id2ra_ctl_cls  =  1'b0;
                ra2exec_ctl_clr   =  1'b0;
                pc_prectl=PC_IGN;
                zz_is_nop = 0;end             
      `MUL:  begin
                id2ra_ins_clr  =  1'b1;
                id2ra_ins_cls  =  1'b0;
                id2ra_ctl_clr  =  1'b1;
                id2ra_ctl_cls  =  1'b0;
                ra2exec_ctl_clr  =  1'b0;
                pc_prectl =PC_KEP;
                zz_is_nop =0; end            
      `CUR:  begin
                id2ra_ins_clr  =  1'b0;
                id2ra_ins_cls  =  1'b1;
                id2ra_ctl_clr  =  1'b0;
                id2ra_ctl_cls  =  1'b1;
                ra2exec_ctl_clr  =  1'b1;
                pc_prectl =PC_KEP;
                zz_is_nop = 1; end            
      `RET: begin id2ra_ins_clr  =  1'b0;
                id2ra_ins_cls  =  1'b0;
                id2ra_ctl_clr  =  1'b0;
                id2ra_ctl_cls  =  1'b0;
                ra2exec_ctl_clr   =  1'b0;
                pc_prectl =PC_IGN;
                zz_is_nop = 1'b0;  end        
      `IRQ: begin
                id2ra_ins_clr  =  1'b1;
                id2ra_ins_cls  =  1'b0;
                id2ra_ctl_clr  =  1'b1;
                id2ra_ctl_cls  =  1'b0;
                ra2exec_ctl_clr  =  1'b1;
                pc_prectl =PC_IRQ;
                zz_is_nop = 1'b0;end       
      `RST: begin
                id2ra_ins_clr  =  1'b1;
                id2ra_ins_cls  =  1'b0;
                id2ra_ctl_clr  =  1'b1;
                id2ra_ctl_cls  =  1'b0;
                ra2exec_ctl_clr  =  1'b1;
                pc_prectl=PC_RST;
                zz_is_nop = 1'b1; end       
      `LD:begin
                id2ra_ins_clr  =  1'b1;
                id2ra_ins_cls  =  1'b0;
                id2ra_ctl_clr  =  1'b1;
                id2ra_ctl_cls  =  1'b0;
                ra2exec_ctl_clr  =  1'b0;
                pc_prectl =PC_KEP;
                zz_is_nop = 1'b0;end          
      `NOI:begin
                id2ra_ins_clr  =  1'b0;
                id2ra_ins_cls  =  1'b0;
                id2ra_ctl_clr  =  1'b0;
                id2ra_ctl_cls  =  1'b0;
                ra2exec_ctl_clr   =  1'b0;
                pc_prectl=PC_IGN;
                zz_is_nop = 1'b0;end         
      default   begin
                id2ra_ins_clr  =  1'b1;
                id2ra_ins_cls  =  1'b0;
                id2ra_ctl_clr  =  1'b1;
                id2ra_ctl_cls  =  1'b0;
                ra2exec_ctl_clr  =  1'b1;
                pc_prectl=PC_RST;
                zz_is_nop = 1'b1;end          
      endcase
    end
endmodule

