------------------------------------------------------------------
-- Universal dongle board source code
-- 
-- Copyright (C) 2006 Artec Design <jyrit@artecdesign.ee>
-- 
-- This source code is free hardware; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
-- 
-- This source code is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
-- 
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
-- 
-- 
-- The complete text of the GNU Lesser General Public License can be found in 
-- the file 'lesser.txt'.



----------------------------------------------------------------------------------
-- Company: ArtecDesign
-- Engineer: Jüri Toomessoo 
-- 
-- Create Date:    12:57:23 28/02/2008 
-- Design Name:    Postcode serial pipe Hardware
-- Module Name:    pc_serializer - rtl 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pc_serializer is
    Port ( --system signals
         sys_clk : in  STD_LOGIC;
         resetn  : in  STD_LOGIC;		   
		   --postcode data port
         dbg_data : in  STD_LOGIC_VECTOR (7 downto 0);
         dbg_wr   : in  STD_LOGIC;   --write not read
		   dbg_full : out STD_LOGIC;   --write not read
		   dbg_almost_full	: out STD_LOGIC;
		   dbg_usedw		: out STD_LOGIC_VECTOR (12 DOWNTO 0);
		   --debug USB port
		   dbg_usb_mode_en: in   std_logic;  -- enable this debug mode
		   dbg_usb_wr     : out  std_logic;  -- write performed on edge \ of signal
		   dbg_usb_txe_n  : in   std_logic;  -- tx fifo not full (redy for new data if low)
		   dbg_usb_bd     : inout  std_logic_vector(7 downto 0) --bus data
);
		  
end pc_serializer;

architecture rtl of pc_serializer is

	component fifo
		PORT
		(
		aclr		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		almost_full		: OUT STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		usedw		: OUT STD_LOGIC_VECTOR (12 DOWNTO 0)

		);
	end component;



	--type state is (RESETs, HEXMARKs,MSNIBBLEs,LSNIBBLEs,LINEFDs,CRs,START_WRITEs,END_WRITEs,WAITs);  -- simple ASCII converter to USB fifo
	signal CS : std_logic_vector(8 downto 0);--state;
	signal RETS : std_logic_vector(8 downto 0); --state;
	signal next_char  : std_logic_vector(7 downto 0); --bus data
	signal ascii_char : std_logic_vector(7 downto 0); --bus data
	signal in_nibble  : std_logic_vector(3 downto 0); --bus data
	signal usb_send_char  : std_logic_vector(7 downto 0); --bus data
	
	signal count : std_logic_vector(3 downto 0); --internal counter
    signal dly_count : std_logic_vector(15 downto 0); --internal counter
	signal dbg_wr_pulse : std_logic; --active reset
	signal dbg_wrd : std_logic; --active reset
	signal dbg_wr_len : std_logic; --active reset
	signal usb_send   : std_logic; --active reset

	
	signal rdreq_sig    : std_logic; --active reset
	signal empty_sig    : std_logic; --active reset
	signal full_sig     : std_logic; --active reset
	signal almost_full     : std_logic; --active reset
	
	signal q_sig        : std_logic_vector(7 downto 0); --bus data
	
	signal reset    : std_logic; --active reset
	signal half_clk : std_logic; --active reset

      
   --RESETs, HEXMARKs,MSNIBBLEs,LSNIBBLEs,LINEFDs,CRs,START_WRITEs,END_WRITEs,WAITs
   constant  RESETs: std_logic_vector(8 downto 0)      := "000000001"; -- char /n
   constant  HEXMARKs: std_logic_vector(8 downto 0)    := "000000010"; -- char /n
   constant  MSNIBBLEs: std_logic_vector(8 downto 0)   := "000000100"; -- char /n
   constant  LSNIBBLEs: std_logic_vector(8 downto 0)   := "000001000"; -- char /n
   constant  LINEFDs: std_logic_vector(8 downto 0)     := "000010000"; -- char /n
   constant  CRs: std_logic_vector(8 downto 0)         := "000100000"; -- char /n
   constant  START_WRITEs: std_logic_vector(8 downto 0):= "001000000"; -- char /n
   constant  WAITs: std_logic_vector(8 downto 0)       := "010000000"; -- char /n
   constant  END_WRITEs: std_logic_vector(8 downto 0)  := "100000000"; -- char /n
   

	constant CHAR_LF : std_logic_vector(7 downto 0):= x"0A"; -- char /n
	constant CHAR_CR : std_logic_vector(7 downto 0):= x"0D"; -- char /n
	constant CHAR_SP : std_logic_vector(7 downto 0):= x"20"; -- space
	constant CHAR_ux : std_logic_vector(7 downto 0):= x"58"; -- fifo full hex marker --upper case x
	constant CHAR_x : std_logic_vector(7 downto 0):= x"78"; -- regular hex marker
	constant CHAR_0 : std_logic_vector(7 downto 0):= x"30";
	constant CHAR_1 : std_logic_vector(7 downto 0):= x"31";	
	constant CHAR_2 : std_logic_vector(7 downto 0):= x"32";
	constant CHAR_3 : std_logic_vector(7 downto 0):= x"33";
	constant CHAR_4 : std_logic_vector(7 downto 0):= x"34";
	constant CHAR_5 : std_logic_vector(7 downto 0):= x"35";		
	constant CHAR_6 : std_logic_vector(7 downto 0):= x"36";		
	constant CHAR_7 : std_logic_vector(7 downto 0):= x"37";		
	constant CHAR_8 : std_logic_vector(7 downto 0):= x"38";		
	constant CHAR_9 : std_logic_vector(7 downto 0):= x"39";		
	constant CHAR_a : std_logic_vector(7 downto 0):= x"41";		
	constant CHAR_b : std_logic_vector(7 downto 0):= x"42";		
	constant CHAR_c : std_logic_vector(7 downto 0):= x"43";		
	constant CHAR_d : std_logic_vector(7 downto 0):= x"44";		
	constant CHAR_e : std_logic_vector(7 downto 0):= x"45";				
	constant CHAR_f : std_logic_vector(7 downto 0):= x"46";		
				
	

