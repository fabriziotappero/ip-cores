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
-- File       : pcie_pipe_misc_v6.vhd
-- Version    : 2.3
---- Description: Misc PIPE module for Virtex6 PCIe Block
----
----
----
----------------------------------------------------------------------------------

library ieee;
   use ieee.std_logic_1164.all;

entity pcie_pipe_misc_v6 is
   generic (
      PIPE_PIPELINE_STAGES                         : integer := 0		-- 0 - 0 stages, 1 - 1 stage, 2 - 2 stages
      
   );
   port (
      pipe_tx_rcvr_det_i                           : in std_logic;
      pipe_tx_reset_i                              : in std_logic;
      pipe_tx_rate_i                               : in std_logic;
      pipe_tx_deemph_i                             : in std_logic;
      pipe_tx_margin_i                             : in std_logic_vector(2 downto 0);
      pipe_tx_swing_i                              : in std_logic;
      pipe_tx_rcvr_det_o                           : out std_logic;
      pipe_tx_reset_o                              : out std_logic;
      pipe_tx_rate_o                               : out std_logic;
      pipe_tx_deemph_o                             : out std_logic;
      pipe_tx_margin_o                             : out std_logic_vector(2 downto 0);
      pipe_tx_swing_o                              : out std_logic;
      pipe_clk                                     : in std_logic;
      rst_n                                        : in std_logic
   );
end pcie_pipe_misc_v6;

architecture v6_pcie of pcie_pipe_misc_v6 is
   
   --******************************************************************//
   -- Reality check.                                                   //
   --******************************************************************//
      
   constant TCQ                                    : integer := 1;		-- clock to out delay model

   signal pipe_tx_rcvr_det_q                       : std_logic;
   signal pipe_tx_reset_q                          : std_logic;
   signal pipe_tx_rate_q                           : std_logic;
   signal pipe_tx_deemph_q                         : std_logic;
   signal pipe_tx_margin_q                         : std_logic_vector(2 downto 0);
   signal pipe_tx_swing_q                          : std_logic;
   
   signal pipe_tx_rcvr_det_qq                      : std_logic;
   signal pipe_tx_reset_qq                         : std_logic;
   signal pipe_tx_rate_qq                          : std_logic;
   signal pipe_tx_deemph_qq                        : std_logic;
   signal pipe_tx_margin_qq                        : std_logic_vector(2 downto 0);
   signal pipe_tx_swing_qq                         : std_logic;
