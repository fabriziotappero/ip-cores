//////////////////////////////////////////////////////////////////
//                                                              //
//  Amber 2 Core top-Level module                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Instantiates the core consisting of fetch, instruction      //
//  decode, execute, and co-processor.                          //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2010 Authors and OPENCORES.ORG                 //
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


module a23_core
(
input                       i_clk,

input                       i_irq,              // Interrupt request, active high
input                       i_firq,             // Fast Interrupt request, active high

input                       i_system_rdy,       // Amber is stalled when this is low

// Wishbone Master I/F
output      [31:0]          o_wb_adr,
output      [3:0]           o_wb_sel,
output                      o_wb_we,
input       [31:0]          i_wb_dat,
output      [31:0]          o_wb_dat,
output                      o_wb_cyc,
output                      o_wb_stb,
input                       i_wb_ack,
input                       i_wb_err

);

wire      [31:0]          execute_address;
wire                      execute_address_valid;
wire      [31:0]          execute_address_nxt;  // un-registered version of execute_address to the cache rams
wire      [31:0]          write_data;
wire                      write_enable;
wire      [31:0]          read_data;
wire                      priviledged;
wire                      exclusive_exec;
wire                      data_access_exec;
wire      [3:0]           byte_enable;
wire                      data_access;          // high for data petch, low for instruction fetch
wire                      exclusive;            // swap access
wire                      cache_enable;         // Enabel the cache
wire                      cache_flush;          // Flush the cache
wire      [31:0]          cacheable_area;

wire                      fetch_stall;          // when this is asserted all registers in all 3 pipeline 
                                                // stages are held
                                                // at their current values
wire     [1:0]            status_bits_mode;               
wire                      status_bits_irq_mask;           
wire                      status_bits_firq_mask;           
wire                      status_bits_flags_wen;          
wire                      status_bits_mode_wen;           
wire                      status_bits_irq_mask_wen;       
wire                      status_bits_firq_mask_wen;       
wire     [31:0]           execute_status_bits;
                 
wire     [31:0]           imm32;                   
wire     [4:0]            imm_shift_amount; 
wire                      shift_imm_zero;      
wire     [3:0]            condition;               
wire     [31:0]           read_data_s2;            
wire     [4:0]            read_data_alignment;     

wire     [3:0]            rm_sel;                  
wire     [3:0]            rds_sel;                 
wire     [3:0]            rn_sel;                  
wire     [3:0]            rm_sel_nxt;
wire     [3:0]            rds_sel_nxt;
wire     [3:0]            rn_sel_nxt;
wire     [1:0]            barrel_shift_amount_sel; 
wire     [1:0]            barrel_shift_data_sel;   
wire     [1:0]            barrel_shift_function; 
wire                      use_carry_in;  
wire     [8:0]            alu_function;            
wire     [1:0]            multiply_function;       
wire     [2:0]            interrupt_vector_sel;    
wire     [3:0]            address_sel;             
wire     [1:0]            pc_sel;                  
wire     [1:0]            byte_enable_sel;         
wire     [2:0]            status_bits_sel;                
wire     [2:0]            reg_write_sel;           
wire                      user_mode_regs_load;     
wire                      user_mode_regs_store_nxt;    
wire                      firq_not_user_mode;

wire                      write_data_wen;          
wire                      copro_write_data_wen;          
wire                      base_address_wen;        
wire                      pc_wen;                  
wire     [14:0]           reg_bank_wen;            
wire     [3:0]            reg_bank_wsel;            

wire     [2:0]            copro_opcode1;
wire     [2:0]            copro_opcode2;
wire     [3:0]            copro_crn;    
wire     [3:0]            copro_crm;
wire     [3:0]            copro_num;
wire     [1:0]            copro_operation;
wire     [31:0]           copro_read_data;
wire     [31:0]           copro_write_data;
wire                      multiply_done;

