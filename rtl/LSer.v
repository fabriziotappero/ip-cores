// File name=Module= LSer     2005-04-23      btltz@mail.china.com       btltz from CASIC  
// Description:      Distributed line schedulers with 16 identic "routing table"(a "16 port memory" :-> ).
//                   1 table every Line Scheduler 
// Spec :            Note Port0 is in the routing table. But it is disposed by module "cfg_ctrl"     	    
//                   Because minimum latency is a key issue, the fifo empty flag is monitored and Router
//                   will transfer data whenever the buffer has data.
// Abbreviations: 	  Tab(TAB)   ---   table
// Origin:  SpaceWire Std - Draft-1(Clause 8)of ECSS(European Cooperation for Space Standardization),ESTEC,ESA.
//          SpaceWire Router Requirements Specification Issue 1 Rev 5. Astrium & University of Dundee 
// TODO:	     make rtl faster
////////////////////////////////////////////////////////////////////////////////////
//
/*synthesis translate_off*/
`include "timescale.v"
/*synthesis translate_on */
`define reset  1	               // WISHBONE standard reset
`define XIL_BRAM	    			   // Use Xilinx block RAM
`define XIL_DISRAM	 			   // Use Xilinx distributed RAM	

module LSer	#(parameter IF_PORTNUM =16, IO_DW =10,	              // interface port number=16. 
                        TRY_DW = IF_PORTNUM >16  ?  5   :
								         (IF_PORTNUM >8   ?  4   :  3 ),
                        ORG_AW = TRY_DW,
								TAB_DW = IF_PORTNUM+1                    // 16 IF_PORTNUM + 1 config port 
				  )
            (
// interface with SpW input ports
                  output reg  rd_IBUF_o,    // Note write to SpW IO port FIFO is performed by "switch core"
                  input [IO_DW-2:0]	SpW_di,		           // ignor the parity bit		
					   input  empty_IBUF_i,     // empty flag of SpW input interface buffer(fifo)
// config/control interface
                  output tab_d0_o,                      // d0 of the routing table value     
						input try_msb,	                       // if true, try "more(not most :-> ) significant bit"
						
						input [TAB_DW-1:0] tab_di,
						input we_tab_i,
						input [7:0] tab_WrAddr_i,
// origin line No.
                  input [ORG_AW-1:0] org_line_i,    
// Switch Matrix interface
                  output reg[IF_PORTNUM-1:0] we_cell_o,
					   //output sop_req_o,                    // pulse. start of package require 
						output [TRY_DW-1:0] cfg_SMX_o,         // try cnt data out to "config" switch matrix
						//output eop_o,	                     // pulse. end of package command
						//input  sop_ack_i,						   // level. responsion from switch matrix for sop
                  input [IF_PORTNUM-1:0] full_cell_i,
// global signal input						
						input reset,
						input gclk  
				);
	  
				  parameter EOP         = 9'b1_0000_0000;                 // {p,1'b1,8'b0000_0000}
				  parameter EEP         = 9'b1_0000_0001;   		          // {p,1'b1,8'b0000_0001}
				  parameter HEADS_Cargo = 9'b0_xxxx_xxxx;                 // {p,1'b0,1-byte data } 

				  parameter STATE_NUM   = 8; 
              parameter IDLE           = 8'b0000_0001;
				  parameter JUDGE_HEAD	   = 8'b0000_0010;
				  parameter DEL_HEAD       = 8'b0000_0100;
				  parameter TRY_ORG_COL    = 8'b0000_1000;
				  parameter INCR_TRY_COL   = 8'b0001_0000;
				  parameter DECR_TRY_COL   = 8'b0010_0000;
				  parameter DISTRIBUTING   = 8'b0100_0000;				   
              parameter GRAB_CELL_WAIT	= 8'b1000_0000;			 // N-Chars from one packet shall not be interleaved with N-Chars from another packet(but FCTs,NULLs,TimeCodes).		 

				  parameter HCW = TAB_DW <8  ?  3  :	       // Hot counter width
                					(TAB_DW <16  ?  4  :
					 					 (TAB_DW <32  ?   5   :
					   				  (TAB_DW <64  ?    6   :  2 )));
              parameter True  = 1;
				  parameter False = 0;

// dispose SpW data input from fifo 
reg [7:0] Head;
wire [8:0] SpW_data = SpW_di[8:0];										 // exclude parity bit
assign emgEXP = (SpW_data == EOP) || (SpW_data == EEP); // emerge	a Nchar(control data)
// assign emgEOP = (SpW_data == EOP);
// assign emgEEP = (SpW_data == EEP);
// assign emgEXX = (SpW_data[8]==1) && (   (|SpW_data[7:1]) != 1'b0  );

