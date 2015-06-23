-------------------------------------------------------------------------------
--
-- (c) Copyright 2010-2011 Xilinx, Inc. All rights reserved.
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
-- Project    : Series-7 Integrated Block for PCI Express
-- File       : cl_a7pcie_x4_gt_rx_valid_filter_7x.vhd
-- Version    : 1.11
---- Description: GTX module for 7-series Integrated PCIe Block
----
----
----
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_unsigned.all;

entity cl_a7pcie_x4_gt_rx_valid_filter_7x is
  generic (
    CLK_COR_MIN_LAT      : integer := 28;
    TCQ                  : integer := 1
  );
  port (
    USER_RXCHARISK       : out std_logic_vector( 1 downto 0);
    USER_RXDATA          : out std_logic_vector(15 downto 0);        
    USER_RXVALID         : out std_logic;
    USER_RXELECIDLE      : out std_logic;
    USER_RX_STATUS       : out std_logic_vector( 2 downto 0);
    USER_RX_PHY_STATUS   : out std_logic;
    GT_RXCHARISK         : in  std_logic_vector( 1 downto 0);
    GT_RXDATA            : in  std_logic_vector(15 downto 0);
    GT_RXVALID           : in  std_logic;
    GT_RXELECIDLE        : in  std_logic;
    GT_RX_STATUS         : in  std_logic_vector( 2 downto 0);
    GT_RX_PHY_STATUS     : in  std_logic;
  
    PLM_IN_L0            : in  std_logic;
    PLM_IN_RS            : in  std_logic;
  
    USER_CLK             : in  std_logic;
    RESET                : in  std_logic
  );

end cl_a7pcie_x4_gt_rx_valid_filter_7x;                      
                                                               
