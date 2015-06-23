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
-- File       : cl_a7pcie_x4_pcie_brams_7x.vhd
-- Version    : 1.11
--  Description : pcie bram wrapper
--                arrange and connect brams
--                implement address decoding, datapath muxing and pipeline stages
--
--                banks of brams are used for 1,2,4,8,18 brams
--                brams are stacked for other values of NUM_BRAMS
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_unsigned.all;

entity cl_a7pcie_x4_pcie_brams_7x is
generic(
   LINK_CAP_MAX_LINK_SPEED : integer := 1;        -- PCIe Link Speed : 1 - 2.5 GT/s; 2 - 5.0 GT/s
   LINK_CAP_MAX_LINK_WIDTH : integer := 8;        -- PCIe Link Width : 1 / 2 / 4 / 8
   IMPL_TARGET             : string := "HARD";    -- the implementation target : HARD, SOFT

  -- the number of BRAMs to use
  -- supported values are:
  -- 1,2,4,8,18
   NUM_BRAMS               : integer := 0;

  -- BRAM read address latency
  --
  -- value     meaning
  -- ==========================
  --   0       BRAM read address port sample
  --   1       BRAM read address port sample and a pipeline stage on the address port
   RAM_RADDR_LATENCY       : integer := 1;

  -- BRAM read data latency
  --
  -- value     meaning
  -- ==========================
  --   1       no BRAM OREG
  --   2       use BRAM OREG
  --   3       use BRAM OREG and a pipeline stage on the data port
   RAM_RDATA_LATENCY       :integer := 1;

  -- BRAM write latency
  -- The BRAM write port is synchronous
  --
  -- value     meaning
  -- ==========================
  --   0       BRAM write port sample
  --   1       BRAM write port sample plus pipeline stage
   RAM_WRITE_LATENCY       :integer := 1
);
port (
    user_clk_i : in std_logic;                              -- user clock
    reset_i    : in std_logic;                              -- bram reset
    wen        : in std_logic;                              -- write enable
    waddr      : in std_logic_vector(12 downto 0);          -- write address
    wdata      : in std_logic_vector(71 downto 0);          -- write data
    ren        : in std_logic;                              -- read enable
    rce        : in std_logic;                              -- output register clock enable
    raddr      : in std_logic_vector(12 downto 0);          -- read address
    rdata      : out std_logic_vector(71 downto 0)          -- read data
);
end cl_a7pcie_x4_pcie_brams_7x;

architecture pcie_7x of cl_a7pcie_x4_pcie_brams_7x is
   component cl_a7pcie_x4_pcie_bram_7x is
      generic (
           LINK_CAP_MAX_LINK_SPEED : INTEGER := 1;             -- PCIe Link Speed : 1 - 2.5 GT/s; 2 - 5.0 GT/s
           LINK_CAP_MAX_LINK_WIDTH : INTEGER := 8;             -- PCIe Link Width : 1 / 2 / 4 / 8
           IMPL_TARGET             : STRING := "HARD";         -- the implementation target : HARD, SOFT
           DOB_REG                 : INTEGER := 0;             -- 1 - use the output register;
                                                               -- 0 - don't use the output register
           WIDTH                   : INTEGER := 0              -- supported WIDTH's : 4, 9, 18, 36 - uses RAMB36
                                                               --                     72 - uses RAMB36SDP
      );
      port (
           user_clk_i : in std_logic;                              -- user clock
           reset_i    : in std_logic;                              -- bram reset
           wen_i      : in std_logic;                              -- write enable
           waddr_i    : in std_logic_vector(12 downto 0);          -- write address
           wdata_i    : in std_logic_vector(WIDTH - 1 downto 0);   -- write data
           ren_i      : in std_logic;                              -- read enable
           rce_i      : in std_logic;                              -- output register clock enable
           raddr_i    : in std_logic_vector(12 downto 0);          -- read address
           rdata_o    : out std_logic_vector(WIDTH - 1 downto 0)   -- read data
      );
   end component;

  function get_dob_reg (
    constant rdata_lat   : integer)
    return integer is
  begin  -- get_dob_reg
    if (rdata_lat > 1) then
      return 1;
    else
      return 0;
    end if;
  end get_dob_reg;

  function get_width (
    constant num_brams   : integer)
    return integer is
  begin  -- msb_d

    if (num_brams = 1) then
      return 72;
    elsif (num_brams = 2) then
      return 36;
    elsif (num_brams = 4) then
      return 18;
    elsif (num_brams = 8) then
      return 9;
    else
      return 4;
    end if;
  end get_width;

  constant DOB_REG : integer :=  get_dob_reg(RAM_RDATA_LATENCY);
  constant WIDTH   : integer :=  get_width(NUM_BRAMS);
  constant TCQ     : integer := 1;

  signal wen_int   : std_logic;
  signal waddr_int : std_logic_vector(12 downto 0);
  signal wdata_int : std_logic_vector(71 downto 0);

  signal wen_q     : std_logic := '0';
  signal waddr_q   : std_logic_vector(12 downto 0) := (others => '0');
  signal wdata_q   : std_logic_vector(71 downto 0) := (others => '0');

  signal ren_int   : std_logic;
  signal raddr_int : std_logic_vector(12 downto 0);
  signal rdata_int : std_logic_vector(71 downto 0);

  signal ren_q     : std_logic := '0';
  signal raddr_q   : std_logic_vector(12 downto 0) := (others => '0');
  signal rdata_q   : std_logic_vector(71 downto 0) := (others => '0');

