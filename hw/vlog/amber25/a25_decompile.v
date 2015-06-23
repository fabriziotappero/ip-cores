//////////////////////////////////////////////////////////////////
//                                                              //
//  Decompiler for Amber 25 Core                                //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Decompiler for debugging core - not synthesizable           //
//  Shows instruction in Execute Stage at last clock of         //
//  the instruction                                             //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2011 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
//////////////////////////////////////////////////////////////////
`include "global_timescale.vh"
`include "global_defines.vh"
`include "a25_config_defines.vh"

module a25_decompile
(
input                       i_clk,
input                       i_core_stall,
input       [31:0]          i_instruction,
input                       i_instruction_valid,
input                       i_instruction_undefined,
input                       i_instruction_execute,
input       [2:0]           i_interrupt,            // non-zero value means interrupt triggered
input                       i_interrupt_state,
input       [31:0]          i_instruction_address,
input       [2:0]           i_pc_sel,
input                       i_pc_wen

);

`include "a25_localparams.vh"
        
`ifdef A25_DECOMPILE

integer i;

wire    [31:0]         imm32;
wire    [7:0]          imm8;
wire    [11:0]         offset12;
wire    [7:0]          offset8;
wire    [3:0]          reg_n, reg_d, reg_m, reg_s;
wire    [4:0]          shift_imm;
wire    [3:0]          opcode;
wire    [3:0]          condition;
wire    [3:0]          itype;
wire                   opcode_compare;
wire                   opcode_move;
wire                   no_shift;
wire                   shift_op_imm;
wire    [1:0]          mtrans_itype;
wire                   s_bit;

reg     [(5*8)-1:0]    xINSTRUCTION_EXECUTE;
reg     [(5*8)-1:0]    xINSTRUCTION_EXECUTE_R = "---   ";
wire    [(8*8)-1:0]    TYPE_NAME;
reg     [3:0]          fchars;
reg     [31:0]         execute_address = 'd0;
reg     [2:0]          interrupt_d1;
reg     [31:0]         execute_instruction = 'd0;
reg                    execute_now = 'd0;
reg                    execute_valid = 'd0;
reg                    execute_undefined = 'd0;


// ========================================================
// Delay instruction to Execute stage
// ========================================================
always @( posedge i_clk )
    if ( !i_core_stall && i_instruction_valid )
        begin
        execute_instruction <= i_instruction;
        execute_address     <= i_instruction_address;
        execute_undefined   <= i_instruction_undefined;
        execute_now         <= 1'd1;
        end
    else
        execute_now         <= 1'd0;


always @ ( posedge i_clk )
    if ( !i_core_stall )
        execute_valid <= i_instruction_valid;
    
// ========================================================
// Open File
// ========================================================
integer decompile_file;

initial 
    #1 decompile_file = $fopen(`A25_DECOMPILE_FILE, "w");


// ========================================================
// Fields within the instruction
// ========================================================
assign opcode       = execute_instruction[24:21];
assign condition    = execute_instruction[31:28];
assign s_bit        = execute_instruction[20];
assign reg_n        = execute_instruction[19:16];
assign reg_d        = execute_instruction[15:12];
assign reg_m        = execute_instruction[3:0];
assign reg_s        = execute_instruction[11:8];
assign shift_imm    = execute_instruction[11:7];
assign offset12     = execute_instruction[11:0];
assign offset8      = {execute_instruction[11:8], execute_instruction[3:0]};
assign imm8         = execute_instruction[7:0];
assign no_shift     = execute_instruction[11:4] == 8'h0;
assign mtrans_itype = execute_instruction[24:23];

assign opcode_compare =
            opcode == CMP || 
            opcode == CMN || 
            opcode == TEQ || 
            opcode == TST ;
            
assign opcode_move =
            opcode == MOV || 
            opcode == MVN ;
            
assign shift_op_imm = itype == REGOP && execute_instruction[25] == 1'd1;

assign imm32 =  execute_instruction[11:8] == 4'h0 ? {            24'h0, imm8[7:0] } :
                execute_instruction[11:8] == 4'h1 ? { imm8[1:0], 24'h0, imm8[7:2] } :
                execute_instruction[11:8] == 4'h2 ? { imm8[3:0], 24'h0, imm8[7:4] } :
                execute_instruction[11:8] == 4'h3 ? { imm8[5:0], 24'h0, imm8[7:6] } :
                execute_instruction[11:8] == 4'h4 ? { imm8[7:0], 24'h0            } :
                execute_instruction[11:8] == 4'h5 ? { 2'h0,  imm8[7:0], 22'h0 }     :
                execute_instruction[11:8] == 4'h6 ? { 4'h0,  imm8[7:0], 20'h0 }     :
                execute_instruction[11:8] == 4'h7 ? { 6'h0,  imm8[7:0], 18'h0 }     :
                execute_instruction[11:8] == 4'h8 ? { 8'h0,  imm8[7:0], 16'h0 }     :
                execute_instruction[11:8] == 4'h9 ? { 10'h0, imm8[7:0], 14'h0 }     :
                execute_instruction[11:8] == 4'ha ? { 12'h0, imm8[7:0], 12'h0 }     :
                execute_instruction[11:8] == 4'hb ? { 14'h0, imm8[7:0], 10'h0 }     :
                execute_instruction[11:8] == 4'hc ? { 16'h0, imm8[7:0], 8'h0  }     :
                execute_instruction[11:8] == 4'hd ? { 18'h0, imm8[7:0], 6'h0  }     :
                execute_instruction[11:8] == 4'he ? { 20'h0, imm8[7:0], 4'h0  }     :
                                                    { 22'h0, imm8[7:0], 2'h0  }     ;


