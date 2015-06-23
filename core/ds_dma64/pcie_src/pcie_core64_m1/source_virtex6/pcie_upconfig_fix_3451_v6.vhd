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
-- File       : pcie_upconfig_fix_3451_v6.vhd
-- Version    : 2.3
---- Description: Virtex6 Workaround for Root Port Upconfigurability Bug
----
----
----------------------------------------------------------------------------------

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_unsigned.all;

entity pcie_upconfig_fix_3451_v6 is
   generic (
      
      UPSTREAM_FACING                              : boolean := TRUE;
      PL_FAST_TRAIN                                : boolean := FALSE;
      LINK_CAP_MAX_LINK_WIDTH                      : bit_vector := X"08"
   );
   port (
      pipe_clk                                     : in std_logic;
      pl_phy_lnkup_n                               : in std_logic;
      pl_ltssm_state                               : in std_logic_vector(5 downto 0);
      pl_sel_lnk_rate                              : in std_logic;
      pl_directed_link_change                      : in std_logic_vector(1 downto 0);
      cfg_link_status_negotiated_width             : in std_logic_vector(3 downto 0);
      pipe_rx0_data                                : in std_logic_vector(15 downto 0);
      pipe_rx0_char_isk                            : in std_logic_vector(1 downto 0);
      filter_pipe                                  : out std_logic
   );
end pcie_upconfig_fix_3451_v6;

architecture v6_pcie of pcie_upconfig_fix_3451_v6 is

  -- purpose: perform bitwise and and check for value 
  function slv_check (
    val_in1   : std_logic_vector(7 downto 0);
    val_in2   : std_logic_vector(7 downto 0);
    val_check : std_logic_vector(7 downto 0))
    return std_logic is 

    variable val_bw : std_logic_vector(7 downto 0) := X"00";
  begin  -- slv_check
    for i in 7 downto 0 loop
      val_bw(i) := val_in1(i) and val_in2(i);
    end loop;  -- i
    if val_bw = val_check then
      return '1';
    else
      return '0';
    end if;
  end slv_check;

  FUNCTION to_stdlogic (
    in_val      : IN boolean) RETURN std_logic IS
  BEGIN
    IF (in_val) THEN
      RETURN('1');
    ELSE
      RETURN('0');
    END IF;
  END to_stdlogic;


   constant TCQ                                    : integer := 1;
   signal reg_filter_pipe                          : std_logic;
   
   signal reg_tsx_counter                          : std_logic_vector(15 downto 0);
   signal tsx_counter                              : std_logic_vector(15 downto 0);
   
   signal cap_link_width                           : std_logic_vector(5 downto 0);

   signal reg_filter_used                          : std_logic;
   signal reg_com_then_pad                         : std_logic;
   signal reg_data0_b4                             : std_logic;
   signal reg_data0_08                             : std_logic;
   signal reg_data0_43                             : std_logic;
   signal reg_data1_b4                             : std_logic;
   signal reg_data1_08                             : std_logic;
   signal reg_data1_43                             : std_logic;
   signal reg_data0_com                            : std_logic;
   signal reg_data1_com                            : std_logic;
   signal reg_data1_pad                            : std_logic;

   signal data0_b4                                 : std_logic;
   signal data0_08                                 : std_logic;
   signal data0_43                                 : std_logic;

   signal data1_b4                                 : std_logic;
   signal data1_08                                 : std_logic;
   signal data1_43                                 : std_logic;

   signal data0_com                                : std_logic;
   signal data0_pad                                : std_logic;

   signal data1_com                                : std_logic;
   signal data1_pad                                : std_logic;

   signal com_then_pad0                            : std_logic;
   signal com_then_pad1                            : std_logic;
   signal com_then_pad                             : std_logic;
   signal filter_used                              : std_logic;
   signal com_then_pad_reg                         : std_logic;
   signal filter_used_reg                          : std_logic;

   -- X-HDL generated signals

   signal v6pcie1                                  : std_logic_vector(15 downto 0);
   signal v6pcie2                                  : std_logic_vector(15 downto 0);
   
   -- Declare intermediate signals for referenced outputs
   signal filter_pipe_v6pcie0                      : std_logic;

