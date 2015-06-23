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
-- File       : pcie_brams_s6.vhd
-- Description: BlockRAM module for Spartan-6 PCIe Block
--
--              Arranges and connects brams
--              Implements address decoding, datapath muxing and
--              pipeline stages
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity pcie_brams_s6 is
  generic (
    -- the number of BRAMs to use
    -- supported values are:
    -- 1,2,4,9
    NUM_BRAMS           : integer := 0;

    -- BRAM read address latency
    --
    -- value     meaning
    -- ====================================================
    --   0       BRAM read address port sample
    --   1       BRAM read address port sample and a pipeline stage on the address port
    RAM_RADDR_LATENCY   : integer := 1;

    -- BRAM read data latency
    --
    -- value     meaning
    -- ====================================================
    --   1       no BRAM OREG
    --   2       use BRAM OREG
    --   3       use BRAM OREG and a pipeline stage on the data port
    RAM_RDATA_LATENCY   : integer := 1;

    -- BRAM write latency
    -- The BRAM write port is synchronous
    --
    -- value     meaning
    -- ====================================================
    --   0       BRAM write port sample
    --   1       BRAM write port sample plus pipeline stage
    RAM_WRITE_LATENCY   : integer :=  1
  );
  port (
    user_clk_i          : in std_logic;
    reset_i             : in std_logic;
    wen                 : in std_logic;
    waddr               : in std_logic_vector(11 downto 0);
    wdata               : in std_logic_vector(35 downto 0);
    ren                 : in std_logic;
    rce                 : in std_logic;
    raddr               : in std_logic_vector(11 downto 0);
    rdata               : out std_logic_vector(35 downto 0)
  );
end pcie_brams_s6;

architecture rtl of pcie_brams_s6 is

  constant TCQ : time := 1 ns;  -- Clock-to-out delay to be modeled

  -- Turn on the bram output register
  function CALC_DOB_REG(constant RAM_RDATA_LATENCY : in integer) return integer is
    variable DOB_REG : integer;
  begin
    if   (RAM_RDATA_LATENCY > 1) then DOB_REG := 1;
    else                              DOB_REG := 0;
    end if;
    return DOB_REG;
  end function CALC_DOB_REG;

  -- Calculate the data width of the individual BRAMs
  function CALC_WIDTH(constant NUM_BRAMS : in integer) return integer is
    variable WIDTH : integer;
  begin
    if    (NUM_BRAMS = 1) then WIDTH := 36;
    elsif (NUM_BRAMS = 2) then WIDTH := 18;
    elsif (NUM_BRAMS = 4) then WIDTH := 9;
    else                       WIDTH := 4; -- NUM_BRAMS = 9
    end if;
    return WIDTH;
  end function CALC_WIDTH;

  component pcie_bram_s6 is
  generic (
    DOB_REG           : integer;
    WIDTH             : integer
  );
  port (
    user_clk_i : in std_logic;
    reset_i    : in std_logic;

    wen_i      : in std_logic;
    waddr_i    : in std_logic_vector(11 downto 0);
    wdata_i    : in std_logic_vector(CALC_WIDTH(NUM_BRAMS)-1 downto 0);

    ren_i      : in std_logic;
    rce_i      : in std_logic;
    raddr_i    : in std_logic_vector(11 downto 0);

    rdata_o    : out std_logic_vector(CALC_WIDTH(NUM_BRAMS)-1 downto 0) --  read data
  );
  end component;

  -- Model the delays for RAM write latency
  signal wen_int   : std_logic;
  signal waddr_int : std_logic_vector(11 downto 0);
  signal wdata_int : std_logic_vector(35 downto 0);

  signal wen_dly   : std_logic;
  signal waddr_dly : std_logic_vector(11 downto 0);
  signal wdata_dly : std_logic_vector(35 downto 0);

  -- Model the delays for RAM read latency
  signal ren_int   : std_logic;
  signal raddr_int : std_logic_vector(11 downto 0);
  signal rdata_int : std_logic_vector(35 downto 0);

  signal ren_dly   : std_logic;
  signal raddr_dly : std_logic_vector(11 downto 0);
  signal rdata_dly : std_logic_vector(35 downto 0);

