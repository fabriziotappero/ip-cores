 
`include "clairisc_def.h"
			  											    
`define ADDR_STATUS                3	   
`define ADDR_DVC_DATA              0 
`define ADDR_DVC_WR_ADDR           2
`define ADDR_DVC_RD_ADDR           1	

/*
#define    PORT_DATA        *(unsigned char*)0 
#define    IN_PORT_ADDR     *(unsigned char*)1 
#define    OUT_PORT_ADDR    *(unsigned char*)2 
#define    STATUS           *(unsigned char*)3 
*/

module  mem_man(
        input wr_en,
        input clk,
        input rst,	 
		
        input ci,
        input zi,
        input z_wr,
        input c_wr,
        
		output reg [7:0] dout,
        output co,
        input [7:0] din	   ,
        output reg [7:0]status     ,

        input  [4:0] rd_addr,  
        input  [4:0] wr_addr , 
 
	output reg [7:0]dvc_wr_addr,
	output reg [7:0]dvc_rd_addr,
	output reg  [7:0]data_mem2dvc,
	input [7:0]data_dvc2mem,
	output reg dvc_wr	,
	output /*reg */dvc_rd	
);		  

	
    reg wr_en_r;
    reg [7:0] din_r;
	reg [4:0] wr_addr_r;
    reg [4:0] rd_addr_r;

    always @(posedge clk)
    begin  
        wr_addr_r<=wr_addr;
        rd_addr_r<=rd_addr;
        wr_en_r<=wr_en;
        din_r<=din;
    end			  
	
    wire [7:0] ram_q ;
    wire [7:0] alt_ram_q;

 //   `ifdef SIM	
    sim_reg_file i_reg_file(
                     .data(din),
                     .wren(wr_en),
                     .wraddress(wr_addr[4:0]),
                     .rdaddress(rd_addr[4:0]),
                     .clock(clk),
                     .q(alt_ram_q));
 /*   `else	
    ram128x8 i_reg_file(
                 .data(din),
                 .wren(wr_en),
                 .wraddress(wr_addr),
                 .rdaddress(rd_addr),
                 .clock(clk),
                 .q(alt_ram_q)
             );	
    `endif
  */
    assign ram_q =/* ((wr_addr_r==rd_addr_r)&&(wr_en_r))?din_r:*/alt_ram_q;

    /*status register*/
    wire write_status = wr_addr[4:0] ==`ADDR_STATUS && wr_en;
    always@(posedge clk)
    begin
        if (rst)status<=8'h3f;//default value
        else
            if (write_status)status<=din;
            else
            begin
                if (c_wr)status[0]<=ci;
				if (z_wr)status[2]<=zi;
            end
    end		
			
    assign co = status[0];

    `ifdef SIM 	 						    
    always@(*)
    begin
        if (wr_en)
            $display("hex=>%x< char=>%x<",wr_addr[4:0],din[7:0]);
    end
    `endif 		  
	
    always@(*) 
    case(rd_addr_r[4:0])			   
		`ADDR_STATUS:dout = status;			    	  
	   	`ADDR_DVC_DATA :dout  = data_dvc2mem ;
        default dout = ram_q ;
    endcase			 	  
	
	always @ (posedge clk) if ((wr_addr[4:0]==`ADDR_DVC_WR_ADDR)&&(1==wr_en))dvc_wr_addr <=din;		
	always @ (posedge clk)	if ((wr_addr[4:0]==`ADDR_DVC_RD_ADDR)&&(1==wr_en))  dvc_rd_addr <=din;	
	always @ (posedge clk) if ((wr_addr[4:0]==`ADDR_DVC_DATA )&&(1==wr_en)) data_mem2dvc <=din;	  
	always	@ (*) dvc_wr  <=wr_en_r&(wr_addr==0);
	assign  dvc_rd   =	1'b1  ;					  			  
	
 
endmodule



