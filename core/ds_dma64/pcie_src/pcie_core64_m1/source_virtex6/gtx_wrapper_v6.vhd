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
-- File       : gtx_wrapper_v6.vhd
-- Version    : 2.3
-- Description: GTX module for Virtex6 PCIe Block
--
--
--
--------------------------------------------------------------------------------

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

entity gtx_wrapper_v6 is
   generic (
      NO_OF_LANES                        : integer := 1;
      REF_CLK_FREQ                       : integer := 0;
      PL_FAST_TRAIN                      : boolean := FALSE
   );
   port (

      -- TX
      TX                                 : out std_logic_vector(NO_OF_LANES - 1 downto 0);
      TXN                                : out std_logic_vector(NO_OF_LANES - 1 downto 0);
      TxData                             : in std_logic_vector((NO_OF_LANES * 16) - 1 downto 0);
      TxDataK                            : in std_logic_vector((NO_OF_LANES * 2) - 1 downto 0);
      TxElecIdle                         : in std_logic_vector(NO_OF_LANES - 1 downto 0);
      TxCompliance                       : in std_logic_vector(NO_OF_LANES - 1 downto 0);

      -- RX
      RX                                 : in std_logic_vector(NO_OF_LANES - 1 downto 0);
      RXN                                : in std_logic_vector(NO_OF_LANES - 1 downto 0);
      RxData                             : out std_logic_vector((NO_OF_LANES * 16) - 1 downto 0);
      RxDataK                            : out std_logic_vector((NO_OF_LANES * 2) - 1 downto 0);
      RxPolarity                         : in std_logic_vector(NO_OF_LANES - 1 downto 0);
      RxValid                            : out std_logic_vector(NO_OF_LANES - 1 downto 0);
      RxElecIdle                         : out std_logic_vector(NO_OF_LANES - 1 downto 0);
      RxStatus                           : out std_logic_vector((NO_OF_LANES * 3) - 1 downto 0);

      -- other
      GTRefClkout                        : out std_logic_vector(NO_OF_LANES - 1 downto 0);
      plm_in_l0                          : in std_logic;
      plm_in_rl                          : in std_logic;
      plm_in_dt                          : in std_logic;
      plm_in_rs                          : in std_logic;
      RxPLLLkDet                         : out std_logic_vector(NO_OF_LANES - 1 downto 0);
      TxDetectRx                         : in std_logic;
      PhyStatus                          : out std_logic_vector(NO_OF_LANES - 1 downto 0);
      TXPdownAsynch                      : in std_logic;

      PowerDown                          : in std_logic_vector((NO_OF_LANES * 2) - 1 downto 0);
      Rate                               : in std_logic;
      Reset_n                            : in std_logic;
      GTReset_n                          : in std_logic;
      PCLK                               : in std_logic;
      REFCLK                             : in std_logic;
      TxDeemph                           : in std_logic;
      TxMargin                           : in std_logic;
      TxSwing                            : in std_logic;
      ChanIsAligned                      : out std_logic_vector(NO_OF_LANES - 1 downto 0);
      local_pcs_reset                    : in std_logic;
      RxResetDone                        : out std_logic;
      SyncDone                           : out std_logic;
      DRPCLK                             : in std_logic;
      TxOutClk                           : out std_logic
   );
end gtx_wrapper_v6;

