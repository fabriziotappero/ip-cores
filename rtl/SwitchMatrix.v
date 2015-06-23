//File name=Module=SwitchMatrix  2005-04-10      btltz@mail.china.com    btltz from CASIC  
//Description:     buffered digital SwitchMatrix  to simplify design, avoid HOL.
//                 * 16 x 16 switch connecting sixteen 9-bit FIFO I/O ports to 
//                      sixteen 10-bit output ports with  16 x 16 (x depth) = 256 syn buffers. buffered each point
//Abbreviations: 	 crd  --- credit
//						 alw  --- allow
//Origin:  SpaceWire Std - Draft-1(Clause 8)of ECSS(European Cooperation for Space Standardization),ESTEC,ESA.
//         SpaceWire Router Requirements Specification Issue 1 Rev 5. Astrium & University of Dundee 
//TODO:	  make rtl faster
////////////////////////////////////////////////////////////////////////////////////
//
/*synthesis translate_off*/
`include "timescale.v"
/*synthesis translate_on */
`define reset  1	        // WISHBONE standard reset
`define TOOL_NOTSUP_PORT_ARRAY //if the tool's support port array declaration  
										 
module SwitchMatrix #(parameter BW=10, PORTNUM=16, AW=4,  // (1byte + 1)Byte-WIDTH 16x16 crossbar swith
                                CellDepth =255,           // 16x16 beffers x (255Byte x 10-bit / Cell) 
										  WCCNT = (CellDepth ==255 ? 8 :
										           (CellDepth ==511 ? 9  :
													   (CellDepth == 1023 ? 10 : 'bx  )) ),
										  WIDTH_CRD = (CellDepth ==255 && PORTNUM ==16) ? 12 :  //255depth x16ports = 4080 Bbytes/column
						    							   (CellDepth ==511 && PORTNUM ==16 ? 13 : //511depth x 16ports = 8176	Bbytes/column
															 (CellDepth == 1023 && PORTNUM == 16 ? 14 :
                                            (CellDepth ==255 && PORTNUM ==8 ? 11 :
														   (CellDepth ==511 && PORTNUM ==8 ? 12 :
															 (CellDepth ==1023 && PORTNUM ==8 ? 13 :'bx )))))
							 ) 						
		( // Byte width data input(output) from(to) FIFO
		                  `ifdef TOOL_NOTSUP_PORT_ARRAY 
								 output [BW-1:0] do0,do1,do2,do3,do4,do5,do6,do7,
								                 do8,do9,do10,do11,d12,do13,do14,do15,
                         input  [BW-1:0] di0,di1,di2,di3,di4,di5,di6,di7,
								                 di8,di9,di10,di11,di12,di13,di14,di15,
                         `else
							    output reg [BW-1:0] do [0:PORTNUM-1],
							    input  [BW-1:0] di [0:PORTNUM-1],								 
								`endif
								 
								 output [PORTNUM-1:0] PHasData_o,   //a output port has data to transmit
		 // Configuration Port
		                  //output [WIDTH_CRD-1:0] crd_o [0:PORTNUM-1], // credit output back to each in line
		                   output reg [PORTNUM-1:0] sop_ack_o,       //level
								 input [PORTNUM-1:0] sop_req_i,       //pulse 								
								 input [PORTNUM-1:0]	eop_i,		     //pulse
								`ifdef TOOL_NOTSUP_PORT_ARRAY 
								 input cfg_data0_i,  cfg_data1_i,  cfg_data2_i,  cfg_data3_i,
										 cfg_data4_i,  cfg_data5_i,  cfg_data6_i,  cfg_data7_i,
										 cfg_data8_i,  cfg_data9_i,  cfg_data10_i, cfg_data11_i,
										 cfg_data12_i, cfg_data13_i, cfg_data14_i, cfg_data15_i,
                        `else
								 input [PORTNUM-1:0] cfg_data_i [0:PORTNUM-1],
                        `endif

								`ifdef TOOL_NOTSUP_PORT_ARRAY	 	
								 input [AW-1:0] out_addr0_i,out_addr1_i,out_addr2_i,out_addr3_i,
								                out_addr4_i,out_addr5_i,out_addr6_i,out_addr7_i,
													 out_addr8_i,out_addr9_i,out_addr10_i,out_addr11_i,
													 out_addr12_i,out_addr13_i,out_addr14_i,out_addr15_i,
								`else					 	   				
								 input [AW-1:0] out_addr_i [0:PORTNUM],	//select output column								 
								`endif
							    //input [PORTNUM-1:0] ld_inaddr_i, ld_outaddr_i,
       // System interface
								 input reset, gclk
							  );	
							      parameter True  = 1;
							      parameter False = 0;

