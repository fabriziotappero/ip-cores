
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
-- File       : pcie_brams_v6.vhd
-- Version    : 2.3
---- Description: BlockRAM module for Virtex6 PCIe Block
----
----
----
----------------------------------------------------------------------------------

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_unsigned.all;

entity pcie_brams_v6 is
   generic (
      -- the number of BRAMs to use
      -- supported values are:
      -- 1,2,4,8,18
      NUM_BRAMS                            : integer := 0;
      
      -- BRAM read address latency
      --
      -- value     meaning
      -- ====================================================
      --   0       BRAM read address port sample
      --   1       BRAM read address port sample and a pipeline stage on the address port
      RAM_RADDR_LATENCY                    : integer := 1;
      
      -- BRAM read data latency
      --
      -- value     meaning
      -- ====================================================
      --   1       no BRAM OREG
      --   2       use BRAM OREG
      --   3       use BRAM OREG and a pipeline stage on the data port
      RAM_RDATA_LATENCY                    : integer := 1;
      
      -- BRAM write latency
      -- The BRAM write port is synchronous
      --
      -- value     meaning
      -- ====================================================
      --   0       BRAM write port sample
      --   1       BRAM write port sample plus pipeline stage
      RAM_WRITE_LATENCY                    : integer := 1
      
   );
   port (
      user_clk_i                           : in std_logic;
      reset_i                              : in std_logic;
      wen                                  : in std_logic;
      waddr                                : in std_logic_vector(12 downto 0);
      wdata                                : in std_logic_vector(71 downto 0);
      ren                                  : in std_logic;
      rce                                  : in std_logic;
      raddr                                : in std_logic_vector(12 downto 0);
      rdata                                : out std_logic_vector(71 downto 0)
   );
end pcie_brams_v6;

architecture v6_pcie of pcie_brams_v6 is
   component pcie_bram_v6 is
      generic (
         DOB_REG                           : integer;
         WIDTH                             : integer
      );
      port (
         user_clk_i                        : in std_logic;
         reset_i                           : in std_logic;
         wen_i                             : in std_logic;
         waddr_i                           : in std_logic_vector(12 downto 0);
         wdata_i                           : in std_logic_vector(WIDTH - 1 downto 0);
         ren_i                             : in std_logic;
         rce_i                             : in std_logic;
         raddr_i                           : in std_logic_vector(12 downto 0);
         rdata_o                           : out std_logic_vector(WIDTH - 1 downto 0)
      );
   end component;
   
   FUNCTION to_integer (
      in_val      : IN boolean) RETURN integer IS
   BEGIN
      IF (in_val) THEN
         RETURN(1);
      ELSE
         RETURN(0);
      END IF;
   END to_integer;

      -- turn on the bram output register
   constant DOB_REG                        : integer := to_integer(RAM_RDATA_LATENCY > 1);
      
      -- calculate the data width of the individual brams
  function width (
    constant NUM_BRAM   : integer)
    return integer is
     variable WIDTH_BRAM : integer := 1;
  begin  -- width

    if (NUM_BRAM = 1) then
      WIDTH_BRAM := 72;
    elsif (NUM_BRAM = 2) then
      WIDTH_BRAM := 36;
    elsif (NUM_BRAM = 4) then
      WIDTH_BRAM := 18;
    elsif (NUM_BRAM = 8) then
      WIDTH_BRAM := 9;
    else
      WIDTH_BRAM := 4;
    end if;
    return WIDTH_BRAM;
  end width;

   constant BRAM_WIDTH : integer := width(NUM_BRAMS);

   constant TCQ                            : integer := 1;

   
   signal wen_int                          : std_logic;
   signal waddr_int                        : std_logic_vector(12 downto 0);
   signal wdata_int                        : std_logic_vector(71 downto 0);
   
   signal wen_dly                          : std_logic := '0';
   signal waddr_dly                        : std_logic_vector(12 downto 0) := (others => '0');
   signal wdata_dly                        : std_logic_vector(71 downto 0) := (others => '0');
   
   -- if (RAM_WRITE_LATENCY == 1)
   
   -- model the delays for ram read latency
   
   signal ren_int                          : std_logic;
   signal raddr_int                        : std_logic_vector(12 downto 0);
   signal rdata_int                        : std_logic_vector(71 downto 0);

   signal ren_dly                          : std_logic;
   signal raddr_dly                        : std_logic_vector(12 downto 0);
   signal rdata_dly                        : std_logic_vector(71 downto 0);

