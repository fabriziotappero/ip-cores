----------------------------------------------------------------------------------
-- Company:       VISENGI S.L. (www.visengi.com)
-- Engineer:      Victor Lopez Lorenzo (victor.lopez (at) visengi (dot) com)
-- 
-- Create Date:    23:44:13 22/August/2008 
-- Project Name:   Triple Port WISHBONE SPRAM Wrapper
-- Tool versions:  Xilinx ISE 9.2i
-- Description: 
--
-- Description: This is a wrapper for an inferred single port RAM, that converts it
--              into a Three-port RAM with one WISHBONE slave interface for each port. 
--
--
-- LICENSE TERMS: GNU LESSER GENERAL PUBLIC LICENSE Version 2.1
--     That is you may use it in ANY project (commercial or not) without paying a cent.
--     You are only required to include in the copyrights/about section of accompanying 
--     software and manuals of use that your system contains a "3P WB SPRAM Wrapper
--     (C) VISENGI S.L. under LGPL license"
--     This holds also in the case where you modify the core, as the resulting core
--     would be a derived work.
--     Also, we would like to know if you use this core in a project of yours, just an email will do.
--
--    Please take good note of the disclaimer section of the LPGL license, as we don't
--    take any responsability for anything that this core does.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity wb_Np_ram is
      generic (data_width : integer := 32;
					addr_width : integer := 8);
      port (
			wb_clk_i: in std_logic;
         wb_rst_i: in std_logic;
         
         wb1_cyc_i : in std_logic;
         wb1_stb_i : in std_logic;
         wb1_we_i : in std_logic;
         wb1_adr_i : in std_logic_vector(addr_width-1 downto 0);
         wb1_dat_i : in std_logic_vector(data_width-1 downto 0);
			wb1_dat_o : out std_logic_vector(data_width-1 downto 0);
         wb1_ack_o : out std_logic;
         
         wb2_cyc_i : in std_logic;
         wb2_stb_i : in std_logic;
         wb2_we_i : in std_logic;
         wb2_adr_i : in std_logic_vector(addr_width-1 downto 0);
         wb2_dat_i : in std_logic_vector(data_width-1 downto 0);
			wb2_dat_o : out std_logic_vector(data_width-1 downto 0);
         wb2_ack_o : out std_logic;
         
         wb3_cyc_i : in std_logic;
         wb3_stb_i : in std_logic;
         wb3_we_i : in std_logic;
         wb3_adr_i : in std_logic_vector(addr_width-1 downto 0);
         wb3_dat_i : in std_logic_vector(data_width-1 downto 0);
			wb3_dat_o : out std_logic_vector(data_width-1 downto 0);
         wb3_ack_o : out std_logic);
end wb_Np_ram;

architecture Behavioral of wb_Np_ram is
   component sp_ram is --uncomment to use an inferred spram
		generic (data_width : integer := 32;
					addr_width : integer := 8);
   --component sp_ram_core is --uncomment to use the coregen spram
		port (
			clka: IN std_logic;
			wea: IN std_logic_vector(0 downto 0);
			addra: IN std_logic_vector(addr_width-1 downto 0);
			dina: IN std_logic_vector(data_width-1 downto 0);
			douta: OUT std_logic_vector(data_width-1 downto 0));
   end component;
   
   signal we: std_logic_vector(0 downto 0);
   signal a : std_logic_vector(addr_width-1 downto 0);
   signal d,q : std_logic_vector(data_width-1 downto 0);
