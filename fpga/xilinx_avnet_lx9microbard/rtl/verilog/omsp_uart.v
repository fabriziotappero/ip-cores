//----------------------------------------------------------------------------
// Copyright (C) 2009 , Olivier Girard
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the authors nor the names of its contributors
//       may be used to endorse or promote products derived from this software
//       without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
// OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
// THE POSSIBILITY OF SUCH DAMAGE
//
//----------------------------------------------------------------------------
//
// *File Name: omsp_uart.v
// 
// *Module Description:
//                       Simple full duplex UART (8N1 protocol).
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 111 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2011-05-20 22:39:02 +0200 (Fri, 20 May 2011) $
//----------------------------------------------------------------------------

module  omsp_uart (

// OUTPUTs
    irq_uart_rx,                    // UART receive interrupt
    irq_uart_tx,                    // UART transmit interrupt
    per_dout,                       // Peripheral data output
    uart_txd,                       // UART Data Transmit (TXD)

// INPUTs
    mclk,                           // Main system clock
    per_addr,                       // Peripheral address
    per_din,                        // Peripheral data input
    per_en,                         // Peripheral enable (high active)
    per_we,                         // Peripheral write enable (high active)
    puc_rst,                        // Main system reset
    smclk_en,                       // SMCLK enable (from CPU)
    uart_rxd                        // UART Data Receive (RXD)
);

// OUTPUTs
//=========
output             irq_uart_rx;     // UART receive interrupt
output             irq_uart_tx;     // UART transmit interrupt
output      [15:0] per_dout;        // Peripheral data output
output             uart_txd;        // UART Data Transmit (TXD)

// INPUTs
//=========
input              mclk;            // Main system clock
input       [13:0] per_addr;        // Peripheral address
input       [15:0] per_din;         // Peripheral data input
input              per_en;          // Peripheral enable (high active)
input        [1:0] per_we;          // Peripheral write enable (high active)
input              puc_rst;         // Main system reset
input              smclk_en;        // SMCLK enable (from CPU)
input              uart_rxd;        // UART Data Receive (RXD)


//=============================================================================
// 1)  PARAMETER DECLARATION
//=============================================================================

// Register base address (must be aligned to decoder bit width)
parameter       [14:0] BASE_ADDR   = 15'h0080;

// Decoder bit width (defines how many bits are considered for address decoding)
parameter              DEC_WD      =  3;

// Register addresses offset
parameter [DEC_WD-1:0] CTRL        =  'h0,
                       STATUS      =  'h1,
                       BAUD_LO     =  'h2,
                       BAUD_HI     =  'h3,
                       DATA_TX     =  'h4,
                       DATA_RX     =  'h5;

   
