--------------------------------------------------------------------------------
-- Title      : Transmitter FIFO with AxiStream interfaces
-- Version    : 1.3
-- Project    : Tri-Mode Ethernet MAC
--------------------------------------------------------------------------------
-- File       : tx_client_fifo.vhd
-- Author     : Xilinx Inc.
-- Project    : Virtex-6 Embedded Tri-Mode Ethernet MAC Wrapper
-- File       : tx_client_fifo.vhd
-- Version    : 2.1
-------------------------------------------------------------------------------
--
-- (c) Copyright 2004-2008 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
--
-- Description: This is a transmitter side FIFO for the design example
--              of the Tri-Mode Ethernet MAC core. AxiStream interfaces are used.
--
--              The FIFO is created from 2 Block RAMs of size 2048
--              words of 8-bits per word, giving a total frame memory capacity
--              of 4096 bytes.
--
--              Valid frame data received from the user interface is written
--              into the Block RAM on the tx_fifo_aclkk. The FIFO will store
--              frames up to 4kbytes in length. If larger frames are written
--              to the FIFO, the AxiStream interface will accept the rest of the
--              frame, but that frame will be dropped by the FIFO and the
--              overflow signal will be asserted.
--
--              The FIFO is designed to work with a minimum frame length of 14
--              bytes.
--
--              When there is at least one complete frame in the FIFO, the MAC
--              transmitter AxiStream interface will be driven to request frame
--              transmission by placing the first byte of the frame onto
--              tx_axis_mac_tdata and by asserting tx_axis_mac_tvalid. The MAC will later
--              respond by asserting tx_axis_mac_tready. At this point the remaining
--              frame data is read out of the FIFO subject to tx_axis_mac_tready.
--              Data is read out of the FIFO on the tx_mac_aclk.
--
--              If the generic FULL_DUPLEX_ONLY is set to false, the FIFO will
--              requeue and retransmit frames as requested by the MAC. Once a
--              frame has been transmitted by the FIFO it is stored until the
--              possible retransmit window for that frame has expired.
--
--              The FIFO has been designed to operate with different clocks
--              on the write and read sides. The write clock (user-side
--              AxiStream clock) can be an equal or faster frequency than the
--              read clock (MAC-side AxiStream clock). The minimum write clock
--              frequency is the read clock frequency divided by 2.
--
--              The FIFO memory size can be increased by expanding the rd_addr
--              and wr_addr signal widths, to address further BRAMs.
--
--------------------------------------------------------------------------------


library unimacro;
use unimacro.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


--------------------------------------------------------------------------------
-- Entity declaration for the Transmitter FIFO
--------------------------------------------------------------------------------

entity tx_client_fifo is
   generic (
      FULL_DUPLEX_ONLY : boolean := false);
   port (
        -- User-side (write-side) AxiStream interface
        tx_fifo_aclk    : in  std_logic;
        tx_fifo_resetn  : in  std_logic;
        tx_axis_fifo_tdata : in  std_logic_vector(7 downto 0);
        tx_axis_fifo_tvalid : in  std_logic;
        tx_axis_fifo_tlast : in  std_logic;
        tx_axis_fifo_tready : out std_logic;

        -- MAC-side (read-side) AxiStream interface
        tx_mac_aclk     : in  std_logic;
        tx_mac_resetn   : in  std_logic;
        tx_axis_mac_tdata : out std_logic_vector(7 downto 0);
        tx_axis_mac_tvalid : out std_logic;
        tx_axis_mac_tlast : out std_logic;
        tx_axis_mac_tready : in  std_logic;
        tx_axis_mac_tuser : out std_logic;

        -- FIFO status and overflow indication,
        -- synchronous to write-side (tx_user_aclk) interface
        fifo_overflow   : out std_logic;
        fifo_status     : out std_logic_vector(3 downto 0);

        -- FIFO collision and retransmission requests from MAC
        tx_collision    : in  std_logic;
        tx_retransmit   : in  std_logic
        );
end tx_client_fifo;


architecture RTL of tx_client_fifo is


  ------------------------------------------------------------------------------
  -- Component declaration for the synchronisation flip-flop pair
  ------------------------------------------------------------------------------
  component sync_block
  port (
    clk                 : in  std_logic;
    data_in             : in  std_logic;
    data_out            : out std_logic
    );
  end component;


  ------------------------------------------------------------------------------
  -- Define internal signals
  ------------------------------------------------------------------------------

  signal VCC                  : std_logic;
  signal GND                  : std_logic_vector(0 downto 0);
  signal GND_BUS              : std_logic_vector(8 downto 0);

  -- Encoded read state machine states.
  type rd_state_typ is       (IDLE_s,
                              QUEUE1_s,
                              QUEUE2_s,
                              QUEUE3_s,
                              QUEUE_ACK_s,
                              WAIT_ACK_s,
                              FRAME_s,
                              HANDSHAKE_s,
                              FINISH_s,
                              DROP_ERROR_s,
                              DROP_s,
                              RETRANSMIT_ERROR_s,
                              RETRANSMIT_s);

  signal rd_state             : rd_state_typ;
  signal rd_nxt_state         : rd_state_typ;

  -- Encoded write state machine states,
  type wr_state_typ is       (WAIT_s,
                              DATA_s,
                              EOF_s,
                              OVFLOW_s);

  signal wr_state             : wr_state_typ;
  signal wr_nxt_state         : wr_state_typ;

  type data_pipe is array (0 to 1) of std_logic_vector(7 downto 0);
  type cntl_pipe is array (0 to 1) of std_logic;

  signal wr_eof_data_bram     : std_logic_vector(8 downto 0);
  signal wr_data_bram         : std_logic_vector(7 downto 0);
  signal wr_data_pipe         : data_pipe;
  signal wr_sof_pipe          : cntl_pipe;
  signal wr_eof_pipe          : cntl_pipe;
  signal wr_accept_pipe       : cntl_pipe;
  signal wr_accept_bram       : std_logic;
  signal wr_sof_int           : std_logic;
  signal wr_eof_bram          : std_logic_vector(0 downto 0);
  signal wr_eof_reg           : std_logic;
  signal wr_addr              : unsigned(11 downto 0);
  signal wr_addr_inc          : std_logic;
  signal wr_start_addr_load   : std_logic;
  signal wr_addr_reload       : std_logic;
  signal wr_start_addr        : unsigned(11 downto 0);
  signal wr_fifo_full         : std_logic;
  signal wr_en                : std_logic;
  signal wr_en_u              : std_logic;
  signal wr_en_u_bram         : std_logic_vector(0 downto 0);
  signal wr_en_l              : std_logic;
  signal wr_en_l_bram         : std_logic_vector(0 downto 0);
  signal wr_ovflow_dst_rdy    : std_logic;
  signal tx_axis_fifo_tready_int_n : std_logic;

  signal frame_in_fifo        : std_logic;
  signal rd_eof               : std_logic;
  signal rd_eof_pipe          : std_logic;
  signal rd_eof_reg           : std_logic;
  signal rd_addr              : unsigned(11 downto 0);
  signal rd_addr_inc          : std_logic;
  signal rd_addr_reload       : std_logic;
  signal rd_bram_u_unused     : std_logic_vector(8 downto 0);
  signal rd_bram_l_unused     : std_logic_vector(8 downto 0);
  signal rd_eof_data_bram_u   : std_logic_vector(8 downto 0);
  signal rd_eof_data_bram_l   : std_logic_vector(8 downto 0);
  signal rd_data_bram_u       : std_logic_vector(7 downto 0);
  signal rd_data_bram_l       : std_logic_vector(7 downto 0);
  signal rd_data_pipe_u       : std_logic_vector(7 downto 0);
  signal rd_data_pipe_l       : std_logic_vector(7 downto 0);
  signal rd_data_pipe         : std_logic_vector(7 downto 0);
  signal rd_eof_bram_u        : std_logic_vector(0 downto 0);
  signal rd_eof_bram_l        : std_logic_vector(0 downto 0);
  signal rd_en                : std_logic;
  signal rd_bram_u            : std_logic;
  signal rd_bram_u_reg        : std_logic;

  signal rd_addr_slv          : std_logic_vector(10 downto 0);
  signal wr_addr_slv          : std_logic_vector(10 downto 0);

  signal rd_tran_frame_tog    : std_logic := '0';
  signal wr_tran_frame_sync   : std_logic;
  signal wr_tran_frame_delay  : std_logic := '0';
  signal rd_retran_frame_tog  : std_logic := '0';
  signal wr_retran_frame_sync : std_logic;
  signal wr_retran_frame_delay : std_logic := '0';
  signal wr_store_frame       : std_logic;
  signal wr_eof_state         : std_logic;
  signal wr_eof_state_reg     : std_logic;
  signal wr_transmit_frame    : std_logic;
  signal wr_retransmit_frame  : std_logic;
  signal wr_frames            : std_logic_vector(8 downto 0);
  signal wr_frame_in_fifo     : std_logic;

  signal rd_16_count          : unsigned(3 downto 0);
  signal rd_txfer_en          : std_logic;
  signal rd_addr_txfer        : unsigned(11 downto 0);
  signal rd_txfer_tog         : std_logic := '0';
  signal wr_txfer_tog_sync    : std_logic;
  signal wr_txfer_tog_delay   : std_logic := '0';
  signal wr_txfer_en          : std_logic;
  signal wr_rd_addr           : unsigned(11 downto 0);
  signal wr_addr_diff         : unsigned(11 downto 0);

  signal wr_fifo_status       : unsigned(3 downto 0);

  signal rd_drop_frame        : std_logic;
  signal rd_retransmit        : std_logic;

  signal rd_start_addr        : unsigned(11 downto 0);
  signal rd_start_addr_load   : std_logic;
  signal rd_start_addr_reload : std_logic;

  signal rd_dec_addr          : unsigned(11 downto 0);

  signal rd_transmit_frame    : std_logic;
  signal rd_retransmit_frame  : std_logic;
  signal rd_col_window_expire : std_logic;
  signal rd_col_window_pipe   : cntl_pipe;
  signal wr_col_window_pipe   : cntl_pipe;
  signal wr_fifo_overflow     : std_logic;
  signal rd_slot_timer        : unsigned(9 downto 0);
  signal wr_col_window_expire : std_logic;
  signal rd_idle_state        : std_logic;

  signal tx_axis_mac_tdata_int_frame       : std_logic_vector(7 downto 0);
  signal tx_axis_mac_tdata_int_handshake   : std_logic_vector(7 downto 0);
  signal tx_axis_mac_tdata_int             : std_logic_vector(7 downto 0);
  signal tx_axis_mac_tvalid_int_finish     : std_logic;
  signal tx_axis_mac_tvalid_int_droperror  : std_logic;
  signal tx_axis_mac_tvalid_int_retransmiterror : std_logic;
  signal tx_axis_mac_tlast_int_frame_handshake : std_logic;
  signal tx_axis_mac_tlast_int_finish      : std_logic;
  signal tx_axis_mac_tlast_int_droperror   : std_logic;
  signal tx_axis_mac_tlast_int_retransmiterror : std_logic;
  signal tx_axis_mac_tuser_int_droperror   : std_logic;
  signal tx_axis_mac_tuser_int_retransmit  : std_logic;

  signal tx_fifo_reset                     : std_logic;
  signal tx_mac_reset                      : std_logic;

  -- Small delay for simulation purposes.
  constant dly : time := 1 ps;


  ------------------------------------------------------------------------------
  -- Attributes for FIFO simulation and synthesis
  ------------------------------------------------------------------------------
  -- ASYNC_REG attributes added to simulate actual behaviour under
  -- asynchronous operating conditions.
  attribute ASYNC_REG                          : string;
  attribute ASYNC_REG of wr_rd_addr            : signal is "TRUE";
  attribute ASYNC_REG of wr_col_window_pipe    : signal is "TRUE";


  ------------------------------------------------------------------------------
  -- Begin FIFO architecture
  ------------------------------------------------------------------------------

