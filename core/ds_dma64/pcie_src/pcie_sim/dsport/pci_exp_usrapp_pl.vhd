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
-- File       : pci_exp_usrapp_pl.vhd
-- Version    : 2.3
--
--------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;

entity pci_exp_usrapp_pl is 
   generic (
     LINK_CAP_MAX_LINK_SPEED : integer := 1);
   port (
      
      pl_initial_link_width           : in std_logic_vector(2 downto 0);
      pl_lane_reversal_mode           : in std_logic_vector(1 downto 0);
      pl_link_gen2_capable            : in std_logic;
      pl_link_partner_gen2_supported  : in std_logic;
      pl_link_upcfg_capable           : in std_logic;
      pl_ltssm_state                  : in std_logic_vector(5 downto 0);
      pl_received_hot_rst             : in std_logic;
      pl_sel_link_rate                : in std_logic;
      pl_sel_link_width               : in std_logic_vector(1 downto 0);
      pl_directed_link_auton          : out std_logic;
      pl_directed_link_change         : out std_logic_vector(1 downto 0);
      pl_directed_link_speed          : out std_logic;
      pl_directed_link_width          : out std_logic_vector(1 downto 0);
      pl_upstream_prefer_deemph       : out std_logic;
      speed_change_done_n             : out std_logic;
      
      trn_lnk_up_n                    : in std_logic;
      trn_clk                         : in std_logic;
      trn_reset_n                     : in std_logic
   );
end pci_exp_usrapp_pl;

architecture rtl of pci_exp_usrapp_pl is
   
   constant Tcq                     : integer := 1;
begin
   
   process 
   begin
      
      pl_directed_link_auton <= '0';
      pl_directed_link_change <= "00";
      pl_directed_link_speed <= '0';
      pl_directed_link_width <= "00";
      pl_upstream_prefer_deemph <= '0';
      
      speed_change_done_n <= '1';
      if (LINK_CAP_MAX_LINK_SPEED = 2) then
         
         wait until trn_lnk_up_n = '0';
         
         pl_directed_link_speed <= '1';
         pl_directed_link_change <= "10";

         wait until pl_ltssm_state = "100000";
         
         pl_directed_link_speed <= '0';
         pl_directed_link_change <= "00";

         if pl_sel_link_rate = '0' then
             wait until pl_sel_link_rate = '1';
             speed_change_done_n <= '0';
         else
             speed_change_done_n <= '0';
         end if;

      end if;
      wait;
   end process;
   
   
end rtl;




-- pci_exp_usrapp_pl
