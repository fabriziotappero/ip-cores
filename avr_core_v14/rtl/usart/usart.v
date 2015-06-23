//****************************************************************************************
//
// Version 0.95!
// Modified 29.09.12
// Written by Ruslan Lepetenok(lepetenokr@yahoo.com)
// 
// To do:
// MPCM  (Implemented but not tested)
// CLK2X (Implemented but not tested) 
// Fractional baud generation (Not implemented)
//
// Stop bit if parity is enabled problem bug is found
// chsize width ([3:0] instead of [2:0]) was found and fixed
// TXIF should be cleared when the transmitter is disabled (fixed)
// disable_receiver generation logic bug fixed 18.09.12 
// External address decoder support + hardware flow control + internal loopback added 22.09.12
// cts_int / hw_flow_ctrl_en bug was fixed 23.09.12
// Width of ramadr was reduced from 8 to 3 bits
// Support for HW flow control was added but not tested 26.09.12
// To do: ctsn -> rtsn in loopback mode !!!! => Done
//****************************************************************************************


module usart #(
     	      parameter  SYNC_RST	   = 0,
     	      parameter  RXB_TXB_ADR	   = 0,
     	      parameter  STATUS_ADR	   = 1,
     	      parameter  CTRLA_ADR	   = 2,
     	      parameter  CTRLB_ADR	   = 3,
     	      parameter  CTRLC_ADR	   = 4,
     	      parameter  BAUDCTRLA_ADR     = 5,
     	      parameter  BAUDCTRLB_ADR     = 6,      
     	      parameter  RXB_TXB_DM_LOC    = 0, // Must be 0 or 1 only
     	      parameter  STATUS_DM_LOC     = 0, // Must be 0 or 1 only
     	      parameter  CTRLA_DM_LOC	   = 0, // Must be 0 or 1 only
     	      parameter  CTRLB_DM_LOC	   = 0, // Must be 0 or 1 only
     	      parameter  CTRLC_DM_LOC	   = 0, // Must be 0 or 1 only
     	      parameter  BAUDCTRLA_DM_LOC  = 0, // Must be 0 or 1 only
     	      parameter  BAUDCTRLB_DM_LOC  = 0, // Must be 0 or 1 only	    
     	      parameter  RX_FIFO_DEPTH     = 4,
     	      parameter  TX_FIFO_DEPTH     = 4,
	      parameter  MEGA_COMPAT_MODE  = 1,  // TBD
	      parameter  COMPAT_MODE       = 0,
              parameter  IMPL_DFT          = 0	        
              )
            (
             // Clock and Reset
             input wire       ireset,
             input wire       cp2,
             // I/O 
             input wire [5:0] adr,
             input wire [7:0] dbus_in,
             output wire[7:0] dbus_out,
	     input wire	      iore,
	     input wire	      iowe,
	     output wire      io_out_en,
	     // DM
	     input wire [2:0] ramadr,
	     input wire [7:0] dm_dbus_in,
	     output wire[7:0] dm_dbus_out,
	     input wire	      ramre,
	     input wire	      ramwe,
	     input wire	      dm_sel,
	     output wire      cpuwait,
	     output wire      dm_out_en,
             // XMEGA interrupt controller support  
	     output wire[1:0] rxcintlvl,
             output wire[1:0] txcintlvl,
             output wire[1:0] dreintlvl,

	     input wire	      rxd, 
	     output wire      rx_en, 
	     output wire      txd, 
	     output wire      tx_en, 
	     output wire      txcirq, 
	     input wire	      txc_irqack, 
	     output wire      udreirq, 
	     output wire      rxcirq,
	     // Hardware flow control
	     output wire      rtsn,
	     input wire       ctsn,
	     // Test related
	     input wire       test_se,
	     input wire       test_si1,
	     input wire       test_si2,
	     
	     output wire      test_so1,
	     output wire      test_so2
	     );

//****************************************************************************************

// External address decoder 
localparam LP_EXT_ADDR_DCD = (STATUS_ADR +	
                 	       CTRLA_ADR +	
                 	       CTRLB_ADR +	
                 	       CTRLC_ADR +	
                 	       BAUDCTRLA_ADR +	
                 	       BAUDCTRLB_ADR +	
                 	       RXB_TXB_DM_LOC +	
                 	       STATUS_DM_LOC +	
                 	       CTRLA_DM_LOC +	
                 	       CTRLB_DM_LOC +	
                 	       CTRLC_DM_LOC +	
                 	       BAUDCTRLA_DM_LOC +  
                 	       BAUDCTRLB_DM_LOC) ? 0 : 1;        


function fn_param_is_one;
input integer arg;
 begin
  fn_param_is_one = (arg) ? 1'b1 : 1'b0;
 end
endfunction // fn_param_is_one


  // Possible character sizes
  localparam LP_CHSIZE_5BIT = 3'b000,
             LP_CHSIZE_6BIT = 3'b001,
             LP_CHSIZE_7BIT = 3'b010,
             LP_CHSIZE_8BIT = 3'b011,
             LP_CHSIZE_RSV1 = 3'b100,
             LP_CHSIZE_RSV2 = 3'b101,
             LP_CHSIZE_RSV3 = 3'b110,
             LP_CHSIZE_9BIT = 3'b111;

wire rxd_fe_det; // Fallinge edge on RXC
wire rx_clk_en;

wire rc_start_detected; //????????????

wire[7:0] rxb_dout;  
wire[7:0] status_dout;   
wire[7:0] ctrla_dout;    
wire[7:0] ctrlb_dout;    
wire[7:0] ctrlc_dout;    
wire[7:0] baudctrla_dout;
wire[7:0] baudctrlb_dout;

wire[7:0] rxb_din;  
wire[7:0] status_din;   
wire[7:0] ctrla_din;    
wire[7:0] ctrlb_din;    
wire[7:0] ctrlc_din;    
wire[7:0] baudctrla_din;
wire[7:0] baudctrlb_din;

wire rxb_txb_sel;  
wire status_sel;   
wire ctrla_sel;    
wire ctrlb_sel;    
wire ctrlc_sel;    
wire baudctrla_sel;
wire baudctrlb_sel;

wire rxb_txb_we;  
wire status_we;   
wire ctrla_we;    
wire ctrlb_we;    
wire ctrlc_we;    
wire baudctrla_we;
wire baudctrlb_we;

wire rxd_filt;

localparam LP_WBE_WIDTH = 1;


// USART receiver SM
localparam LP_RC_SM_ST_IDLE   = 4'h0,
           LP_RC_SM_ST_START  = 4'h1,  // Start (ST)
           LP_RC_SM_ST_B0     = 4'h2,  // Bit 0 
           LP_RC_SM_ST_B1     = 4'h3,  // Bit 1
           LP_RC_SM_ST_B2     = 4'h4,  // Bit 2
           LP_RC_SM_ST_B3     = 4'h5,  // Bit 3
           LP_RC_SM_ST_B4     = 4'h6,  // Bit 4
           LP_RC_SM_ST_B5     = 4'h7,  // Bit 5				   
           LP_RC_SM_ST_B6     = 4'h8,  // Bit [6]
           LP_RC_SM_ST_B7     = 4'hA,  // Bit [7]
           LP_RC_SM_ST_B8     = 4'hB,  // Bit [8]
           LP_RC_SM_ST_P      = 4'hC,  // Bit [P]
           LP_RC_SM_ST_SP     = 4'hD;  // Stop 1  				   
	   
reg[3:0] rc_sm_st_current;
reg[3:0] rc_sm_st_next;	   

reg[3:0] rx_step_cnt_current;
reg[3:0] rx_step_cnt_next;	   
wire     rx_step;

wire     disable_receiver;

wire chsize_5b;
wire chsize_6b;
wire chsize_7b;
wire chsize_8b;
wire chsize_9b;
wire parity_en;
wire parity_odd;
wire parity_even; 
wire parity_reserved; 

wire rx_sh_en;

localparam LP_SHIFTER_LEN = 9+1+1; //  

wire[LP_SHIFTER_LEN-1:0] rx_shifter_out;
reg[LP_SHIFTER_LEN-1:0]  rx_shifter_out_muxed;
wire                     rx_shifter_parity_out; // Received parity bit   