// ========================================================
// Instruction decode
// ========================================================
// the order of these matters
assign itype = 
    {execute_instruction[27:23], execute_instruction[21:20], execute_instruction[11:4] } == { 5'b00010, 2'b00, 8'b00001001 } ? SWAP     :  // Before REGOP
    {execute_instruction[27:22], execute_instruction[7:4]                              } == { 6'b000000, 4'b1001           } ? MULT     :  // Before REGOP
    {execute_instruction[27:26]                                                        } == { 2'b00                        } ? REGOP    :    
    {execute_instruction[27:26]                                                        } == { 2'b01                        } ? TRANS    :
    {execute_instruction[27:25]                                                        } == { 3'b100                       } ? MTRANS   :
    {execute_instruction[27:25]                                                        } == { 3'b101                       } ? BRANCH   :
    {execute_instruction[27:25]                                                        } == { 3'b110                       } ? CODTRANS :
    {execute_instruction[27:24], execute_instruction[4]                                } == { 4'b1110, 1'b0                } ? COREGOP  :
    {execute_instruction[27:24], execute_instruction[4]                                } == { 4'b1110, 1'b1                } ? CORTRANS :
                                                                                                                               SWI      ;

                                                                                                                 
//
// Convert some important signals to ASCII
// so their values can easily be displayed on a waveform viewer
//
assign TYPE_NAME    = itype == REGOP    ? "REGOP   " :
                      itype == MULT     ? "MULT    " :
                      itype == SWAP     ? "SWAP    " :
                      itype == TRANS    ? "TRANS   " : 
                      itype == MTRANS   ? "MTRANS  " : 
                      itype == BRANCH   ? "BRANCH  " : 
                      itype == CODTRANS ? "CODTRANS" : 
                      itype == COREGOP  ? "COREGOP " : 
                      itype == CORTRANS ? "CORTRANS" : 
                      itype == SWI      ? "SWI     " : 
                                         "UNKNOWN " ;
                                           

always @*
    begin
    
    if ( !execute_now ) 
        begin 
        xINSTRUCTION_EXECUTE =  xINSTRUCTION_EXECUTE_R; 
        end // stalled

    else if ( itype == REGOP    && opcode == ADC                                                          ) xINSTRUCTION_EXECUTE = "adc  ";
    else if ( itype == REGOP    && opcode == ADD                                                          ) xINSTRUCTION_EXECUTE = "add  ";
    else if ( itype == REGOP    && opcode == AND                                                          ) xINSTRUCTION_EXECUTE = "and  ";
    else if ( itype == BRANCH   && execute_instruction[24] == 1'b0                                        ) xINSTRUCTION_EXECUTE = "b    ";
    else if ( itype == REGOP    && opcode == BIC                                                          ) xINSTRUCTION_EXECUTE = "bic  ";
    else if ( itype == BRANCH   && execute_instruction[24] == 1'b1                                        ) xINSTRUCTION_EXECUTE = "bl   ";
    else if ( itype == COREGOP                                                                            ) xINSTRUCTION_EXECUTE = "cdp  ";
    else if ( itype == REGOP    && opcode == CMN                                                          ) xINSTRUCTION_EXECUTE = "cmn  ";
    else if ( itype == REGOP    && opcode == CMP                                                          ) xINSTRUCTION_EXECUTE = "cmp  ";
    else if ( itype == REGOP    && opcode == EOR                                                          ) xINSTRUCTION_EXECUTE = "eor  ";
    else if ( itype == CODTRANS && execute_instruction[20] == 1'b1                                        ) xINSTRUCTION_EXECUTE = "ldc  ";
    else if ( itype == MTRANS   && execute_instruction[20] == 1'b1                                        ) xINSTRUCTION_EXECUTE = "ldm  ";
    else if ( itype == TRANS    && {execute_instruction[22],execute_instruction[20]}    == {1'b0, 1'b1}   ) xINSTRUCTION_EXECUTE = "ldr  ";
    else if ( itype == TRANS    && {execute_instruction[22],execute_instruction[20]}    == {1'b1, 1'b1}   ) xINSTRUCTION_EXECUTE = "ldrb ";
    else if ( itype == CORTRANS && execute_instruction[20] == 1'b0                                        ) xINSTRUCTION_EXECUTE = "mcr  ";
    else if ( itype == MULT     && execute_instruction[21] == 1'b1                                        ) xINSTRUCTION_EXECUTE = "mla  ";
    else if ( itype == REGOP    && opcode == MOV                                                          ) xINSTRUCTION_EXECUTE = "mov  ";
    else if ( itype == CORTRANS && execute_instruction[20] == 1'b1                                        ) xINSTRUCTION_EXECUTE = "mrc  ";
    else if ( itype == MULT     && execute_instruction[21] == 1'b0                                        ) xINSTRUCTION_EXECUTE = "mul  ";
    else if ( itype == REGOP    && opcode == MVN                                                          ) xINSTRUCTION_EXECUTE = "mvn  ";
    else if ( itype == REGOP    && opcode == ORR                                                          ) xINSTRUCTION_EXECUTE = "orr  ";
    else if ( itype == REGOP    && opcode == RSB                                                          ) xINSTRUCTION_EXECUTE = "rsb  ";
    else if ( itype == REGOP    && opcode == RSC                                                          ) xINSTRUCTION_EXECUTE = "rsc  ";
    else if ( itype == REGOP    && opcode == SBC                                                          ) xINSTRUCTION_EXECUTE = "sbc  ";
    else if ( itype == CODTRANS && execute_instruction[20] == 1'b0                                        ) xINSTRUCTION_EXECUTE = "stc  ";
    else if ( itype == MTRANS   && execute_instruction[20] == 1'b0                                        ) xINSTRUCTION_EXECUTE = "stm  ";
    else if ( itype == TRANS    && {execute_instruction[22],execute_instruction[20]}    == {1'b0, 1'b0}   ) xINSTRUCTION_EXECUTE = "str  ";
    else if ( itype == TRANS    && {execute_instruction[22],execute_instruction[20]}    == {1'b1, 1'b0}   ) xINSTRUCTION_EXECUTE = "strb ";
    else if ( itype == REGOP    && opcode == SUB                                                          ) xINSTRUCTION_EXECUTE = "sub  ";  
    else if ( itype == SWI                                                                                ) xINSTRUCTION_EXECUTE = "swi  ";  
    else if ( itype == SWAP     && execute_instruction[22] == 1'b0                                        ) xINSTRUCTION_EXECUTE = "swp  ";  
    else if ( itype == SWAP     && execute_instruction[22] == 1'b1                                        ) xINSTRUCTION_EXECUTE = "swpb ";  
    else if ( itype == REGOP    && opcode == TEQ                                                          ) xINSTRUCTION_EXECUTE = "teq  ";  
    else if ( itype == REGOP    && opcode == TST                                                          ) xINSTRUCTION_EXECUTE = "tst  ";  
    else                                                                                                    xINSTRUCTION_EXECUTE = "unkow";  
    end

always @ ( posedge i_clk )
    xINSTRUCTION_EXECUTE_R <= xINSTRUCTION_EXECUTE;
        
// =================================================================================
// Memory Reads and Writes
// =================================================================================

reg [31:0] tmp_address;


always @( posedge i_clk )
    begin
    // Data Write    
    if ( get_1bit_signal(0) && !get_1bit_signal(3) )
        begin
        
        $fwrite(decompile_file, "%09d              write   addr ", `U_TB.clk_count);
        tmp_address = get_32bit_signal(2);
        fwrite_hex_drop_zeros(decompile_file, {tmp_address [31:2], 2'd0} );
                  
        $fwrite(decompile_file, ", data %08h, be %h", 
                get_32bit_signal(3),    // u_cache.i_write_data
                get_4bit_signal (0));   // u_cache.i_byte_enable
                                       
        $fwrite(decompile_file, "\n");
        end
    
    // Data Read    
    if ( get_1bit_signal(4) && !get_1bit_signal(1) )     
        begin
        $fwrite(decompile_file, "%09d              read    addr ", `U_TB.clk_count);
        tmp_address = get_32bit_signal(5);
        fwrite_hex_drop_zeros(decompile_file, {tmp_address[31:2], 2'd0} );    
                     
        $fwrite(decompile_file, ", data %08h to ", get_32bit_signal(4));
        warmreg(get_4bit_signal(1)); 
                                      
        $fwrite(decompile_file, "\n");
        end

    // instruction
    if ( execute_now )
        begin
        
            // Interrupts override instructions that are just starting
        if ( interrupt_d1 == 3'd0 || interrupt_d1 == 3'd7 )
            begin
            $fwrite(decompile_file,"%09d  ", `U_TB.clk_count);
            
            // Right justify the address
            if      ( execute_address < 32'h10)        $fwrite(decompile_file,"       %01x:  ", {execute_address[ 3:1], 1'd0});
            else if ( execute_address < 32'h100)       $fwrite(decompile_file,"      %02x:  ",  {execute_address[ 7:1], 1'd0}); 
            else if ( execute_address < 32'h1000)      $fwrite(decompile_file,"     %03x:  ",   {execute_address[11:1], 1'd0}); 
            else if ( execute_address < 32'h10000)     $fwrite(decompile_file,"    %04x:  ",    {execute_address[15:1], 1'd0});
            else if ( execute_address < 32'h100000)    $fwrite(decompile_file,"   %05x:  ",     {execute_address[19:1], 1'd0});
            else if ( execute_address < 32'h1000000)   $fwrite(decompile_file,"  %06x:  ",      {execute_address[23:1], 1'd0});
            else if ( execute_address < 32'h10000000)  $fwrite(decompile_file," %07x:  ",       {execute_address[27:1], 1'd0});
            else                                       $fwrite(decompile_file,"%8x:  ",         {execute_address[31:1], 1'd0});
            
            // Mark that the instruction is not being executed 
            // condition field in execute stage allows instruction to execute ?
            if (!i_instruction_execute)
                begin
                $fwrite(decompile_file,"-");
                if ( itype == SWI )
                    $display ("Cycle %09d  SWI not taken *************", `U_TB.clk_count);
                end
            else     
                $fwrite(decompile_file," ");
                
            // ========================================
            // print the instruction name
            // ========================================
            case (numchars( xINSTRUCTION_EXECUTE ))
                4'd1: $fwrite(decompile_file,"%s", xINSTRUCTION_EXECUTE[39:32] );
                4'd2: $fwrite(decompile_file,"%s", xINSTRUCTION_EXECUTE[39:24] );
                4'd3: $fwrite(decompile_file,"%s", xINSTRUCTION_EXECUTE[39:16] );
                4'd4: $fwrite(decompile_file,"%s", xINSTRUCTION_EXECUTE[39: 8] );
            default:  $fwrite(decompile_file,"%s", xINSTRUCTION_EXECUTE[39: 0] );
            endcase

            fchars = 8 - numchars(xINSTRUCTION_EXECUTE);
        
            // Print the Multiple transfer itype
            if (itype   == MTRANS )
                begin
                w_mtrans_type;           
                fchars = fchars - 2;
                end

            // Print the s bit
           if ( ((itype == REGOP && !opcode_compare) || itype == MULT ) && s_bit == 1'b1 )
                begin
                $fwrite(decompile_file,"s");
                fchars = fchars - 1;
                end

            // Print the p bit
           if ( itype == REGOP && opcode_compare && s_bit == 1'b1 && reg_d == 4'd15 )
                begin
                $fwrite(decompile_file,"p");
                fchars = fchars - 1;
                end

            // Print the condition code
            if ( condition != AL )
                begin
                wcond;
                fchars = fchars - 2;
                end
                            
            // Align spaces after instruction    
            case ( fchars )
                4'd0: $fwrite(decompile_file,"");
                4'd1: $fwrite(decompile_file," ");
                4'd2: $fwrite(decompile_file,"  ");
                4'd3: $fwrite(decompile_file,"   ");
                4'd4: $fwrite(decompile_file,"    ");
                4'd5: $fwrite(decompile_file,"     ");
                4'd6: $fwrite(decompile_file,"      ");
                4'd7: $fwrite(decompile_file,"       ");
                4'd8: $fwrite(decompile_file,"        ");
            default:  $fwrite(decompile_file,"         ");
            endcase
        
            // ========================================
            // print the arguments for the instruction
            // ========================================
            case ( itype )
                REGOP:     regop_args;
                TRANS:     trans_args;
                MTRANS:    mtrans_args;
                BRANCH:    branch_args;
                MULT:      mult_args;
                SWAP:      swap_args;
                CODTRANS:  codtrans_args; 
                COREGOP:   begin 
                           // `TB_ERROR_MESSAGE
                           $write("Coregop not implemented in decompiler yet\n"); 
                           end
                CORTRANS:  cortrans_args; 
                SWI:       $fwrite(decompile_file,"#0x%06h", execute_instruction[23:0]);
                default: begin
                         `TB_ERROR_MESSAGE
                         $write("Unknown Instruction Type ERROR\n");
                         end                     
            endcase
            
            $fwrite( decompile_file,"\n" );
            end

        // Undefined Instruction Interrupts    
        if ( i_instruction_execute && execute_undefined )
            begin
            $fwrite( decompile_file,"%09d              interrupt undefined instruction", `U_TB.clk_count );
            $fwrite( decompile_file,", return addr " );
            $fwrite( decompile_file,"%08x\n",  pcf(get_reg_val(5'd21)-4'd4) );
            end
            
        // Software Interrupt  
        if ( i_instruction_execute && itype == SWI )    
            begin
            $fwrite( decompile_file,"%09d              interrupt swi", `U_TB.clk_count );
            $fwrite( decompile_file,", return addr " );
            $fwrite( decompile_file,"%08x\n",  pcf(get_reg_val(5'd21)-4'd4) );
            end
        end
    end
    
    

always @( posedge i_clk )
    if ( !i_core_stall )
        begin
        interrupt_d1 <= i_interrupt;
        
        // Asynchronous Interrupts    
        if ( interrupt_d1 != 3'd0 && i_interrupt_state )
            begin
            $fwrite( decompile_file,"%09d              interrupt ", `U_TB.clk_count );
            case ( interrupt_d1 )
                3'd1:    $fwrite( decompile_file,"data abort" );
                3'd2:    $fwrite( decompile_file,"firq" );
                3'd3:    $fwrite( decompile_file,"irq" );
                3'd4:    $fwrite( decompile_file,"address exception" );
                3'd5:    $fwrite( decompile_file,"instruction abort" );
                default: $fwrite( decompile_file,"unknown type" );
            endcase
            $fwrite( decompile_file,", return addr " );
            
            case ( interrupt_d1 )
                3'd1:    $fwrite(decompile_file,"%08h\n",  pcf(get_reg_val(5'd16)));
                3'd2:    $fwrite(decompile_file,"%08h\n",  pcf(get_reg_val(5'd17)));
                3'd3:    $fwrite(decompile_file,"%08h\n",  pcf(get_reg_val(5'd18)));
                3'd4:    $fwrite(decompile_file,"%08h\n",  pcf(get_reg_val(5'd19)));
                3'd5:    $fwrite(decompile_file,"%08h\n",  pcf(get_reg_val(5'd19)));
                3'd7:    $fwrite(decompile_file,"%08h\n",  pcf(get_reg_val(5'd20)));
                default: ;
            endcase
            end
        end


// jump
// Dont print a jump message for interrupts
always @( posedge i_clk )
        if ( 
             i_pc_sel != 3'd0 && 
             i_pc_wen &&
             !i_core_stall && 
             i_instruction_execute && 
             i_interrupt == 3'd0 &&
             !execute_undefined &&
             itype != SWI &&
             execute_address != get_32bit_signal(0)  // Don't print jump to same address
             )
            begin
            $fwrite(decompile_file,"%09d              jump    from ", `U_TB.clk_count);
            fwrite_hex_drop_zeros(decompile_file,  pcf(execute_address));
            $fwrite(decompile_file," to ");
            fwrite_hex_drop_zeros(decompile_file,  pcf(get_32bit_signal(0)) ); // u_execute.pc_nxt
            $fwrite(decompile_file,", r0 %08h, ",  get_reg_val ( 5'd0 ));
            $fwrite(decompile_file,"r1 %08h\n",    get_reg_val ( 5'd1 ));
            end


// =================================================================================
// Tasks
// =================================================================================

// Write Condition field
task wcond;
    begin
    case( condition)
        4'h0:    $fwrite(decompile_file,"eq");
        4'h1:    $fwrite(decompile_file,"ne");
        4'h2:    $fwrite(decompile_file,"cs");
        4'h3:    $fwrite(decompile_file,"cc");
        4'h4:    $fwrite(decompile_file,"mi");
        4'h5:    $fwrite(decompile_file,"pl");
        4'h6:    $fwrite(decompile_file,"vs");
        4'h7:    $fwrite(decompile_file,"vc");
        4'h8:    $fwrite(decompile_file,"hi");
        4'h9:    $fwrite(decompile_file,"ls"); 
        4'ha:    $fwrite(decompile_file,"ge"); 
        4'hb:    $fwrite(decompile_file,"lt");
        4'hc:    $fwrite(decompile_file,"gt");
        4'hd:    $fwrite(decompile_file,"le"); 
        4'he:    $fwrite(decompile_file,"  ");  // Always
        default: $fwrite(decompile_file,"nv");  // Never
    endcase    
    end
endtask

// ldm and stm types
task w_mtrans_type;
    begin
    case( mtrans_itype )
        4'h0:    $fwrite(decompile_file,"da");
        4'h1:    $fwrite(decompile_file,"ia");
        4'h2:    $fwrite(decompile_file,"db");
        4'h3:    $fwrite(decompile_file,"ib");
        default: $fwrite(decompile_file,"xx");
    endcase    
    end
endtask

// e.g. mrc	15, 0, r9, cr0, cr0, {0}
task cortrans_args;
    begin
    // Co-Processor Number
    $fwrite(decompile_file,"%1d, ", execute_instruction[11:8]);
    // opcode1
    $fwrite(decompile_file,"%1d, ", execute_instruction[23:21]);
    // Rd [15:12]
    warmreg(reg_d); 
    // CRn [19:16]
    $fwrite(decompile_file,", cr%1d", execute_instruction[19:16]);
    // CRm [3:0]
    $fwrite(decompile_file,", cr%1d", execute_instruction[3:0]);
    // Opcode2 [7:5]
    $fwrite(decompile_file,", {%1d}",   execute_instruction[7:5]);
    end
endtask


// ldc	15, 0, r9, cr0, cr0, {0}
task codtrans_args;
    begin
    // Co-Processor Number
    $fwrite(decompile_file,"%1d, ", execute_instruction[11:8]);
    // CRd [15:12]
    $fwrite(decompile_file,"cr%1d, ", execute_instruction[15:12]);
    // Rd [19:16]
    warmreg(reg_n); 
    end
endtask


task branch_args;
reg [31:0] shift_amount;
    begin
    if (execute_instruction[23]) // negative
        shift_amount = {~execute_instruction[23:0] + 24'd1, 2'd0};
    else
        shift_amount = {execute_instruction[23:0], 2'd0};

    if (execute_instruction[23]) // negative
        fwrite_hex_drop_zeros ( decompile_file, get_reg_val( 5'd21 ) - shift_amount );
    else             
        fwrite_hex_drop_zeros ( decompile_file, get_reg_val( 5'd21 ) + shift_amount );
    end
endtask


task mult_args;
    begin
    warmreg(reg_n);  // Rd is in the Rn position for MULT instructions
    $fwrite(decompile_file,", ");
    warmreg(reg_m);
    $fwrite(decompile_file,", ");
    warmreg(reg_s); 

    if (execute_instruction[21]) // MLA
        begin
        $fwrite(decompile_file,", ");
        warmreg(reg_d); 
        end
    end
endtask


task swap_args;
    begin
    warmreg(reg_d);
    $fwrite(decompile_file,", ");
    warmreg(reg_m);
    $fwrite(decompile_file,", [");
    warmreg(reg_n); 
    $fwrite(decompile_file,"]");
    end
endtask


task regop_args;
    begin
    if (!opcode_compare)
        warmreg(reg_d);
        
    if (!opcode_move )
        begin
        if (!opcode_compare)
            begin
            $fwrite(decompile_file,", ");
            if (reg_d < 4'd10 || reg_d > 4'd12) 
                $fwrite(decompile_file," ");
            end
        warmreg(reg_n);
        $fwrite(decompile_file,", ");
        if (reg_n < 4'd10 || reg_n > 4'd12) 
            $fwrite(decompile_file," ");
        end
    else
        begin
        $fwrite(decompile_file,", ");
        if (reg_d < 4'd10 || reg_d > 4'd12) 
            $fwrite(decompile_file," ");
        end    
            
    if (shift_op_imm)  
        begin
        if (|imm32[31:15])
            $fwrite(decompile_file,"#0x%08h", imm32);
        else
            $fwrite(decompile_file,"#%1d", imm32);
        end        
    else // Rm
        begin
        warmreg(reg_m);
        if (execute_instruction[4]) 
            // Register Shifts
            wshiftreg;
        else 
            // Immediate shifts
            wshift;
        end       
    end
endtask


task trans_args;
    begin
    warmreg(reg_d);   // Destination register

    casez ({execute_instruction[25:23], execute_instruction[21], no_shift, offset12==12'd0})
           6'b0100?0 : begin $fwrite(decompile_file,", ["); warmreg(reg_n); $fwrite(decompile_file,", #-%1d]" , offset12); end
           6'b0110?0 : begin $fwrite(decompile_file,", ["); warmreg(reg_n); $fwrite(decompile_file,", #%1d]"  , offset12); end
           6'b0100?1 : begin $fwrite(decompile_file,", ["); warmreg(reg_n); $fwrite(decompile_file,"]"); end
           6'b0110?1 : begin $fwrite(decompile_file,", ["); warmreg(reg_n); $fwrite(decompile_file,"]"); end
           6'b0101?? : begin $fwrite(decompile_file,", ["); warmreg(reg_n); $fwrite(decompile_file,", #-%1d]!", offset12); end
           6'b0111?? : begin $fwrite(decompile_file,", ["); warmreg(reg_n); $fwrite(decompile_file,", #%1d]!" , offset12); end

           6'b0000?0 : begin $fwrite(decompile_file,", ["); warmreg(reg_n); $fwrite(decompile_file,"], #-%1d", offset12); end
           6'b0010?0 : begin $fwrite(decompile_file,", ["); warmreg(reg_n); $fwrite(decompile_file,"], #%1d" , offset12); end
           6'b0001?0 : begin $fwrite(decompile_file,", ["); warmreg(reg_n); $fwrite(decompile_file,"], #-%1d", offset12); end
           6'b0011?0 : begin $fwrite(decompile_file,", ["); warmreg(reg_n); $fwrite(decompile_file,"], #%1d" , offset12); end
     
           6'b0000?1 : begin $fwrite(decompile_file,", ["); warmreg(reg_n); $fwrite(decompile_file,"]"); end
           6'b0010?1 : begin $fwrite(decompile_file,", ["); warmreg(reg_n); $fwrite(decompile_file,"]"); end
           6'b0001?1 : begin $fwrite(decompile_file,", ["); warmreg(reg_n); $fwrite(decompile_file,"]"); end
           6'b0011?1 : begin $fwrite(decompile_file,", ["); warmreg(reg_n); $fwrite(decompile_file,"]"); end

           6'b11001? : begin $fwrite(decompile_file,", ["); warmreg(reg_n); $fwrite(decompile_file,", -");  warmreg(reg_m); $fwrite(decompile_file,"]");  end
           6'b11101? : begin $fwrite(decompile_file,", ["); warmreg(reg_n); $fwrite(decompile_file,", ");   warmreg(reg_m); $fwrite(decompile_file,"]");  end
           6'b11011? : begin $fwrite(decompile_file,", ["); warmreg(reg_n); $fwrite(decompile_file,", -");  warmreg(reg_m); $fwrite(decompile_file,"]!"); end
           6'b11111? : begin $fwrite(decompile_file,", ["); warmreg(reg_n); $fwrite(decompile_file,", ");   warmreg(reg_m); $fwrite(decompile_file,"]!"); end

           6'b10001? : begin $fwrite(decompile_file,", ["); warmreg(reg_n); $fwrite(decompile_file,"], -"); warmreg(reg_m);  end
           6'b10101? : begin $fwrite(decompile_file,", ["); warmreg(reg_n); $fwrite(decompile_file,"], ");  warmreg(reg_m);  end
           6'b10011? : begin $fwrite(decompile_file,", ["); warmreg(reg_n); $fwrite(decompile_file,"], -"); warmreg(reg_m);  end
           6'b10111? : begin $fwrite(decompile_file,", ["); warmreg(reg_n); $fwrite(decompile_file,"], ");  warmreg(reg_m);  end

           6'b11000? : begin $fwrite(decompile_file,", ["); warmreg(reg_n); $fwrite(decompile_file,", -");  warmreg(reg_m); wshift; $fwrite(decompile_file,"]"); end
           6'b11100? : begin $fwrite(decompile_file,", ["); warmreg(reg_n); $fwrite(decompile_file,", ");   warmreg(reg_m); wshift; $fwrite(decompile_file,"]"); end
           6'b11010? : begin $fwrite(decompile_file,", ["); warmreg(reg_n); $fwrite(decompile_file,", -");  warmreg(reg_m); wshift; $fwrite(decompile_file,"]!");end
           6'b11110? : begin $fwrite(decompile_file,", ["); warmreg(reg_n); $fwrite(decompile_file,", ");   warmreg(reg_m); wshift; $fwrite(decompile_file,"]!");end

           6'b10000? : begin $fwrite(decompile_file,", ["); warmreg(reg_n); $fwrite(decompile_file,"], -"); warmreg(reg_m); wshift; end
           6'b10100? : begin $fwrite(decompile_file,", ["); warmreg(reg_n); $fwrite(decompile_file,"], ");  warmreg(reg_m); wshift; end
           6'b10010? : begin $fwrite(decompile_file,", ["); warmreg(reg_n); $fwrite(decompile_file,"], -"); warmreg(reg_m); wshift; end
           6'b10110? : begin $fwrite(decompile_file,", ["); warmreg(reg_n); $fwrite(decompile_file,"], ");  warmreg(reg_m); wshift; end

    endcase       
    end
endtask


task mtrans_args;
    begin
    warmreg(reg_n);
    if (execute_instruction[21]) $fwrite(decompile_file,"!");
    $fwrite(decompile_file,", {");
    for (i=0;i<16;i=i+1)
        if (execute_instruction[i])  
            begin 
            warmreg(i); 
            if (more_to_come(execute_instruction[15:0], i))
                $fwrite(decompile_file,", "); 
            end
    $fwrite(decompile_file,"}");
    // SDM: store the user mode registers, when in priviledged mode     
    if (execute_instruction[22:20] == 3'b100)  
        $fwrite(decompile_file,"^");
    end
endtask


task wshift;
    begin                                                                                                        
    // Check that its a valid shift operation. LSL by #0 is the null operator                                    
    if (execute_instruction[6:5] != LSL || shift_imm != 5'd0)                                                    
        begin                                                                                                    
        case(execute_instruction[6:5])                                                                           
            2'd0: $fwrite(decompile_file,", lsl");                                                               
            2'd1: $fwrite(decompile_file,", lsr");                                                               
            2'd2: $fwrite(decompile_file,", asr");                                                               
            2'd3: if (shift_imm == 5'd0) $fwrite(decompile_file,", rrx"); else $fwrite(decompile_file,", ror");  
        endcase                                                                                                  

       if (execute_instruction[6:5] != 2'd3 || shift_imm != 5'd0)                                                
           $fwrite(decompile_file," #%1d", shift_imm);                                                           
       end                                                                                                       
    end                                                                                                          
endtask


task wshiftreg;
    begin
    case(execute_instruction[6:5])
        2'd0: $fwrite(decompile_file,", lsl ");
        2'd1: $fwrite(decompile_file,", lsr ");
        2'd2: $fwrite(decompile_file,", asr ");
        2'd3: $fwrite(decompile_file,", ror "); 
    endcase

    warmreg(reg_s); 
    end
endtask


task warmreg;
input [3:0] regnum;
    begin
    if (regnum < 4'd12)
        $fwrite(decompile_file,"r%1d", regnum);
    else
    case (regnum)
        4'd12   : $fwrite(decompile_file,"ip");
        4'd13   : $fwrite(decompile_file,"sp");
        4'd14   : $fwrite(decompile_file,"lr");
        4'd15   : $fwrite(decompile_file,"pc");
    endcase
    end
endtask


task fwrite_hex_drop_zeros;
input [31:0] file;
input [31:0] num;
    begin
    if (num[31:28] != 4'd0) 
        $fwrite(file, "%x", num);
    else if (num[27:24] != 4'd0) 
        $fwrite(file, "%x", num[27:0]);
    else if (num[23:20] != 4'd0) 
        $fwrite(file, "%x", num[23:0]);
    else if (num[19:16] != 4'd0) 
        $fwrite(file, "%x", num[19:0]);
    else if (num[15:12] != 4'd0) 
        $fwrite(file, "%x", num[15:0]);
    else if (num[11:8] != 4'd0) 
        $fwrite(file, "%x", num[11:0]);
    else if (num[7:4] != 4'd0) 
        $fwrite(file, "%x", num[7:0]);
    else
        $fwrite(file, "%x", num[3:0]);
        
    end
endtask



// =================================================================================
// Functions
// =================================================================================

// Get current value of register
function [31:0] get_reg_val;
input [4:0] regnum;
begin
    case (regnum)
        5'd0   : get_reg_val = `U_REGISTER_BANK.r0_out;
        5'd1   : get_reg_val = `U_REGISTER_BANK.r1_out; 
        5'd2   : get_reg_val = `U_REGISTER_BANK.r2_out; 
        5'd3   : get_reg_val = `U_REGISTER_BANK.r3_out; 
        5'd4   : get_reg_val = `U_REGISTER_BANK.r4_out; 
        5'd5   : get_reg_val = `U_REGISTER_BANK.r5_out; 
        5'd6   : get_reg_val = `U_REGISTER_BANK.r6_out; 
        5'd7   : get_reg_val = `U_REGISTER_BANK.r7_out; 
        5'd8   : get_reg_val = `U_REGISTER_BANK.r8_out; 
        5'd9   : get_reg_val = `U_REGISTER_BANK.r9_out; 
        5'd10  : get_reg_val = `U_REGISTER_BANK.r10_out; 
        5'd11  : get_reg_val = `U_REGISTER_BANK.r11_out; 
        5'd12  : get_reg_val = `U_REGISTER_BANK.r12_out; 
        5'd13  : get_reg_val = `U_REGISTER_BANK.r13_out; 
        5'd14  : get_reg_val = `U_REGISTER_BANK.r14_out; 
        5'd15  : get_reg_val = `U_REGISTER_BANK.r15_out_rm; // the version of pc with status bits 
        
        5'd16  : get_reg_val = `U_REGISTER_BANK.r14_svc;
        5'd17  : get_reg_val = `U_REGISTER_BANK.r14_firq;
        5'd18  : get_reg_val = `U_REGISTER_BANK.r14_irq;
        5'd19  : get_reg_val = `U_REGISTER_BANK.r14_svc;
        5'd20  : get_reg_val = `U_REGISTER_BANK.r14_svc;
        5'd21  : get_reg_val = `U_REGISTER_BANK.r15_out_rn; // the version of pc without status bits 
    endcase
end
endfunction


function [31:0] get_32bit_signal;
input [2:0] num;
begin
    case (num)
        3'd0: get_32bit_signal = `U_EXECUTE.pc_nxt;
        3'd1: get_32bit_signal = `U_EXECUTE.o_iaddress;
        3'd2: get_32bit_signal = `U_EXECUTE.o_daddress;
        3'd3: get_32bit_signal = `U_EXECUTE.o_write_data;
//         3'd4: get_32bit_signal = `U_EXECUTE.read_data_filtered;
        3'd4: get_32bit_signal = `U_EXECUTE.i_wb_read_data;
        3'd5: get_32bit_signal = `U_WB.daddress_r;
    endcase
end
endfunction


function get_1bit_signal;
input [2:0] num;
begin
    case (num)
        3'd0: get_1bit_signal = `U_EXECUTE.o_write_enable;
        3'd1: get_1bit_signal = `U_AMBER.mem_stall;
        3'd2: get_1bit_signal = `U_EXECUTE.o_daddress_valid;
        3'd3: get_1bit_signal = `U_AMBER.core_stall;
        3'd4: get_1bit_signal = `U_WB.mem_read_data_valid_r;
    endcase
end
endfunction


function [3:0] get_4bit_signal;
input [2:0] num;
begin
    case (num)
        3'd0: get_4bit_signal = `U_EXECUTE.o_byte_enable;
        3'd1: get_4bit_signal = `U_WB.mem_load_rd_r;
    endcase
end
endfunction


function [3:0] numchars;
input [(5*8)-1:0] xINSTRUCTION_EXECUTE;
begin
     if (xINSTRUCTION_EXECUTE[31:0] == "    ")
    numchars = 4'd1;
else if (xINSTRUCTION_EXECUTE[23:0] == "   ")
    numchars = 4'd2;
else if (xINSTRUCTION_EXECUTE[15:0] == "  ")
    numchars = 4'd3;
else if (xINSTRUCTION_EXECUTE[7:0]  == " ")
    numchars = 4'd4;
else    
    numchars = 4'd5;
end
endfunction


function more_to_come;
input [15:0] regs;
input [31:0] i;
begin
case (i)
    15 : more_to_come = 1'd0;
    14 : more_to_come =  regs[15]    ? 1'd1 : 1'd0;
    13 : more_to_come = |regs[15:14] ? 1'd1 : 1'd0;
    12 : more_to_come = |regs[15:13] ? 1'd1 : 1'd0;
    11 : more_to_come = |regs[15:12] ? 1'd1 : 1'd0;
    10 : more_to_come = |regs[15:11] ? 1'd1 : 1'd0;
     9 : more_to_come = |regs[15:10] ? 1'd1 : 1'd0;
     8 : more_to_come = |regs[15: 9] ? 1'd1 : 1'd0;
     7 : more_to_come = |regs[15: 8] ? 1'd1 : 1'd0;
     6 : more_to_come = |regs[15: 7] ? 1'd1 : 1'd0;
     5 : more_to_come = |regs[15: 6] ? 1'd1 : 1'd0;
     4 : more_to_come = |regs[15: 5] ? 1'd1 : 1'd0;
     3 : more_to_come = |regs[15: 4] ? 1'd1 : 1'd0;
     2 : more_to_come = |regs[15: 3] ? 1'd1 : 1'd0;
     1 : more_to_come = |regs[15: 2] ? 1'd1 : 1'd0;
     0 : more_to_come = |regs[15: 1] ? 1'd1 : 1'd0;
endcase
end
endfunction

`endif

endmodule

