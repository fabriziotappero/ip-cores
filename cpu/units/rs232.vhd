----------------------------------------------------------------------------------
-- Company:        Fachhochschule Augsburg - Fakultät für Informatik
-- Engineer:       Schäferling Michael
-- 
-- Create Date:    23:34:55 02/27/2007 
-- Design Name:    
-- Module Name:    rs232 - Behavioral 
-- Project Name:   
-- Target Devices: Xilinx
-- Tool versions:  
-- Description:    This module provides RS232 communication
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

entity rs232 is
  generic(DATABITS:  integer:= 8;
			 STARTBITS: integer:= 1;
			 STOPBITS:  integer:= 1
  );
  
  port( -- HW signalling 
			CLK_50MHZ	 : in  std_logic;
			RS232_RXD: in  std_logic;
			RS232_TXD: out std_logic := '1';
		  
		  -- internal DataCom
			DATA_TX		 : in  std_logic_vector(DATABITS-1 downto 0);
			TX_SEND_DATA : in  std_logic;
			TX_BUSY		 : out std_logic := '0';
			
			DATA_RX		 : out std_logic_vector(DATABITS-1 downto 0) := (others => '0');
			RX_DATA_RCVD : out std_logic := '0';
			RX_BUSY		 : out std_logic := '0'
  );
end rs232;



architecture Behavioral of rs232 is

type SER_STATES is (IDLE, SYN, B0, B1, B2, B3, B4, B5, B6, B7, VALID);

signal SER_STATE: SER_STATES := IDLE;


signal CLK_38400: std_logic := '0';
signal SIG_RST_TSER2: std_logic := '0';
signal SIG_TSER2: std_logic := '0';

signal SIG_RST_TSER: std_logic := '0';
signal SIG_TSER: std_logic := '0';


begin



-- Generate Signal for Serial Clock at 38400
P_GEN_CLK38400: process (CLK_50MHZ)
-- 1302 == 10100010110
constant CLK38400_MAX: std_logic_vector(10 downto 0) := "10100010110";
variable CLK38400_CUR: std_logic_vector(10 downto 0) := "00000000000";
begin
  if CLK_50MHZ'event AND CLK_50MHZ='1' then
  	 if CLK38400_CUR = CLK38400_MAX then
	   CLK38400_CUR := (others => '0');
		CLK_38400 <= '1';
	 else
	   CLK38400_CUR := CLK38400_CUR + "00000000001";
		CLK_38400 <= '0';
	 end if;
  end if;
end process P_GEN_CLK38400;



-- Generate Reset-driven Signal after Tser/2
P_GEN_SIG_TSER2: process (CLK_50MHZ)
-- 651 == 1010001011
constant TSER2_MAX: std_logic_vector(9 downto 0) := "1010001011";
variable TSER2_CUR: std_logic_vector(9 downto 0) := "0000000000";
begin
  if CLK_50MHZ'event AND CLK_50MHZ='1' then
  	 if SIG_RST_TSER2 = '1' then
		SIG_TSER2 <= '0';
	   TSER2_CUR := (others => '0');
	 elsif TSER2_CUR = TSER2_MAX then
	   SIG_TSER2 <= '1';
		TSER2_CUR := (others => '0');
	 else
		SIG_TSER2 <= '0';
	   TSER2_CUR := TSER2_CUR + "0000000001";
	 end if;
  end if;
end process P_GEN_SIG_TSER2;



-- Generate Reset-driven Signal after Tser
P_GEN_SIG_TSER: process (CLK_50MHZ)
constant TSER_MAX: std_logic_vector(10 downto 0) := "10100010110";
variable TSER_CUR: std_logic_vector(10 downto 0) := "00000000000";
begin
  if CLK_50MHZ'event AND CLK_50MHZ='1' then
  	 if SIG_RST_TSER = '1' then
		SIG_TSER <= '0';
	   TSER_CUR := (others => '0');
	 elsif TSER_CUR = TSER_MAX then
		SIG_TSER <= '1';
	   TSER_CUR := (others => '0');
	 else
		SIG_TSER <= '0';
	   TSER_CUR := TSER_CUR + "00000000001";
	 end if;
  end if;
end process P_GEN_SIG_TSER;



-- RX / TX Process
P_RX_TX: process (CLK_50MHZ) 
constant TOKENSIZE: integer:= STARTBITS + DATABITS + STOPBITS;

-- variables for RX
variable BYTE_RX: std_logic_vector(7 downto 0);
  -- for testing
