`include "sd_defines.v"
module sd_controller_wb(
  wb_clk_i, wb_rst_i, wb_dat_i, wb_dat_o, 

  // WISHBONE slave
  wb_adr_i, wb_sel_i, wb_we_i, wb_cyc_i, wb_stb_i, wb_ack_o, 

  // WISHBONE master

 
  we_m_tx_bd, new_cmd,
  we_m_rx_bd, 
  we_ack, int_ack, cmd_int_busy,
  Bd_isr_reset,
  normal_isr_reset,
  error_isr_reset,
  int_busy,
  dat_in_m_tx_bd,
  dat_in_m_rx_bd,
  write_req_s,
  cmd_set_s,
  cmd_arg_s,
  argument_reg,
  cmd_setting_reg,
  status_reg,
  cmd_resp_1,
  software_reset_reg,
  time_out_reg,
  normal_int_status_reg,
  error_int_status_reg,
  normal_int_signal_enable_reg,
  error_int_signal_enable_reg,
  clock_divider,
  Bd_Status_reg,
  Bd_isr_reg,
  Bd_isr_enable_reg
  );
  
  // WISHBONE common
input           wb_clk_i;     // WISHBONE clock
input           wb_rst_i;     // WISHBONE reset
input   [31:0]  wb_dat_i;     // WISHBONE data input
output reg [31:0]  wb_dat_o;     // WISHBONE data output
     // WISHBONE error output

// WISHBONE slave
input   [7:0]  wb_adr_i;     // WISHBONE address input
input    [3:0]  wb_sel_i;     // WISHBONE byte select input
input           wb_we_i;      // WISHBONE write enable input
input           wb_cyc_i;     // WISHBONE cycle input
input           wb_stb_i;     // WISHBONE strobe input

output reg         wb_ack_o;     // WISHBONE acknowledge output


  
output reg we_m_tx_bd;

output reg new_cmd;
output reg we_ack; //CMD acces granted 
output reg int_ack; //Internal Delayed Ack;
output reg cmd_int_busy;

output reg we_m_rx_bd; //Write enable Master side Rx_bd
  //Read enable Master side Rx_bd
output reg int_busy;
input write_req_s;
input wire [15:0] cmd_set_s;
input wire [31:0] cmd_arg_s;


//
`define SUPPLY_VOLTAGE_3_3
`define SD_CARD_2_0

//Register Addreses 
`define argument 8'h00
`define command 8'h04
`define status 8'h08
`define resp1 8'h0c
`define controller 8'h1c
`define block 8'h20
`define power 8'h24
`define software 8'h28
`define timeout 8'h2c  
`define normal_isr 8'h30   
`define error_isr 8'h34  
`define normal_iser 8'h38
`define error_iser 8'h3c
`define capa 8'h48
`define clock_d 8'h4c
`define bd_status 8'h50
`define bd_isr 8'h54 
`define bd_iser 8'h58 
`define bd_rx 8'h60  
`define bd_tx 8'h80  



`ifdef SUPPLY_VOLTAGE_3_3
   parameter power_controll_reg  = 8'b0000_111_1;
`elsif SUPPLY_VOLTAGE_3_0
   parameter power_controll_reg  = 8'b0000_110_1;
`elsif SUPPLY_VOLTAGE_1_8
   parameter power_controll_reg  = 8'b0000_101_1;
`endif 

parameter block_size_reg = `BLOCK_SIZE ; //512-Bytes

`ifdef SD_BUS_WIDTH_4
     parameter controll_setting_reg =16'b0000_0000_0000_0010;
`else  
     parameter controll_setting_reg =16'b0000_0000_0000_0000;
