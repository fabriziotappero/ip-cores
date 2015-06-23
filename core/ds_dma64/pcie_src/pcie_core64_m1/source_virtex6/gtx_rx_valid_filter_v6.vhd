
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
-- File       : gtx_rx_valid_filter_v6.vhd
-- Version    : 2.3
-------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

entity GTX_RX_VALID_FILTER_V6 is
   generic (
      
      CLK_COR_MIN_LAT                           : integer := 28
   );
   port (
      USER_RXCHARISK                            : out std_logic_vector(1 downto 0);
      USER_RXDATA                               : out std_logic_vector(15 downto 0);
      USER_RXVALID                              : out std_logic;
      USER_RXELECIDLE                           : out std_logic;
      USER_RX_STATUS                            : out std_logic_vector(2 downto 0);
      USER_RX_PHY_STATUS                        : out std_logic;
      GT_RXCHARISK                              : in std_logic_vector(1 downto 0);
      GT_RXDATA                                 : in std_logic_vector(15 downto 0);
      GT_RXVALID                                : in std_logic;
      GT_RXELECIDLE                             : in std_logic;
      GT_RX_STATUS                              : in std_logic_vector(2 downto 0);
      GT_RX_PHY_STATUS                          : in std_logic;
      PLM_IN_L0                                 : in std_logic;
      PLM_IN_RS                                 : in std_logic;
      USER_CLK                                  : in std_logic;
      RESET                                     : in std_logic
   );
end GTX_RX_VALID_FILTER_V6;

