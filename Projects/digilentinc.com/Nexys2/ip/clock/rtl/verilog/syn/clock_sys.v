module 
cde_clock_sys
#(parameter   FREQ        = 48,  
              PLL_MULT    =  4,
              PLL_DIV     =  2,
              PLL_SIZE    =  4,
              CLOCK_SRC   =  0,
              RESET_SENSE =  0
)  

(
input  wire   a_clk_pad_in,
input  wire   b_clk_pad_in,
input  wire   pwron_pad_in,

output wire      div_clk_out,


output  reg   one_usec,
output  wire   reset

);

wire      ckIn;
reg 	  ref_reset;
   
reg [6:0] counter;   
reg [3:0] reset_cnt;

wire      pwron_reset;
   wire      dll_reset;

   
  wire ckOut;
   

	      
generate

if( CLOCK_SRC) 

  begin
  assign ckIn = b_clk_pad_in;
  end
else
  begin 
  assign ckIn = a_clk_pad_in;
  end		   

endgenerate


generate

if( RESET_SENSE) 

  begin
  assign pwron_reset = !pwron_pad_in;
  end
else
  begin 
  assign pwron_reset = pwron_pad_in;
  end		   

endgenerate




   
   

   

   

always@(posedge ckIn or posedge pwron_reset)
  if( pwron_reset)   reset_cnt     <= 4'b1111;
  else
  if(|reset_cnt)     reset_cnt     <= reset_cnt-4'b0001;
  else               reset_cnt     <= 4'b0000;
   


always@(posedge ckIn or posedge pwron_reset)
  if( pwron_reset)   ref_reset     <= 1'b1;
  else               ref_reset     <= |reset_cnt;

  






always@(posedge ckOut)
  if(dll_reset)                       
       begin
       one_usec  <=  1'b0;
       counter   <=  FREQ;
       end
  else if(counter == 7'b0000001)
       begin
       one_usec  <= !one_usec;
       counter   <=  FREQ;
       end
  else
       begin
       one_usec  <=  one_usec;	  
       counter   <=  counter -7'b0000001;
       end
       

wire    ckOut_pre;
      
DCM_SP #(
     .DLL_FREQUENCY_MODE   ("LOW"),
     .CLKIN_PERIOD         (20.0),         
     .CLK_FEEDBACK         ("2X"),         
     .DUTY_CYCLE_CORRECTION("TRUE"), 
     .CLKDV_DIVIDE         (2.0),                          
     .CLKFX_MULTIPLY       (4),          
     .CLKFX_DIVIDE         (1),            
     .PHASE_SHIFT          (0),              	 
     .CLKOUT_PHASE_SHIFT   ("NONE"), 
     .DESKEW_ADJUST        ("SYSTEM_SYNCHRONOUS"),
     .DFS_FREQUENCY_MODE   ("LOW"),     	 
     .STARTUP_WAIT         ("FALSE"),
     .CLKIN_DIVIDE_BY_2    ("FALSE") 
) DCM_SP_inst    (
      .CLKFX     (),     
      .CLKFX180  (),     
      .PSDONE    (),     
      .STATUS    (),     
      .PSCLK     (1'b0), 
      .PSEN      (1'b0), 
      .PSINCDEC  (1'b0), 
      .CLK0      (),
      .CLK180    (),
      .CLK270    (),
      .CLK2X     (ckOut_pre), 
      .CLK2X180  (), 
      .CLK90     (),      
      .CLKDV     (div_clk_out),
      .LOCKED    (),        
      .CLKFB     (ckOut),   
      .CLKIN     (ckIn), 
      .RST       (1'b0)  
   );


  BUFG 
  BUFG_inst (
            .I(ckOut_pre),      // Clock buffer input
            .O(ckOut)           // Clock buffer output
            );



cde_sync_with_reset 
  #(.WIDTH  (1),
    .DEPTH  (2),
    .RST_VAL(1'b1)
   ) 
  ref_rsync(
    .clk                 (div_clk_out),
    .reset_n             (!pwron_reset),
    .data_in             (ref_reset),
    .data_out            (reset)
       );



   
cde_sync_with_reset 
  #(.WIDTH  (1),
    .DEPTH  (2),
    .RST_VAL(1'b1)
   ) 
  dll_rsync(
    .clk                 (ckOut),
    .reset_n             (!pwron_reset),
    .data_in             (ref_reset),
    .data_out            (dll_reset)
       );
   

   
endmodule