assign IBUF_HasData = !empty_IBUF_i;
assign head_ptr2cfg = ( |SpW_data==1'b0 );	              // the head points to config area

reg [STATE_NUM-1:0] state, next_state;	  
reg C_ld_Head;

// table declaration.implemented by Single Port RAM.  
`ifdef XIL_BRAM 
reg  [TAB_DW-1:0] ram [255:0] /* synthesis syn_ramstyle = "block_ram" */;    // Addr range 0-255(255 reserved) 
`else 
reg  [TAB_DW-1:0] ram [255:0] /* synthesis syn_ramstyle = "select_ram" */;  
`endif 	
wire [7:0] tab_addr = we_tab_i  ?  tab_WrAddr_i  :  Head;
wire [TAB_DW-1:0] tab_do;	 

assign            tab_d0_o = tab_do[0] && !we_tab_i;  
wire [TAB_DW-2:0] tab_sw_do;
assign  tab_sw_do =	tab_do[TAB_DW-1 : 1];	 // tab data out for swith 

// try_cnt
reg [TRY_DW-1:0] try_cnt;
reg C_incr_cnt, C_decr_cnt, C_ld_org;                     // command to increase try counter or decrease try counter 


//An EEP received by a routing switch shall be transferred through the routing switch in the same way as an EOP

///////////////////
// HEAD delete
// 
always @(posedge gclk)
if(reset)
  Head <= 1;	          // to avoid initial address 0 of table(configuration port) 
else if(C_ld_Head)
  Head <= SpW_di[7:0];

///////////////////////
// try_cnt incr or decr
//

wire reset_ld_org = reset || C_ld_org; 

always @(posedge gclk)
if(reset_ld_org)
  try_cnt <= org_line_i;
else if(C_incr_cnt)
  begin
  if(try_cnt==IF_PORTNUM)	      // to support arbitrary	ports number
    try_cnt <= 0;
  else
    try_cnt <= try_cnt + 1;
  end
else if(C_decr_cnt)
  begin
  if(try_cnt==0)				   // to support arbitrary ports number
    try_cnt <= IF_PORTNUM;	    
  else
    try_cnt <= try_cnt - 1;
  end 
  

//////////////////////
// Routing Table
//
// implemented by Single Port RAM. Should complete configuration before read 
`ifdef XIL_BRAM
 reg [7:0] Addr_reg;                     
 always @(posedge gclk)
 begin
    if(we_tab_i)
	   ram[tab_addr] <= tab_di;
	Addr_reg <= tab_addr;					        // register the addr input 
 end	  
 assign tab_do = ram[Addr_reg];  
 
 `else                                         // Use distributed RAM 
 always @(posedge gclk)
 if(we_tab_i)
   ram[tab_addr] <= tab_di;	 
 assign tab_do = ram[tab_addr];
`endif	


///////////////////////////////
// Control FSM	 
//
// The first data character following either EOP or EEP shall be taken as the first character of the next packet


// reg [HCW-1:0] seekN1;                // Seek for annother "1", the order is "seekN1"
// reg [IF_PORTNUM-1:0] C_Load_BitX; 

always @(posedge gclk)
if(reset==`reset)  
    state <= IDLE;   //Initialized state			   
else 
    state <= next_state;

//------ next_state assignment
always @(*)
begin:NEXT_ASSIGN
  //Default Values for FSM outputs:		     
	 C_ld_Head   = 1'b0;
	 rd_IBUF_o   = 1'b0;               // single wire 		
	 C_incr_cnt  = 1'b0;
	 C_decr_cnt  = 1'b0;
	 C_ld_org    = 1'b0;
	 we_cell_o   = 0;						  // array

	 

  //Use "Default next_state" style ->
    next_state = state;
      case(state) /* synthesis parallel_case */
  IDLE        :   begin  //When EOP marker seen, router terminates connection and frees output port
					 	   
							if(IBUF_HasData || emgEXP)
						   begin 						 
						   rd_IBUF_o = 1'b1;	         // read buf to refresh the data output 						
						   next_state = JUDGE_HEAD;
					      end
					   end
  JUDGE_HEAD   :  begin
    /*temp*/        rd_IBUF_o = 1'b1;	         // 2nd read, later will emerge a "data" or a "EXP" 
                    if(head_ptr2cfg || emgEXP ) // if(result of 1st read) 
						    next_state = IDLE;	      // IDLE is also a state to waite configuration command to pass by
						  else 							   
							 next_state = DEL_HEAD;							
						end
  DEL_HEAD    :   begin
	/*temp*/ 		  C_ld_Head = 1'b1;						
						  if(emgEXP)  						 // if (result of 2nd read)
                	    begin
						    rd_IBUF_o = 1'b1;	
						    next_state = JUDGE_HEAD; // taken as the first character of the next packet
                      end								// An EOP or EEP received immediately after an EOP or EEP represents an empty packet                          
                    else
						    begin
							 C_ld_org = 1;
                      next_state = TRY_ORG_COL;
							 end
						end
  TRY_ORG_COL :   begin	                     
	/*temp*/ 		  if( tab_sw_do[org_line_i] == 1 &&     // here "org_line_i"=="try_cnt"
	                     full_cell_i[org_line_i] == False  )

						    	 next_state = DISTRIBUTING; 							
                    else if( try_msb )
						       next_state = INCR_TRY_COL;
                    else 
						       next_state = DECR_TRY_COL;
						end
  INCR_TRY_COL:   begin
                    C_incr_cnt = 1'b1;
						  if(  tab_sw_do[try_cnt] == 1 &&  
						       full_cell_i[try_cnt] == False )
						     next_state = DISTRIBUTING;                
					   end
  DECR_TRY_COL :  begin
                    C_decr_cnt = 1'b1;
						  if(  tab_sw_do[try_cnt] == 1 &&  
						       full_cell_i[try_cnt] == False )
						     next_state = DISTRIBUTING;     
                  end
  DISTRIBUTING :  begin
                    rd_IBUF_o = 1'b1;
						  we_cell_o[try_cnt] = 1'b1;		// only one "we_cell_o" is active at the same time. 
						  if( emgEXP )
						    next_state = DEL_HEAD;
						  else if(empty_IBUF_i ==True)   // if not emerge a "EXP"
						    next_state = GRAB_CELL_WAIT;
                  end
  GRAB_CELL_WAIT: begin	 
                	  if(IBUF_HasData)
						  next_state = DISTRIBUTING;
					   end					 
		default:  next_state = 'bx;    // for simulation
    endcase
end  


////////////////////
// Output assignment
//
assign cfg_SMX_o = try_cnt;	 





/*
wire [TAB_DW-1:0] HotDec [0:TAB_DW-1];	       // decode output of table to one-hot  
// assignment of HotDec array
always @(*)
begin 
 integer k;
  for (k =0; k<IF_PORTNUM; k =k+1)
   HotDec[i] = Hot_Neq1(tab_do, seekN1); 
end

always @(posedge gclk)
if(reset ==`reset)
 cfg_data_o <= 0;			// cfg_data_o has 17 value: 0, 1000..., 0100..., 00100..., 000100...
else if( |Load_BitX )
   begin
   case(1'b1)  // synthesis parallel_case /
	C_Load_BitX[0]    :   cfg_data_o <= HotDec[0];
	C_Load_BitX[1]    :   cfg_data_o <= HotDec[1];
	C_Load_BitX[2]	   :   cfg_data_o <= HotDec[2];
	C_Load_BitX[3]    :   cfg_data_o <= HotDec[3];
	C_Load_BitX[4]    :   cfg_data_o <= HotDec[4];
	C_Load_BitX[5]	   :   cfg_data_o <= HotDec[5];
	C_Load_BitX[6]    :   cfg_data_o <= HotDec[6];
	C_Load_BitX[7]    :   cfg_data_o <= HotDec[7];
	C_Load_BitX[8]	   :   cfg_data_o <= HotDec[8];
	C_Load_BitX[9]    :   cfg_data_o <= HotDec[9];
	C_Load_BitX[10]   :   cfg_data_o <= HotDec[10];
	C_Load_BitX[11]	:   cfg_data_o <= HotDec[11];
	C_Load_BitX[12]	:   cfg_data_o <= HotDec[12];
	C_Load_BitX[13]   :   cfg_data_o <= HotDec[13];
	C_Load_BitX[14]   :   cfg_data_o <= HotDec[14];
	C_Load_BitX[15]	:   cfg_data_o <= HotDec[15];
	default           :   begin
	                    cfg_data_o <= 16'b0;
							  $display("Error at time=%dns  PORT WIDTH exceeded, maybe you need to modify this HDL file manually :-# ",	$time);
							  end
   end
*/

/*
///////////////////
//	 Function array
//
function [IF_PORTNUM-1:0] Hot_Neq1;
input [TAB_DW-1:0] di;
input [HCW-1:0] NEXT;
integer k;
integer n1 = 0;    //number of 1s
  for(k =0; k <TAB_DW; k =k+1)
  begin
    if(di[k] =1'b1)
	   n1 = n1 + 1;
	 if( n1 ==NEXT )
	   begin
	   hot_1st[TAB_NUM-1:k+1] =0; 
		hot_1st[k] = 1'b1;
		hot_1st[k-1:0] = 0;
		end
  end
endfunction
*/


endmodule

`undef reset 
`undef XIL_BRAM
`undef XIL_DISRAM