begin

  --synthesis translate_off
  process begin
    case NUM_BRAMS is
      when 1 | 2 | 4 | 9 =>
        null;
      when others =>
        report "Error NUM_BRAMS size " & integer'image(NUM_BRAMS) & " is not supported." severity failure;
    end case; -- case NUM_BRAMS

    case RAM_RADDR_LATENCY is
      when 0 | 1 =>
        null;
      when others =>
        report "Error RAM_RADDR_LATENCY size " & integer'image(RAM_RADDR_LATENCY) & " is not supported." severity failure;
    end case; -- case RAM_RADDR_LATENCY

    case RAM_RDATA_LATENCY is
      when 1 | 2 | 3 =>
        null;
      when others =>
        report "Error RAM_RDATA_LATENCY size " & integer'image(RAM_RDATA_LATENCY) & " is not supported." severity failure;
    end case; -- case RAM_RDATA_LATENCY

    case RAM_WRITE_LATENCY is
      when 0 | 1 =>
        null;
      when others =>
        report "Error RAM_WRITE_LATENCY size " & integer'image(RAM_WRITE_LATENCY) & " is not supported." severity failure;
    end case; -- case RAM_WRITE_LATENCY

    wait;
  end process;
  --synthesis translate_on

  -- 1 stage RAM write pipeline
  wr_lat_1 : if(RAM_WRITE_LATENCY = 1) generate
    process (user_clk_i) begin
      if (user_clk_i'event and user_clk_i = '1') then
         if (reset_i = '1') then
           wen_dly   <= '0' after TCQ;
           waddr_dly <= (others => '0') after TCQ;
           wdata_dly <= (others => '0') after TCQ;
         else
           wen_dly   <= wen after TCQ;
           waddr_dly <= waddr after TCQ;
           wdata_dly <= wdata after TCQ;
         end if;
      end if;
    end process;

    wen_int <= wen_dly;
    waddr_int <= waddr_dly;
    wdata_int <= wdata_dly;
  end generate wr_lat_1;

  -- No RAM write pipeline
  wr_lat_0 : if(RAM_WRITE_LATENCY /= 1) generate
    wen_int   <= wen;
    waddr_int <= waddr;
    wdata_int <= wdata;
  end generate wr_lat_0;


  -- 1 stage RAM read addr pipeline
  raddr_lat_1 : if(RAM_RADDR_LATENCY = 1) generate
    process (user_clk_i) begin
      if (user_clk_i'event and user_clk_i = '1') then
        if (reset_i = '1') then
          ren_dly   <= '0' after TCQ;
          raddr_dly <= (others => '0') after TCQ;
        else 
          ren_dly   <= ren after TCQ;
          raddr_dly <= raddr after TCQ;
        end if;
      end if;
    end process;

    ren_int <= ren_dly;
    raddr_int <= raddr_dly;

  end generate raddr_lat_1;

  -- No RAM read addr pipeline
  raddr_lat_0 : if(RAM_RADDR_LATENCY /= 1) generate
    ren_int   <= ren after TCQ;
    raddr_int <= raddr after TCQ;
  end generate raddr_lat_0;

  -- 3 stages RAM read data pipeline (first is internal to BRAM)
  rdata_lat_3 : if(RAM_RDATA_LATENCY = 3) generate
    process (user_clk_i) begin
      if (user_clk_i'event and user_clk_i = '1') then
        if (reset_i = '1') then
          rdata_dly <= (others => '0') after TCQ;
        else
          rdata_dly <= rdata_int after TCQ;
        end if;
      end if;
    end process;

    rdata <= rdata_dly;

  end generate rdata_lat_3;

  -- 1 or 2 stages RAM read data pipeline
  rdata_lat_1_2 : if(RAM_RDATA_LATENCY /= 3) generate
    rdata <= rdata_int;
  end generate rdata_lat_1_2;

  -- Instantiate BRAM(s)
  brams : for i in 0 to (NUM_BRAMS - 1) generate
  begin
    ram : pcie_bram_s6
    generic map (
      DOB_REG => CALC_DOB_REG(RAM_RDATA_LATENCY),
      WIDTH   => CALC_WIDTH(NUM_BRAMS)
    )
    port map (
      user_clk_i => user_clk_i,
      reset_i    => reset_i,
      wen_i      => wen_int,
      waddr_i    => waddr_int,
      wdata_i    => wdata_int((((i + 1) * CALC_WIDTH(NUM_BRAMS)) - 1) downto (i * CALC_WIDTH(NUM_BRAMS))),
      ren_i      => ren_int,
      rce_i      => rce,
      raddr_i    => raddr_int,
      rdata_o    => rdata_int((((i + 1) * CALC_WIDTH(NUM_BRAMS)) - 1) downto (i * CALC_WIDTH(NUM_BRAMS)))
    );
  end generate brams;

end rtl;