wire                      decode_fault;
wire                      iabt_trigger;
wire                      dabt_trigger;

wire     [7:0]            decode_fault_status;
wire     [7:0]            iabt_fault_status;
wire     [7:0]            dabt_fault_status;

wire     [31:0]           decode_fault_address;
wire     [31:0]           iabt_fault_address;
wire     [31:0]           dabt_fault_address;

wire                      adex;


// data abort has priority
assign decode_fault_status  = dabt_trigger ? dabt_fault_status  : iabt_fault_status;
assign decode_fault_address = dabt_trigger ? dabt_fault_address : iabt_fault_address;
assign decode_fault         = dabt_trigger | iabt_trigger;


a23_fetch u_fetch (
    .i_clk                              ( i_clk                             ),

    .i_address                          ( {execute_address[31:2], 2'd0}     ),
    .i_address_valid                    ( execute_address_valid             ), 
    .i_address_nxt                      ( execute_address_nxt               ),
    .i_write_data                       ( write_data                        ),
    .i_write_enable                     ( write_enable                      ),
    .o_read_data                        ( read_data                         ),
    .i_priviledged                      ( priviledged                       ),
    .i_byte_enable                      ( byte_enable                       ),
    .i_data_access                      ( data_access                       ),      
    .i_exclusive                        ( exclusive                         ),
    .i_cache_enable                     ( cache_enable                      ),     
    .i_cache_flush                      ( cache_flush                       ), 
    .i_cacheable_area                   ( cacheable_area                    ),

    .i_system_rdy                       ( i_system_rdy                      ),
    .o_fetch_stall                      ( fetch_stall                       ),
    
    .o_wb_adr                           ( o_wb_adr                          ),
    .o_wb_sel                           ( o_wb_sel                          ),
    .o_wb_we                            ( o_wb_we                           ),
    .i_wb_dat                           ( i_wb_dat                          ),
    .o_wb_dat                           ( o_wb_dat                          ),
    .o_wb_cyc                           ( o_wb_cyc                          ),
    .o_wb_stb                           ( o_wb_stb                          ),
    .i_wb_ack                           ( i_wb_ack                          ),
    .i_wb_err                           ( i_wb_err                          )
);


a23_decode u_decode (
    .i_clk                              ( i_clk                             ),
    
    // Instruction fetch or data read signals
    .i_read_data                        ( read_data                         ),                                          
    .i_execute_address                  ( execute_address                   ),
    .i_adex                             ( adex                              ),
    .i_iabt                             ( 1'd0                              ),
    .i_dabt                             ( 1'd0                              ),
    .i_abt_status                       ( 8'd0                              ),                                          
    
    .o_read_data                        ( read_data_s2                      ),                                          
    .o_read_data_alignment              ( read_data_alignment               ),                                          
    
    .i_irq                              ( i_irq                             ),                                          
    .i_firq                             ( i_firq                            ),                                          
    .i_fetch_stall                      ( fetch_stall                       ),                                          
    .i_execute_status_bits              ( execute_status_bits               ),                                          
    .i_multiply_done                    ( multiply_done                     ),                                          
    
    .o_status_bits_mode                 ( status_bits_mode                  ),
    .o_status_bits_irq_mask             ( status_bits_irq_mask              ),  
    .o_status_bits_firq_mask            ( status_bits_firq_mask             ),  
    .o_imm32                            ( imm32                             ),
    .o_imm_shift_amount                 ( imm_shift_amount                  ),
    .o_shift_imm_zero                   ( shift_imm_zero                    ),
    .o_condition                        ( condition                         ),
    .o_exclusive_exec                   ( exclusive_exec                    ), 
    .o_data_access_exec                 ( data_access_exec                  ),
    .o_rm_sel                           ( rm_sel                            ),
    .o_rds_sel                          ( rds_sel                           ),
    .o_rn_sel                           ( rn_sel                            ),
    .o_rm_sel_nxt                       ( rm_sel_nxt                        ),
    .o_rds_sel_nxt                      ( rds_sel_nxt                       ),
    .o_rn_sel_nxt                       ( rn_sel_nxt                        ),
    .o_barrel_shift_amount_sel          ( barrel_shift_amount_sel           ),
    .o_barrel_shift_data_sel            ( barrel_shift_data_sel             ),
    .o_barrel_shift_function            ( barrel_shift_function             ),
    .o_use_carry_in                     ( use_carry_in                      ),
    .o_alu_function                     ( alu_function                      ),
    .o_multiply_function                ( multiply_function                 ),
    .o_interrupt_vector_sel             ( interrupt_vector_sel              ),
    .o_address_sel                      ( address_sel                       ),
    .o_pc_sel                           ( pc_sel                            ),
    .o_byte_enable_sel                  ( byte_enable_sel                   ),
    .o_status_bits_sel                  ( status_bits_sel                   ),
    .o_reg_write_sel                    ( reg_write_sel                     ),
    .o_user_mode_regs_load              ( user_mode_regs_load               ),
    .o_user_mode_regs_store_nxt         ( user_mode_regs_store_nxt          ),
    .o_firq_not_user_mode               ( firq_not_user_mode                ),
    .o_write_data_wen                   ( write_data_wen                    ),
    .o_base_address_wen                 ( base_address_wen                  ),
    .o_pc_wen                           ( pc_wen                            ),
    .o_reg_bank_wen                     ( reg_bank_wen                      ),
    .o_reg_bank_wsel                    ( reg_bank_wsel                     ),
    .o_status_bits_flags_wen            ( status_bits_flags_wen             ),
    .o_status_bits_mode_wen             ( status_bits_mode_wen              ),
    .o_status_bits_irq_mask_wen         ( status_bits_irq_mask_wen          ),
    .o_status_bits_firq_mask_wen        ( status_bits_firq_mask_wen         ),
    
    .o_copro_opcode1                    ( copro_opcode1                     ),                                        
    .o_copro_opcode2                    ( copro_opcode2                     ),                                        
    .o_copro_crn                        ( copro_crn                         ),                                        
    .o_copro_crm                        ( copro_crm                         ),                                        
    .o_copro_num                        ( copro_num                         ),                                        
    .o_copro_operation                  ( copro_operation                   ), 
    .o_copro_write_data_wen             ( copro_write_data_wen              ),                                        
    
    .o_iabt_trigger                     ( iabt_trigger                      ),
    .o_iabt_address                     ( iabt_fault_address                ),
    .o_iabt_status                      ( iabt_fault_status                 ),
    .o_dabt_trigger                     ( dabt_trigger                      ),
    .o_dabt_address                     ( dabt_fault_address                ),
    .o_dabt_status                      ( dabt_fault_status                 ) 
);


a23_execute u_execute (
    .i_clk                              ( i_clk                             ),
    
    .i_read_data                        ( read_data_s2                      ),
    .i_read_data_alignment              ( read_data_alignment               ), 
    .i_copro_read_data                  ( copro_read_data                   ),
    
    .o_write_data                       ( write_data                        ),
    .o_copro_write_data                 ( copro_write_data                  ),
    .o_address                          ( execute_address                   ),
    .o_address_valid                    ( execute_address_valid             ),
    .o_address_nxt                      ( execute_address_nxt               ),
    .o_adex                             ( adex                              ),

    .o_byte_enable                      ( byte_enable                       ),
    .o_data_access                      ( data_access                       ),
    .o_write_enable                     ( write_enable                      ),
    .o_exclusive                        ( exclusive                         ),
    .o_priviledged                      ( priviledged                       ),
    .o_status_bits                      ( execute_status_bits               ),
    .o_multiply_done                    ( multiply_done                     ),

    .i_fetch_stall                      ( fetch_stall                       ),   
    .i_status_bits_mode                 ( status_bits_mode                  ),   
    .i_status_bits_irq_mask             ( status_bits_irq_mask              ),   
    .i_status_bits_firq_mask            ( status_bits_firq_mask             ),   
    .i_imm32                            ( imm32                             ),   
    .i_imm_shift_amount                 ( imm_shift_amount                  ),   
    .i_shift_imm_zero                   ( shift_imm_zero                    ),   
    .i_condition                        ( condition                         ),   
    .i_exclusive_exec                   ( exclusive_exec                    ),   
    .i_data_access_exec                 ( data_access_exec                  ),   
    .i_rm_sel                           ( rm_sel                            ),   
    .i_rds_sel                          ( rds_sel                           ),   
    .i_rn_sel                           ( rn_sel                            ),   
    .i_rm_sel_nxt                       ( rm_sel_nxt                        ),
    .i_rds_sel_nxt                      ( rds_sel_nxt                       ),
    .i_rn_sel_nxt                       ( rn_sel_nxt                        ),
    .i_barrel_shift_amount_sel          ( barrel_shift_amount_sel           ),   
    .i_barrel_shift_data_sel            ( barrel_shift_data_sel             ),   
    .i_barrel_shift_function            ( barrel_shift_function             ),   
    .i_use_carry_in                     ( use_carry_in                      ),
    .i_alu_function                     ( alu_function                      ),   
    .i_multiply_function                ( multiply_function                 ),   
    .i_interrupt_vector_sel             ( interrupt_vector_sel              ),   
    .i_address_sel                      ( address_sel                       ),   
    .i_pc_sel                           ( pc_sel                            ),   
    .i_byte_enable_sel                  ( byte_enable_sel                   ),   
    .i_status_bits_sel                  ( status_bits_sel                   ),   
    .i_reg_write_sel                    ( reg_write_sel                     ),   
    .i_user_mode_regs_load              ( user_mode_regs_load               ),   
    .i_user_mode_regs_store_nxt         ( user_mode_regs_store_nxt          ),   
    .i_firq_not_user_mode               ( firq_not_user_mode                ),   
    .i_write_data_wen                   ( write_data_wen                    ),   
    .i_base_address_wen                 ( base_address_wen                  ),   
    .i_pc_wen                           ( pc_wen                            ),   
    .i_reg_bank_wen                     ( reg_bank_wen                      ),   
    .i_reg_bank_wsel                    ( reg_bank_wsel                     ),
    .i_status_bits_flags_wen            ( status_bits_flags_wen             ),   
    .i_status_bits_mode_wen             ( status_bits_mode_wen              ),   
    .i_status_bits_irq_mask_wen         ( status_bits_irq_mask_wen          ),   
    .i_status_bits_firq_mask_wen        ( status_bits_firq_mask_wen         ),   
    .i_copro_write_data_wen             ( copro_write_data_wen              )
);


a23_coprocessor u_coprocessor (
    .i_clk                              ( i_clk                             ),
    
    .i_fetch_stall                      ( fetch_stall                       ),
    .i_copro_opcode1                    ( copro_opcode1                     ),
    .i_copro_opcode2                    ( copro_opcode2                     ),
    .i_copro_crn                        ( copro_crn                         ),    
    .i_copro_crm                        ( copro_crm                         ),
    .i_copro_num                        ( copro_num                         ),
    .i_copro_operation                  ( copro_operation                   ),
    .i_copro_write_data                 ( copro_write_data                  ),
    
    .i_fault                            ( decode_fault                      ),
    .i_fault_status                     ( decode_fault_status               ),
    .i_fault_address                    ( decode_fault_address              ), 
    
    .o_copro_read_data                  ( copro_read_data                   ),
    .o_cache_enable                     ( cache_enable                      ),
    .o_cache_flush                      ( cache_flush                       ),
    .o_cacheable_area                   ( cacheable_area                    )
);


endmodule

