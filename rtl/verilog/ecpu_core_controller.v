`include "ecpu_core.vh"
module ecpu_core_controller (
                              INT_EXT       ,
                              RESET_N       ,
                              CLK           ,


                              A             ,
                              B             ,
                              S             ,
                              Y             ,
                              CLR           ,
                              C             ,
                              V             ,
                              Z             ,

                              ram_enable    ,
                              ram_rw_mask   ,
                              ram_address   ,
                              ram_rd        ,
                              ram_wr        ,
                              ram_data_in   ,
                              ram_data_out  ,

                              rom_enable    ,
                              rom_rw_mask   ,
                              rom_address   ,
                              rom_rd        ,
                              rom_data_out  ,

                              rom_byte_required           ,
                              rom_byte_granted            ,
                              rom_byte_valid              ,
                              
                              read_alu                    ,
                              load_alu                    ,
                              a_acc_reg_select            ,
                              b_acc_reg_select
                            );

  parameter DWIDTH  = 16;
  parameter OPWIDTH =  4;

  // rom parameters
  parameter Mk  =  1;
  parameter N   = 16;
  
  input                      INT_EXT       ;
  input                      RESET_N       ;
  input                      CLK           ;


  output   [(DWIDTH  -1):0]  A             ;
  output   [(DWIDTH  -1):0]  B             ;
  output   [(OPWIDTH -1):0]  S             ;
  input    [(DWIDTH  -1):0]  Y             ;
  output                     CLR           ;
  output                     C             ;
  output                     V             ;
  output                     Z             ;

  output                     ram_enable    ;
  output   [N-1:0]           ram_rw_mask   ;
  output   [(Mk*10-1):0]     ram_address   ;
  output                     ram_rd        ;
  output                     ram_wr        ;
  output   [N-1:0]           ram_data_in   ;
  input    [N-1:0]           ram_data_out  ;

  output                     rom_enable    ;
  output   [N-1:0]           rom_rw_mask   ;
  output   [(Mk*10-1):0]     rom_address   ;
  output                     rom_rd        ;
  input    [N-1:0]           rom_data_out  ; 
 

  input                      rom_byte_required ;
  output                     rom_byte_valid    ;
  output                     rom_byte_granted  ;
  
  output                     read_alu          ;
  output                     load_alu          ; 
  output    [`A_ACC_SEL-1:0] a_acc_reg_select  ;
  output    [`B_ACC_SEL-1:0] b_acc_reg_select  ;
  
  //////////////////////////////////////////////
  // registered outputs
  reg                        read_alu          ;
  reg                        load_alu          ;
  reg                        rom_byte_granted  ;
  reg                        rom_byte_valid    ;
  
  reg   [`A_ACC_SEL-1:0]     a_acc_reg_select  ;
  reg   [`B_ACC_SEL-1:0]     b_acc_reg_select  ;
  //////////////////////////////////////////////
    
  // address
  reg                        ram_enable_reg    ;
  reg   [N-1:0]              ram_rw_mask_reg   ;
  reg   [(Mk*10-1):0]        ram_address_reg   ;
  reg                        ram_rd_reg        ;
  reg                        ram_wr_reg        ;
  reg   [N-1:0]              ram_data_in_reg   ;

  reg                        rom_enable_reg    ;
  reg   [N-1:0]              rom_rw_mask_reg   ;
  reg   [(Mk*10-1):0]        rom_address_reg   ;
  reg                        rom_rd_reg        ;
  
  reg   [(Mk*10-1):0]        this_pcounter     ;
  reg   [(Mk*10-1):0]        next_pcounter     ;
  reg   [(Mk*10-1):0]        pcounter_tracker  ;


  reg                        halt_cpu          ;
  reg   [1:0]                counter           ;
  reg   [1:0]                next_counter      ;
    

  // hook up access for ram
  assign ram_enable   = ram_enable_reg      ;
  assign ram_rw_mask  = ram_rw_mask_reg    ;
  assign ram_address  = ram_address_reg    ;
  assign ram_rd       = ram_rd_reg              ;
  assign ram_wr       = ram_wr_reg              ;
  assign ram_data_in  = ram_data_in_reg    ;

  // hook up access for rom
  assign rom_enable   = rom_enable_reg      ;
  assign rom_rw_mask  = rom_rw_mask_reg    ;
  assign rom_address  = rom_address_reg    ;
  assign rom_rd       = rom_rd_reg              ;
  
  
  
  reg [2:0]         this_state;
  reg [2:0]         next_state;
  reg [3:0]         idle_count;

  // read instructions byte by byte
  always @(posedge CLK)
  begin
    if (!RESET_N)
    begin
      this_state <= 'h0;
      this_pcounter <= 'h0;
    end
    else
    begin
      this_state    <= next_state   ;
      this_pcounter <= next_pcounter;
    end
  end
  
  always @(posedge CLK)
  begin
    if (!halt_cpu)
    begin
      if ((rom_data_out == 'd7) && (a_acc_reg_select != `ALU_OUT))
      begin
        read_alu      <= 1'b1 ;
        next_counter  <= 0    ;
      end
      else if (rom_data_out == 'h80 )
      begin
        read_alu  <= 1'b0;
        load_alu  <= 1'b1;
        next_counter <= next_counter + 1;
      end
      else if (rom_address == ((1<<(Mk*10))-1))
      begin
        read_alu  <= 1'b0;
        load_alu  <= 1'b0;
        halt_cpu  <= 1;
        next_counter <= next_counter + 1;
      end
      else
      begin
        read_alu <= 1'b0;
        load_alu <= 1'b0;
        next_counter <= next_counter + 1;
      end
    end
    else if (!RESET_N)
    begin
      halt_cpu <= 1'b0;
    end
    
    
  end
  
  always @( 
            this_state          or 
            this_pcounter       or 
            rom_byte_required   or 
            rom_byte_granted    or 
            read_alu            or
            next_counter        or
            
            RESET_N             
          )
  begin

    if (!RESET_N)
    begin
      next_counter <= 0;
      counter      <= 0;
    end
    else
    begin
      case (this_state)
        `INITIALIZE       :   
                        begin
                          rom_enable_reg  <= 1'b0;
                          rom_rd_reg      <= 1'b0             ;
                          next_state      <= `INSTR_FETCH        ;
                          rom_byte_valid  <= 1'b0             ;
                          rom_byte_granted<= 1'b0             ;
                          //idle_count      <= 'd0              ;
                          next_pcounter   <= 'd0              ;
                        end
        `IDLE       :   
                        begin
                          rom_enable_reg  <= 1'b0;
                          rom_rd_reg      <= 1'b0             ;
                         if (rom_byte_required)
                            next_state      <= `INSTR_FETCH      ;
                          else
                            next_state      <= `IDLE          ;
                          rom_byte_valid  <= 1'b0             ;
                          rom_byte_granted<= 1'b0             ;

                          //idle_count      <= idle_count + 1   ;
                        end
        `INSTR_FETCH   :
                        begin
                          //idle_count      <= 'h0              ;
                          rom_enable_reg  <= 1'b1             ;
                          rom_rd_reg      <= 1'b1             ;
                          rom_rw_mask_reg <= {N{1'b1}}        ;
                          if  (halt_cpu)
                          begin
                            next_state      <= `HALT_CPU      ;
                          end
                          else
                          begin
                            rom_address_reg <= this_pcounter    ;
                            next_pcounter   <= this_pcounter + 1;
                            if (read_alu)
                              next_state      <= `READ_ALU      ;
                            else if  (rom_byte_required)
                              next_state      <= `INSTR_FETCH   ;
                            else
                              next_state      <= `IDLE          ;
                          end
                          a_acc_reg_select  <= `ROM_OUT       ;
                          rom_byte_valid  <= 1'b1             ;
                          rom_byte_granted<= 1'b1             ;

                        end
         `DATA_FETCH   :
                        begin
                          //idle_count      <= 'h0              ;
                          rom_enable_reg  <= 1'b1             ;
                          rom_rd_reg      <= 1'b1             ;
                          rom_rw_mask_reg <= {N{1'b1}}        ;
                          if  (halt_cpu)
                          begin
                            next_state      <= `HALT_CPU      ;
                          end
                          else
                          begin
                           rom_address_reg <= this_pcounter    ;
                           next_pcounter   <= this_pcounter + 1;
                           if (read_alu)
                              next_state      <= `READ_ALU      ;
                            else if  (rom_byte_required)
                              next_state      <= `INSTR_FETCH   ;
                            else
                              next_state      <= `IDLE          ;
                          end
                          a_acc_reg_select  <= `ROM_OUT       ;
                          rom_byte_valid  <= 1'b1             ;
                          rom_byte_granted<= 1'b1             ;

                        end
       `READ_ALU       :   
                        begin
                         if (counter < 3)
                         begin
                            next_state      <= `READ_ALU      ;
                            counter <= next_counter           ;
                            // three cycles to load alu,
                            // A, B, S(opcode)...fourth cycle is the result
                              rom_enable_reg  <= 1'b1;
                              rom_rd_reg      <= 1'b1             ;
                              rom_rw_mask_reg <= {N{1'b1}}        ;
                              rom_address_reg <= this_pcounter    ;
                              next_pcounter   <= this_pcounter + 1;
                        end
                         else
                         begin
                            next_state      <= `INSTR_FETCH      ;
                            counter <= 'd0;
                          rom_enable_reg  <= 1'b0;
                          rom_rd_reg      <= 1'b0             ;
                         end
                         a_acc_reg_select     <= `ALU_OUT     ;
                        end
        `RAM_READ   :
                        begin
                        end
        `HALT_CPU  :
                        begin
                          next_state <= `HALT_CPU;
                        end

      endcase
    end
  
  end
  

endmodule
