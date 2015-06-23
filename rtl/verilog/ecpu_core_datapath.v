`include "ecpu_core.vh"
module ecpu_core_datapath  (
                              A_ACC                      ,
                              B_ACC                      ,

                              A                          ,
                              B                          ,
                              S                          ,
                              Y                          ,
                              CLR                        ,
                              C                          ,
                              V                          ,
                              Z                          ,
                              rom_data_out               ,

                             rom_byte_required           ,
                             rom_byte_granted            ,
                             read_alu                    ,
                             load_alu                    ,
                             a_acc_reg_select            ,
                             b_acc_reg_select            ,
                             clk                         
                           );


  parameter DWIDTH  = 16;
  parameter OPWIDTH =  4;

  // rom parameters
  parameter Mk  =  1;
  parameter N   = 16;
  
  output    [(DWIDTH -1):0]     A_ACC             ;
  output    [(DWIDTH -1):0]     B_ACC             ;

  output    [(DWIDTH  -1):0]    A                 ;
  output    [(DWIDTH  -1):0]    B                 ;
  output    [(OPWIDTH -1):0]    S                 ;
  input     [(DWIDTH  -1):0]    Y                 ;
  output                        CLR               ;
  output                        C                 ;
  output                        V                 ;
  output                        Z                 ;
  
  input     [(N  -1):0]         rom_data_out      ;

  output                        rom_byte_required   ;
  input                         rom_byte_granted    ;
  input                         read_alu            ;
  input                         load_alu            ;
  input   [`A_ACC_SEL-1:0]      a_acc_reg_select    ;
  input   [`B_ACC_SEL-1:0]      b_acc_reg_select    ;
  input                         clk                 ;

  
  reg   [(DWIDTH -1):0]         A_ACC_reg           ;
  reg   [(DWIDTH -1):0]         B_ACC_reg           ;
 
  reg                           load_alu_reg0       ;
  reg                           load_alu_reg1       ;
  
  wire                          rom_byte_required   ; 
  
  
  
  assign  A_ACC =  (a_acc_reg_select == `ROM_OUT) ? rom_data_out : 
                      ((a_acc_reg_select == `ALU_OUT) ? ((load_alu_reg1)?S:(((load_alu|load_alu_reg0|load_alu_reg1))?rom_data_out:Y)) : A_ACC);
  assign  B_ACC =  (b_acc_reg_select == `ROM_OUT) ? rom_data_out : 
                      ((b_acc_reg_select == `ALU_OUT) ? Y : B_ACC);

  
  assign  A     = (load_alu     )  ? rom_data_out              : A;
  assign  B     = (load_alu_reg0)  ? rom_data_out              : B; 
  assign  S     = (read_alu     )  ? rom_data_out[OPWIDTH-1:0] : S;
  assign  CLR   = 0;
    
  assign rom_byte_required = (rom_byte_granted) ? 1'b1 : 1'b0;


  always @(posedge clk)
  begin
    load_alu_reg0 <= load_alu     ;
    load_alu_reg1 <= load_alu_reg0;
  end
                      
endmodule
