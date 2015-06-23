`timescale 1ns / 1ps

module wishbone_master_mock #(
    parameter APPDATA_WIDTH           = 128  )
	(
    input clk, rst,
   
	 output 	reg								 	cyc_wb,
	 output	reg							    	stb_wb,
	 output	reg [30:0] 							address_wb,
	 output	reg [(APPDATA_WIDTH/8)-1:0]	sel_wb, //write mask	 
	 output	reg [APPDATA_WIDTH-1:0]		   wr_data_wb, // write data
	 output	reg  							   	we_wb,
	 output 	reg [2:0]							cti_wb,
	 output  reg [1:0]							bte_wb,
	 //to wishbone from memory interface
	 input										ack_mem, err_mem, rty_mem,
	 input	[APPDATA_WIDTH-1:0]			rd_data_mem,
	 output	[3:0]								state
	 );
	 
	    
    localparam WB_IDLE	= 4'b0000;
    localparam WR_CYC0	= 4'b0001;
    localparam WR_CYCI	= 4'b0010;
    localparam RD_REQ		= 4'b0011;
    localparam RD_WAIT_RSP= 4'b0100;
    localparam RD_RSP0		= 4'b0101;
    localparam RD_RSP1		= 4'b0110;
    localparam WR_CYCI_1		= 4'b0111;
    localparam STALL1		= 4'b1000;
	 localparam STALL2		= 4'b1001;
    
    
    
    reg [3:0] st_reg, st_nxt;
	 reg [1:0] cnt_reg, cnt_nxt;
	 reg [7:0] adr_cnt_reg, adr_cnt_nxt;
	 reg [4:0] op_cnt_reg, op_cnt_nxt;
    //reg [1:0] cnt_reg, cnt_nxt;
    //reg [APPDATA_WIDTH-1:0]		wr_data_reg, wr_data_nxt;
    //reg [(APPDATA_WIDTH/8)-1:0]	 wr_mask_reg, wr_mask_nxt;
    
  assign state = st_reg;  
	 
  always
		@(posedge clk, posedge rst)
	 begin
		if(rst)
			begin
				//wr_data_reg <= 0; 
	      st_reg <= 0; //st_reg;
			cnt_reg <= 0;
			adr_cnt_reg <= 0;
			op_cnt_reg <= 0;
			end
		else
			begin
				//wr_data_reg <= wr_data_nxt;
	      st_reg <= st_nxt;
			cnt_reg <= cnt_nxt;
			adr_cnt_reg <= adr_cnt_nxt;
			op_cnt_reg <= op_cnt_nxt;
			end
	 end
    
  //***************************************************************************
  // State Machine for mimicking responses from memory to mem_wb_if for wb bus
  //***************************************************************************
  always @*
  begin
	//for memory WR operations
	//wr_data_nxt = wr_data_reg;
	st_nxt = st_reg;
	sel_wb = 0;
	cyc_wb = 1'b0;
	stb_wb = 1'b0;
	we_wb = 1'bx;
	wr_data_wb = 0;
	cnt_nxt = cnt_reg;
	cti_wb = 3'b010;
	bte_wb = 2'b00;
	adr_cnt_nxt = adr_cnt_reg;
	op_cnt_nxt = op_cnt_reg;
	address_wb [30] = 1;
		
	case (st_reg)
		WB_IDLE:
			begin
				  //start with WR command
					st_nxt = WR_CYC0;
					cyc_wb = 1'b0;
					stb_wb = 1'b0;
					we_wb = 1'b0;
					address_wb = 8'h00;
					cti_wb = 3'b111;
					adr_cnt_nxt = 0;
					//adr_cnt_nxt = adr_cnt_reg + 32;
					wr_data_wb = 128'hBABEBABEBABEBABEBABEBABEBABEBABE;
					sel_wb = 16'hFFFFFFFF;
					
			end
		WR_CYC0:
				begin
				  cyc_wb = 1'b1;
					stb_wb = 1'b1;
					address_wb = adr_cnt_reg;
					address_wb [30] = 1;
					we_wb = 1'b1;
					sel_wb = 16'hFFFFFFFF;
				   wr_data_wb = 128'hBABEBABEBABEBABEBABEBABEBABEBABE;
					cti_wb = 3'b010;
					bte_wb = 2'b00;
					st_nxt = WR_CYCI;
				end
		WR_CYCI:
				begin
				  cyc_wb = 1'b1;
					stb_wb = 1'b1;
					address_wb = adr_cnt_reg;
					address_wb [30] = 1;
					we_wb = 1'b1;
					cti_wb = 3'b010;
					bte_wb = 2'b00;
					sel_wb = 16'hFFFFFFFF;
					//wait for ack
					if (ack_mem)
					begin
					   st_nxt = WR_CYCI_1;
						//wr_data_wb = 128'hADADADADADADADADADADADADADADADAD;
						wr_data_wb = 128'hBABEBABEBABEBABEBABEBABEBABEBABE;
					end
					else
					begin
					  st_nxt = WR_CYCI;
					  wr_data_wb = 128'hBABEBABEBABEBABEBABEBABEBABEBABE;
					end
				end
		WR_CYCI_1:
		     begin
					cyc_wb = 1'b1;
					stb_wb = 1'b1;
					we_wb  = 1'b1; 
					address_wb = adr_cnt_reg;
					address_wb [30] = 1;
					we_wb = 1'b1;
					wr_data_wb = 128'hADADADADADADADADADADADADADADADAD;
					sel_wb = 16'hFFFFFFFF;
					cti_wb = 3'b010;
					bte_wb = 2'b00;
					//wait for ack
					if (!ack_mem)
					begin
					   st_nxt = WR_CYCI_1;
					end
					else
					begin
					  st_nxt = 8;
					  cyc_wb = 1'b1;
					  stb_wb = 1'b1;
					  we_wb  = 1'b1; 
					  cti_wb = 3'b010;
					  op_cnt_nxt = 0;
					end
				end 
		8:
		    begin
		      if (op_cnt_reg == 0)
				begin
					st_nxt = RD_REQ;
					op_cnt_nxt = 0;
					adr_cnt_nxt = 0;
					//adr_cnt_nxt[30] = 1;
				end					
				else
				begin
					st_nxt = 8;
					op_cnt_nxt = op_cnt_reg + 1;
					//adr_cnt_nxt = adr_cnt_reg + 32;
				end
		      cyc_wb = 1'b0;
				stb_wb = 1'b0;
				we_wb  = 1'b0;
				cti_wb = 3'b111;
		    end
		RD_REQ: 
				begin
					cyc_wb = 1'b1;
					stb_wb = 1'b1;
					we_wb  = 1'b0;
					address_wb = adr_cnt_reg;
					address_wb [30] = 1;
					cti_wb = 3'b010;
					bte_wb = 2'b00;
					st_nxt = RD_WAIT_RSP;
				end
		RD_WAIT_RSP:
				begin
				  cyc_wb = 1'b1;
					stb_wb = 1'b1;
					we_wb  = 1'b0;
					address_wb = adr_cnt_reg;
					address_wb [30] = 1;
					cti_wb = 3'b010;
					bte_wb = 2'b00;
					cnt_nxt = 2;
					if (err_mem)
						st_nxt = WB_IDLE;
					else
					begin
						if (ack_mem)
							st_nxt = RD_RSP0;
						else
						  st_nxt = RD_WAIT_RSP;
					end
				end
		RD_RSP0:
				begin
				  cyc_wb = 1'b1;
					stb_wb = 1'b1;
					we_wb  = 1'b0;
					address_wb = adr_cnt_reg;
					address_wb [30] = 1;
					cti_wb = 3'b010;
					bte_wb = 2'b00;
					cnt_nxt = cnt_reg -1;
					if (ack_mem && (cnt_reg != 0))
					 begin
					   st_nxt = RD_RSP1;
					   //$display ("RD response available from mem ... \n");
					 end
					else
					  st_nxt = RD_RSP0;
				end
		 RD_RSP1:
				begin
					cyc_wb = 1'b1;
					stb_wb = 1'b1;
					we_wb  = 1'b0;
					address_wb = adr_cnt_reg;
					address_wb [30] = 1;
					cti_wb = 3'b010;
					bte_wb = 2'b00;
					//$display ("Data bus word: %h \n", rd_data_mem);
					cnt_nxt = cnt_reg - 1;
					if (ack_mem && (cnt_reg != 0))
					  st_nxt = RD_RSP1;
					 else
					 begin
					   //latch data
						st_nxt = 9;
						cyc_wb = 1'b0;
						stb_wb = 1'b0;
						we_wb  = 1'b0;
						cti_wb = 3'b010;
					   //$display ("Data bus word 2: %h", rd_data_mem);
					 end
				end
			10:
				begin
					st_nxt = 9;
					op_cnt_nxt = 0;
					cyc_wb = 1'b0;
					stb_wb = 1'b0;
					we_wb = 1'b0;
					//adr_cnt_nxt = adr_cnt_reg + 16;
					cti_wb = 3'b111;
				end
			9:
		    begin
		      if (op_cnt_reg == 0)
				begin
					st_nxt = WB_IDLE;//RD_REQ;
					op_cnt_nxt = 0;
					adr_cnt_nxt = 0;
					//adr_cnt_nxt[30] = 1;
				end					
				else
				begin
					st_nxt = 9;
					op_cnt_nxt = op_cnt_reg + 1;
					//adr_cnt_nxt = adr_cnt_reg + 32;
				end
		      cyc_wb = 1'b0;
				stb_wb = 1'b0;
				we_wb  = 1'b0;
				cti_wb = 3'b111;
		    end
		endcase
  end
	 
endmodule