begin
   
   v6pcie0 : if (PIPE_PIPELINE_STAGES = 0) generate
      
      pipe_tx_rcvr_det_o <= pipe_tx_rcvr_det_i;
      pipe_tx_reset_o <= pipe_tx_reset_i;
      pipe_tx_rate_o <= pipe_tx_rate_i;
      pipe_tx_deemph_o <= pipe_tx_deemph_i;
      pipe_tx_margin_o <= pipe_tx_margin_i;
      pipe_tx_swing_o <= pipe_tx_swing_i;
      
   end generate;
   v6pcie1 : if (PIPE_PIPELINE_STAGES = 1) generate
         
      process (pipe_clk)
      begin
         if (pipe_clk'event and pipe_clk = '1') then
            
            if (rst_n = '1') then
               
               pipe_tx_rcvr_det_q <= '0' after (TCQ)*1 ps;
               pipe_tx_reset_q <= '1' after (TCQ)*1 ps;
               pipe_tx_rate_q <= '0' after (TCQ)*1 ps;
               pipe_tx_deemph_q <= '1' after (TCQ)*1 ps;
               pipe_tx_margin_q <= "000" after (TCQ)*1 ps;
               pipe_tx_swing_q <= '0' after (TCQ)*1 ps;
            else
               
               pipe_tx_rcvr_det_q <= pipe_tx_rcvr_det_i after (TCQ)*1 ps;
               pipe_tx_reset_q <= pipe_tx_reset_i after (TCQ)*1 ps;
               pipe_tx_rate_q <= pipe_tx_rate_i after (TCQ)*1 ps;
               pipe_tx_deemph_q <= pipe_tx_deemph_i after (TCQ)*1 ps;
               pipe_tx_margin_q <= pipe_tx_margin_i after (TCQ)*1 ps;
               pipe_tx_swing_q <= pipe_tx_swing_i after (TCQ)*1 ps;
            end if;
         end if;
      end process;

      pipe_tx_rcvr_det_o <= pipe_tx_rcvr_det_q;
      pipe_tx_reset_o <= pipe_tx_reset_q;
      pipe_tx_rate_o <= pipe_tx_rate_q;
      pipe_tx_deemph_o <= pipe_tx_deemph_q;
      pipe_tx_margin_o <= pipe_tx_margin_q;
      pipe_tx_swing_o <= pipe_tx_swing_q;
      
   end generate;
   v6pcie2 : if (PIPE_PIPELINE_STAGES = 2) generate
            
      process (pipe_clk)
      begin
         if (pipe_clk'event and pipe_clk = '1') then
            
            if (rst_n = '1') then
               
               pipe_tx_rcvr_det_q <= '0' after (TCQ)*1 ps;
               pipe_tx_reset_q <= '1' after (TCQ)*1 ps;
               pipe_tx_rate_q <= '0' after (TCQ)*1 ps;
               pipe_tx_deemph_q <= '1' after (TCQ)*1 ps;
               pipe_tx_margin_q <= "000" after (TCQ)*1 ps;
               pipe_tx_swing_q <= '0' after (TCQ)*1 ps;

               pipe_tx_rcvr_det_qq <= '0' after (TCQ)*1 ps;
               pipe_tx_reset_qq <= '1' after (TCQ)*1 ps;
               pipe_tx_rate_qq <= '0' after (TCQ)*1 ps;
               pipe_tx_deemph_qq <= '1' after (TCQ)*1 ps;
               pipe_tx_margin_qq <= "000" after (TCQ)*1 ps;
               pipe_tx_swing_qq <= '0' after (TCQ)*1 ps;
            else
               
               pipe_tx_rcvr_det_q <= pipe_tx_rcvr_det_i after (TCQ)*1 ps;
               pipe_tx_reset_q <= pipe_tx_reset_i after (TCQ)*1 ps;
               pipe_tx_rate_q <= pipe_tx_rate_i after (TCQ)*1 ps;
               pipe_tx_deemph_q <= pipe_tx_deemph_i after (TCQ)*1 ps;
               pipe_tx_margin_q <= pipe_tx_margin_i after (TCQ)*1 ps;
               pipe_tx_swing_q <= pipe_tx_swing_i after (TCQ)*1 ps;

               pipe_tx_rcvr_det_qq <= pipe_tx_rcvr_det_q after (TCQ)*1 ps;
               pipe_tx_reset_qq <= pipe_tx_reset_q after (TCQ)*1 ps;
               pipe_tx_rate_qq <= pipe_tx_rate_q after (TCQ)*1 ps;
               pipe_tx_deemph_qq <= pipe_tx_deemph_q after (TCQ)*1 ps;
               pipe_tx_margin_qq <= pipe_tx_margin_q after (TCQ)*1 ps;
               pipe_tx_swing_qq <= pipe_tx_swing_q after (TCQ)*1 ps;
            end if;
         end if;
      end process;
            
            
      pipe_tx_rcvr_det_o <= pipe_tx_rcvr_det_qq;
      pipe_tx_reset_o <= pipe_tx_reset_qq;
      pipe_tx_rate_o <= pipe_tx_rate_qq;
      pipe_tx_deemph_o <= pipe_tx_deemph_qq;
      pipe_tx_margin_o <= pipe_tx_margin_qq;
      pipe_tx_swing_o <= pipe_tx_swing_qq;
      
   end generate;

end v6_pcie;


