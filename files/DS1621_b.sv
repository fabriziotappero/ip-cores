// LTX-CREDENCE
// Project:   XXX-X
//
// Module:    DS1621_b
// Revision:  01
// Language:  SystemVerilog
//
// Engineer:  Ashot Khachatryan
// Function:  DS1621 temperature sensor. Behavioral model. Accesses the DS1621_b_nvm.sv memory file.
//
// Comments:  20091202 AKH: Created.  ADAPTED TO CADENCE IUS8.2
//            20091216 AKH: Has given up adding the features.
//                          DS1621_CNT (8'hA8) & DS1621_SLP (8'hA9) registers are not supported by this model.
//            20100402 AKH: Replaced the global temperature variable with real input (convenient for stand alone using/testing).
//
//            I couldn't find the model in the Internet. So, feel free to use it anywhere.
//

`timescale 1ns/10ps

`ifndef DS1621_STOP
  `define DS1621_STOP  8'h22
  `define DS1621_TH    8'hA1
  `define DS1621_TL    8'hA2
  `define DS1621_CNT   8'hA8
  `define DS1621_SLP   8'hA9
  `define DS1621_TMP   8'hAA
  `define DS1621_CFG   8'hAC
  `define DS1621_STRT  8'hEE
`endif

module DS1621_b(
     input         SCL
    ,inout         SDA
    ,input         A0
    ,input         A1
    ,input         A2
    ,output        TOUT
    ,input  [64:1] TEMP_R
);

parameter tsafe_sim    = 1000;
parameter NVM_WRITE_TM = 10_000_000;    // Write time
parameter NVM_WRITE_CP = 500;           // internal clock period
parameter TMP_CONV_TIM = 1_000_000_000; // Temperature conversion time (can be shortened for simulation in the module instance)
`define   DS1621_ID      4'h9

real        int_tmp_port;
real        int_tmp;

shortint    TH, TL, TMP;
reg         rst_n, rst_n_d;
reg         POL, ONE_SHOT, t_alarm;
reg  [15:0] TH_init, TL_init, word3_init;
reg         POL_init, ONE_SHOT_init;
reg  [15:0] nv_RAM [2:0];
reg  [15:0] SRi;
reg   [7:0] SRo, SLP, CNT;
reg   [7:0] cur_acc;
reg   [9:0] bit_cnt;
reg         selected, rw_op;
reg         ev_start, ev_stop, ev_TH, ev_TL;
reg         st_write1, st_write2, st_read1, st_read2, st_ack_sl, st_ack_ms, st_pend_memw;
reg         rst_ev_start, rst_sel, bcnt_strt, a_memwr;
reg         int_clk;
reg  [14:0] eewr_tmr;   //    'h4E20 =        'd20_000 = 10ms
reg  [20:0] tcnv_tmr;   // 'h1E_8480 = 'd2_000_000_000 = 1s
reg   [2:0] iic_sm, iic_smn;
reg   [2:0] eewr_sm, eewr_smn;
reg   [2:0] tcnv_sm, tcnv_smn;
reg   [1:0] byte_cnt, ev_start_r, ev_stop_r;
reg         SDA_r;
reg         a_STOP_r;
reg         THF, TLF;  // status bits

tri1        SDA;
wire  [2:0] A210;
wire        select;
wire        rst_bit_cnt, rst_start, rst_stop, rst_timer, rst_ttimer, rst_byte_cnt, rst_pend, rst_bcnt_strt, rst_a_stop;
wire        THF_reset, TLF_reset, rst_thf, rst_tlf;
wire  [7:0] stat;
wire        DONE, NVB;  // status bits
wire        iic_start, ee_start, tcnv_start, timer_done, ttimer_done, a_START_w;
wire        wrt_idle, wrt_wait, wrt_done, tcnv_idle, tcnv_wait, tcnv_done;
wire        a_TH, a_TL, a_CNT, a_SLP, a_TMP, a_CFG;
wire        byte_cmd, byte_one, byte_two, byte_thr, two_byte_cmd;

initial begin  int_clk = 0; forever int_clk = #(NVM_WRITE_CP/2) ~int_clk;  end  // internal clock for EEPROM / Temperature convertion operations

  // access units
