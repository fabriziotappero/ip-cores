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
-- File       : pcie_clocking_v6.vhd
-- Version    : 2.3
---- Description: Clocking module for Virtex6 PCIe Block
----
----
----
----------------------------------------------------------------------------------

library ieee;
   use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity pcie_clocking_v6 is
   generic (

      IS_ENDPOINT                                  : boolean := TRUE;
      CAP_LINK_WIDTH                               : integer := 8;		-- 1 - x1 , 2 - x2 , 4 - x4 , 8 - x8
      CAP_LINK_SPEED                               : integer := 1;		-- 1 - Gen1 , 2 - Gen2
      REF_CLK_FREQ                                 : integer := 0;		-- 0 - 100 MHz , 1 - 125 MHz , 2 - 250 MHz
      USER_CLK_FREQ                                : integer := 3		-- 0 - 31.25 MHz , 1 - 62.5 MHz , 2 - 125 MHz , 3 - 250 MHz , 4 - 500Mhz
      
   );
   port (
      sys_clk                                      : in std_logic;
      gt_pll_lock                                  : in std_logic;
      sel_lnk_rate                                 : in std_logic;
      sel_lnk_width                                : in std_logic_vector(1 downto 0);
      sys_clk_bufg                                 : out std_logic;
      pipe_clk                                     : out std_logic;
      user_clk                                     : out std_logic;
      block_clk                                    : out std_logic;
      drp_clk                                      : out std_logic;
      clock_locked                                 : out std_logic
   );
end pcie_clocking_v6;

architecture v6_pcie of pcie_clocking_v6 is

  -- MMCM Configuration
      
  function clkin_prd(
    constant REF_CLK_FREQ     : integer)
    return real is
     variable CLKIN_PERD : real := 0.0;
  begin  -- clkin_prd

    if (REF_CLK_FREQ = 0) then
      CLKIN_PERD := 10.0;
    elsif (REF_CLK_FREQ = 1) then
      CLKIN_PERD := 8.0;
    elsif (REF_CLK_FREQ = 2) then
      CLKIN_PERD := 4.0;
    else
      CLKIN_PERD := 0.0;
    end if;
    return CLKIN_PERD;
  end clkin_prd;

   constant mmcm_clockin_period                    : real := clkin_prd(REF_CLK_FREQ);
      
  function clkfb_mul(
    constant REF_CLK_FREQ     : integer)
    return real is
     variable CLKFB_MULT : real := 0.0;
  begin  -- clkfb_mul

    if (REF_CLK_FREQ = 0) then
      CLKFB_MULT := 10.0;
    elsif (REF_CLK_FREQ = 1) then
      CLKFB_MULT := 8.0;
    elsif (REF_CLK_FREQ = 2) then
      CLKFB_MULT := 8.0;
    else
      CLKFB_MULT := 0.0;
    end if;
    return CLKFB_MULT;
  end clkfb_mul;

   constant mmcm_clockfb_mult                      : real := clkfb_mul(REF_CLK_FREQ);
      
  function divclk_div(
    constant REF_CLK_FREQ     : integer)
    return integer is
     variable DIVCLK_DIVIDE : integer := 0;
  begin  -- divclk_div

    if (REF_CLK_FREQ = 0) then
      DIVCLK_DIVIDE := 1;
    elsif (REF_CLK_FREQ = 1) then
      DIVCLK_DIVIDE := 1;
    elsif (REF_CLK_FREQ = 2) then
      DIVCLK_DIVIDE := 2;
    else
      DIVCLK_DIVIDE := 0;
    end if;
    return DIVCLK_DIVIDE;
  end divclk_div;

   constant mmcm_divclk_divide                     : integer := divclk_div(REF_CLK_FREQ);

   constant mmcm_clock0_div                        : real := 4.0;
   constant mmcm_clock1_div                        : integer := 8;

   constant TCQ : integer := 1;
  
  function clk2_div(
    constant LNK_WDT          : integer;
    constant LNK_SPD          : integer;
    constant USR_CLK_FREQ     : integer)
    return integer is
     variable CLK_DIV : integer := 1;
  begin  -- clk2_div

    if ((LNK_WDT = 1) and (LNK_SPD = 1) and (USR_CLK_FREQ = 0)) then
      CLK_DIV := 32;
    elsif ((LNK_WDT = 1) and (LNK_SPD = 1) and (USR_CLK_FREQ = 1)) then
      CLK_DIV := 16;
    elsif ((LNK_WDT = 1) and (LNK_SPD = 2) and (USR_CLK_FREQ = 1)) then
      CLK_DIV := 16;
    elsif ((LNK_WDT = 2) and (LNK_SPD = 1) and (USR_CLK_FREQ = 1)) then
      CLK_DIV := 16;
    else
      CLK_DIV := 2;
    end if;
    return CLK_DIV;
  end clk2_div;

   constant mmcm_clock2_div                        : integer := clk2_div(CAP_LINK_WIDTH, CAP_LINK_SPEED, USER_CLK_FREQ);
   constant mmcm_clock3_div                        : integer := 2;

   signal mmcm_locked                              : std_logic;
   signal mmcm_clkfbin                             : std_logic;
   signal mmcm_clkfbout                            : std_logic;
   signal mmcm_reset                               : std_logic;
   signal clk_500                                  : std_logic;
   signal clk_250                                  : std_logic;
   signal clk_125                                  : std_logic;
   signal user_clk_prebuf                          : std_logic;
   signal sel_lnk_rate_d                           : std_logic;
   signal reg_clock_locked                         : std_logic_vector(1 downto 0) := "11";

   -- Declare intermediate signals for referenced outputs
   signal sys_clk_bufg_v6pcie3                         : std_logic;
   signal pipe_clk_v6pcie                              : std_logic;
   signal user_clk_v6pcie4                             : std_logic;
   signal block_clk_v6pcie0                            : std_logic;
   signal drp_clk_v6pcie1                              : std_logic;

  signal clock_locked_int : std_logic;

