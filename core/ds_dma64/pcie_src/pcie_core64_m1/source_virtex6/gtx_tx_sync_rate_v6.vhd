
-------------------------------------------------------------------------------
--
-- (c) Copyright 2009-2011 Xilinx, Inc. All rights reserved.
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
-------------------------------------------------------------------------------
-- Project    : Virtex-6 Integrated Block for PCI Express
-- File       : gtx_tx_sync_rate_v6.vhd
-- Version    : 2.3
-- 
-- Module TX_SYNC
-- 
-------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_unsigned.all;

-- Module TX_SYNC

entity GTX_TX_SYNC_RATE_V6 is
   generic (
      C_SIMULATION                              : integer := 0		-- Set to 1 for simulation
      
   );
   port (
      ENPMAPHASEALIGN                           : out std_logic;
      PMASETPHASE                               : out std_logic;
      SYNC_DONE                                 : out std_logic;
      OUT_DIV_RESET                             : out std_logic;
      PCS_RESET                                 : out std_logic;
      USER_PHYSTATUS                            : out std_logic;
      TXALIGNDISABLE                            : out std_logic;
      DELAYALIGNRESET                           : out std_logic;
      USER_CLK                                  : in std_logic;
      RESET                                     : in std_logic;
      RATE                                      : in std_logic;
      RATEDONE                                  : in std_logic;
      GT_PHYSTATUS                              : in std_logic;
      RESETDONE                                 : in std_logic
   );
end GTX_TX_SYNC_RATE_V6;

