-- #########################################################
-- #       << ATLAS Project - System Controller 0 >>       #
-- # ***************************************************** #
-- #  -> Interrupt Controller (8 channels)                 #
-- #  -> High Precision Timer (16+16 bit)                  #
-- #  -> Linear-Feedback Shift Register (16 bit)           #
-- # ***************************************************** #
-- #  Last modified: 28.11.2014                            #
-- # ***************************************************** #
-- #  by Stephan Nolting 4788, Hanover, Germany            #
-- #########################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.atlas_core_package.all;

entity sys_0_core is
  port	(
-- ###############################################################################################
-- ##           Host Interface                                                                  ##
-- ###############################################################################################

        clk_i           : in  std_ulogic; -- global clock line
        rst_i           : in  std_ulogic; -- global reset line, sync, high-active
        ice_i           : in  std_ulogic; -- interface clock enable, high-active
        w_en_i          : in  std_ulogic; -- write enable
        r_en_i          : in  std_ulogic; -- read enable
        adr_i           : in  std_ulogic_vector(02 downto 0); -- access address
        dat_i           : in  std_ulogic_vector(15 downto 0); -- write data
        dat_o           : out std_ulogic_vector(15 downto 0); -- read data

-- ###############################################################################################
-- ##           Interrupt Lines                                                                 ##
-- ###############################################################################################

        timer_irq_o     : out std_ulogic; -- timer irq
        irq_i           : in  std_ulogic_vector(07 downto 0); -- irq input
        irq_o           : out std_ulogic  -- interrupt request
      );
end sys_0_core;

architecture sys_0_core_behav of sys_0_core is

  -- Module Addresses --
  constant irq_sm_reg_c     : std_ulogic_vector(02 downto 0) := "000"; -- R/W: Interrupt source and mask
  constant irq_conf_reg_c   : std_ulogic_vector(02 downto 0) := "001"; -- R/W: Interrupt type configuration
  -- lo byte: '1': level triggered, '0': edge triggered
  -- hi byte: '1': high level/rising edge, '0': low level/falling edge
  constant timer_cnt_reg_c  : std_ulogic_vector(02 downto 0) := "010"; -- R/W: Timer counter register
  constant timer_thr_reg_c  : std_ulogic_vector(02 downto 0) := "011"; -- R/W: Timer threshold register
  constant timer_prsc_reg_c : std_ulogic_vector(02 downto 0) := "100"; -- R/W: Timer prescaler register
  constant lfsr_data_reg_c  : std_ulogic_vector(02 downto 0) := "101"; -- R/W: LFSR data register
  constant lfsr_poly_reg_c  : std_ulogic_vector(02 downto 0) := "110"; -- R/W: LFSR polynomial register
  -- bit 15: '0' new value after read access, '1' free running mode
  constant reserved_reg_c   : std_ulogic_vector(02 downto 0) := "111"; -- RESERVED

  -- IRQ Registers --
  signal irq_mask_reg   : std_ulogic_vector(07 downto 0);
  signal irq_source_reg : std_ulogic_vector(02 downto 0);
  signal irq_conf_reg   : std_ulogic_vector(15 downto 0);

  -- Internals --
  signal irq_sync_0      : std_ulogic_vector(07 downto 0);
  signal irq_sync_1      : std_ulogic_vector(07 downto 0);
  signal irq_raw_req     : std_ulogic_vector(07 downto 0);
  signal irq_buf         : std_ulogic_vector(07 downto 0);
  signal irq_id          : std_ulogic_vector(02 downto 0);
  signal irq_ack_mask    : std_ulogic_vector(07 downto 0);
  signal irq_ack_mask_ff : std_ulogic_vector(07 downto 0);
  signal irq_lock        : std_ulogic;

  -- Timer Registers --
  signal tmr_cnt_reg  : std_ulogic_vector(15 downto 0);
  signal tmr_thr_reg  : std_ulogic_vector(15 downto 0);
  signal tmr_prsc_reg : std_ulogic_vector(15 downto 0);
  signal tmr_prsc_cnt : std_ulogic_vector(15 downto 0);

  -- Timer Signals --
  signal tmr_prsc_match : std_ulogic;
  signal tmr_thres_zero : std_ulogic;

  -- LFSR Registers --
  signal lfsr_data  : std_ulogic_vector(15 downto 0);
  signal lfsr_poly  : std_ulogic_vector(15 downto 0);
  signal lfsr_new   : std_ulogic_vector(15 downto 0);
  signal lfsr_noise : std_ulogic;

