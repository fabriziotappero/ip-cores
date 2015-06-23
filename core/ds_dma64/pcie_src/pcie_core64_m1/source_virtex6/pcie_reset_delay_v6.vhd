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
-- File       : pcie_reset_delay_v6.vhd
-- Version    : 2.3
-- Description: sys_reset_n delay (20ms) for Virtex6 PCIe Block
--
--
--
--------------------------------------------------------------------------------

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_unsigned.all;

entity pcie_reset_delay_v6 is
   generic (
      
      PL_FAST_TRAIN                                : boolean := FALSE;
      REF_CLK_FREQ                                 : integer := 0		-- 0 - 100 MHz, 1 - 125 MHz, 2 - 250 MHz
   );
   port (
      ref_clk                                      : in std_logic;
      sys_reset_n                                  : in std_logic;
      delayed_sys_reset_n                          : out std_logic
   );
end pcie_reset_delay_v6;

architecture v6_pcie of pcie_reset_delay_v6 is
   
   constant TCQ                                    : integer := 1;
      
  function t_bit(
    constant PL_FAST_TRAIN    : boolean;
    constant REF_CLK_FREQ     : integer)
    return integer is
     variable tbit_out : integer := 2;
  begin  -- t_bit

    if (PL_FAST_TRAIN) then
      tbit_out := 2;
    else
     if (REF_CLK_FREQ = 0) then
      tbit_out := 20;
     elsif (REF_CLK_FREQ = 1) then
      tbit_out := 20;
     else
      tbit_out := 21;
     end if;
    end if;
    return tbit_out;
  end t_bit;

   constant TBIT                                   : integer := t_bit(PL_FAST_TRAIN, REF_CLK_FREQ);

   signal reg_count_7_0                            : std_logic_vector(7 downto 0);
   signal reg_count_15_8                           : std_logic_vector(7 downto 0);
   signal reg_count_23_16                          : std_logic_vector(7 downto 0);
   signal concat_count                             : std_logic_vector(23 downto 0);

   -- X-HDL generated signals

   signal v6pcie1 : std_logic_vector(7 downto 0);
   signal v6pcie2 : std_logic_vector(7 downto 0);
   
   -- Declare intermediate signals for referenced outputs
   signal delayed_sys_reset_n_v6pcie0                  : std_logic;

begin
   -- Drive referenced outputs
   delayed_sys_reset_n <= delayed_sys_reset_n_v6pcie0;
   
   concat_count <= (reg_count_23_16 & reg_count_15_8 & reg_count_7_0);
   
   
   v6pcie1 <= reg_count_15_8 + "00000001" when (reg_count_7_0 = "11111111") else
              reg_count_15_8;

   v6pcie2 <= reg_count_23_16 + "00000001" when ((reg_count_15_8 = "11111111") and (reg_count_7_0 = "11111111")) else
              reg_count_23_16;

   process (ref_clk, sys_reset_n)
   begin
     if ((not(sys_reset_n)) = '1') then

        reg_count_7_0 <= "00000000" after (TCQ)*1 ps;
        reg_count_15_8 <= "00000000" after (TCQ)*1 ps;
        reg_count_23_16 <= "00000000" after (TCQ)*1 ps;

     elsif (ref_clk'event and ref_clk = '1') then

       if (delayed_sys_reset_n_v6pcie0 /= '1') then

         reg_count_7_0 <= reg_count_7_0 + "00000001" after (TCQ)*1 ps;
         reg_count_15_8 <= v6pcie1 after (TCQ)*1 ps;
         reg_count_23_16 <= v6pcie2 after (TCQ)*1 ps;

       end if;

     end if;
   end process;
   
   
   delayed_sys_reset_n_v6pcie0 <= concat_count(TBIT);
   
end v6_pcie;