architecture v6_pcie of GTX_TX_SYNC_RATE_V6 is

   constant   TCQ                                       : integer := 1;

   FUNCTION to_stdlogic (
      in_val      : IN boolean) RETURN std_logic IS
   BEGIN
      IF (in_val) THEN
         RETURN('1');
      ELSE
         RETURN('0');
      END IF;
   END to_stdlogic;

   constant    IDLE                                     : std_logic_vector(24 downto 0) :=  "0000000000000000000000001";
   constant    PHASEALIGN                               : std_logic_vector(24 downto 0) :=  "0000000000000000000000010";
   constant    RATECHANGE_DIVRESET                      : std_logic_vector(24 downto 0) :=  "0000000000000000000000100";
   constant    RATECHANGE_DIVRESET_POST                 : std_logic_vector(24 downto 0) :=  "0000000000000000000001000";
   constant    RATECHANGE_ENPMADISABLE                  : std_logic_vector(24 downto 0) :=  "0000000000000000000010000";
   constant    RATECHANGE_ENPMADISABLE_POST             : std_logic_vector(24 downto 0) :=  "0000000000000000000100000";
   constant    RATECHANGE_PMARESET                      : std_logic_vector(24 downto 0) :=  "0000000000000000001000000";
   constant    RATECHANGE_IDLE                          : std_logic_vector(24 downto 0) :=  "0000000000000000010000000";
   constant    RATECHANGE_PCSRESET                      : std_logic_vector(24 downto 0) :=  "0000000000000000100000000";
   constant    RATECHANGE_PCSRESET_POST                 : std_logic_vector(24 downto 0) :=  "0000000000000001000000000";
   constant    RATECHANGE_ASSERTPHY                     : std_logic_vector(24 downto 0) :=  "0000000000000010000000000";
   constant    RESET_STATE                              : std_logic_vector(24 downto 0) :=  "0000000000000100000000000";
   constant    WAIT_PHYSTATUS                           : std_logic_vector(24 downto 0) :=  "0000000000010000000000000";
   constant    RATECHANGE_PMARESET_POST                 : std_logic_vector(24 downto 0) :=  "0000000000100000000000000";
   constant    RATECHANGE_DISABLEPHASE                  : std_logic_vector(24 downto 0) :=  "0000000001000000000000000";
   constant    DELAYALIGNRST                            : std_logic_vector(24 downto 0) :=  "0000000010000000000000000";
   constant    SETENPMAPHASEALIGN                       : std_logic_vector(24 downto 0) :=  "0000000100000000000000000";
   constant    TXALIGNDISABLEDEASSERT                   : std_logic_vector(24 downto 0) :=  "0000001000000000000000000";
   constant    RATECHANGE_TXDLYALIGNDISABLE             : std_logic_vector(24 downto 0) :=  "0000010000000000000000000";
   constant    GTXTEST_PULSE_1                          : std_logic_vector(24 downto 0) :=  "0000100000000000000000000";
   constant    RATECHANGE_DISABLE_TXALIGNDISABLE        : std_logic_vector(24 downto 0) :=  "0001000000000000000000000";
   constant    BEFORE_GTXTEST_PULSE1_1024CLKS           : std_logic_vector(24 downto 0) :=  "0010000000000000000000000";
   constant    BETWEEN_GTXTEST_PULSES                   : std_logic_vector(24 downto 0) :=  "0100000000000000000000000";
   constant    GTXTEST_PULSE_2                          : std_logic_vector(24 downto 0) :=  "1000000000000000000000000";
   
  function s_idx(
    constant C_SIMULATION    : integer)
    return integer is
     variable sidx_out : integer := 8;
  begin  -- s_idx

    if (C_SIMULATION /= 0) then
      sidx_out := 0;
    else
      sidx_out := 2;
    end if;
    return sidx_out;
  end s_idx;

  function pma_idx(
    constant C_SIMULATION    : integer)
    return integer is
     variable pma_idx_out : integer := 8;
  begin  -- pma_idx

    if (C_SIMULATION /= 0) then
      pma_idx_out := 0;
    else
      pma_idx_out := 7;
    end if;
    return pma_idx_out;
  end pma_idx;

   constant   SYNC_IDX                            : integer := s_idx(C_SIMULATION);
   constant   PMARESET_IDX                        : integer := pma_idx(C_SIMULATION);

   signal ENPMAPHASEALIGN_c                       : std_logic;
   signal PMASETPHASE_c                           : std_logic;
   signal SYNC_DONE_c                             : std_logic;
   signal OUT_DIV_RESET_c                         : std_logic;
   signal PCS_RESET_c                             : std_logic;
   signal USER_PHYSTATUS_c                        : std_logic;
   signal DELAYALIGNRESET_c                       : std_logic;
   signal TXALIGNDISABLE_c                        : std_logic;
   signal state                                   : std_logic_vector(24 downto 0);
   signal nextstate                               : std_logic_vector(24 downto 0);
   signal wait_amt                                : std_logic_vector(15 downto 0);
   signal wait_c                                  : std_logic_vector(15 downto 0);
   signal waitcounter                             : std_logic_vector(7 downto 0);
   signal nextwaitcounter                         : std_logic_vector(7 downto 0);
   signal waitcounter2                            : std_logic_vector(7 downto 0);
   signal waitcounter2_check                      : std_logic_vector(7 downto 0);
   signal nextwaitcounter2                        : std_logic_vector(7 downto 0);
   signal ratedone_r                              : std_logic;
   signal ratedone_r2                             : std_logic;
   signal ratedone_pulse_i                        : std_logic;

   signal gt_phystatus_q                          : std_logic;
   
   -- Declare intermediate signals for referenced outputs
   signal state_v6pcie0                           : std_logic_vector(4 downto 0);
--   signal waitcounter_v6pcie1                     : std_logic_vector(16 downto 0);

begin

   -- Drive referenced outputs