assign a_STOP         =  SRi[7:0] == `DS1621_STOP;
assign a_TH           =  SRi[7:0] == `DS1621_TH;
assign a_TL           =  SRi[7:0] == `DS1621_TL;
assign a_CNT          =  SRi[7:0] == `DS1621_CNT;
assign a_SLP          =  SRi[7:0] == `DS1621_SLP;
assign a_TMP          =  SRi[7:0] == `DS1621_TMP;
assign a_CFG          =  SRi[7:0] == `DS1621_CFG;
assign a_STRT         =  SRi[7:0] == `DS1621_STRT;
  // conditions
assign A210           =  {A2, A1, A0};
assign select         =  ev_start & (SRi[7:1] == {`DS1621_ID, A210});
assign stat           =  {DONE, THF, TLF, NVB, 2'b00, POL, ONE_SHOT};
assign rst_bit_cnt    =  ev_stop | ((bcnt_strt | bit_cnt[9]) & ~SCL) | ~rst_n;
assign rst_bcnt_strt  = ~SCL | ~rst_n;
assign rst_start      =  rst_ev_start | ev_stop | ~rst_n;
assign rst_timer      =  wrt_done  | ~rst_n;
assign rst_ttimer     =  tcnv_done | ~rst_n;
assign rst_byte_cnt   =  bcnt_strt | ~rst_n; //rst_ev_start
assign rst_pend       = (rst_timer & st_pend_memw) | ~rst_n;
assign rst_sel        = (~ev_start_r[1] & ev_start_r[0]) | ev_stop | ~rst_n;
assign rst_stop       = &ev_stop_r[1:0] | ~rst_n;
assign rst_a_stop     =  a_START_w | ~rst_n;
assign rst_thf        =  THF_reset | ~rst_n_d;
assign rst_tlf        =  TLF_reset | ~rst_n_d;
assign a_START_w      =  a_STRT & selected & byte_one & bit_cnt[8] & ~SCL & ~rw_op;
assign iic_start      = (ev_start & ~SCL) | (bit_cnt[0] & selected);
assign ee_start       =  st_pend_memw & ev_stop;
assign tcnv_start     = (ONE_SHOT & a_START_w) | (~ONE_SHOT & tcnv_idle & ~a_STOP_r);
assign timer_done     =  wrt_wait  & (eewr_tmr == (NVM_WRITE_TM / NVM_WRITE_CP));
assign ttimer_done    =  tcnv_wait & (tcnv_tmr == (TMP_CONV_TIM / NVM_WRITE_CP));
assign byte_cmd       =  byte_cnt == 2'b00;
assign byte_one       =  byte_cnt == 2'b01;
assign byte_two       =  byte_cnt == 2'b10;
assign byte_thr       =  byte_cnt == 2'b11;
  // status bits
assign NVB            = ~wrt_idle;
assign DONE           =  tcnv_idle;
assign THF_reset      = ~rw_op & bit_cnt[8] & cur_acc[1] & byte_two & ~SCL & ~SRi[6];
assign TLF_reset      = ~rw_op & bit_cnt[8] & cur_acc[1] & byte_two & ~SCL & ~SRi[5];

  // Start
always @( negedge SDA, posedge rst_start )
    if ( rst_start )      ev_start <= 1'b0;
    else if ( SCL )       ev_start <= 1'b1;

always @( negedge SCL )  rst_ev_start <= bit_cnt[9] & ev_start;
  //

  // Stop
always @( posedge SDA, posedge rst_stop )
    if ( rst_stop )  ev_stop <= 1'b0;
    else if ( SCL )  ev_stop <= 1'b1;  // one int_clk period

always @( posedge int_clk, negedge rst_n )
    if ( ~rst_n )  ev_stop_r[1:0] <= 1'b0;
    else           ev_stop_r[1:0] <= {ev_stop_r[0], ev_stop};
  //

  // bit counter
always @( posedge SCL, posedge rst_bit_cnt )
    if ( rst_bit_cnt )       bit_cnt <=  10'h001;
    else                     bit_cnt <= {bit_cnt, 1'b0};

always @( posedge ev_start, posedge rst_bcnt_strt )  // reset after the start condition received
    if ( rst_bcnt_strt )  bcnt_strt <= 1'b0;
    else                  bcnt_strt <= 1'b1;
  //

  // byte counter
always @( negedge SCL, posedge rst_byte_cnt )
    if ( rst_byte_cnt )                byte_cnt <= 2'b00;
    else if ( bit_cnt[9] & selected )  byte_cnt <= byte_cnt +1;

  // EEPROM write timer
always @( posedge int_clk, posedge rst_timer )
    if ( rst_timer )      eewr_tmr <= 15'h0000;
    else if ( wrt_wait )  eewr_tmr <= eewr_tmr +1;

  // Temperature conversion timer
always @( posedge int_clk, posedge rst_ttimer )
    if ( rst_ttimer )      tcnv_tmr <= 21'h00_0000;
    else if ( tcnv_wait )  tcnv_tmr <= tcnv_tmr +1;

  // Operation control
always @( negedge SCL, posedge rst_sel )
    if ( rst_sel )                              rw_op <= 1'b1;
    else if ( bit_cnt[8] & ev_start & select )  rw_op <= SRi[0];  // wr=0, rd=1

always @( negedge SCL, posedge rst_sel )
    if ( rst_sel )                              selected <= 1'b0;
    else if ( bit_cnt[8] & ev_start & select )  selected <= 1'b1;

always @( posedge int_clk, negedge rst_n )
    if ( ~rst_n )  ev_start_r[1:0] <= 1'b0;
    else           ev_start_r[1:0] <= {ev_start_r[0], ev_start};
  //

  // Current resource being accessed
always @( negedge SCL, negedge rst_n )
    if ( ~rst_n )                                          cur_acc[7:0] <=  0;
    else if ( bit_cnt[8] & selected & ~rw_op & byte_one )  cur_acc[7:0] <= {a_STOP, a_TH, a_TL, a_CNT, a_SLP, a_TMP, a_CFG, a_STRT};

  // STOP command retention for not ONE_SHOT mode
always @( negedge SCL, posedge rst_a_stop )
    if ( rst_a_stop )       a_STOP_r <= 1'b0;
    else if ( cur_acc[7] )  a_STOP_r <= 1'b1;

  // Pending NV memory write flag
always @( negedge SCL, posedge rst_pend )
    if ( rst_pend )         st_pend_memw <= 0;
    else if ( bit_cnt[9] )  st_pend_memw <= a_memwr | st_pend_memw;

always @( negedge SCL, posedge rst_pend )
    if ( rst_pend )                    a_memwr <= 0;
    else if ( bit_cnt[8] & selected )  a_memwr <= (  ( byte_thr & ((cur_acc[6] & (SRi[15:0] != TH_init)) || (cur_acc[5] & (SRi[15:0] != TL_init))) )
                                                  || ( byte_two &   cur_acc[1] & (SRi[1:0] != word3_init[1:0]) )
                                                  ) & ~rw_op & bit_cnt[8];
  //

  // Slave ACK
always @( negedge SCL, negedge rst_n )
    if ( ~rst_n )                                 st_ack_sl <= 1'b0;
    else if ( bit_cnt[8] & (~rw_op | ev_start) )  st_ack_sl <= 1'b1;
    else                                          st_ack_sl <= 1'b0;

  // Master ACK
always @( negedge SCL, negedge rst_n )
    if ( ~rst_n )                               st_ack_ms <= 1'b0;
    else if ( bit_cnt[8] & rw_op & ~ev_start )  st_ack_ms <= 1'b1;
    else                                        st_ack_ms <= 1'b0;

  // Shift register: input
always @( posedge SCL, negedge rst_n )
    if ( ~rst_n )                        SRi[15:0] <=  16'h0000;
    else if ( ~st_ack_sl & ~st_ack_ms )  SRi[15:0] <= {SRi[14:0], SDA};

  // Shift register: output
always @(negedge SCL) // a_STOP, a_TH, a_TL, a_CNT, a_SLP, a_TMP, a_CFG, a_STRT
    if ( bit_cnt[9] )  SRo[7:0] <= cur_acc[6] ? (byte_cmd ? TH[15:8]  : TH[7:0])  :
                                   cur_acc[5] ? (byte_cmd ? TL[15:8]  : TL[7:0])  :
                                   cur_acc[2] ? (byte_cmd ? TMP[15:8] : TMP[7:0]) :
                                   cur_acc[1] ?  stat : 8'hff;
    else               SRo[7:0] <= {SRo[6:0], 1'b1};

// DS1621 registers
  // TH
always @( negedge SCL, negedge rst_n_d )
    if ( ~rst_n_d )                                                      TH[15:8] <= TH_init[15:8];
    else if ( ~rw_op & bit_cnt[8] & cur_acc[6] & byte_two & ~wrt_wait )  TH[15:8] <= SRi[7:0];

always @( negedge SCL, negedge rst_n_d )
    if ( ~rst_n_d )                                                      TH[7:0] <= TH_init[7:0];
    else if ( ~rw_op & bit_cnt[8] & cur_acc[6] & byte_thr & ~wrt_wait )  TH[7:0] <= SRi[7:0];
  // 
  // TL
always @( negedge SCL, negedge rst_n_d )
    if ( ~rst_n_d )                                                      TL[15:8] <= TL_init[15:8];
    else if ( ~rw_op & bit_cnt[8] & cur_acc[5] & byte_two & ~wrt_wait )  TL[15:8] <= SRi[7:0];

always @( negedge SCL, negedge rst_n_d )
    if ( ~rst_n_d )                                                      TL[7:0] <= TL_init[7:0];
    else if ( ~rw_op & bit_cnt[8] & cur_acc[5] & byte_thr & ~wrt_wait )  TL[7:0] <= SRi[7:0];
  // 
  // CFG status bits: POL, ONE_SHOT
always @( negedge SCL, negedge rst_n_d )
    if ( ~rst_n_d ) begin
        POL      <= POL_init;
        ONE_SHOT <= ONE_SHOT_init;
    end
    else if ( ~rw_op & bit_cnt[8] & cur_acc[1] & byte_two & ~wrt_wait ) begin
        POL      <= SRi[1];
        ONE_SHOT <= SRi[0];
    end
  // THF, TLF
always @( posedge ev_TH, posedge rst_thf )
    if ( rst_thf )  THF <= 1'b0;
    else            THF <= 1'b1;
  // TLF
always @( posedge ev_TL, posedge rst_tlf )
     if ( rst_tlf )  TLF <= 1'b0;
    else             TLF <= 1'b1;
  //

  // EEPROM write state machine
`define DS1621EE_IDLE   eewr_sm[0]
`define DS1621EE_WAIT   eewr_sm[1]
`define DS1621EE_DONE   eewr_sm[2]
`define NDS1621EE_IDLE  3'b001
`define NDS1621EE_WAIT  3'b010
`define NDS1621EE_DONE  3'b100

always @( posedge int_clk, negedge rst_n )
    if ( ~rst_n )  eewr_sm <= `NDS1621EE_IDLE;
    else           eewr_sm <=  eewr_smn;

always @( * ) begin
    eewr_smn = eewr_sm;
    casex( 1 )
      `DS1621EE_IDLE: if ( ee_start )   eewr_smn = `NDS1621EE_WAIT;
      `DS1621EE_WAIT: if ( timer_done ) eewr_smn = `NDS1621EE_DONE;
      `DS1621EE_DONE:                   eewr_smn = `NDS1621EE_IDLE;
      default:                          eewr_smn = `NDS1621EE_IDLE;
    endcase
end

assign wrt_idle = `DS1621EE_IDLE;
assign wrt_wait = `DS1621EE_WAIT;
assign wrt_done = `DS1621EE_DONE;
  //

  // Temperature conversion state machine
`define DS1621T_IDLE   tcnv_sm[0]
`define DS1621T_WAIT   tcnv_sm[1]
`define DS1621T_DONE   tcnv_sm[2]
`define NDS1621T_IDLE  3'b001
`define NDS1621T_WAIT  3'b010
`define NDS1621T_DONE  3'b100

always @( posedge int_clk, negedge rst_n )
    if ( ~rst_n )  tcnv_sm <= `NDS1621EE_IDLE;
    else           tcnv_sm <=  tcnv_smn;

always @( * ) begin
    tcnv_smn = tcnv_sm;
    casex( 1 )
      `DS1621T_IDLE: if ( tcnv_start )  tcnv_smn = `NDS1621T_WAIT;
      `DS1621T_WAIT: if ( ttimer_done ) tcnv_smn = `NDS1621T_DONE;
      `DS1621T_DONE:                    tcnv_smn = `NDS1621T_IDLE;
      default:                          tcnv_smn = `NDS1621T_IDLE;
    endcase
end

assign tcnv_idle = `DS1621T_IDLE;
assign tcnv_wait = `DS1621T_WAIT;
assign tcnv_done = `DS1621T_DONE;
  //

  // Temperature conversion, behavioral
initial assign int_tmp_port = $bitstoreal( TEMP_R );

always @( * )
    if ( int_tmp_port < -55.0 )       int_tmp = -55.0;
    else if ( int_tmp_port > 125.0 )  int_tmp = 125.0;
    else                              int_tmp = int_tmp_port;

shortint TMP_tmp;
always @( posedge tcnv_done, negedge rst_n_d )
    if ( ~rst_n_d )                      TMP[15:0] = 16'h1700;  // initial valkue is 23*C
    else begin
        TMP_tmp   = $rtoi(int_tmp);
        TMP[15:8] = TMP_tmp[7:0];
        //$display("After rtoi TMP_tmp=%0h TMP[15:0]=%0h", TMP_tmp, TMP[15:0]);
        if ( (TMP_tmp - int_tmp) != 0 )  TMP[7:0] = 8'h80;
        else                             TMP[7:0] = 8'h00;
        //$display("Final                  TMP[15:0]=%0h", TMP[15:0]);
    end
  //

  // Temperature alarm
assign ev_TH = TMP > TH;
assign ev_TL = TMP < TL;

always @( * )
    if ( ~rst_n_d )    t_alarm = 1'b0;
    else if ( ev_TH )  t_alarm = 1'b1;
    else if ( ev_TL )  t_alarm = 1'b0;
    else               t_alarm = t_alarm;
  //

  // Output generation
assign two_byte_cmd  = |cur_acc[6:5] | cur_acc[2];
assign SDA           =  st_ack_sl ? 1'b0 : selected & rw_op & ~st_ack_ms & (byte_one | (byte_two & two_byte_cmd)) ? SRo[7] : 1'bz;
assign TOUT          =  t_alarm ^~ POL;

  // NV memory read & write
always @( posedge wrt_done, negedge rst_n ) begin
    if ( ~rst_n ) begin
        $readmemh( "DS1621_b_nvm.sv", nv_RAM );
        if ( nv_RAM[0] == 16'hxxxx )  TH_init    = 16'h0000;
        else                          TH_init    = nv_RAM[0];
        if ( nv_RAM[1] == 16'hxxxx )  TL_init    = 16'h0000;
        else                          TL_init    = nv_RAM[1];
        if ( nv_RAM[2] == 16'hxxxx )  word3_init = 16'h0000;
        else                          word3_init = nv_RAM[2];
        POL_init      = word3_init[1];
        ONE_SHOT_init = word3_init[0];
    end
    else if ( wrt_done ) begin
        nv_RAM[0] =  TH;
        nv_RAM[1] =  TL;
        nv_RAM[2] = {14'h0000, POL, ONE_SHOT};
        $writememh( "DS1621_b_nvm.sv", nv_RAM );
    end
    //$display("TH=%h, TL=%h, POL=%0h, ONE_SHOT=%0h", TH_init, TL_init, POL_init, ONE_SHOT_init);
end

  // timing checks
initial begin
    rst_n   = 0;
    rst_n_d = 1;     // memory init signal
   #(tsafe_sim / 2)
    rst_n_d = 0;
   #(tsafe_sim / 2)
    rst_n   = 1;
    rst_n_d = 1;
end

specify
    specparam
      `ifdef DS1621_STANDARD
         tBUF    = 4700,  // Bus free time
         tHD_STA = 4000,  // SCL+ hold time: start condition [repeated]
         tLOW    = 4700,  // SCL- width
         tHIGH   = 4000,  // SCL+ width
         //tHD_DAT =    0,  // SDA to SCL+ hold  time
         tSU_STA = 4700,  // SCL+ to SDA setup time for repeated start
         tSU_DAT =  250,  // SDA to SCL+ setup time
         tSU_STO = 4000;  // SCL+ to SDA setup time
      `else
         tBUF    = 1300,  // Bus free time
         tHD_STA =  600,  // SCL+ hold time: start condition [repeated]
         tLOW    = 1300,  // SCL- width
         tHIGH   =  600,  // SCL+ width
         //tHD_DAT =    0,  // SDA to SCL+ hold  time
         tSU_STA =  600,  // SCL+ to SDA setup time for repeated start
         tSU_DAT =  100,  // SDA to SCL+ setup time
         tSU_STO =  600;  // SCL+ to SDA setup time
      `endif
    $width( posedge SDA &&& SCL, tBUF  );
    $width( negedge SCL,         tLOW  );
    $width( posedge SCL,         tHIGH );
    $hold ( negedge SDA, negedge SCL &&& rst_n, tHD_STA );
    $setup( posedge SCL, negedge SDA &&& rst_n, tSU_STA );
    $setup( SDA, posedge SCL         &&& rst_n, tSU_DAT );
    $setup( posedge SCL, posedge SDA &&& rst_n, tSU_STO );
endspecify

endmodule
