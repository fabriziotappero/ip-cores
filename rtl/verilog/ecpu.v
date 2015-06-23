module ecpu (
		          INT_EXT       , 
              A_ACC         ,
              B_ACC         ,
		          RESET_N       , 
		          CLK
		        );

  // alu parameters
  parameter DWIDTH  = 16;
  parameter OPWIDTH =  4;

  // rom parameters
  parameter Mk  =  1;
  parameter N   = 16;
  
	input                     INT_EXT       ;
  output  [(DWIDTH -1):0]   A_ACC         ;
	output  [(DWIDTH -1):0]   B_ACC         ;
  input                     RESET_N       ;
  input                     CLK           ;
   
  
	wire	  [(DWIDTH -1):0]   A             ;
	wire 	  [(DWIDTH -1):0]   B             ;
	wire 	  [(OPWIDTH-1):0]   S             ;
	wire	  [(DWIDTH -1):0]   Y             ;
	wire 	                    CLR           ;
	wire	                    alu_clk       ;
	wire	                    C             ;
	wire	                    V             ;
	wire	                    Z             ;

  wire                      ram_clk       ;
  wire                      ram_reset     ;
  wire                      ram_enable    ;
  wire  [N-1:0]             ram_rw_mask   ;
  wire  [(Mk*10-1):0]       ram_address   ;
  wire                      ram_rd        ;
  wire                      ram_wr        ;
  wire  [N-1:0]             ram_data_in   ;
  wire  [N-1:0]             ram_data_out  ;
  
  wire                      rom_clk       ;
  wire                      rom_reset     ;
  wire                      rom_enable    ;
  wire  [N-1:0]             rom_rw_mask   ;
  wire  [(Mk*10-1):0]       rom_address   ;
  wire                      rom_rd        ;
  wire                      rom_wr        ;
  wire  [N-1:0]             rom_data_in   ;
  wire  [N-1:0]             rom_data_out  ;
  
  // handle clocks for all sub blocks
  assign  alu_clk   = CLK       ;
  assign  ram_clk   = CLK       ;
  assign  rom_clk   = CLK       ;
  
  // handle resets for all sub blocks
  assign  CLR       = ~RESET_N  ;
  assign  ram_reset = ~RESET_N  ;
  assign  rom_reset = ~RESET_N  ;
  
  // handle other sub block specific settings
  
  assign  rom_wr    = 1'b0      ; // no write for ROM
  
  // instantiate ecpu_alu
  alu #(DWIDTH, OPWIDTH) ecpu_alu (
                                    A       , 
                                    B       , 
                                    S       , 
                                    Y       , 
                                    CLR     , 
                                    alu_clk , 
                                    C       , 
                                    V       , 
                                    Z
                                  );
                                  
  ram #(Mk, N)          ecpu_ram  (
                                    ram_clk       ,
                                    ram_reset     ,
                                    ram_enable    ,
                                    ram_rw_mask   ,
                                    ram_rd        , 
                                    ram_wr        ,
                                    ram_address   ,
                                    ram_data_in   ,
                                    ram_data_out
                                  );
                                  
  // instantiate ecpu_rom for program memory
  rom #(Mk, N)          ecpu_rom  (
                                    rom_clk       ,
                                    rom_reset     ,
                                    rom_enable    ,
                                    rom_rw_mask   ,
                                    rom_rd        , 
                                    rom_wr        ,
                                    rom_address   ,
                                    rom_data_in   ,
                                    rom_data_out
                                  );
  
  ecpu_core_generic     ecpu_core (
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
 
endmodule