`ifdef TOOL_NOTSUP_PORT_ARRAY
reg [BW-1:0] do [0:PORTNUM-1];
wire [BW-1:0] di [0:PORTNUM-1];	 
assign di0 = di[0],   di1 = di[1],   di2 = di[2],   di3 = di[3], 
       di4 = di[4],   di5 = di[5],   di6 = di[6],   di7 = di[7],
		 di8 = di[9],   di9 = di[9],   di10 = di[10], di11 = di[11],
		 di12 = di[12], di13 = di[13], di14 = di[14], di15 = di[15];
assign do0 = do[0],   do1 = do[1],   do2 = do[2],   do3 = do[3], 
       do4 = do[4],   do5 = do[5],   do6 = do[6],   do7 = do[7],
		 do8 = do[9],   do9 = do[9],   do10 = do[10], do11 = do[11],
		 do12 = do[12], do13 = do[13], do14 = do[14], do15 = do[15];
`endif

// Register to provide address when write(read) line(column).
// Each output port = 1 column
reg [AW-1:0] SelColumn [0:PORTNUM-1];       // for line cells selection//bit width ,depth
reg [AW-1:0] SelColine [0:PORTNUM-1];	     // for MUXes	 select lines in a column 
wire [PORTNUM-1:0] ld_SelColumn = sop_req_i;            
wire [PORTNUM-1:0] ld_SelColine;             // load select lines in a column

wire [AW-1:0] ScheOut;  //output from the schedule.Determine which line in a column has priority 

							  //opposite line| each column
wire [BW-1:0] CellOut    [0:PORTNUM]    [0:PORTNUM];	 //16x16 *9 from cell fifo to MUXes	                      
wire [WCCNT-1:0] CellCnt [0:PORTNUM]    [0:PORTNUM];  //data num(vectors) in each switch cell     
// Cell Control Lines
reg [PORTNUM-1:0] wr_en  [0:PORTNUM-1];
reg [PORTNUM-1:0] rd_en  [0:PORTNUM-1];
wire [PORTNUM-1:0] clrCell[0:PORTNUM-1]; 
wire [PORTNUM-1:0] CellEmpty [0:PORTNUM-1];
wire [PORTNUM-1:0] CellFull  [0:PORTNUM-1];	
wire [PORTNUM-1:0] CellAfull  [0:PORTNUM-1];                    // buffer cell almost full 
wire [PORTNUM-1:0] CellAempty  [0:PORTNUM-1];						  // buffer cell almost empty

wire [PORTNUM-1:0] CellHasData [0:PORTNUM-1] = ~CellEmpty;      //? is the syntax right ?	
wire [PORTNUM-1:0] CellHasSpc  [0:PORTNUM-1] = ~CellFull;  


// signal for Matrix Output management
reg [PORTNUM-1:0] columnHasData;
wire [PORTNUM-1:0] ColumnOE = columnHasData;
assign PHasData_o           = columnHasData; //Port Has Data.Synchronous output to write Tx FIFO
  
// reg [WIDTH_CRD-1:0] crdcnt [0:PORTNUM-1];//credit counter
// assign crd_o = crdcnt;

/////////////////////////////////////
// Config input/output address REGs
//  
always @(posedge gclk)
begin
integer i=0;
if(reset)
     begin
     SelColumn <= 0;
     SelLine <= 0;
     end
else begin
     for (i=0; i<PORTNUM; i=i+1 )
       begin 
		 if( ld_SelColumn[i] == True )	    // ld_SelColumn = sop_req_i; Note taht the addr must be valid.
	      SelColumn[i] <= out_addr_i[i];	 //   Address Vector load
	    if( ld_SelColine[i] == True )	    // if the scheduler load output address.
	      SelColine[i] <= ScheOut [i];	    //   Address Vector load
	    end
     end
end

///////////////////////
// Matrix Cell buffers
//
// note: should select devices that have true dual port RAM	  

generate
begin:GEN_Cell
genvar i,k;
for (i=0; i<PORTNUM; i=i+1)       // i : each column
begin
   for (k=0; k<PORTNUM; k=k+1)	 // k : in a column(sel line)
	begin
	eth_fifo  #(parameter DATA_WIDTH=BW, DEPTH=CellDepth)	  // byte width=9, depth=? undetermined
	         Cell_Fifo_Array
	         (.data_in ( di[k] ),	       // different colum has same data input line
				 .data_out( CellOut[i][k] ),// k assign to 1 column,i assign to n columns.L<-R			 
				 .write   ( wr_en[i][k] ), 
				 .read    ( rd_en[i][k] ),
				 .clear   ( clrCell[i][k] ), 
				 .almost_full ( CellAfull[i][k] ), 
				 .full        ( CellFull[i][k] ), 
				 .almost_empty( CellAempty[i][k] ), 
				 .empty       ( CellEmpty[i][k] ), 
				 .gclk  ( gclk ), 
				 .reset( reset ),
				 .cnt( CellCnt[i][k] )      //may be usable
				 );
    end  //end 1 column (16x1 )