architecture v6_pcie of gtx_wrapper_v6 is
   component GTX_RX_VALID_FILTER_V6 is
      generic (
         CLK_COR_MIN_LAT                 : integer
      );
      port (
         USER_RXCHARISK                  : out std_logic_vector(1 downto 0);
         USER_RXDATA                     : out std_logic_vector(15 downto 0);
         USER_RXVALID                    : out std_logic;
         USER_RXELECIDLE                 : out std_logic;
         USER_RX_STATUS                  : out std_logic_vector(2 downto 0);
         USER_RX_PHY_STATUS              : out std_logic;
         GT_RXCHARISK                    : in std_logic_vector(1 downto 0);
         GT_RXDATA                       : in std_logic_vector(15 downto 0);
         GT_RXVALID                      : in std_logic;
         GT_RXELECIDLE                   : in std_logic;
         GT_RX_STATUS                    : in std_logic_vector(2 downto 0);
         GT_RX_PHY_STATUS                : in std_logic;
         PLM_IN_L0                       : in std_logic;
         PLM_IN_RS                       : in std_logic;
         USER_CLK                        : in std_logic;
         RESET                           : in std_logic
      );
   end component;

   component GTX_DRP_CHANALIGN_FIX_3752_V6 is
      generic (
         C_SIMULATION                    : integer
      );
      port (
         dwe                             : out std_logic;
         din                             : out std_logic_vector(15 downto 0);
         den                             : out std_logic;
         daddr                           : out std_logic_vector(7 downto 0);
         drpstate                        : out std_logic_vector(3 downto 0);
         write_ts1                       : in std_logic;
         write_fts                       : in std_logic;
         dout                            : in std_logic_vector(15 downto 0);
         drdy                            : in std_logic;
         Reset_n                         : in std_logic;
         drp_clk                         : in std_logic
      );
   end component;

   component GTX_TX_SYNC_RATE_V6 is
      generic (
         C_SIMULATION                    : integer
      );
      port (
         ENPMAPHASEALIGN                 : out std_logic;
         PMASETPHASE                     : out std_logic;
         SYNC_DONE                       : out std_logic;
         OUT_DIV_RESET                   : out std_logic;
         PCS_RESET                       : out std_logic;
         USER_PHYSTATUS                  : out std_logic;
         TXALIGNDISABLE                  : out std_logic;
         DELAYALIGNRESET                 : out std_logic;
         USER_CLK                        : in std_logic;
         RESET                           : in std_logic;
         RATE                            : in std_logic;
         RATEDONE                        : in std_logic;
         GT_PHYSTATUS                    : in std_logic;
         RESETDONE                       : in std_logic
      );
   end component;

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

   FUNCTION and_bw (
      val_in : std_logic_vector) RETURN std_logic IS

      VARIABLE ret : std_logic := '1';
   BEGIN
      FOR index IN val_in'RANGE LOOP
         ret := ret AND val_in(index);
      END LOOP;
      RETURN(ret);
   END and_bw;

   FUNCTION to_integer (
      in_val      : IN boolean) RETURN integer IS
   BEGIN
      IF (in_val) THEN
         RETURN(1);
      ELSE
         RETURN(0);
      END IF;
   END to_integer;

   FUNCTION to_stdlogic (
      in_val      : IN boolean) RETURN std_logic IS
   BEGIN
      IF (in_val) THEN
         RETURN('1');
      ELSE
         RETURN('0');
      END IF;
   END to_stdlogic;

   -- purpose: PLL_CP_CFG selector function
   function pll_cp_cfg_sel (
     ref_freq : integer)
     return bit_vector is
   begin  -- pll_cp_cfg_sel
     if (ref_freq = 2) then
       return (X"05");
     else
       return (X"05");
     end if;
   end pll_cp_cfg_sel;

   FUNCTION clk_div (
      in_val      : IN integer) RETURN integer IS
   BEGIN
      if (in_val = 0) THEN
         return (4);
      elsif (in_val = 1) then
        return (5);
      else
        return (10);
      end if;
   END clk_div;

   FUNCTION pll_div (
      in_val      : IN integer) RETURN integer IS
   BEGIN
      if (in_val = 0) THEN
         return (5);
      elsif (in_val = 1) then
        return (4);
      elsif (in_val = 2) then
        return (2);
      else
        return (0);
      end if;
   END pll_div;


    -- ground and tied_to_vcc_i signals
    signal  tied_to_ground_i                :   std_logic;
    signal  tied_to_ground_vec_i            :   std_logic_vector(31 downto 0);
    signal  tied_to_vcc_i                   :   std_logic;

   type type_v6pcie10 is array (NO_OF_LANES + 1 downto 0) of std_logic_vector(3 downto 0);
   type type_v6pcie11 is array (NO_OF_LANES - 1 downto 0) of std_logic;
   type type_v6pcie16 is array (NO_OF_LANES - 1 downto 0) of std_logic_vector(12 downto 0);


   -- dummy signals to avoid port mismatch with DUAL_GTX
   signal RxData_dummy                            : std_logic_vector(15 downto 0);
   signal RxDataK_dummy                           : std_logic_vector(1 downto 0);
   signal TxData_dummy                            : std_logic_vector(15 downto 0);
   signal TxDataK_dummy                           : std_logic_vector(1 downto 0);

   -- inputs
   signal GTX_TxData                              : std_logic_vector((NO_OF_LANES * 16) - 1 downto 0);
   signal GTX_TxDataK                             : std_logic_vector((NO_OF_LANES * 2) - 1 downto 0);
   signal GTX_TxElecIdle                          : std_logic_vector((NO_OF_LANES) - 1 downto 0);
   signal GTX_TxCompliance                        : std_logic_vector((NO_OF_LANES - 1) downto 0);
   signal GTX_RXP                                 : std_logic_vector((NO_OF_LANES) - 1 downto 0);
   signal GTX_RXN                                 : std_logic_vector((NO_OF_LANES) - 1 downto 0);

   -- outputs
   signal GTX_TXP                                 : std_logic_vector((NO_OF_LANES) - 1 downto 0);
   signal GTX_TXN                                 : std_logic_vector((NO_OF_LANES) - 1 downto 0);
   signal GTX_RxData                              : std_logic_vector((NO_OF_LANES * 16) - 1 downto 0);
   signal GTX_RxDataK                             : std_logic_vector((NO_OF_LANES * 2) - 1 downto 0);
   signal GTX_RxPolarity                          : std_logic_vector((NO_OF_LANES) - 1 downto 0);
   signal GTX_RxValid                             : std_logic_vector((NO_OF_LANES) - 1 downto 0);
   signal GTX_RxElecIdle                          : std_logic_vector((NO_OF_LANES) - 1 downto 0);
   signal GTX_RxResetDone                         : std_logic_vector((NO_OF_LANES - 1) downto 0);
   signal GTX_RxChbondLevel                       : std_logic_vector((NO_OF_LANES * 3) - 1 downto 0);
   signal GTX_RxStatus                            : std_logic_vector((NO_OF_LANES * 3) - 1 downto 0);

   signal RXCHBOND                                : type_v6pcie10;
   signal TXBYPASS8B10B                           : std_logic_vector(3 downto 0);
   signal RXDEC8B10BUSE                           : std_logic;
   signal GTX_PhyStatus                           : std_logic_vector(NO_OF_LANES - 1 downto 0);
   signal RESETDONE                               : type_v6pcie11;
   signal GTXRESET                                : std_logic;
   signal RXRECCLK                                : std_logic;

   signal SYNC_DONE                               : std_logic_vector(NO_OF_LANES - 1 downto 0);
   signal OUT_DIV_RESET                           : std_logic_vector(NO_OF_LANES - 1 downto 0);
   signal PCS_RESET                               : std_logic_vector(NO_OF_LANES - 1 downto 0);
   signal TXENPMAPHASEALIGN                       : std_logic_vector(NO_OF_LANES - 1 downto 0);
   signal TXPMASETPHASE                           : std_logic_vector(NO_OF_LANES - 1 downto 0);
   signal TXRESETDONE                             : std_logic_vector(NO_OF_LANES - 1 downto 0);
   signal TXRATEDONE                              : std_logic_vector(NO_OF_LANES - 1 downto 0);
   signal PHYSTATUS_int                           : std_logic_vector(NO_OF_LANES - 1 downto 0);
   signal RATE_CLK_SEL                            : std_logic_vector(NO_OF_LANES - 1 downto 0);
   signal TXOCLK                                  : std_logic_vector(NO_OF_LANES - 1 downto 0);
   signal TXDLYALIGNDISABLE                       : std_logic_vector(NO_OF_LANES - 1 downto 0);
   signal TXDLYALIGNRESET                         : std_logic_vector(NO_OF_LANES - 1 downto 0);

   signal GTX_RxResetDone_q                       : std_logic_vector((NO_OF_LANES - 1) downto 0);
   signal TXRESETDONE_q                           : std_logic_vector((NO_OF_LANES - 1) downto 0);

   signal daddr                                   : std_logic_vector((NO_OF_LANES * 8 - 1) downto 0);
   signal den                                     : std_logic_vector(NO_OF_LANES - 1 downto 0);
   signal din                                     : std_logic_vector((NO_OF_LANES * 16 - 1) downto 0);
   signal dwe                                     : std_logic_vector(NO_OF_LANES - 1 downto 0);

   signal drpstate                                : std_logic_vector((NO_OF_LANES * 4 - 1) downto 0);
   signal drdy                                    : std_logic_vector(NO_OF_LANES - 1 downto 0);
   signal dout                                    : std_logic_vector((NO_OF_LANES * 16 - 1) downto 0);

   signal write_drp_cb_fts                        : std_logic;
   signal write_drp_cb_ts1                        : std_logic;

   -- X-HDL generated signals

   signal v6pcie12 : std_logic;
   signal v6pcie13 : std_logic;
   signal v6pcie14 : std_logic_vector(NO_OF_LANES - 1 downto 0);
   signal v6pcie15 : std_logic;
   signal v6pcie16 : type_v6pcie16;
   signal v6pcie18 : std_logic_vector(1 downto 0);
   signal v6pcie21 : std_logic_vector((NO_OF_LANES*4) - 1 downto 0);
   signal v6pcie23 : std_logic_vector((NO_OF_LANES*32) - 1 downto 0);
   signal v6pcie24 : std_logic_vector(1 downto 0);
   signal v6pcie25 : std_logic_vector(NO_OF_LANES - 1 downto 0);
   signal v6pcie26 : std_logic_vector(19 downto 0);
   signal v6pcie27 : std_logic_vector((NO_OF_LANES * 4) - 1 downto 0);
   signal v6pcie28 : std_logic_vector((NO_OF_LANES * 4) - 1 downto 0);
   signal v6pcie29 : std_logic_vector((NO_OF_LANES * 32) - 1 downto 0) := (others => '0');
   signal v6pcie30 : std_logic_vector(2 downto 0);

   -- Declare intermediate signals for referenced outputs
   signal RxData_v6pcie3                          : std_logic_vector((NO_OF_LANES * 16) - 1 downto 0);
   signal RxDataK_v6pcie4                         : std_logic_vector((NO_OF_LANES * 2) - 1 downto 0);
   signal RxValid_v6pcie8                         : std_logic_vector(NO_OF_LANES - 1 downto 0);
   signal RxElecIdle_v6pcie5                      : std_logic_vector(NO_OF_LANES - 1 downto 0);
   signal RxStatus_v6pcie7                        : std_logic_vector((NO_OF_LANES * 3) - 1 downto 0);
   signal RxPLLLkDet_v6pcie6                      : std_logic_vector(NO_OF_LANES - 1 downto 0);
   signal PhyStatus_v6pcie1                       : std_logic_vector(NO_OF_LANES - 1 downto 0);
   signal ChanIsAligned_v6pcie0                   : std_logic_vector(NO_OF_LANES - 1 downto 0);
