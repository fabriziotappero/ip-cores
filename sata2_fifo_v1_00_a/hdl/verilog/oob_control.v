//*****************************************************************************/
// Module :     OOB_control 
// Version:     1.0
// Author:      Ashwin Mendon 
// Description: This module handles the Out-Of-Band (OOB) sinaling requirements
//               for link initialization and synchronization 
//              It has been modified from Xilinx XAPP870 to support Virtex 6 GTX
//              transceivers 
//*****************************************************************************/

module OOB_control (

 clk,	// Clock
 reset,	// reset	
 oob_control_ila_control,
 
 /**** GTX ****/
 rxreset,	// GTX PCS reset
 rx_locked,	// GTX PLL is locked
 gen2,		// Generation 2 speed
 txcominit,	// TX OOB issue  RESET/INIT
 txcomwake,	// TX OOB issue  WAKE
 cominitdet,	// RX OOB detect INIT 
 comwakedet,	// RX OOB detect WAKE 
 rxelecidle,	// RX electrical idle
 txelecidle_out,// TX electircal idel
 rxbyteisaligned,// RX byte alignment completed

 tx_dataout,	// Outgoing TX data to GTX
 tx_charisk_out,// TX byted is K character
 
 rx_datain,    // Data from GTX            
 rx_charisk_in,   // K character from GTX                        
 /**** GTX ****/

 /**** LINK LAYER ****/
 // INPUT 
 tx_datain,	// Incoming TX data from SATA Link Layer 
 tx_charisk_in, // K character indicator                          
 // OUTPUT 
 rx_dataout,   // Data to SATA Link Layer
 rx_charisk_out, 

 linkup,	// SATA link is established
 linkup_led_out, // LINKUP LED output
 align_en_out,
 CurrentState_out // Current state for Chipscope
 /**** LINK LAYER ****/ 

);

        parameter       CHIPSCOPE  = "FALSE";	
	input		clk;
	input 		reset;
        input   [35:0]  oob_control_ila_control;
	input 		rx_locked;
	input           gen2;
        // Added for GTX	
	input		cominitdet;
	input		comwakedet;
        // Added for GTX	
	input		rxelecidle;
	input		rxbyteisaligned;
	input	[31:0]  tx_datain;
	input	        tx_charisk_in;
	input	[3:0]   rx_charisk_in;   		
	input	[31:0]  rx_datain;      //changed for GTX 
      
	output		rxreset;
        // Added for GTX	
	output		txcominit;
	output		txcomwake;
        // Added for GTX	
	output 		txelecidle_out;
	output	[31:0]  tx_dataout;     //changed for GTX 
	output          tx_charisk_out;                                
                                         
	output	[31:0]  rx_dataout;
	output	[3:0]   rx_charisk_out;
	output          linkup;
	output          linkup_led_out;
	output          align_en_out;
	output	[7:0]   CurrentState_out;
	
	parameter [3:0]
	host_comreset		= 8'h00,
	wait_dev_cominit	= 8'h01,
	host_comwake 		= 8'h02, 
	wait_dev_comwake 	= 8'h03,
	wait_after_comwake 	= 8'h04,
	wait_after_comwake1 	= 8'h05,
	host_d10_2 		= 8'h06,
	host_send_align 	= 8'h07,
	link_ready 		= 8'h08,
        link_idle               = 8'h09;

        // Primitves
        parameter ALIGN      = 4'b00;
        parameter SYNC       = 4'b01;
        parameter DIAL       = 4'b10;
        //parameter R_RDY      = 4'b11;
        parameter LINK_LAYER = 4'b11;

	reg	[7:0]	CurrentState, NextState;
	reg	[17:0]	count;
	reg	[3:0]	align_char_cnt_reg;
	reg		align_char_cnt_rst, align_char_cnt_inc;
	reg		count_en;
	reg		tx_charisk, tx_charisk_next;
	reg		txelecidle, txelecidle_next;
	reg        	linkup_r, linkup_r_next;
	reg		rxreset; 
	reg	[31:0]  tx_datain_r;
	wire	[31:0]  tx_dataout_i;
	reg	[31:0]  rx_dataout_i;
	wire	[31:0]  tx_align, tx_sync, tx_dial, tx_r_rdy;
	reg     [3:0]   rx_charisk_r;
	reg		txcominit_r, txcomwake_r;
        wire    [1:0]   align_count_mux_out;
        reg     [8:0]   align_count;
        reg     [1:0]   prim_type, prim_type_next;
      
	wire		align_det, sync_det, cont_det, sof_det, eof_det, x_rdy_det, r_err_det, r_ok_det;
        reg             align_en, align_en_r;
        reg             rxelecidle_r;
        reg     [31:0]  rx_datain_r;
        reg     [3:0]   rx_charisk_in_r;
        reg             rxbyteisaligned_r;
        reg             comwakedet_r, cominitdet_r;