end	   //end 1 array  (16x16) 
end      //end GEN_Cell 



/////////////////////////////////////////
// Distribute lines data 
//     to the Matrix Cell	
reg [PORTNUM-1:0] wpen ;     // Write Packages Enable

//register sop_req_i or eop_i pulse
always @(posedge gclk)
begin
integer k;
if(reset==`reset)
  wpen <= 0;
else begin
     for(k=0; k<PORTNUM; k=k+1)
   	  begin
	      if(eop_i[k])
	  	     wpen[k] <= 1'b0;
         else if(sop_req_i[k])
		     wpen[k] <= 1'b1;
        end
	   end
end

reg [PORTNUM-1:0] wr__;		  // level signal

always @(*)
begin
 for (k =0; k <PORTNUM; k =k+1)
  wr__[k] =  ( wpen[k] ==False || eop_i[k])  ?   0   :
             ( ( wpen[k] ==True && eop_i[k] ==False )  ?   1'b1 : 'bx	    );       
end 			

//decode config addr according to the external controller
//(and the package addr head). Generate cell "we" signals array.
always @(*)
begin
integer i,k;
  for (i=0; i<PORTNUM; i=i+1)       // i : each column
  begin
    for (k=0; k<PORTNUM; k=k+1)	   // k : lines in a column(sel line)
	 begin
      wr_en[i][k] = ( wr__[i]                     // write to x column 
		                &&  SelColine[i] ==k    	  // select a line in a column
							 &&  CellHasSpc[i][k] ==True // that cell is not full
						   )					        
							   ?   1'b1  :  1'b0;
     sop_ack_o[i] = (SelColine[i] ==k    	        // "select a line" must has been configed
							 &&  CellHasSpc[i][k] ==True // that cell is not full
							)
							   ?   1'b1  :  1'b0;         
	 end
  end
end 


/////////////////////////
// Read enable to Tx Fifo
//
////////////////////
// Credit collecting credit information to The Input Line
// Output Schedulers	are responsible for selecting eligible 

always @ (*)
begin
integer m;
  for(m=0; m<PORTNUM; m=m+1)
  	columnHasData[m] = | celHasData[m];           
	// cellHasData[m][0] || cellHasData[m][1] || ...|| cellHasData[m][15] 	  					
end


//////////////////////////////
// 16 outputs Column Schedulers 
//
//////////////////////////////
// 1 scheduler is responsible to 32 cell in a column

generate
begin:GEN_CSers
genvar i, k;
 for (i=0; i<PORTNUM; i=i+1)       // i : each column
 begin:inst_column
   for (k=0; k<PORTNUM; k=k+1)	  // k : in a column(sel line)
	begin:inst_line
     CSer    inst_CSer
	             ( .ld_SelCoLine_o( ld_SelColine ),
					   .empty_i(CellEmpty[i][k] ),      // one-hot input
						.Aempty_i(CellAfull[i][k]),		// one-hot
					   .addr_o( ScheOut[i] ),						
						.reset(reset)
						.gclk(gclk)						 
					  );
   end  // end lines in a column
 end    // end columns
end
endgenerate

////////////////////////////
//	16 outputs
// 
always @(*)
begin
integer n;
 for (n=0; n<PORTNUM; n=n+1) 
    begin
	 if(columOE)
	 do[n] = CellOut[SelLine][n];	  // n : (port0 -> port15)
	 else 
	 do[n] = 'b0;                   //       10'b p0_0000_0000  
    end									  // EOP = 10'b p1_0000_0000
end


/*///////////////
// Functions
//
function [15:0] greyiDEC4_16;  //Grey code input decoder
input [3:0] in;
begin
case (in)
	4'b0000 : greyiDEC4_16 = 16'h1;
	4'b0001 : greyiDEC4_16 = 16'h2;
	4'b0011 : greyiDEC4_16 = 16'h4;
	4'b0010 : greyiDEC4_16 = 16'h8;
	4'b0110 : greyiDEC4_16 = 16'h10;
	4'b0111 : greyiDEC4_16 = 16'h20;
	4'b0101 : greyiDEC4_16 = 16'h40;
	4'b0100 : greyiDEC4_16 = 16'h80;
	4'b1100 : greyiDEC4_16 = 16'h100;
	4'b1101 : greyiDEC4_16 = 16'h200;
	4'b1111 : greyiDEC4_16 = 16'h400;
	4'b1110 : greyiDEC4_16 = 16'h800;
	4'b1010 : greyiDEC4_16 = 16'h1000;
	4'b1011 : greyiDEC4_16 = 16'h2000;
	4'b1001 : greyiDEC4_16 = 16'h4000;
	4'b1000 : greyiDEC4_16 = 16'h8000;
	default : greyiDEC4_16 = 'bx;	
endcase
end
endfunction	*/

endmodule

`undef reset
`undef TOOL_NOTSUP_PORT_ARRAY
