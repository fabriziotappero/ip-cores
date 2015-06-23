-------------------------------------------------------------------------------
-- AES3 / SPDIF Minimalistic Receiver
-- Version 0.9
-- Petr Nohavica (c) 2009
-- Released under GNU Lesser General Public License
-- Original target device: Xilinx Spartan-3AN family
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity aes3rx is
   generic (
      -- Registers width, determines minimal baud speed of input AES3 at given master clock frequency
      reg_width : integer := 5
   );
   port (
      -- Master clock
      clk   : in  std_logic;
      -- AES3/SPDIF compatible input signal
      aes3  : in  std_logic; 
      -- Synchronous reset
      reset : in  std_logic; 
      -- Serial data out
      sdata : out std_logic := '0'; -- output serial data
      -- AES3 clock out
      sclk  : out std_logic := '0'; -- output serial data clock
      -- Block start (asserted when Z subframe is being transmitted)
      bsync : out std_logic := '0'; 
      -- Frame sync (asserted for channel A, negated for B)
      lrck  : out std_logic := '0'; 
      -- Receiver has (probably) valid data on its outputs
      active: out std_logic := '0'
   );
end aes3rx;

architecture Behavioral of aes3rx is
   -- Locking state machine states enum type
   type lock_state_type is (locking, confirming, locked);
   -- Constants for preamble detection
   constant X_PREAMBLE     : std_logic_vector(7 downto 0) := "01000111"; 
   constant Y_PREAMBLE     : std_logic_vector(7 downto 0) := "00100111"; 
   constant Z_PREAMBLE     : std_logic_vector(7 downto 0) := "00010111"; 
   -- Input shift register for handling metastability issues and delaying input
   signal aes3_sync        : std_logic_vector(3 downto 0) := (others => '0'); 
   -- Change signal, active high on input transition
   signal change           : std_logic := '0'; 
   -- Recovered AES3 clock, stream of pulses
   signal aes3_clk         : std_logic := '0';
   -- Shift register for preamble detection and data decoding
   signal decoder_shift    : std_logic_vector(7 downto 0) := (others => '0');
   -- 1 bit counter used for correct decoder_shift alignment for data decoder
   signal align_counter    : std_logic := '0'; 
   -- Counter for AES3 clk regeneration
   signal clk_counter      : std_logic_vector(reg_width - 1 downto 0) := (others => '0');
   -- Counts aes3_clk pulses per frame (for locking reasons)
   signal sync_cnt         : std_logic_vector(5 downto 0) := (others => '0'); 
   -- Period register for clk_counter
   signal reg_clk_period   : std_logic_vector(reg_width - 1 downto 0) := (others => '1'); 
   -- Asserted when locking state machine is not in locked state
   signal sync_lost        : std_logic := '1';
   -- Asserted when preamble has been detected
   signal preamble_detected: std_logic := '0';
   -- Internal version of bsync signal
   signal bsync_int        : std_logic := '0';
   -- Internal version of lrck signal
   signal lrck_int         : std_logic := '0';
   -- Internal version of sdata signal
   signal sdata_int        : std_logic := '0';
   -- State of locking state machine
   signal lock_state       : lock_state_type := locking;
   -- Next state of locking state machine
   signal lock_state_next  : lock_state_type;
   -- Signal indicating some error in received AES3, used primarily by locking state machine
   signal lock_error       : std_logic;
   -- Asserted when sync_cnt is full (i.e. it has value of 63)
   signal sync_cnt_full    : std_logic;
   -- Asserted when there was at least one aes3_clk pulse since last input transition
   signal aes3_clk_activity: std_logic := '0';
   -- Signals indicating detection of X, Y and Z preambles
   signal x_detected       : std_logic := '0';
   signal y_detected       : std_logic := '0';
   signal z_detected       : std_logic := '0';
