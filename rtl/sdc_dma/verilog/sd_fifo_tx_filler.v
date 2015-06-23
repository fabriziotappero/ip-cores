`include "sd_defines.v"

module sd_fifo_tx_filler
( 
input clk,
input rst,
//WB Signals
output  [31:0]  m_wb_adr_o,

output  reg        m_wb_we_o,
input   [31:0]  m_wb_dat_i,

output    reg      m_wb_cyc_o,
output   reg       m_wb_stb_o,
input           m_wb_ack_i,
output  reg	[2:0] m_wb_cti_o,
output	reg [1:0]	 m_wb_bte_o,

//Data Master Control signals
input en,
input [31:0] adr,


//Data Serial signals 
input sd_clk,
output [31:0] dat_o, 
input rd,
output empty,
output fe
//

);
reg reset_tx_fifo;

reg [31:0] din;
reg wr_tx;
reg [8:0] we;
reg [8:0] offset;
wire [5:0]mem_empt;
sd_tx_fifo Tx_Fifo (
.d ( din ),
.wr  (  wr_tx ),
.wclk  (clk),
.q ( dat_o),
.rd (rd),
.full (fe),
.empty (empty),
.mem_empt (mem_empt),
.rclk (sd_clk),
.rst  (rst | reset_tx_fifo)
);


assign  m_wb_adr_o = adr+offset;


reg first;

reg ackd;
reg delay;

always @(posedge clk or posedge rst )begin
 if (rst) begin
	offset <=0;
	we <= 8'h1;
	m_wb_we_o <=0;
	m_wb_cyc_o <= 0;
	m_wb_stb_o <= 0;
	wr_tx<=0;
	ackd <=1;
	delay<=0;
	reset_tx_fifo<=1;

	first<=1;
	din<=0;
		m_wb_bte_o <= 2'b00;
		m_wb_cti_o <= 3'b000;

			
 end
 else if (en) begin //Start filling the TX buffer
    reset_tx_fifo<=0;
    
	  if (m_wb_ack_i) begin 		  
		  wr_tx <=1;
		  din <=m_wb_dat_i;	
		  					
		  m_wb_cyc_o <= 0;
		  m_wb_stb_o <= 0; 
		  delay<=~ delay;   
		end 
		else begin
			wr_tx <=0;
			
		end
	 
	  if (delay)begin
	     offset<=offset+`MEM_OFFSET;	
	     ackd<=~ackd;
	     delay<=~ delay;
	     wr_tx <=0; 
	  end
	  
		if ( !m_wb_ack_i & !fe & ackd  ) begin //If not full And no Ack  
		  m_wb_we_o <=0;
			m_wb_cyc_o <= 1;
			m_wb_stb_o <= 1; 
			ackd<=0;   
		end 
		
 
 end 
 else begin
   offset <=0;
   reset_tx_fifo<=1;
   m_wb_cyc_o <= 0;
   m_wb_stb_o <= 0; 
   m_wb_we_o <=0; 
		
		
 end 
end 
  
endmodule