begin


	u_sp_ram : sp_ram --uncomment to use an inferred spram
		generic map (data_width,addr_width)
   --u_sp_ram : sp_ram_core  --uncomment to use the coregen spram
		port map (
			clka => wb_clk_i,
			wea => we,
			addra => a,
			dina => d,
			douta => q);	
	
   wb1_dat_o <= q;
   wb2_dat_o <= q;
   wb3_dat_o <= q;
   
   WB_interconnect: process (wb_clk_i, wb_rst_i)
      variable ack1, ack2, ack3 : std_logic;
      variable lock : integer;
      variable State : integer;
   begin
      if (wb_rst_i = '1') then
         we(0) <= '0';
         a <= (others => '0');
         d <= (others => '0');
         ack1 := '0';
         wb1_ack_o <= '0';
         ack2 := '0';
         wb2_ack_o <= '0';
         ack3 := '0';
         wb3_ack_o <= '0';
         
         lock := 0;
         State := 0;
      elsif (wb_clk_i = '1' and wb_clk_i'event) then
         --defaults (unless overriden afterwards)
         we(0) <= '0';
         
         case State is
            when 0 => --priority for wb1
               --unlockers
               if (lock = 1 and wb1_cyc_i = '0') then lock := 0; end if;
               if (lock = 2 and wb2_cyc_i = '0') then lock := 0; end if;
               if (lock = 3 and wb3_cyc_i = '0') then lock := 0; end if;
               
               if (wb1_cyc_i = '1' and (lock = 0 or lock=1)) then --lock request (grant if lock is available)
                  ack2 := '0';
                  ack3 := '0';
                  lock := 1;
                  if (wb1_stb_i = '1' and ack1 = '0') then --operation request
                     we(0) <= wb1_we_i;
                     a <= wb1_adr_i;
                     d <= wb1_dat_i;
                     if (wb1_we_i = '1') then
                        ack1 := '1'; --ack now and stay in this state waiting for new ops
                        State := 1;
                     else
                        State := 11; --wait one cycle for operation to end
                     end if;
                  else
                     ack1 := '0'; --force one cycle wait between operations
                     --or else the wb master could issue a write, then receive two acks (first legal ack and then
                     --a spurious one due to being in the cycle where the master is still reading the first ack)
                     --followed by a read and misinterpret the spurious ack as an ack for the read
                  end if;
               elsif (wb2_cyc_i = '1' and (lock = 0 or lock=2)) then --lock request (grant if lock is available)
                  ack1 := '0';
                  ack3 := '0';
                  lock := 2;
                  if (wb2_stb_i = '1' and ack2 = '0') then --operation request
                     we(0) <= wb2_we_i;
                     a <= wb2_adr_i;
                     d <= wb2_dat_i;
                     if (wb2_we_i = '1') then
                        ack2 := '1'; --ack now and stay in this state waiting for new ops
                        State := 2;
                     else
                        State := 12; --wait one cycle for operation to end
                     end if;
                  else
                     ack2 := '0'; --force one cycle wait between operations
                  end if;
               elsif (wb3_cyc_i = '1' and (lock = 0 or lock=3)) then --lock request (grant if lock is available)
                  ack1 := '0';
                  ack2 := '0';
                  lock := 3;
                  if (wb3_stb_i = '1' and ack3 = '0') then --operation request
                     we(0) <= wb3_we_i;
                     a <= wb3_adr_i;
                     d <= wb3_dat_i;
                     if (wb3_we_i = '1') then
                        ack3 := '1'; --ack now and stay in this state waiting for new ops
                        State := 0;
                     else
                        State := 13; --wait one cycle for operation to end
                     end if;
                  else
                     ack3 := '0'; --force one cycle wait between operations
                  end if;
               end if;

            when 1 => --priority for wb2 (same code as previous State but changing the order of the if...elsifs)
               --unlockers
               if (lock = 1 and wb1_cyc_i = '0') then lock := 0; end if;
               if (lock = 2 and wb2_cyc_i = '0') then lock := 0; end if;
               if (lock = 3 and wb3_cyc_i = '0') then lock := 0; end if;
               
               if (wb2_cyc_i = '1' and (lock = 0 or lock=2)) then --lock request (grant if lock is available)
                  ack1 := '0';
                  ack3 := '0';
                  lock := 2;
                  if (wb2_stb_i = '1' and ack2 = '0') then --operation request
                     we(0) <= wb2_we_i;
                     a <= wb2_adr_i;
                     d <= wb2_dat_i;
                     if (wb2_we_i = '1') then
                        ack2 := '1'; --ack now and stay in this state waiting for new ops
                        State := 2;
                     else
                        State := 12; --wait one cycle for operation to end
                     end if;
                  else
                     ack2 := '0'; --force one cycle wait between operations
                  end if;
               elsif (wb3_cyc_i = '1' and (lock = 0 or lock=3)) then --lock request (grant if lock is available)
                  ack1 := '0';
                  ack2 := '0';
                  lock := 3;
                  if (wb3_stb_i = '1' and ack3 = '0') then --operation request
                     we(0) <= wb3_we_i;
                     a <= wb3_adr_i;
                     d <= wb3_dat_i;
                     if (wb3_we_i = '1') then
                        ack3 := '1'; --ack now and stay in this state waiting for new ops
                        State := 0;
                     else
                        State := 13; --wait one cycle for operation to end
                     end if;
                  else
                     ack3 := '0'; --force one cycle wait between operations
                  end if;
               elsif (wb1_cyc_i = '1' and (lock = 0 or lock=1)) then --lock request (grant if lock is available)
                  ack2 := '0';
                  ack3 := '0';
                  lock := 1;
                  if (wb1_stb_i = '1' and ack1 = '0') then --operation request
                     we(0) <= wb1_we_i;
                     a <= wb1_adr_i;
                     d <= wb1_dat_i;
                     if (wb1_we_i = '1') then
                        ack1 := '1'; --ack now and stay in this state waiting for new ops
                        State := 1;
                     else
                        State := 11; --wait one cycle for operation to end
                     end if;
                  else
                     ack1 := '0'; --force one cycle wait between operations
                  end if;
               end if;

            when 2 => --priority for wb3 (same code as previous State but changing the order of the if...elsifs)
               --unlockers
               if (lock = 1 and wb1_cyc_i = '0') then lock := 0; end if;
               if (lock = 2 and wb2_cyc_i = '0') then lock := 0; end if;
               if (lock = 3 and wb3_cyc_i = '0') then lock := 0; end if;
               
               if (wb3_cyc_i = '1' and (lock = 0 or lock=3)) then --lock request (grant if lock is available)
                  ack1 := '0';
                  ack2 := '0';
                  lock := 3;
                  if (wb3_stb_i = '1' and ack3 = '0') then --operation request
                     we(0) <= wb3_we_i;
                     a <= wb3_adr_i;
                     d <= wb3_dat_i;
                     if (wb3_we_i = '1') then
                        ack3 := '1'; --ack now and stay in this state waiting for new ops
                        State := 0;
                     else
                        State := 13; --wait one cycle for operation to end
                     end if;
                  else
                     ack3 := '0'; --force one cycle wait between operations
                  end if;
               elsif (wb1_cyc_i = '1' and (lock = 0 or lock=1)) then --lock request (grant if lock is available)
                  ack2 := '0';
                  ack3 := '0';
                  lock := 1;
                  if (wb1_stb_i = '1' and ack1 = '0') then --operation request
                     we(0) <= wb1_we_i;
                     a <= wb1_adr_i;
                     d <= wb1_dat_i;
                     if (wb1_we_i = '1') then
                        ack1 := '1'; --ack now and stay in this state waiting for new ops
                        State := 1;
                     else
                        State := 11; --wait one cycle for operation to end
                     end if;
                  else
                     ack1 := '0'; --force one cycle wait between operations
                  end if;
               elsif (wb2_cyc_i = '1' and (lock = 0 or lock=2)) then --lock request (grant if lock is available)
                  ack1 := '0';
                  ack3 := '0';
                  lock := 2;
                  if (wb2_stb_i = '1' and ack2 = '0') then --operation request
                     we(0) <= wb2_we_i;
                     a <= wb2_adr_i;
                     d <= wb2_dat_i;
                     if (wb2_we_i = '1') then
                        ack2 := '1'; --ack now and stay in this state waiting for new ops
                        State := 2;
                     else
                        State := 12; --wait one cycle for operation to end
                     end if;
                  else
                     ack2 := '0'; --force one cycle wait between operations
                  end if;
               end if;               

            when 11 =>
               ack1 := '1'; --ack operation
               ack2 := '0';
               ack3 := '0';
               State := 1;
            when 12 =>
               ack1 := '0';
               ack2 := '1'; --ack operation
               ack3 := '0';
               State := 2;
            when 13 =>
               ack1 := '0';
               ack2 := '0';
               ack3 := '1'; --ack operation
               State := 0;
               
            when others => --sanity
               ack1 := '0';
               ack2 := '0';
               ack3 := '0';
               State := 0;
         end case;
         
         wb1_ack_o <= (ack1 and wb1_stb_i and wb1_cyc_i); --to don't ack aborted operations
         wb2_ack_o <= (ack2 and wb2_stb_i and wb2_cyc_i); --to don't ack aborted operations
         wb3_ack_o <= (ack3 and wb3_stb_i and wb3_cyc_i); --to don't ack aborted operations
      end if;   
   end process WB_interconnect;
end Behavioral;

