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
-- File       : cl_a7pcie_x4_pcie_bram_7x.vhd
-- Version    : 1.11
--  Description : single bram wrapper for the mb pcie block
--                The bram A port is the write port
--                the      B port is the read port
--
--
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

library unimacro;
use unimacro.vcomponents.all;

entity cl_a7pcie_x4_pcie_bram_7x      is
  generic(
    LINK_CAP_MAX_LINK_SPEED : INTEGER := 1;             -- PCIe Link Speed : 1 - 2.5 GT/s; 2 - 5.0 GT/s
    LINK_CAP_MAX_LINK_WIDTH : INTEGER := 8;             -- PCIe Link Width : 1 / 2 / 4 / 8
    IMPL_TARGET             : STRING := "HARD";         -- the implementation target : HARD, SOFT
    DOB_REG                 : INTEGER := 0;             -- 1 - use the output register;
                                                        -- 0 - don't use the output register
    WIDTH                   : INTEGER := 0              -- supported WIDTH's : 4, 9, 18, 36 - uses RAMB36
                                                        --                     72 - uses RAMB36SDP
  );
   port (

      user_clk_i                           : in std_logic;                              -- user clock
      reset_i                              : in std_logic;                              -- bram reset
      wen_i                                : in std_logic;                              -- write enable
      waddr_i                              : in std_logic_vector(12 downto 0);          -- write address
      wdata_i                              : in std_logic_vector(WIDTH - 1 downto 0);   -- write data
      ren_i                                : in std_logic;                              -- read enable
      rce_i                                : in std_logic;                              -- output register clock enable
      raddr_i                              : in std_logic_vector(12 downto 0);          -- read address
      rdata_o                              : out std_logic_vector(WIDTH - 1 downto 0)   -- read data
   );
end cl_a7pcie_x4_pcie_bram_7x;