begin

    ---------------------------  Static signal Assignments ---------------------

    tied_to_ground_i                    <= '0';
    tied_to_ground_vec_i(31 downto 0)   <= (others => '0');
    tied_to_vcc_i                       <= '1';

  -- Drive referenced outputs
   RxData <= RxData_v6pcie3;
   RxDataK <= RxDataK_v6pcie4;
   RxValid <= RxValid_v6pcie8;
   RxElecIdle <= RxElecIdle_v6pcie5;
   RxStatus <= RxStatus_v6pcie7;
   RxPLLLkDet <= RxPLLLkDet_v6pcie6;
   PhyStatus <= PhyStatus_v6pcie1;
   ChanIsAligned <= ChanIsAligned_v6pcie0;
   GTX_TxData <= TxData;
   GTX_TxDataK <= TxDataK;
   GTX_TxElecIdle <= TxElecIdle;
   GTX_TxCompliance <= TxCompliance;
   GTX_RXP <= RX((NO_OF_LANES) - 1 downto 0);
   GTX_RXN <= RXN((NO_OF_LANES) - 1 downto 0);
   GTX_RxPolarity <= RxPolarity;
   TXBYPASS8B10B <= "0000";
   RXDEC8B10BUSE <= '1';
   GTXRESET <= '0';

   RxResetDone <= and_bw((GTX_RxResetDone_q((NO_OF_LANES) - 1 downto 0)));
   TX((NO_OF_LANES - 1) downto 0) <= GTX_TXP((NO_OF_LANES - 1) downto 0);
   TXN((NO_OF_LANES - 1) downto 0) <= GTX_TXN((NO_OF_LANES - 1) downto 0);
   RXCHBOND(0) <= "0000";
   TxData_dummy <= "0000000000000000";
   TxDataK_dummy <= "00";
   SyncDone <= and_bw((SYNC_DONE((NO_OF_LANES - 1) downto 0)));
   TxOutClk <= TXOCLK(0);

   write_drp_cb_fts <= plm_in_l0;
   write_drp_cb_ts1 <= plm_in_rl or plm_in_dt;


   -- pipeline to improve timing
   process (PCLK)
   begin
      if (PCLK'event and PCLK = '1') then

         GTX_RxResetDone_q((NO_OF_LANES - 1) downto 0) <= GTX_RxResetDone((NO_OF_LANES - 1) downto 0);

         TXRESETDONE_q((NO_OF_LANES - 1) downto 0) <= TXRESETDONE((NO_OF_LANES - 1) downto 0);
      end if;
   end process;

   GTXD : for i in 0 to (NO_OF_LANES - 1) generate
      GTX_RxChbondLevel((3 * i) + 2 downto (3 * i)) <= (to_stdlogicvector((NO_OF_LANES - (i + 1)), 3));

      GTX_DRP_CHANALIGN_FIX_3752 : GTX_DRP_CHANALIGN_FIX_3752_V6
         generic map (
            C_SIMULATION  => to_integer(PL_FAST_TRAIN)
         )
         port map (

            dwe        => dwe(i),
            din        => din((16 * i) + 15 downto (16 * i)),
            den        => den(i),
            daddr      => daddr((8 * i) + 7 downto (8 * i)),
            drpstate   => drpstate((4 * i) + 3 downto (4 * i)),
            write_ts1  => write_drp_cb_ts1,
            write_fts  => write_drp_cb_fts,
            dout       => dout((16 * i) + 15 downto (16 * i)),
            drdy       => drdy(i),
            Reset_n    => Reset_n,
            drp_clk    => DRPCLK
         );

      v6pcie12 <= not(Reset_n);  --I

      GTX_RX_VALID_FILTER : GTX_RX_VALID_FILTER_V6
         generic map (
            CLK_COR_MIN_LAT  => 28
         )
         port map (
            USER_RXCHARISK      => RxDataK_v6pcie4((2 * i) + 1 downto 2 * i),           --O
            USER_RXDATA         => RxData_v6pcie3((16 * i) + 15 downto (16 * i) + 0),   --O
            USER_RXVALID        => RxValid_v6pcie8(i),                                  --O
            USER_RXELECIDLE     => RxElecIdle_v6pcie5(i),                               --O
            USER_RX_STATUS      => RxStatus_v6pcie7((3 * i) + 2 downto (3 * i)),        --O
            USER_RX_PHY_STATUS  => PhyStatus_v6pcie1(i),                                --O
            GT_RXCHARISK        => GTX_RxDataK((2 * i) + 1 downto 2 * i),               --I
            GT_RXDATA           => GTX_RxData((16 * i) + 15 downto (16 * i) + 0),       --I
            GT_RXVALID          => GTX_RxValid(i),                                      --I
            GT_RXELECIDLE       => GTX_RxElecIdle(i),                                   --I
            GT_RX_STATUS        => GTX_RxStatus((3 * i) + 2 downto (3 * i)),            --I
            GT_RX_PHY_STATUS    => PHYSTATUS_int(i),                                    --I
            PLM_IN_L0           => plm_in_l0,                                           --I
            PLM_IN_RS           => plm_in_rs,                                           --I
            USER_CLK            => PCLK,                                                --I
            RESET               => v6pcie12                                             --I
         );

      v6pcie14(i) <= (TXRESETDONE_q(i) and GTX_RxResetDone_q(i));  --I

      GTX_TX_SYNC : GTX_TX_SYNC_RATE_V6
         generic map (
            C_SIMULATION  => to_integer(PL_FAST_TRAIN)
         )
         port map (
            ENPMAPHASEALIGN  => TXENPMAPHASEALIGN(i),                           --O
            PMASETPHASE      => TXPMASETPHASE(i),                               --O
            SYNC_DONE        => SYNC_DONE(i),                                   --O
            OUT_DIV_RESET    => OUT_DIV_RESET(i),                               --O
            PCS_RESET        => PCS_RESET(i),                                   --O
            USER_PHYSTATUS   => PHYSTATUS_int(i),                               --O
            TXALIGNDISABLE   => TXDLYALIGNDISABLE(i),                           --O
            DELAYALIGNRESET  => TXDLYALIGNRESET(i),                             --O
            USER_CLK         => PCLK,                                           --I
            RESET            => v6pcie12,                                       --I
            RATE             => Rate,                                           --I
            RATEDONE         => TXRATEDONE(i),                                  --I
            GT_PHYSTATUS     => GTX_PhyStatus(i),                               --I
            RESETDONE        => v6pcie14(i)                                     --I
         );

      v6pcie15 <= not(GTReset_n);
      v6pcie16(i) <= ("10000000000" & OUT_DIV_RESET(i) & '0');
      v6pcie18 <= ('0' & REFCLK);
      GTX_RxDataK((2 * i) + 1 downto 2 * i) <= v6pcie21((4*i)+1 downto (4*i));
      GTX_RxData((16 * i) + 15 downto (16 * i) + 0) <= v6pcie23((32*i)+15 downto (32*i));
      v6pcie24 <= ('1' & Rate);
      v6pcie25(i) <= not(GTReset_n) or local_pcs_reset or PCS_RESET(i);
      v6pcie26 <= (others => '1');
      v6pcie27((4 * i) + 3 downto (4 * i) + 0) <= ("000" & GTX_TxCompliance(i));
      v6pcie28((4 * i) + 3 downto (4 * i) + 0) <= (TxDataK_dummy(1 downto 0) & GTX_TxDataK((2 * i) + 1 downto 2 * i));
      v6pcie29((32 * i) + 31 downto (32 * i) + 0) <= (TxData_dummy(15 downto 0) & GTX_TxData((16 * i) + 15 downto (16 * i) + 0));

      v6pcie30 <= (TxMargin & "00");

      GTX : GTXE1
         generic map (
            TX_DRIVE_MODE             => "PIPE",
            TX_DEEMPH_1               => "10010",
            TX_MARGIN_FULL_0          => "1001101",
            TX_CLK_SOURCE             => "RXPLL",
            POWER_SAVE                => "0000110100",
            CM_TRIM                   => "01",
            PMA_CDR_SCAN              => x"640404C",
            PMA_CFG                   => x"0040000040000000003",
            RCV_TERM_GND              => TRUE,
            RCV_TERM_VTTRX            => FALSE,
            RX_DLYALIGN_EDGESET       => "00010",
            RX_DLYALIGN_LPFINC        => "0110",
            RX_DLYALIGN_OVRDSETTING   => "10000000",
            TERMINATION_CTRL          => "00000",
            TERMINATION_OVRD          => FALSE,
            TX_DLYALIGN_LPFINC        => "0110",
            TX_DLYALIGN_OVRDSETTING   => "10000000",
            TXPLL_CP_CFG              => pll_cp_cfg_sel(REF_CLK_FREQ),
            OOBDETECT_THRESHOLD       => "011",
            RXPLL_CP_CFG              => pll_cp_cfg_sel(REF_CLK_FREQ),
      -------------------------------------------------------------------------
      --       TX_DETECT_RX_CFG         => x"1832",
      -------------------------------------------------------------------------
            TX_TDCC_CFG               => "11",
            BIAS_CFG                  => x"00000",
            AC_CAP_DIS                => FALSE,
            DFE_CFG                   => "00011011",
            SIM_TX_ELEC_IDLE_LEVEL    => "1",
            SIM_RECEIVER_DETECT_PASS  => TRUE,
            RX_EN_REALIGN_RESET_BUF   => FALSE,
            TX_IDLE_ASSERT_DELAY      => "100",                 -- TX-idle-set-to-idle (13 UI)
            TX_IDLE_DEASSERT_DELAY    => "010",                 -- TX-idle-to-diff (7 UI)
            CHAN_BOND_SEQ_2_CFG       => "11111",               -- 5'b11111 for PCIE mode, 5'b00000 for other modes
            CHAN_BOND_KEEP_ALIGN      => TRUE,
            RX_IDLE_HI_CNT            => "1000",
            RX_IDLE_LO_CNT            => "0000",
            RX_EN_IDLE_RESET_BUF      => TRUE,
            TX_DATA_WIDTH             => 20,
            RX_DATA_WIDTH             => 20,
            ALIGN_COMMA_WORD          => 1,
            CHAN_BOND_1_MAX_SKEW      => 7,
            CHAN_BOND_2_MAX_SKEW      => 1,
            CHAN_BOND_SEQ_1_1         => "0001000101",          -- D5.2 (end TS2)
            CHAN_BOND_SEQ_1_2         => "0001000101",          -- D5.2 (end TS2)
            CHAN_BOND_SEQ_1_3         => "0001000101",          -- D5.2 (end TS2)
            CHAN_BOND_SEQ_1_4         => "0110111100",          -- K28.5 (COM)
            CHAN_BOND_SEQ_1_ENABLE    => "1111",                -- order is 4321
            CHAN_BOND_SEQ_2_1         => "0100111100",          -- K28.1 (FTS)
            CHAN_BOND_SEQ_2_2         => "0100111100",          -- K28.1 (FTS)
            CHAN_BOND_SEQ_2_3         => "0110111100",          -- K28.5 (COM)
            CHAN_BOND_SEQ_2_4         => "0100111100",          -- K28.1 (FTS)
            CHAN_BOND_SEQ_2_ENABLE    => "1111",                -- order is 4321
            CHAN_BOND_SEQ_2_USE       => TRUE,
            CHAN_BOND_SEQ_LEN         => 4,                     -- 1..4
            RX_CLK25_DIVIDER          => clk_div(REF_CLK_FREQ),
            TX_CLK25_DIVIDER          => clk_div(REF_CLK_FREQ),
            CLK_COR_ADJ_LEN           => 1,                     -- 1..4
            CLK_COR_DET_LEN           => 1,                     -- 1..4
            CLK_COR_INSERT_IDLE_FLAG  => FALSE,
            CLK_COR_KEEP_IDLE         => FALSE,
            CLK_COR_MAX_LAT           => 30,
            CLK_COR_MIN_LAT           => 28,
            CLK_COR_PRECEDENCE        => TRUE,
            CLK_CORRECT_USE           => TRUE,
            CLK_COR_REPEAT_WAIT       => 0,
            CLK_COR_SEQ_1_1           => "0100011100",          -- K28.0 (SKP)
            CLK_COR_SEQ_1_2           => "0000000000",
            CLK_COR_SEQ_1_3           => "0000000000",
            CLK_COR_SEQ_1_4           => "0000000000",
            CLK_COR_SEQ_1_ENABLE      => "1111",
            CLK_COR_SEQ_2_1           => "0000000000",
            CLK_COR_SEQ_2_2           => "0000000000",
            CLK_COR_SEQ_2_3           => "0000000000",
            CLK_COR_SEQ_2_4           => "0000000000",
            CLK_COR_SEQ_2_ENABLE      => "1111",
            CLK_COR_SEQ_2_USE         => FALSE,
            COMMA_10B_ENABLE          => "1111111111",
            COMMA_DOUBLE              => FALSE,
            DEC_MCOMMA_DETECT         => TRUE,
            DEC_PCOMMA_DETECT         => TRUE,
            DEC_VALID_COMMA_ONLY      => TRUE,
            MCOMMA_10B_VALUE          => "1010000011",
            MCOMMA_DETECT             => TRUE,
            PCI_EXPRESS_MODE          => TRUE,
            PCOMMA_10B_VALUE          => "0101111100",
            PCOMMA_DETECT             => TRUE,
            RXPLL_DIVSEL_FB           => pll_div(REF_CLK_FREQ),     -- 1..5, 8, 10
            TXPLL_DIVSEL_FB           => pll_div(REF_CLK_FREQ),     -- 1..5, 8, 10
            RXPLL_DIVSEL_REF          => 1,                     -- 1..6, 8, 10, 12, 16, 20
            TXPLL_DIVSEL_REF          => 1,                     -- 1..6, 8, 10, 12, 16, 20
            RXPLL_DIVSEL_OUT          => 2,                     -- 1, 2, 4
            TXPLL_DIVSEL_OUT          => 2,                     -- 1, 2, 4
            RXPLL_DIVSEL45_FB         => 5,
            TXPLL_DIVSEL45_FB         => 5,
            RX_BUFFER_USE             => TRUE,
            RX_DECODE_SEQ_MATCH       => TRUE,
            RX_LOS_INVALID_INCR       => 8,                     -- power of 2:  1..128
            RX_LOSS_OF_SYNC_FSM       => FALSE,
            RX_LOS_THRESHOLD          => 128,                   -- power of 2:  4..512
            RX_SLIDE_MODE             => "OFF",                 -- 00=OFF 01=AUTO 10=PCS 11=PMA
            RX_XCLK_SEL               => "RXREC",
            TX_BUFFER_USE             => FALSE,                 -- Must be set to FALSE for use by PCIE
            TX_XCLK_SEL               => "TXUSR",               -- Must be set to TXUSR for use by PCIE
            TXPLL_LKDET_CFG           => "101",
            RX_EYE_SCANMODE           => "00",
            RX_EYE_OFFSET             => x"4C",
            PMA_RX_CFG                => x"05ce008",
            TRANS_TIME_NON_P2         => x"02",                 -- Reduced simulation time
            TRANS_TIME_FROM_P2        => x"03c",                -- Reduced simulation time
            TRANS_TIME_TO_P2          => x"064",                -- Reduced simulation time
            TRANS_TIME_RATE           => x"D7",                 -- Reduced simulation time
            SHOW_REALIGN_COMMA        => FALSE,
            TX_PMADATA_OPT            => '1',                   -- Lockup latch between PCS and PMA
            PMA_TX_CFG                => x"80082",              -- Aligns posedge of USRCLK
            TXOUTCLK_CTRL             => "TXPLLREFCLK_DIV1"
         )
         port map (
            COMFINISH             => open,
            COMINITDET            => open,
            COMSASDET             => open,
            COMWAKEDET            => open,
            DADDR                 => daddr((8 * i) + 7 downto (8 * i)),
            DCLK                  => DRPCLK,
            DEN                   => den(i),
            DFECLKDLYADJ          => "000000",          -- Hex 13
            DFECLKDLYADJMON       => open,
            DFEDLYOVRD            => '1',
            DFEEYEDACMON          => open,
            DFESENSCAL            => open,
            DFETAP1               => "00000",
            DFETAP1MONITOR        => open,
            DFETAP2               => tied_to_ground_vec_i(4 downto 0),
            DFETAP2MONITOR        => open,
            DFETAP3               => tied_to_ground_vec_i(3 downto 0),
            DFETAP3MONITOR        => open,
            DFETAP4               => tied_to_ground_vec_i(3 downto 0),
            DFETAP4MONITOR        => open,
            DFETAPOVRD            => '1',
            DI                    => din((16 * i) + 15 downto (16 * i)),
            DRDY                  => drdy(i),
            DRPDO                 => dout((16 * i) + 15 downto (16 * i)),
            DWE                   => dwe(i),
            GATERXELECIDLE        => '0',
            GREFCLKRX             => tied_to_ground_i,
            GREFCLKTX             => tied_to_ground_i,
            GTXRXRESET            => v6pcie15,
            GTXTEST               => v6pcie16(i),
            GTXTXRESET            => v6pcie15,
            LOOPBACK              => "000",
            MGTREFCLKFAB          => open,
            MGTREFCLKRX           => v6pcie18,
            MGTREFCLKTX           => v6pcie18,
            NORTHREFCLKRX         => tied_to_ground_vec_i(1 downto 0),
            NORTHREFCLKTX         => tied_to_ground_vec_i(1 downto 0),
            PHYSTATUS             => GTX_PhyStatus(i),
            PLLRXRESET            => '0',
            PLLTXRESET            => '0',
            PRBSCNTRESET          => '0',
            RXBUFRESET            => '0',
            RXBUFSTATUS           => open,
            RXBYTEISALIGNED       => open,
            RXBYTEREALIGN         => open,
            RXCDRRESET            => '0',
            RXCHANBONDSEQ         => open,
            RXCHANISALIGNED       => ChanIsAligned_v6pcie0(i),
            RXCHANREALIGN         => open,
            RXCHARISCOMMA         => open,
            RXCHARISK             => v6pcie21((4 * i) + 3 downto (4 * i)),
            RXCHBONDI             => RXCHBOND(i),
            RXCHBONDLEVEL         => GTX_RxChbondLevel((3 * i) + 2 downto (3 * i)),
            RXCHBONDMASTER        => to_stdlogic(i = 0),
            RXCHBONDO             => RXCHBOND(i + 1),
            RXCHBONDSLAVE         => to_stdlogic(i > 0),
            RXCLKCORCNT           => open,
            RXCOMMADET            => open,
            RXCOMMADETUSE         => '1',
            RXDATA                => v6pcie23(((32 * i) + 31) downto (32 * i)),
            RXDATAVALID           => open,
            RXDEC8B10BUSE         => RXDEC8B10BUSE,
            RXDISPERR             => open,
            RXDLYALIGNDISABLE     => '1',
            RXELECIDLE            => GTX_RxElecIdle(i),
            RXENCHANSYNC          => '1',
            RXENMCOMMAALIGN       => '1',
            RXENPCOMMAALIGN       => '1',
            RXENPMAPHASEALIGN     => '0',
            RXENPRBSTST           => "000",
            RXENSAMPLEALIGN       => '0',
            RXDLYALIGNMONENB      => '1',
            RXEQMIX               => "0110000011",
            RXGEARBOXSLIP         => '0',
            RXHEADER              => open,
            RXHEADERVALID         => open,
            RXLOSSOFSYNC          => open,
            RXN                   => GTX_RXN(i),
            RXNOTINTABLE          => open,
            RXOVERSAMPLEERR       => open,
            RXP                   => GTX_RXP(i),
            RXPLLLKDET            => RxPLLLkDet_v6pcie6(i),
            RXPLLLKDETEN          => '1',
            RXPLLPOWERDOWN        => '0',
            RXPLLREFSELDY         => "000",
            RXPMASETPHASE         => '0',
            RXPOLARITY            => GTX_RxPolarity(i),
            RXPOWERDOWN           => PowerDown((2 * i) + 1 downto (2 * i)),
            RXPRBSERR             => open,
            RXRATE                => v6pcie24,
            RXRATEDONE            => open,
            RXRECCLK              => RXRECCLK,
            RXRECCLKPCS           => open,
            RXRESET               => v6pcie25(i),
            RXRESETDONE           => GTX_RxResetDone(i),
            RXRUNDISP             => open,
            RXSLIDE               => '0',
            RXSTARTOFSEQ          => open,
            RXSTATUS              => GTX_RxStatus((3 * i) + 2 downto (3 * i)),
            RXUSRCLK              => PCLK,
            RXUSRCLK2             => PCLK,
            RXVALID               => GTX_RxValid(i),
            SOUTHREFCLKRX         => tied_to_ground_vec_i(1 downto 0),
            SOUTHREFCLKTX         => tied_to_ground_vec_i(1 downto 0),
            TSTCLK0               => '0',
            TSTCLK1               => '0',
            TSTIN                 => v6pcie26,
            TSTOUT                => open,
            TXBUFDIFFCTRL         => "111",
            TXBUFSTATUS           => open,
            TXBYPASS8B10B         => TXBYPASS8B10B(3 downto 0),
            TXCHARDISPMODE        => v6pcie27((4 * i) + 3 downto (4 * i) + 0),
            TXCHARDISPVAL         => "0000",
            TXCHARISK             => v6pcie28((4 * i) + 3 downto (4 * i) + 0),
            TXCOMINIT             => '0',
            TXCOMSAS              => '0',
            TXCOMWAKE             => '0',
            TXDATA                => v6pcie29((32 * i) + 31 downto (32 * i) + 0),
            TXDEEMPH              => TxDeemph,
            TXDETECTRX            => TxDetectRx,
            TXDIFFCTRL            => "1111",
            TXDLYALIGNDISABLE     => TXDLYALIGNDISABLE(i),
            TXDLYALIGNRESET       => TXDLYALIGNRESET(i),
            TXELECIDLE            => GTX_TxElecIdle(i),
            TXENC8B10BUSE         => '1',
            TXENPMAPHASEALIGN     => TXENPMAPHASEALIGN(i),
            TXENPRBSTST           => tied_to_ground_vec_i(2 downto 0),
            TXGEARBOXREADY        => open,
            TXHEADER              => tied_to_ground_vec_i(2 downto 0),
            TXINHIBIT             => '0',
            TXKERR                => open,
            TXMARGIN              => v6pcie30,
            TXN                   => GTX_TXN(i),
            TXOUTCLK              => TXOCLK(i),
            TXOUTCLKPCS           => open,
            TXP                   => GTX_TXP(i),
            TXPDOWNASYNCH         => TXPdownAsynch,
            TXPLLLKDET            => open,
            TXPLLLKDETEN          => '0',
            TXPLLPOWERDOWN        => '0',
            TXPLLREFSELDY         => "000",
            TXPMASETPHASE         => TXPMASETPHASE(i),
            TXPOLARITY            => '0',
            TXPOSTEMPHASIS        => tied_to_ground_vec_i(4 downto 0),
            TXPOWERDOWN           => PowerDown((2 * i) + 1 downto (2 * i)),
            TXPRBSFORCEERR        => tied_to_ground_i,
            TXPREEMPHASIS         => tied_to_ground_vec_i(3 downto 0),
            TXRATE                => v6pcie24,
            TXRESET               => v6pcie25(i),
            TXRESETDONE           => TXRESETDONE(i),
            TXRUNDISP             => open,
            TXSEQUENCE            => tied_to_ground_vec_i(6 downto 0),
            TXSTARTSEQ            => tied_to_ground_i,
            TXSWING               => TxSwing,
            TXUSRCLK              => PCLK,
            TXUSRCLK2             => PCLK,
            USRCODEERR            => tied_to_ground_i,
            IGNORESIGDET          => tied_to_ground_i,
            PERFCLKRX             => tied_to_ground_i,
            PERFCLKTX             => tied_to_ground_i,
            RXDLYALIGNMONITOR     => open,
            RXDLYALIGNOVERRIDE    => '0',
            RXDLYALIGNRESET       => tied_to_ground_i,
            RXDLYALIGNSWPPRECURB  => '1',
            RXDLYALIGNUPDSW       => '0',
            TXDLYALIGNMONITOR     => open,
            TXDLYALIGNOVERRIDE    => '0',
            TXDLYALIGNUPDSW       => '0',
            TXDLYALIGNMONENB      => '1',
            TXRATEDONE            => TXRATEDONE(i)
         );

   end generate;


end v6_pcie;