// OOB FSM Logic Process
				
always @ ( CurrentState or count or rxelecidle_r or rx_locked or rx_datain_r or
           cominitdet_r or comwakedet_r or 
           align_det or sync_det or cont_det or 
           tx_charisk_in )
begin : Comb_FSM
 
	count_en = 1'b0;
	NextState = host_comreset;
	linkup_r_next = linkup_r;
	txcominit_r =1'b0;
	txcomwake_r = 1'b0;
	rxreset = 1'b0;
	txelecidle_next = txelecidle;
        prim_type_next = prim_type;
        tx_charisk_next = tx_charisk;			
        rx_dataout_i  = 32'b0;
        rx_charisk_r = 4'b0;

       case (CurrentState)
		host_comreset :
			begin
			        txelecidle_next = 1'b1;
			        prim_type_next = ALIGN; 
				if (rx_locked)
					begin 
						if ((~gen2 && count == 18'h00051) || (gen2 && count == 18'h000A2))
						begin
							txcominit_r =1'b0;	
							NextState = wait_dev_cominit;
						end
						else  //Issue COMRESET  
						begin
							txcominit_r =1'b1;	
							count_en = 1'b1;
							NextState = host_comreset;						
						end
					end
				else
					begin
						txcominit_r =1'b0;	
						NextState = host_comreset;
					end													
			end						

		wait_dev_cominit : //1
			begin
				if (cominitdet_r == 1'b1) //device cominit detected				
				begin
					NextState = host_comwake;
				end
				else
				begin
					`ifdef SIM
					if(count == 18'h001ff) 
					`else
					if(count == 18'h203AD) //restart comreset after no cominit for at least 880us
					`endif
					begin
						count_en = 1'b0;
						NextState = host_comreset;
					end
					else
					begin
						count_en = 1'b1;
						NextState = wait_dev_cominit;
					end
				end
			end

		host_comwake : //2
			begin
				if ((~gen2 && count == 18'h0004E) || (gen2 && count == 18'h0009B))
				begin
					txcomwake_r =1'b0;	
					NextState = wait_dev_comwake;
				end
				else
				begin
					txcomwake_r =1'b1;	
					count_en = 1'b1;
					NextState = host_comwake;						
				end

			end

		wait_dev_comwake : //3 
			begin
				if (comwakedet_r == 1'b1) //device comwake detected				
				begin
					NextState = wait_after_comwake;
				end
				else
				begin
					if(count == 18'h203AD) //restart comreset after no cominit for 880us
					begin
						count_en = 1'b0;
						NextState = host_comreset;
					end
					else
					begin
						count_en = 1'b1;
						NextState = wait_dev_comwake;
					end
				end
			end


		wait_after_comwake : // 4
			begin
				if (count == 6'h3F)
				begin
					NextState = wait_after_comwake1;
				end
				else
				begin
					count_en = 1'b1;
					
					NextState = wait_after_comwake;
				end
			end		


		wait_after_comwake1 : //5
			begin
				if (rxelecidle_r == 1'b0)
				begin
					rxreset = 1'b1;
					NextState = host_d10_2;
				end
				else
					NextState = wait_after_comwake1; 	
			end

		host_d10_2 : //6
		begin
			txelecidle_next = 1'b0;

                        // D10.2-D10.2 "dial tone"
			rx_dataout_i  = rx_datain_r;
			prim_type_next = DIAL; 
			tx_charisk_next = 1'b0;			

			if (align_det)
			begin
				NextState = host_send_align;
			end
			else
			begin
				if(count == 18'h203AD) // restart comreset after 880us
				begin
					count_en = 1'b0;
					NextState = host_comreset;						
				end
				else
				begin
					count_en = 1'b1;
					NextState = host_d10_2;
				end
			end				
		end	
				
		host_send_align : //7
		begin
                        rx_dataout_i  = rx_datain_r;
                        
                	// Send Align primitives. Align is 
			// K28.5, D10.2, D10.2, D27.3
                        prim_type_next = ALIGN;
			tx_charisk_next = 1'b1;			
			
			if (sync_det) // SYNC detected
			begin
				linkup_r_next = 1'b1;
				NextState = link_ready;
			end
			else
				NextState = host_send_align;
		end
			
			
		link_ready : // 8
		begin
			if (rxelecidle_r == 1'b1)
			begin
				NextState = link_ready;
				linkup_r_next = 1'b0;
			end
			else
			begin
				NextState = link_ready;
				linkup_r_next = 1'b1;
				rx_charisk_r = rx_charisk_in_r;
				rx_dataout_i = rx_datain_r;
                                // Send LINK_LAYER DATA
                                prim_type_next = LINK_LAYER;
                                if (align_en)
			           tx_charisk_next = 1'b1;
                                else
			           tx_charisk_next = tx_charisk_in;
			end
		end
            
	        
		default : NextState = host_comreset;	
	endcase
end	


// OOB FSM Synchronous Process

always@(posedge clk or posedge reset)
begin : Seq_FSM 
	if (reset)
        begin
		CurrentState       <= host_comreset;
                prim_type          <= ALIGN;
                tx_charisk         <= 1'b0;
                txelecidle         <= 1'b1;
                linkup_r           <= 1'b0;
                align_en_r         <= 1'b0;
                rxelecidle_r       <= 1'b0;
                rx_datain_r        <= 32'b0;
                rx_charisk_in_r    <= 4'b0;
                rxbyteisaligned_r  <= 1'b0; 
                cominitdet_r       <= 1'b0;
                comwakedet_r       <= 1'b0;
	end
	else
        begin
		CurrentState      <= NextState;
                prim_type         <= prim_type_next;
                tx_charisk        <= tx_charisk_next;
                txelecidle        <= txelecidle_next;
	        linkup_r          <= linkup_r_next;
                align_en_r        <= align_en;
                rxelecidle_r      <= rxelecidle;
                rx_datain_r       <= rx_datain;
                rx_charisk_in_r   <= rx_charisk_in; 
                rxbyteisaligned_r <= rxbyteisaligned; 
                cominitdet_r      <= cominitdet;
                comwakedet_r      <= comwakedet;
        end
end


always@(posedge clk or posedge reset)
begin : freecount
	if (reset)
	begin
		count <= 18'b0;
	end	
	else if (count_en)
	begin  
		count <= count + 1;
	end
     	else
     	begin
		count <= 18'b0;

	end
end



assign txcominit = txcominit_r;
assign txcomwake = txcomwake_r;
assign txelecidle_out = txelecidle;
//Primitive detection
// Changed for 32-bit GTX
assign align_det = (rx_datain_r == 32'h7B4A4ABC) && (rxbyteisaligned_r == 1'b1); //prevent invalid align at wrong speed
assign sync_det  = (rx_datain_r == 32'hB5B5957C);
assign cont_det  = (rx_datain_r == 32'h9999AA7C);
assign sof_det   = (rx_datain_r == 32'h3737B57C);
assign eof_det   = (rx_datain_r == 32'hD5D5B57C);
assign x_rdy_det = (rx_datain_r == 32'h5757B57C);
assign r_err_det = (rx_datain_r == 32'h5656B57C);
assign r_ok_det  = (rx_datain_r == 32'h3535B57C);

assign linkup = linkup_r;
assign linkup_led_out = ((CurrentState == link_ready) && (rxelecidle_r == 1'b0)) ? 1'b1 : 1'b0;
assign CurrentState_out = CurrentState;
assign rx_charisk_out = rx_charisk_r;
assign tx_charisk_out = tx_charisk;
assign rx_dataout  = rx_dataout_i;

// SATA Primitives 

// ALIGN
assign tx_align  = 32'h7B4A4ABC;

// SYNC
assign tx_sync   = 32'hB5B5957C;

// Dial Tone
assign tx_dial   = 32'h4A4A4A4A;

// R_RDY
assign tx_r_rdy  = 32'h4A4A957C;

// Mux to switch between ALIGN and other primitives/data
mux_21 i_align_count
  (
   .a   (prim_type),
   .b   (ALIGN),
   .sel (align_en_r),
   .o   (align_count_mux_out)
  );
 // Output to Link Layer to Pause writing data frame
 assign align_en_out = align_en;

//ALIGN Primitives transmitted every 256 DWORDS for speed alignment
always@(posedge clk or posedge reset)
begin : align_cnt
	if (reset)
        begin
           align_count <= 9'b0;
        end 
	else if (align_count < 9'h0FF) //255
        begin       
           if (align_count == 9'h001) //de-assert after 2 ALIGN primitives
           begin
                align_en <= 1'b0;
           end  
           align_count <= align_count + 1;
        end
     	else
        begin     
           align_count <= 9'b0;
           align_en <= 1'b1;
        end
end


//OUTPUT MUX
mux_41 i_tx_out
  (
    .a    (tx_align),
    .b    (tx_sync),
    .c    (tx_dial),
    //.d    (tx_r_rdy),
    .d    (tx_datain),
    .sel  (align_count_mux_out),
    .o    (tx_dataout_i)
  );

assign tx_dataout = tx_dataout_i;


// OOB ILA
wire [15:0] trig0;
wire [15:0] trig1;
wire [15:0] trig2;
wire [15:0] trig3;
wire [31:0] trig4;
wire [3:0]  trig5;
wire [31:0] trig6;
wire [31:0] trig7;
wire [35:0] control;

if (CHIPSCOPE == "TRUE") begin
 oob_control_ila  i_oob_control_ila  
    (
      .control(oob_control_ila_control),
      .clk(clk),
      .trig0(trig0),
      .trig1(trig1),
      .trig2(trig2),
      .trig3(trig3),
      .trig4(trig4),
      .trig5(trig5),
      .trig6(trig6),
      .trig7(trig7)
    );
end

assign trig0[0] = txcomwake_r;
assign trig0[1] = tx_charisk;
assign trig0[2] = rxbyteisaligned_r;
assign trig0[3] = count_en;
assign trig0[4] = tx_charisk_in;
assign trig0[5] = txelecidle;
assign trig0[6] = rx_locked;
assign trig0[7] = gen2;
assign trig0[11:8] = rx_charisk_in_r;
assign trig0[15:12] = 4'b0;
assign trig1[15:12] =  prim_type;
assign trig1[11:10] = 2'b0;
assign trig1[9] = align_en_r;
assign trig1[8]  = rxelecidle_r;
assign trig1[7:0] = CurrentState_out;
assign trig2[15:7] = align_count;
assign trig2[6:5] = 2'b0;
assign trig2[4] = cominitdet_r;
assign trig2[3] = comwakedet_r;
assign trig2[2] = align_det;
assign trig2[1] = sync_det;
assign trig2[0] = cont_det;
assign trig3[0] = sof_det;
assign trig3[1] = eof_det;
assign trig3[2] = x_rdy_det;
assign trig3[3] = r_err_det;
assign trig3[4] = r_ok_det;
assign trig3[15:5] =  11'b0;
assign trig4 =  rx_datain_r;
assign trig5[0] = txcominit_r;
assign trig5[1] = linkup_r;
assign trig5[2] = align_en;
assign trig5[3] = 1'b0;
assign trig6 =  tx_datain;
assign trig7  = tx_dataout_i;

endmodule

module oob_control_ila 
  (
    control,
    clk,
    trig0,
    trig1,
    trig2,
    trig3,
    trig4,
    trig5,
    trig6,
    trig7
  );
  input [35:0] control;
  input clk;
  input [15:0] trig0;
  input [15:0] trig1;
  input [15:0] trig2;
  input [15:0] trig3;
  input [31:0] trig4;
  input [3:0]  trig5;
  input [31:0] trig6;
  input [31:0] trig7;
  
endmodule
