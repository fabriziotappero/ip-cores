--------------------------------------------------------------------------------
-- Title      : Receiver FIFO with AxiStream interfaces
-- Project    : Tri-Mode Ethernet MAC
--------------------------------------------------------------------------------
-- File       : rx_client_fifo.vhd
-- Author     : Xilinx Inc.
-- Project    : Virtex-6 Embedded Tri-Mode Ethernet MAC Wrapper
-- File       : rx_client_fifo.vhd
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
-- Description: This is the receiver side FIFO for the design example
--              of the Tri-Mode Ethernet MAC core. AxiStream interfaces are used.
--
--              The FIFO is created from 2 Block RAMs of size 2048
--              words of 8-bits per word, giving a total frame memory capacity
--              of 4096 bytes.
--
--              Frame data received from the MAC receiver is written into the
--              FIFO on the rx_mac_aclk. An end-of-frame marker is written to
--              the BRAM parity bit on the last byte of data stored for a frame.
--              This acts as frame deliniation.
--
--              The rx_axis_mac_tvalid, rx_axis_mac_tlast, and rx_axis_mac_tuser signals
--              qualify the frame. A frame which ends with rx_axis_mac_tuser asserted
--              indicates a bad frame and will cause the FIFO write address
--              pointer to be reset to the base address of that frame. In this
--              way the bad frame will be overwritten with the next received
--              frame and is therefore dropped from the FIFO.
--
--              Frames will also be dropped from the FIFO if an overflow occurs.
--              If there is not enough memory capacity in the FIFO to store the
--              whole of an incoming frame, the write address pointer will be
--              reset and the overflow signal asserted.
--
--              When there is at least one complete frame in the FIFO,
--              the 8-bit AxiStream read interface's rx_axis_fifo_tvalid signal will
--              be enabled allowing data to be read from the FIFO.
--
--              The FIFO has been designed to operate with different clocks
--              on the write and read sides. The read clock (user side) should
--              always operate at an equal or faster frequency than the write
--              clock (MAC side).
--
--              The FIFO is designed to work with a minimum frame length of 8
--              bytes.
--
--              The FIFO memory size can be increased by expanding the rd_addr
--              and wr_addr signal widths, to address further BRAMs.
--
--              Requirements :
--              * Minimum frame size of 8 bytes
--              * Spacing between good/bad frame signaling (encoded by
--                rx_axis_mac_tvalid, rx_axis_mac_tlast, rx_axis_mac_tuser), is at least 64
--                clock cycles
--              * Write AxiStream clock is 125MHz downto 1.25MHz
--              * Read AxiStream clock equal to or faster than write clock,
--                and downto 20MHz
--
--------------------------------------------------------------------------------

library unisim;
use unisim.vcomponents.all;

library unimacro;
use unimacro.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


--------------------------------------------------------------------------------
-- The entity declaration for the Receiver FIFO
--------------------------------------------------------------------------------

entity rx_client_fifo is
  port (
     -- User-side (read-side) AxiStream interface
     rx_fifo_aclk   : in  std_logic;
     rx_fifo_resetn : in  std_logic;
     rx_axis_fifo_tdata : out std_logic_vector(7 downto 0);
     rx_axis_fifo_tvalid : out std_logic;
     rx_axis_fifo_tlast : out std_logic;
     rx_axis_fifo_tready : in  std_logic;

     -- MAC-side (write-side) AxiStream interface
     rx_mac_aclk    : in  std_logic;
     rx_mac_resetn    : in  std_logic;
     rx_axis_mac_tdata : in  std_logic_vector(7 downto 0);
     rx_axis_mac_tvalid : in  std_logic;
     rx_axis_mac_tlast : in  std_logic;
     rx_axis_mac_tready : out std_logic;
     rx_axis_mac_tuser : in  std_logic;

     -- FIFO status and overflow indication,
     -- synchronous to write-side (rx_mac_aclk) interface
     fifo_status    : out std_logic_vector(3 downto 0);
     fifo_overflow  : out std_logic
     );
end rx_client_fifo;