begin
   -- Drive referenced outputs
   sys_clk_bufg <= sys_clk_bufg_v6pcie3;
   pipe_clk <= pipe_clk_v6pcie;
   user_clk <= user_clk_v6pcie4;
   block_clk <= block_clk_v6pcie0;
   drp_clk <= drp_clk_v6pcie1;
   clock_locked <= clock_locked_int;
   clock_locked_int <= (not(reg_clock_locked(1))) and mmcm_locked;
   

   -- MMCM Reset
     mmcm_reset <= '0';

   -- PIPE Clock BUFG.
   
   GEN1_LINK : if (CAP_LINK_SPEED = 1) generate
      pipe_clk_bufg : BUFG port map (O  => pipe_clk_v6pcie, I  => clk_125 );
      
   end generate;

   GEN2_LINK : if (CAP_LINK_SPEED = 2) generate
      sel_lnk_rate_delay : SRL16E generic map ( INIT  => X"0000" ) 
                                  port map (
                                    Q    => sel_lnk_rate_d,
                                    D    => sel_lnk_rate,
                                    CLK  => pipe_clk_v6pcie,
                                    CE   => clock_locked_int,
                                    A3   => '1',
                                    A2   => '1',
                                    A1   => '1',
                                    A0   => '1'
                                    );

      pipe_clk_bufgmux : BUFGMUX port map (
                                    O   => pipe_clk_v6pcie,
                                    I0  => clk_125,
                                    I1  => clk_250,
                                    S   => sel_lnk_rate_d
                                    );
         
      end generate;
   ILLEGAL_LINK_SPEED : if ((CAP_LINK_SPEED /= 1) and (CAP_LINK_SPEED /= 2)) generate
         
         --$display("Confiuration Error : CAP_LINK_SPEED = %d, must be either 1 or 2.", CAP_LINK_SPEED);
         --$finish;
         
   end generate;

   -- User Clock BUFG.
   x1_GEN1_31_25 : if ((CAP_LINK_WIDTH = 1) and (CAP_LINK_SPEED = 1) and (USER_CLK_FREQ = 0)) generate
      
     user_clk_bufg : BUFG port map ( O => user_clk_v6pcie4, I => user_clk_prebuf );
      
   end generate;

   x1_GEN1_62_50 : if ((CAP_LINK_WIDTH = 1) and (CAP_LINK_SPEED = 1) and (USER_CLK_FREQ = 1)) generate
         
     user_clk_bufg : BUFG port map ( O => user_clk_v6pcie4, I => user_clk_prebuf );
         
   end generate;

   x1_GEN1_125_00 : if ((CAP_LINK_WIDTH = 1) and (CAP_LINK_SPEED = 1) and (USER_CLK_FREQ = 2)) generate
            
     user_clk_bufg : BUFG port map ( O => user_clk_v6pcie4, I => clk_125 );
            
   end generate;

   x1_GEN1_250_00 : if ((CAP_LINK_WIDTH = 1) and (CAP_LINK_SPEED = 1) and (USER_CLK_FREQ = 3)) generate
               
     user_clk_bufg : BUFG port map ( O => user_clk_v6pcie4, I => clk_250 );
               
   end generate;

   x1_GEN2_62_50 : if ((CAP_LINK_WIDTH = 1) and (CAP_LINK_SPEED = 2) and (USER_CLK_FREQ = 1)) generate

     user_clk_bufg : BUFG port map ( O => user_clk_v6pcie4, I  => user_clk_prebuf );
                  
   end generate;

   x1_GEN2_125_00 : if ((CAP_LINK_WIDTH = 1) and (CAP_LINK_SPEED = 2) and (USER_CLK_FREQ = 2)) generate

     user_clk_bufg : BUFG port map ( O => user_clk_v6pcie4, I  => clk_125 );
                     
   end generate;

   x1_GEN2_250_00 : if ((CAP_LINK_WIDTH = 1) and (CAP_LINK_SPEED = 2) and (USER_CLK_FREQ = 3)) generate

     user_clk_bufg : BUFG port map ( O => user_clk_v6pcie4, I => clk_250 );
                        
   end generate;

   x2_GEN1_62_50 : if ((CAP_LINK_WIDTH = 2) and (CAP_LINK_SPEED = 1) and (USER_CLK_FREQ = 1)) generate

     user_clk_bufg : BUFG port map ( O => user_clk_v6pcie4, I => user_clk_prebuf );

   end generate;

   x2_GEN1_125_00 : if ((CAP_LINK_WIDTH = 2) and (CAP_LINK_SPEED = 1) and (USER_CLK_FREQ = 2)) generate

     user_clk_bufg : BUFG port map ( O => user_clk_v6pcie4, I => clk_125 );

   end generate;

   x2_GEN1_250_00 : if ((CAP_LINK_WIDTH = 2) and (CAP_LINK_SPEED = 1) and (USER_CLK_FREQ = 3)) generate

     user_clk_bufg : BUFG port map ( O => user_clk_v6pcie4, I => clk_250 );

   end generate;

   x2_GEN2_125_00 : if ((CAP_LINK_WIDTH = 2) and (CAP_LINK_SPEED = 2) and (USER_CLK_FREQ = 2)) generate

     user_clk_bufg : BUFG port map ( O => user_clk_v6pcie4, I => clk_125 );

   end generate;

   x2_GEN2_250_00 : if ((CAP_LINK_WIDTH = 2) and (CAP_LINK_SPEED = 2) and (USER_CLK_FREQ = 3)) generate

     user_clk_bufg : BUFG port map ( O => user_clk_v6pcie4, I => clk_250 );

   end generate;

   x4_GEN1_125_00 : if ((CAP_LINK_WIDTH = 4) and (CAP_LINK_SPEED = 1) and (USER_CLK_FREQ = 2)) generate

     user_clk_bufg : BUFG port map ( O => user_clk_v6pcie4, I => clk_125 );

   end generate;

   x4_GEN1_250_00 : if ((CAP_LINK_WIDTH = 4) and (CAP_LINK_SPEED = 1) and (USER_CLK_FREQ = 3)) generate

     user_clk_bufg : BUFG port map ( O => user_clk_v6pcie4, I => clk_250 );

   end generate;

   x4_GEN2_250_00 : if ((CAP_LINK_WIDTH = 4) and (CAP_LINK_SPEED = 2) and (USER_CLK_FREQ = 3)) generate

     user_clk_bufg : BUFG port map ( O => user_clk_v6pcie4, I => clk_250 );

   end generate;

   x8_GEN1_250_00 : if ((CAP_LINK_WIDTH = 8) and (CAP_LINK_SPEED = 1) and (USER_CLK_FREQ = 3)) generate

     user_clk_bufg : BUFG port map ( O => user_clk_v6pcie4, I => clk_250 );

   end generate;

   x8_GEN2_250_00 : if ((CAP_LINK_WIDTH = 8) and (CAP_LINK_SPEED = 2) and (USER_CLK_FREQ = 4)) generate

     user_clk_bufg : BUFG port map ( O => user_clk_v6pcie4, I => clk_250 );

     block_clk_bufg : BUFG port map ( O => block_clk_v6pcie0, I => clk_500 );

   end generate;