`endif
     parameter capabilies_reg =16'b0000_0000_0000_0000;
   
//Buss accessible registers    
output reg [31:0] argument_reg;
output reg [15:0] cmd_setting_reg;
input  wire [15:0] status_reg;
input wire [31:0] cmd_resp_1;
output reg [7:0] software_reset_reg; 
output reg [15:0] time_out_reg;   
input wire [15:0]normal_int_status_reg; 
input wire [15:0]error_int_status_reg;
output reg [15:0]normal_int_signal_enable_reg;
output reg [15:0]error_int_signal_enable_reg;
output reg [7:0] clock_divider;
input  wire [15:0] Bd_Status_reg;   
input  wire [7:0] Bd_isr_reg;
output reg [7:0] Bd_isr_enable_reg;

//Register Controll
output reg Bd_isr_reset;
output reg normal_isr_reset;
output reg error_isr_reset;
output reg [`RAM_MEM_WIDTH-1:0] dat_in_m_rx_bd; //Data in to Rx_bd from Master
output reg [`RAM_MEM_WIDTH-1:0] dat_in_m_tx_bd;


//internal reg
reg [1:0] we;


always @(posedge wb_clk_i or posedge wb_rst_i)
	begin
	  we_m_rx_bd <= 0;
   	we_m_tx_bd <= 0;
	  new_cmd<= 1'b0 ;
	  we_ack <= 0;
	  int_ack =  1;
	  cmd_int_busy<=0;
     if ( wb_rst_i )begin
	    argument_reg <=0;
      cmd_setting_reg <= 0;
	    software_reset_reg <= 0;
	    time_out_reg <= 0;
	    normal_int_signal_enable_reg <= 0;
	    error_int_signal_enable_reg <= 0;	  
	    clock_divider <=`RESET_CLK_DIV;
	    int_ack=1 ;
	    we<=0;
	    int_busy <=0;
	    we_ack <=0;
	    wb_ack_o=0;
	    cmd_int_busy<=0;
	    Bd_isr_reset<=0;
	    dat_in_m_tx_bd<=0;
	    dat_in_m_rx_bd<=0;
	    Bd_isr_enable_reg<=0;
	    normal_isr_reset<=0;
	    error_isr_reset<=0;
	  end
	  else if ((wb_stb_i  & wb_cyc_i) || wb_ack_o )begin 
	    Bd_isr_reset<=0; 
	     normal_isr_reset<=  0;
	    error_isr_reset<=  0;
	    if (wb_we_i) begin
	      case (wb_adr_i) 
	        `argument: begin  
	            argument_reg  <=  wb_dat_i;
	            new_cmd <=  1'b1 ;	            
	         end
	        `command : begin 
	            cmd_setting_reg  <=  wb_dat_i;
	            int_busy <= 1;
	        end
          `software : software_reset_reg <=  wb_dat_i;
          `timeout : time_out_reg  <=  wb_dat_i;
          `normal_iser : normal_int_signal_enable_reg <=  wb_dat_i;
          `error_iser : error_int_signal_enable_reg  <=  wb_dat_i;
          `normal_isr : normal_isr_reset<=  1;
          `error_isr:  error_isr_reset<=  1;
	        `clock_d: clock_divider  <=  wb_dat_i;
	        `bd_isr: Bd_isr_reset<=  1;	    
	        `bd_iser : Bd_isr_enable_reg <= wb_dat_i ;     
	        `ifdef RAM_MEM_WIDTH_32
	          `bd_rx: begin
	             we <= we+1;	           
	             we_m_rx_bd <= 1;
	             int_ack =  0;	
	           if  (we[1:0]==2'b00)
	             we_m_rx_bd <= 0;
	           else if  (we[1:0]==2'b01) 
	            dat_in_m_rx_bd <=  wb_dat_i;	                   
	           else begin
	              int_ack =  1; 
	              we<= 0;
	              we_m_rx_bd <= 0;
	            end
	           
	        end
	        `bd_tx: begin
	           we <= we+1;	           
	           we_m_tx_bd <= 1;
	           int_ack =  0;	
	           if  (we[1:0]==2'b00)
	             we_m_tx_bd <= 0;
	           else if  (we[1:0]==2'b01) 
	            dat_in_m_tx_bd <=  wb_dat_i;                   
	           else begin
	             int_ack =  1; 
	              we<= 0;
	              we_m_tx_bd <= 0;
	            end
	        end
	        
	        `endif
	        `ifdef RAM_MEM_WIDTH_16
	        `bd_rx: begin
	             we <= we+1;	           
	             we_m_rx_bd <= 1;
	             int_ack =  0;	
	           if  (we[1:0]==2'b00)
	             we_m_rx_bd <= 0;
	           else if  (we[1:0]==2'b01) 
	            dat_in_m_rx_bd <=  wb_dat_i[15:0];	                    
	           else if ( we[1:0]==2'b10) 
	             dat_in_m_rx_bd <=  wb_dat_i[31:16];	            
	           else begin
	             int_ack =  1; 
	              we<= 0;
	              we_m_rx_bd <= 0;
	            end
	           
	        end
	        `bd_tx: begin
	           we <= we+1;	           
	           we_m_tx_bd <= 1;
	           int_ack =  0;	
	           if  (we[1:0]==2'b00)
	             we_m_tx_bd <= 0;
	           else if  (we[1:0]==2'b01) 
	            dat_in_m_tx_bd <=  wb_dat_i[15:0];	                    
	           else if ( we[1:0]==2'b10) 
	             dat_in_m_tx_bd <=  wb_dat_i[31:16];	            
	           else begin
	             int_ack =  1; 
	              we<= 0;
	              we_m_tx_bd <= 0;
	            end
	        end
	        `endif
	        
	      endcase
	    end     	     
	wb_ack_o =   wb_cyc_i & wb_stb_i & ~wb_ack_o & int_ack; 
	 end
	    else if (write_req_s) begin
	       new_cmd <=  1'b1 ; 
	       cmd_setting_reg <=   cmd_set_s; 
	       argument_reg  <=  cmd_arg_s ; 
	       cmd_int_busy<=  1; 
	       we_ack <= 1;
	    end  
	 
	 if (status_reg[0])
	    int_busy <=  0; 
	  
	//wb_ack_o =   wb_cyc_i & wb_stb_i & ~wb_ack_o & int_ack; 
end

always @(posedge wb_clk_i )begin
   if (wb_stb_i  & wb_cyc_i) begin //CS
      case (wb_adr_i)
	         `argument:  wb_dat_o  <=   argument_reg ;
	         `command : wb_dat_o <=  cmd_setting_reg ;
	         `status : wb_dat_o <=  status_reg ;
           `resp1 : wb_dat_o <=  cmd_resp_1 ;   
           
           `controller : wb_dat_o <=  controll_setting_reg ;
           `block :  wb_dat_o <=  block_size_reg ;
           `power : wb_dat_o <=  power_controll_reg ;
           `software : wb_dat_o  <=  software_reset_reg ;
           `timeout : wb_dat_o  <=  time_out_reg ;
           `normal_isr : wb_dat_o <=  normal_int_status_reg ;
           `error_isr : wb_dat_o  <=  error_int_status_reg ;
           `normal_iser : wb_dat_o <=  normal_int_signal_enable_reg ;
           `error_iser : wb_dat_o  <=  error_int_signal_enable_reg ;
            `clock_d : wb_dat_o  <= clock_divider;
	         `capa  : wb_dat_o  <=  capabilies_reg ; 
	         `bd_status : wb_dat_o  <=  Bd_Status_reg; 
	         `bd_isr : wb_dat_o  <=  Bd_isr_reg ; 
	         `bd_iser : wb_dat_o  <=  Bd_isr_enable_reg ; 
	    endcase
	  end 
end

  
  
endmodule