architecture RTL of rx_client_fifo is


  ------------------------------------------------------------------------------
  -- Component declaration for the synchronisation flip-flop pair
  ------------------------------------------------------------------------------
  component sync_block
  port (
    clk                : in  std_logic;
    data_in            : in  std_logic;
    data_out           : out std_logic
    );
  end component;


  ------------------------------------------------------------------------------
  -- Define internal signals
  ------------------------------------------------------------------------------

  signal VCC                 : std_logic;
  signal GND_BUS             : std_logic_vector(8 downto 0);
  signal GND                 : std_logic_vector(0 downto 0);

  -- Encoded read state machine states
  type rd_state_typ is      (WAIT_s,
                             QUEUE1_s,
                             QUEUE2_s,
                             QUEUE3_s,
                             QUEUE_SOF_s,
                             SOF_s,
                             DATA_s,
                             EOF_s);

  signal rd_state            : rd_state_typ;
  signal rd_nxt_state        : rd_state_typ;

  -- Encoded write state machine states
  type wr_state_typ is      (IDLE_s,
                             FRAME_s,
                             GF_s,
                             BF_s,
                             OVFLOW_s);

  signal wr_state            : wr_state_typ;
  signal wr_nxt_state        : wr_state_typ;

  type data_pipe is array (0 to 1) of std_logic_vector(7 downto 0);
  type cntl_pipe_long is array(0 to 2) of std_logic;
  type cntl_pipe_short is array(0 to 1) of std_logic;

  signal wr_en               : std_logic;
  signal wr_en_u             : std_logic;
  signal wr_en_u_bram        : std_logic_vector(0 downto 0);
  signal wr_en_l             : std_logic;
  signal wr_en_l_bram        : std_logic_vector(0 downto 0);
  signal wr_addr             : unsigned(11 downto 0);
  signal wr_addr_inc         : std_logic;
  signal wr_start_addr_load  : std_logic;
  signal wr_addr_reload      : std_logic;
  signal wr_start_addr       : unsigned(11 downto 0);
  signal wr_eof_data_bram    : std_logic_vector(8 downto 0);
  signal wr_data_bram        : std_logic_vector(7 downto 0);
  signal wr_data_pipe        : data_pipe;
  signal wr_dv_pipe          : cntl_pipe_long;
  signal wr_gfbf_pipe        : cntl_pipe_short;
  signal wr_gf               : std_logic;
  signal wr_bf               : std_logic;
  signal wr_eof_bram_pipe    : cntl_pipe_short;
  signal wr_eof_bram         : std_logic;
  signal frame_in_fifo       : std_logic;

  signal rd_addr             : unsigned(11 downto 0);
  signal rd_addr_inc         : std_logic;
  signal rd_addr_reload      : std_logic;
  signal rd_eof_data_bram_u  : std_logic_vector(8 downto 0);
  signal rd_eof_data_bram_l  : std_logic_vector(8 downto 0);
  signal rd_data_bram_u      : std_logic_vector(7 downto 0);
  signal rd_data_bram_l      : std_logic_vector(7 downto 0);
  signal rd_data_pipe_u      : std_logic_vector(7 downto 0);
  signal rd_data_pipe_l      : std_logic_vector(7 downto 0);
  signal rd_data_pipe        : std_logic_vector(7 downto 0);
  signal rd_valid_pipe       : std_logic_vector(1 downto 0);
  signal rd_eof_bram_u       : std_logic_vector(0 downto 0);
  signal rd_eof_bram_l       : std_logic_vector(0 downto 0);
  signal rd_en               : std_logic;
  signal rd_bram_u           : std_logic;
  signal rd_bram_u_reg       : std_logic;
  signal rd_pull_frame       : std_logic;
  signal rd_eof              : std_logic;

  signal wr_store_frame_tog  : std_logic := '0';
  signal rd_store_frame_sync : std_logic;
  signal rd_store_frame_delay : std_logic := '0';
  signal rd_store_frame      : std_logic;
  signal rd_frames           : std_logic_vector(8 downto 0);
  signal wr_fifo_full        : std_logic;

  signal old_rd_addr         : std_logic_vector(1 downto 0);
  signal update_addr_tog     : std_logic;
  signal update_addr_tog_sync : std_logic;
  signal update_addr_tog_sync_reg : std_logic;

  signal wr_rd_addr          : unsigned(11 downto 0);
  signal wr_addr_diff_in     : unsigned(12 downto 0);
  signal wr_addr_diff        : unsigned(11 downto 0);

  signal wr_fifo_status      : unsigned(3 downto 0);
  signal rx_axis_fifo_tlast_int : std_logic;

  signal doa_l_unused        : std_logic_vector(8 downto 0);
  signal doa_u_unused        : std_logic_vector(8 downto 0);
  
  signal rx_fifo_reset       : std_logic;
  signal rx_mac_reset        : std_logic;