begin

	ascii_char <=CHAR_0 when in_nibble = x"0" else
				CHAR_1 when in_nibble = x"1" else
				CHAR_2 when in_nibble = x"2" else
				CHAR_3 when in_nibble = x"3" else
				CHAR_4 when in_nibble = x"4" else
				CHAR_5 when in_nibble = x"5" else
				CHAR_6 when in_nibble = x"6" else
				CHAR_7 when in_nibble = x"7" else
				CHAR_8 when in_nibble = x"8" else
				CHAR_9 when in_nibble = x"9" else
				CHAR_a when in_nibble = x"a" else
				CHAR_b when in_nibble = x"b" else
				CHAR_c when in_nibble = x"c" else
				CHAR_d when in_nibble = x"d" else
				CHAR_e when in_nibble = x"e" else
				CHAR_f when in_nibble = x"f";
	


	dbg_usb_bd <= usb_send_char when dbg_usb_mode_en = '1' else
				  (others=>'Z');
				
	dbg_usb_wr <= usb_send when dbg_usb_mode_en = '1' else
				  'Z';

	SER_SM: process (sys_clk,resetn) 
	begin  -- process

	  if sys_clk'event and sys_clk = '1' then    -- rising clock edge
	  if resetn='0' then  --active low reset
		CS<= RESETs;
		in_nibble <= (others=>'0');
		usb_send_char <= (others=>'0');
        dly_count<= (others=>'0');
		usb_send <='0';
		RETS <= RESETs;
		rdreq_sig <='0';
		count<= (others=>'1');
      else
	    case CS is
	      when RESETs => ----------------------------------------------------------

			if empty_sig ='0' and dbg_usb_txe_n='0' and dbg_usb_mode_en='1'  then  --is, can and may send
					rdreq_sig <='1';
					count <= count + 1;
					RETS <= HEXMARKs;
					dly_count <= x"000F";
               		CS <= END_WRITEs; --cheat as 1 extra cycle is needed for fifo to output data
            else
               usb_send <='0';
               rdreq_sig <='0';            
               CS <= RESETs; --cheat as 1 extra cycle is needed for fifo to output data
			end if;
		  when HEXMARKs => ----------------------------------------------------------
				rdreq_sig <='0'; --data will be ready on output 'till next read request
				--if almost_full='0' then
				usb_send_char <= CHAR_x; --show fifo full status to user by hex x case
			   --else
				--	usb_send_char <= CHAR_ux; --show fifo full status to user by hex x case
				--end if;
				in_nibble <= q_sig(7 downto 4);	--take fifo output and put to decoder								
				RETS <= MSNIBBLEs;
				CS <= START_WRITEs;
		  when MSNIBBLEs => ----------------------------------------------------------
				usb_send_char <= ascii_char; --put MS nibble to output
				in_nibble <= q_sig(3 downto 0);	--take fifo output and put to decoder								
				RETS <= LSNIBBLEs;
				CS <= START_WRITEs;		
		  when LSNIBBLEs => ----------------------------------------------------------
				usb_send_char <= ascii_char; --put MS nibble to output							
				if count = x"f" then
					RETS <= CRs;
				else
					RETS <= LINEFDs;
				end if;
				CS <= START_WRITEs;	
		  when CRs => ----------------------------------------------------------
				--if count = x"f" then
				usb_send_char <= CHAR_CR; --put line feed
				--else
				--	usb_send_char <= CHAR_SP; --put space
				--end if;
				RETS <= LINEFDs;
				CS <= START_WRITEs;									
		  when LINEFDs => ----------------------------------------------------------
				if count = x"f" then
					usb_send_char <= CHAR_LF; --put line feed
				else
					usb_send_char <= CHAR_SP; --put space
				end if;
				RETS <= RESETs;
				CS <= START_WRITEs;				
			
 		  when START_WRITEs => ---------------------------------------------------------- 		
            if dly_count /= x"0004" then
			      if dbg_usb_txe_n='0' then    
                     usb_send <='1';
                     dly_count <= dly_count + 1;
				  else
					 usb_send <='0'; --remove send signal when txe is falsely asserted
               	  end if;
         	else
 				usb_send <='0';
                CS <= WAITs;
         	end if;
		   when WAITs => ---------------------------------------------------------- 
				usb_send <='0';
				CS <= END_WRITEs;		
 	      when END_WRITEs => ---------------------------------------------------------- 
			 rdreq_sig <='0'; --used as intermeadiate cheat state when exiting resets
             if dly_count /= x"000F" then
			      if dbg_usb_txe_n='0' then    
                     dly_count <= dly_count + 1;
	           	  end if;
         	 else
   		 		dly_count <= (others=>'0');
		     	CS <= RETS;
         	 end if;
  	      when others => null;            
	    end case; 
     end if;       
	  end if;
	end process SER_SM;


   SYNCER: process (sys_clk,resetn)  --make slower clock and 2 cycle write pulse
   begin  -- process
      if sys_clk'event and sys_clk = '1' then    -- rising clock edge
         if resetn='0' then  --active low reset
            dbg_wr_pulse <='0';
            dbg_wr_len <='0';
            dbg_wrd <='0';
         else
            dbg_wrd <= dbg_wr;
            if dbg_wrd='0' and dbg_wr='1' then -- rising front on fifo write
               dbg_wr_pulse <='1';
            else
               dbg_wr_pulse <='0';
            end if;
         end if;
      end if;		
   end process SYNCER;		


	reset <= not resetn;
	dbg_full <= full_sig;
	dbg_almost_full<= almost_full;
	fifo_inst : fifo PORT MAP (
			--system signals
			aclr	 => reset,
			clock	 => sys_clk,  --make serial back end work 2 times slower as FDTI chip max timing length is 80 ns
			-- push interface
			data	 => dbg_data,
			wrreq	 => dbg_wr_pulse,
			almost_full	 => almost_full,
			usedw	 => dbg_usedw,
			--pop interface
			rdreq	 => rdreq_sig,
			empty	 => empty_sig,
			full	 => full_sig,
			q	 	 => q_sig
		);




end rtl;

