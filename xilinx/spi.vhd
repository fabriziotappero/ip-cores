-------------------------------------------------------------------------------
--	MiniGA
--  Author: Thomas Pototschnig (thomas.pototschnig@gmx.de)
--
--  License: Creative Commons Attribution-NonCommercial-ShareAlike 2.0 License
--           http://creativecommons.org/licenses/by-nc-sa/2.0/de/
--
--  If you want to use MiniGA for commercial purposes please contact the author
-------------------------------------------------------------------------------
-- spi interface 
-- very slow because this component is crap!
-- reason: tried to implement a shift register which gets the clock from SCK
-- but this makes a lot harder. Next version will sample the SPI pins

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity spi is
	port (
		clk : in std_logic;
		reset : in std_logic;
		spi_ss : in std_logic;
		spi_clk : in std_logic;
		spi_data : in std_logic;
		spi_cd : in std_logic;
		
		out_adr : out std_logic_vector (18 downto 0);
		out_data : out std_logic_vector (15 downto 0);
		out_wr : out std_logic;
		testbild_en : out std_logic
	);
end spi;

architecture behaviour of spi is
signal rcvd_flag : std_logic;
signal rcvd_data : std_logic_vector (15 downto 0);
signal rcvd_cd : std_logic;
signal ack : std_logic;

begin

	process (spi_ss, spi_clk, ack, reset)
	variable ctr : integer := 0;
	variable data : std_logic_vector (15 downto 0);
	begin
		if spi_ss='1' or ack='0' or reset='0' then
			ctr := 0;
			rcvd_flag <= '0';
		elsif spi_clk'event and spi_clk='1' then
			if ctr /= 16 then -- braucht man nicht - aber erstmal testen wie simuliert
				data(15-ctr):=spi_data;
				ctr:=ctr+1;
				if ctr = 16 then
					rcvd_data <= data;
					rcvd_flag <= '1';
					rcvd_cd <= spi_cd;
					ctr := 0;
				end if;
			end if;
		end if;	
	end process;
	
	process (clk, reset)
	variable state : integer := 0;
	variable adr : unsigned (18 downto 0);
	variable cmd : integer := 0;
	begin
		if reset='0' then
			state := 0;
			adr := conv_unsigned(0,19);
			out_adr <= (others => '0');
			out_data <= (others => '0');
			out_wr <= '1';
			ack <= '1';
			testbild_en <= '1';
		elsif clk'event and clk='1' then
			case state is
				when 0 =>	-- etwas per spi empfangen?
					if rcvd_flag = '1' then
						state:=1;
					end if;
				when 1 =>	-- ja - dann adr und data ausgeben und schreiben aktivieren
					ack <= '0'; -- spi resetten

					out_adr <= conv_std_logic_vector(adr,19);
					adr := adr + 1;

					if rcvd_cd='0' then	-- datum empfangen
						out_data <= rcvd_data;
						out_wr <= '0';
					else				-- commando empfangen
						cmd := conv_integer(rcvd_data (15 downto 10));
						case cmd is
							when 1 => -- low-byte der adresse
								adr (9 downto 0) := unsigned(rcvd_data(9 downto 0));
							when 2 => -- high-byte der adresse
								adr (18 downto 10) := unsigned(rcvd_data (8 downto 0));
							when 3 => -- testbild an / aus
								testbild_en <= rcvd_data(0);
							when others =>
						end case;
					end if;

					state := 2;
					
				when 2 =>	-- jetzt wurde das zeugs geschrieben
					ack <= '1';
					out_wr <= '1';
					state := 0;
				when others =>
					state:=0;
			end case;		
		end if;
	end process;
	
end architecture;
