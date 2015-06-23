-------------------------------------------------------------------------------
--
-- (c) Copyright 2008, 2009 Xilinx, Inc. All rights reserved.
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
-- Project    : Spartan-6 Integrated Block for PCI Express
-- File       : pcie_bram_s6.vhd
-- Description: BlockRAM module for Spartan-6 PCIe Block
--              The BRAM A port is the write port.
--              The BRAM B port is the read port.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

entity pcie_bram_s6 is
  generic (
    DOB_REG   : integer := 0; --  1 use output register, 0 don't use output register
    WIDTH     : integer := 0  --  supported WIDTH values are: 4, 9, 18, 36
  );
  port (
    user_clk_i   : in  std_logic; --  user clock
    reset_i      : in  std_logic; --  bram reset

    wen_i        : in  std_logic; --  write enable
    waddr_i      : in  std_logic_vector(11 downto 0); --  write address
    wdata_i      : in  std_logic_vector(WIDTH-1 downto 0); --  write data

    ren_i        : in  std_logic; --  read enable
    rce_i        : in  std_logic; --  output register clock enable
    raddr_i      : in  std_logic_vector(11 downto 0); --  read address

    rdata_o      : out std_logic_vector(WIDTH-1 downto 0) --  read data
  );
end pcie_bram_s6;

architecture rtl of pcie_bram_s6 is

  function CALC_ADDR(constant WIDTH : in integer;
                     constant addr_in : in std_logic_vector(11 downto 0)
                    ) return std_logic_vector is
    variable ADDR : std_logic_vector(13 downto 0);
  begin
    if    WIDTH = 4 then  ADDR := addr_in(11 downto 0) & "00";
    elsif WIDTH = 9 then  ADDR := addr_in(10 downto 0) & "000";
    elsif WIDTH = 18 then ADDR := addr_in(9  downto 0) & "0000";
    else                  ADDR := addr_in(8  downto 0) & "00000"; -- WIDTH=36
    end if;
    return ADDR;
  end function CALC_ADDR;

  signal di_int     : std_logic_vector(31 downto 0);
  signal dip_int    : std_logic_vector(3 downto 0);
  signal do_int     : std_logic_vector(31 downto 0);
  signal dop_int    : std_logic_vector(3 downto 0);
  signal waddr_int  : std_logic_vector(13 downto 0);
  signal raddr_int  : std_logic_vector(13 downto 0);
  signal wen_int    : std_logic_vector(3 downto 0);

begin

  --synthesis translate_off
  process
  begin
    case WIDTH is
      when 4 | 9 | 18 | 36 =>
        null;
      when others =>
        report "ERROR: WIDTH size " & integer'image(WIDTH) & " is not supported."
          severity failure;
    end case;
    wait;
  end process;
  --synthesis translate_on

  -- Wire up BRAM I/Os to module I/Os - map data & parity bits appropriately
  width_36 : if (WIDTH = 36) generate
    di_int                <= wdata_i(31 downto 0);
    dip_int               <= wdata_i(35 downto 32);
    rdata_o(35 downto 32) <= dop_int;
    rdata_o(31 downto 0)  <= do_int;
  end generate width_36;

  width_18 : if (WIDTH = 18) generate
    di_int(31 downto 16)  <= (OTHERS => '0');
    di_int(15 downto 0)   <= wdata_i(15 downto 0);
    dip_int(3 downto 2)   <= (OTHERS => '0');
    dip_int(1 downto 0)   <= wdata_i(17 downto 16);
    rdata_o(17 downto 16) <= dop_int(1 downto 0);
    rdata_o(15 downto 0)  <= do_int(15 downto 0);
  end generate width_18;

  width_9 : if (WIDTH = 9) generate
    di_int(31 downto 8)   <= (OTHERS => '0');
    di_int(7 downto 0)    <= wdata_i(7 downto 0);
    dip_int(3 downto 1)   <= (OTHERS => '0');
    dip_int(0)            <= wdata_i(8);
    rdata_o(8)            <= dop_int(0);
    rdata_o(7 downto 0)   <= do_int(7 downto 0);
  end generate width_9;

  width_4 : if (WIDTH = 4) generate
    di_int(31 downto 4)   <= (OTHERS => '0');
    di_int(3 downto 0)    <= wdata_i(3 downto 0);
    dip_int               <= (OTHERS => '0');
    rdata_o               <= do_int(3 downto 0);
  end generate width_4;

  waddr_int <= CALC_ADDR(WIDTH, waddr_i);
  raddr_int <= CALC_ADDR(WIDTH, raddr_i);
  wen_int   <= wen_i & wen_i & wen_i & wen_i;

  ramb16 : RAMB16BWER
  generic map (
    DATA_WIDTH_A  => WIDTH,
    DATA_WIDTH_B  => WIDTH,
    DOA_REG       => 0,
    DOB_REG       => DOB_REG,
    WRITE_MODE_A  => "NO_CHANGE",
    WRITE_MODE_B  => "NO_CHANGE"
  )
  port map (
    CLKA           => user_clk_i,
    RSTA           => reset_i,
    DOA            => open,
    DOPA           => open,
    ADDRA          => waddr_int,
    DIA            => di_int,
    DIPA           => dip_int,
    ENA            => wen_i,
    WEA            => wen_int,
    REGCEA         => '0',

    CLKB           => user_clk_i,
    RSTB           => reset_i,
    WEB            => "0000",
    DIB            => x"00000000",
    DIPB           => "0000",
    ADDRB          => raddr_int,
    DOB            => do_int,
    DOPB           => dop_int,
    ENB            => ren_i,
    REGCEB         => rce_i
  );

end rtl;