// Register one-hot decoder utilities
parameter              DEC_SZ      =  (1 << DEC_WD);
parameter [DEC_SZ-1:0] BASE_REG    =  {{DEC_SZ-1{1'b0}}, 1'b1};

// Register one-hot decoder
parameter [DEC_SZ-1:0] CTRL_D      = (BASE_REG << CTRL),
                       STATUS_D    = (BASE_REG << STATUS), 
                       BAUD_LO_D   = (BASE_REG << BAUD_LO), 
                       BAUD_HI_D   = (BASE_REG << BAUD_HI), 
                       DATA_TX_D   = (BASE_REG << DATA_TX), 
                       DATA_RX_D   = (BASE_REG << DATA_RX); 


//============================================================================
// 2)  REGISTER DECODER
//============================================================================

// Local register selection
wire              reg_sel      =  per_en & (per_addr[13:DEC_WD-1]==BASE_ADDR[14:DEC_WD]);

// Register local address
wire [DEC_WD-1:0] reg_addr     =  {1'b0, per_addr[DEC_WD-2:0]};

// Register address decode
wire [DEC_SZ-1:0] reg_dec      = (CTRL_D    &  {DEC_SZ{(reg_addr==(CTRL    >>1))}}) |
                                 (STATUS_D  &  {DEC_SZ{(reg_addr==(STATUS  >>1))}}) |
                                 (BAUD_LO_D &  {DEC_SZ{(reg_addr==(BAUD_LO >>1))}}) |
                                 (BAUD_HI_D &  {DEC_SZ{(reg_addr==(BAUD_HI >>1))}}) |
                                 (DATA_TX_D &  {DEC_SZ{(reg_addr==(DATA_TX >>1))}}) |
                                 (DATA_RX_D &  {DEC_SZ{(reg_addr==(DATA_RX >>1))}});

// Read/Write probes
wire              reg_lo_write =  per_we[0] & reg_sel;
wire              reg_hi_write =  per_we[1] & reg_sel;
wire              reg_read     = ~|per_we   & reg_sel;

// Read/Write vectors
wire [DEC_SZ-1:0] reg_hi_wr    = reg_dec & {DEC_SZ{reg_hi_write}};
wire [DEC_SZ-1:0] reg_lo_wr    = reg_dec & {DEC_SZ{reg_lo_write}};
wire [DEC_SZ-1:0] reg_rd       = reg_dec & {DEC_SZ{reg_read}};


//============================================================================
// 3) REGISTERS
//============================================================================

// CTRL Register
//-----------------
reg  [7:0] ctrl;

wire       ctrl_wr  = CTRL[0] ? reg_hi_wr[CTRL] : reg_lo_wr[CTRL];
wire [7:0] ctrl_nxt = CTRL[0] ? per_din[15:8]   : per_din[7:0];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)       ctrl <=  8'h00;
  else if (ctrl_wr)  ctrl <=  ctrl_nxt & 8'h73;

wire       ctrl_ien_tx_empty = ctrl[7];
wire       ctrl_ien_tx       = ctrl[6];
wire       ctrl_ien_rx_ovflw = ctrl[5];
wire       ctrl_ien_rx       = ctrl[4];
wire       ctrl_smclk_sel    = ctrl[1];
wire       ctrl_en           = ctrl[0];


// STATUS Register
//-----------------
wire [7:0] status;
reg        status_tx_empty_pnd;
reg        status_tx_pnd;
reg        status_rx_ovflw_pnd;
reg        status_rx_pnd;
wire       status_tx_full;
wire       status_tx_busy;
wire       status_rx_busy;

wire       status_wr  = STATUS[0] ? reg_hi_wr[STATUS] : reg_lo_wr[STATUS];
wire [7:0] status_nxt = STATUS[0] ? per_din[15:8]     : per_din[7:0];

wire       status_tx_empty_pnd_clr = status_wr & status_nxt[7];
wire       status_tx_pnd_clr       = status_wr & status_nxt[6];
wire       status_rx_ovflw_pnd_clr = status_wr & status_nxt[5];
wire       status_rx_pnd_clr       = status_wr & status_nxt[4];
wire       status_tx_empty_pnd_set;
wire       status_tx_pnd_set;
wire       status_rx_ovflw_pnd_set;
wire       status_rx_pnd_set;

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                      status_tx_empty_pnd <=  1'b0;
  else if (status_tx_empty_pnd_set) status_tx_empty_pnd <=  1'b1;
  else if (status_tx_empty_pnd_clr) status_tx_empty_pnd <=  1'b0;

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                      status_tx_pnd       <=  1'b0;
  else if (status_tx_pnd_set)       status_tx_pnd       <=  1'b1;
  else if (status_tx_pnd_clr)       status_tx_pnd       <=  1'b0;

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                      status_rx_ovflw_pnd <=  1'b0;
  else if (status_rx_ovflw_pnd_set) status_rx_ovflw_pnd <=  1'b1;
  else if (status_rx_ovflw_pnd_clr) status_rx_ovflw_pnd <=  1'b0;

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                      status_rx_pnd       <=  1'b0;
  else if (status_rx_pnd_set)       status_rx_pnd       <=  1'b1;
  else if (status_rx_pnd_clr)       status_rx_pnd       <=  1'b0;

assign     status = {status_tx_empty_pnd, status_tx_pnd,   status_rx_ovflw_pnd, status_rx_pnd,
                     status_tx_full,      status_tx_busy,  1'b0,                status_rx_busy};

   
// BAUD_LO Register
//-----------------
reg  [7:0] baud_lo;

wire       baud_lo_wr  = BAUD_LO[0] ? reg_hi_wr[BAUD_LO] : reg_lo_wr[BAUD_LO];
wire [7:0] baud_lo_nxt = BAUD_LO[0] ? per_din[15:8]      : per_din[7:0];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)         baud_lo <=  8'h00;
  else if (baud_lo_wr) baud_lo <=  baud_lo_nxt;


// BAUD_HI Register
//-----------------
reg  [7:0] baud_hi;

wire       baud_hi_wr  = BAUD_HI[0] ? reg_hi_wr[BAUD_HI] : reg_lo_wr[BAUD_HI];
wire [7:0] baud_hi_nxt = BAUD_HI[0] ? per_din[15:8]      : per_din[7:0];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)         baud_hi <=  8'h00;
  else if (baud_hi_wr) baud_hi <=  baud_hi_nxt;


wire [15:0] baudrate = {baud_hi, baud_lo};
 

// DATA_TX Register
//-----------------
reg  [7:0] data_tx;

wire       data_tx_wr  = DATA_TX[0] ? reg_hi_wr[DATA_TX] : reg_lo_wr[DATA_TX];
wire [7:0] data_tx_nxt = DATA_TX[0] ? per_din[15:8]      : per_din[7:0];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)         data_tx <=  8'h00;
  else if (data_tx_wr) data_tx <=  data_tx_nxt;