--------------------------------------------------------------------------------
-- Begin FIFO architecture
--------------------------------------------------------------------------------

begin

  VCC     <= '1';
  GND_BUS <= (others => '0');
  GND(0)  <= GND_BUS(0);

  -- invert reset sense as architecture is optimised for active high resets
  rx_fifo_reset <= not rx_fifo_resetn;
  rx_mac_reset  <= not rx_mac_resetn;

  ------------------------------------------------------------------------------
  -- Read state machines and control
  ------------------------------------------------------------------------------

  -- Read state machine.
  -- States are WAIT, QUEUE1, QUEUE2, QUEUE3, QUEUE_SOF, SOF, DATA, EOF.
  -- Clock state to next state.
  clock_rds_p : process(rx_fifo_aclk)
  begin
     if (rx_fifo_aclk'event and rx_fifo_aclk = '1') then
        if rx_fifo_reset = '1' then
           rd_state <= WAIT_s;
        else
           rd_state <= rd_nxt_state;
        end if;
     end if;
  end process clock_rds_p;

  rx_axis_fifo_tlast <= rx_axis_fifo_tlast_int;

  -- Decode next state, combinatorial.
  next_rds_p : process(rd_state, frame_in_fifo, rd_eof, rx_axis_fifo_tready,
                       rx_axis_fifo_tlast_int, rd_valid_pipe)
  begin
     case rd_state is
        when WAIT_s =>
           -- Wait until there is a full frame in the FIFO, then
           -- start to load the pipeline.
           if frame_in_fifo = '1' and rx_axis_fifo_tlast_int = '0' then
              rd_nxt_state <= QUEUE1_s;
           else
              rd_nxt_state <= WAIT_s;
           end if;

        -- Load the output pipeline, which takes three clock cycles.
        when QUEUE1_s =>
           rd_nxt_state <= QUEUE2_s;

        when QUEUE2_s =>
           rd_nxt_state <= QUEUE3_s;

        when QUEUE3_s =>
           rd_nxt_state <= QUEUE_SOF_s;

        when QUEUE_SOF_s =>
           -- The pipeline is full and the frame output starts now.
           rd_nxt_state <= DATA_s;

        when SOF_s =>
           -- A new frame begins immediately following end of last frame.
           if rx_axis_fifo_tready = '1' then
              rd_nxt_state <= DATA_s;
           else
              rd_nxt_state <= SOF_s;
           end if;

        when DATA_s =>
           -- Read data from the FIFO. When the EOF marker is detected from
           -- the BRAM output, move to the EOF state.
           if rx_axis_fifo_tready = '1' and rd_eof = '1' then
              rd_nxt_state <= EOF_s;
           else
              rd_nxt_state <= DATA_s;
           end if;

        when EOF_s =>
           -- Hold in this state until tready is asserted and the EOF
           -- marker (tlast) is accepted on interface.
           -- If there is another frame in the FIFO, then it will already be
           -- queued into the pipeline so so move straight to SOF state.
           if rx_axis_fifo_tready = '1' then
              if rd_valid_pipe(1) = '1' then
                rd_nxt_state <= SOF_s;
              else
                 rd_nxt_state <= WAIT_s;
              end if;
           else
              rd_nxt_state <= EOF_s;
           end if;

        when others =>
           rd_nxt_state <= WAIT_s;
        end case;
  end process next_rds_p;

  -- Detect if frame_in_fifo was high 3 reads ago.
  -- This is used to ensure we only treat data in the pipeline as valid if
  -- frame_in_fifo goes high at or before the EOF marker of the current frame.
  -- It may be that there is valid data (i.e a partial frame has been written)
  -- but until the end of that frame we do not know if it is a good frame.
  rd_valid_pipe_p : process(rx_fifo_aclk)
  begin
     if (rx_fifo_aclk'event and rx_fifo_aclk = '1') then
         if (rx_axis_fifo_tready = '1') then
            rd_valid_pipe <= rd_valid_pipe(0) & frame_in_fifo;
         end if;
     end if;
  end process rd_valid_pipe_p;

  -- Decode tlast signal from EOF marker.
  rd_ll_decode_p : process(rx_fifo_aclk)
  begin
     if (rx_fifo_aclk'event and rx_fifo_aclk = '1') then
        if rx_fifo_reset = '1' then
           rx_axis_fifo_tlast_int <= '0';
        elsif rx_axis_fifo_tready = '1' then
           -- Assert tlast signal when the EOF marker has been detected, and
           -- continue to drive it until it has been accepted on the interface.
           case rd_state is
              when EOF_s =>
                 rx_axis_fifo_tlast_int <= '1';
              when others =>
                 rx_axis_fifo_tlast_int <= '0';
           end case;
        end if;
     end if;
  end process rd_ll_decode_p;

  -- Decode the tvalid output based on state.
  rd_ll_src_p : process(rx_fifo_aclk)
  begin
     if (rx_fifo_aclk'event and rx_fifo_aclk = '1') then
        if rx_fifo_reset = '1' then
           rx_axis_fifo_tvalid <= '0';
        else
           case rd_state is
              when QUEUE_SOF_s =>
                 rx_axis_fifo_tvalid <= '1';
              when SOF_s =>
                 rx_axis_fifo_tvalid <= '1';
              when DATA_s =>
                 rx_axis_fifo_tvalid <= '1';
              when EOF_s =>
                 rx_axis_fifo_tvalid <= '1';
              when others =>
                 if rx_axis_fifo_tready = '1' then
                    rx_axis_fifo_tvalid <= '0';
                 end if;
            end case;
         end if;
     end if;
  end process rd_ll_src_p;

  -- Decode internal control signals.
  -- rd_en is used to enable the BRAM read and load the output pipeline.
  rd_en_p : process(rd_state, rx_axis_fifo_tready)
  begin
     case rd_state is
        when WAIT_s =>
           rd_en <= '0';
        when QUEUE1_s =>
           rd_en <= '1';
        when QUEUE2_s =>
           rd_en <= '1';
        when QUEUE3_s =>
           rd_en <= '1';
        when QUEUE_SOF_s =>
           rd_en <= '1';
        when others =>
           rd_en <= rx_axis_fifo_tready;
     end case;
  end process rd_en_p;

  -- When the BRAM is being read, enable the read address to be incremented.
  rd_addr_inc <= rd_en;

  -- When the current frame is done, and if there is no frame in the FIFO, then
  -- the FIFO must wait until a new frame is written in. This requires the read
  -- address to be moved back to where the new frame will be written. The
  -- pipeline is then reloaded using the QUEUE states.
  p_rd_addr_reload : process (rx_fifo_aclk)
  begin
    if rx_fifo_aclk'event and rx_fifo_aclk = '1' then
      if rx_fifo_reset = '1' then
        rd_addr_reload <= '0';
      else
        if rd_state = EOF_s and rd_nxt_state = WAIT_s then
          rd_addr_reload <= '1';
        else
          rd_addr_reload <= '0';
        end if;
      end if;
    end if;
  end process p_rd_addr_reload;

  -- Data is available if there is at least one frame stored in the FIFO.
  p_rd_avail : process (rx_fifo_aclk)
  begin
    if rx_fifo_aclk'event and rx_fifo_aclk = '1' then
      if rx_fifo_reset = '1' then
        frame_in_fifo <= '0';
      else
        if rd_frames /= (rd_frames'range => '0') then
          frame_in_fifo <= '1';
        else
          frame_in_fifo <= '0';
        end if;
      end if;
    end if;
  end process p_rd_avail;

  -- When a frame has been stored we need to synchronize that event to the
  -- read clock domain for frame count store.
  resync_wr_store_frame_tog : sync_block
  port map (
    clk       => rx_fifo_aclk,
    data_in   => wr_store_frame_tog,
    data_out  => rd_store_frame_sync
  );

  p_delay_rd_store : process (rx_fifo_aclk)
  begin
    if rx_fifo_aclk'event and rx_fifo_aclk = '1' then
      rd_store_frame_delay <= rd_store_frame_sync;
    end if;
  end process p_delay_rd_store;

  -- Edge detect of the resynchronized frame count. This creates a pulse
  -- when a new frame has been stored.
  p_sync_rd_store : process (rx_fifo_aclk)
  begin
    if rx_fifo_aclk'event and rx_fifo_aclk = '1' then
      if rx_fifo_reset = '1' then
        rd_store_frame       <= '0';
      else
        -- Edge detector
        if (rd_store_frame_delay xor rd_store_frame_sync) = '1' then
          rd_store_frame     <= '1';
        else
          rd_store_frame     <= '0';
        end if;
      end if;
    end if;
  end process p_sync_rd_store;

  -- This creates a pulse when a new frame has begun to be output.
  p_rd_pull_frame : process (rx_fifo_aclk)
  begin
    if rx_fifo_aclk'event and rx_fifo_aclk = '1' then
      if rx_fifo_reset = '1' then
        rd_pull_frame <= '0';
      else
        if rd_state = SOF_s and rd_nxt_state /= SOF_s then
          rd_pull_frame <= '1';
        elsif rd_state = QUEUE_SOF_s and rd_nxt_state /= QUEUE_SOF_s then
          rd_pull_frame <= '1';
        else
          rd_pull_frame <= '0';
        end if;
      end if;
    end if;
  end process p_rd_pull_frame;

  -- Up/down counter to monitor the number of frames stored within the FIFO.
  -- Note:
  --    * increments at the end of a frame write cycle
  --    * decrements at the beginning of a frame read cycle
  p_rd_frames : process (rx_fifo_aclk)
  begin
    if rx_fifo_aclk'event and rx_fifo_aclk = '1' then
      if rx_fifo_reset = '1' then
        rd_frames <= (others => '0');
      else
        -- A frame is written to the FIFO in this cycle, and no frame is being
        -- read out on the same cycle.
        if rd_store_frame = '1' and rd_pull_frame = '0' then
            rd_frames <= rd_frames + 1;
        -- A frame is being read out on this cycle and no frame is being
        -- written on the same cycle.
        elsif rd_store_frame = '0' and rd_pull_frame = '1' then
             rd_frames <= rd_frames - 1;
        end if;
      end if;
    end if;
  end process p_rd_frames;


  ------------------------------------------------------------------------------
  -- Write state machines and control
  ------------------------------------------------------------------------------

  -- Write state machine.
  -- States are IDLE, FRAME, GF, BF, OVFLOW.
  -- Clock state to next state.
  clock_wrs_p : process(rx_mac_aclk)
  begin
     if (rx_mac_aclk'event and rx_mac_aclk = '1') then
        if rx_mac_reset = '1' then
           wr_state <= IDLE_s;
        else
           wr_state <= wr_nxt_state;
        end if;
     end if;
  end process clock_wrs_p;

  -- Decode next state, combinatorial.
  next_wrs_p : process(wr_state, wr_dv_pipe(1), wr_gf, wr_bf, wr_fifo_full)
  begin
     case wr_state is
        when IDLE_s =>
           -- There is data in incoming pipeline when dv_pipe(1) goes high.
           if wr_dv_pipe(1) = '1' then
              wr_nxt_state <= FRAME_s;
           else
              wr_nxt_state <= IDLE_s;
           end if;

        when FRAME_s =>
           -- If FIFO is full then go to overflow state.
           -- If the good or bad flag is detected, then the end of the frame
           -- has been reached and the gf or bf state is visited before idle.
           -- Otherwise remain in frame state while data is written to FIFO.
           if wr_fifo_full = '1' then
              wr_nxt_state <= OVFLOW_s;
           elsif wr_gf = '1' then
              wr_nxt_state <= GF_s;
           elsif wr_bf = '1' then
              wr_nxt_state <= BF_s;
           else
              wr_nxt_state <= FRAME_s;
           end if;

        when GF_s =>
           -- Return to idle and wait for next frame.
           wr_nxt_state <= IDLE_s;

        when BF_s =>
           -- Return to idle and wait for next frame.
           wr_nxt_state <= IDLE_s;

        when OVFLOW_s =>
           -- Wait until the good or bad flag received.
           if wr_gf = '1' or wr_bf = '1' then
              wr_nxt_state <= IDLE_s;
           else
              wr_nxt_state <= OVFLOW_s;
           end if;

        when others =>
           wr_nxt_state <= IDLE_s;
     end case;
  end process next_wrs_p;

  -- Decode control signals, combinatorial.
  -- wr_en is used to enable the BRAM write and loading of the input pipeline.
  wr_en <= wr_dv_pipe(2) when wr_state = FRAME_s else '0';

  -- The upper and lower signals are used to distinguish between the upper and
  -- lower BRAMs.
  wr_en_l <= wr_en and not(wr_addr(11));
  wr_en_u <= wr_en and     wr_addr(11);
  wr_en_l_bram(0) <= wr_en_l;
  wr_en_u_bram(0) <= wr_en_u;

  -- Increment the write address when we are receiving valid frame data.
  wr_addr_inc <= wr_dv_pipe(2) when wr_state = FRAME_s else '0';

  -- If the FIFO overflows or a frame is to be dropped, we need to move the
  -- write address back to the start of the frame.  This allows the data to be
  -- overwritten.
  wr_addr_reload <= '1' when wr_state = BF_s or wr_state = OVFLOW_s else '0';

  -- The start address is saved when in the idle state.
  wr_start_addr_load <= '1' when wr_state = IDLE_s else '0';

  -- We need to know when a frame is stored, in order to increment the count of
  -- frames stored in the FIFO.
  p_wr_store_tog : process (rx_mac_aclk)
  begin
     if (rx_mac_aclk'event and rx_mac_aclk = '1') then
        if wr_state = GF_s then
           wr_store_frame_tog <= not wr_store_frame_tog;
        end if;
     end if;
  end process;


  ------------------------------------------------------------------------------
  -- Address counters
  ------------------------------------------------------------------------------

  -- Write address is incremented when data is being written into the FIFO.
  wr_addr_p : process(rx_mac_aclk)
  begin
     if (rx_mac_aclk'event and rx_mac_aclk = '1') then
        if rx_mac_reset = '1' then
           wr_addr <= (others => '0');
        else
           if wr_addr_reload = '1' then
              wr_addr <= wr_start_addr;
           elsif wr_addr_inc = '1' then
              wr_addr <= wr_addr + 1;
           end if;
        end if;
     end if;
  end process wr_addr_p;

  -- Store the start address.
  wr_staddr_p : process(rx_mac_aclk)
  begin
     if (rx_mac_aclk'event and rx_mac_aclk = '1') then
        if rx_mac_reset = '1' then
           wr_start_addr <= (others => '0');
        else
           if wr_start_addr_load = '1' then
              wr_start_addr <= wr_addr;
           end if;
        end if;
     end if;
  end process wr_staddr_p;

  -- Read address is incremented when data is being read from the FIFO.
  rd_addr_p : process(rx_fifo_aclk)
  begin
     if (rx_fifo_aclk'event and rx_fifo_aclk = '1') then
        if rx_fifo_reset = '1' then
           rd_addr <= (others => '0');
        else
           if rd_addr_reload = '1' then
              rd_addr <= rd_addr - 3;
           elsif rd_addr_inc = '1' then
              rd_addr <= rd_addr + 1;
           end if;
        end if;
     end if;
  end process rd_addr_p;

  -- Which BRAM is read from is dependant on the upper bit of the address
  -- space. This needs to be registered to give the correct timing.
  rd_bram_p : process(rx_fifo_aclk)
  begin
     if (rx_fifo_aclk'event and rx_fifo_aclk = '1') then
        if rx_fifo_reset = '1' then
           rd_bram_u <= '0';
           rd_bram_u_reg <= '0';
        elsif rd_addr_inc = '1' then
           rd_bram_u <= rd_addr(11);
           rd_bram_u_reg <= rd_bram_u;
        end if;
     end if;
  end process rd_bram_p;


  ------------------------------------------------------------------------------
  -- Data pipelines
  ------------------------------------------------------------------------------

  -- Register data inputs to BRAM.
  -- No resets to allow for SRL16 target.
  reg_din_p : process(rx_mac_aclk)
  begin
     if (rx_mac_aclk'event and rx_mac_aclk = '1') then
        wr_data_pipe(0) <= rx_axis_mac_tdata;
        wr_data_pipe(1) <= wr_data_pipe(0);
        wr_data_bram    <= wr_data_pipe(1);
     end if;
  end process reg_din_p;

  -- The valid input enables BRAM write and is a condition for other signals.
  reg_dv_p : process(rx_mac_aclk)
  begin
     if (rx_mac_aclk'event and rx_mac_aclk = '1') then
        wr_dv_pipe(0) <= rx_axis_mac_tvalid;
        wr_dv_pipe(1) <= wr_dv_pipe(0);
        wr_dv_pipe(2) <= wr_dv_pipe(1);
     end if;
  end process reg_dv_p;

  -- End of frame flag set when tlast and tvalid are asserted together.
  reg_eof_p : process(rx_mac_aclk)
  begin
     if (rx_mac_aclk'event and rx_mac_aclk = '1') then
        wr_eof_bram_pipe(0) <= rx_axis_mac_tlast;
        wr_eof_bram_pipe(1) <= wr_eof_bram_pipe(0);
        wr_eof_bram <= wr_eof_bram_pipe(1) and wr_dv_pipe(1);
     end if;
  end process reg_eof_p;

  -- Upon arrival of EOF flag, the frame is good if tuser signal
  -- is low, and bad if tuser signal is high.
  reg_gf_p : process(rx_mac_aclk)
  begin
     if (rx_mac_aclk'event and rx_mac_aclk = '1') then
        wr_gfbf_pipe(0) <= rx_axis_mac_tuser;
        wr_gfbf_pipe(1) <= wr_gfbf_pipe(0);
        wr_gf <= (not wr_gfbf_pipe(1)) and wr_eof_bram_pipe(1) and wr_dv_pipe(1);
        wr_bf <=      wr_gfbf_pipe(1)  and wr_eof_bram_pipe(1) and wr_dv_pipe(1);
     end if;
  end process reg_gf_p;

  -- The MAC's RX path cannot be helpd off, so the tready signal is always high.
  reg_ready_p : process(rx_mac_aclk)
  begin
     if (rx_mac_aclk'event and rx_mac_aclk = '1') then
        if (rx_mac_reset = '1') then
           rx_axis_mac_tready <= '0';
        else
           rx_axis_mac_tready <= '1';
        end if;
     end if;
  end process reg_ready_p;

  -- Register data outputs from BRAM.
  -- No resets to allow for SRL16 target.
  reg_dout_p : process(rx_fifo_aclk)
  begin
     if (rx_fifo_aclk'event and rx_fifo_aclk = '1') then
        if rd_en = '1' then
           rd_data_pipe_u <= rd_data_bram_u;
           rd_data_pipe_l <= rd_data_bram_l;
           if rd_bram_u_reg = '1' then
              rd_data_pipe <= rd_data_pipe_u;
           else
              rd_data_pipe <= rd_data_pipe_l;
           end if;
           rx_axis_fifo_tdata <= rd_data_pipe;
        end if;
     end if;
  end process reg_dout_p;

  reg_eofout_p : process(rx_fifo_aclk)
  begin
     if (rx_fifo_aclk'event and rx_fifo_aclk = '1') then
        if rd_en = '1' then
           if rd_bram_u = '1' then
              rd_eof <= rd_eof_bram_u(0);
           else
              rd_eof <= rd_eof_bram_l(0);
           end if;
        end if;
     end if;
  end process reg_eofout_p;


  ------------------------------------------------------------------------------
  -- Overflow functionality
  ------------------------------------------------------------------------------

  -- to minimise the number of read address updates the bottom 6 bits of the 
  -- read address are not passed across and the write domain will only sample 
  -- them when bits 5 and 4 of the read address transition from 01 to 10.  
  -- Since this is for full detection this just means that if the read stops
  -- the write will hit full up to 64 locations early
  
  -- need to use two bits and look for an increment transition as reload can cause
  -- a decrement on this boundary (decrement is only by 3 so above bit 2 should be safe)
  p_rd_addr_tog : process (rx_fifo_aclk)
  begin
     if rx_fifo_aclk'event and rx_fifo_aclk = '1' then
        if rx_fifo_reset = '1' then
           old_rd_addr <= (others => '0');
           update_addr_tog <= '0';
        else 
           old_rd_addr <= std_logic_vector(rd_addr(5 downto 4));
           if rd_addr(5 downto 4) = "10" and old_rd_addr = "01" then
              update_addr_tog <= not update_addr_tog;
           end if;
        end if;
     end if;
  end process p_rd_addr_tog;

  sync_rd_addr_tog: sync_block
  port map (
     clk       => rx_mac_aclk,
     data_in   => update_addr_tog,
     data_out  => update_addr_tog_sync
  );

  -- Obtain the difference between write and read pointers.
  p_sample_addr : process (rx_mac_aclk)
  begin
     if rx_mac_aclk'event and rx_mac_aclk = '1' then
        if rx_mac_reset = '1' then
           update_addr_tog_sync_reg <= '0';
           wr_rd_addr               <= (others => '0');
        else
           update_addr_tog_sync_reg <= update_addr_tog_sync;
           if update_addr_tog_sync_reg /= update_addr_tog_sync then
              wr_rd_addr               <= rd_addr(11 downto 6) & "000000";
           end if;
        end if;
     end if;
  end process p_sample_addr;

  wr_addr_diff_in <= ('0' & wr_rd_addr) - ('0' & wr_addr);

  -- Obtain the difference between write and read pointers.
  p_addr_diff : process (rx_mac_aclk)
  begin
     if rx_mac_aclk'event and rx_mac_aclk = '1' then
        if rx_mac_reset = '1' then
           wr_addr_diff <= (others => '0');
        else
           wr_addr_diff <= wr_addr_diff_in(11 downto 0);
        end if;
     end if;
  end process p_addr_diff;

  -- Detect when the FIFO is full.
  -- The FIFO is considered to be full if the write address pointer is
  -- within 0 to 3 of the read address pointer.
  p_wr_full : process (rx_mac_aclk)
  begin
     if rx_mac_aclk'event and rx_mac_aclk = '1' then
       if rx_mac_reset = '1' then
         wr_fifo_full <= '0';
       else
         if wr_addr_diff(11 downto 4) = 0
            and wr_addr_diff(3 downto 2) /= "00" then
            wr_fifo_full <= '1';
         else
            wr_fifo_full <= '0';
         end if;
       end if;
     end if;
  end process p_wr_full;

  -- Decode the overflow indicator output.
  fifo_overflow <= '1' when wr_state = OVFLOW_s else '0';


  ------------------------------------------------------------------------------
  -- FIFO status signals
  ------------------------------------------------------------------------------
  -- The FIFO status is four bits which represents the occupancy of the FIFO
  -- in sixteenths. To generate this signal we therefore only need to compare
  -- the 4 most significant bits of the write address pointer with the 4 most
  -- significant bits of the read address pointer.

  p_wr_fifo_status : process (rx_mac_aclk)
  begin
     if rx_mac_aclk'event and rx_mac_aclk = '1' then
        if rx_mac_reset = '1' then
           wr_fifo_status <= "0000";
        else
           if wr_addr_diff = (wr_addr_diff'range => '0') then
              wr_fifo_status <= "0000";
           else
              wr_fifo_status(3) <= not wr_addr_diff(11);
              wr_fifo_status(2) <= not wr_addr_diff(10);
              wr_fifo_status(1) <= not wr_addr_diff(9);
              wr_fifo_status(0) <= not wr_addr_diff(8);
           end if;
        end if;
     end if;
  end process p_wr_fifo_status;

  fifo_status <= std_logic_vector(wr_fifo_status);


  ------------------------------------------------------------------------------
  -- Instantiate FIFO block memory
  ------------------------------------------------------------------------------

  wr_eof_data_bram(8) <= wr_eof_bram;
  wr_eof_data_bram(7 downto 0) <= wr_data_bram;

  -- Block RAM for lower address space (rx_addr(11) = '0')
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
      DOA    => doa_l_unused,
      DOB    => rd_eof_data_bram_l,
      ADDRA  => std_logic_vector(wr_addr(10 downto 0)),
      ADDRB  => std_logic_vector(rd_addr(10 downto 0)),
      CLKA   => rx_mac_aclk,
      CLKB   => rx_fifo_aclk,
      DIA    => wr_eof_data_bram,
      DIB    => GND_BUS(8 downto 0),
      ENA    => VCC,
      ENB    => rd_en,
      REGCEA => VCC,
      REGCEB => VCC,
      RSTA   => rx_mac_reset,
      RSTB   => rx_fifo_reset,
      WEA    => wr_en_l_bram,
      WEB    => GND
  );

  -- Block RAM for lower address space (rx_addr(11) = '0')
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
      DOA    => doa_u_unused,
      DOB    => rd_eof_data_bram_u,
      ADDRA  => std_logic_vector(wr_addr(10 downto 0)),
      ADDRB  => std_logic_vector(rd_addr(10 downto 0)),
      CLKA   => rx_mac_aclk,
      CLKB   => rx_fifo_aclk,
      DIA    => wr_eof_data_bram,
      DIB    => GND_BUS(8 downto 0),
      ENA    => VCC,
      ENB    => rd_en,
      REGCEA => VCC,
      REGCEB => VCC,
      RSTA   => rx_mac_reset,
      RSTB   => rx_fifo_reset,
      WEA    => wr_en_u_bram,
      WEB    => GND
  );


end RTL;