begin
   
   --synthesis translate_off
   process 
   begin
      -- $display("[%t] %m NUM_BRAMS %0d  DOB_REG %0d WIDTH %0d RAM_WRITE_LATENCY %0d RAM_RADDR_LATENCY %0d RAM_RDATA_LATENCY %0d", now, to_stdlogic(NUM_BRAMS), to_stdlogicvector(DOB_REG, 13), ("00000000000000000000000000000000000000000000000000000000000000000" & WIDTH), to_stdlogic(RAM_WRITE_LATENCY), to_stdlogic(RAM_RADDR_LATENCY), to_stdlogicvector(RAM_RDATA_LATENCY, 13));
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
               wen_dly <= '0' after (TCQ)*1 ps;
               waddr_dly <= "0000000000000" after (TCQ)*1 ps;
               wdata_dly <= "000000000000000000000000000000000000000000000000000000000000000000000000" after (TCQ)*1 ps;
            else
               wen_dly <= wen after (TCQ)*1 ps;
               waddr_dly <= waddr after (TCQ)*1 ps;
               wdata_dly <= wdata after (TCQ)*1 ps;
            end if;
         end if;
      end process;
      
      wen_int <= wen_dly;
      waddr_int <= waddr_dly;
      wdata_int <= wdata_dly;
   end generate;

   wr_lat_1 : if (RAM_WRITE_LATENCY = 0) generate
      wen_int <= wen;
      waddr_int <= waddr;
      wdata_int <= wdata;
   end generate;
   
   raddr_lat_2 : if (RAM_RADDR_LATENCY = 1) generate
      
      process (user_clk_i)
      begin
         if (user_clk_i'event and user_clk_i = '1') then
            if (reset_i = '1') then
               ren_dly <= '0' after (TCQ)*1 ps;
               raddr_dly <= "0000000000000" after (TCQ)*1 ps;
            else
               ren_dly <= ren after (TCQ)*1 ps;
               raddr_dly <= raddr after (TCQ)*1 ps;
            end if;		-- else: !if(reset_i)
         end if;
      end process;

      ren_int <= ren_dly;
      raddr_int <= raddr_dly;

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
               rdata_dly <= "000000000000000000000000000000000000000000000000000000000000000000000000" after (TCQ)*1 ps;
            else
               rdata_dly <= rdata_int after (TCQ)*1 ps;
            end if;		-- else: !if(reset_i)
         end if;
      end process;

      rdata <= rdata_dly;

   end generate;      -- block: rd_lat_data_3

   rdata_lat_1_2 : if (not(RAM_RDATA_LATENCY = 3)) generate
      rdata <= rdata_int after (TCQ)*1 ps;
   end generate;
   
   -- instantiate the brams
   brams : for i in 0 to  NUM_BRAMS - 1 generate

     ram : pcie_bram_v6
         generic map (
            DOB_REG  => DOB_REG,
            WIDTH    => BRAM_WIDTH
         )
         port map (
            user_clk_i  => user_clk_i,
            reset_i     => reset_i,
            wen_i       => wen_int,
            waddr_i     => waddr_int,
            wdata_i     => wdata_int((((i + 1) * BRAM_WIDTH) - 1) downto (i * BRAM_WIDTH)),
            ren_i       => ren_int,
            raddr_i     => raddr_int,
            rdata_o     => rdata_int((((i + 1) * BRAM_WIDTH) - 1) downto (i * BRAM_WIDTH)),
            rce_i       => rce
         );
   end generate;
   		-- pcie_brams_v6
end v6_pcie;