begin
   -- Drive referenced outputs
   filter_pipe <= filter_pipe_v6pcie0;
   
   -- Corrupting all Tsx on all lanes as soon as we do R.RC->R.RI transition to allow time for
   -- the core to see the TS1s on all the lanes being configured at the same time
   -- R.RI has a 2ms timeout.Corrupting tsxs for ~1/4 of that time
   -- 225 (00E1 Hex) pipe_clk cycles-sim_fast_train
   -- 60000 (EA60 Hex) pipe_clk cycles-without sim_fast_train
   -- Not taking any action  when PLDIRECTEDLINKCHANGE is set
   
   -- Detect xx, COM then PAD,xx or COM,PAD then PAD,xx
   -- data0 will be the first symbol on lane 0, data1 will be the next symbol.
   --  Don't look for PAD on data1 since it's unnecessary.
   -- COM=0xbc and PAD=0xf7 (and isk).
   -- detect if (data & 0xb4) == 0xb4 and isk, and then
   --  if (data & 0x4b) == 0x08 or 0x43.  This distinguishes COM and PAD, using
   --  no more than a 6-input LUT, so should be "free".

   data0_b4 <= pipe_rx0_char_isk(0) and slv_check(pipe_rx0_data(7 downto 0), X"b4", X"b4");
   data0_08 <= slv_check(pipe_rx0_data(7 downto 0), X"4b", X"08");
   data0_43 <= slv_check(pipe_rx0_data(7 downto 0), X"4b", X"43");

   data1_b4 <= pipe_rx0_char_isk(1) and slv_check(pipe_rx0_data(15 downto 8), X"b4", X"b4");
   data1_08 <= slv_check(pipe_rx0_data(15 downto 8), X"4b", X"08");
   data1_43 <= slv_check(pipe_rx0_data(15 downto 8), X"4b", X"43");

   data0_com <= reg_data0_b4 and reg_data0_08;
   data1_com <= reg_data1_b4 and reg_data1_08;
   data0_pad <= reg_data0_b4 and reg_data0_43;
   data1_pad <= reg_data1_b4 and reg_data1_43;
   com_then_pad0 <= reg_data0_com and reg_data1_pad and data0_pad;
   com_then_pad1 <= reg_data1_com and data0_pad and data1_pad;
   com_then_pad <= (com_then_pad0 or com_then_pad1) and not(reg_filter_used);

   filter_used <= to_stdlogic(pl_ltssm_state = "100000") and (reg_filter_pipe or reg_filter_used);

   com_then_pad_reg <= com_then_pad when ((not(pl_phy_lnkup_n)) = '1') else
                       '0';
   filter_used_reg <= filter_used when ((not(pl_phy_lnkup_n)) = '1') else
                      '0';
   process (pipe_clk)
   begin
      if (pipe_clk'event and pipe_clk = '1') then
         reg_data0_b4 <= data0_b4 after (TCQ)*1 ps;
         reg_data0_08 <= data0_08 after (TCQ)*1 ps;
         reg_data0_43 <= data0_43 after (TCQ)*1 ps;
         reg_data1_b4 <= data1_b4 after (TCQ)*1 ps;
         reg_data1_08 <= data1_08 after (TCQ)*1 ps;
         reg_data1_43 <= data1_43 after (TCQ)*1 ps;
         reg_data0_com <= data0_com after (TCQ)*1 ps;
         reg_data1_com <= data1_com after (TCQ)*1 ps;
         reg_data1_pad <= data1_pad after (TCQ)*1 ps;
         reg_com_then_pad <= com_then_pad_reg after (TCQ)*1 ps;
         
         reg_filter_used <= filter_used_reg after (TCQ)*1 ps;
      end if;
   end process;
   
   v6pcie1 <= X"0320" when (pl_sel_lnk_rate = '1') else
              X"0190";
   v6pcie2 <= X"00E1" when (PL_FAST_TRAIN) else
              v6pcie1;

   process (pipe_clk)
   begin
      if (pipe_clk'event and pipe_clk = '1') then

        if (pl_phy_lnkup_n = '1') then

          reg_tsx_counter <= "0000000000000000" after (TCQ)*1 ps;
          reg_filter_pipe <= '0' after (TCQ)*1 ps;

        elsif ((pl_ltssm_state = "100000") and (reg_com_then_pad = '1') and (("00" & cfg_link_status_negotiated_width) /= cap_link_width(5 downto 0)) and (pl_directed_link_change(1 downto 0) = "00")) then

          reg_tsx_counter <= "0000000000000000" after (TCQ)*1 ps;
          reg_filter_pipe <= '1' after (TCQ)*1 ps;

        elsif (filter_pipe_v6pcie0 = '1') then 

          if (tsx_counter < v6pcie2) then
               
            reg_tsx_counter <= tsx_counter + "0000000000000001" after (TCQ)*1 ps;
            reg_filter_pipe <= '1' after (TCQ)*1 ps;

          else
               
            reg_tsx_counter <= "0000000000000000" after (TCQ)*1 ps;
            reg_filter_pipe <= '0' after (TCQ)*1 ps;

          end if;
        end if;
      end if;
   end process;
   
   
   filter_pipe_v6pcie0 <= '0' when (UPSTREAM_FACING) else
                          reg_filter_pipe;
   tsx_counter <= reg_tsx_counter;
   
   cap_link_width <= to_stdlogicvector(LINK_CAP_MAX_LINK_WIDTH);
   
end v6_pcie;