--   state <= state_v6pcie0;
--   waitcounter <= waitcounter_v6pcie1;
   
   process (USER_CLK)
   begin
      if (USER_CLK'event and USER_CLK = '1') then
         
         if (RESET = '1') then

            state <= RESET_STATE after (TCQ)*1 ps;
            waitcounter <= X"00" after (TCQ)*1 ps;
            waitcounter2 <= X"00" after (TCQ)*1 ps;
            USER_PHYSTATUS <= GT_PHYSTATUS after (TCQ)*1 ps;
            SYNC_DONE <= '0' after (TCQ)*1 ps;
            ENPMAPHASEALIGN <= '0' after (TCQ)*1 ps;
            PMASETPHASE <= '0' after (TCQ)*1 ps;
            OUT_DIV_RESET <= '0' after (TCQ)*1 ps;
            PCS_RESET <= '0' after (TCQ)*1 ps;
            DELAYALIGNRESET <= '0' after (TCQ)*1 ps;
            TXALIGNDISABLE <= '1' after (TCQ)*1 ps;

         else

            state <= nextstate after (TCQ)*1 ps;
            waitcounter <= nextwaitcounter after (TCQ)*1 ps;
            waitcounter2 <= nextwaitcounter2 after (TCQ)*1 ps;
            USER_PHYSTATUS <= USER_PHYSTATUS_c after (TCQ)*1 ps;
            SYNC_DONE <= SYNC_DONE_c after (TCQ)*1 ps;
            ENPMAPHASEALIGN <= ENPMAPHASEALIGN_c after (TCQ)*1 ps;
            PMASETPHASE <= PMASETPHASE_c after (TCQ)*1 ps;
            OUT_DIV_RESET <= OUT_DIV_RESET_c after (TCQ)*1 ps;
            PCS_RESET <= PCS_RESET_c after (TCQ)*1 ps;
            DELAYALIGNRESET <= DELAYALIGNRESET_c after (TCQ)*1 ps;
            TXALIGNDISABLE <= TXALIGNDISABLE_c after (TCQ)*1 ps;

         end if;
      end if;
   end process;

   waitcounter2_check <= waitcounter2 + X"01" when (waitcounter = X"FF") else 
                        waitcounter2;
   
   process (state, GT_PHYSTATUS, waitcounter, waitcounter2, waitcounter2_check, ratedone_pulse_i, gt_phystatus_q, RESETDONE)
   begin
      
      -- DEFAULT CONDITIONS
      
      DELAYALIGNRESET_c <= '0';
      SYNC_DONE_c <= '0';
      ENPMAPHASEALIGN_c <= '1';
      PMASETPHASE_c <= '0';
      OUT_DIV_RESET_c <= '0';
      PCS_RESET_c <= '0';
      TXALIGNDISABLE_c <= '0';
      nextstate <= state;
      USER_PHYSTATUS_c <= GT_PHYSTATUS;
      
      nextwaitcounter <= waitcounter + X"01";
      nextwaitcounter2 <= waitcounter2_check;
      
      case state is
         
        -- START IN RESET
         when RESET_STATE =>
            TXALIGNDISABLE_c <= '1';
            ENPMAPHASEALIGN_c <= '0';
            nextstate <= BEFORE_GTXTEST_PULSE1_1024CLKS;
            nextwaitcounter <= X"00";
            nextwaitcounter2 <= X"00";
         
         -- Wait 1024 clocks before asseting GTXTEST[1] - Figure 3-9 UG366
         when BEFORE_GTXTEST_PULSE1_1024CLKS =>
            OUT_DIV_RESET_c <= '0';
            TXALIGNDISABLE_c <= '1';
            ENPMAPHASEALIGN_c <= '0';
            if ((waitcounter2(1)) = '1') then
               nextstate <= GTXTEST_PULSE_1;
               nextwaitcounter <= X"00";
               nextwaitcounter2 <= X"00";
            end if;

         -- Assert GTXTEST[1] for 256 clocks - Figure 3-9 UG366
         when GTXTEST_PULSE_1 =>
            OUT_DIV_RESET_c <= '1';
            TXALIGNDISABLE_c <= '1';
            ENPMAPHASEALIGN_c <= '0';
            if ((waitcounter(7)) = '1') then
               nextstate <= BETWEEN_GTXTEST_PULSES;
               nextwaitcounter <= X"00";
               nextwaitcounter2 <= X"00";
            end if;

         -- De-assert GTXTEST[1] for 256 clocks - Figure 3-9 UG366        
         when BETWEEN_GTXTEST_PULSES =>
            OUT_DIV_RESET_c <= '0';
            TXALIGNDISABLE_c <= '1';
            ENPMAPHASEALIGN_c <= '0';
            if ((waitcounter(7)) = '1') then
               nextstate <= GTXTEST_PULSE_2;
               nextwaitcounter <= X"00";
               nextwaitcounter2 <= X"00";
            end if;

         -- Assert GTXTEST[1] for 256 clocks - Figure 3-9 UG366
         when GTXTEST_PULSE_2 =>
            OUT_DIV_RESET_c <= '1';
            TXALIGNDISABLE_c <= '1';
            ENPMAPHASEALIGN_c <= '0';
            if ((waitcounter(7)) = '1') then
               nextstate <= DELAYALIGNRST;
               nextwaitcounter <= X"00";
               nextwaitcounter2 <= X"00";
            end if;


         -- ASSERT TXDLYALIGNRESET FOR 16 CLOCK CYCLES
         when DELAYALIGNRST =>
            DELAYALIGNRESET_c <= '1';
            ENPMAPHASEALIGN_c <= '0';
            TXALIGNDISABLE_c <= '1';
            if ((waitcounter(4)) = '1') then
               nextstate <= SETENPMAPHASEALIGN;
               nextwaitcounter <= X"00";
               nextwaitcounter2 <= X"00";
            end if;
         
         -- ASSERT ENPMAPHASEALIGN FOR 32 CLOCK CYCLES
         when SETENPMAPHASEALIGN =>
            TXALIGNDISABLE_c <= '1';
            if ((waitcounter(5)) = '1') then
               nextstate <= PHASEALIGN;
               nextwaitcounter <= X"00";
               nextwaitcounter2 <= X"00";
            end if;
         
         -- ASSERT PMASETPHASE OUT OF RESET for 32K CYCLES
         when PHASEALIGN =>
            PMASETPHASE_c <= '1';
            TXALIGNDISABLE_c <= '1';
            if ((waitcounter2(PMARESET_IDX)) = '1') then
               nextstate <= TXALIGNDISABLEDEASSERT;
               nextwaitcounter <= X"00";
               nextwaitcounter2 <= X"00";
            end if;
         
         -- KEEP TXALIGNDISABLE ASSERTED for 64 CYCLES
         when TXALIGNDISABLEDEASSERT =>
            TXALIGNDISABLE_c <= '1';
            if ((waitcounter(6)) = '1') then
               nextwaitcounter <= X"00";
               nextstate <= IDLE;
               nextwaitcounter2 <= X"00";
            end if;
         
         -- NOW IN IDLE, ASSERT SYNC DONE, WAIT FOR RATECHANGE
         when IDLE =>
            SYNC_DONE_c <= '1';
            if (ratedone_pulse_i = '1') then
               USER_PHYSTATUS_c <= '0';
               nextstate <= WAIT_PHYSTATUS;
               nextwaitcounter <= X"00";
               nextwaitcounter2 <= X"00";
            end if;
         
         -- WAIT FOR PHYSTATUS
         when WAIT_PHYSTATUS =>
            USER_PHYSTATUS_c <= '0';
            if (gt_phystatus_q = '1') then
               nextstate <= RATECHANGE_IDLE;
               nextwaitcounter <= X"00";
               nextwaitcounter2 <= X"00";
            end if;
         
         -- WAIT 64 CYCLES BEFORE WE START THE RATE CHANGE
         when RATECHANGE_IDLE =>
            USER_PHYSTATUS_c <= '0';
            if ((waitcounter(6)) = '1') then
               nextstate <= RATECHANGE_TXDLYALIGNDISABLE;
               nextwaitcounter <= X"00";
               nextwaitcounter2 <= X"00";
            end if;
         
         -- ASSERT TXALIGNDISABLE FOR 32 CYCLES
         when RATECHANGE_TXDLYALIGNDISABLE =>
            USER_PHYSTATUS_c <= '0';
            TXALIGNDISABLE_c <= '1';
            if ((waitcounter(5)) = '1') then
               nextstate <= RATECHANGE_DIVRESET;
               nextwaitcounter <= X"00";
               nextwaitcounter2 <= X"00";
            end if;
         
         -- ASSERT DIV RESET FOR 16 CLOCK CYCLES
         when RATECHANGE_DIVRESET =>
            OUT_DIV_RESET_c <= '1';
            USER_PHYSTATUS_c <= '0';
            TXALIGNDISABLE_c <= '1';
            if ((waitcounter(4)) = '1') then
               nextstate <= RATECHANGE_DIVRESET_POST;
               nextwaitcounter <= X"00";
               nextwaitcounter2 <= X"00";
            end if;
         
         -- WAIT FOR 32 CLOCK CYCLES BEFORE NEXT STEP
         when RATECHANGE_DIVRESET_POST =>
            USER_PHYSTATUS_c <= '0';
            TXALIGNDISABLE_c <= '1';
            if ((waitcounter(5)) = '1') then
               nextstate <= RATECHANGE_PMARESET;
               nextwaitcounter <= X"00";
               nextwaitcounter2 <= X"00";
            end if;
         
         -- ASSERT PMA RESET FOR 32K CYCLES
         when RATECHANGE_PMARESET =>
            PMASETPHASE_c <= '1';
            USER_PHYSTATUS_c <= '0';
            TXALIGNDISABLE_c <= '1';
            if ((waitcounter2(PMARESET_IDX)) = '1') then
               nextstate <= RATECHANGE_PMARESET_POST;
               nextwaitcounter <= X"00";
               nextwaitcounter2 <= X"00";
            end if;
         
         -- WAIT FOR 32 CYCLES BEFORE DISABLING TXALIGNDISABLE
         when RATECHANGE_PMARESET_POST =>
            USER_PHYSTATUS_c <= '0';
            TXALIGNDISABLE_c <= '1';
            if ((waitcounter(5)) = '1') then
               nextstate <= RATECHANGE_DISABLE_TXALIGNDISABLE;
               nextwaitcounter <= X"00";
               nextwaitcounter2 <= X"00";
            end if;
         
         -- DISABLE TXALIGNDISABLE FOR 32 CYCLES
         when RATECHANGE_DISABLE_TXALIGNDISABLE =>
            USER_PHYSTATUS_c <= '0';
            if ((waitcounter(5)) = '1') then
               nextstate <= RATECHANGE_PCSRESET;
               nextwaitcounter <= X"00";
               nextwaitcounter2 <= X"00";
            end if;
         
         -- NOW ASSERT PCS RESET FOR 32 CYCLES
         when RATECHANGE_PCSRESET =>
            PCS_RESET_c <= '1';
            USER_PHYSTATUS_c <= '0';
            if ((waitcounter(5)) = '1') then
               nextstate <= RATECHANGE_PCSRESET_POST;
               nextwaitcounter <= X"00";
               nextwaitcounter2 <= X"00";
            end if;
         
         -- WAIT FOR RESETDONE BEFORE ASSERTING PHY_STATUS_OUT
         when RATECHANGE_PCSRESET_POST =>
            USER_PHYSTATUS_c <= '0';
            if (RESETDONE = '1') then
               nextstate <= RATECHANGE_ASSERTPHY;
            end if;
         
         -- ASSERT PHYSTATUSOUT MEANING RATECHANGE IS DONE AND GO BACK TO IDLE
         when RATECHANGE_ASSERTPHY =>
            USER_PHYSTATUS_c <= '1';
            nextstate <= IDLE;

         when others =>
            nextstate <= IDLE;

      end case;
   end process;
   
   
   -- Generate Ratechange Pulse
   
   process (USER_CLK)
   begin
      if (USER_CLK'event and USER_CLK = '1') then
         
         if (RESET = '1') then
            
            ratedone_r <= '0' after (TCQ)*1 ps;
            ratedone_r2 <= '0' after (TCQ)*1 ps;
            gt_phystatus_q <= '0' after (TCQ)*1 ps;

         else
            
            ratedone_r <= RATE after (TCQ)*1 ps;
            ratedone_r2 <= ratedone_r after (TCQ)*1 ps;
            gt_phystatus_q <= GT_PHYSTATUS after (TCQ)*1 ps;

         end if;

      end if;
   end process;
   
   
   ratedone_pulse_i <= to_stdlogic((ratedone_r /= ratedone_r2));
   
end v6_pcie;