architecture v6_pcie of GTX_RX_VALID_FILTER_V6 is

   constant TCQ                                   : integer := 1;

   constant EIOS_DET_IDL                          : std_logic_vector(4 downto 0) := "00001";
   constant EIOS_DET_NO_STR0                      : std_logic_vector(4 downto 0) := "00010";
   constant EIOS_DET_STR0                         : std_logic_vector(4 downto 0) := "00100";
   constant EIOS_DET_STR1                         : std_logic_vector(4 downto 0) := "01000";
   constant EIOS_DET_DONE                         : std_logic_vector(4 downto 0) := "10000";

   constant EIOS_COM                              : std_logic_vector(7 downto 0) := "10111100";
   constant EIOS_IDL                              : std_logic_vector(7 downto 0) := "01111100";
   constant FTSOS_COM                             : std_logic_vector(7 downto 0) := "10111100";
   constant FTSOS_FTS                             : std_logic_vector(7 downto 0) := "00111100";

   constant USER_RXVLD_IDL                        : std_logic_vector(3 downto 0) := "0001";
   constant USER_RXVLD_EI                         : std_logic_vector(3 downto 0) := "0010";
   constant USER_RXVLD_EI_DB0                     : std_logic_vector(3 downto 0) := "0100";
   constant USER_RXVLD_EI_DB1                     : std_logic_vector(3 downto 0) := "1000";

   constant TS1_FILTER_IDLE                       : std_logic_vector(2 downto 0) := "001";
   constant TS1_FILTER_WAITVALID                  : std_logic_vector(2 downto 0) := "010";
   constant TS1_FILTER_DB                         : std_logic_vector(2 downto 0) := "100";

   FUNCTION to_stdlogicvector (
      val_in      : IN integer;
      length      : IN integer) RETURN std_logic_vector IS
      
      VARIABLE ret      : std_logic_vector(length-1 DOWNTO 0) := (OTHERS => '0');
      VARIABLE num      : integer := val_in;
      VARIABLE x        : integer;
   BEGIN
      FOR index IN 0 TO length-1 LOOP
         x := num rem 2;
         num := num/2;
         IF (x = 1) THEN
            ret(index) := '1';
         ELSE
            ret(index) := '0';
         END IF;
      END LOOP;
      RETURN(ret);
   END to_stdlogicvector;

  FUNCTION to_stdlogic (
    in_val      : IN boolean) RETURN std_logic IS
  BEGIN
    IF (in_val) THEN
      RETURN('1');
    ELSE
      RETURN('0');
    END IF;
  END to_stdlogic;

   signal reg_state_eios_det                      : std_logic_vector(4 downto 0);
   signal state_eios_det                          : std_logic_vector(4 downto 0);
   signal reg_eios_detected                       : std_logic;
   signal eios_detected                           : std_logic;
   signal reg_symbol_after_eios                   : std_logic;
   signal symbol_after_eios                       : std_logic;
   
   signal reg_state_rxvld_ei                      : std_logic_vector(3 downto 0);
   signal state_rxvld_ei                          : std_logic_vector(3 downto 0);
   
   signal reg_rxvld_count                         : std_logic_vector(4 downto 0);
   signal rxvld_count                             : std_logic_vector(4 downto 0);
   
   signal reg_rxvld_fallback                      : std_logic_vector(3 downto 0);
   signal rxvld_fallback                          : std_logic_vector(3 downto 0);
   
   signal gt_rxcharisk_q                          : std_logic_vector(1 downto 0);
   signal gt_rxdata_q                             : std_logic_vector(15 downto 0);
   signal gt_rxvalid_q                            : std_logic;
   signal gt_rxelecidle_q                         : std_logic;
   signal gt_rxelecidle_qq                        : std_logic;
   
   signal gt_rx_status_q                          : std_logic_vector(2 downto 0);
   signal gt_rx_phy_status_q                      : std_logic;
   signal gt_rx_is_skp0_q                         : std_logic;
   signal gt_rx_is_skp1_q                         : std_logic;
   
   signal ts1_state                               : std_logic_vector(2 downto 0);
   signal next_ts1_state                          : std_logic_vector(2 downto 0);
   signal ts1_resetcount                          : std_logic;
   signal ts1_count                               : std_logic_vector(8 downto 0);
   signal ts1_filter_done                         : std_logic;
   signal next_ts1_filter_done                    : std_logic;

   signal awake_in_progress_q                     : std_logic := '0';
   signal awake_in_progress                       : std_logic := '0';
   signal awake_see_com_q                         : std_logic := '0';
   signal awake_com_count_q                       : std_logic_vector(3 downto 0) := "0000";
   signal awake_com_count                         : std_logic_vector(3 downto 0) := "0000";
   signal awake_com_count_inced                   : std_logic_vector(3 downto 0) := "0000";

   signal awake_see_com_0                         : std_logic;
   signal awake_see_com_1                         : std_logic;
   signal awake_see_com                           : std_logic;
   signal awake_done                              : std_logic;
   signal awake_start                             : std_logic;

   signal rst_l                                   : std_logic;

   
   -- Declare intermediate signals for referenced outputs
   signal USER_RXVALID_v6pcie1                    : std_logic;
   signal USER_RXELECIDLE_v6pcie0                 : std_logic;