--   v6pcie42 : if (not((CAP_LINK_WIDTH = 8) and (CAP_LINK_SPEED = 2) and (USER_CLK_FREQ = 4))) generate

    --$display("Confiuration Error : Unsupported Link Width, Link Speed and User Clock Frequency Combination");
    --$finish;

--   end generate;
   
   -- DRP clk
   drp_clk_bufg_i : BUFG port map ( O => drp_clk_v6pcie1, I => clk_125 );
   
   -- Feedback BUFG. Required for Temp Compensation
   clkfbin_bufg_i : BUFG port map ( O => mmcm_clkfbin, I => mmcm_clkfbout );
   
   -- sys_clk BUFG. 
   sys_clk_bufg_i : BUFG port map ( O => sys_clk_bufg_v6pcie3, I => sys_clk );
   
   mmcm_adv_i : MMCM_ADV
      generic map (
         -- 5 for 100 MHz , 4 for 125 MHz , 2 for 250 MHz
         CLKFBOUT_MULT_F   => mmcm_clockfb_mult,
         DIVCLK_DIVIDE     => mmcm_divclk_divide,
         CLKFBOUT_PHASE    => 0.0,
         -- 10 for 100 MHz, 4 for 250 MHz
         CLKIN1_PERIOD     => mmcm_clockin_period,
         CLKIN2_PERIOD     => mmcm_clockin_period,
         -- 500 MHz / mmcm_clockx_div  
         CLKOUT0_DIVIDE_F  => mmcm_clock0_div,
         CLKOUT0_PHASE     => 0.0,
         CLKOUT1_DIVIDE    => mmcm_clock1_div,
         CLKOUT1_PHASE     => 0.0,
         CLKOUT2_DIVIDE    => mmcm_clock2_div,
         CLKOUT2_PHASE     => 0.0,
         CLKOUT3_DIVIDE    => mmcm_clock3_div,
         CLKOUT3_PHASE     => 0.0
      )
      port map (
         clkfbout      => mmcm_clkfbout,
         clkout0       => clk_250,              -- 250 MHz for pipe_clk
         clkout1       => clk_125,              -- 125 MHz for pipe_clk
         clkout2       => user_clk_prebuf,      -- user clk
         clkout3       => clk_500,
         clkout4       => open,
         clkout5       => open,
         clkout6       => open,
         do            => open,
         drdy          => open,
         clkfboutb     => open,
         clkfbstopped  => open,
         clkinstopped  => open,
         clkout0b      => open,
         clkout1b      => open,
         clkout2b      => open,
         clkout3b      => open,
         psdone        => open,
         locked        => mmcm_locked,
         clkfbin       => mmcm_clkfbin,
         clkin1        => sys_clk,
         clkin2        => '0',
         clkinsel      => '1',
         daddr         => "0000000",
         dclk          => '0',
         den           => '0',
         di            => "0000000000000000",
         dwe           => '0',
         psen          => '0',
         psincdec      => '0',
         pwrdwn        => '0',
         psclk         => '0',
         rst           => mmcm_reset
      );
   
  -- Synchronize MMCM locked output
  process (pipe_clk_v6pcie, gt_pll_lock)
  begin
    
    if ((not(gt_pll_lock)) = '1') then

      reg_clock_locked <= "11" after (TCQ)*1 ps;

    elsif (pipe_clk_v6pcie'event and pipe_clk_v6pcie = '1') then
      
      reg_clock_locked <= (reg_clock_locked(0) & '0') after (TCQ)*1 ps;

    end if;
  end process;
  
end v6_pcie;