variable signcount: std_logic_vector(3 downto 0) := "0000";

-- variables for TX
variable SEND_TOKEN: std_logic := '0';
variable TOKEN_OUT: std_logic_vector(TOKENSIZE-1 downto 0); 
variable COUNT: std_logic_vector(3 downto 0) := "0000";

begin
  if CLK_50MHZ'event AND CLK_50MHZ='1' then
 -- RX
	 RX_BUSY <= '1';
    case SER_STATE is
	   when IDLE =>   if RS232_RXD = '0' then 
								SIG_RST_TSER2 <= '1';
								SER_STATE <= SYN;
								RX_DATA_RCVD <= '0';
							else 
								RX_BUSY <= '0';
								SIG_RST_TSER2 <= '0';
								SER_STATE <= IDLE;
								RX_DATA_RCVD <= '0';
							end if;
		when SYN  =>   if SIG_TSER2 = '1' then
								SIG_RST_TSER2 <= '0';
								SIG_RST_TSER <= '1';
								SER_STATE <= B0;
							else 
								SIG_RST_TSER2 <= '0';
								SIG_RST_TSER <= '0';
								SER_STATE <= SYN;
							end if;
		when B0   =>   if SIG_TSER = '1' then
								SIG_RST_TSER <= '0';
								SER_STATE <= B1;
								BYTE_RX := RS232_RXD & BYTE_RX(7 downto 1);
							else 
								SIG_RST_TSER <= '0';
								SER_STATE <= B0;
							end if;
		when B1   =>   if SIG_TSER = '1' then
								SER_STATE <= B2;
								BYTE_RX := RS232_RXD & BYTE_RX(7 downto 1);
							else SER_STATE <= B1;
							end if;
		when B2   =>   if SIG_TSER = '1' then
								SER_STATE <= B3;
								BYTE_RX := RS232_RXD & BYTE_RX(7 downto 1);
							else SER_STATE <= B2;
							end if;
		when B3   =>   if SIG_TSER = '1' then
								SER_STATE <= B4;
								BYTE_RX := RS232_RXD & BYTE_RX(7 downto 1);
							else SER_STATE <= B3;
							end if;
		when B4   =>   if SIG_TSER = '1' then
								SER_STATE <= B5;
								BYTE_RX := RS232_RXD & BYTE_RX(7 downto 1);
							else SER_STATE <= B4;
							end if;
		when B5   =>   if SIG_TSER = '1' then
								SER_STATE <= B6;
								BYTE_RX := RS232_RXD & BYTE_RX(7 downto 1);
							else SER_STATE <= B5;
							end if;
		when B6   =>   if SIG_TSER = '1' then
								SER_STATE <= B7;
								BYTE_RX := RS232_RXD & BYTE_RX(7 downto 1);
							else SER_STATE <= B6;
							end if;
		when B7   =>   if SIG_TSER = '1' then
								SER_STATE <= VALID;
								BYTE_RX := RS232_RXD & BYTE_RX(7 downto 1);
							else SER_STATE <= B7;
							end if;
		when VALID =>  if SIG_TSER = '1' then
								if RS232_RXD = '1' then
									DATA_RX <= BYTE_RX;
									RX_DATA_RCVD <= '1';
								else 
								   DATA_RX <= (others => '0');
									RX_DATA_RCVD <= '0';
								end if;
								SER_STATE <= IDLE;
							else
								SER_STATE <= VALID;
							end if;
		end case;

  
 -- TX
		TX_BUSY <= '0';
      if TX_SEND_DATA = '1' AND SEND_TOKEN = '0' then
		  TOKEN_OUT := '1' & DATA_TX & '0';
		  SEND_TOKEN := '1';
		end if;
		
		if SEND_TOKEN = '1' then
			TX_BUSY <= '1';
			if CLK_38400 = '1' then
		      if COUNT < TOKENSIZE then
		         --TX_BUSY <= '1';
		         COUNT := COUNT + "0001";
					-- send from right to left (LSB first)
               RS232_TXD <= TOKEN_OUT(0);
	            TOKEN_OUT(TOKENSIZE-1 downto 0) := TOKEN_OUT(0) & TOKEN_OUT(TOKENSIZE-1 downto 1);
	         else
		         COUNT := "0000";
					SEND_TOKEN := '0';
					--TX_BUSY <= '0';
	         end if;
			end if;
		--else
			--TX_BUSY <= '0';
	   end if;
   end if;
end process P_RX_TX;

end Behavioral;
