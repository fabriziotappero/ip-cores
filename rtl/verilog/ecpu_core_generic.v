`include "ecpu_core.vh"
module ecpu_core_generic  (
                            INT_EXT       ,
                            A_ACC         ,
                            B_ACC         ,
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
                            rom_data_out
                          );

  parameter DWIDTH  = 16;
  parameter OPWIDTH =  4;

  // rom parameters
  parameter Mk  =  1;
  parameter N   = 16;
  
  input                       INT_EXT           ;
  output    [(DWIDTH -1):0]   A_ACC             ;
  output    [(DWIDTH -1):0]   B_ACC             ;
  input                       RESET_N           ;
  input                       CLK               ;


  output    [(DWIDTH  -1):0]  A                 ;
  output    [(DWIDTH  -1):0]  B                 ;
  output    [(OPWIDTH -1):0]  S                 ;
  input     [(DWIDTH  -1):0]  Y                 ;
  output                      CLR               ;
  output                      C                 ;
  output                      V                 ;
  output                      Z                 ;

  output                      ram_enable        ;
  output    [N-1:0]           ram_rw_mask       ;
  output    [(Mk*10-1):0]     ram_address       ;
  output                      ram_rd            ;
  output                      ram_wr            ;
  output    [N-1:0]           ram_data_in       ;
  input     [N-1:0]           ram_data_out      ;

  output                      rom_enable        ;
  output    [N-1:0]           rom_rw_mask       ;
  output    [(Mk*10-1):0]     rom_address       ;
  output                      rom_rd            ;
  input     [N-1:0]           rom_data_out      ; 
 
 
  wire                        rom_byte_required ;
  wire                        rom_byte_valid    ;
  wire                        rom_byte_granted  ;
  
  wire                        read_alu          ;
  wire                        load_alu          ;
  
  wire      [`A_ACC_SEL-1:0]  a_acc_reg_select  ;
  wire      [`B_ACC_SEL-1:0]  b_acc_reg_select  ;
 
  ecpu_core_datapath     ecpu_core_datapath0  (
                                                A_ACC                       ,
                                                B_ACC                       ,
                                                A                           ,
                                                B                           ,
                                                S                           ,
                                                Y                           ,
                                                CLR                         ,
                                                C                           ,
                                                V                           ,
                                                Z                           ,
                                                rom_data_out                ,
                                                rom_byte_required           ,
                                                rom_byte_granted            ,
                                                read_alu                    ,
                                                load_alu                    ,
                                                a_acc_reg_select            ,
                                                b_acc_reg_select            ,
                                                CLK                         
                                              );
  ecpu_core_controller  ecpu_core_controller0 (
                                                INT_EXT                     ,
                                                RESET_N                     ,
                                                CLK                         ,


                                                A                           ,
                                                B                           ,
                                                S                           ,
                                                Y                           ,
                                                CLR                         ,
                                                C                           ,
                                                V                           ,
                                                Z                           ,

                                                ram_enable                  ,
                                                ram_rw_mask                 ,
                                                ram_address                 ,
                                                ram_rd                      ,
                                                ram_wr                      ,
                                                ram_data_in                 ,
                                                ram_data_out                ,

                                                rom_enable                  ,
                                                rom_rw_mask                 ,
                                                rom_address                 ,
                                                rom_rd                      ,
                                                rom_data_out                ,

                                                rom_byte_required           ,
                                                rom_byte_granted            ,
                                                rom_byte_valid              ,
                                                
                                                read_alu                    ,
                                                load_alu                    ,
                                                a_acc_reg_select            ,
                                                b_acc_reg_select
                                              );
  
  
endmodule
