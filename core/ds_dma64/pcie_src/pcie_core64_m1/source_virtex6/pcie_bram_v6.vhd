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
-- File       : pcie_bram_v6.vhd
-- Version    : 2.3
--
-- Description: BlockRAM module for Virtex6 PCIe Block
--
--------------------------------------------------------------------------------

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

entity pcie_bram_v6 is
   generic (
      DOB_REG                              : integer := 0;		-- 1 use the output register 0 don't use the output register
      WIDTH                                : integer := 0		-- supported WIDTH's are: 4, 9, 18, 36 (uses RAMB36) and 72 (uses RAMB36SDP)
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
end pcie_bram_v6;

architecture v6_pcie of pcie_bram_v6 is

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

  constant DP_MSB                      : integer :=  msb_dp(WIDTH);
      
      constant DPW                         : integer := DP_MSB - DP_LSB + 1;
      
      constant WRITE_MODE                  : string := "NO_CHANGE";

    -- ground and tied_to_vcc_i signals
    signal  tied_to_ground_i                :   std_logic;
    signal  tied_to_ground_vec_i            :   std_logic_vector(31 downto 0);
    signal  tied_to_vcc_i                   :   std_logic;


   -- X-HDL generated signals

   signal v6pcie2 : std_logic_vector(7 downto 0) := (others => '0');
   signal v6pcie5 : std_logic_vector(15 downto 0) := (others => '0');
   signal v6pcie7 : std_logic_vector(15 downto 0) := (others => '0');
   signal v6pcie11 : std_logic_vector(31 downto 0) := (others => '0');
   signal v6pcie12 : std_logic_vector(3 downto 0) := (others => '0');
   signal v6pcie15 : std_logic_vector(63 downto 0) := (others => '0');
   signal v6pcie16 : std_logic_vector(7 downto 0) := (others => '0');
   signal v6pcie13 : std_logic_vector((DP_MSB - DP_LSB) downto 0) := (others => '0');

      -- dob_unused and dopb_unused only needed when WIDTH < 36. how to declare
-- these accordingly.
   signal dob_unused : std_logic_vector(31 - D_MSB - 1 downto 0);
   signal dopb_unused : std_logic_vector(4 - DPW - 1 downto 0);

      
   -- Declare intermediate signals for referenced outputs
   signal rdata_o_v6pcie0                  : std_logic_vector(WIDTH - 1 downto 0);

begin

  ---------------------------  Static signal Assignments ---------------------

    tied_to_ground_i                    <= '0';
    tied_to_ground_vec_i(31 downto 0)   <= (others => '0');
    tied_to_vcc_i                       <= '1';

   -- Drive referenced outputs
   rdata_o <= rdata_o_v6pcie0;
   
   --synthesis translate_off
   process 
   begin
      --$display("[%t] %m DOB_REG %0d WIDTH %0d ADDR_MSB %0d ADDR_LO_BITS %0d DP_MSB %0d DP_LSB %0d D_MSB %0d",
      --          $time, DOB_REG,   WIDTH,    ADDR_MSB,    ADDR_LO_BITS,    DP_MSB,    DP_LSB,    D_MSB);
      
      case WIDTH is
         when 4 | 9 | 18 | 36 | 72 =>
         when others =>		-- case (WIDTH)
            -- $display("[%t] %m Error WIDTH %0d not supported", now, to_stdlogic(WIDTH));
            -- $finish();
      end case;
      wait;
   end process;
   
   --synthesis translate_on
   
   use_ramb36sdp : if (WIDTH = 72) generate
      
      v6pcie2 <= (others => wen_i);
      rdata_o_v6pcie0 <= v6pcie16((DP_MSB - DP_LSB) downto 0) & v6pcie15(D_MSB downto 0);

      -- use RAMB36SDP if the width is 72
      ramb36sdp_i : RAMB36SDP
         generic map (
            DO_REG  => DOB_REG
         )
         port map (
            DBITERR => open,
            ECCPARITY => open,
            SBITERR => open,
            WRCLK   => user_clk_i,
            SSR     => '0',
            WRADDR  => waddr_i(ADDR_MSB downto 0),
            DI      => wdata_i(D_MSB downto 0),
            DIP     => wdata_i(DP_MSB downto DP_LSB),
            WREN    => wen_i,
            WE      => v6pcie2,
            
            RDCLK   => user_clk_i,
            RDADDR  => raddr_i(ADDR_MSB downto 0),
            DO      => v6pcie15,
            DOP     => v6pcie16,
            RDEN    => ren_i,
            REGCE   => rce_i
         );
      
      -- use RAMB36's if the width is 4, 9, 18, or 36   
   end generate;
   use_ramb36_1 : if (WIDTH = 36) generate

      v6pcie2 <= (others => wen_i);
      v6pcie5 <= pad_val(waddr_i(ADDR_MSB downto 0), ADDR_MSB + ADDR_LO_BITS, ADDR_LO_BITS, '1', 16);
      v6pcie7 <= pad_val(raddr_i(ADDR_MSB downto 0), ADDR_MSB + ADDR_LO_BITS, ADDR_LO_BITS, '1', 16);
      rdata_o_v6pcie0 <= v6pcie16((DP_MSB - DP_LSB) downto 0) & v6pcie15(D_MSB downto 0);

      ramb36_i : RAMB36
         generic map (
            DOA_REG        => 0,
            DOB_REG        => DOB_REG,
            READ_WIDTH_A   => 0,
            READ_WIDTH_B   => WIDTH,
            WRITE_WIDTH_A  => WIDTH,
            WRITE_WIDTH_B  => 0,
            WRITE_MODE_A   => WRITE_MODE
         )
         port map (
            CLKA            => user_clk_i,
            SSRA            => '0',
            REGCEA          => '0',
            CASCADEINLATA   => '0',
            CASCADEINREGA   => '0',
            CASCADEOUTLATA  => open,
            CASCADEOUTREGA  => open,
            DOA             => open,
            DOPA            => open,
            ADDRA           => v6pcie5,
            DIA             => wdata_i(D_MSB downto 0),
            DIPA            => wdata_i(DP_MSB downto DP_LSB),
            ENA             => wen_i,
            WEA             => v6pcie2(3 downto 0),
            CLKB            => user_clk_i,
            SSRB            => '0',
            WEB             => "0000",
            CASCADEINLATB   => '0',
            CASCADEINREGB   => '0',
            CASCADEOUTLATB  => open,
            CASCADEOUTREGB  => open,
            DIB             => "00000000000000000000000000000000",
            DIPB            => "0000",
            ADDRB           => v6pcie7,
            DOB             => v6pcie15(31 downto 0),
            DOPB            => v6pcie16(3 downto 0),
            ENB             => ren_i,
            REGCEB          => rce_i
         );
      
   end generate;
   use_ramb36_2 : if (WIDTH < 36 and WIDTH > 4) generate

      v6pcie2 <= (others => wen_i);
      v6pcie5 <= pad_val(waddr_i(ADDR_MSB downto 0), ADDR_MSB + ADDR_LO_BITS, ADDR_LO_BITS, '1', 16);
      v6pcie7 <= pad_val(raddr_i(ADDR_MSB downto 0), ADDR_MSB + ADDR_LO_BITS, ADDR_LO_BITS, '1', 16);
      v6pcie11 <= pad_val(wdata_i(D_MSB downto 0), D_MSB, 0, '0', 32);
      v6pcie13 <= wdata_i(DP_MSB downto DP_LSB);
      v6pcie12 <= pad_val(v6pcie13((DP_MSB - DP_LSB) downto 0), DP_MSB - DP_LSB, 0, '0', 4);
      rdata_o_v6pcie0 <= v6pcie16((DP_MSB - DP_LSB) downto 0) & v6pcie15(D_MSB downto 0);

      ramb36_i : RAMB36
         generic map (
            DOA_REG        => 0,
            DOB_REG        => DOB_REG,
            READ_WIDTH_A   => 0,
            READ_WIDTH_B   => WIDTH,
            WRITE_WIDTH_A  => WIDTH,
            WRITE_WIDTH_B  => 0,
            WRITE_MODE_A   => WRITE_MODE
         )
         port map (
            CLKA            => user_clk_i,
            SSRA            => '0',
            REGCEA          => '0',
            CASCADEINLATA   => '0',
            CASCADEINREGA   => '0',
            CASCADEOUTLATA  => open,
            CASCADEOUTREGA  => open,
            DOA             => open,
            DOPA            => open,
            ADDRA           => v6pcie5,
            DIA             => v6pcie11,
            DIPA            => v6pcie12,
            ENA             => wen_i,
            WEA             => v6pcie2(3 downto 0),
            CLKB            => user_clk_i,
            SSRB            => '0',
            WEB             => "0000",
            CASCADEINLATB   => '0',
            CASCADEINREGB   => '0',
            CASCADEOUTLATB  => open,
            CASCADEOUTREGB  => open,
            DIB             => "00000000000000000000000000000000",
            DIPB            => "0000",
            ADDRB           => v6pcie7,
            DOB             => v6pcie15(31 downto 0),
            DOPB            => v6pcie16(3 downto 0),
            ENB             => ren_i,
            REGCEB          => rce_i
         );
      
   end generate;
   use_ramb36_3 : if (WIDTH = 4) generate
      
      v6pcie2 <= (others => wen_i);
      v6pcie5 <= pad_val(waddr_i(ADDR_MSB downto 0), ADDR_MSB + ADDR_LO_BITS, ADDR_LO_BITS, '1', 16);
      v6pcie7 <= pad_val(raddr_i(ADDR_MSB downto 0), ADDR_MSB + ADDR_LO_BITS, ADDR_LO_BITS, '1', 16);
      v6pcie11 <= pad_val(wdata_i(D_MSB downto 0), D_MSB, 0, '0', 32);
      rdata_o_v6pcie0 <= v6pcie15(D_MSB downto 0);

      ramb36_i : RAMB36
         generic map (
            dob_reg        => DOB_REG,
            read_width_a   => 0,
            read_width_b   => WIDTH,
            write_width_a  => WIDTH,
            write_width_b  => 0,
            write_mode_a   => WRITE_MODE
         )
         port map (
            CLKA            => user_clk_i,
            SSRA            => '0',
            REGCEA          => '0',
            CASCADEINLATA   => '0',
            CASCADEINREGA   => '0',
            CASCADEOUTLATA  => open,
            CASCADEOUTREGA  => open,
            DOA             => open,
            DOPA            => open,
            ADDRA           => v6pcie5,
            DIA             => v6pcie11,
            DIPA            => tied_to_ground_vec_i(3 downto 0),
            ENA             => wen_i,
            WEA             => v6pcie2(3 downto 0),
            CLKB            => user_clk_i,
            SSRB            => '0',
            WEB             => "0000",
            CASCADEINLATB   => '0',
            CASCADEINREGB   => '0',
            CASCADEOUTLATB  => open,
            CASCADEOUTREGB  => open,
            ADDRB           => v6pcie7,
            DIB             => tied_to_ground_vec_i,
            DIPB            => tied_to_ground_vec_i(3 downto 0),
            DOB             => v6pcie15(31 downto 0),
            DOPB            => open,
            ENB             => ren_i,
            REGCEB          => rce_i
         );


      -- block: use_ramb36
   end generate;
   
   		-- pcie_bram_v6
end v6_pcie;