reg rx_fifo_wr_pending_st_next;
reg rx_fifo_wr_pending_st_current;
wire rx_fifo_wr;

wire tx_clk_en;

wire rx_calculated_parity;

wire rx_fifo_re;       // Read enable for RX FIFO
wire rxb_txb_re;       // Read from data register
wire[LP_SHIFTER_LEN-1:0] rx_fifo_out; // RX FIFO data output

wire rx_fifo_empty; // TBD
wire rx_fifo_full;  
wire rx_fifo_almost_full;

reg  rx_buf_ovf_current; // RX buffer overflow
reg  rx_buf_ovf_next;

localparam LP_16X_SAMPLING_POINT = 4'h8; // 4'h7;
localparam LP_8X_SAMPLING_POINT  = 4'h5; // TBD ???

// TBD
reg rtsn_current;
reg rtsn_next;

// Multiprocessor communication mode 
// address flag (frame type)
wire mpcm_adr_fl; 

// Loopback support
wire rxd_muxed; 
wire ctsn_muxed; 

//###########################################################################################################
localparam LP_TR_SM_ST_IDLE         = 4'h0,
           LP_TR_SM_ST_START        = 4'h1,  // Start (ST)
           LP_TR_SM_ST_B0           = 4'h2,  // Bit 0 
           LP_TR_SM_ST_B1           = 4'h3,  // Bit 1
           LP_TR_SM_ST_B2           = 4'h4,  // Bit 2
           LP_TR_SM_ST_B3           = 4'h5,  // Bit 3
           LP_TR_SM_ST_B4           = 4'h6,  // Bit 4
           LP_TR_SM_ST_B5           = 4'h7,  // Bit 5				 
           LP_TR_SM_ST_B6           = 4'h8,  // Bit [6]
           LP_TR_SM_ST_B7           = 4'hA,  // Bit [7]
           LP_TR_SM_ST_B8           = 4'hB,  // Bit [8]
           LP_TR_SM_ST_P            = 4'hC,  // Bit [P]
           LP_TR_SM_ST_SP1          = 4'hD,  // Stop 1  				 
           LP_TR_SM_ST_SP2          = 4'hE,  // Stop 2	
	   LP_TR_SM_ST_WAIT_FOR_CTS = 4'hF;  // Wait for CTS (HW flow control support)

localparam LP_TX_SHIFTER_WIDTH = 10; 

reg[3:0] tr_sm_st_current;
reg[3:0] tr_sm_st_next;	   

// TBD
wire cts_int; // Clear to send

wire tx_fifo_wr;
wire tx_fifo_re;
wire[LP_TX_SHIFTER_WIDTH-1:0] tx_fifo_out; // ????
wire tx_fifo_full;
wire tx_fifo_empty;
wire tx_calculated_parity;

// TX step related logic
wire     tx_step; 
reg[3:0] tx_step_cnt_current;
reg[3:0] tx_step_cnt_next;	   

wire tx_shift_en;
wire tx_shift_load;
reg[9:0] tx_shift_in_muxed; // Prepared data for shifter and TX FIFO
wire[9:0] tx_shift_data_i;   // Input of the TX shifter 

wire[LP_TX_SHIFTER_WIDTH-1:0] tx_data_for_tr; // Data for transmission
wire[LP_TX_SHIFTER_WIDTH-1:0] tx_data_for_parity_calc; // Data for parity caclculation

reg txcif_current;
reg txcif_next;

wire clr_tx_cnt;

reg[8:0] tx_parity_calc_i; // Input of the parity calculator for transmission 

reg tx_en_current;
reg tx_en_next;

wire enable_transmitter;
wire disable_transmitter;
wire disable_transmitter_pulse;

wire ctsn_clk;

wire tx_opt_parity_bit; // Data bit 10 for transmission (replaces parity bit)

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

// Alias replacement

// CTRLB register
wire rxen  = ctrlb_dout[4];
wire txen  = ctrlb_dout[3];
wire clk2x = ctrlb_dout[2];
wire mpcm  = ctrlb_dout[1];
wire txb8  = ctrlb_dout[0]; // TXB8 

wire sbmode = ctrlc_dout[3]; // Two stop bits
wire[1:0] pmode = ctrlc_dout[5:4]; 

wire[2:0] chsize = ctrlc_dout[2:0]; // wire[3:0] chsize = ctrlc_dout[3:0]; => 26.08.12

