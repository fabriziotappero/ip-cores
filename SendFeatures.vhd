----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:14:03 11/05/2008 
-- Design Name: 
-- Module Name:    SendFeatures - Behavioral 
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

entity SendFeatures is
    Port ( features : in  STD_LOGIC_VECTOR (34 downto 0);
           fsync	 : in STD_LOGIC;
			  wstrobe : in  STD_LOGIC;
			  ready : out STD_LOGIC;
           clk : in  STD_LOGIC;
			  reset : in STD_LOGIC;
           RX_DATA : in  STD_LOGIC;
           RTS_IN : in  STD_LOGIC;
           DSR_OUT : out  STD_LOGIC;
           TX_DATA : out  STD_LOGIC;
           CTS_OUT : out  STD_LOGIC);
end SendFeatures;

architecture Behavioral of SendFeatures is

	signal transdata   : std_logic_vector(7 downto 0); 	-- Data to be transmitted
	signal wr			: std_logic; 							-- write strobe
	signal tbe			: std_logic;							-- transmitt buffer empty
	
	type state_type is (idle, sendB1_A, sendB1_B, sendB1_C, sendB2_A, sendB2_B, sendB2_C, 
							sendB3_A, sendB3_B, sendB3_C, sendB4_A, sendB4_B, sendB4_C, sendB5_A, 
							sendB5_B, sendB5_C); --state declaration
							
	signal state : state_type := idle;
	signal firstByteInFrame : std_logic := '0';
	signal data_vector : std_logic_vector(34 downto 0);
	signal recdata : std_logic_vector(7 downto 0);
	
begin

serial : entity work.UARTcomponent port map (
			TXD => TX_DATA,				-- Transmitted serial data output
    		RXD => RX_DATA,				-- Received serial data input
    		CLK => clk,						-- Clock signal
			DBIN 	=> transdata,		   -- Input parallel data to be transmitted
		 	DBOUT => recdata,  			-- Recevived parallel data output
		 	RDA => open,					-- Read Data Available
		 	TBE => tbe,					   -- Transfer Buffer Emty
		 	RD	 => '0',					
		 	WR	 => wr,					
		 	PE	 => open,					-- Parity error		
		 	FE	 => open,					-- Frame error
		 	OE	 => open,					-- Overwrite error
		 	RST => reset		);			-- Reset signal
			
			DSR_OUT <= '1';
			CTS_OUT <= RTS_IN;

sendStates: process(clk,reset) 
	-- This process 
	
begin		

	if reset = '1' then
		state <= idle;
	elsif clk'event and clk = '1' then
		case state is
		
			when idle => -- Waiting for the feature vector to be ready and the wstrobe
				if fsync = '1' then
					firstByteInFrame <= '1'; -- The most significant bit is set for
				end if;						-- the first byte in the first feature vector for all frames.
										   -- This bit is thus used for frame syncronization with the 
											-- recieving unit on the serial RS232 link.
				ready <= '1';
				if wstrobe = '1' then
					state <= sendB1_A;
					data_vector <= features;
				end if;
				
			when sendB1_A => -- Send first byte for feature vector
				ready <= '0';
				if tbe = '1' then
					state <= sendB1_B;
				end if;
			when sendB1_B =>
					state <= sendB1_C;
			when sendB1_C =>
				if tbe = '1' then
					state <= sendB2_A;
					firstByteInFrame <= '0';
				end if;	
				
			when sendB2_A => -- Send second byte for feature vector
				ready <= '0';
				if tbe = '1' then
					state <= sendB2_B;
				end if;
			when sendB2_B =>
					state <= sendB2_C;
			when sendB2_C =>
				if tbe = '1' then
					state <= sendB3_A;
				end if;	

			when sendB3_A => -- Send third byte for feature vector
				ready <= '0';
				firstByteInFrame <= '0';
				if tbe = '1' then
					state <= sendB3_B;
				end if;
			when sendB3_B =>
					state <= sendB3_C;
			when sendB3_C =>
				if tbe = '1' then
					state <= sendB4_A;
				end if;		
			
			when sendB4_A => -- Send fourth byte for feature vector
				ready <= '0';
				firstByteInFrame <= '0';
				if tbe = '1' then
					state <= sendB4_B;
				end if;
			when sendB4_B =>
					state <= sendB4_C;
			when sendB4_C =>
				if tbe = '1' then
					state <= sendB5_A;
				end if;		
				
			when sendB5_A => -- Send fifth byte for feature vector
				ready <= '0';
				firstByteInFrame <= '0';
				if tbe = '1' then
					state <= sendB5_B;
				end if;
			when sendB5_B =>
					state <= sendB5_C;
			when sendB5_C =>
				if tbe = '1' then
					state <= idle;
				end if;			

		end case;
		

	end if; -- of synchronous part
end process; -- sendStates

sendOut: process(state)
begin
	case state is
		when idle =>
			wr <= '0';
			transdata <= firstByteInFrame&data_vector(34 downto 28);
			
		when sendB1_A => --- Send first byte -----------------
			transdata <= firstByteInFrame&data_vector(34 downto 28);
			wr <= '0';
		when sendB1_B => -- Activate strobe 
		   transdata <= firstByteInFrame&data_vector(34 downto 28);
			wr <= '1';
		when sendB1_C =>
			transdata <= firstByteInFrame&data_vector(34 downto 28);
			wr <= '0';
		
		when sendB2_A => --- Send second byte -----------------
			transdata <= firstByteInFrame&data_vector(27 downto 21);
			wr <= '0';
		when sendB2_B => -- Activate strobe 
		   transdata <= firstByteInFrame&data_vector(27 downto 21);
			wr <= '1';
		when sendB2_C =>
			transdata <= firstByteInFrame&data_vector(27 downto 21);
			wr <= '0';
			
		when sendB3_A => --- Send third byte -----------------
			transdata <= firstByteInFrame&data_vector(20 downto 14);
			wr <= '0';
		when sendB3_B => -- Activate strobe 
		   transdata <= firstByteInFrame&data_vector(20 downto 14);
			wr <= '1';
		when sendB3_C =>
			transdata <= firstByteInFrame&data_vector(20 downto 14);
			wr <= '0';
		
		when sendB4_A => --- Send fourth byte -----------------
			transdata <= firstByteInFrame&data_vector(13 downto 7);
			wr <= '0';
		when sendB4_B => -- Activate strobe 
		   transdata <= firstByteInFrame&data_vector(13 downto 7);
			wr <= '1';
		when sendB4_C =>
			transdata <= firstByteInFrame&data_vector(13 downto 7);
			wr <= '0';
		
		when sendB5_A => --- Send fifth byte -----------------
			transdata <= firstByteInFrame&data_vector(6 downto 0);
			wr <= '0';
		when sendB5_B => -- Activate strobe 
		   transdata <= firstByteInFrame&data_vector(6 downto 0);
			wr <= '1';
		when sendB5_C =>
			transdata <= firstByteInFrame&data_vector(6 downto 0);
			wr <= '0';
			
		when others =>
			wr <= '0';
			transdata <= firstByteInFrame&data_vector(34 downto 28);
	end case;
end process; -- sendOut

end Behavioral;

