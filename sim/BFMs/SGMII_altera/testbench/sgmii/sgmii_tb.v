// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
//
// Revision Control Information
//
// $RCSfile: tb_pcs_pma_powerdown.v,v $
// $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/testbench/PCS/verilog/tb_pcs_pma_powerdown.v,v $
//
// $Revision: #1 $
// $Date: 2012/06/21 $
// Check in by : $Author: swbranch $
// Author      : SKNg/TTChong
//
// Project     : Triple Speed Ethernet - 1000 Base-X PCS / SGMII
//
// Description : (Simulation only)
//
// Testbench with PCS under test implemented with Altera Transceivers
//
// 
// ALTERA Confidential and Proprietary
// Copyright 2007 (c) Altera Corporation
// All rights reserved
//
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------


`timescale 1 ns / 10 ps


module tb ;

//  Core Settings
//  WARNING: DO NOT MODIFY THESE PARAMETERS
//  -------------------------------
	parameter PHY_IDENTIFIER=32'h00000000;
	parameter DEV_VERSION=16'h0c00;
	parameter ENABLE_SGMII=1;
	parameter SYNCHRONIZER_DEPTH=3;
	parameter DEVICE_FAMILY="CYCLONEIVGX";
	parameter EXPORT_PWRDN=1;
	parameter TRANSCEIVER_OPTION=0;
	parameter ENABLE_ALT_RECONFIG=1;
	parameter STARTING_CHANNEL_NUMBER=0;

	parameter MAX_CHANNELS=0;



//  Simulation Settings (Testbench)
//  -------------------------------

parameter TB_TXFRAMES = 5 ; //  number of frames to send in Txs path
parameter TB_TXIPG = 12 ; //  Inter Packet Gap used by RX generator
parameter TB_LENSTART = 100 ; //  length to start (incremented each new frame by TB_LENSTEP)
parameter TB_LENSTEP = 1 ; //  steps the length should increase with each frame
parameter TB_LENMAX = 1500 ; //  max. payload length for generation
parameter TB_MACLENMAX = 1518; //  max. frame length configuration of MAC
parameter TB_PHYERR = 1'b0; //  Generate PHY Error
parameter TB_CHAR_ERR = 0; //  Insert 10b Character Error
parameter TB_CHAR_ERR_NUM = 6; //  Number of Consecutive Character Error
parameter TB_ENA_AUTONEG = 1'b 0 ; //  Enable Auto-Negotiation
parameter TB_PCS_LINK_TIMER = 512 ; //  Link Timer
parameter TB_PARTNER_LINK_TIMER = 128 ; //  Link Timer
parameter TB_TX_ERR = 1'b 0 ; //  Enable GMII Error
parameter TB_PARTNER_PS1 = 1'b 1 ; //  Pause Support Encoding
parameter TB_PARTNER_PS2 = 1'b 0 ; //  Pause Support Encoding
parameter TB_PARTNER_RF1 = 1'b 0 ; //  Remote Fault Encoding
parameter TB_PARTNER_RF2 = 1'b 0 ; //  Remote Fault Encoding
parameter TB_PCS_PS1 = 1'b 1 ; //  Pause Support Encoding
parameter TB_PCS_PS2 = 1'b 0 ; //  Pause Support Encoding
parameter TB_PCS_RF1 = 1'b 0 ; //  Remote Fault Encoding
parameter TB_PCS_RF2 = 1'b 0 ; //  Remote Fault Encoding
parameter TB_ISOLATE = 1'b 0 ; //  Remote Fault Encoding
parameter TB_SGMII_ENA = 1'b 0 ; //  Enable SGMII Interface
parameter TB_SGMII_AUTO_CONF = 1'b 0 ; //  Enable SGMII Auto-Configuration
parameter TB_SGMII_1000 = 1'b 1 ; //  Enable SGMII Gigabit
parameter TB_SGMII_100 = 1'b 0 ; //  Enable SGMII 100Mbps
parameter TB_SGMII_10 = 1'b 0 ; //  Enable SGMII 10Mbps
parameter TB_SGMII_HD = 1'b 0 ; // Enable SGMII Half-Duplex Operation




reg     reset; 
reg     reset_model = 1'b0; 

//  PCS Status
//  ----------

wire    led_crs;                //  Carrier Sense
wire    led_link;               //  Valid Link
wire    hd_ena;                 //  Half-Duplex
wire    led_col;                //  Collision
wire    led_an;                 //  Auto-Negotiation Status
wire    led_char_err;           //  Character Error
wire    led_disp_err;           //  Disparity Error
wire    set_10;                 //  10Mbps Mode
wire    set_100;                //  100Mbps Mode
wire    set_1000;               //  1000Mbps Mode

wire    pcs_pwrdn_out;          //  Powerdown Control from pcs         
wire    gxb_pwrdn_in;           //  Powerdown Contril to GXB block  

// Reconfig

wire reconfig_clk;
wire reconfig_busy;
wire [3:0]	reconfig_togxb;

// Receive Recovered Clock

wire rx_recovclkout;


//  TBI Interface
//  -------------

wire    gmii_crs;               //  Carrier Sense           
wire    rx_sync;                //  Receiver Synchronized
wire    an_restart_rst;         //  Reset Autonegotiation Command        

//  GMII Receive
//  ------------

wire    gmii_rx_dv;              //  Enable
wire    [7:0] gmii_rx_d;         //  Data
wire    gmii_rx_err;             //  Error 

//  MII Receive
//  -----------

wire    mii_rx_dv;               //  Enable
wire    [3:0] mii_rx_d;          //  Data
wire    mii_rx_err;              //  Error 

//  Partner GMII Transmit
//  ---------------------

wire    part_gmii_txen;         //  Enable
wire    [7:0] part_gmii_txd;    //  Data
wire    part_gmii_txerr;        //  Error

//  Partner GMII Receive
//  --------------------

wire    part_gmii_rxdv;         //  Enable
wire    [7:0] part_gmii_rxd;    //  Data
wire    part_gmii_rxerr;        //  Error 

//  GMII Transmit
//  -------------

wire    gmii_tx_en;              //  Enable
wire    [7:0] gmii_tx_d;         //  Data
wire    gmii_tx_err;             //  Error

//  MII Transmit
//  ------------

wire    mii_tx_en;               //  Enable
wire    mii_txen_tmp;           //  Enable
wire    [7:0] mii_txd;          //  Data
wire    [3:0] mii_tx_d;          //  Data
wire    mii_tx_err;              //  Error
wire    mii_txerr_tmp;          //  Error  

//  Clocks
//  ------

reg     ref_clk;                //  Reference Clock
wire    rx_clk;                 //  GMII / MII Receive Clock 
wire    tx_clk;                 //  GMII / MII Transmit Clock       
wire    rx_clk_sig;             //  GMII / MII Receive Clock 
wire    tx_clk_sig;             //  GMII / MII Transmit Clock 
wire    rx_clkena;              //  GMII / MII Receive Clock Enable
wire    tx_clkena;              //  GMII / MII Transmit Clock Enable
reg     rx_en1;
reg     rx_en2;
reg     tx_en1;
reg     tx_en2; 

//  Autonegotiaition Signals
//  ------------------------

wire    an_enable;              //  Enable Autonegotiation
wire    an_restart;             //  Restart Autonegotiation        
wire    [15:0] an_ability;      //  Autonegotiation Ability Register
wire    an_done;                //  Autonegotiation Done
wire    an_ack;                 //  Acknowledge Indication
wire    [20:1] an_link_timer;   //  Link Timer Maximum Value
wire    page_receive;           //  Page Receive Indication
wire    [15:0] lp_ability;      //  Link Partner Ability Register
reg     [15:0] lp_ability_reg;  //  Link Partner Ability Register
wire    lp_ability_ena;         //  Link Partner Ability Valid
wire    [31:0] link_timer_reg;  //  Link Timer Value         

//  Model Configuration
//  -------------------

wire    [47:0] mac_dst;         //  Destination Address
wire    [47:0] mac_scr;         //  Source Address
wire    mac_reverse;            //  Reverse MAC Address
wire    [4:0] prmble_len;       //  Preamble Length
wire    [15:0] pquant;          //  Pause Quanta
wire    [15:0] vlan_ctl;        //  VLAN control info
wire    [15:0] frmtype;         //  if non-null: type field instead length      
wire    [7:0] cntstart;         //  payload data counter start (first byte of payload)
wire    [7:0] cntstep;          //  payload counter step (2nd byte in paylaod)
wire    [15:0] ipg_len;         //  inter packet gap (delay after CRC)                
wire    payload_err;            //  generate payload pattern error (last payload byte is wrong)
wire    prmbl_err;              //  Insert Preamble Error
wire    crc_err;                //  Insert CRC Error
wire    vlan_en;                //  Generate VLAN Frame
wire    pause_gen;              //  Generate Pause Frame
wire    pad_en;                 //  Pad Short Frames
wire    phy_err;                //  Insert GMII Error
wire    end_err;                //  keep rx_dv high one cycle after end of frame
wire    data_only;              //  if set omits preamble, padding, CRC
reg     [15:0] tx_len;          //  Length of payload
integer tx_len_tmp;

//  Register Interface
//  ------------------

reg     reg_clk;                        //  25MHz Host Interface Clock
reg     reg_rd;                         //  Register Read Strobe
reg     reg_wr;                         //  Register Write Strobe
reg     [4:0] reg_addr;                 //  Register Address
reg     [15:0] reg_data_in;             //  Write Data for Host Bus
wire    [15:0] reg_data_out;            //  Read Data to Host Bus
wire    reg_busy;                       //  Interface Busy
reg     reg_busy_reg;                   //  Interface Busy

//  Simulation Control
//  ------------------

reg     frm_gen_ena_gmii;       //  Enable Frame Genaration
reg     frm_gen_ena_mii;        //  Enable Frame Genaration
wire    frm_gen_done;           //  Frame Generation Done
wire    tx_sop_gmii;            //  Start of Generated Frame 
wire    tx_sop_mii;             //  Start of Generated Frame 
wire    frm_rcv_gmii;           //  Frame Receive
wire    frm_rcv_mii;            //  Frame Receive
wire    rx_crc_err_gmii;        //  CRC Error
wire    rx_crc_err_mii;         //  CRC Error
wire    rx_preamble_err;        //  Preamble Error
wire    rx_data_err;            //  Data Error
wire    rx_payload_vld;         //  Payload Valid
wire    rx_payload_vld_gmii;    //  Payload Valid
wire    rx_payload_vld_mii;     //  Payload Valid
integer end_cnt;                //  End of Simulation Pause
wire    [47:0] rx_dst;          //  Received Destination MAC address
wire    [47:0] rx_src;          //  Received Source MAC address
wire    [47:0] rx_dst_gmii;     //  Received Destination MAC address
wire    [47:0] rx_src_gmii;     //  Received Source MAC address
wire    [47:0] rx_dst_mii;      //  Received Destination MAC address
wire    [47:0] rx_src_mii;      //  Received Source MAC address
wire    rx_frm_err_mii;         //  Errored Frame Indication
wire    rx_frm_err_gmii;        //  Errored Frame Indication
reg     sim_start;              //  when to start simulation

//  Event Counters
//  --------------

integer tx_frm_cnt;             //  Number of Transmitted Frames
integer tx_gmii_err_cnt;        //  Number of GMII Error
integer rx_frm_cnt;             //  Number of Received Frames
integer rx_crc_err_cnt;         //  Number of CRC Error
integer rx_pbl_err_cnt;         //  Number of Premable Error
integer rx_dst_err_cnt;         //  Number of MAC Destination Address Error
integer rx_src_err_cnt;         //  Number of MAC Source Address Error
integer rx_gmii_err_cnt;        //  Number of GMII Error

//  Simulation Control
//  ------------------

parameter stm_typ_idle = 0;
parameter stm_typ_read_ver = 1;
parameter stm_typ_wr_scratch = 2;
parameter stm_typ_rd_scratch = 3;
parameter stm_typ_read_phy_control = 4;
parameter stm_typ_read_sync_status = 5;
parameter stm_typ_prog_ability = 6;
parameter stm_typ_prog_timer_1 = 7;
parameter stm_typ_prog_timer_2 = 8;
parameter stm_typ_autoneg_enable = 9;
parameter stm_typ_start_autoneg = 10;
parameter stm_typ_wait_autoneg = 11;
parameter stm_typ_read_autoneg_expansion = 12;
parameter stm_typ_read_autoneg_status = 13;
parameter stm_typ_read_part_ability = 14;
parameter stm_typ_wait_link = 15;
parameter stm_typ_sim = 16;
parameter stm_typ_stop_tbi = 17;
parameter stm_typ_start_tbi = 18;
parameter stm_typ_read_status = 19;
parameter stm_typ_read_status_2 = 20;
parameter stm_typ_ena_sw_reset = 21;
parameter stm_typ_read_sw_reset = 22;
parameter stm_typ_ena_isolate = 23;
parameter stm_typ_disable_isolate = 24;
parameter stm_typ_end_sim = 25;
parameter stm_typ_autoneg_disable = 26;
parameter stm_typ_if_control = 27;

reg     [4:0] state; 
reg     [4:0] nextstate; 
wire    gnd; 
wire    vcc; 
wire    mdio_wire; 



// register write/read test
//

reg [15:0] readback_scratch;

integer register_test;

assign gxb_pwrdn_in = 1'b 0;
assign reconfig_clk = ref_clk;
assign reconfig_busy = 1'b0;
assign reconfig_togxb = "0010";


assign gnd = 1'b 0; 
assign vcc = 1'b 1; 

//  Reset Control and start simulation
//  ----------------------------------
   
initial
begin

        $display("\n - ---------------------------------------------------------------------------------------- -") ;
        $display("\n -- Testbench for 1000Base-X PCS with SGMII + PMA --") ;
        $display(" --    (c) ALTERA CORPORATION 2007  --") ;
        $display("\n - ---------------------------------------------------------------------------------------- -\n") ; 
   
   
        reset       <=1'b0 ;
        sim_start   <=1'b0 ;
        #(50)
        reset       <=1'b1 ;
        #(2000) ;
        reset<=1'b0 ;
        #(3000) ;
        sim_start   <=1'b1 ;

end


// Clock generation for Gigabit and 10/100 operations
always @(posedge reset or posedge rx_clk)
   begin
	   if (reset == 1'b1) begin
	   rx_en1 <= 1'b0;
	   rx_en2 <= 1'b0;
	   end
	   else begin
		    rx_en1 <= rx_clkena;
			rx_en2 <= rx_en1;
	   end
   end 
   
always @(posedge reset or posedge tx_clk)
   begin
	   if (reset == 1'b1) begin
	   tx_en1 <= 1'b0;
	   tx_en2 <= 1'b0;
	   end
	   else begin
		    tx_en1 <= tx_clkena;
			tx_en2 <= tx_en1;
	   end
   end 

// For testbench purposes, the clock enable of the 125MHz clock is used to mimic the 2.5/25MHz clock with a short duty cycle . 
assign rx_clk_sig = (ENABLE_SGMII == 0)|(rx_en1 == 1'b1 && rx_en2 == 1'b1) ? rx_clk : rx_clkena;   
assign tx_clk_sig = (ENABLE_SGMII == 0)|(tx_en1 == 1'b1 && tx_en2 == 1'b1) ? tx_clk : tx_clkena; 


	sgmii dut (
	 .gmii_rx_d(gmii_rx_d),
	 .gmii_rx_dv(gmii_rx_dv),
	 .gmii_rx_err(gmii_rx_err),
	 .gmii_tx_d(gmii_tx_d),
	 .gmii_tx_en(gmii_tx_en),
	 .gmii_tx_err(gmii_tx_err),
	 .tx_clk(tx_clk),
	 .rx_clk(rx_clk),
	 .mii_rx_d(mii_rx_d),
	 .mii_rx_dv(mii_rx_dv),
	 .mii_rx_err(mii_rx_err),
	 .mii_tx_d(mii_tx_d),
	 .mii_tx_en(mii_tx_en),
	 .mii_tx_err(mii_tx_err),
	 .mii_col(),
	 .mii_crs(),
	 .set_10(),
	 .set_100(set_100),
	 .set_1000(),
	 .hd_ena(hd_ena),
	 .reset_tx_clk(reset),
	 .reset_rx_clk(reset),
	 .led_col(),
	 .led_crs(led_crs),
	 .led_an(led_an),
	 .tx_clkena(tx_clkena),
	 .rx_clkena(rx_clkena),
	 .rx_recovclkout(rx_recovclkout),
	 .address(reg_addr),
	 .readdata(reg_data_out),
	 .read(reg_rd),
	 .writedata(reg_data_in),
	 .write(reg_wr),
	 .waitrequest(reg_busy),
	 .clk(reg_clk),
	 .reset(reset),
	 .txp(txp),
	 .rxp(rxp),
	 .ref_clk(ref_clk),
	 .gxb_pwrdn_in(gxb_pwrdn_in),
	 .pcs_pwrdn_out(pcs_pwrdn_out),
	 .reconfig_clk(reconfig_clk),
	 .reconfig_togxb(reconfig_togxb),
	 .reconfig_fromgxb(reconfig_fromgxb),
	 .reconfig_busy(reconfig_busy),
	 .led_disp_err(led_disp_err),
	 .led_link(led_link),
	 .led_char_err(led_char_err),
	 .gxb_cal_blk_clk(ref_clk)
	);


assign rxp = txp;
assign mii_tx_d = mii_txd[3:0] ;
                
//  Clocks
//  ------

always 
   begin : process_2
   ref_clk <= 1'b 1;   
   #(4); 
   ref_clk <= 1'b 0;   
   #(4); 
   end             
   
always 
   begin : process_3
   reg_clk <= 1'b 1;   
   #(20); 
   reg_clk <= 1'b 0;   
   #(20); 
   end 

always @(posedge reset or posedge reg_clk)
   begin : process_5
   
   if (reset==1'b1)
   begin
   
        reg_wr <= #(2)1'b 0;    
        reg_rd <= #(2)1'b 0;    
        reg_addr <= #(2) {5{1'b 0}};    
        reg_data_in <= #(2)  {16{1'b 0}};
        
   end
   
   else if (nextstate == stm_typ_read_ver)
      begin
      reg_addr  <= 5'b 10001;   
      reg_rd  <= 1'b 1;   
      reg_wr <= 1'b 0;   
      reg_data_in   <= 16'h 0000;   
      end
   else if (nextstate == stm_typ_if_control )
      begin
      reg_addr  <= 5'b 10100;   
      reg_rd    <= 1'b 0;   
      reg_wr    <= 1'b 1;  
      
       if (TB_SGMII_ENA==1'b1)
       begin
       
        reg_data_in[0] <= 1'b1;
        
       end
       else
       begin
       
        reg_data_in[0] <= 1'b0;
        
       end
       
       if (TB_SGMII_AUTO_CONF==1'b1)
       begin
       
        reg_data_in[1] <= 1'b1;
        
       end
       else
       begin
       
        reg_data_in[1] <= 1'b0;
        
       end
       
       if (TB_SGMII_AUTO_CONF==1'b1)
       begin
       
        reg_data_in[3:2] <= 2'b00;
        
       end         
       else if (TB_SGMII_1000==1'b1)
       begin
       
        reg_data_in[3:2] <= 2'b10;
        
       end
       else if (TB_SGMII_100==1'b1)
       begin
       
        reg_data_in[3:2] <= 2'b01;
        
       end
       else
       begin
       
        reg_data_in[3:2] <= 2'b00;
        
       end
       
       if (TB_SGMII_HD==1'b1)
       begin
      
                reg_data_in[4] <= 1'b1;
                
       end
       else
       begin
       
                reg_data_in[4] <= 1'b0;
                
       end
       
      reg_data_in[15:5]   <= 0;   
      end
   else if (nextstate == stm_typ_wr_scratch )
      begin
      reg_addr  <= 5'b 10000;   
      reg_rd  <= 1'b 0;   
      reg_wr <= 1'b 1;   
      reg_data_in   <= 16'h AAAA;   
      end
   else if (nextstate == stm_typ_rd_scratch )
      begin
      reg_addr  <= 5'b 10000;   
      reg_rd  <= 1'b 1;   
      reg_wr <= 1'b 0;   
      reg_data_in   <= 16'h 0;   
      end
   else if (nextstate == stm_typ_read_sync_status | nextstate == stm_typ_read_status | 
      nextstate == stm_typ_read_status_2 )
      begin
      reg_addr  <= 5'b 00001;   
      reg_rd  <= 1'b 1;   
      reg_wr <= 1'b 0;   
      reg_data_in   <= 16'h 0;   
      end
   else if (nextstate == stm_typ_read_phy_control )
      begin
      reg_addr  <= 5'b 00000;   
      reg_rd  <= 1'b 1;   
      reg_wr <= 1'b 0;   
      reg_data_in   <= 16'h 0;   
      end
   else if (nextstate == stm_typ_prog_ability )
      begin
      reg_addr     <= 5'b 00100;   
      reg_rd     <= 1'b 0;   
      reg_wr    <= 1'b 1;   
      reg_data_in[4:0] <= {5{1'b 0}};   
      reg_data_in[5]   <= 1'b 1;   
      reg_data_in[6]   <= 1'b 0;   
      if (TB_PCS_PS1)
         begin
         reg_data_in[7] <= 1'b 1;   
         end
      else
         begin
         reg_data_in[7] <= 1'b 0;   
         end
      if (TB_PCS_PS2)
         begin
         reg_data_in[8] <= 1'b 1;   
         end
      else
         begin
         reg_data_in[8] <= 1'b 0;   
         end
      reg_data_in[11:9] <= {3{1'b 0}};   
      if (TB_PCS_RF1)
         begin
         reg_data_in[12] <= 1'b 1;   
         end
      else
         begin
         reg_data_in[12] <= 1'b 0;   
         end
      if (TB_PCS_RF2)
         begin
         reg_data_in[13] <= 1'b 1;   
         end
      else
         begin
         reg_data_in[13] <= 1'b 0;   
         end
      reg_data_in[15:14] <= {2{1'b 0}};   
      end
   else if (nextstate == stm_typ_prog_timer_1 )
      begin
      reg_addr <= 5'b 10010;   
      reg_rd <= 1'b 0;   
      reg_wr <= 1'b 1;   
      reg_data_in <= link_timer_reg[15:0];   
      end
   else if (nextstate == stm_typ_prog_timer_2 )
      begin
      reg_addr  <= 5'b 10011;   
      reg_rd  <= 1'b 0;   
      reg_wr <= 1'b 1;   
      reg_data_in   <= link_timer_reg[31:16];   
      end
   else if (nextstate == stm_typ_autoneg_enable )
      begin
      reg_addr  <= 5'b 00000;   
      reg_rd  <= 1'b 0;   
      reg_wr <= 1'b 1;   
      reg_data_in   <= 16'b 0001000000100000;   
      end
   else if (nextstate == stm_typ_autoneg_disable )
      begin
      reg_addr  <= 5'b 00000;   
      reg_rd  <= 1'b 0;   
      reg_wr <= 1'b 1;   
      reg_data_in   <= 16'b 000001000100000;   
      end
   else if (nextstate == stm_typ_start_autoneg )
      begin
      reg_addr  <= 5'b 00000;   
      reg_rd  <= 1'b 0;   
      reg_wr <= 1'b 1;   
      reg_data_in   <= 16'b 001001000100000;   
      end
   else if (nextstate == stm_typ_read_part_ability )
      begin
      reg_addr  <= 5'b 00101;   
      reg_rd  <= 1'b 1;   
      reg_wr <= 1'b 0;   
      reg_data_in   <= 16'h 0;   
      end
   else if (nextstate == stm_typ_read_autoneg_status )
      begin
      reg_addr  <= 5'b 00001;   
      reg_rd  <= 1'b 1;   
      reg_wr <= 1'b 0;   
      reg_data_in   <= 16'h 0;   
      end
   else if (nextstate == stm_typ_read_autoneg_expansion )
      begin
      reg_addr  <= 5'b 00110;   
      reg_rd  <= 1'b 1;   
      reg_wr <= 1'b 0;   
      reg_data_in   <= 16'h 0;   
      end
   else if (nextstate == stm_typ_ena_sw_reset )
      begin
      reg_addr  <= 5'b 00000;   
      reg_rd  <= 1'b 0;   
      reg_wr <= 1'b 1;   
      reg_data_in   <= 16'h 0;   
      end
   else if (nextstate == stm_typ_read_sw_reset )
      begin
      reg_addr  <= 5'b 00000;   
      reg_rd  <= 1'b 1;   
      reg_wr <= 1'b 0;   
      reg_data_in   <= 16'h 0;   
      end
   else if (nextstate == stm_typ_ena_isolate )
      begin
      reg_addr  <= 5'b 00000;   
      reg_rd  <= 1'b 0;   
      reg_wr <= 1'b 1;   
      reg_data_in   <= 16'h 0;   
      end
   else if (nextstate == stm_typ_disable_isolate )
      begin
      reg_addr  <= 5'b 00000;   
      reg_rd  <= 1'b 0;   
      reg_wr <= 1'b 1;   
      reg_data_in   <= 16'h 0;   
      end
   else
      begin
      reg_addr  <= 5'b 00000;   
      reg_rd  <= 1'b 0;   
      reg_wr <= 1'b 0;   
      reg_data_in   <= 16'h 0;   
      end
   end


always @(led_link)
   begin : process_11
   if (led_link == 1'b 1)
   begin
   
        $display("  - Link Acquired\n:") ;
        
   end
   else if (led_link == 1'b 0 & $time>10)
   begin
   
        $display("  - Link Lost\n:") ;

   end

end

//  Ethernet Frame Generator Configuration
//  --------------------------------------

assign mac_dst          = 48'h AABBCCDDEEFF; 
assign mac_scr          = 48'h 112233445566; 
assign prmble_len       = 5'b 01000; 
assign pquant           = 16'h 0000; 
assign vlan_ctl         = 16'h 0000; 
assign frmtype          = 16'h 0000; 
assign cntstart         = 2'b 10; 
assign cntstep          = 1'b 1; 
assign ipg_len          = TB_TXIPG; 
assign payload_err      = 1'b 0; 
assign prmbl_err        = 1'b 0; 
assign crc_err          = 1'b 0; 
assign vlan_en          = 1'b 0; 
assign pause_gen        = 1'b 0; 
assign pad_en           = 1'b 1; 
assign phy_err          = tx_frm_cnt % 10 == 5 & TB_TX_ERR ? 1'b 1 : 1'b 0; 
assign end_err          = 1'b 0; 
assign data_only        = 1'b 0; 
assign mac_reverse      = 1'b 0;

assign mii_tx_en  = (led_link==1'b1) ? mii_txen_tmp  : 1'b0 ;
assign mii_tx_err = (led_link==1'b1) ? mii_txerr_tmp : 1'b0 ;

ethgenerator2 #(4) U_FRM_GEN2 (

          .reset(reset),       
          .rx_clk(tx_clk_sig),       
          .rxd(mii_txd),             
          .rx_dv(mii_txen_tmp),          
          .rx_er(mii_txerr_tmp),         
          .sop(tx_sop_mii),          
          .eop(),                    
          .ethernet_speed(1'b0),
          .carrier_sense(1'b0),
          .false_carrier(1'b0),
          .carrier_extend(1'b0),
          .carrier_extend_error(1'b0),
          .mii_mode(1'b1),           
          .rgmii_mode(1'b0),         
          .mac_reverse(mac_reverse), 
          .dst(mac_dst),             
          .src(mac_scr),             
          .prmble_len(prmble_len),   
          .pquant(pquant),           
          .vlan_ctl(vlan_ctl),       
          .len(tx_len),              
          .frmtype(frmtype),         
          .cntstart(cntstart),       
          .cntstep(cntstep),         
          .ipg_len(ipg_len),         
          .payload_err(payload_err), 
          .prmbl_err(prmbl_err),     
          .crc_err(crc_err),         
          .vlan_en(1'b0),            
          .stack_vlan(1'b0),         
          .pause_gen(pause_gen),     
          .pad_en(pad_en),           
          .phy_err(phy_err),         
          .end_err(end_err), 
          .data_only(data_only),     
          .start(frm_gen_ena_mii),   
          .done(frm_gen_done_mii));  

ethgenerator #(4) U_FRM_GEN (

          .reset(reset),
          .rx_clk(tx_clk_sig),
          .rxd(gmii_tx_d),
          .enable(1'b1),
          .carrier_sense(1'b0),
          .false_carrier(1'b0),
          .carrier_extend(1'b0),
          .carrier_extend_error(1'b0),
          .rx_dv(gmii_tx_en),
          .rx_er(gmii_tx_err),
          .sop(tx_sop_gmii),
          .eop(),
          .mac_reverse(mac_reverse),
          .dst(mac_dst),
          .src(mac_scr),
          .prmble_len(prmble_len),
          .pquant(pquant),
          .vlan_ctl(vlan_ctl),
          .len(tx_len),
          .frmtype(frmtype),
          .cntstart(cntstart),
          .cntstep(cntstep),
          .ipg_len(ipg_len),
          .payload_err(payload_err),
          .prmbl_err(prmbl_err),
          .crc_err(crc_err),
          .vlan_en(1'b0),
          .pause_gen(pause_gen),
          .pad_en(pad_en),
          .phy_err(phy_err),
          .end_err(end_err),
          .data_only(data_only),
          .stack_vlan(1'b0),
          .runt_gen(1'b 0),
          .long_pause(1'b 0),
          .start(frm_gen_ena_gmii),
          .done(frm_gen_done_gmii));

always @(posedge reset or posedge tx_clk_sig)
   begin : process_13
   if (reset == 1'b 1)
      begin
      frm_gen_ena_gmii <= 1'b 0;  
      frm_gen_ena_mii  <= 1'b 0;  
      end
   else
      begin
      
        if ((TB_SGMII_ENA==1'b0)|(TB_SGMII_ENA==1'b1 & TB_SGMII_1000==1'b1))
        begin
        
                frm_gen_ena_mii <= 1'b 0;
      
                if (tx_frm_cnt >= TB_TXFRAMES)
                begin
                        frm_gen_ena_gmii <= 1'b 0;   
                end
                else if (state == stm_typ_sim & (tx_frm_cnt < TB_TXFRAMES) )
                begin
                        frm_gen_ena_gmii <= #200 1'b 1;   
                end
        
        end
        else
        begin
        
                frm_gen_ena_gmii <= 1'b 0;
      
                if (tx_frm_cnt >= TB_TXFRAMES)
                begin
                        frm_gen_ena_mii <= 1'b 0;   
                end
                else if (state == stm_typ_sim & (tx_frm_cnt < TB_TXFRAMES) )
                begin
                        frm_gen_ena_mii <= #20 1'b 1;   
                end
        
        end
        
      end
   end
   
//  Frame Length
//  ------------

//  Ethernet Generator Enable / Disable
//  -----------------------------------

always @(posedge reset or posedge tx_clk_sig)
   begin : process_14
   if (reset == 1'b 1)
      begin
      tx_len     <= TB_LENSTART;
      tx_len_tmp = 0 ;   
      end
   else
      begin
      
      tx_len_tmp = tx_len + TB_LENSTEP ;
      
      if (tx_sop_gmii == 1'b 1 | tx_sop_mii == 1'b1)
         begin
         if (tx_len_tmp <= 46)
            begin
            tx_len <= TB_LENMAX;   
            end  
         else if (tx_len_tmp >= TB_MACLENMAX)
            begin
            tx_len <= TB_LENSTART;   
            end
         else
            begin
            tx_len <= tx_len_tmp;   
            end
         end
      end
   end

//  Transmit Frame Counter                     
//  ----------------------             

always @(posedge reset or posedge tx_clk_sig)
   begin : process_15
   if (reset == 1'b 1)
      begin
      tx_frm_cnt <= 0;   
      end
   else
      begin
      if (tx_sop_gmii == 1'b 1 | tx_sop_mii == 1'b1)
         begin
         tx_frm_cnt <= tx_frm_cnt + 1'b 1;   
         end
      end
   end

always @(posedge reset or posedge tx_clk_sig)
   begin : process_16
   if (reset == 1'b 1)
      begin
      tx_gmii_err_cnt <= 0;   
      end
   else
      begin
      if ((tx_sop_gmii == 1'b 1 | tx_sop_mii == 1'b1) & phy_err == 1'b 1)
         begin
         tx_gmii_err_cnt <= tx_gmii_err_cnt + 1'b 1;   
         end
      end
   end

//  Receive Model
//  -------------

ethmonitor2 U_MON2 (

          .reset(reset),
          .tx_clk(rx_clk_sig),
          .txd({4'b0, mii_rx_d}),
          .tx_dv(mii_rx_dv),
          .tx_er(mii_rx_err),
          .tx_sop(1'b 0),
          .tx_eop(1'b 0),
          .ethernet_speed(1'b0),
          .mii_mode(1'b1),
          .rgmii_mode(1'b0),
          .dst(rx_dst_mii),
          .src(rx_src_mii),
          .prmble_len(),
          .pquant(),
          .vlan_ctl(),
          .len(),
          .frmtype(),
          .payload(),
          .payload_vld(rx_payload_vld_mii),
          .is_vlan(),
          .is_pause(),
          .crc_err(rx_crc_err_mii),
          .prmbl_err(rx_preamble_err),
          .len_err(),
          .payload_err(rx_data_err),
          .frame_err(),
          .pause_op_err(),
          .pause_dst_err(),
          .mac_err(rx_frm_err_gmii),
          .end_err(),
          .jumbo_en(1'b 1),
          .data_only(1'b 0),
          .is_stack_vlan(),
          .frm_rcvd(frm_rcv_mii));

ethmonitor U_MON (

          .reset(reset),
          .tx_clk(rx_clk_sig),
          .txd(gmii_rx_d),
          .tx_dv(gmii_rx_dv),
          .tx_er(gmii_rx_err),
          .tx_sop(1'b 0),
          .tx_eop(1'b 0),
          .dst(rx_dst_gmii),
          .src(rx_src_gmii),
          .prmble_len(),
          .pquant(),
          .vlan_ctl(),
          .len(),
          .frmtype(),
          .payload(),
          .payload_vld(rx_payload_vld_gmii),
          .is_vlan(),
          .is_pause(),
          .crc_err(rx_crc_err_gmii),
          .prmbl_err(rx_preamble_err),
          .len_err(),
          .payload_err(rx_data_err),
          .frame_err(),
          .pause_op_err(),
          .pause_dst_err(),
          .mac_err(rx_frm_err_mii),
          .end_err(),
          .jumbo_en(1'b 1),
          .data_only(1'b 0),
          .is_stack_vlan(),
          .frm_rcvd(frm_rcv_gmii));
          
assign rx_dst         = ((TB_SGMII_ENA==1'b0) | (TB_SGMII_ENA==1'b1 & TB_SGMII_1000==1'b1)) ? rx_dst_gmii         : rx_dst_mii ;
assign rx_src         = ((TB_SGMII_ENA==1'b0) | (TB_SGMII_ENA==1'b1 & TB_SGMII_1000==1'b1)) ? rx_src_gmii         : rx_src_mii ;
assign rx_payload_vld = ((TB_SGMII_ENA==1'b0) | (TB_SGMII_ENA==1'b1 & TB_SGMII_1000==1'b1)) ? rx_payload_vld_gmii : rx_payload_vld_mii ;

always @(posedge reset or posedge rx_clk_sig)
   begin : process_17
   if (reset == 1'b 1)
      begin
      rx_frm_cnt      <= 0;   
      rx_crc_err_cnt  <= 0;   
      rx_pbl_err_cnt  <= 0;   
      rx_gmii_err_cnt <= 0;
      rx_src_err_cnt  <= 0;
      rx_dst_err_cnt  <= 0;
      end
   else
      begin

   //  Number of Frames Received
   //  -------------------------
   
      if ((frm_rcv_gmii == 1'b 1 | frm_rcv_mii == 1'b 1)&tx_frm_cnt>0)
         begin
         rx_frm_cnt <= rx_frm_cnt + 1'b 1;   
         end

   //  Number of CRC Errors
   //  --------------------
   
      if (TB_SGMII_1000==1'b1 | (TB_SGMII_ENA==1'b0))
      begin
   
                if (frm_rcv_gmii == 1'b 1 & rx_crc_err_gmii == 1'b 1 & rx_frm_err_gmii == 1'b 0)
                begin
                        rx_crc_err_cnt <= rx_crc_err_cnt + 1'b 1;   
         
                        $display(" - GMII Rx: CRC Error on Frame\n:") ;
         
                end
                
      end
      else
      begin
      
                if (frm_rcv_mii == 1'b 1 & rx_crc_err_mii == 1'b 1 & rx_frm_err_mii == 1'b 0 & rx_frm_cnt>0)
                begin
                        rx_crc_err_cnt <= rx_crc_err_cnt + 1'b 1;   
         
                        $display(" - MII Rx: CRC Error on Frame\n:") ;
         
                end
                
      end

   //  Number of GMII Errors
   //  ---------------------
   
      if ((frm_rcv_gmii == 1'b 1 | frm_rcv_mii == 1'b 1) & (rx_frm_err_mii == 1'b 1 | rx_frm_err_gmii == 1'b1) & rx_frm_cnt>0)
         begin
         rx_gmii_err_cnt <= rx_gmii_err_cnt + 1'b 1;   
         
         $display(" - MII / GMII Rx: GMII Error on Frame\n:") ;
         
         end

   //  Number of Preamble Errors
   //  -------------------------
   
      if (rx_preamble_err == 1'b 1)
         begin
         rx_pbl_err_cnt <= rx_pbl_err_cnt + 1'b 1; 
         
         $display(" - MII / GMII Rx: Preamble Error on Frame\n:") ;
           
         end

   //  Number of Source MAC Address Errors
   //  -----------------------------------
   
      if ((frm_rcv_gmii == 1'b 1 | frm_rcv_mii == 1'b 1) & rx_src != mac_scr & (rx_frm_err_mii == 1'b0 & rx_frm_err_gmii==1'b0) & 
           TB_SGMII_10==1'b0 & tx_frm_cnt>0)
         begin
         rx_src_err_cnt <= rx_src_err_cnt + 1'b 1; 
         
         $display(" - MII / GMII Rx: Wrong Source MAC Address on Frame\n:") ;
           
         end

   //  Number of Source MAC Address Errors
   //  -----------------------------------
   
      if ((frm_rcv_gmii == 1'b 1 | frm_rcv_mii == 1'b 1) & rx_dst != mac_dst & (rx_frm_err_mii == 1'b 0 & rx_frm_err_gmii == 1'b0) & 
           TB_SGMII_10==1'b0 & tx_frm_cnt>0)
         begin
         rx_dst_err_cnt <= rx_dst_err_cnt + 1'b 1;
         
         $display(" - MII / GMII Rx: Wrong Destination MAC Address on Frame\n:") ;
            
         end

   //  Data Error
   //  ----------
   
      if (rx_data_err == 1'b 1 & rx_payload_vld == 1'b 1)
         begin
      
                $display(" - GMII Rx: Data Error on Frame\n:") ;
                
         end

      end
   end

//  Simulation Control
//  ------------------

always@(posedge reset or posedge reg_clk)
begin

        if (reset==1'b1)
        begin
                
                reg_busy_reg <= 1'b0 ;
                
        end
        else
        
                reg_busy_reg <= reg_busy ;
                
        end

always @(posedge reset or posedge reg_clk)
   begin : process_18
   if (reset == 1'b 1)
      begin
      state <= stm_typ_idle;   
      end
   else
      begin
      state <= nextstate;   
      end
   end

always @(state or sim_start or reg_busy_reg or reg_busy or an_done or led_link or rx_frm_cnt or end_cnt or led_an)
   begin : process_19
   case (state)
   stm_typ_idle:
      begin
      if (sim_start==1'b1)
      begin
      nextstate <= stm_typ_read_ver;   
      end
      else
       begin
         nextstate   <= stm_typ_idle ;
      end 
      end
   stm_typ_read_ver:
      begin
      if (reg_busy == 1'b 0 && reg_busy_reg == 1'b1)
         begin
         nextstate <= stm_typ_wr_scratch;   
         end
      else
         begin
         nextstate <= stm_typ_read_ver;   
         end
      end
   stm_typ_wr_scratch:
      begin
      if (reg_busy == 1'b 0 && reg_busy_reg == 1'b1)
         begin
         nextstate <= stm_typ_rd_scratch;   
         end
      else
         begin
         nextstate <= stm_typ_wr_scratch;   
         end
      end
   stm_typ_rd_scratch:
      begin
      if (reg_busy == 1'b 0 && reg_busy_reg == 1'b1)
         begin
         nextstate <= stm_typ_if_control;   
         end
      else
         begin
         nextstate <= stm_typ_rd_scratch;   
         end
      end
   stm_typ_if_control:
      begin
      if (reg_busy == 1'b 0 && reg_busy_reg == 1'b1)
         begin
         
                nextstate <= stm_typ_wait_link; 
                                          
         end
      else
         begin
         nextstate <= stm_typ_if_control;   
         end
      end
   stm_typ_wait_link:
      begin
      if (led_link == 1'b 1)
         begin
         nextstate <= stm_typ_read_phy_control;   
         end
      else
         begin
         nextstate <= stm_typ_wait_link;   
         end
      end
   stm_typ_read_phy_control:
      begin
      if (reg_busy == 1'b 0 && reg_busy_reg == 1'b1)
         begin
         nextstate <= stm_typ_read_sync_status;   
         end
      else
         begin
         nextstate <= stm_typ_read_phy_control;   
         end
      end
   stm_typ_read_sync_status:
      begin
      if (reg_busy == 1'b 0 && reg_busy_reg == 1'b1)
         begin
         if (TB_ENA_AUTONEG)
            begin
            nextstate <= stm_typ_prog_ability;   
            end
         else
            begin
            nextstate <= stm_typ_autoneg_disable;   
            end
         end
      else
         begin
         nextstate <= stm_typ_read_sync_status;   
         end
      end
   stm_typ_autoneg_disable:
      begin
      if (reg_busy == 1'b 0 && reg_busy_reg == 1'b1)
         begin
         nextstate <= stm_typ_sim;   
         end
      else
         begin
         nextstate <= stm_typ_autoneg_disable;   
         end
      end
   stm_typ_prog_ability:
      begin
      if (reg_busy == 1'b 0 && reg_busy_reg == 1'b1)
         begin
         nextstate <= stm_typ_prog_timer_1;   
         end
      else
         begin
         nextstate <= stm_typ_prog_ability;   
         end
      end
   stm_typ_prog_timer_1:
      begin
      if (reg_busy == 1'b 0 && reg_busy_reg == 1'b1)
         begin
         nextstate <= stm_typ_prog_timer_2;   
         end
      else
         begin
         nextstate <= stm_typ_prog_timer_1;   
         end
      end
   stm_typ_prog_timer_2:
      begin
      if (reg_busy == 1'b 0 && reg_busy_reg == 1'b1)
         begin
         nextstate <= stm_typ_autoneg_enable;   
         end
      else
         begin
         nextstate <= stm_typ_prog_timer_2;   
         end
      end
   stm_typ_autoneg_enable:
      begin
      if (reg_busy == 1'b 0 && reg_busy_reg == 1'b1)
         begin
         nextstate <= stm_typ_start_autoneg;   
         end
      else
         begin
         nextstate <= stm_typ_autoneg_enable;   
         end
      end
   stm_typ_start_autoneg:
      begin
      if (reg_busy == 1'b 0 && reg_busy_reg == 1'b1)
         begin
         nextstate <= stm_typ_wait_autoneg;   
         end
      else
         begin
         nextstate <= stm_typ_start_autoneg;   
         end
      end
   stm_typ_wait_autoneg:
      begin
      if (an_done == 1'b 1 & led_an==1'b1)
         begin
         nextstate <= stm_typ_read_autoneg_expansion;   
         end
      else
         begin
         nextstate <= stm_typ_wait_autoneg;   
         end
      end
   stm_typ_read_autoneg_expansion:
      begin
      if (reg_busy == 1'b 0 && reg_busy_reg == 1'b1)
         begin
         nextstate <= stm_typ_read_autoneg_status;   
         end
      else
         begin
         nextstate <= stm_typ_read_autoneg_expansion;   
         end
      end
   stm_typ_read_autoneg_status:
      begin
      if (reg_busy == 1'b 0 && reg_busy_reg == 1'b1)
         begin
         nextstate <= stm_typ_read_part_ability;   
         end
      else
         begin
         nextstate <= stm_typ_read_autoneg_status;   
         end
      end
   stm_typ_read_part_ability:
      begin
      if (reg_busy == 1'b 0 && reg_busy_reg == 1'b1)
         begin
         nextstate <= stm_typ_sim;   
         end
      else
         begin
         nextstate <= stm_typ_read_part_ability;   
         end
      end
   stm_typ_sim:
      begin
      if (rx_frm_cnt == TB_TXFRAMES)
         begin
         
                nextstate <= stm_typ_end_sim;
                   
         end
      else
         begin
         nextstate <= stm_typ_sim;   
         end
      end
   stm_typ_stop_tbi:
      begin
      if (end_cnt > 500)
         begin
         nextstate <= stm_typ_ena_sw_reset;   
         end
      else
         begin
         nextstate <= stm_typ_stop_tbi;   
         end
      end

   stm_typ_ena_sw_reset:
      begin
      if (reg_busy == 1'b 0 && reg_busy_reg == 1'b1)
         begin
         nextstate <= stm_typ_read_sw_reset;   
         end
      else
         begin
         nextstate <= stm_typ_ena_sw_reset;   
         end
      end
   stm_typ_read_sw_reset:
      begin
      if (reg_busy == 1'b 0 && reg_busy_reg == 1'b1)
         begin
         nextstate <= stm_typ_start_tbi;   
         end
      else
         begin
         nextstate <= stm_typ_read_sw_reset;   
         end
      end
   stm_typ_start_tbi:
      begin
      nextstate <= stm_typ_read_status;   
      end      
   stm_typ_read_status:
      begin
      if (reg_busy == 1'b 0 && reg_busy_reg == 1'b1)
         begin
         nextstate <= stm_typ_read_status_2;   
         end
      else
         begin
         nextstate <= stm_typ_read_status;   
         end
      end
   stm_typ_read_status_2:
      begin
      if (reg_busy == 1'b 0 && reg_busy_reg == 1'b1)
         begin
         if (TB_ISOLATE==1'b1)
            begin
            nextstate <= stm_typ_read_status;   
            end
         else
            begin
            nextstate <= stm_typ_end_sim;   
            end
         end
      else
         begin
         nextstate <= stm_typ_read_status_2;   
         end
      end      

   stm_typ_disable_isolate:
      begin
      if (reg_busy == 1'b 0 && reg_busy_reg == 1'b1)
         begin
         nextstate <= stm_typ_end_sim;   
         end
      else
         begin
         nextstate <= stm_typ_disable_isolate;   
         end
      end
   stm_typ_end_sim:
      begin
      nextstate <= stm_typ_end_sim;   
      end
   endcase
   end

//  Simulation Status
//  -----------------

always @(negedge reg_clk)
   begin : process_20
      if (state == stm_typ_read_ver & reg_busy == 1'b 0 && reg_busy_reg == 1'b1)
      begin
   
    $display(" - Altera Design Version : %0d.%0d ", reg_data_out[15:8], reg_data_out[7:0] ) ;
          
      end
      else if (state == stm_typ_rd_scratch & reg_busy == 1'b 0 && reg_busy_reg == 1'b1 )
      begin
        readback_scratch <= reg_data_out;  
        $display("   - Read Scratch Register : 0x%h", reg_data_out, "\n") ;

      end
      else if ((state == stm_typ_read_sync_status | state == stm_typ_read_status | state == stm_typ_read_status_2) & reg_busy == 1'b 0 && reg_busy_reg == 1'b1 )
      begin
      
        $display("   - Check Link Status : \n") ;

        if (reg_data_out[2] == 1'b 1)
        begin
        
                $display("              Link Acquired\n") ;
                
        end
        else
        begin
        
                $display("              Link not Acquired\n") ;
                
        end
     end
     else if (state == stm_typ_read_sw_reset & reg_busy == 1'b 0 && reg_busy_reg == 1'b1 )
     begin
     
        $display("   - Check if Self-Clearing MDIO Reset Bit is Cleared : \n") ;
        
        if (reg_data_out[15] == 1'b 1)
        begin
        
                $display("              Reset Command bit not Cleared\n") ; 
                
        end
        else
        begin  
        
                $display("              Reset Command bit Correctly Cleared\n") ;
                
        end      
     end
     else if (state == stm_typ_read_phy_control & reg_busy == 1'b 0 && reg_busy_reg == 1'b1 )
     begin
     
        $display("   - Checking PCS Capabilies (MDIO Control Register):0x%h", reg_data_out)  ;

        if (reg_data_out[6] == 1'b 1 & reg_data_out[13] == 1'b 0)
        begin
        
                $display("              Speed: 1000Mbps\n") ; 
                
        end
        else
        begin 
        
                $display("              Speed: ERROR\n") ; 
                
        end   
     
        if (reg_data_out[7] == 1'b 0)
        begin
     
                $display("              Colision Test: Not Supported\n") ;
                
        end
        else
        begin
        
                $display("              Colision Test: ERROR\n") ;  
                
        end
     end       
     else if (state == stm_typ_read_autoneg_expansion & reg_busy == 1'b 0 && reg_busy_reg == 1'b1 )
     begin
      
        if (reg_data_out[2] == 1'b 1)
        begin
        
                $display("              Page(s) Received from Link Partner\n") ;
                
        end
        else
        begin
        
                $display("              Page NOT Received from Link Partner\n") ;  
                
        end
     end              
     else if (state == stm_typ_read_autoneg_status & reg_busy == 1'b 0 && reg_busy_reg == 1'b1 )
     begin
     
        if (reg_data_out[5] == 1'b 1)
        begin
        
                $display("              Auto-Negotiation Completed\n") ;  
                
        end
        else
        begin
        
                $display("              Auto-Negotiation Not Completed\n") ;
                
        end
     end              
     else if (state == stm_typ_read_part_ability & reg_busy == 1'b 0 && reg_busy_reg == 1'b1 )
     begin
     
        $display("   - Advertised Link Partner Ability:\n") ;
        
        if (TB_SGMII_ENA==1'b0)
        begin
        
                if (reg_data_out[15] == 1'b 1)
                begin
        
                        $display("              Link Partner Supports Next Page\n") ; 
                
                end
                else
                begin
        
                        $display("              Link Partner does not Support Next Page\n") ;
                
                end               

                if (reg_data_out[8:7] == 2'b 11)
                begin
        
                        $display("              Link Partner Advertises Symetric and Asymetric Pause Support\n") ;
                
                end        
                else if (reg_data_out[8:7] == 2'b 10 )
                begin
        
                        $display("              Link Partner Advertises Asymetric Towards Link Partner Support\n") ;
                
                end        
                else if (reg_data_out[8:7] == 2'b 01 )
                begin
        
                        $display("              Link Partner Advertises Symetric Pause Support\n") ;   
                
                end
                else
                begin  
        
                        $display("              Link Partner Advertises no Support Pause\n") ;  
                
                end
         
                if (reg_data_out[13:12] == 2'b 00)
                begin
        
                        $display("              Link Partner Advertises no Remote Fault\n") ; 
                
                end
                else
                begin
                
                        $display("              Link Partner Advertises a Remote Fault\n") ;  
                
                end             

                if (reg_data_out[6] == 1'b 1)
                begin
        
                        $display("              Link Partner Supports Half Duplex Operation\n") ;
                
                end
                else
                begin
        
                        $display("              Link Partner does not Support Half Duplex Operation\n") ;
                
                end                

                if (reg_data_out[5] == 1'b 1)
                begin
        
                        $display("              Link Partner Supports Full Duplex Operation\n") ;  
                
                end
                else
                begin
        
                        $display("              Link Partner does not Support Full Duplex Operation\n") ;
                
                end
                
        end
        else
        begin
        
                if (reg_data_out[11:10] == 2'b 00)
                begin
        
                        $display("              Link Partner Supports 10Mbps Operation\n") ; 
                
                end
                else if (reg_data_out[11:10] == 2'b 01)
                begin
        
                        $display("              Link Partner Supports 100Mbps Operation\n") ; 
                
                end
                else
                begin
        
                        $display("              Link Partner Supports Gigabit Operation\n") ;
                
                end
                
                if (reg_data_out[12] == 1'b 0)
                begin
        
                        $display("              Link Partner Supports Full Duplex Operation\n") ;  
                
                end
                else
                begin
        
                        $display("              Link Partner does not Support Full Duplex Operation\n") ;
                
                end
                
        end                   

      end
      
   end

always @(state)
   begin : process_21
   if (state == stm_typ_wr_scratch)
   begin
   
        $display("   - write Scratch Register : 0xaaaa") ;
        
   end        
   else if (state == stm_typ_prog_ability )
   begin
   
        $display("   - Set Core Ability\n") ;   
        
   end     
   else if (state == stm_typ_autoneg_enable )
   begin
   
        $display("   - Enable Auto Negotiation\n") ; 
        
   end
   else if (state == stm_typ_prog_timer_1 )
   begin
   
        $display("   - Programming Link Timer\n") ; 
        
   end
   else if (state == stm_typ_start_autoneg )
   begin
   
        $display("   - Start Auto-Negotiation\n") ; 
        
   end    
   else if (state == stm_typ_read_part_ability )
   begin
   
        $display("   - Read Partner Ability\n") ;   
        
   end 
   else if (state == stm_typ_read_autoneg_status )
   begin
   
        $display("   - Read Auto-Negotiation Results\n") ; 
        
   end    
   else if (state == stm_typ_read_autoneg_expansion )
   begin
   
        $display("   - Read Auto-Negotiation Expansion Register\n") ; 
        
   end    
   else if (state == stm_typ_ena_sw_reset )
   begin
   
        $display(" -- ---------------------------------------------------------- --\n") ;  
        $display("   Test Self Clearing MDIO Reset Command bit\n") ;   

   end
   else if (state == stm_typ_ena_isolate )
   begin
   
        $display(" -- ---------------------------------------------------------- --\n") ;  
        $display("   Enable PHY Isolation\n") ;      
   
   end
   else if (state == stm_typ_disable_isolate )
   begin
   
        $display("   Disable PHY Isolation\n") ;
        $display(" -- ---------------------------------------------------------- --\n") ;                                                
   
   end
   else if (state == stm_typ_sim )
   begin
   
        $display(" -- ---------------------------------------------------------- --\n") ;
        $display("    Start Simulation\n") ;

   end
   else if (state == stm_typ_start_tbi )
   begin
   
        $display("   Checking Latch Low Link MDIO bit\n") ;

   end
   
end

//  -----------------------
//  register test status
//  -----------------------


always @(posedge reset or state or nextstate)

   begin

       if (reset == 1'b 1)
          begin
          register_test <= 0;   
          end
       else
          begin
              if (nextstate == stm_typ_end_sim & state == stm_typ_sim)
                begin
                    // expected scratch register readback is 0xaaaa
                    //
                    if (readback_scratch != 16'haaaa)
                      begin
                         $display("\n      Register test failed on SCRATCH register") ;
                         register_test <= 1;
                      end
    
               end
          end
   end


//  End of Simulation
//  -----------------

always @(posedge reset or posedge rx_clk_sig)
   begin : process_22
   if (reset == 1'b 1)
      begin
      end_cnt <= 0;   
      end
   else
      begin
      if (state == stm_typ_stop_tbi)
         begin
         if (end_cnt == 50)
            begin
            
                $display("\n    End of Simulation\n") ;
                $display(" -- ---------------------------------------------------------- --\n") ;

            end_cnt <= end_cnt + 1'b 1;   
            end
         else
            begin
            end_cnt <= end_cnt + 1'b 1;   
            end
         end
      else if (state == stm_typ_end_sim )
         begin
         if (end_cnt == 300)
            begin
            
                $display(" -- ---------------------------------------------------------- --\n") ;
                $display("   Simulation Results:\n") ; 
                $display("        - Transmitted Frames: ", tx_frm_cnt) ;
                $display("        - Received Frames: ", rx_frm_cnt) ;
                $display("        - CRC Errors: ", rx_crc_err_cnt) ;
                $display("        - Preamble Errors: ", rx_pbl_err_cnt) ;
                $display("        - MII / GMII Error Received: ", rx_gmii_err_cnt) ;
                $display("        - MII / GMII Error Transmitted: ", tx_gmii_err_cnt) ;
                $display("        - Header Errors (Wrong Source MAC Address): ", rx_src_err_cnt) ;
                $display("        - Header Errors (Wrong Destination MAC Address): ", rx_dst_err_cnt, "\n") ;
  
                end_cnt <= end_cnt + 1'b 1;   
            end
         else if (end_cnt == 500 )
            begin

                if ((rx_frm_cnt        == tx_frm_cnt) &
                    (rx_crc_err_cnt    == 0) &
                    (rx_pbl_err_cnt    == 0) &
                    (rx_gmii_err_cnt   == tx_gmii_err_cnt) &
                    (register_test     == 0) &
                    (rx_src_err_cnt    == 0) &
                    (rx_dst_err_cnt    == 0) &
                    (tx_frm_cnt           == TB_TXFRAMES) )
                
                begin
            
                        $display("\n -- Loopback Simulation Ended with no Error") ;
                
                end
                else
                begin
                
                        $display("\n -- Loopback Simulation Ended with Error !") ;
                        
                end
                

                $display("\n- ---------------------------------------------------------------------------------------- -") ;              
            $display("End of simulation");
            $stop;
            end
         else
            begin
            end_cnt <= end_cnt + 1'b 1;   
            end
         end
      else
         begin
         end_cnt <= 0;   
         end
      end
   end

endmodule // module tb
