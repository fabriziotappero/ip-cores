--
--
--		address map:
--
--			0	SS Register
--			1	SCLK Divider
--			2	Data in
--			3	Data out
--			4	Interrupt Config Status
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.jop_types.all;

entity sc_spi is

generic (addr_bits : integer;
	clk_freq : integer);
port (
	clk		: in std_logic;
	reset	: in std_logic;

-- SimpCon interface

	address		: in std_logic_vector(addr_bits-1 downto 0);
	wr_data		: in std_logic_vector(31 downto 0);
	rd, wr		: in std_logic;
	rd_data		: out std_logic_vector(31 downto 0);
	rdy_cnt		: out unsigned(1 downto 0);

-- SPI Con

	slave_s	: out std_logic_vector(7 downto 0);
	miso	: in std_logic;
	mosi	: out std_logic;
	sclk	: out std_logic;

);
end sc_spi;

architecture rtl of sc_spi is

	signal spi_out		: std_logic_vector(7 downto 0);
	signal spi_in		: std_logic_vector(7 downto 0);

	signal read_ack		: std_logic;
	signal fifo_wr	: std_logic;

--
--	
	constant WS		: integer := (clk_freq/20000000)+1;
	signal cnt			: integer range 0 to WS;

--
--	FIFO signals
--
	signal tf_dout		: std_logic_vector(7 downto 0); -- fifo out
	signal tf_rd		: std_logic;
	signal tf_empty		: std_logic;
	signal tf_full		: std_logic;

	signal rf_din		: std_logic_vector(7 downto 0); -- fifo input
	signal rf_wr		: std_logic;
	signal rf_empty		: std_logic;
	signal rf_full		: std_logic;


--
--	USB interface signals
--
	type state_type		is (idle, inact, rx1, rx2, tx1, tx2);
	signal state 		: state_type;

	signal spi_dout		: std_logic_vector(7 downto 0);
	signal spi_din		: std_logic_vector(7 downto 0);

	--signal nrxf_buf		: std_logic_vector(1 downto 0);
	--signal ntxe_buf		: std_logic_vector(1 downto 0);
	--signal rdr, wrr		: std_logic_vector(7 downto 0);
	--signal data_oe		: std_logic;

begin

	rdy_cnt <= "00";	-- no wait states
	rd_data(31 downto 8) <= std_logic_vector(to_unsigned(0, 24));
--
--	The registered MUX is all we need for a SimpCon read.
--	The read data is stored in registered rd_data.
--
process(clk, reset)
begin

	if (reset='1') then
		rd_data(7 downto 0) <= (others => '0');
	elsif rising_edge(clk) then

		read_ack <= '0';
		if rd='1' then
			case address(2 downto 0) is
				when "000" =>
					rd_data(7 downto 0) <= slave_s;
					rd_data(31 downto 8) <= (others => '0');
				when "001" =>
					rd_data(7 downto 0) <= WS;
					rd_data(31 downto 8) <= (others => '0');
				when "010" =>
					rd_data(7 downto 0) <= spi_din;
					rd_data(31 downto 8) <= (others => '0');
				when "011" =>
					rd_data(7 downto 0) <= spi_dout;
					rd_data(31 downto 8) <= (others => '0');	
				when "100" =>
					rd_data(7 downto 0) <= spi_dout;
					rd_data(31 downto 8) <= (others => '0');						
--				when "111" =>
				when others =>
					rd_data(0) <= '0';
					rd_data(31 downto 1) <= (others => '0');
			end case;
		end if;
	end if;

			if wr='1' then
			case address(2 downto 0) is
				when "000" =>
					irq_in.irq_ena <= wr_data(0);
				when "001" =>
					irq_cnt <= wr_data;
					int_ack <= '1';
				when "010" =>
					spi_din <= wr_data;;
				when "011" =>
					spi_dout <= wr_data;;
				when "100" =>
					spi_dout <= wr_data;;
				when "110" =>
					-- nothing, processor id is read only
				when others =>
--				when "111" =>
					sync_in.s_in <= wr_data(0);
			end case;
		end if;
	
end process;


	-- we don't use the send immediate
	nsi <= '1';


--
--	receive fifo
--
	rxfifo: entity work.fifo generic map (
				width => 8,
				depth => 4,
				thres => 2	-- we don't care about the half signal
			) port map (
				clk => clk,
				reset => reset,
				din => rf_din,
				dout => usb_dout,
				rd => read_ack,
				wr => rf_wr,
				empty => rf_empty,
				full => rf_full,
				half => open
			);

--
--	transmit fifo
--
	txfifo: entity work.fifo generic map (
				width => 8,
				depth => 4,
				thres => 2	-- we don't care about the half signal
			) port map (
				clk => clk,
				reset => reset,
				din => wr_data(7 downto 0),
				dout => tf_dout,
				rd => tf_rd,
				wr => fifo_wr,
				empty => tf_empty,
				full => tf_full,
				half => open
			);


--
--	state machine for the usb bus
--
process(clk, reset)

begin

	if (reset='1') then
		state <= idle;
		nrxf_buf <= "11";
		ntxe_buf <= "11";
		cnt <= WS;

		rdr <= (others => '0');
		wrr <= (others => '0');

		tf_rd <= '0';
		rf_wr <= '0';

		nrd <= '1';
		ft_wr <= '0';

	elsif rising_edge(clk) then

		-- input register
		nrxf_buf(0) <= nrxf;
		nrxf_buf(1) <= nrxf_buf(0);
		ntxe_buf(0) <= ntxe;
		ntxe_buf(1) <= ntxe_buf(0);

		case state is

			when idle =>
				cnt <= WS;
				tf_rd <= '0';
				rf_wr <= '0';
				nrd <= '1';
				ft_wr <= '0';
				data_oe <= '0';
				if rf_full='0' and nrxf_buf(1)='0' then
					nrd <= '0';
					state <= rx1;
				elsif tf_empty='0' and ntxe_buf(1)='0' then
					ft_wr <= '1';
					wrr <= tf_dout;
					tf_rd <= '1';
					state <= tx1;
				end if;

			when inact =>
				tf_rd <= '0';
				rf_wr <= '0';
				nrd <= '1';
				ft_wr <= '0';
				data_oe <= '0';
				cnt <= cnt-1;
				if cnt=0 then
					state <= idle;
				end if;


			when rx1 =>
				cnt <= cnt-1;
				if cnt=0 then
					state <= rx2;
					rdr <= data;
				end if;

			when rx2 =>
				nrd <= '1';
				rf_wr <= '1';
				cnt <= WS;
				state <= inact;
				
			when tx1 =>
				tf_rd <= '0';
				data_oe <= '1';
				cnt <= cnt-1;
				if cnt=0 then
					state <= tx2;
					ft_wr <= '0';
				end if;

			when tx2 =>
				data_oe <= '0';
				cnt <= WS;
				state <= inact;

		end case;
	end if;

end process;

	data <= wrr when data_oe='1' else (others => 'Z');
	rf_din <= data;

end rtl;
