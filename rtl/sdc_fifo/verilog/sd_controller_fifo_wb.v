`include "sd_defines.v"

module sd_controller_fifo_wba
( 
    
    
  // WISHBONE common
  wb_clk_i, wb_rst_i, wb_dat_i, wb_dat_o, 

  // WISHBONE slave
  wb_adr_i, wb_sel_i, wb_we_i, wb_cyc_i, wb_stb_i, wb_ack_o, 
  
    // WISHBONE master

  //SD BUS
  sd_cmd_dat_i,sd_cmd_out_o,  sd_cmd_oe_o, 
  sd_dat_dat_i, sd_dat_out_o , sd_dat_oe_o, sd_clk_o_pad
  //PLL CLK_IN
   `ifdef SD_CLK_EXT
    ,sd_clk_i_pad
   `endif
  

);
input           wb_clk_i;     // WISHBONE clock
input           wb_rst_i;     // WISHBONE reset
input   [7:0]  wb_dat_i;     // WISHBONE data input
output  [7:0]  wb_dat_o;     // WISHBONE data output
     // WISHBONE error output

// WISHBONE slave
input   [2:0]  wb_adr_i;     // WISHBONE address input
input    [3:0]  wb_sel_i;     // WISHBONE byte select input
input           wb_we_i;      // WISHBONE write enable input
input           wb_cyc_i;     // WISHBONE cycle input
input           wb_stb_i;     // WISHBONE strobe input

output reg          wb_ack_o;     // WISHBONE acknowledge output

// WISHBONE master


input wire [3:0] sd_dat_dat_i;
output wire [3:0] sd_dat_out_o;
output wire sd_dat_oe_o;

input wire sd_cmd_dat_i;
output wire sd_cmd_out_o;
output wire sd_cmd_oe_o;

output sd_clk_o_pad;
wire sd_clk_i;

   `ifdef SD_CLK_EXT
     input sd_clk_i_pad;
   `endif
  


`define tx_cmd_fifo 4'h0
`define rx_cmd_fifo 4'h1
`define tx_data_fifo 4'h2
`define rx_data_fifo 4'h3
`define status 4'h4
`define controll 4'h5
`define timer 4'h6

reg [7:0] controll_reg;
reg [7:0] status_reg;
reg [7:0] command_timeout_reg;

`ifdef SD_CLK_BUS_CLK
  assign sd_clk_i = wb_clk_i;
`endif

`ifdef SD_CLK_EXT
  assign sd_clk_i = sd_clk_i_pad;
`endif
assign sd_clk_o=sd_clk_i;

reg [1:0] wb_fifo_adr_i_writer;
reg [1:0] wb_fifo_adr_i_reader;
wire [1:0] wb_fifo_adr_i;
reg add_token_read;
wire [7:0] wb_fifo_dat_i;
wire [7:0] wb_fifo_dat_o;
reg [7:0]  wb_dat_i_storage;
reg [7:0] wb_dat_o_i;
reg time_enable;
assign sd_clk_o_pad  = sd_clk_i ;


assign wb_fifo_adr_i = add_token_read ? wb_fifo_adr_i_reader : wb_fifo_adr_i_writer;
assign wb_fifo_dat_i =wb_dat_i_storage;
assign wb_dat_o = wb_adr_i[0] ? wb_fifo_dat_o :   wb_dat_o_i ;



wire [1:4]fifo_full ;
wire [1:4]fifo_empty;
reg wb_fifo_we_i;
reg wb_fifo_re_i;
wire [1:0] sd_adr_o;
wire [7:0] sd_dat_o;
wire [7:0] sd_dat_i;
sd_fifo sd_fifo_0
( 
   .wb_adr_i  (wb_fifo_adr_i ),
   .wb_dat_i  (wb_fifo_dat_i),
   .wb_dat_o  (wb_fifo_dat_o ),
   .wb_we_i   (wb_fifo_we_i),
   .wb_re_i   (wb_fifo_re_i),
   .wb_clk  (wb_clk_i),
   .sd_adr_i (sd_adr_o ),
   .sd_dat_i (sd_dat_o),
   .sd_dat_o (sd_dat_i ),
   .sd_we_i (sd_we_o),
   .sd_re_i (sd_re_o),
   .sd_clk (sd_clk_o),
   .fifo_full ( fifo_full ),
   .fifo_empty (fifo_empty    ),
   .rst (wb_rst_i) // | controll_reg[0])
  ) ; 
  
wire [1:0] sd_adr_o_cmd;
wire [7:0] sd_dat_i_cmd;
wire [7:0] sd_dat_o_cmd;