architecture pcie_7x of cl_a7pcie_x4_gt_rx_valid_filter_7x is


  constant EIOS_DET_IDL          : std_logic_vector(4 downto 0) := "00001";
  constant EIOS_DET_NO_STR0      : std_logic_vector(4 downto 0) := "00010";
  constant EIOS_DET_STR0         : std_logic_vector(4 downto 0) := "00100";
  constant EIOS_DET_STR1         : std_logic_vector(4 downto 0) := "01000";
  constant EIOS_DET_DONE         : std_logic_vector(4 downto 0) := "10000";
                                 
  constant EIOS_COM              : std_logic_vector(7 downto 0) := X"BC";
  constant EIOS_IDL              : std_logic_vector(7 downto 0) := X"7C";
  constant FTSOS_COM             : std_logic_vector(7 downto 0) := X"BC";
  constant FTSOS_FTS             : std_logic_vector(7 downto 0) := X"3C";

  signal   reg_state_eios_det    : std_logic_vector(4 downto 0):= (others => '0');
  signal   state_eios_det        : std_logic_vector(4 downto 0):= (others => '0');

  signal   reg_eios_detected     : std_logic:= '0';
  signal   eios_detected         : std_logic:= '0';

  signal   reg_symbol_after_eios : std_logic:= '0';
  signal   symbol_after_eios     : std_logic:= '0';

  constant USER_RXVLD_IDL        : std_logic_vector(3 downto 0) := "0001";
  constant USER_RXVLD_EI         : std_logic_vector(3 downto 0) := "0010";
  constant USER_RXVLD_EI_DB0     : std_logic_vector(3 downto 0) := "0100";
  constant USER_RXVLD_EI_DB1     : std_logic_vector(3 downto 0) := "1000";


  signal   gt_rxcharisk_q        : std_logic_vector( 1 downto 0):= (others => '0');
  signal   gt_rxdata_q           : std_logic_vector(15 downto 0):= (others => '0');
  signal   gt_rxvalid_q          : std_logic:= '0';
  signal   gt_rxelecidle_q       : std_logic:= '0';

  signal   gt_rx_status_q        : std_logic_vector( 2 downto 0):= (others => '0');
  signal   gt_rx_phy_status_q    : std_logic:= '0';
  signal   gt_rx_is_skp0_q       : std_logic:= '0';                    
  signal   gt_rx_is_skp1_q       : std_logic:= '0';                    

  begin  

  -- EIOS detector

  process(USER_CLK) 
  begin
  
    if rising_edge(USER_CLK) then
      if (RESET = '1') then
        reg_eios_detected     <= '0' after (TCQ)*1 ps;
        reg_state_eios_det    <= EIOS_DET_IDL after (TCQ)*1 ps ;
        reg_symbol_after_eios <= '0' after (TCQ)*1 ps ;
        gt_rxcharisk_q        <= "00" after (TCQ)*1 ps ;
        gt_rxdata_q           <= X"0000" after (TCQ)*1 ps ;
        gt_rxvalid_q          <= '0' after (TCQ)*1 ps ;
        gt_rxelecidle_q       <= '0' after (TCQ)*1 ps ;
        gt_rx_status_q        <= "000" after (TCQ)*1 ps ;
        gt_rx_phy_status_q    <= '0' after (TCQ)*1 ps ;
        gt_rx_is_skp0_q       <= '0' after (TCQ)*1 ps ;
        gt_rx_is_skp1_q       <= '0' after (TCQ)*1 ps ;
  
      else
        reg_eios_detected     <= '0' after (TCQ)*1 ps ;
        reg_symbol_after_eios <= '0' after (TCQ)*1 ps ;
        gt_rxcharisk_q        <= GT_RXCHARISK after (TCQ)*1 ps ;
        gt_rxelecidle_q       <= GT_RXELECIDLE after (TCQ)*1 ps ;
        gt_rxdata_q           <= GT_RXDATA after (TCQ)*1 ps ;
        gt_rx_phy_status_q    <= GT_RX_PHY_STATUS after (TCQ)*1 ps ;
        
        --De-assert rx_valid signal when EIOS is detected on RXDATA
        if((reg_state_eios_det = "10000") and (PLM_IN_L0 = '1')) then
          gt_rxvalid_q <= '0' after (TCQ)*1 ps; 
        elsif (GT_RXELECIDLE = '1' and gt_rxvalid_q = '0') then
          gt_rxvalid_q <= '0' after (TCQ)*1 ps; 
        else
          gt_rxvalid_q <= GT_RXVALID;
        end if;  
  
        if (gt_rxvalid_q = '1') then
          gt_rx_status_q <= GT_RX_STATUS after (TCQ)*1 ps ;
        elsif (gt_rxvalid_q = '0' and PLM_IN_L0 = '1') then
          gt_rx_status_q <= "000" after (TCQ)*1 ps;
        else
         gt_rx_status_q <= GT_RX_STATUS after (TCQ)*1 ps ;
        end if;     
        
        if ((GT_RXCHARISK(0) = '1') and (GT_RXDATA(7 downto 0) = FTSOS_FTS)) then 
          gt_rx_is_skp0_q <= '1' after (TCQ)*1 ps ;
        else
          gt_rx_is_skp0_q <= '0' after (TCQ)*1 ps ;
        end if;
  
        if ((GT_RXCHARISK(1) = '1') and (GT_RXDATA(15 downto 8) = FTSOS_FTS)) then
          gt_rx_is_skp1_q <= '1' after (TCQ)*1 ps ;
        else
          gt_rx_is_skp1_q <= '0' after (TCQ)*1 ps ;
        end if;
  
        case ( state_eios_det ) is
  
          when EIOS_DET_IDL => 
            if ((gt_rxcharisk_q(0) = '1' ) and (gt_rxdata_q( 7 downto 0) = EIOS_COM) and 
                (gt_rxcharisk_q(1) = '1' ) and (gt_rxdata_q(15 downto 8) = EIOS_IDL)) then
              reg_state_eios_det <= EIOS_DET_NO_STR0 after (TCQ)*1 ps ;
              reg_eios_detected  <= '1' after (TCQ)*1 ps;
              --gt_rxvalid_q       <= '0' after (TCQ)*1 ps;
            elsif ((gt_rxcharisk_q(1) = '1' ) and (gt_rxdata_q(15 downto 8) = EIOS_COM)) then
              reg_state_eios_det <= EIOS_DET_STR0 after (TCQ)*1 ps ;
            else
              reg_state_eios_det <= EIOS_DET_IDL after (TCQ)*1 ps ;
            end if;
  
          when EIOS_DET_NO_STR0 =>
            if ((gt_rxcharisk_q(0) = '1' and (gt_rxdata_q( 7 downto 0) = EIOS_IDL)) and
                (gt_rxcharisk_q(1) = '1' and (gt_rxdata_q(15 downto 8) = EIOS_IDL))) then
              reg_state_eios_det <= EIOS_DET_DONE after (TCQ)*1 ps ;
              gt_rxvalid_q       <= '0' after (TCQ)*1 ps ;
            elsif (gt_rxcharisk_q(0) = '1' and (gt_rxdata_q(7 downto 0) = EIOS_IDL)) then
              reg_state_eios_det <= EIOS_DET_DONE after (TCQ)*1 ps ;
              gt_rxvalid_q       <= '0' after (TCQ)*1 ps;
            else
              reg_state_eios_det <= EIOS_DET_IDL after (TCQ)*1 ps ;
            end if;
  
          when EIOS_DET_STR0 => 
  
            if ((gt_rxcharisk_q(0) = '1' and (gt_rxdata_q( 7 downto 0) = EIOS_IDL)) and
                (gt_rxcharisk_q(1) = '1' and (gt_rxdata_q(15 downto 8) = EIOS_IDL))) then
              reg_state_eios_det    <= EIOS_DET_STR1 after (TCQ)*1 ps ;
              reg_eios_detected     <= '1' after (TCQ)*1 ps;
              gt_rxvalid_q          <= '0' after (TCQ)*1 ps;
              reg_symbol_after_eios <= '1' after (TCQ)*1 ps;
            else
              reg_state_eios_det    <= EIOS_DET_IDL after (TCQ)*1 ps ;
            end if;
  
          when EIOS_DET_STR1 => 
            if ((gt_rxcharisk_q(0) = '1' ) and (gt_rxdata_q(7 downto 0) = EIOS_IDL)) then
              reg_state_eios_det <= EIOS_DET_DONE after (TCQ)*1 ps ;
              gt_rxvalid_q       <= '0' after (TCQ)*1 ps ;
            else
              reg_state_eios_det <= EIOS_DET_IDL after (TCQ)*1 ps ;
            end if;
  
          when EIOS_DET_DONE => 
            reg_state_eios_det <= EIOS_DET_IDL after (TCQ)*1 ps ;
  
          when others => 
            reg_state_eios_det <= EIOS_DET_IDL after (TCQ)*1 ps ;          
            
        end case;

      end if;
    end if;

  end process;
  
  
  state_eios_det    <= reg_state_eios_det;
  eios_detected     <= reg_eios_detected;
  symbol_after_eios <= reg_symbol_after_eios;
  
--  rx_elec_idle_delay : SRL16E
--  generic map (
--    INIT  => X"0000"
--  )
--  port map (
--    Q    => USER_RXELECIDLE,
--    D    => gt_rxelecidle_q,
--    CLK  => USER_CLK,
--    CE   => '1',
--    A3   => '1',
--    A2   => '1',
--    A1   => '1',
--    A0   => '1'
--  );

  USER_RXVALID             <= gt_rxvalid_q;
  USER_RXCHARISK(0)        <= gt_rxcharisk_q(0) when (gt_rxvalid_q = '1') else '0';
  USER_RXCHARISK(1)        <= gt_rxcharisk_q(1) when (gt_rxvalid_q = '1' and symbol_after_eios = '0') else '0';
  USER_RXDATA(7 downto 0)  <= gt_rxdata_q(7 downto 0);
  USER_RXDATA(15 downto 8) <= gt_rxdata_q(15 downto 8);
  USER_RX_STATUS           <= gt_rx_status_q;
  USER_RX_PHY_STATUS       <= gt_rx_phy_status_q;
  USER_RXELECIDLE          <= gt_rxelecidle_q;
                    
end pcie_7x;