begin

  VCC     <= '1';
  GND     <= (others => '0');
  GND_BUS <= (others => '0');

  -- invert reset sense as architecture is optimised for active high resets
  tx_fifo_reset <= not tx_fifo_resetn;
  tx_mac_reset  <= not tx_mac_resetn;


  ------------------------------------------------------------------------------
  -- Write state machine and control
  ------------------------------------------------------------------------------

  -- Write state machine.
  -- States are WAIT, DATA, EOF, OVFLOW.
  -- Clock state to next state.
  clock_wrs_p : process(tx_fifo_aclk)
  begin
     if (tx_fifo_aclk'event and tx_fifo_aclk = '1') then
        if tx_fifo_reset = '1' then
           wr_state <= WAIT_s after dly;
        else
           wr_state <= wr_nxt_state after dly;
        end if;
     end if;
  end process clock_wrs_p;

  -- Decode next state, combinitorial.
  next_wrs_p : process(wr_state, wr_sof_pipe(1), wr_eof_pipe(0), wr_eof_pipe(1),
                       wr_eof_bram(0), wr_fifo_overflow)
  begin
  case wr_state is
     when WAIT_s =>
        if wr_sof_pipe(1) = '1'  and wr_eof_pipe(1) = '0' then
           wr_nxt_state <= DATA_s;
        else
           wr_nxt_state <= WAIT_s;
        end if;

     when DATA_s =>
        -- Wait for the end of frame to be detected.
        if wr_fifo_overflow = '1' and wr_eof_pipe(0) = '0'
           and wr_eof_pipe(1) = '0' then
           wr_nxt_state <= OVFLOW_s;
        elsif wr_eof_pipe(1) = '1' then
           wr_nxt_state <= EOF_s;
        else
           wr_nxt_state <= DATA_s;
        end if;

     when EOF_s =>
        -- If the start of frame is already in the pipe, a back-to-back frame
        -- transmission has occured. Move straight back to frame state.
        if wr_sof_pipe(1) = '1' and wr_eof_pipe(1) = '0' then
           wr_nxt_state <= DATA_s;
        elsif wr_eof_bram(0) = '1' then
           wr_nxt_state <= WAIT_s;
        else
           wr_nxt_state <= EOF_s;
        end if;

     when OVFLOW_s =>
        -- Wait until the end of frame is reached before clearing the overflow.
        if wr_eof_bram(0) = '1' then
           wr_nxt_state <= WAIT_s;
        else
           wr_nxt_state <= OVFLOW_s;
        end if;

     when others =>
        wr_nxt_state <= WAIT_s;
  end case;
  end process;

  -- Decode output signals, combinatorial.
  -- wr_en is used to enable the BRAM write and the address to increment.
  wr_en <= '0' when wr_state = OVFLOW_s else wr_accept_bram;

  -- The upper and lower signals are used to distinguish between the upper and
  -- lower BRAMs.
  wr_en_l <= wr_en and not(wr_addr(11));
  wr_en_u <= wr_en and     wr_addr(11);
  wr_en_l_bram(0) <= wr_en_l;
  wr_en_u_bram(0) <= wr_en_u;

  wr_addr_inc <= wr_en;

  wr_addr_reload <= '1' when wr_state = OVFLOW_s else '0';
  wr_start_addr_load <= '1' when wr_state = EOF_s and wr_nxt_state = WAIT_s
                        else
                        '1' when wr_state = EOF_s and wr_nxt_state = DATA_s
                        else  '0';

  -- Pause the AxiStream handshake when the FIFO is full.
  tx_axis_fifo_tready_int_n <= wr_ovflow_dst_rdy when wr_state = OVFLOW_s
                       else wr_fifo_full;

  tx_axis_fifo_tready <= not tx_axis_fifo_tready_int_n;

  -- Generate user overflow indicator.
  fifo_overflow <= '1' when wr_state = OVFLOW_s else '0';

  -- When in overflow and have captured ovflow EOF, set tx_axis_fifo_tready again.
  p_ovflow_dst_rdy : process (tx_fifo_aclk)
  begin
     if tx_fifo_aclk'event and tx_fifo_aclk = '1' then
        if tx_fifo_reset = '1' then
           wr_ovflow_dst_rdy <= '0' after dly;
        else
           if wr_fifo_overflow = '1' and wr_state = DATA_s then
              wr_ovflow_dst_rdy <= '0' after dly;
           elsif tx_axis_fifo_tvalid = '1' and tx_axis_fifo_tlast = '1' then
              wr_ovflow_dst_rdy <= '1' after dly;
           end if;
        end if;
     end if;
  end process;

  -- EOF signals for use in overflow logic.
  wr_eof_state <= '1' when wr_state = EOF_s else '0';

  p_reg_eof_st : process (tx_fifo_aclk)
  begin
     if tx_fifo_aclk'event and tx_fifo_aclk = '1' then
        if tx_fifo_reset = '1' then
           wr_eof_state_reg <= '0' after dly;
        else
           wr_eof_state_reg <= wr_eof_state after dly;
        end if;
     end if;
  end process;


  ------------------------------------------------------------------------------
  -- Read state machine and control
  ------------------------------------------------------------------------------

  -- Read state machine.
  -- States are IDLE, QUEUE1, QUEUE2, QUEUE3, QUEUE_ACK, WAIT_ACK, FRAME,
  -- HANDSHAKE, FINISH, DROP_ERROR, DROP, RETRANSMIT_ERROR, RETRANSMIT.
  -- Clock state to next state.
  clock_rds_p : process(tx_mac_aclk)
  begin
     if (tx_mac_aclk'event and tx_mac_aclk = '1') then
        if tx_mac_reset = '1' then
           rd_state <= IDLE_s after dly;
        else
           rd_state <= rd_nxt_state after dly;
        end if;
     end if;
  end process clock_rds_p;

  ------------------------------------------------------------------------------
  -- Full duplex-only state machine.
gen_fd_sm : if (FULL_DUPLEX_ONLY = TRUE) generate
  -- Decode next state, combinatorial.
  next_rds_p : process(rd_state, frame_in_fifo, rd_eof, rd_eof_reg, tx_axis_mac_tready)
  begin
  case rd_state is
           when IDLE_s =>
              -- If there is a frame in the FIFO, start to queue the new frame
              -- to the output.
              if frame_in_fifo = '1' then
                 rd_nxt_state <= QUEUE1_s;
              else
                 rd_nxt_state <= IDLE_s;
              end if;

           -- Load the output pipeline, which takes three clock cycles.
           when QUEUE1_s =>
              rd_nxt_state <= QUEUE2_s;

           when QUEUE2_s =>
              rd_nxt_state <= QUEUE3_s;

           when QUEUE3_s =>
              rd_nxt_state <= QUEUE_ACK_s;

           when QUEUE_ACK_s =>
              -- The pipeline is full and the frame output starts now.
              rd_nxt_state <= WAIT_ACK_s;

           when WAIT_ACK_s =>
              -- Await the tx_axis_mac_tready acknowledge before moving on.
              if tx_axis_mac_tready = '1' then
                 rd_nxt_state <= FRAME_s;
              else
                 rd_nxt_state <= WAIT_ACK_s;
              end if;

           when FRAME_s =>
              -- Read the frame out of the FIFO. If the MAC deasserts
              -- tx_axis_mac_tready, stall in the handshake state. If the EOF
              -- flag is encountered, move to the finish state.
              if tx_axis_mac_tready = '0' then
                 rd_nxt_state <= HANDSHAKE_s;
              elsif rd_eof = '1' then
                 rd_nxt_state <= FINISH_s;
              else
                 rd_nxt_state <= FRAME_s;
              end if;

           when HANDSHAKE_s =>
              -- Await tx_axis_mac_tready before continuing frame transmission.
              -- If the EOF flag is encountered, move to the finish state.
              if tx_axis_mac_tready = '1' and rd_eof_reg = '1' then
                 rd_nxt_state <= FINISH_s;
              elsif tx_axis_mac_tready = '1' and rd_eof_reg = '0' then
                 rd_nxt_state <= FRAME_s;
              else
                 rd_nxt_state <= HANDSHAKE_s;
              end if;

           when FINISH_s =>
              -- Frame has finished. Assure that the MAC has accepted the final
              -- byte by transitioning to idle only when tx_axis_mac_tready is high.
              if tx_axis_mac_tready = '1' then
                 rd_nxt_state <= IDLE_s;
              else
                 rd_nxt_state <= FINISH_s;
              end if;

           when others =>
                 rd_nxt_state <= IDLE_s;
        end case;
  end process next_rds_p;
end generate gen_fd_sm;

  ------------------------------------------------------------------------------
  -- Full and half duplex state machine.
gen_hd_sm : if (FULL_DUPLEX_ONLY = FALSE) generate
  -- Decode the next state, combinatorial.
  next_rds_p : process(rd_state, frame_in_fifo, rd_eof_reg, tx_axis_mac_tready,
                       rd_drop_frame, rd_retransmit)
  begin
  case rd_state is
           when IDLE_s =>
              -- If a retransmit request is detected then prepare to retransmit.
              if rd_retransmit = '1' then
                 rd_nxt_state <= RETRANSMIT_ERROR_s;
              -- If there is a frame in the FIFO, then queue the new frame to
              -- the output.
              elsif frame_in_fifo = '1' then
                 rd_nxt_state <= QUEUE1_s;
              else
                 rd_nxt_state <= IDLE_s;
              end if;

           -- Load the output pipeline, which takes three clock cycles.
           when QUEUE1_s =>
              if rd_retransmit = '1' then
                 rd_nxt_state <= RETRANSMIT_ERROR_s;
              else
                rd_nxt_state <= QUEUE2_s;
              end if;

           when QUEUE2_s =>
              if rd_retransmit = '1' then
                 rd_nxt_state <= RETRANSMIT_ERROR_s;
              else
                 rd_nxt_state <= QUEUE3_s;
              end if;

           when QUEUE3_s =>
              if rd_retransmit = '1' then
                 rd_nxt_state <= RETRANSMIT_ERROR_s;
              else
                 rd_nxt_state <= QUEUE_ACK_s;
              end if;

           when QUEUE_ACK_s =>
              -- The pipeline is full and the frame output starts now.
              if rd_retransmit = '1' then
                 rd_nxt_state <= RETRANSMIT_ERROR_s;
              else
                 rd_nxt_state <= WAIT_ACK_s;
              end if;

           when WAIT_ACK_s =>
              -- Await the tx_axis_mac_tready acknowledge before moving on.
              if rd_retransmit = '1' then
                 rd_nxt_state <= RETRANSMIT_ERROR_s;
              elsif tx_axis_mac_tready = '1' then
                 rd_nxt_state <= FRAME_s;
              else
                 rd_nxt_state <= WAIT_ACK_s;
              end if;

           when FRAME_s =>
              -- If a collision-only request, then must drop the rest of the
              -- current frame. If a collision and retransmit, then prepare
              -- to retransmit the frame.
              if rd_drop_frame = '1' then
                 rd_nxt_state <= DROP_ERROR_s;
              elsif rd_retransmit = '1' then
                 rd_nxt_state <= RETRANSMIT_ERROR_s;
              -- Read the frame out of the FIFO. If the MAC deasserts
              -- tx_axis_mac_tready, stall in the handshake state. If the EOF
              -- flag is encountered, move to the finish state.
              elsif tx_axis_mac_tready = '0' then
                 rd_nxt_state <= HANDSHAKE_s;
              elsif rd_eof_reg = '1' then
                 rd_nxt_state <= FINISH_s;
              else
                 rd_nxt_state <= FRAME_s;
              end if;

           when HANDSHAKE_s =>
              -- Await tx_axis_mac_tready before continuing frame transmission.
              -- If the EOF flag is encountered, move to the finish state.
              if rd_retransmit = '1' then
                 rd_nxt_state <= RETRANSMIT_ERROR_s;
              elsif tx_axis_mac_tready = '1' and rd_eof_reg = '1' then
                 rd_nxt_state <= FINISH_s;
              elsif tx_axis_mac_tready = '1' and rd_eof_reg = '0' then
                 rd_nxt_state <= FRAME_s;
              else
                 rd_nxt_state <= HANDSHAKE_s;
              end if;

           when FINISH_s =>
              -- Frame has finished. Assure that the MAC has accepted the final
              -- byte by transitioning to idle only when tx_axis_mac_tready is high.
              if rd_retransmit = '1' then
                 rd_nxt_state <= RETRANSMIT_ERROR_s;
              elsif tx_axis_mac_tready = '1' then
                 rd_nxt_state <= IDLE_s;
              else
                 rd_nxt_state <= FINISH_s;
              end if;

           when DROP_ERROR_s =>
              -- FIFO is ready to drop the frame. Assure that the MAC has
              -- accepted the final byte and error signal before dropping.
              if tx_axis_mac_tready = '1' then
                 rd_nxt_state <= DROP_s;
              else
                 rd_nxt_state <= DROP_ERROR_s;
              end if;

           when DROP_s =>
              -- Wait until rest of frame has been cleared.
              if rd_eof_reg = '1' then
                 rd_nxt_state <= IDLE_s;
              else
                 rd_nxt_state <= DROP_s;
              end if;

           when RETRANSMIT_ERROR_s =>
              -- FIFO is ready to retransmit the frame. Assure that the MAC has
              -- accepted the final byte and error signal before retransmitting.
              if tx_axis_mac_tready = '1' then
                 rd_nxt_state <= RETRANSMIT_s;
              else
                 rd_nxt_state <= RETRANSMIT_ERROR_s;
              end if;

           when RETRANSMIT_s =>
              -- Reload the data pipeline from the start of the frame.
              rd_nxt_state <= QUEUE1_s;

           when others =>
              rd_nxt_state <= IDLE_s;
        end case;
  end process next_rds_p;
end generate gen_hd_sm;


  -- Combinatorially select tdata candidates.
  tx_axis_mac_tdata_int_frame <= tx_axis_mac_tdata_int when rd_nxt_state = HANDSHAKE_s
                                else rd_data_pipe;
  tx_axis_mac_tdata_int_handshake <= rd_data_pipe     when rd_nxt_state = FINISH_s
                                else tx_axis_mac_tdata_int;
  tx_axis_mac_tdata          <= tx_axis_mac_tdata_int;

  -- Decode output tdata based on current and next read state.
  rd_data_decode_p : process(tx_mac_aclk)
  begin
     if (tx_mac_aclk'event and tx_mac_aclk = '1') then
        if rd_nxt_state = FRAME_s then
           tx_axis_mac_tdata_int <= rd_data_pipe after dly;
        elsif (rd_nxt_state = RETRANSMIT_ERROR_s or rd_nxt_state = DROP_ERROR_s)
           then tx_axis_mac_tdata_int <= tx_axis_mac_tdata_int after dly;
        else
           case rd_state is
              when QUEUE_ACK_s =>
                 tx_axis_mac_tdata_int <= rd_data_pipe after dly;
              when FRAME_s =>
                 tx_axis_mac_tdata_int <= tx_axis_mac_tdata_int_frame after dly;
              when HANDSHAKE_s =>
                 tx_axis_mac_tdata_int <= tx_axis_mac_tdata_int_handshake after dly;
              when others =>
                 tx_axis_mac_tdata_int <= tx_axis_mac_tdata_int after dly;
           end case;
        end if;
     end if;
  end process rd_data_decode_p;

  -- Combinatorially select tvalid candidates.
  tx_axis_mac_tvalid_int_finish     <= '0' when rd_nxt_state = IDLE_s
                                       else '1';
  tx_axis_mac_tvalid_int_droperror  <= '0' when rd_nxt_state = DROP_s
                                       else '1';
  tx_axis_mac_tvalid_int_retransmiterror <= '0' when rd_nxt_state = RETRANSMIT_s
                                       else '1';

  -- Decode output tvalid based on current and next read state.
  rd_dv_decode_p : process(tx_mac_aclk)
  begin
     if (tx_mac_aclk'event and tx_mac_aclk = '1') then
        if rd_nxt_state = FRAME_s then
           tx_axis_mac_tvalid <= '1' after dly;
        elsif (rd_nxt_state = RETRANSMIT_ERROR_s or rd_nxt_state = DROP_ERROR_s)
           then tx_axis_mac_tvalid <= '1' after dly;
        else
           case rd_state is
              when QUEUE_ACK_s =>
                 tx_axis_mac_tvalid <= '1' after dly;
              when WAIT_ACK_s =>
                 tx_axis_mac_tvalid <= '1' after dly;
              when FRAME_s =>
                 tx_axis_mac_tvalid <= '1' after dly;
              when HANDSHAKE_s =>
                 tx_axis_mac_tvalid <= '1' after dly;
              when FINISH_s =>
                 tx_axis_mac_tvalid <= tx_axis_mac_tvalid_int_finish after dly;
              when DROP_ERROR_s =>
                 tx_axis_mac_tvalid <= tx_axis_mac_tvalid_int_droperror after dly;
              when RETRANSMIT_ERROR_s =>
                 tx_axis_mac_tvalid <= tx_axis_mac_tvalid_int_retransmiterror after dly;
              when others =>
                 tx_axis_mac_tvalid <= '0' after dly;
           end case;
        end if;
     end if;
  end process rd_dv_decode_p;

  -- Combinatorially select tlast candidates.
  tx_axis_mac_tlast_int_frame_handshake <= rd_eof_reg when rd_nxt_state = FINISH_s
                                      else '0';
  tx_axis_mac_tlast_int_finish     <= '0' when rd_nxt_state = IDLE_s
                                      else rd_eof_reg;
  tx_axis_mac_tlast_int_droperror  <= '0' when rd_nxt_state = DROP_s
                                      else '1';
  tx_axis_mac_tlast_int_retransmiterror <= '0' when rd_nxt_state = RETRANSMIT_s
                                      else '1';

  -- Decode output tlast based on current and next read state.
  rd_last_decode_p : process(tx_mac_aclk)
  begin
     if (tx_mac_aclk'event and tx_mac_aclk = '1') then
        if rd_nxt_state = FRAME_s then
           tx_axis_mac_tlast <= rd_eof after dly;
        elsif (rd_nxt_state = RETRANSMIT_ERROR_s or rd_nxt_state = DROP_ERROR_s)
           then tx_axis_mac_tlast <= '1' after dly;
        else
           case rd_state is
              when WAIT_ACK_s =>
                 tx_axis_mac_tlast <= rd_eof after dly;
              when FRAME_s =>
                 tx_axis_mac_tlast <= tx_axis_mac_tlast_int_frame_handshake after dly;
              when HANDSHAKE_s =>
                 tx_axis_mac_tlast <= tx_axis_mac_tlast_int_frame_handshake after dly;
              when FINISH_s =>
                 tx_axis_mac_tlast <= tx_axis_mac_tlast_int_finish after dly;
              when DROP_ERROR_s =>
                 tx_axis_mac_tlast <= tx_axis_mac_tlast_int_droperror after dly;
              when RETRANSMIT_ERROR_s =>
                 tx_axis_mac_tlast <= tx_axis_mac_tlast_int_retransmiterror after dly;
              when others =>
                 tx_axis_mac_tlast <= '0' after dly;
           end case;
        end if;
     end if;
  end process rd_last_decode_p;

  -- Combinatorially select tuser candidates.
  tx_axis_mac_tuser_int_droperror <= '0' when rd_nxt_state = DROP_s
                                 else '1';
  tx_axis_mac_tuser_int_retransmit <= '0' when rd_nxt_state = RETRANSMIT_s
                                 else '1';

  -- Decode output tuser based on current and next read state.
  rd_user_decode_p : process(tx_mac_aclk)
  begin
     if (tx_mac_aclk'event and tx_mac_aclk = '1') then
        if (rd_nxt_state = RETRANSMIT_ERROR_s or rd_nxt_state = DROP_ERROR_s)
           then tx_axis_mac_tuser <= '1' after dly;
        else
           case rd_state is
              when DROP_ERROR_s =>
                 tx_axis_mac_tuser <= tx_axis_mac_tuser_int_droperror after dly;
              when RETRANSMIT_ERROR_s =>
                 tx_axis_mac_tuser <= tx_axis_mac_tuser_int_retransmit after dly;
              when others =>
                 tx_axis_mac_tuser <= '0' after dly;
           end case;
        end if;
     end if;
  end process rd_user_decode_p;

  ------------------------------------------------------------------------------
  -- Decode full duplex-only control signals.
gen_fd_decode : if (FULL_DUPLEX_ONLY = TRUE) generate

  -- rd_en is used to enable the BRAM read and load the output pipeline.
  rd_en <= '0' when rd_state = IDLE_s else
           '1' when rd_nxt_state = FRAME_s else
           '0' when (rd_state = FRAME_s and rd_nxt_state = HANDSHAKE_s) else
           '0' when rd_nxt_state = HANDSHAKE_s else
           '0' when rd_state = FINISH_s else
           '0' when rd_state = WAIT_ACK_s else '1';

  -- When the BRAM is being read, enable the read address to be incremented.
  rd_addr_inc <=  rd_en;

  rd_addr_reload <= '1' when rd_state /= FINISH_s and rd_nxt_state = FINISH_s
                    else '0';

  -- Transmit frame pulse must never be more frequent than once per 64 clocks to
  -- allow toggle to cross clock domain.
  rd_transmit_frame <= '1' when rd_state = WAIT_ACK_s and rd_nxt_state = FRAME_s
                       else '0';

  -- Unused for full duplex only.
  rd_start_addr_reload <= '0';
  rd_start_addr_load   <= '0';
  rd_retransmit_frame  <= '0';

end generate gen_fd_decode;

  ------------------------------------------------------------------------------
  -- Decode full and half duplex control signals.
gen_hd_decode : if (FULL_DUPLEX_ONLY = FALSE) generate

  -- rd_en is used to enable the BRAM read and load the output pipeline.
  rd_en <= '0' when rd_state = IDLE_s else
           '0' when rd_nxt_state = DROP_ERROR_s else
           '0' when (rd_nxt_state = DROP_s and rd_eof = '1') else
           '1' when rd_nxt_state = FRAME_s else
           '0' when (rd_state = FRAME_s and rd_nxt_state = HANDSHAKE_s) else
           '0' when rd_nxt_state = HANDSHAKE_s else
           '0' when rd_state = FINISH_s else
           '0' when rd_state = RETRANSMIT_ERROR_s else
           '0' when rd_state = RETRANSMIT_s else
           '0' when rd_state = WAIT_ACK_s else '1';

  -- When the BRAM is being read, enable the read address to be incremented.
  rd_addr_inc <=  rd_en;

  rd_addr_reload <= '1' when rd_state /= FINISH_s and rd_nxt_state = FINISH_s
                    else
                    '1' when rd_state = DROP_s and rd_nxt_state = IDLE_s
                    else '0';

  -- Assertion indicates that the starting address must be reloaded to enable
  -- the current frame to be retransmitted.
  rd_start_addr_reload <= '1' when rd_state = RETRANSMIT_s else '0';

  rd_start_addr_load <= '1' when rd_state= WAIT_ACK_s and rd_nxt_state = FRAME_s
                        else
                        '1' when rd_col_window_expire = '1' else '0';

  -- Transmit frame pulse must never be more frequent than once per 64 clocks to
  -- allow toggle to cross clock domain.
  rd_transmit_frame <= '1' when rd_state = WAIT_ACK_s and rd_nxt_state = FRAME_s
                       else '0';

  -- Retransmit frame pulse must never be more frequent than once per 16 clocks
  -- to allow toggle to cross clock domain.
  rd_retransmit_frame <= '1' when rd_state = RETRANSMIT_s else '0';

end generate gen_hd_decode; -- half duplex control signals


  ------------------------------------------------------------------------------
  -- Frame count
  -- We need to maintain a count of frames in the FIFO, so that we know when a
  -- frame is available for transmission. The counter must be held on the write
  -- clock domain as this is the faster clock if they differ.
  ------------------------------------------------------------------------------

  -- A frame has been written to the FIFO.
  wr_store_frame <= '1' when wr_state = EOF_s and wr_nxt_state /= EOF_s
                    else '0';

  -- Generate a toggle to indicate when a frame has been transmitted by the FIFO.
  p_rd_trans_tog : process (tx_mac_aclk)
  begin
     if tx_mac_aclk'event and tx_mac_aclk = '1' then
        if rd_transmit_frame = '1' then
           rd_tran_frame_tog <= not rd_tran_frame_tog after dly;
        end if;
     end if;
  end process;

  -- Synchronize the read transmit frame signal into the write clock domain.
  resync_rd_tran_frame_tog : sync_block
  port map (
    clk       => tx_fifo_aclk,
    data_in   => rd_tran_frame_tog,
    data_out  => wr_tran_frame_sync
  );

  -- Edge-detect of the resynchronized transmit frame signal.

  p_delay_wr_trans : process (tx_fifo_aclk)
  begin
    if tx_fifo_aclk'event and tx_fifo_aclk = '1' then
      wr_tran_frame_delay <= wr_tran_frame_sync after dly;
    end if;
  end process p_delay_wr_trans;

  p_sync_wr_trans : process (tx_fifo_aclk)
  begin
    if tx_fifo_aclk'event and tx_fifo_aclk = '1' then
      if tx_fifo_reset = '1' then
        wr_transmit_frame   <= '0' after dly;
      else
        -- Edge detector
        if (wr_tran_frame_delay xor wr_tran_frame_sync) = '1' then
          wr_transmit_frame <= '1' after dly;
        else
          wr_transmit_frame <= '0' after dly;
        end if;
      end if;
    end if;
  end process p_sync_wr_trans;

  ------------------------------------------------------------------------------
  -- Full duplex-only frame count.
gen_fd_count : if (FULL_DUPLEX_ONLY = TRUE) generate

  -- Count the number of frames in the FIFO. The counter is incremented when a
  -- frame is stored and decremented when a frame is transmitted. Need to keep
  -- the counter on the write clock as this is the fastest clock if they differ.
  p_wr_frames : process (tx_fifo_aclk)
  begin
    if tx_fifo_aclk'event and tx_fifo_aclk = '1' then
      if tx_fifo_reset = '1' then
        wr_frames <= (others => '0') after dly;
      else
         if (wr_store_frame and not wr_transmit_frame) = '1' then
            wr_frames <= wr_frames + 1 after dly;
         elsif (not wr_store_frame and wr_transmit_frame) = '1' then
            wr_frames <= wr_frames - 1 after dly;
         end if;
      end if;
    end if;
  end process p_wr_frames;
end generate gen_fd_count;

  ------------------------------------------------------------------------------
  -- Full and half duplex frame count.
gen_hd_count : if (FULL_DUPLEX_ONLY = FALSE) generate

  -- Generate a toggle to indicate when a frame has been retransmitted from
  -- the FIFO.
  p_rd_retran_tog : process (tx_mac_aclk)
  begin
     if tx_mac_aclk'event and tx_mac_aclk = '1' then
        if rd_retransmit_frame = '1' then
           rd_retran_frame_tog <= not rd_retran_frame_tog after dly;
        end if;
     end if;
  end process;

  -- Synchronize the read retransmit frame signal into the write clock domain.
  resync_rd_tran_frame_tog : sync_block
  port map (
    clk       => tx_fifo_aclk,
    data_in   => rd_retran_frame_tog,
    data_out  => wr_retran_frame_sync
  );

  -- Edge detect of the resynchronized read transmit frame signal.

  p_delay_wr_trans : process (tx_fifo_aclk)
  begin
    if tx_fifo_aclk'event and tx_fifo_aclk = '1' then
      wr_retran_frame_delay <= wr_retran_frame_sync after dly;
    end if;
  end process p_delay_wr_trans;

  p_sync_wr_trans : process (tx_fifo_aclk)
  begin
    if tx_fifo_aclk'event and tx_fifo_aclk = '1' then
      if tx_fifo_reset = '1' then
        wr_retransmit_frame   <= '0' after dly;
      else
        -- Edge detector
        if (wr_retran_frame_delay xor wr_retran_frame_sync) = '1' then
          wr_retransmit_frame <= '1' after dly;
        else
          wr_retransmit_frame <= '0' after dly;
        end if;
      end if;
    end if;
  end process p_sync_wr_trans;

  -- Count the number of frames in the FIFO. The counter is incremented when a
  -- frame is stored or retransmitted and decremented when a frame is
  -- transmitted. Need to keep the counter on the write clock as this is the
  -- fastest clock if they differ. Logic assumes transmit and retransmit cannot
  -- happen at same time.
  p_wr_frames : process (tx_fifo_aclk)
  begin
    if tx_fifo_aclk'event and tx_fifo_aclk = '1' then
      if tx_fifo_reset = '1' then
        wr_frames <= (others => '0') after dly;
      else
         if (wr_store_frame and wr_retransmit_frame) = '1' then
            wr_frames <= wr_frames + 2 after dly;
         elsif ((wr_store_frame or wr_retransmit_frame)
               and not wr_transmit_frame) = '1' then
            wr_frames <= wr_frames + 1 after dly;
         elsif (wr_transmit_frame and not wr_store_frame) = '1' then
            wr_frames <= wr_frames - 1 after dly;
         end if;
      end if;
    end if;
  end process p_wr_frames;
end generate gen_hd_count;

  -- Generate a frame in FIFO signal for use in control logic.
  p_wr_avail : process (tx_fifo_aclk)
  begin
    if tx_fifo_aclk'event and tx_fifo_aclk = '1' then
      if tx_fifo_reset = '1' then
        wr_frame_in_fifo <= '0' after dly;
      else
        if wr_frames /= (wr_frames'range => '0') then
          wr_frame_in_fifo <= '1' after dly;
        else
          wr_frame_in_fifo <= '0' after dly;
        end if;
      end if;
    end if;
  end process p_wr_avail;

  -- Synchronize it back onto read domain for use in the read logic.
  resync_wr_frame_in_fifo : sync_block
  port map (
    clk       => tx_mac_aclk,
    data_in   => wr_frame_in_fifo,
    data_out  => frame_in_fifo
  );


  ------------------------------------------------------------------------------
  -- Address counters
  ------------------------------------------------------------------------------

  -- Write address is incremented when write enable signal has been asserted
  wr_addr_p : process(tx_fifo_aclk)
  begin
     if (tx_fifo_aclk'event and tx_fifo_aclk = '1') then
        if tx_fifo_reset = '1' then
           wr_addr <= (others => '0') after dly;
        elsif wr_addr_reload = '1' then
           wr_addr <= wr_start_addr after dly;
        elsif wr_addr_inc = '1' then
           wr_addr <= wr_addr + 1 after dly;
        end if;
     end if;
  end process wr_addr_p;

  -- Store the start address in case the address must be reset.
  wr_staddr_p : process(tx_fifo_aclk)
  begin
     if (tx_fifo_aclk'event and tx_fifo_aclk = '1') then
        if tx_fifo_reset = '1' then
           wr_start_addr <= (others => '0') after dly;
        elsif wr_start_addr_load = '1' then
           wr_start_addr <= wr_addr + 1 after dly;
        end if;
     end if;
  end process wr_staddr_p;

  ------------------------------------------------------------------------------
  -- Half duplex-only read address counters.
gen_fd_addr : if (FULL_DUPLEX_ONLY = TRUE) generate
  -- Read address is incremented when read enable signal has been asserted.
  rd_addr_p : process(tx_mac_aclk)
  begin
     if (tx_mac_aclk'event and tx_mac_aclk = '1') then
        if tx_mac_reset = '1' then
           rd_addr <= (others => '0') after dly;
        else
           if rd_addr_reload = '1' then
              rd_addr <= rd_dec_addr after dly;
           elsif rd_addr_inc = '1' then
              rd_addr <= rd_addr + 1 after dly;
           end if;
        end if;
     end if;
  end process rd_addr_p;

  -- Do not need to keep a start address, but the address is needed to
  -- calculate FIFO occupancy.
  rd_start_p : process(tx_mac_aclk)
  begin
     if (tx_mac_aclk'event and tx_mac_aclk = '1') then
        if tx_mac_reset = '1' then
           rd_start_addr <= (others => '0') after dly;
        else
           rd_start_addr <= rd_addr after dly;
       end if;
     end if;
  end process rd_start_p;
end generate gen_fd_addr;

  ------------------------------------------------------------------------------
  -- Full and half duplex read address counters
gen_hd_addr : if (FULL_DUPLEX_ONLY = FALSE) generate
  -- Read address is incremented when read enable signal has been asserted.
  rd_addr_p : process(tx_mac_aclk)
  begin
     if (tx_mac_aclk'event and tx_mac_aclk = '1') then
        if tx_mac_reset = '1' then
           rd_addr <= (others => '0') after dly;
        else
           if rd_addr_reload = '1' then
              rd_addr <= rd_dec_addr after dly;
           elsif rd_start_addr_reload = '1' then
              rd_addr <= rd_start_addr after dly;
           elsif rd_addr_inc = '1' then
              rd_addr <= rd_addr + 1 after dly;
           end if;
        end if;
     end if;
  end process rd_addr_p;

  rd_staddr_p : process(tx_mac_aclk)
  begin
     if (tx_mac_aclk'event and tx_mac_aclk = '1') then
        if tx_mac_reset = '1' then
           rd_start_addr <= (others => '0') after dly;
        else
           if rd_start_addr_load = '1' then
              rd_start_addr <= rd_addr - 4 after dly;
           end if;
        end if;
     end if;
  end process rd_staddr_p;

  -- Collision window expires after MAC has been transmitting for required slot
  -- time.  This is 512 clock cycles at 1Gbps. Also if the end of frame has fully
  -- been transmitted by the MAC then a collision cannot occur. This collision
  -- expiration signal goes high at 768 cycles from the start of the frame.
  -- This is inefficient for short frames, however it should be enough to
  -- prevent the FIFO from locking up.
  rd_col_p : process(tx_mac_aclk)
  begin
     if (tx_mac_aclk'event and tx_mac_aclk = '1') then
        if tx_mac_reset = '1' then
           rd_col_window_expire <= '0' after dly;
        else
           if rd_transmit_frame = '1' then
              rd_col_window_expire <= '0' after dly;
           elsif rd_slot_timer(9 downto 8) = "11" then
              rd_col_window_expire <= '1' after dly;
           end if;
        end if;
     end if;
  end process;

  rd_idle_state <= '1' when rd_state = IDLE_s else '0';

  rd_colreg_p : process(tx_mac_aclk)
  begin
     if (tx_mac_aclk'event and tx_mac_aclk = '1') then
        rd_col_window_pipe(0) <= rd_col_window_expire
                                 and rd_idle_state after dly;
        if rd_txfer_en = '1' then
           rd_col_window_pipe(1) <= rd_col_window_pipe(0) after dly;
        end if;
     end if;
  end process;

  rd_slot_time_p : process(tx_mac_aclk)
  begin
     if (tx_mac_aclk'event and tx_mac_aclk = '1') then
        -- Will not count until after the first frame is sent.
        if tx_mac_reset = '1' then
           rd_slot_timer <= (others => '0') after dly;
        else
           -- Reset counter.
           if rd_transmit_frame = '1' then
              rd_slot_timer <= (others => '0') after dly;
           -- Do not allow counter to roll over, and
           -- only count when frame is being transmitted.
           elsif rd_slot_timer /= "1111111111" then
              rd_slot_timer <= rd_slot_timer + 1 after dly;
           end if;
        end if;
     end if;
  end process;
end generate gen_hd_addr;

  -- Read address generation
  rd_decaddr_p : process(tx_mac_aclk)
  begin
     if (tx_mac_aclk'event and tx_mac_aclk = '1') then
        if tx_mac_reset = '1' then
           rd_dec_addr <= (others => '0') after dly;
        else
           if rd_addr_inc = '1' then
              rd_dec_addr <= rd_addr - 1 after dly;
           end if;
        end if;
     end if;
  end process rd_decaddr_p;

  -- Which BRAM is read from is dependant on the upper bit of the address
  -- space. This needs to be registered to give the correct timing.
  rd_bram_p : process(tx_mac_aclk)
  begin
     if (tx_mac_aclk'event and tx_mac_aclk = '1') then
        if tx_mac_reset = '1' then
           rd_bram_u <= '0' after dly;
           rd_bram_u_reg <= '0' after dly;
        else
           if rd_addr_inc = '1' then
              rd_bram_u <= rd_addr(11) after dly;
              rd_bram_u_reg <= rd_bram_u after dly;
           end if;
        end if;
     end if;
  end process rd_bram_p;


  ------------------------------------------------------------------------------
  -- Data pipelines
  ------------------------------------------------------------------------------

  -- Register data inputs to BRAM.
  -- No resets to allow for SRL16 target.
  reg_din_p : process(tx_fifo_aclk)
  begin
     if (tx_fifo_aclk'event and tx_fifo_aclk = '1') then
        wr_data_pipe(0) <= tx_axis_fifo_tdata after dly;
        if wr_accept_pipe(0) = '1' then
           wr_data_pipe(1) <= wr_data_pipe(0) after dly;
        end if;
        if wr_accept_pipe(1) = '1' then
           wr_data_bram    <= wr_data_pipe(1) after dly;
        end if;
     end if;
  end process reg_din_p;

  -- Start of frame set when tvalid is asserted and previous frame has ended.
  wr_sof_int <= tx_axis_fifo_tvalid and wr_eof_reg;

  -- Set end of frame flag when tlast and tvalid are asserted together.
  -- Reset to logic 1 to enable first frame's start of frame flag.
  reg_eofreg_p : process(tx_fifo_aclk)
  begin
     if (tx_fifo_aclk'event and tx_fifo_aclk = '1') then
        if tx_fifo_reset = '1' then
           wr_eof_reg <= '1';
        else
           if tx_axis_fifo_tvalid = '1' and tx_axis_fifo_tready_int_n = '0'  then
              wr_eof_reg <= tx_axis_fifo_tlast;
           end if;
        end if;
     end if;
  end process reg_eofreg_p;

  -- Pipeline the start of frame flag when the pipe is enabled.
  reg_sof_p : process(tx_fifo_aclk)
  begin
     if (tx_fifo_aclk'event and tx_fifo_aclk = '1') then
         wr_sof_pipe(0) <= wr_sof_int after dly;
         if wr_accept_pipe(0) = '1' then
            wr_sof_pipe(1) <= wr_sof_pipe(0) after dly;
         end if;
     end if;
  end process reg_sof_p;

  -- Pipeline the pipeline enable signal, which is derived from simultaneous
  -- assertion of tvalid and tready.
  reg_acc_p : process(tx_fifo_aclk)
  begin
     if (tx_fifo_aclk'event and tx_fifo_aclk = '1') then
        if (tx_fifo_reset = '1') then
           wr_accept_pipe(0) <= '0' after dly;
           wr_accept_pipe(1) <= '0' after dly;
           wr_accept_bram    <= '0' after dly;
        else
           wr_accept_pipe(0) <= tx_axis_fifo_tvalid and (not tx_axis_fifo_tready_int_n) after dly;
           wr_accept_pipe(1) <= wr_accept_pipe(0) after dly;
           wr_accept_bram    <= wr_accept_pipe(1) after dly;
        end if;
     end if;
  end process reg_acc_p;

  -- Pipeline the end of frame flag when the pipe is enabled.
  reg_eof_p : process(tx_fifo_aclk)
  begin
     if (tx_fifo_aclk'event and tx_fifo_aclk = '1') then
        wr_eof_pipe(0) <= tx_axis_fifo_tvalid and tx_axis_fifo_tlast after dly;
        if wr_accept_pipe(0) = '1' then
           wr_eof_pipe(1) <= wr_eof_pipe(0) after dly;
        end if;
        if wr_accept_pipe(1) = '1' then
           wr_eof_bram(0) <= wr_eof_pipe(1) after dly;
        end if;
     end if;
  end process reg_eof_p;

  -- Register data outputs from BRAM.
  -- No resets to allow SRL16 target.
  reg_dout_p : process(tx_mac_aclk)
  begin
     if (tx_mac_aclk'event and tx_mac_aclk = '1') then
        if rd_en = '1' then
           rd_data_pipe_u <= rd_data_bram_u after dly;
           rd_data_pipe_l <= rd_data_bram_l after dly;
           if rd_bram_u_reg = '1' then
              rd_data_pipe <= rd_data_pipe_u after dly;
           else
              rd_data_pipe <= rd_data_pipe_l after dly;
           end if;
        end if;
     end if;
  end process reg_dout_p;

  reg_eofout_p : process(tx_mac_aclk)
  begin
     if (tx_mac_aclk'event and tx_mac_aclk = '1') then
        if rd_en = '1' then
           if rd_bram_u = '1' then
              rd_eof_pipe <= rd_eof_bram_u(0) after dly;
           else
              rd_eof_pipe <= rd_eof_bram_l(0) after dly;
           end if;
           rd_eof <= rd_eof_pipe after dly;
           rd_eof_reg <= rd_eof or rd_eof_pipe after dly;
        end if;
     end if;
  end process reg_eofout_p;

  ------------------------------------------------------------------------------
  -- Half duplex-only drop and retransmission controls.
gen_hd_input : if (FULL_DUPLEX_ONLY = FALSE) generate
  -- Register the collision without retransmit signal, which is a pulse that
  -- causes the FIFO to drop the frame.
  reg_col_p : process(tx_mac_aclk)
  begin
     if (tx_mac_aclk'event and tx_mac_aclk = '1') then
        rd_drop_frame <= tx_collision and (not tx_retransmit) after dly;
     end if;
  end process reg_col_p;

  -- Register the collision with retransmit signal, which is a pulse that
  -- causes the FIFO to retransmit the frame.
  reg_retr_p : process(tx_mac_aclk)
  begin
     if (tx_mac_aclk'event and tx_mac_aclk = '1') then
        rd_retransmit <= tx_collision and tx_retransmit after dly;
     end if;
  end process reg_retr_p;
end generate gen_hd_input;


  ------------------------------------------------------------------------------
  -- FIFO full functionality
  ------------------------------------------------------------------------------

  -- Full functionality is the difference between read and write addresses.
  -- We cannot use gray code this time as the read address and read start
  -- addresses jump by more than 1.
  -- We generate an enable pulse for the read side every 16 read clocks. This
  -- provides for the worst-case situation where the write clock is 20MHz and
  -- read clock is 125MHz.
  p_rd_16_pulse : process (tx_mac_aclk)
  begin
     if tx_mac_aclk'event and tx_mac_aclk = '1' then
        if tx_mac_reset = '1' then
           rd_16_count <= (others => '0') after dly;
        else
           rd_16_count <= rd_16_count + 1 after dly;
        end if;
     end if;
  end process;

  rd_txfer_en <= '1' when rd_16_count = "1111" else '0';

  -- Register the start address on the enable pulse.
  p_rd_addr_txfer : process (tx_mac_aclk)
  begin
    if tx_mac_aclk'event and tx_mac_aclk = '1' then
       if tx_mac_reset = '1' then
          rd_addr_txfer <= (others => '0') after dly;
       else
          if rd_txfer_en = '1' then
             rd_addr_txfer <= rd_start_addr after dly;
          end if;
       end if;
    end if;
  end process;

  -- Generate a toggle to indicate that the address has been loaded.
  p_rd_tog_txfer : process (tx_mac_aclk)
  begin
    if tx_mac_aclk'event and tx_mac_aclk = '1' then
       if rd_txfer_en = '1' then
          rd_txfer_tog <= not rd_txfer_tog after dly;
       end if;
    end if;
  end process;

  -- Synchronize the toggle to the write side.
  resync_rd_txfer_tog : sync_block
  port map (
    clk       => tx_fifo_aclk,
    data_in   => rd_txfer_tog,
    data_out  => wr_txfer_tog_sync
  );

  -- Delay the synchronized toggle by one cycle.
  p_wr_tog_txfer : process (tx_fifo_aclk)
  begin
     if tx_fifo_aclk'event and tx_fifo_aclk = '1' then
        wr_txfer_tog_delay <= wr_txfer_tog_sync after dly;
     end if;
  end process;

  -- Generate an enable pulse from the toggle. The address should have been
  -- steady on the wr clock input for at least one clock.
  wr_txfer_en <= wr_txfer_tog_delay xor wr_txfer_tog_sync;

  -- Capture the address on the write clock when the enable pulse is high.
  p_wr_addr_txfer : process (tx_fifo_aclk)
  begin
     if tx_fifo_aclk'event and tx_fifo_aclk = '1' then
        if tx_fifo_reset = '1' then
           wr_rd_addr <= (others => '0') after dly;
        elsif wr_txfer_en = '1' then
           wr_rd_addr <= rd_addr_txfer after dly;
        end if;
     end if;
  end process;

  -- Obtain the difference between write and read pointers
  p_wr_addr_diff : process (tx_fifo_aclk)
  begin
     if tx_fifo_aclk'event and tx_fifo_aclk = '1' then
        if tx_fifo_reset = '1' then
           wr_addr_diff <= (others => '0') after dly;
        else
           wr_addr_diff <= wr_rd_addr - wr_addr after dly;
        end if;
     end if;
  end process;

  -- Detect when the FIFO is full.
  -- The FIFO is considered to be full if the write address pointer is
  -- within 0 to 3 of the read address pointer.
  p_wr_full : process (tx_fifo_aclk)
  begin
     if tx_fifo_aclk'event and tx_fifo_aclk = '1' then
       if tx_fifo_reset = '1' then
         wr_fifo_full <= '0' after dly;
       else
         if wr_addr_diff(11 downto 4) = 0
            and wr_addr_diff(3 downto 2) /= "00" then
           wr_fifo_full <= '1' after dly;
         else
           wr_fifo_full <= '0' after dly;
         end if;
       end if;
     end if;
  end process p_wr_full;

  -- Memory overflow occurs when the FIFO is full and there are no frames
  -- available in the FIFO for transmission. If the collision window has
  -- expired and there are no frames in the FIFO and the FIFO is full, then the
  -- FIFO is in an overflow state. We must accept the rest of the incoming
  -- frame in overflow condition.

gen_fd_ovflow : if (FULL_DUPLEX_ONLY = TRUE) generate
     -- In full duplex mode, the FIFO memory can only overflow if the FIFO goes
     -- full but there is no frame available to be retranmsitted. Therefore,
     -- prevent signal from being asserted when store_frame signal is high, as
     -- frame count is being updated.
     wr_fifo_overflow <= '1' when wr_fifo_full = '1' and wr_frame_in_fifo = '0'
                               and wr_eof_state = '0' and wr_eof_state_reg = '0'
                             else '0';
end generate gen_fd_ovflow;

gen_hd_ovflow : if (FULL_DUPLEX_ONLY = FALSE) generate
    -- In half duplex mode, register write collision window to give address
    -- counter sufficient time to update. This will prevent the signal from
    -- being asserted when the store_frame signal is high, as the frame count
    -- is being updated.
    wr_fifo_overflow <= '1' when wr_fifo_full = '1' and wr_frame_in_fifo = '0'
                               and wr_eof_state = '0' and wr_eof_state_reg = '0'
                               and wr_col_window_expire = '1'
                            else '0';

    -- Register rd_col_window signal.
    -- This signal is long, and will remain high until overflow functionality
    -- has finished, so save just to register the once.
    p_wr_col_expire : process (tx_fifo_aclk)
    begin
       if tx_fifo_aclk'event and tx_fifo_aclk = '1' then
          if tx_fifo_reset = '1' then
             wr_col_window_pipe(0) <= '0' after dly;
             wr_col_window_pipe(1) <= '0' after dly;
             wr_col_window_expire  <= '0' after dly;
          else
             if wr_txfer_en = '1' then
               wr_col_window_pipe(0) <= rd_col_window_pipe(1) after dly;
             end if;
             wr_col_window_pipe(1) <= wr_col_window_pipe(0) after dly;
             wr_col_window_expire  <= wr_col_window_pipe(1) after dly;
          end if;
       end if;
    end process;
end generate gen_hd_ovflow;


  ------------------------------------------------------------------------------
  -- FIFO status signals
  ------------------------------------------------------------------------------

  -- The FIFO status is four bits which represents the occupancy of the FIFO
  -- in sixteenths. To generate this signal we therefore only need to compare
  -- the 4 most significant bits of the write address pointer with the 4 most
  -- significant bits of the read address pointer.
  p_fifo_status : process (tx_fifo_aclk)
  begin
     if tx_fifo_aclk'event and tx_fifo_aclk = '1' then
        if tx_fifo_reset = '1' then
           wr_fifo_status <= "0000" after dly;
        else
           if wr_addr_diff = (wr_addr_diff'range => '0') then
              wr_fifo_status <= "0000" after dly;
           else
              wr_fifo_status(3) <= not wr_addr_diff(11) after dly;
              wr_fifo_status(2) <= not wr_addr_diff(10) after dly;
              wr_fifo_status(1) <= not wr_addr_diff(9) after dly;
              wr_fifo_status(0) <= not wr_addr_diff(8) after dly;
           end if;
        end if;
     end if;
  end process p_fifo_status;

  fifo_status <= std_logic_vector(wr_fifo_status);


  ------------------------------------------------------------------------------
  -- Instantiate FIFO block memory
  ------------------------------------------------------------------------------

  wr_eof_data_bram(8)          <= wr_eof_bram(0);
  wr_eof_data_bram(7 downto 0) <= wr_data_bram;

  -- Block RAM for lower address space (rd_addr(11) = '0')
  rd_eof_bram_l(0) <= rd_eof_data_bram_l(8);
  rd_data_bram_l   <= rd_eof_data_bram_l(7 downto 0);
  ramgen_l : BRAM_TDP_MACRO
    generic map (
      DEVICE        => "VIRTEX6",
      WRITE_WIDTH_A => 9,
      WRITE_WIDTH_B => 9,
      READ_WIDTH_A  => 9,
      READ_WIDTH_B  => 9)
    port map (
      DOA    => rd_bram_l_unused,
      DOB    => rd_eof_data_bram_l,
      ADDRA  => std_logic_vector(wr_addr(10 downto 0)),
      ADDRB  => std_logic_vector(rd_addr(10 downto 0)),
      CLKA   => tx_fifo_aclk,
      CLKB   => tx_mac_aclk,
      DIA    => wr_eof_data_bram,
      DIB    => GND_BUS(8 downto 0),
      ENA    => VCC,
      ENB    => rd_en,
      REGCEA => VCC,
      REGCEB => VCC,
      RSTA   => tx_fifo_reset,
      RSTB   => tx_mac_reset,
      WEA    => wr_en_l_bram,
      WEB    => GND
  );

  -- Block RAM for lower address space (rd_addr(11) = '0')
  rd_eof_bram_u(0) <= rd_eof_data_bram_u(8);
  rd_data_bram_u   <= rd_eof_data_bram_u(7 downto 0);
  ramgen_u : BRAM_TDP_MACRO
    generic map (
      DEVICE        => "VIRTEX6",
      WRITE_WIDTH_A => 9,
      WRITE_WIDTH_B => 9,
      READ_WIDTH_A  => 9,
      READ_WIDTH_B  => 9)
    port map (
      DOA    => rd_bram_u_unused,
      DOB    => rd_eof_data_bram_u,
      ADDRA  => std_logic_vector(wr_addr(10 downto 0)),
      ADDRB  => std_logic_vector(rd_addr(10 downto 0)),
      CLKA   => tx_fifo_aclk,
      CLKB   => tx_mac_aclk,
      DIA    => wr_eof_data_bram,
      DIB    => GND_BUS(8 downto 0),
      ENA    => VCC,
      ENB    => rd_en,
      REGCEA => VCC,
      REGCEB => VCC,
      RSTA   => tx_fifo_reset,
      RSTB   => tx_mac_reset,
      WEA    => wr_en_u_bram,
      WEB    => GND
  );


end RTL;