architecture v7_pcie of cl_a7pcie_x4_pcie_bram_7x is

  -- map the address bits
  function msb_addr (
    constant wdt   : integer)
    return integer is
     variable addr_msb : integer := 8;
  begin  -- msb_addr

    if (wdt = 4) then
      addr_msb := 12;
    elsif (wdt = 9) then
      addr_msb := 11;
    elsif (wdt = 18) then
      addr_msb := 10;
    elsif (wdt = 36) then
      addr_msb := 9;
    else
      addr_msb := 8;
    end if;
    return addr_msb;
  end msb_addr;

      constant ADDR_MSB                    : integer := msb_addr(WIDTH);

      -- set the width of the tied off low address bits
  function alb (
    constant wdt   : integer)
    return integer is
     variable addr_lo_bit : integer := 8;
  begin  -- alb

    if (wdt = 4) then
      addr_lo_bit := 2;
    elsif (wdt = 9) then
      addr_lo_bit := 3;
    elsif (wdt = 18) then
      addr_lo_bit := 4;
    elsif (wdt = 36) then
      addr_lo_bit := 5;
    else
      addr_lo_bit := 0;      -- for WIDTH 72 use RAMB36SDP
    end if;
    return addr_lo_bit;
  end alb;

      constant ADDR_LO_BITS                : integer := alb(WIDTH);

      -- map the data bits
  function msb_d (
    constant wdt   : integer)
    return integer is
     variable dmsb : integer := 8;
  begin  -- msb_d

    if (wdt = 4) then
      dmsb := 3;
    elsif (wdt = 9) then
      dmsb := 7;
    elsif (wdt = 18) then
      dmsb := 15;
    elsif (wdt = 36) then
      dmsb := 31;
    else
      dmsb := 63;
    end if;
    return dmsb;
  end msb_d;

      constant D_MSB                       : integer :=  msb_d(WIDTH);

      -- map the data parity bits
      constant DP_LSB                      : integer := D_MSB + 1;

  function msb_dp (
    constant wdt   : integer)
    return integer is
     variable dpmsb : integer := 8;
  begin  -- msb_dp

    if (wdt = 4) then
      dpmsb := 4;
    elsif (wdt = 9) then
      dpmsb := 8;
    elsif (wdt = 18) then
      dpmsb := 17;
    elsif (wdt = 36) then
      dpmsb := 35;
    else
      dpmsb := 71;
    end if;
    return dpmsb;
  end msb_dp;

  function pad_val (
    in_vec   : std_logic_vector;
    range_hi : integer;
    range_lo : integer;
    pad      : std_logic;
    op_len   : integer)
    return std_logic_vector is
   variable ret : std_logic_vector(op_len-1 downto 0) := (others => '0');
  begin  -- pad_val
    for i in 0 to op_len-1 loop
      if ((i >= range_lo) and (i <= range_hi)) then
        ret(i) := in_vec(i - range_lo);
      else
        ret(i) := pad;
      end if;
    end loop;  -- i
    return ret;
  end pad_val;

  function device_val (
    impl_target   : string)
    return string is
  begin  -- dev
    if (impl_target = "HARD") then
      return "7SERIES";
    else
      return "VIRTEX6";
    end if;
  end device_val;

  function get_write_mode (
    link_width : integer;
    WIDTH      : integer;
    link_speed : integer)
    return string is
  begin  -- wr_mode
    if ((WIDTH = 72) and (not((link_width =8) and (link_speed = 2)))) then
      return "WRITE_FIRST";
    elsif ((link_width =8) and (link_speed = 2)) then
      return "WRITE_FIRST";
    else
      return "NO_CHANGE";
    end if;
  end get_write_mode;

  function get_we_width (
    DEVICE   : string;
    WIDTH  : integer)
    return integer is
  begin  -- wr_mode
    if ((DEVICE = "VIRTEX5") or (DEVICE = "VIRTEX6") or (DEVICE = "7SERIES")) then
      if (WIDTH <= 9) then
        return 1;
      elsif (WIDTH > 9 and WIDTH <= 18) then
        return 2;
      elsif (WIDTH > 18 and WIDTH <= 36) then
        return 4;
      elsif (WIDTH > 36 and WIDTH <= 72) then
        return 8;
      else
        return 8;
      end if;
    else
      return 8;
    end if;
  end get_we_width;

  constant DP_MSB                      : integer :=  msb_dp(WIDTH);
  constant DPW                         : integer := DP_MSB - DP_LSB + 1;
  constant WRITE_MODE                  : string  := get_write_mode(LINK_CAP_MAX_LINK_WIDTH,WIDTH,LINK_CAP_MAX_LINK_SPEED);
  constant BRAM_SIZE                   : string  := "36Kb";
  constant DEVICE                      : string  := device_val(IMPL_TARGET);
  constant WE_WIDTH                    : integer := get_we_width(DEVICE,WIDTH);

  signal DIB_dummy                     : std_logic_vector ((WIDTH-1) downto 0);
  signal WE_dummy_gnd                  : std_logic_vector ((WE_WIDTH-1) downto 0);
  signal WE_dummy_vcc                  : std_logic_vector ((WE_WIDTH-1) downto 0);
  signal rdata_o_dummy                 : std_logic_vector (WIDTH-1 downto 0);

  begin
    -- Tie off dummy vectors
    DIB_dummy     <= (others => '0');
    WE_dummy_gnd  <= (others => '0');
    WE_dummy_vcc  <= (others => '1');

   --synthesis translate_off
   process
   begin
      --$display("[%t] %m DOB_REG %0d WIDTH %0d ADDR_MSB %0d ADDR_LO_BITS %0d DP_MSB %0d DP_LSB %0d D_MSB %0d",
      --          $time, DOB_REG,   WIDTH,    ADDR_MSB,    ADDR_LO_BITS,    DP_MSB,    DP_LSB,    D_MSB);

      case WIDTH is
         when 4 | 9 | 18 | 36 | 72 =>
         when others =>  -- case (WIDTH)
            -- $display("[%t] %m Error WIDTH %0d not supported", now, to_stdlogic(WIDTH));
            -- $finish();
      end case;
      wait;
   end process;

   --synthesis translate_on

   use_sdp : if (((LINK_CAP_MAX_LINK_WIDTH = "001000") and (LINK_CAP_MAX_LINK_SPEED = "0010")) or ( WIDTH = 72)) generate

    --  v6pcie2 <= (others => wen_i);
    --  rdata_o_v6pcie0 <= v6pcie16((DP_MSB - DP_LSB) downto 0) & v6pcie15(D_MSB downto 0);

      -- use RAMB36SDP if the width is 72 or X8GEN2
      ramb36sdp : BRAM_SDP_MACRO
         generic map (
            DEVICE      => DEVICE,
            BRAM_SIZE   => BRAM_SIZE,
            DO_REG      => DOB_REG,
            READ_WIDTH  => WIDTH,
            WRITE_WIDTH => WIDTH,
            WRITE_MODE  => WRITE_MODE
         )
         port map (
            DO      => rdata_o(WIDTH-1 downto 0),
            DI      => wdata_i(WIDTH-1 downto 0),
            RDADDR  => raddr_i(ADDR_MSB downto 0),
            RDCLK   => user_clk_i,
            RDEN    => ren_i,
            REGCE   => rce_i,
            RST     => reset_i,
            WE      => WE_dummy_vcc,
            WRADDR  => waddr_i(ADDR_MSB downto 0),
            WRCLK   => user_clk_i,
            WREN    => wen_i
         );

      -- use RAMB36's if the width is 4, 9, 18, or 36
   end generate;

   use_tdp : if (( WIDTH <= 36) and (not((LINK_CAP_MAX_LINK_WIDTH = "001000") and (LINK_CAP_MAX_LINK_SPEED = "0010")))) generate
        -- use RAMB36SDP if the width is 72 or X8GEN2
      ramb36 : BRAM_TDP_MACRO
         generic map (
            DEVICE        => DEVICE,
            BRAM_SIZE     => BRAM_SIZE,
            DOA_REG       => 0,
            DOB_REG       => DOB_REG,
            READ_WIDTH_A  => WIDTH,
            READ_WIDTH_B  => WIDTH,
            WRITE_WIDTH_A => WIDTH,
            WRITE_WIDTH_B => WIDTH,
            WRITE_MODE_A  => WRITE_MODE
         )
         port map (
            DOA     => rdata_o_dummy(WIDTH-1 downto 0),
            DOB     => rdata_o(WIDTH-1 downto 0),
            ADDRA   => waddr_i(ADDR_MSB downto 0),
            ADDRB   => raddr_i(ADDR_MSB downto 0),
            CLKA    => user_clk_i,
            CLKB    => user_clk_i,
            DIA     => wdata_i(WIDTH-1 downto 0),
            DIB     => DIB_dummy,
            ENA     => wen_i,
            ENB     => ren_i,
            REGCEA  => '0',
            REGCEB  => rce_i,
            RSTA    => reset_i,
            RSTB    => reset_i,
            WEA     => WE_dummy_vcc,
            WEB     => WE_dummy_gnd
         );

    end generate;
end v7_pcie;