begin

   --synthesis translate_off
   process
   begin
      -- $display("[%t] %m NUM_BRAMS %0d  DOB_REG %0d WIDTH %0d RAM_WRITE_LATENCY %0d RAM_RADDR_LATENCY %0d RAM_RDATA_LATENCY %0d",
      -- now, to_stdlogic(NUM_BRAMS), to_stdlogicvector(DOB_REG, 13),
      -- ("00000000000000000000000000000000000000000000000000000000000000000" & WIDTH), to_stdlogic(RAM_WRITE_LATENCY),
      -- to_stdlogic(RAM_RADDR_LATENCY), to_stdlogicvector(RAM_RDATA_LATENCY, 13));
      case NUM_BRAMS is
         when 1 | 2 | 4 | 8 | 18 =>
         when others =>
            -- $display("[%t] %m Error NUM_BRAMS %0d not supported", now, to_stdlogic(NUM_BRAMS));
            -- $finish();
      end case;   -- case(NUM_BRAMS)
      case RAM_RADDR_LATENCY is
         when 0 | 1 =>
         when others =>
            -- $display("[%t] %m Error RAM_READ_LATENCY %0d not supported", now, to_stdlogic(RAM_RADDR_LATENCY));
            -- $finish();
      end case;   -- case (RAM_RADDR_LATENCY)
      case RAM_RDATA_LATENCY is
         when 1 | 2 | 3 =>
         when others =>
            -- $display("[%t] %m Error RAM_READ_LATENCY %0d not supported", now, to_stdlogic(RAM_RDATA_LATENCY));
            -- $finish();
      end case;   -- case (RAM_RDATA_LATENCY)
      case RAM_WRITE_LATENCY is
         when 0 | 1 =>
         when others =>
            -- $display("[%t] %m Error RAM_WRITE_LATENCY %0d not supported", now, to_stdlogic(RAM_WRITE_LATENCY));
            -- $finish();
      end case;   -- case(RAM_WRITE_LATENCY)
      wait;
   end process;
   --synthesis translate_on

  -- model the delays for ram write latency
   wr_lat_2 : if (RAM_WRITE_LATENCY = 1) generate
      process (user_clk_i)
      begin
         if (user_clk_i'event and user_clk_i = '1') then
            if (reset_i = '1') then
               wen_q   <= '0' after (TCQ)*1 ps;
               waddr_q <= "0000000000000" after (TCQ)*1 ps;
               wdata_q <= "000000000000000000000000000000000000000000000000000000000000000000000000" after (TCQ)*1 ps;
            else
               wen_q   <= wen after (TCQ)*1 ps;
               waddr_q <= waddr after (TCQ)*1 ps;
               wdata_q <= wdata after (TCQ)*1 ps;
            end if;
         end if;
      end process;

      wen_int   <= wen_q;
      waddr_int <= waddr_q;
      wdata_int <= wdata_q;
   end generate;

   wr_lat_1 : if (RAM_WRITE_LATENCY = 0) generate
      wen_int   <= wen;
      waddr_int <= waddr;
      wdata_int <= wdata;
   end generate;

   raddr_lat_2 : if (RAM_RADDR_LATENCY = 1) generate

      process (user_clk_i)
      begin
         if (user_clk_i'event and user_clk_i = '1') then
            if (reset_i = '1') then
               ren_q   <= '0' after (TCQ)*1 ps;
               raddr_q <= "0000000000000" after (TCQ)*1 ps;
            else
               ren_q   <= ren after (TCQ)*1 ps;
               raddr_q <= raddr after (TCQ)*1 ps;
            end if;  -- else: !if(reset_i)
         end if;
      end process;

      ren_int   <= ren_q;
      raddr_int <= raddr_q;

   end generate;      -- block: rd_lat_addr_2

   raddr_lat_1 : if (not(RAM_RADDR_LATENCY = 1)) generate
      ren_int <= ren;
      raddr_int <= raddr;
   end generate;

   rdata_lat_3 : if (RAM_RDATA_LATENCY = 3) generate

      process (user_clk_i)
      begin
         if (user_clk_i'event and user_clk_i = '1') then
            if (reset_i = '1') then
               rdata_q <= "000000000000000000000000000000000000000000000000000000000000000000000000" after (TCQ)*1 ps;
            else
               rdata_q <= rdata_int after (TCQ)*1 ps;
            end if;  -- else: !if(reset_i)
         end if;
      end process;

      rdata <= rdata_q;

   end generate;      -- block: rd_lat_data_3

   rdata_lat_1_2 : if (not(RAM_RDATA_LATENCY = 3)) generate
      rdata <= rdata_int after (TCQ)*1 ps;
   end generate;

   -- instantiate the brams
   brams : for ii in 0 to  NUM_BRAMS - 1 generate

     ram : cl_a7pcie_x4_pcie_bram_7x
         generic map (
           LINK_CAP_MAX_LINK_WIDTH => LINK_CAP_MAX_LINK_WIDTH,
           LINK_CAP_MAX_LINK_SPEED => LINK_CAP_MAX_LINK_SPEED,
           IMPL_TARGET             => IMPL_TARGET,
           DOB_REG                 => DOB_REG,
           WIDTH                   => WIDTH
         )
         port map (
           user_clk_i => user_clk_i,
           reset_i    => reset_i,
           wen_i      => wen_int,
           waddr_i    => waddr_int,
           wdata_i    => wdata_int(((ii+1)*WIDTH-1) downto (ii * WIDTH)),
           ren_i      => ren_int,
           raddr_i    => raddr_int,
           rdata_o    => rdata_int(((ii+1)*WIDTH-1) downto (ii * WIDTH)),
           rce_i      => rce
         );
   end generate;
     -- pcie_brams_7x
end pcie_7x;


