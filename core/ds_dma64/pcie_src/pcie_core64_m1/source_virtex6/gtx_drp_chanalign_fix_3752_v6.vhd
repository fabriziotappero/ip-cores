
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
-- File       : gtx_drp_chanalign_fix_3752_v6.vhd
-- Version    : 2.3
---- Description: Virtex6 Workaround for deadlock due lane-lane skew Bug
----
----
----
----------------------------------------------------------------------------------

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_unsigned.all;

entity GTX_DRP_CHANALIGN_FIX_3752_V6 is
   generic (
      C_SIMULATION                              : integer := 0    -- Set to 1 for simulation

   );
   port (
      dwe                                       : out std_logic;
      din                                       : out std_logic_vector(15 downto 0);      --THIS IS THE INPUT TO THE DRP
      den                                       : out std_logic;
      daddr                                     : out std_logic_vector(7 downto 0);
      drpstate                                  : out std_logic_vector(3 downto 0);      --DEBUG
      write_ts1                                 : in std_logic;
      write_fts                                 : in std_logic;
      dout                                      : in std_logic_vector(15 downto 0);      --THIS IS THE OUTPUT OF THE DRP
      drdy                                      : in std_logic;
      Reset_n                                   : in std_logic;
      drp_clk                                   : in std_logic
   );
end GTX_DRP_CHANALIGN_FIX_3752_V6;

architecture v6_pcie of GTX_DRP_CHANALIGN_FIX_3752_V6 is

   constant TCQ                      : integer := 1;
   constant DRP_IDLE_FTS             : std_logic_vector(3 downto 0) := "0001";
   constant DRP_IDLE_TS1             : std_logic_vector(3 downto 0) := "0010";
   constant DRP_RESET                : std_logic_vector(3 downto 0) := "0011";
   constant DRP_WRITE_FTS            : std_logic_vector(3 downto 0) := "0110";
   constant DRP_WRITE_DONE_FTS       : std_logic_vector(3 downto 0) := "0111";
   constant DRP_WRITE_TS1            : std_logic_vector(3 downto 0) := "1000";
   constant DRP_WRITE_DONE_TS1       : std_logic_vector(3 downto 0) := "1001";
   constant DRP_COM                  : std_logic_vector(9 downto 0) := "0110111100";
   constant DRP_FTS                  : std_logic_vector(9 downto 0) := "0100111100";
   constant DRP_TS1                  : std_logic_vector(9 downto 0) := "0001001010";

   signal next_daddr                              : std_logic_vector(7 downto 0);
   signal next_drpstate                           : std_logic_vector(3 downto 0);
   signal write_ts1_gated                         : std_logic;
   signal write_fts_gated                         : std_logic;

   -- Declare intermediate signals for referenced outputs
   signal daddr_v6pcie                           : std_logic_vector(7 downto 0);
   signal drpstate_v6pcie                        : std_logic_vector(3 downto 0);

begin
   -- Drive referenced outputs
   daddr <= daddr_v6pcie;
   drpstate <= drpstate_v6pcie;

   process (drp_clk)
   begin
      if (drp_clk'event and drp_clk = '1') then

         if ((not(Reset_n)) = '1') then

            daddr_v6pcie <= X"08" after (TCQ)*1 ps;
            drpstate_v6pcie <= DRP_RESET after (TCQ)*1 ps;

            write_ts1_gated <= '0' after (TCQ)*1 ps;
            write_fts_gated <= '0' after (TCQ)*1 ps;

         else

            daddr_v6pcie <= next_daddr after (TCQ)*1 ps;
            drpstate_v6pcie <= next_drpstate after (TCQ)*1 ps;

            write_ts1_gated <= write_ts1 after (TCQ)*1 ps;
            write_fts_gated <= write_fts after (TCQ)*1 ps;

         end if;

      end if;

   end process;


   process (drpstate_v6pcie, daddr_v6pcie, drdy, write_ts1_gated, write_fts_gated)
   begin

      -- DEFAULT CONDITIONS
      next_drpstate <= drpstate_v6pcie;
      next_daddr <= daddr_v6pcie;
      den <= '0';
      din <= (others => '0');
      dwe <= '0';

      case drpstate_v6pcie is

         -- RESET CONDITION, WE NEED TO READ THE TOP 6 BITS OF THE DRP REGISTER WHEN WE GET THE WRITE FTS TRIGGER
         when DRP_RESET =>
            next_drpstate <= DRP_WRITE_TS1;
            next_daddr <= X"08";

         -- WRITE FTS SEQUENCE
         when DRP_WRITE_FTS =>
            den <= '1';
            dwe <= '1';
            if (daddr_v6pcie = X"08") then
               din <= X"FD3C";
            elsif (daddr_v6pcie = X"09") then
               din <= X"C53C";
            elsif (daddr_v6pcie = X"0A") then
               din <= X"FDBC";
            elsif (daddr_v6pcie = X"0B") then
               din <= X"853C";
            end if;
            next_drpstate <= DRP_WRITE_DONE_FTS;

         -- WAIT FOR FTS SEQUENCE WRITE TO FINISH, ONCE WE FINISH ALL WRITES GO TO FTS IDLE
         when DRP_WRITE_DONE_FTS =>
            if (drdy = '1') then
               if (daddr_v6pcie = X"0B") then
                  next_drpstate <= DRP_IDLE_FTS;
                  next_daddr <= X"08";
               else
                  next_drpstate <= DRP_WRITE_FTS;
                  next_daddr <= daddr_v6pcie + X"01";
               end if;
            end if;

         -- FTS IDLE: WAIT HERE UNTIL WE NEED TO WRITE TS1
         when DRP_IDLE_FTS =>
            if (write_ts1_gated = '1') then
               next_drpstate <= DRP_WRITE_TS1;
               next_daddr <= X"08";
            end if;

         -- WRITE TS1 SEQUENCE
         when DRP_WRITE_TS1 =>
            den <= '1';
            dwe <= '1';
            if (daddr_v6pcie = X"08") then
               din <= X"FC4A";
            elsif (daddr_v6pcie = X"09") then
               din <= X"DC4A";
            elsif (daddr_v6pcie = X"0A") then
               din <= X"C04A";
            elsif (daddr_v6pcie = X"0B") then
               din <= X"85BC";
            end if;
            next_drpstate <= DRP_WRITE_DONE_TS1;

         -- WAIT FOR TS1 SEQUENCE WRITE TO FINISH, ONCE WE FINISH ALL WRITES GO TO TS1 IDLE
         when DRP_WRITE_DONE_TS1 =>
            if (drdy = '1') then
               if (daddr_v6pcie = X"0B") then
                  next_drpstate <= DRP_IDLE_TS1;
                  next_daddr <= X"08";
               else
                  next_drpstate <= DRP_WRITE_TS1;
                  next_daddr <= daddr_v6pcie + X"01";
               end if;
            end if;

         -- TS1 IDLE: WAIT HERE UNTIL WE NEED TO WRITE FTS
         when DRP_IDLE_TS1 =>
            if (write_fts_gated = '1') then
               next_drpstate <= DRP_WRITE_FTS;
               next_daddr <= X"08";
            end if;
        when others =>
               next_drpstate <= DRP_RESET;
               next_daddr <= X"00";
      end case;
   end process;


end v6_pcie;