begin

   -- Carries out input double sampling in order to avoid metastable states on FFs and creation 
   -- of delayed signals for change detector (1 clk period) and decoder (2 clk periods).
   input_shift_reg_proc: process (clk)
   begin
      if clk'event and clk = '1' then
         if reset = '1' then
            aes3_sync <= (others => '0');
         else
            aes3_sync <= aes3 & aes3_sync(3 downto 1); -- synthetizes  shift reg
         end if;
      end if;
   end process;	

   -- Detects edge on sampled input in the way of comparsion of delayed input and its current 
   -- state on XOR gate.
   change_detect_proc: process (clk)
   begin
      if clk'event and clk = '1' then
         if reset = '1' then
            change <= '0';
         else
            change <= aes3_sync(2) xor aes3_sync(1);
         end if;
      end if;
   end process;
   
   -- Counts number of aes3_clk pulses since last preamble detection, used by locking state machine
   sync_cnt_proc: process (clk) 
   begin
      if clk'event and clk ='1' then
         if reset = '1' then
            sync_cnt <= (others => '0');
         elsif aes3_clk = '1' then 
            if preamble_detected = '1' then
               sync_cnt <= (others => '0');
            else 
               sync_cnt <= sync_cnt + 1;
            end if;
         end if;
      end if;
   end process;
   
   -- Comparator driving sync_cnt_full signal
   sync_cnt_comp: process(sync_cnt)
   begin
      if sync_cnt = 63 then
         sync_cnt_full <= '1';
      else
         sync_cnt_full <= '0';
      end if;
   end process;   
   
   -- Lock error occurs when sync_cnt is full and no preamble has been detected (i.e. when the
   -- aes3_clk pulse generation speed is too high) or preamble is detected and sync_cnt is not full
   -- (when aes3_clk pulse rate is too low) or when since last input transition there was no 
   -- aes3_clk pulse at all (value of reg_clk_period is a way too high)
   lock_error <= (sync_cnt_full and not preamble_detected) or
                 (not sync_cnt_full and preamble_detected) or
                 (change and not aes3_clk_activity);
   
   -- Counter holding aes3_clk period duration. The receiver tries to receive a valid frame using 
   -- counter's (which is initially all ones) output, if it fails, counter is enabled to lower its
   -- value by one (counter is also enabled when aes3_clk_activity is low on input transition -
   -- which indicates that value of reg_clk_period is way too high and no aes3_clk pulses are being
   -- generated) and this new value is tried. This process is repeated until lock is not acquired. 
   -- This solution consumes less logic than direct measurement of shortest AES3 symbol and is actually
   -- more reliable. Lock time is fast enough (will always be under 2**(reg_width + 1) frames, but very
   -- likely much faster thanks to initial rapid speed of counting which is given by no activity on
   -- aes3_clk signal).
   aes3_clk_period_proc: process(clk)
   begin 
      if clk'event and clk = '1' then
         if reset = '1' then
            reg_clk_period <= (others => '1');
         elsif (lock_state = locked and lock_state_next = locking) then
            reg_clk_period <= (others => '1');
         elsif (aes3_clk = '1' and sync_cnt_full = '1' and lock_state_next = locking) or 
               (change = '1' and aes3_clk_activity = '0') then
            reg_clk_period <= reg_clk_period - 1;
         end if;
      end if;
   end process;

   -- Locking state machine. While initialized in locking state, waits for preamble_detection - once one
   -- has been detected, state machine is transitioned to confirming state. When no locking error 
   -- occurs during one next frame, receiver is considered locked and state accordingly changes. Otherwise
   -- the state machine falls back to locking state.
   lock_state_machine: process (lock_state, preamble_detected, sync_cnt_full, 
                                lock_error)
   begin
      case lock_state is 
         when locking =>
            if preamble_detected = '1' then
               lock_state_next <= confirming;
            else
               lock_state_next <= locking;
            end if;
         when confirming =>
            if lock_error = '1' then
               lock_state_next <= locking;
            elsif sync_cnt_full = '1' and preamble_detected = '1' then
               lock_state_next <= locked;
            else
               lock_state_next <= confirming;
            end if;
         when locked =>
            if lock_error = '1' then
               lock_state_next <= locking;
            else
               lock_state_next <= locked;
            end if;
      end case;
   end process;
   
   -- When state of locking state machine is other than locked, sync_lost signal is asserted.
   sync_lost_proc: process (lock_state)
   begin
      if lock_state = locked then
         sync_lost <= '0';
      else 
         sync_lost <= '1';
      end if;
   end process;
   
   -- Synchronization process for locking state machine
   lock_state_machinine_sync_proc: process (clk)
   begin
      if clk'event and clk = '1' then
         if reset = '1' then
            lock_state <= locking;
         elsif aes3_clk = '1' or (change = '1' and aes3_clk_activity = '0') then
            lock_state <= lock_state_next;
         end if;
      end if;
   end process;

   -- Counter for aes3_clk generation. On input transition, counter is loaded with approx. half
   -- of reg_clk_period, which should create 90 degrees phase shift of regenerated clock in respect
   -- to delayed input and thus ensure that input will be sampled in approximate middle of 1UI symbol
   -- (or in the middle of one half of 2UI symbol or in the middle of one third of 3UI symbol).
   -- Otherwise, when no transition has been detected on input and clk_counter counts to zero, full 
   -- reg_clk_period is loaded into the counter to create aes3_clk pulses when 2UI and 3UI symbols are 
   -- being received.
   aes3_clk_cnt_proc: process (clk)
   begin
      if clk'event and clk = '1' then
         if reset = '1' then
            clk_counter <= (others => '0');
         elsif change = '1' or clk_counter = 0 then
            if change = '1' then
               clk_counter <= '0' & reg_clk_period(reg_width - 1 downto 1);
            else
               clk_counter <= reg_clk_period;
            end if;
         else
            clk_counter <= clk_counter - 1;
         end if;
      end if;
   end process;
   
   -- Generates aes3_clk pulse when clk_counter counts to zero.
   process (clk)
   begin
      if clk'event and clk = '1' then
         if reset = '1' then
            aes3_clk <= '0';
         else
            if clk_counter = 0 then
               aes3_clk <= '1';
            else
               aes3_clk <= '0';
            end if;
         end if;
      end if;   
   end process;
   
   -- Monitors activity on aes3_clk
   process (clk)
   begin
      if clk'event and clk = '1' then
         if reset = '1' then
            aes3_clk_activity <= '0';
         else
            if change = '1' then
               aes3_clk_activity <= '0';
            elsif clk_counter = 0 then
               aes3_clk_activity <= '1';
            end if;
         end if;
      end if;
   end process;

   -- Eight bit shift register for preamble detection and decoder functionality.
   decoder_shift_reg_proc: process (clk)
   begin
      if clk'event and clk = '1' then
         if reset = '1' then
            decoder_shift <= (others => '0');
         elsif aes3_clk = '1' then
            decoder_shift <= aes3_sync(0) & decoder_shift(7  downto 1);
         end if;
      end if;
   end process;
  
   -- Preamble detectors (implemented using comparators)
   x_preamble_detector: process(decoder_shift)
   begin
      if decoder_shift = X_PREAMBLE or decoder_shift = not X_PREAMBLE then
         x_detected <= '1';
      else 
         x_detected <= '0';
      end if;
   end process;
   
   y_preamble_detector: process(decoder_shift)
   begin
      if decoder_shift = Y_PREAMBLE or decoder_shift = not Y_PREAMBLE then
         y_detected <= '1';
      else 
         y_detected <= '0';
      end if;
   end process;

   z_preamble_detector: process(decoder_shift)
   begin
      if decoder_shift = Z_PREAMBLE or decoder_shift = not Z_PREAMBLE then
         z_detected <= '1';
      else 
         z_detected <= '0';
      end if;
   end process;   
   
   preamble_detected <= x_detected or y_detected or z_detected;
   
   -- One bit counter used for correct bit alignment on bit decoder. Align_counter is reset on 
   -- preamble detection and thus allows decoder to be correctly aligned with sampled symbol beginning.
   align_cnt_proc: process(clk)
   begin
      if clk'event and clk = '1' then
         if reset = '1' then
            align_counter <= '0';
         elsif aes3_clk = '1' then 
            if preamble_detected = '1' then
               align_counter <= '0';
            else
               align_counter <= not align_counter;
            end if;
         end if;
      end if;
   end process;
   
   -- Drives lrck and bsync signals
   frame_block_sync_proc: process (clk)
   begin
      if clk'event and clk = '1' then
         if aes3_clk = '1' and preamble_detected = '1' then
            lrck_int <= x_detected or z_detected;
            bsync_int <= z_detected;
         end if;
      end if;
   end process;
     
   -- Two consecutive sampled symbols, when equal, are considered as logical 0. Two consecutive sampled 
   -- symbols, when differs, are considered as logical 1. This logical value is then shifted into 
   -- data_shift_reg.
   data_shift_reg_proc: process (clk)
   begin
      if clk'event and clk = '1' then
         if aes3_clk = '1' and align_counter = '1' then
            sdata_int <= decoder_shift(1) xor decoder_shift(0);
         end if;
      end if;
   end process;
      
   -- Synchronization and activity signals outputs
   activity_eval_proc: process (clk)
   begin
      if clk'event and clk = '1' then
         active <= not sync_lost;
         lrck <= lrck_int and not sync_lost;
         bsync <= bsync_int and not sync_lost;
         sclk <= align_counter and not sync_lost;
         sdata <= sdata_int and not sync_lost;
      end if;
   end process;   
end Behavioral;