// Loopback support
wire loopback_en     = ctrlb_dout[5]; // !!!TBD!!!
wire hw_flow_ctrl_en = ctrlb_dout[6]; // !!!TBD!!!

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`

assign rxb_din       = (RXB_TXB_DM_LOC  ) ? dm_dbus_in : dbus_in;  
assign status_din    = (STATUS_DM_LOC	) ? dm_dbus_in : dbus_in;   
assign ctrla_din     = (CTRLA_DM_LOC	) ? dm_dbus_in : dbus_in;    
assign ctrlb_din     = (CTRLB_DM_LOC	) ? dm_dbus_in : dbus_in;    
assign ctrlc_din     = (CTRLC_DM_LOC	) ? dm_dbus_in : dbus_in;    
assign baudctrla_din = (BAUDCTRLA_DM_LOC) ? dm_dbus_in : dbus_in;
assign baudctrlb_din = (BAUDCTRLB_DM_LOC) ? dm_dbus_in : dbus_in;

assign dbus_out    =  (rxb_dout       &   {8{rxb_txb_sel  }} & {8{~(fn_param_is_one(RXB_TXB_DM_LOC  ))}}) |
                      (status_dout    &   {8{status_sel   }} & {8{~(fn_param_is_one(STATUS_DM_LOC   ))}}) |
                      (ctrla_dout     &   {8{ctrla_sel    }} & {8{~(fn_param_is_one(CTRLA_DM_LOC    ))}}) |
                      (ctrlb_dout     &   {8{ctrlb_sel    }} & {8{~(fn_param_is_one(CTRLB_DM_LOC    ))}}) |
                      (ctrlc_dout     &   {8{ctrlc_sel    }} & {8{~(fn_param_is_one(CTRLC_DM_LOC    ))}}) |
                      (baudctrla_dout &   {8{baudctrla_sel}} & {8{~(fn_param_is_one(BAUDCTRLA_DM_LOC))}}) |
                      (baudctrlb_dout &   {8{baudctrlb_sel}} & {8{~(fn_param_is_one(BAUDCTRLB_DM_LOC))}}); 

assign dm_dbus_out =  (rxb_dout       &   {8{rxb_txb_sel  }} & {8{(fn_param_is_one(RXB_TXB_DM_LOC  ))}}) |
		      (status_dout    &   {8{status_sel   }} & {8{(fn_param_is_one(STATUS_DM_LOC   ))}}) |
		      (ctrla_dout     &   {8{ctrla_sel    }} & {8{(fn_param_is_one(CTRLA_DM_LOC    ))}}) |
		      (ctrlb_dout     &   {8{ctrlb_sel    }} & {8{(fn_param_is_one(CTRLB_DM_LOC    ))}}) |
		      (ctrlc_dout     &   {8{ctrlc_sel    }} & {8{(fn_param_is_one(CTRLC_DM_LOC    ))}}) |
		      (baudctrla_dout &   {8{baudctrla_sel}} & {8{(fn_param_is_one(BAUDCTRLA_DM_LOC))}}) |
		      (baudctrlb_dout &   {8{baudctrlb_sel}} & {8{(fn_param_is_one(BAUDCTRLB_DM_LOC))}}); 

assign io_out_en   = iore & ((rxb_txb_sel   & ~fn_param_is_one(RXB_TXB_DM_LOC  )) |
		             (status_sel    & ~fn_param_is_one(STATUS_DM_LOC   )) |
		             (ctrla_sel     & ~fn_param_is_one(CTRLA_DM_LOC    )) |
		             (ctrlb_sel     & ~fn_param_is_one(CTRLB_DM_LOC    )) |
		             (ctrlc_sel     & ~fn_param_is_one(CTRLC_DM_LOC    )) |
		             (baudctrla_sel & ~fn_param_is_one(BAUDCTRLA_DM_LOC)) |
		             (baudctrlb_sel & ~fn_param_is_one(BAUDCTRLB_DM_LOC)) ); 

assign dm_out_en   = (dm_sel & ramre) & ((rxb_txb_sel   & fn_param_is_one(RXB_TXB_DM_LOC  )) |
		                         (status_sel    & fn_param_is_one(STATUS_DM_LOC   )) |
		                         (ctrla_sel     & fn_param_is_one(CTRLA_DM_LOC    )) |
		                         (ctrlb_sel     & fn_param_is_one(CTRLB_DM_LOC    )) |
		                         (ctrlc_sel     & fn_param_is_one(CTRLC_DM_LOC    )) |
		                         (baudctrla_sel & fn_param_is_one(BAUDCTRLA_DM_LOC)) |
		                         (baudctrlb_sel & fn_param_is_one(BAUDCTRLB_DM_LOC)) ); 

/*
assign rxb_txb_sel    = (RXB_TXB_DM_LOC  ) ?  (ramadr[2:0] == RXB_TXB_ADR  ) : (adr[5:0] == RXB_TXB_ADR); 
assign status_sel     = (STATUS_DM_LOC   ) ?  (ramadr[2:0] == STATUS_ADR   ) : (adr[5:0] == STATUS_ADR); 
assign ctrla_sel      = (CTRLA_DM_LOC	 ) ?  (ramadr[2:0] == CTRLA_ADR    ) : (adr[5:0] == CTRLA_ADR); 
assign ctrlb_sel      = (CTRLB_DM_LOC	 ) ?  (ramadr[2:0] == CTRLB_ADR    ) : (adr[5:0] == CTRLB_ADR);
assign ctrlc_sel      = (CTRLC_DM_LOC	 ) ?  (ramadr[2:0] == CTRLC_ADR    ) : (adr[5:0] == CTRLC_ADR); 
assign baudctrla_sel  = (BAUDCTRLA_DM_LOC) ?  (ramadr[2:0] == BAUDCTRLA_ADR) : (adr[5:0] == BAUDCTRLA_ADR); 
assign baudctrlb_sel  = (BAUDCTRLB_DM_LOC) ?  (ramadr[2:0] == BAUDCTRLB_ADR) : (adr[5:0] == BAUDCTRLB_ADR); 
*/

assign rxb_txb_sel    = (LP_EXT_ADDR_DCD) ? adr[0]    : ((RXB_TXB_DM_LOC  ) ?  (ramadr[2:0] == RXB_TXB_ADR  ) : (adr[5:0] == RXB_TXB_ADR)); 
assign status_sel     = (LP_EXT_ADDR_DCD) ? adr[1]    : ((STATUS_DM_LOC   ) ?  (ramadr[2:0] == STATUS_ADR   ) : (adr[5:0] == STATUS_ADR)); 
assign ctrla_sel      = (LP_EXT_ADDR_DCD) ? adr[3]    : ((CTRLA_DM_LOC  )   ?  (ramadr[2:0] == CTRLA_ADR    ) : (adr[5:0] == CTRLA_ADR)); 
assign ctrlb_sel      = (LP_EXT_ADDR_DCD) ? adr[4]    : ((CTRLB_DM_LOC  )   ?  (ramadr[2:0] == CTRLB_ADR    ) : (adr[5:0] == CTRLB_ADR));
assign ctrlc_sel      = (LP_EXT_ADDR_DCD) ? adr[5]    : ((CTRLC_DM_LOC  )   ?  (ramadr[2:0] == CTRLC_ADR    ) : (adr[5:0] == CTRLC_ADR)); 
assign baudctrla_sel  = (LP_EXT_ADDR_DCD) ? ramadr[0] : ((BAUDCTRLA_DM_LOC) ?  (ramadr[2:0] == BAUDCTRLA_ADR) : (adr[5:0] == BAUDCTRLA_ADR)); 
assign baudctrlb_sel  = (LP_EXT_ADDR_DCD) ? ramadr[1] : ((BAUDCTRLB_DM_LOC) ?  (ramadr[2:0] == BAUDCTRLB_ADR) : (adr[5:0] == BAUDCTRLB_ADR)); 


assign rxb_txb_we    = ((RXB_TXB_DM_LOC  ) ?  (dm_sel & ramwe) : iowe) & rxb_txb_sel  ;     
assign status_we     = ((STATUS_DM_LOC	 ) ?  (dm_sel & ramwe) : iowe) & status_sel   ;     
assign ctrla_we      = ((CTRLA_DM_LOC	 ) ?  (dm_sel & ramwe) : iowe) & ctrla_sel    ;     
assign ctrlb_we      = ((CTRLB_DM_LOC	 ) ?  (dm_sel & ramwe) : iowe) & ctrlb_sel    ;     
assign ctrlc_we      = ((CTRLC_DM_LOC	 ) ?  (dm_sel & ramwe) : iowe) & ctrlc_sel    ;     
assign baudctrla_we  = ((BAUDCTRLA_DM_LOC) ?  (dm_sel & ramwe) : iowe) & baudctrla_sel;     
assign baudctrlb_we  = ((BAUDCTRLB_DM_LOC) ?  (dm_sel & ramwe) : iowe) & baudctrlb_sel;     

// Read from data register
assign rxb_txb_re    = ((RXB_TXB_DM_LOC  ) ?  (dm_sel & ramre) : iore) & rxb_txb_sel  ;


 assign chsize_5b = (chsize == LP_CHSIZE_5BIT) ? 1'b1 : 1'b0;
 assign chsize_6b = (chsize == LP_CHSIZE_6BIT) ? 1'b1 : 1'b0;
 assign chsize_7b = (chsize == LP_CHSIZE_7BIT) ? 1'b1 : 1'b0;
 assign chsize_8b = (chsize == LP_CHSIZE_8BIT) ? 1'b1 : 1'b0; 
 assign chsize_9b = (chsize == LP_CHSIZE_9BIT) ? 1'b1 : 1'b0;

// Parity configuration
assign parity_en       = (pmode == {2{1'b0}}) ? 1'b0 : 1'b1;
assign parity_odd      = (pmode == 2'b11)     ? 1'b1 : 1'b0;
assign parity_even     = (pmode == 2'b10)     ? 1'b1 : 1'b0;
assign parity_reserved = (pmode == 2'b01)     ? 1'b1 : 1'b0;

// TBD 
assign rxcintlvl = ctrla_dout[5:4];
assign txcintlvl = ctrla_dout[3:2];
assign dreintlvl = ctrla_dout[1:0];

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//                                 Receiver
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

assign disable_receiver = rxen & (ctrlb_we & ~ctrlb_din[4]); // Fixed 18.09.12

// TBD
       rg_md #(
	       .p_width     (6),   
               .p_init_val  ({6{1'b0}}),
	       .p_impl_mask ({6{1'b1}}),
	       .p_sync_rst  (0)   
	       )
   rg_md_ctrla_inst(
               .clk   (cp2),
               .nrst  (ireset),
               .wdata (ctrla_din[5:0]),  				     
               .wbe   ({LP_WBE_WIDTH{ctrla_we}}),
               .rdata (ctrla_dout[5:0])										     
	       );

assign ctrla_dout[7:6] = {2{1'b0}};

// TBD
/*
       rg_md #(
	       .p_width     (5),   
               .p_init_val  ({5{1'b0}}),
	       .p_impl_mask ({5{1'b1}}),
	       .p_sync_rst  (0)   
	       )
   rg_md_ctrlb_inst(
               .clk   (cp2),
               .nrst  (ireset),
               .wdata (ctrlb_din[4:0]),  				     
               .wbe   ({LP_WBE_WIDTH{ctrlb_we}}),
               .rdata (ctrlb_dout[4:0])										     
	       );

assign ctrlb_dout[7:5] = {3{1'b0}};
*/

// CTRLB bits 5 and 6 are now implemented
       rg_md #(
	       .p_width     (5+2),   
               .p_init_val  ({(5+2){1'b0}}),
	       .p_impl_mask ({(5+2){1'b1}}),
	       .p_sync_rst  (0)   
	       )
   rg_md_ctrlb_inst(
               .clk   (cp2),
               .nrst  (ireset),
               .wdata (ctrlb_din[6:0]),  				     
               .wbe   ({LP_WBE_WIDTH{ctrlb_we}}),
               .rdata (ctrlb_dout[6:0])										     
	       );

assign ctrlb_dout[7] = 1'b0;



       rg_md #(
	       .p_width     (8),   
               .p_init_val  ({8{1'b0}}),
	       .p_impl_mask ({8{1'b1}}),
	       .p_sync_rst  (0)   
	       )
   rg_md_ctrlc_inst(
               .clk   (cp2),
               .nrst  (ireset),
               .wdata (ctrlc_din),  				     
               .wbe   ({LP_WBE_WIDTH{ctrlc_we}}),
               .rdata (ctrlc_dout)										     
	       );


       rg_md #(
	       .p_width     (8),   
               .p_init_val  ({8{1'b0}}),
	       .p_impl_mask ({8{1'b1}}),
	       .p_sync_rst  (0)   
	       )
   rg_md_baudctrla_inst(
               .clk   (cp2),
               .nrst  (ireset),
               .wdata (baudctrla_din),  				     
               .wbe   ({LP_WBE_WIDTH{baudctrla_we}}),
               .rdata (baudctrla_dout)										     
	       );

       rg_md #(
	       .p_width     (8),   
               .p_init_val  ({8{1'b0}}),
	       .p_impl_mask ({8{1'b1}}),
	       .p_sync_rst  (0)   
	       )
   rg_md_baudctrlb_inst(
               .clk   (cp2),
               .nrst  (ireset),
               .wdata (baudctrlb_din),  				     
               .wbe   ({LP_WBE_WIDTH{baudctrlb_we}}),
               .rdata (baudctrlb_dout)										     
	       );

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

// Attention: shift must not take place when 
// buffer overflow is detected (rx_buf_ovf_current) 
assign rx_sh_en = (!rx_buf_ovf_current && rx_step && rx_clk_en && (rc_sm_st_current != LP_RC_SM_ST_IDLE  && rc_sm_st_current != LP_RC_SM_ST_START)) ? 1'b1 : 1'b0;

assign rc_start_detected = ~rxd_filt;

always@*
 begin : receiver_main_comb
 // Latch avoidance
 rc_sm_st_next              = rc_sm_st_current;  
 rx_step_cnt_next           = rx_step_cnt_current; 
 rx_shifter_out_muxed       = {LP_SHIFTER_LEN{1'b0}};
 rx_fifo_wr_pending_st_next = rx_fifo_wr_pending_st_current;
 rx_buf_ovf_next            = rx_buf_ovf_current;
 rtsn_next                  = rtsn_current; 
 // Latch avoidance

if(rx_clk_en) begin

if(rc_sm_st_current == LP_RC_SM_ST_IDLE && rxd_fe_det) 
 // Clear RX step counter at the beginning of the new frame
 rx_step_cnt_next = 4'b0001; // TBD -> {4{1'b0}};
else 
 rx_step_cnt_next = rx_step_cnt_current + 4'b1; 

case(rc_sm_st_current)
 LP_RC_SM_ST_IDLE   : if(rxd_fe_det) rc_sm_st_next = LP_RC_SM_ST_START;
 LP_RC_SM_ST_START  : if(rx_step) begin
                       if(rc_start_detected) rc_sm_st_next = LP_RC_SM_ST_B0;      
		       else rc_sm_st_next = LP_RC_SM_ST_IDLE; 	     
                      end 

 LP_RC_SM_ST_B0     : if(rx_step) rc_sm_st_next = LP_RC_SM_ST_B1;
 LP_RC_SM_ST_B1     : if(rx_step) rc_sm_st_next = LP_RC_SM_ST_B2;
 LP_RC_SM_ST_B2     : if(rx_step) rc_sm_st_next = LP_RC_SM_ST_B3;
 LP_RC_SM_ST_B3     : if(rx_step) rc_sm_st_next = LP_RC_SM_ST_B4;
 LP_RC_SM_ST_B4     : 
                      if(rx_step) begin  
                       if(chsize_6b || chsize_7b || chsize_8b || chsize_9b) rc_sm_st_next = LP_RC_SM_ST_B5;		    
 		       else if (parity_en) rc_sm_st_next = LP_RC_SM_ST_P;
 		       else if (mpcm) rc_sm_st_next = LP_RC_SM_ST_SP; // ???? 
 		       else rc_sm_st_next = LP_RC_SM_ST_SP;
                      end  

 LP_RC_SM_ST_B5     :
                      if(rx_step) begin  
                       if(chsize_7b || chsize_8b || chsize_9b) rc_sm_st_next = LP_RC_SM_ST_B6;		    
 		       else if (parity_en) rc_sm_st_next = LP_RC_SM_ST_P;
 		       else if (mpcm) rc_sm_st_next = LP_RC_SM_ST_SP; // ???? 
 		       else rc_sm_st_next = LP_RC_SM_ST_SP;
                      end  

 LP_RC_SM_ST_B6     :
                      if(rx_step) begin  
                       if(chsize_8b || chsize_9b) rc_sm_st_next = LP_RC_SM_ST_B7;		    
 		       else if (parity_en) rc_sm_st_next = LP_RC_SM_ST_P;
 		       else if (mpcm) rc_sm_st_next = LP_RC_SM_ST_SP; // ???? 
 		       else rc_sm_st_next = LP_RC_SM_ST_SP;
                      end  

 LP_RC_SM_ST_B7     :
                      if(rx_step) begin  
                       if(chsize_9b) rc_sm_st_next = LP_RC_SM_ST_B8;		    
 		       else if (parity_en) rc_sm_st_next = LP_RC_SM_ST_P;
 		       else if (mpcm) rc_sm_st_next = LP_RC_SM_ST_SP; // ???? 
 		       else rc_sm_st_next = LP_RC_SM_ST_SP;
                      end  

 LP_RC_SM_ST_B8     :
                      if(rx_step) begin  
 		       if (parity_en) rc_sm_st_next = LP_RC_SM_ST_P;
 		       else if (mpcm) rc_sm_st_next = LP_RC_SM_ST_SP; // ???? 
 		       else rc_sm_st_next = LP_RC_SM_ST_SP;
                      end  

 LP_RC_SM_ST_P      : if(rx_step) rc_sm_st_next = LP_RC_SM_ST_SP;
 
 // Must be changed
 LP_RC_SM_ST_SP    : if(rx_step) begin if (mpcm) rc_sm_st_next = LP_RC_SM_ST_START; else rc_sm_st_next = LP_RC_SM_ST_IDLE; end

 default            : rc_sm_st_next = LP_RC_SM_ST_IDLE;  
endcase // case(rc_sm_st_current)

end // if(rx_clk_en)

// Shifter output
//                10 9 8 7 6 5 4 3 2 1 0
// 5b              S 4 3 2 1 0 x x x x x
// 5b + P          S P 4 3 2 1 0 x x x x          
// 6b              S 5 4 3 2 1 0 x x x x
// 6b + P          S P 5 4 3 2 1 0 x x x
// 7b              S 6 5 4 3 2 1 0 x x x
// 7b + P          S P 6 5 4 3 2 1 0 x x
// 8b              S 7 6 5 4 3 2 1 0 x x 
// 8b + P          S P 7 6 5 4 3 2 1 0 x 
// 9b              S 8 7 6 5 4 3 2 1 0 x 
// 9b + P          S P 8 7 6 5 4 3 2 1 0

// Shifter out MUX
 rx_shifter_out_muxed[10]  = ~rx_shifter_out[10]; // Frame Error

 // Parity Error (add (parity_reserved) ? rx_shifter_out[9] :  ???)
 rx_shifter_out_muxed[9]   = parity_en & ((parity_reserved & rx_shifter_parity_out) | (~parity_reserved & rx_calculated_parity)); 

     if(chsize_5b) begin if(!parity_en)begin rx_shifter_out_muxed[4:0] = rx_shifter_out[9:5]; end else begin rx_shifter_out_muxed[4:0] = rx_shifter_out[8:4]; end end
else if(chsize_6b) begin if(!parity_en)begin rx_shifter_out_muxed[5:0] = rx_shifter_out[9:4]; end else begin rx_shifter_out_muxed[5:0] = rx_shifter_out[8:3]; end end
else if(chsize_7b) begin if(!parity_en)begin rx_shifter_out_muxed[6:0] = rx_shifter_out[9:3]; end else begin rx_shifter_out_muxed[6:0] = rx_shifter_out[8:2]; end end
else if(chsize_8b) begin if(!parity_en)begin rx_shifter_out_muxed[7:0] = rx_shifter_out[9:2]; end else begin rx_shifter_out_muxed[7:0] = rx_shifter_out[8:1]; end end
else if(chsize_9b) begin if(!parity_en)begin rx_shifter_out_muxed[8:0] = rx_shifter_out[9:1]; end else begin rx_shifter_out_muxed[8:0] = rx_shifter_out[8:0]; end end

 case(rx_fifo_wr_pending_st_current)
  1'b0    : if(rx_step && rx_clk_en && rc_sm_st_current == LP_RC_SM_ST_SP && mpcm_adr_fl) rx_fifo_wr_pending_st_next = 1'b1;
  1'b1    : if(!rx_fifo_full /*|| (rx_fifo_full && 1'b0)*/) rx_fifo_wr_pending_st_next = 1'b0; // !!! TBD
  default : rx_fifo_wr_pending_st_next = 1'b0;
 endcase

 // RX buffer overfolow
 case(rx_buf_ovf_current)
  1'b0    : if(rx_fifo_wr_pending_st_current && rx_fifo_full && (rc_sm_st_current == LP_RC_SM_ST_START && rx_step && rc_start_detected)) rx_buf_ovf_next = 1'b1; // <<<<<<<
  1'b1    : if(rx_fifo_re) rx_buf_ovf_next = 1'b0; // Read of data register
  default : rx_buf_ovf_next = 1'b0;
 endcase

 // Optional
 case(rtsn_current)
  1'b1    : if(!rx_fifo_almost_full && !rx_fifo_full && hw_flow_ctrl_en) rtsn_next = 1'b0;
  1'b0    : if((rx_fifo_almost_full && hw_flow_ctrl_en) || !hw_flow_ctrl_en) rtsn_next = 1'b1;
  default : rtsn_next = 1'b0; 
 endcase // (rtsn_current)

 if(disable_receiver) begin
  rc_sm_st_next              = LP_RC_SM_ST_IDLE;
  rx_step_cnt_next           = {4{1'b0}};
  rx_fifo_wr_pending_st_next = 1'b0;
  rx_buf_ovf_next            = 1'b0;
  rtsn_next                  = 1'b1; // TBD
 end

 //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
 //  Support for synchronous reset 
 //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 if(SYNC_RST) begin 
  if(ireset) begin 
   rc_sm_st_next              = LP_RC_SM_ST_IDLE;
   rx_step_cnt_next           = {4{1'b0}};
   rx_fifo_wr_pending_st_next = 1'b0;
   rx_buf_ovf_next            = 1'b0;
   rtsn_next                  = 1'b1; // TBD 
  end
 end

end // receiver_main_comb



 always @(posedge cp2 or negedge ireset)
   begin: rx_main_seq
      if (!ireset)		// Reset 
      begin
       rc_sm_st_current              <= LP_RC_SM_ST_IDLE;  
       rx_step_cnt_current           <= {4{1'b0}};
       rx_fifo_wr_pending_st_current <= 1'b0;
       rx_buf_ovf_current            <= 1'b0;
       rtsn_current                  <= 1'b1; // ??? TBD polarity 	 
      end
      else 		// Clock 
      begin
       rc_sm_st_current              <= rc_sm_st_next;  
       rx_step_cnt_current           <= rx_step_cnt_next;
       rx_fifo_wr_pending_st_current <= rx_fifo_wr_pending_st_next; 
       rx_buf_ovf_current            <= rx_buf_ovf_next;
       rtsn_current                  <= rtsn_next;
      end
   end // rx_main_seq


// assign rx_step = (rx_step_cnt_current == LP_16X_SAMPLING_POINT) ? 1'b1 : 1'b0;
assign rx_step = (clk2x) ? ((rx_step_cnt_current[2:0] == LP_8X_SAMPLING_POINT) ? 1'b1 : 1'b0) : // 8X mode
                           ((rx_step_cnt_current == LP_16X_SAMPLING_POINT)     ? 1'b1 : 1'b0);  // 16X mode (Normal)

// Allows write data to the RX FIFO in two cases
// 1. MPCM is zero.  
// 2. MPCM is high and the last received data bit is one (address frame) 
assign mpcm_adr_fl = (mpcm) ? ((parity_en) ? rx_shifter_out[8] : rx_shifter_out[9]) : 1'b1;

// Loopback support MUX
assign rxd_muxed = (loopback_en) ? txd : rxd;

rc_sync_voter #(
		.USE_RST  ( 1 ),
 		.SYNC_RST ( 0 )
 		) 
rc_sync_voter_rxd_inst(
	 .nrst    (ireset),
 	 .clk	  (cp2),
 	 .en	  (rx_clk_en),
 	 .rxd	  (rxd_muxed),
 	 .fe_det  (rxd_fe_det),
 	 .re_det  (),
 	 .rfe_det (),
 	 .dout    (rxd_filt) 
	 );


      clk_gen_logic #(
		     .SYNC_RST ( 0 )
		     ) 
   clk_gen_logic_inst(
                     .nrst       (ireset),
		     .clk        (cp2),
		     .bsel       ({baudctrlb_dout[3:0],baudctrla_dout[7:0]}),
		     .bscale     (baudctrlb_dout[7:4]),
		     .change_cfg (baudctrla_we | baudctrlb_we),
		     .rxen       (rxen),
		     .txen       (txen),
		     .clr_tx_cnt (clr_tx_cnt), 
		     .rx_clk_en  (rx_clk_en),
		     .tx_clk_en  (tx_clk_en)
                     );


rx_shift_reg #(
 	      .SYNC_RST ( 0 ),
 	      .SH_LEN   ( LP_SHIFTER_LEN )
 	      ) 
rx_shift_reg_inst(
	      .nrst   (ireset),
 	      .clk    (cp2),
 	      .en     (rx_sh_en),
 	      .rxd    (rxd_filt),
 	      .data_o (rx_shifter_out)
	      );

assign rx_fifo_wr = rx_fifo_wr_pending_st_current & ~rx_fifo_wr_pending_st_next; 


 fifo #(
  	.DEPTH    ( RX_FIFO_DEPTH ),
  	.WIDTH    ( LP_SHIFTER_LEN),
  	.SYNC_RST ( 0 )
  	) 
 fifo_rx_inst(
  	.nrst	       (ireset),
  	.clk	       (cp2),
  	.din	       (rx_shifter_out_muxed), 
  	.we	       (rx_fifo_wr), // ????
  	.re	       (rx_fifo_re), 
  	.flush         (disable_receiver), // Flush FIFO
  	.dout	       (rx_fifo_out),
  	.w_full        (rx_fifo_full),
  	.w_almost_full (rx_fifo_almost_full),
  	.r_empty       (rx_fifo_empty)
	);

assign rx_shifter_parity_out = rx_shifter_out[9];
assign rx_calculated_parity  = (^rx_shifter_out_muxed[8:0] ^ rx_shifter_parity_out) ^ parity_odd; // TBD ???

assign rx_fifo_re = rxb_txb_re & rxen; // Read enable for RX FIFO
assign rxb_dout   = rx_fifo_out[7:0];  

// Status register
assign status_dout[7] = ~rx_fifo_empty;     // TBD See RXCIF description
assign status_dout[6] = txcif_current; 
assign status_dout[5] = ~tx_fifo_full;      // TBD
assign status_dout[4] = rx_fifo_out[10];    // Frame error
assign status_dout[3] = rx_buf_ovf_current;
assign status_dout[2] = rx_fifo_out[9];     // Parity
assign status_dout[1] = 1'b0;               // Reserved
assign status_dout[0] = rx_fifo_out[8];     // Receive Bit 8

assign cpuwait        = 1'b0;

assign rtsn = rtsn_current;

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//                                 Transmitter
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

// Optional PERR for TX
       rg_md #(
	       .p_width     (1),   
               .p_init_val  ({1'b0}),
	       .p_impl_mask ({1'b1}),
	       .p_sync_rst  (0)   
	       )
   rg_md_parity_repl_inst(
               .clk   (cp2),
               .nrst  (ireset),
               .wdata (status_din[2]),  				     
               .wbe   ({LP_WBE_WIDTH{status_we}}),
               .rdata (tx_opt_parity_bit)										     
	       );


assign ctsn_muxed = (loopback_en) ? rtsn_current : ctsn_clk;
assign cts_int = ~ctsn_muxed | ~hw_flow_ctrl_en; // Clear to send (fixed 23.09.12)


// Optional CTS support

             rsnc_cfg_vlog #(
	                     .P_ADD_STGS_NUM  ( 0    ), 
	                     .P_RST_ACT_HIGH  ( 0    ), // nrst is active high
			     .P_SYNC_RST      ( 0    ), // nrst is SYNCHRONOUS reset input
			     .P_NO_RST	      ( 0    ), // nrst is not used (no reset)
			     .P_RST_VAL       ( 1'b1 )  // Values of resynch FFs after reset
		             )
   rsnc_cfg_vlog_ctsn_inst(	                   
			     .clk  (cp2),
		             .nrst (ireset),
                             .din  (ctsn),
                             .dout (ctsn_clk)
                             );	

// TX FIFO
tx_shift_reg #(
	      .SYNC_RST (0),
	      .DATA_LEN (LP_TX_SHIFTER_WIDTH)
	      ) 
tx_shift_reg_inst(
	      .nrst   (ireset),
	      .clk    (cp2),
	      .en     (tx_shift_en),
	      .load   (tx_shift_load),  
	      .data_i (tx_shift_data_i), 
	      .txd    (txd)
	      );

// Data from input data bus or from FIFO (TBD - control signal for the MUX ???)
assign tx_shift_data_i = (tx_fifo_empty) ? tx_shift_in_muxed : tx_fifo_out;

 fifo #(
  	.DEPTH    ( TX_FIFO_DEPTH ),
  	.WIDTH    ( LP_TX_SHIFTER_WIDTH ),
  	.SYNC_RST ( 0 )
  	) 
 fifo_tx_inst(
  	.nrst	       (ireset),
  	.clk	       (cp2),
  	.din	       (tx_shift_in_muxed), 
  	.we	       (tx_fifo_wr), // ????
  	.re	       (tx_fifo_re), 
  	.flush         (1'b0), // Flush FIFO
  	.dout	       (tx_fifo_out),
  	.w_full        (tx_fifo_full),
  	.w_almost_full (),
  	.r_empty       (tx_fifo_empty)
	);


assign tx_fifo_wr = (tr_sm_st_current != LP_TR_SM_ST_IDLE && rxb_txb_we && txen) ? 1'b1 : 1'b0; // TBD

assign tx_fifo_re = ((tr_sm_st_current == LP_TR_SM_ST_SP1 || tr_sm_st_current == LP_TR_SM_ST_SP2) &&  
                     tr_sm_st_next == LP_TR_SM_ST_START) ? 1'b1 : 1'b0;

 always@(posedge cp2 or negedge ireset)
   begin: tx_main_seq
      if (!ireset)		// Reset 
      begin
       tr_sm_st_current    <= LP_TR_SM_ST_IDLE;  
       tx_step_cnt_current <= {4{1'b0}};
       txcif_current       <= 1'b0;
       tx_en_current       <= 1'b0;
      end
      else 		// Clock 
      begin
       tx_en_current       <= tx_en_next;
       tr_sm_st_current    <= tr_sm_st_next;  
       tx_step_cnt_current <= tx_step_cnt_next;
       txcif_current       <= txcif_next;
      end
   end // tx_main_seq

always@*
 begin : tx_main_comb
  // Latch avoidance
  tr_sm_st_next     = tr_sm_st_current;
  tx_shift_in_muxed = {10{1'b1}}; // TBD 
  tx_step_cnt_next  = tx_step_cnt_current;
  txcif_next        = txcif_current;
  tx_parity_calc_i  = {9{1'b0}};
  tx_en_next        = tx_en_current;
  // Latch avoidance  
  
  case(tr_sm_st_current)
   LP_TR_SM_ST_IDLE  : begin if(rxb_txb_we && cts_int && txen) tr_sm_st_next = LP_TR_SM_ST_START; end
   LP_TR_SM_ST_START : begin if(tx_clk_en && tx_step) tr_sm_st_next = LP_TR_SM_ST_B0; end 
   LP_TR_SM_ST_B0    : begin if(tx_clk_en && tx_step) tr_sm_st_next = LP_TR_SM_ST_B1; end 
   LP_TR_SM_ST_B1    : begin if(tx_clk_en && tx_step) tr_sm_st_next = LP_TR_SM_ST_B2; end 
   LP_TR_SM_ST_B2    : begin if(tx_clk_en && tx_step) tr_sm_st_next = LP_TR_SM_ST_B3; end 
   LP_TR_SM_ST_B3    : begin if(tx_clk_en && tx_step) tr_sm_st_next = LP_TR_SM_ST_B4; end 
   LP_TR_SM_ST_B4    :                       
                      if(tx_clk_en && tx_step) begin  
                       if(chsize_6b || chsize_7b || chsize_8b || chsize_9b) tr_sm_st_next = LP_TR_SM_ST_B5;		    
 		       else if (parity_en) tr_sm_st_next = LP_TR_SM_ST_P;
 		       else if (mpcm) tr_sm_st_next = LP_TR_SM_ST_SP1; // ???? 
 		       else tr_sm_st_next = LP_TR_SM_ST_SP1;
                      end  
 
   LP_TR_SM_ST_B5    : 
                      if(tx_clk_en && tx_step) begin  
                       if(chsize_7b || chsize_8b || chsize_9b) tr_sm_st_next = LP_TR_SM_ST_B6;		    
 		       else if (parity_en) tr_sm_st_next = LP_TR_SM_ST_P;
 		       else if (mpcm) tr_sm_st_next = LP_TR_SM_ST_SP1; // ???? 
 		       else tr_sm_st_next = LP_TR_SM_ST_SP1;
                      end  
   
   LP_TR_SM_ST_B6    :
                      if(tx_clk_en && tx_step) begin  
                       if(chsize_8b || chsize_9b) tr_sm_st_next = LP_TR_SM_ST_B7;		    
 		       else if (parity_en) tr_sm_st_next = LP_TR_SM_ST_P;
 		       else if (mpcm) tr_sm_st_next = LP_TR_SM_ST_SP1; // ???? 
 		       else tr_sm_st_next = LP_TR_SM_ST_SP1;
                      end  
    
   LP_TR_SM_ST_B7    :
                      if(tx_clk_en && tx_step) begin  
                       if(chsize_9b) tr_sm_st_next = LP_TR_SM_ST_B8;		    
 		       else if (parity_en) tr_sm_st_next = LP_TR_SM_ST_P;
 		       else if (mpcm) tr_sm_st_next = LP_TR_SM_ST_SP1; // ???? 
 		       else tr_sm_st_next = LP_TR_SM_ST_SP1;
                      end  
   
   LP_TR_SM_ST_B8    :                      
                      if(tx_clk_en && tx_step) begin  
 		       if (parity_en) tr_sm_st_next = LP_TR_SM_ST_P;
 		       else if (mpcm) tr_sm_st_next = LP_TR_SM_ST_SP1; // ???? 
 		       else tr_sm_st_next = LP_TR_SM_ST_SP1;
                      end  
 
   LP_TR_SM_ST_P     : begin if(tx_clk_en && tx_step) tr_sm_st_next = LP_TR_SM_ST_SP1; end 

//   LP_TR_SM_ST_SP1   : begin if(tx_clk_en && tx_step) begin if(sbmode) tr_sm_st_next = LP_TR_SM_ST_SP2; else if(!tx_fifo_empty) tr_sm_st_next = LP_TR_SM_ST_START; else tr_sm_st_next = LP_TR_SM_ST_IDLE; end end  
//   LP_TR_SM_ST_SP2   : begin if(tx_clk_en && tx_step) begin if(!tx_fifo_empty) tr_sm_st_next = LP_TR_SM_ST_START; else tr_sm_st_next = LP_TR_SM_ST_IDLE; end end  

   LP_TR_SM_ST_SP1   : begin 
   			if(tx_clk_en && tx_step) begin
   			 if(sbmode) begin tr_sm_st_next = LP_TR_SM_ST_SP2; end
   			 else begin
   			 //???????????????????????????????????????????????????????????????????? 
   			   if(!tx_fifo_empty) begin // tx_fifo_is_not_empty
   			    if(!hw_flow_ctrl_en || (hw_flow_ctrl_en && cts_int)) begin
   			     tr_sm_st_next = LP_TR_SM_ST_START;
   			    end
   			    else if(hw_flow_ctrl_en && !cts_int) begin
   			     tr_sm_st_next = LP_TR_SM_ST_WAIT_FOR_CTS;
   			    end
   			   end // tx_fifo_is_not_empty
   			   else begin // tx_fifo_is_empty
   			    tr_sm_st_next = LP_TR_SM_ST_IDLE; 
   			   end // tx_fifo_is_empty
   			 //????????????????????????????????????????????????????????????????????
   			 end
   			end // if(tx_clk_en && tx_step)
   		       end
   
   LP_TR_SM_ST_SP2   : begin 
   			if(tx_clk_en && tx_step) begin
   			 //???????????????????????????????????????????????????????????????????? 
   			   if(!tx_fifo_empty) begin // tx_fifo_is_not_empty
   			    if(!hw_flow_ctrl_en || (hw_flow_ctrl_en && cts_int)) begin
   			     tr_sm_st_next = LP_TR_SM_ST_START;
   			    end
   			    else if(hw_flow_ctrl_en && !cts_int) begin
   			     tr_sm_st_next = LP_TR_SM_ST_WAIT_FOR_CTS;
   			    end
   			   end // tx_fifo_is_not_empty
   			   else begin // tx_fifo_is_empty
   			    tr_sm_st_next = LP_TR_SM_ST_IDLE; 
   			   end // tx_fifo_is_empty
                      //????????????????????????????????????????????????????????????????????
                     end // if(tx_clk_en && tx_step)
                    end


   LP_TR_SM_ST_WAIT_FOR_CTS : begin if(cts_int) tr_sm_st_next = LP_TR_SM_ST_START; end

   default           : begin tr_sm_st_next = LP_TR_SM_ST_IDLE; end 
  endcase // (tr_sm_st_current)


     if(chsize_5b) begin tx_shift_in_muxed[4:0] = tx_data_for_tr[4:0]; tx_shift_in_muxed[5] = (parity_en) ? tx_data_for_tr[9] : 1'b1; end
else if(chsize_6b) begin tx_shift_in_muxed[5:0] = tx_data_for_tr[5:0]; tx_shift_in_muxed[6] = (parity_en) ? tx_data_for_tr[9] : 1'b1; end
else if(chsize_7b) begin tx_shift_in_muxed[6:0] = tx_data_for_tr[6:0]; tx_shift_in_muxed[7] = (parity_en) ? tx_data_for_tr[9] : 1'b1; end
else if(chsize_8b) begin tx_shift_in_muxed[7:0] = tx_data_for_tr[7:0]; tx_shift_in_muxed[8] = (parity_en) ? tx_data_for_tr[9] : 1'b1; end
else if(chsize_9b) begin tx_shift_in_muxed[8:0] = tx_data_for_tr[8:0]; tx_shift_in_muxed[9] = (parity_en) ? tx_data_for_tr[9] : 1'b1; end

// Mux for parity calculation
     if(chsize_5b) begin tx_parity_calc_i[4:0] = tx_data_for_parity_calc[4:0];  end
else if(chsize_6b) begin tx_parity_calc_i[5:0] = tx_data_for_parity_calc[5:0];  end
else if(chsize_7b) begin tx_parity_calc_i[6:0] = tx_data_for_parity_calc[6:0];  end
else if(chsize_8b) begin tx_parity_calc_i[7:0] = tx_data_for_parity_calc[7:0];  end
else if(chsize_9b) begin tx_parity_calc_i[8:0] = tx_data_for_parity_calc[8:0];  end


 // TX step generation
 if(clr_tx_cnt) begin tx_step_cnt_next = {4{1'b0}}; end
 else if(tx_clk_en) begin tx_step_cnt_next = tx_step_cnt_current + 4'b1; end

 case(txcif_current)
  1'b0    : if(tr_sm_st_current != LP_TR_SM_ST_IDLE && tr_sm_st_next == LP_TR_SM_ST_IDLE) txcif_next = 1'b1;
  1'b1    : if(((txc_irqack || (status_we && status_din[6])) && 
               !(tr_sm_st_current != LP_TR_SM_ST_IDLE && tr_sm_st_current == LP_TR_SM_ST_IDLE)) || disable_transmitter_pulse) txcif_next = 1'b0;
  default : txcif_next = 1'b0;
 endcase//(txcif_current)

 // !!!!!!!!!!!!!!!
 case(tx_en_current)
  1'b0    : if(enable_transmitter) tx_en_next = 1'b1;
  1'b1    : if(disable_transmitter_pulse)tx_en_next = 1'b0;
  default :      tx_en_next = 1'b0; 
 endcase // (tx_en_current)

 //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
 //  Support for synchronous reset 
 //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 if(SYNC_RST) begin 
  if(ireset) begin 
   tr_sm_st_next    = LP_TR_SM_ST_IDLE;
   tx_step_cnt_next = {4{1'b0}};
   txcif_next       = 1'b0;
   tx_en_next       = 1'b0; 
  end
 end

 end // tx_main_comb

// Enable/disable transmitter
assign enable_transmitter        = ctrlb_we & ctrlb_din[3];
assign disable_transmitter       = ctrlb_we & ~ctrlb_din[3];

// Moment when transmitter will be really disabled
assign disable_transmitter_pulse = ((disable_transmitter && tr_sm_st_current == LP_TR_SM_ST_IDLE) || 
                                    (~ctrlb_dout[3] && tr_sm_st_current == LP_TR_SM_ST_IDLE && !enable_transmitter)) ? 1'b1 : 1'b0;


// Clear TX counter at the beginig of the new transmission (26.09.12 HW flow ctrl support was added)
//assign clr_tx_cnt = (tr_sm_st_current == LP_TR_SM_ST_IDLE && rxb_txb_we && cts_int && txen) ? 1'b1 : 1'b0;
assign clr_tx_cnt = ((tr_sm_st_current == LP_TR_SM_ST_IDLE || tr_sm_st_next == LP_TR_SM_ST_WAIT_FOR_CTS) && rxb_txb_we && cts_int && txen) ? 1'b1 : 1'b0;


assign tx_calculated_parity = (parity_reserved) ? tx_opt_parity_bit : ((^tx_parity_calc_i) ^ parity_odd);

// assign tx_step = &tx_step_cnt_current;
assign tx_step = (clk2x) ? (&tx_step_cnt_current[2:0]) : (&tx_step_cnt_current); 


assign tx_data_for_tr           = {tx_calculated_parity,txb8,rxb_din[7:0]};
assign tx_data_for_parity_calc  = {txb8,rxb_din[7:0]};

assign tx_shift_en   = (tx_clk_en && tx_step && 
                        (tr_sm_st_current != LP_TR_SM_ST_IDLE && 
// 25.08.12 ??			 tr_sm_st_current != LP_TR_SM_ST_P && 
			 tr_sm_st_current != LP_TR_SM_ST_SP1 && 
			 tr_sm_st_current != LP_TR_SM_ST_SP2)) ? 1'b1 : 1'b0;

assign tx_shift_load = ((tr_sm_st_current == LP_TR_SM_ST_IDLE && tr_sm_st_next == LP_TR_SM_ST_START) ||
((tr_sm_st_current == LP_TR_SM_ST_SP1 || tr_sm_st_current == LP_TR_SM_ST_SP2) && tr_sm_st_next == LP_TR_SM_ST_START)) ? 1'b1 : 1'b0;

// TBD -> outputs
 assign rx_en   = rxen; 
 assign tx_en   = tx_en_current; 

// Since XMEGA interrupt support is not yet implemented(TBD)
 assign txcirq  = (MEGA_COMPAT_MODE) ? (txcif_current  & txcintlvl[0]) : txcif_current ; 
 assign udreirq = (MEGA_COMPAT_MODE) ? (~tx_fifo_full  & dreintlvl[0]) : ~tx_fifo_full ; // ??? 
 assign rxcirq  = (MEGA_COMPAT_MODE) ? (~rx_fifo_empty & rxcintlvl[0]) : ~rx_fifo_empty;  

// Scan chains are not implemented for the moment
assign test_so1 = 1'b0;
assign test_so2 = 1'b0;


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ DEBUG ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// pragma translate_off
reg[1:8*12] tr_sm_st_current_str; 
always@*
 begin
case(tr_sm_st_current)
  LP_TR_SM_ST_IDLE   	   : tr_sm_st_current_str = "Idle"; 
  LP_TR_SM_ST_START  	   : tr_sm_st_current_str = "Start"; 
  LP_TR_SM_ST_B0     	   : tr_sm_st_current_str = "Bit_0"; 
  LP_TR_SM_ST_B1     	   : tr_sm_st_current_str = "Bit_1";  
  LP_TR_SM_ST_B2     	   : tr_sm_st_current_str = "Bit_2"; 
  LP_TR_SM_ST_B3     	   : tr_sm_st_current_str = "Bit_3"; 
  LP_TR_SM_ST_B4     	   : tr_sm_st_current_str = "Bit_4";  
  LP_TR_SM_ST_B5     	   : tr_sm_st_current_str = "Bit_5"; 
  LP_TR_SM_ST_B6     	   : tr_sm_st_current_str = "Bit_6"; 
  LP_TR_SM_ST_B7     	   : tr_sm_st_current_str = "Bit_7"; 
  LP_TR_SM_ST_B8     	   : tr_sm_st_current_str = "Bit_8"; 
  LP_TR_SM_ST_P      	   : tr_sm_st_current_str = "Parity"; 
  LP_TR_SM_ST_SP1    	   : tr_sm_st_current_str = "Stop_1"; 
  LP_TR_SM_ST_SP2    	   : tr_sm_st_current_str = "Stop_2"; 
  LP_TR_SM_ST_WAIT_FOR_CTS : tr_sm_st_current_str = "Wait_for_CTS";
  default           : tr_sm_st_current_str = "Unknown";  
endcase
end 

reg[1:8*12] rc_sm_st_current_str; 
always@*
 begin
case(rc_sm_st_current)
  LP_RC_SM_ST_IDLE  : rc_sm_st_current_str = "Idle"; 
  LP_RC_SM_ST_START : rc_sm_st_current_str = "Start"; 
  LP_RC_SM_ST_B0    : rc_sm_st_current_str = "Bit_0"; 
  LP_RC_SM_ST_B1    : rc_sm_st_current_str = "Bit_1";  
  LP_RC_SM_ST_B2    : rc_sm_st_current_str = "Bit_2"; 
  LP_RC_SM_ST_B3    : rc_sm_st_current_str = "Bit_3"; 
  LP_RC_SM_ST_B4    : rc_sm_st_current_str = "Bit_4";  
  LP_RC_SM_ST_B5    : rc_sm_st_current_str = "Bit_5"; 
  LP_RC_SM_ST_B6    : rc_sm_st_current_str = "Bit_6"; 
  LP_RC_SM_ST_B7    : rc_sm_st_current_str = "Bit_7"; 
  LP_RC_SM_ST_B8    : rc_sm_st_current_str = "Bit_8"; 
  LP_RC_SM_ST_P     : rc_sm_st_current_str = "Parity"; 
  LP_RC_SM_ST_SP    : rc_sm_st_current_str = "Stop"; 
  default           : rc_sm_st_current_str = "Unknown";  
endcase
end 

event rx_sample_data;
event rx_det_start;
event rx_sampl_start;
integer  rx_dbg_cnt;

always@(posedge cp2)
 begin
  if(ireset === 1'b1) begin
   if(rx_clk_en) begin rx_dbg_cnt = rx_dbg_cnt + 1; end
   if(rx_sh_en) begin -> rx_sample_data; rx_dbg_cnt = 0; end 
   if(rc_sm_st_current == LP_RC_SM_ST_IDLE && rx_clk_en && rxd_fe_det) begin -> rx_det_start; rx_dbg_cnt = 0; end
   if(rc_sm_st_current == LP_RC_SM_ST_START && rx_clk_en && rx_step && rc_start_detected) begin -> rx_sampl_start; rx_dbg_cnt = 0; end
  end
  else begin
   rx_dbg_cnt = 0;
  end
 end

// STATUS/CTRLB/CTRLC visualization
reg[1:8*80] status_str;
reg[1:8*80] ctrlb_str;
reg[1:8*80] ctrlc_str;

function[1:8*80] fn_dcd_vis_status;
input[7:0] status;
reg[1:8*80] tmp;
 begin
  tmp="";
  if(status[7] === 1'b1) tmp = {tmp,"RXCIF "};
  if(status[6] === 1'b1) tmp = {tmp,"TXCIF "};
  if(status[5] === 1'b1) tmp = {tmp,"DREIF "};
  if(status[4] === 1'b1) tmp = {tmp,"FERR "};
  if(status[3] === 1'b1) tmp = {tmp,"BUFOVF "};	    
  if(status[2] === 1'b1) tmp = {tmp,"PERR "}; 
//  if(status[1] === 1'b1) tmp = {tmp," "}; 
  if(status[0] === 1'b1) tmp = {tmp,"RXB8 "}; 
  fn_dcd_vis_status = tmp;
 end
endfunction // fn_dcd_vis_status


function[1:8*80] fn_dcd_vis_ctrlb;
input[7:0] ctrlb;
reg [1:8*80] tmp;
 begin
  tmp="";
  if(ctrlb[7] === 1'b1) tmp = {tmp," "};
  if(ctrlb[6] === 1'b1) tmp = {tmp,"HWFC "}; // Ext.
  if(ctrlb[5] === 1'b1) tmp = {tmp,"LBK "};  // Ext. 
  if(ctrlb[4] === 1'b1) tmp = {tmp,"RXEN "};
  if(ctrlb[3] === 1'b1) tmp = {tmp,"TXEN "};	    
  if(ctrlb[2] === 1'b1) tmp = {tmp,"CLK2X "}; 
  if(ctrlb[1] === 1'b1) tmp = {tmp,"MPCM "}; 
  if(ctrlb[0] === 1'b1) tmp = {tmp,"TXB8 "}; 
  fn_dcd_vis_ctrlb = tmp;
 end
endfunction // fn_dcd_vis_ctrlb


function[1:8*80] fn_dcd_vis_ctrlc;
input[7:0] ctrlc;
reg[1:8*80] tmp;
 begin
  tmp="";
  if(ctrlc[7] === 1'b1) tmp = {tmp,"CMODE1 "};
  if(ctrlc[6] === 1'b1) tmp = {tmp,"CMODE0 "};
  if(ctrlc[5] === 1'b1) tmp = {tmp,"PMODE1 "};
  if(ctrlc[4] === 1'b1) tmp = {tmp,"PMODE0 "};
  if(ctrlc[3] === 1'b1) tmp = {tmp,"SBMODE "};	    
  if(ctrlc[2] === 1'b1) tmp = {tmp,"CHSIZE2 "}; 
  if(ctrlc[1] === 1'b1) tmp = {tmp,"CHSIZE1 "}; 
  if(ctrlc[0] === 1'b1) tmp = {tmp,"CHSIZE0 "}; 
  fn_dcd_vis_ctrlc = tmp;
 end
endfunction // fn_dcd_vis_ctrlc

always@*
 begin
  if(ireset === 1'b1) begin
   status_str = fn_dcd_vis_status(status_dout);
   ctrlb_str  = fn_dcd_vis_ctrlb(ctrlb_dout);
   ctrlc_str  = fn_dcd_vis_ctrlc(ctrlc_dout);
  end
 end // always@*

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
// Attention!
// If USART baud rate is high there is a possibility of situation when BUFOVF flag
// is set by USART hardware but is not read (and taken into account) by the CPU.
// This can happen if the time interval between the reading of STATUS register
// and the reading of the DATA register is too long.  

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ DEBUG ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// pragma translate_on

endmodule // usart