// DATA_RX Register
//-----------------
reg  [7:0] data_rx;

reg  [7:0] rxfer_buf;

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                data_rx <=  8'h00;
  else if (status_rx_pnd_set) data_rx <=  rxfer_buf;


//============================================================================
// 4) DATA OUTPUT GENERATION
//============================================================================

// Data output mux
wire [15:0] ctrl_rd     = {8'h00, (ctrl     & {8{reg_rd[CTRL]}})}     << (8 & {4{CTRL[0]}});
wire [15:0] status_rd   = {8'h00, (status   & {8{reg_rd[STATUS]}})}   << (8 & {4{STATUS[0]}});
wire [15:0] baud_lo_rd  = {8'h00, (baud_lo  & {8{reg_rd[BAUD_LO]}})}  << (8 & {4{BAUD_LO[0]}});
wire [15:0] baud_hi_rd  = {8'h00, (baud_hi  & {8{reg_rd[BAUD_HI]}})}  << (8 & {4{BAUD_HI[0]}});
wire [15:0] data_tx_rd  = {8'h00, (data_tx  & {8{reg_rd[DATA_TX]}})}  << (8 & {4{DATA_TX[0]}});
wire [15:0] data_rx_rd  = {8'h00, (data_rx  & {8{reg_rd[DATA_RX]}})}  << (8 & {4{DATA_RX[0]}});

wire [15:0] per_dout  =  ctrl_rd    |
                         status_rd  |
                         baud_lo_rd |
                         baud_hi_rd |
                         data_tx_rd |
                         data_rx_rd;


//=============================================================================
// 5)  UART CLOCK SELECTION
//=============================================================================

wire uclk_en = ctrl_smclk_sel ? smclk_en : 1'b1;

   
//=============================================================================
// 5)  UART RECEIVE LINE SYNCHRONIZTION & FILTERING
//=============================================================================

// Synchronize RXD input
//--------------------------------
wire     uart_rxd_sync_n;

omsp_sync_cell sync_cell_uart_rxd (
    .data_out  (uart_rxd_sync_n),
    .data_meta (),
    .data_in   (~uart_rxd),
    .clk       (mclk),
    .rst       (puc_rst)
);
wire uart_rxd_sync = ~uart_rxd_sync_n;
   
// RXD input buffer
//--------------------------------
reg  [1:0] rxd_buf;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) rxd_buf <=  2'h3;
  else         rxd_buf <=  {rxd_buf[0], uart_rxd_sync};

// Majority decision
//------------------------
reg        rxd_maj;

wire [1:0] rxd_maj_cnt = {1'b0, uart_rxd_sync}   +
                         {1'b0, rxd_buf[0]}      +
                         {1'b0, rxd_buf[1]};
wire       rxd_maj_nxt = (rxd_maj_cnt>=2'b10);
   
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) rxd_maj <=  1'b1;
  else         rxd_maj <=  rxd_maj_nxt;

wire rxd_s  =  rxd_maj;
wire rxd_fe =  rxd_maj & ~rxd_maj_nxt;

   
//=============================================================================
// 6)  UART RECEIVE
//=============================================================================
   
// RX Transfer counter
//------------------------
reg  [3:0] rxfer_bit;
reg [15:0] rxfer_cnt;

wire       rxfer_start   = (rxfer_bit==4'h0) & rxd_fe;
wire       rxfer_bit_inc = (rxfer_bit!=4'h0) & (rxfer_cnt=={16{1'b0}});
wire       rxfer_done    = (rxfer_bit==4'ha);

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                 rxfer_bit <=  4'h0;
  else if (~ctrl_en)           rxfer_bit <=  4'h0;
  else if (rxfer_start)        rxfer_bit <=  4'h1;
  else if (uclk_en)
    begin
       if (rxfer_done)         rxfer_bit <=  4'h0;
       else if (rxfer_bit_inc) rxfer_bit <=  rxfer_bit+4'h1;
    end

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                 rxfer_cnt <=  {16{1'b0}};
  else if (~ctrl_en)           rxfer_cnt <=  {16{1'b0}};
  else if (rxfer_start)        rxfer_cnt <=  {1'b0, baudrate[15:1]};
  else if (uclk_en)
    begin
       if (rxfer_bit_inc)      rxfer_cnt <=  baudrate;
       else if (|rxfer_cnt)    rxfer_cnt <=  rxfer_cnt+{16{1'b1}};
    end


// Receive buffer
//-------------------------
wire [7:0] rxfer_buf_nxt =  {rxd_s, rxfer_buf[7:1]};

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)            rxfer_buf <=  8'h00;
  else if (~ctrl_en)      rxfer_buf <=  8'h00;
  else if (uclk_en)
    begin
       if (rxfer_bit_inc) rxfer_buf <=  rxfer_buf_nxt;
    end


// Status flags
//-------------------------

// Edge detection required for the case when
// the transmit base clock is SMCLK
reg rxfer_done_dly;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) rxfer_done_dly <=  1'b0;
  else         rxfer_done_dly <=  rxfer_done;


assign  status_rx_pnd_set       = rxfer_done & ~rxfer_done_dly;
assign  status_rx_ovflw_pnd_set = status_rx_pnd_set & status_rx_pnd;
assign  status_rx_busy          = (rxfer_bit!=4'h0);


//============================================================================
// 5) UART TRANSMIT
//============================================================================

// TX Transfer start detection
//-----------------------------
reg        txfer_triggered;
wire       txfer_start;
   
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)          txfer_triggered <=  1'b0;
  else if (data_tx_wr)  txfer_triggered <=  1'b1;
  else if (txfer_start) txfer_triggered <=  1'b0;
 

// TX Transfer counter
//------------------------
reg  [3:0] txfer_bit;
reg [15:0] txfer_cnt;

assign     txfer_start   = (txfer_bit==4'h0) & txfer_triggered;
wire       txfer_bit_inc = (txfer_bit!=4'h0) & (txfer_cnt=={16{1'b0}});
wire       txfer_done    = (txfer_bit==4'hb);

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                 txfer_bit <=  4'h0;
  else if (~ctrl_en)           txfer_bit <=  4'h0;
  else if (txfer_start)        txfer_bit <=  4'h1;
  else if (uclk_en)
    begin
       if (txfer_done)         txfer_bit <=  4'h0;
       else if (txfer_bit_inc) txfer_bit <=  txfer_bit+4'h1;
    end

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                 txfer_cnt <=  {16{1'b0}};
  else if (~ctrl_en)           txfer_cnt <=  {16{1'b0}};
  else if (txfer_start)        txfer_cnt <=  baudrate;
  else if (uclk_en)
    begin
       if (txfer_bit_inc)      txfer_cnt <=  baudrate;
       else if (|txfer_cnt)    txfer_cnt <=  txfer_cnt+{16{1'b1}};
    end


// Transmit buffer
//-------------------------
reg  [8:0] txfer_buf;

wire [8:0] txfer_buf_nxt =  {1'b1, txfer_buf[8:1]};

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)            txfer_buf <=  9'h1ff;
  else if (~ctrl_en)      txfer_buf <=  9'h1ff;
  else if (txfer_start)   txfer_buf <=  {data_tx, 1'b0};
  else if (uclk_en)
    begin
       if (txfer_bit_inc) txfer_buf <=  txfer_buf_nxt;
    end

assign  uart_txd = txfer_buf[0];

   
// Status flags
//-------------------------

// Edge detection required for the case when
// the transmit base clock is SMCLK
reg txfer_done_dly;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) txfer_done_dly <=  1'b0;
  else         txfer_done_dly <=  txfer_done;


assign  status_tx_pnd_set       = txfer_done & ~txfer_done_dly;
assign  status_tx_empty_pnd_set = status_tx_pnd_set & ~txfer_triggered;
assign  status_tx_busy          = (txfer_bit!=4'h0) | txfer_triggered;
assign  status_tx_full          = status_tx_busy & txfer_triggered;


//============================================================================
// 6) INTERRUPTS
//============================================================================

// Receive interrupt can be generated with the completion of a received byte
// or an overflow occures.
assign  irq_uart_rx    = (status_rx_pnd       & ctrl_ien_rx)        |
                         (status_rx_ovflw_pnd & ctrl_ien_rx_ovflw);


// Transmit interrupt can be generated with the transmition completion of
// a byte or when the tranmit buffer is empty (i.e. nothing left to transmit)
assign  irq_uart_tx    = (status_tx_pnd       & ctrl_ien_tx)        |
                         (status_tx_empty_pnd & ctrl_ien_tx_empty);

  
endmodule // uart