begin
   -- Drive referenced outputs
   USER_RXVALID <= USER_RXVALID_v6pcie1;
   USER_RXELECIDLE <= USER_RXELECIDLE_v6pcie0;
   
   -- EIOS detector
   
   process (USER_CLK)
   begin
      if (USER_CLK'event and USER_CLK = '1') then
         
         if (RESET = '1') then
            
            reg_eios_detected <= '0' after (TCQ)*1 ps;
            reg_state_eios_det <= EIOS_DET_IDL after (TCQ)*1 ps;
            reg_symbol_after_eios <= '0' after (TCQ)*1 ps;
            gt_rxcharisk_q <= "00" after (TCQ)*1 ps;
            gt_rxdata_q <= "0000000000000000" after (TCQ)*1 ps;
            gt_rxvalid_q <= '0' after (TCQ)*1 ps;
            gt_rxelecidle_q <= '0' after (TCQ)*1 ps;
            gt_rxelecidle_qq <= '0' after (TCQ)*1 ps;
            gt_rx_status_q <= "000" after (TCQ)*1 ps;
            
            gt_rx_phy_status_q <= '0' after (TCQ)*1 ps;
            gt_rx_is_skp0_q <= '0' after (TCQ)*1 ps;
            gt_rx_is_skp1_q <= '0' after (TCQ)*1 ps;

         else

            reg_eios_detected <= '0' after (TCQ)*1 ps;
            reg_symbol_after_eios <= '0' after (TCQ)*1 ps;
            gt_rxcharisk_q <= GT_RXCHARISK after (TCQ)*1 ps;
            gt_rxdata_q <= GT_RXDATA after (TCQ)*1 ps;
            gt_rxvalid_q <= GT_RXVALID after (TCQ)*1 ps;
            gt_rxelecidle_q <= GT_RXELECIDLE after (TCQ)*1 ps;
            gt_rxelecidle_qq <= gt_rxelecidle_q after (TCQ)*1 ps;
            gt_rx_status_q <= GT_RX_STATUS after (TCQ)*1 ps;
            
            gt_rx_phy_status_q <= GT_RX_PHY_STATUS after (TCQ)*1 ps;

            if ((GT_RXCHARISK(0) = '1') and (GT_RXDATA(7 downto 0) = FTSOS_FTS)) then
              gt_rx_is_skp0_q  <= '1' after (TCQ)*1 ps;
            else
              gt_rx_is_skp0_q  <= '0' after (TCQ)*1 ps;
            end if;

            if ((GT_RXCHARISK(1) = '1') and (GT_RXDATA(15 downto 8) = FTSOS_FTS)) then
              gt_rx_is_skp1_q  <= '1' after (TCQ)*1 ps;
            else
              gt_rx_is_skp1_q  <= '0' after (TCQ)*1 ps;
            end if;

            case state_eios_det is
               
               when EIOS_DET_IDL =>
                  if ((gt_rxcharisk_q(0) = '1') and (gt_rxdata_q(7 downto 0) = EIOS_COM) and (gt_rxcharisk_q(1) = '1') and (gt_rxdata_q(15 downto 8) = EIOS_IDL)) then
                     reg_state_eios_det <= EIOS_DET_NO_STR0 after (TCQ)*1 ps;
                     reg_eios_detected <= '1' after (TCQ)*1 ps;
                  elsif ((gt_rxcharisk_q(1) = '1') and (gt_rxdata_q(15 downto 8) = EIOS_COM)) then
                     reg_state_eios_det <= EIOS_DET_STR0 after (TCQ)*1 ps;
                  else
                     reg_state_eios_det <= EIOS_DET_IDL after (TCQ)*1 ps;
                  end if;
               
               when EIOS_DET_NO_STR0 =>
                  if ((gt_rxcharisk_q(0) = '1') and (gt_rxdata_q(7 downto 0) = EIOS_IDL) and (gt_rxcharisk_q(1) = '1') and (gt_rxdata_q(15 downto 8) = EIOS_IDL)) then
                     reg_state_eios_det <= EIOS_DET_DONE after (TCQ)*1 ps;
                  else
                     reg_state_eios_det <= EIOS_DET_IDL after (TCQ)*1 ps;
                  end if;
               
               when EIOS_DET_STR0 =>
                  if ((gt_rxcharisk_q(0) = '1') and (gt_rxdata_q(7 downto 0) = EIOS_IDL) and (gt_rxcharisk_q(1) = '1') and (gt_rxdata_q(15 downto 8) = EIOS_IDL)) then
                     reg_state_eios_det <= EIOS_DET_STR1 after (TCQ)*1 ps;
                     reg_eios_detected <= '1' after (TCQ)*1 ps;
                     reg_symbol_after_eios <= '1' after (TCQ)*1 ps;
                  else
                     reg_state_eios_det <= EIOS_DET_IDL after (TCQ)*1 ps;
                  end if;
               
               when EIOS_DET_STR1 =>
                  if ((gt_rxcharisk_q(0) = '1') and (gt_rxdata_q(7 downto 0) = EIOS_IDL)) then
                     reg_state_eios_det <= EIOS_DET_DONE after (TCQ)*1 ps;
                  else
                     reg_state_eios_det <= EIOS_DET_IDL after (TCQ)*1 ps;
                  end if;
               
               when EIOS_DET_DONE =>
                  reg_state_eios_det <= EIOS_DET_IDL after (TCQ)*1 ps;

              when others =>
                  reg_state_eios_det <= EIOS_DET_IDL after (TCQ)*1 ps;
            end case;
         end if;
      end if;
   end process;
   
   state_eios_det <= reg_state_eios_det;
   eios_detected <= reg_eios_detected;
   symbol_after_eios <= reg_symbol_after_eios;
   
   -- user_rxvalid generation
   
   process (USER_CLK)
   begin
      if (USER_CLK'event and USER_CLK = '1') then
         
         if (RESET = '1') then
            reg_state_rxvld_ei <= USER_RXVLD_IDL after (TCQ)*1 ps;
         else
            case state_rxvld_ei is
               
               when USER_RXVLD_IDL =>
                  if (eios_detected = '1') then
                     reg_state_rxvld_ei <= USER_RXVLD_EI after (TCQ)*1 ps;
                  else
                     reg_state_rxvld_ei <= USER_RXVLD_IDL after (TCQ)*1 ps;
                  end if;
               
               when USER_RXVLD_EI =>
                  if ((not(gt_rxvalid_q)) = '1') then
                     reg_state_rxvld_ei <= USER_RXVLD_EI_DB0 after (TCQ)*1 ps;
                  elsif (rxvld_fallback = "1111") then
                     reg_state_rxvld_ei <= USER_RXVLD_IDL after (TCQ)*1 ps;
                  else
                     reg_state_rxvld_ei <= USER_RXVLD_EI after (TCQ)*1 ps;
                  end if;
               
               when USER_RXVLD_EI_DB0 =>
                  if (gt_rxvalid_q = '1') then
                     reg_state_rxvld_ei <= USER_RXVLD_EI_DB1 after (TCQ)*1 ps;
                  elsif ((not(PLM_IN_L0)) = '1') then
                     reg_state_rxvld_ei <= USER_RXVLD_IDL after (TCQ)*1 ps;
                  else
                     reg_state_rxvld_ei <= USER_RXVLD_EI_DB0 after (TCQ)*1 ps;
                  end if;
               
               when USER_RXVLD_EI_DB1 =>
                  if (rxvld_count > to_stdlogicvector(CLK_COR_MIN_LAT, 5)) then
                     reg_state_rxvld_ei <= USER_RXVLD_IDL after (TCQ)*1 ps;
                  else
                     reg_state_rxvld_ei <= USER_RXVLD_EI_DB1 after (TCQ)*1 ps;
                  end if;
              when others =>
                 reg_state_rxvld_ei <= USER_RXVLD_IDL after (TCQ)*1 ps;
            end case;
         end if;
      end if;
   end process;
   
   
   state_rxvld_ei <= reg_state_rxvld_ei;
   
   -- RxValid counter
   
   process (USER_CLK)
   begin
      if (USER_CLK'event and USER_CLK = '1') then
         
         if (RESET = '1') then
            reg_rxvld_count <= "00000" after (TCQ)*1 ps;
         else
            
            if ((gt_rxvalid_q = '1') and (state_rxvld_ei = USER_RXVLD_EI_DB1)) then
               reg_rxvld_count <= reg_rxvld_count + "00001" after (TCQ)*1 ps;
            else
               reg_rxvld_count <= "00000" after (TCQ)*1 ps;
            end if;

         end if;
      end if;
   end process;
   
   
   rxvld_count <= reg_rxvld_count;
   
   -- RxValid fallback
   
   process (USER_CLK)
   begin
      if (USER_CLK'event and USER_CLK = '1') then
         if (RESET = '1') then
            reg_rxvld_fallback <= "0000" after (TCQ)*1 ps;
         else
            if (state_rxvld_ei = USER_RXVLD_EI) then
               reg_rxvld_fallback <= reg_rxvld_fallback + "0001" after (TCQ)*1 ps;
            else
               reg_rxvld_fallback <= "0000" after (TCQ)*1 ps;
            end if;
         end if;
      end if;
   end process;
   
   rxvld_fallback <= reg_rxvld_fallback;
   
   -- Delay pipe_rx_elec_idle

   rx_elec_idle_delay : SRL16E
      generic map (
         INIT  => X"0000"
      )
      port map (
         Q    => USER_RXELECIDLE_v6pcie0,
         D    => gt_rxelecidle_q,
         CLK  => USER_CLK,
         CE   => '1',
         A3   => '1',
         A2   => '1',
         A1   => '1',
         A0   => '1'
      );

   awake_see_com_0      <= GT_RXVALID and (gt_rxcharisk_q(0) and to_stdlogic(gt_rxdata_q(7 downto 0) = EIOS_COM));

   awake_see_com_1      <= GT_RXVALID and (gt_rxcharisk_q(1) and to_stdlogic(gt_rxdata_q(15 downto 8) = EIOS_COM));

   awake_see_com        <= (awake_see_com_0 or awake_see_com_1) and not(awake_see_com_q);
   
-- Count 8 COMs, (not back-to-back), when waking up from electrical idle
--  but not for L0s (which is L0).

   awake_done  <= awake_in_progress_q and to_stdlogic(awake_com_count_q(3 downto 0) >= X"b");

   awake_start <= (not(gt_rxelecidle_q) and gt_rxelecidle_qq) or PLM_IN_RS;

   awake_in_progress <= awake_start or (not(awake_done) and awake_in_progress_q);

   awake_com_count_inced <= awake_com_count_q(3 downto 0) + "0001";

   awake_com_count <= "0000" when (not(awake_in_progress_q) = '1') else 
                      "0000" when (awake_start = '1') else 
                      awake_com_count_inced(3 downto 0) when (awake_see_com_q = '1') else 
                      awake_com_count_q(3 downto 0);

   rst_l  <= not(RESET);

   process (USER_CLK)
   begin
      if (USER_CLK'event and USER_CLK = '1') then
         if (rst_l = '0') then
            awake_see_com_q <= '0';
            awake_in_progress_q <= '0';
            awake_com_count_q(3 downto 0) <= "0000";
         else
            awake_see_com_q <= awake_see_com;
            awake_in_progress_q <= awake_in_progress;
            awake_com_count_q(3 downto 0) <= awake_com_count(3 downto 0);
         end if;
      end if;
   end process;

   USER_RXVALID_v6pcie1 <= gt_rxvalid_q when ((state_rxvld_ei = USER_RXVLD_IDL) and (not(awake_in_progress_q) = '1')) else
                           '0';
   USER_RXCHARISK(0)    <= gt_rxcharisk_q(0) when (USER_RXVALID_v6pcie1 = '1') else
                           '0';
   USER_RXCHARISK(1)    <= gt_rxcharisk_q(1) when ((USER_RXVALID_v6pcie1 and not(symbol_after_eios)) = '1') else
                           '0';
   USER_RXDATA(7 downto 0) <= FTSOS_COM when (gt_rx_is_skp0_q = '1') else 
                             gt_rxdata_q(7 downto 0);

   USER_RXDATA(15 downto 8) <= FTSOS_COM when (gt_rx_is_skp1_q = '1') else 
                             gt_rxdata_q(15 downto 8);

   USER_RX_STATUS       <= gt_rx_status_q when (state_rxvld_ei = USER_RXVLD_IDL) else
                           "000";
   USER_RX_PHY_STATUS   <= gt_rx_phy_status_q;
   
end v6_pcie;