wire [1:0] sd_adr_o_dat;
wire [7:0] sd_dat_i_dat;
wire [7:0] sd_dat_o_dat;
wire [1:0] st_dat_t;
sd_cmd_phy sdc_cmd_phy_0
(
  .sd_clk (sd_clk_o),
  .rst (wb_rst_i ),//| controll_reg[0]),
  .cmd_dat_i ( sd_cmd_dat_i  ),
  .cmd_dat_o (sd_cmd_out_o   ),
  .cmd_oe_o (sd_cmd_oe_o   ),  
  .sd_adr_o (sd_adr_o_cmd),
  .sd_dat_i (sd_dat_i_cmd),
  .sd_dat_o (sd_dat_o_cmd),
  .sd_we_o (sd_we_o_cmd),
  .sd_re_o (sd_re_o_cmd),
  .fifo_full ( fifo_full[1:2] ),
  .fifo_empty ( fifo_empty [1:2]),
  .start_dat_t (st_dat_t),
  .fifo_acces_token (fifo_acces_token)
  ); 
  
  
  sd_data_phy sd_data_phy_0 (
  .sd_clk (sd_clk_o),
  .rst (wb_rst_i | controll_reg[0]),
  .DAT_oe_o ( sd_dat_oe_o  ),
  .DAT_dat_o (sd_dat_out_o),
  .DAT_dat_i  (sd_dat_dat_i ),
  .sd_adr_o (sd_adr_o_dat   ),
  .sd_dat_i (sd_dat_i_dat  ),
  .sd_dat_o (sd_dat_o_dat  ),
  .sd_we_o  (sd_we_o_dat),
  .sd_re_o (sd_re_o_dat),
  .fifo_full ( fifo_full[3:4] ),
  .fifo_empty ( fifo_empty [3:4]),
  .start_dat (st_dat_t),
  .fifo_acces (~fifo_acces_token)  
  ); 


  assign sd_adr_o =  fifo_acces_token ? sd_adr_o_cmd : sd_adr_o_dat; 
  assign sd_dat_o =  fifo_acces_token ? sd_dat_o_cmd : sd_dat_o_dat;
  assign sd_we_o  = fifo_acces_token ? sd_we_o_cmd : sd_we_o_dat;
  assign sd_re_o  =  fifo_acces_token ? sd_re_o_cmd : sd_re_o_dat;

 assign sd_dat_i_dat = sd_dat_i;
 assign sd_dat_i_cmd = sd_dat_i;

  
  always @(posedge wb_clk_i or posedge wb_rst_i)
	begin
	if (wb_rst_i)
	    status_reg<=0;
	  else begin	
      status_reg[0] <= fifo_full[1];
      status_reg[1] <= fifo_empty[2];
      status_reg[2] <=  fifo_full[3];
      status_reg[3] <=  fifo_empty[4];
    end
  end
  
  reg delayed_ack;
  always @(posedge wb_clk_i or posedge wb_rst_i)
	begin	
	  
	  if (wb_rst_i) 
	    wb_ack_o <=0; 
	   else 
	     wb_ack_o <=wb_stb_i & wb_cyc_i &  ~wb_ack_o & delayed_ack;
	  
	end
  
  always @(posedge wb_clk_i or posedge wb_rst_i)
	begin	
	   
	 
    if ( wb_rst_i )begin
	    command_timeout_reg<=`TIME_OUT_TIME;
	    wb_dat_i_storage<=0;
	    controll_reg<=0;
	  
	    wb_fifo_we_i<=0;
	    wb_fifo_adr_i_writer<=0;
	    time_enable<=0;
	  end
	  else if (wb_stb_i  & wb_cyc_i & (~wb_ack_o))begin //CS
	   
	   
	    if (wb_we_i) begin
	      case (wb_adr_i) 
	      `tx_cmd_fifo : begin
	        wb_fifo_adr_i_writer<=0;
	        wb_fifo_we_i<=1&!delayed_ack;
	        wb_dat_i_storage<=wb_dat_i;	       
	        command_timeout_reg<=`TIME_OUT_TIME;
	        time_enable<=1;
	      end       
        `tx_data_fifo : begin
	        wb_fifo_adr_i_writer<=2;
	        wb_fifo_we_i<=1&!delayed_ack;
	        wb_dat_i_storage<=wb_dat_i;
	        command_timeout_reg<=`TIME_OUT_TIME;
	        time_enable<=0;
	      end        
        `controll : controll_reg <= wb_dat_i;
  	      endcase
	    end  	  
	   end
	   else begin
	    //  wb_fifo_adr_i_writer<=0;
	      wb_fifo_we_i<=0;
	     
	     if (!status_reg[1])
	       time_enable<=0; 
	      
	     if ((command_timeout_reg!=0) && (time_enable))
	         command_timeout_reg<=command_timeout_reg-1;   
	   end   
end


always @(posedge wb_clk_i or posedge wb_rst_i )begin
   
  
   if ( wb_rst_i) begin
     add_token_read<=0;
     delayed_ack<=0;
     wb_fifo_re_i<=0;
      wb_fifo_adr_i_reader<=0;
      wb_dat_o_i<=0;
  end 
 else begin  
    delayed_ack<=0;
    wb_fifo_re_i<=0;
   if (wb_stb_i  & wb_cyc_i & (~wb_ack_o)) begin //C
   delayed_ack<=delayed_ack+1;
    add_token_read<=0;
    if (!wb_we_i) begin
  
      case (wb_adr_i)
      `rx_cmd_fifo : begin
         
         add_token_read<=1;
         wb_fifo_adr_i_reader<=1;
	      wb_fifo_re_i<=1&delayed_ack; 
	        
      end
      `rx_data_fifo :begin
         add_token_read<=1;
         wb_fifo_adr_i_reader<=3;
	       wb_fifo_re_i<=1 & delayed_ack;
	             
     end 
      `status : wb_dat_o_i <= status_reg;
      `timer : wb_dat_o_i <= command_timeout_reg;
        
       
     endcase
    end
  end  
end
end
 

//just to get rid of warnings....




endmodule


  
  
  