begin

  -- Write Access ----------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    w_acc: process(clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_i = '1') then
          irq_mask_reg <= (others => '0');
          irq_conf_reg <= (others => '0');
          tmr_cnt_reg  <= (others => '0');
          tmr_thr_reg  <= (others => '0');
          tmr_prsc_reg <= (others => '0');
          tmr_prsc_cnt <= (others => '0');
          lfsr_data    <= (others => '0');
          lfsr_poly    <= (others => '0');
          irq_sync_0   <= (others => '0');
          irq_sync_1   <= (others => '0');
        else
          -- irq ctrl write access --
          if (w_en_i = '1') and (ice_i = '1') and ((adr_i = irq_sm_reg_c) or (adr_i = irq_conf_reg_c)) then
            if (adr_i = irq_sm_reg_c) then
              irq_mask_reg <= dat_i(15 downto 08);
            else -- (adr_i = irq_conf_reg_c)
              irq_conf_reg <= dat_i;
            end if;
          end if;
          irq_sync_1 <= irq_sync_0;
          irq_sync_0 <= irq_i;

          -- timer write access --
          if (w_en_i = '1') and (ice_i = '1') and ((adr_i = timer_cnt_reg_c) or (adr_i = timer_thr_reg_c) or (adr_i = timer_prsc_reg_c)) then
            tmr_prsc_cnt <= (others => '0');
            if (adr_i = timer_cnt_reg_c) then
              tmr_cnt_reg  <= dat_i;
            elsif (adr_i = timer_thr_reg_c) then
              tmr_thr_reg  <= dat_i;
            else -- (adr_i = timer_prsc_reg_c)
              tmr_prsc_reg <= dat_i;
            end if;
          else -- auto update
            if (tmr_prsc_match = '1') or (tmr_thres_zero = '1') then -- prescaler increment
              tmr_prsc_cnt <= (others => '0');
            else
              tmr_prsc_cnt <= std_ulogic_vector(unsigned(tmr_prsc_cnt) + 1);
            end if;
            if (tmr_cnt_reg = tmr_thr_reg) then -- counter increment
              tmr_cnt_reg <= (others => '0');
            elsif (tmr_thres_zero = '0') and (tmr_prsc_match = '1') then
              tmr_cnt_reg <= std_ulogic_vector(unsigned(tmr_cnt_reg) + 1);
            end if;
          end if;

          -- lfsr write access --
          if (w_en_i = '1') and (ice_i = '1') and ((adr_i = lfsr_data_reg_c) or (adr_i = lfsr_poly_reg_c)) then
            if (adr_i = lfsr_data_reg_c) then
               lfsr_data <= dat_i;
            else -- (adr_i = lfsr_poly_reg_c)
              lfsr_poly <= dat_i;
            end if;
          else -- auto update
            if (lfsr_poly(15) = '0') then -- access-update?
              if (r_en_i = '1') and (adr_i = lfsr_data_reg_c) and (ice_i = '1') then
                lfsr_data <= lfsr_new;
              end if;
            else -- free-running mode
              lfsr_data <= lfsr_new;
            end if;
          end if;
        end if;
      end if;
    end process w_acc;

    -- timer prescaler match --
    tmr_prsc_match <= '1' when (tmr_prsc_cnt = tmr_prsc_reg) else '0';

    -- timer threshold zero test --
    tmr_thres_zero <= '1' when (tmr_thr_reg = x"0000") else '0';

    -- timer irq --
    timer_irq_o    <= '1' when ((tmr_cnt_reg = tmr_thr_reg) and (tmr_thres_zero = '0')) else '0';


  -- Read Access -----------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    r_acc: process(adr_i, irq_mask_reg, irq_conf_reg, irq_source_reg, tmr_cnt_reg, tmr_thr_reg,
                   tmr_prsc_reg, lfsr_data, lfsr_poly)
    begin
      case (adr_i) is
        when irq_sm_reg_c     => dat_o <= irq_mask_reg & "00000" & irq_source_reg;
        when irq_conf_reg_c   => dat_o <= irq_conf_reg;
        when timer_cnt_reg_c  => dat_o <= tmr_cnt_reg;
        when timer_thr_reg_c  => dat_o <= tmr_thr_reg;
        when timer_prsc_reg_c => dat_o <= tmr_prsc_reg;
        when lfsr_data_reg_c  => dat_o <= lfsr_data;
        when lfsr_poly_reg_c  => dat_o <= lfsr_poly;
        when others           => dat_o <= (others => '0');
      end case;
    end process r_acc;


  -- Interrupt Detector ----------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    irq_detector: process(irq_mask_reg, irq_conf_reg, irq_sync_0, irq_sync_1)
    begin
      -- edge/level detector --
      irq_raw_req <= (others => '0');
      for i in 0 to 7 loop
        if (irq_mask_reg(i) = '1') then -- channel enabled
          if (irq_conf_reg(i) = '1') then -- level triggered
            irq_raw_req(i) <= irq_conf_reg(i+8) xnor irq_sync_0(i);
          else -- edge triggered
            if (irq_conf_reg(i+8) = '1') then -- rising edge
              irq_raw_req(i) <= irq_sync_0(i) and (not irq_sync_1(i));
            else -- falling edge
              irq_raw_req(i) <= (not irq_sync_0(i)) and irq_sync_1(i);
            end if;
          end if;
        end if;
      end loop;
    end process irq_detector;


  -- Interrupt Request Buffer ----------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    irq_buffer: process(clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_i = '1') then
          irq_buf         <= (others => '0');
          irq_source_reg  <= (others => '0');
          irq_ack_mask_ff <= (others => '0');
          irq_lock        <= '0';
        else
          if (irq_lock = '0') then -- store id and mask until ack
            irq_ack_mask_ff <= irq_ack_mask;
            irq_source_reg  <= irq_id;
          end if;
          if (r_en_i = '1') and (adr_i = irq_sm_reg_c) then -- ack on source reg read
            irq_buf  <= (irq_buf or irq_raw_req) and (not irq_ack_mask_ff);
            irq_lock <= '0'; -- ack: remove lock
          else
            irq_buf  <= irq_buf or irq_raw_req;
            if (irq_buf /= x"00") then
              irq_lock <= '1';
            end if;
          end if;
        end if;
      end if;
    end process irq_buffer;

    -- irq signal to host --
    irq_o <= irq_lock;


  -- Interrupt Priority Encoder --------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    irq_pr_enc: process(irq_buf)
    begin
      irq_id <= (others => '0');
      irq_ack_mask <= (others => '0');
      for i in 0 to 7 loop
        if (irq_buf(i) = '1') then
          irq_id <= std_ulogic_vector(to_unsigned(i,3));
          irq_ack_mask(i) <= '1';
          exit;
        end if;
      end loop;
    end process irq_pr_enc;


  -- LFSR Update -----------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    lfsr_update: process(lfsr_data, lfsr_poly, lfsr_noise)
    begin
      for i in 0 to 14 loop
        if (lfsr_poly(i) = '1') then
          lfsr_new(i) <= lfsr_data(i+1) xor lfsr_data(0);
        else
          lfsr_new(i) <= lfsr_data(i+1);
        end if;
      end loop;
      lfsr_new(15) <= lfsr_data(0) xor lfsr_noise;
    end process lfsr_update;

    -- external noise input --
    lfsr_noise <= '0'; -- not used yet



end sys_0_core_behav;
