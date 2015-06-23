library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity jpeg_idct is
  port
    (	Clk				: in std_logic;
		reset_i			: in std_logic;

		context_i		: in  std_logic_vector(3 downto 0);
		data_i			: in  std_logic_vector(11 downto 0);
		context_o		: out std_logic_vector(3 downto 0);
		data_o			: out std_logic_vector(8 downto 0);

		-- flow control
		datavalid_i 	: in std_logic;
		datavalid_o 	: out std_logic;
		ready_i			: in  std_logic;
		ready_o			: out std_logic
    );
end entity jpeg_idct;





architecture IMP of jpeg_idct is

	--------------------------------------------------------------
	-- IDCT-Core
	--------------------------------------------------------------
	component jpeg_idct_core_12
		port (
		ND: IN std_logic;
		RDY: OUT std_logic;
		RFD: OUT std_logic;
		CLK: IN std_logic;
		RST: IN std_logic;
		DIN: IN std_logic_VECTOR(11 downto 0);
		DOUT: OUT std_logic_VECTOR(8 downto 0));
	end component;
	--------------------------------------------------------------

	signal datavalid : std_logic :='0';
	signal ready, last_ready : std_logic :='0';
	signal block_counter : std_logic_vector(1 downto 0) :=(others=>'0');
	signal out_counter, out_counter_D : std_logic_vector(7 downto 0) :=(others=>'0');
	signal in_counter,  in_counter_D  : std_logic_vector(7 downto 0) :=(others=>'0');
	signal eoi, eoi_D : std_logic_vector(3 downto 0) :=(others=>'0'); 
	signal eoi_out, eoi_out_D : std_logic :='0'; 
	signal header_select, header_select_D : std_logic_vector(3 downto 0) :=(others=>'0');
	signal header_select_out, header_select_out_D : std_logic :='0';
	signal context : std_logic_vector(3 downto 0) := (others=>'0');

begin
	
	--------------------------------------------------------------
	-- dataflow
	--------------------------------------------------------------
	datavalid_o <= datavalid;
	ready_o <= ready and last_ready and ready_i;
	process(Clk)
	begin
		if rising_edge(Clk) then
			last_ready <= ready;
		end if;
	end process;
	--------------------------------------------------------------




	--------------------------------------------------------------
	-- context (esp. eoi)
	--------------------------------------------------------------
	context_o <= context;

	-- count to see when block is finished
	out_counter_D	<= out_counter +1;
	in_counter_D	<= in_counter +1;
	process(Clk)
	begin
		if rising_edge(Clk) then
			if reset_i='1' then
				out_counter	<= (others=>'0');
			elsif(datavalid='1') then
				out_counter	<= out_counter_D;
			end if;
			
			if reset_i='1' then
				in_counter	<= (others=>'0');
			elsif(datavalid_i='1' and ready='1') then
				in_counter	<= in_counter_D;
			end if;

		end if;
	end process;

	-- remember header_select to write while block is shifted out
	process(context_i, in_counter, out_counter, header_select)
	begin
		header_select_D <= header_select; 

		if in_counter(5 downto 0) = "111101" then 		--	just a random counter_value less than "1111111" and greater than "000000"
			case in_counter(7 downto 6) is
			when "00" =>
				header_select_D(0) <= context_i(1);
			when "01" =>
				header_select_D(1) <= context_i(1);
			when "10" =>
				header_select_D(2) <= context_i(1);
			when others =>
				header_select_D(3) <= context_i(1);
			end case;
		end if;
		
 		case out_counter(7 downto 6) is
		when "00" =>
			header_select_out_D <= header_select(0);
		when "01" =>
			header_select_out_D <= header_select(1);
		when "10" =>
			header_select_out_D <= header_select(2);
		when others =>
			header_select_out_D <= header_select(3);
		end case;

	end process;
	
	-- remember received eoi to write after block is finished
	process(eoi, context_i, in_counter, out_counter)
	begin
		
		eoi_D <= eoi;
		eoi_out_D <='0';
	
		if context_i(3)='1' then
			case in_counter(7 downto 6) is
			when "00" =>
				eoi_D(0) <= '1';
			when "01" =>
				eoi_D(1) <= '1';
			when "10" =>
				eoi_D(2) <= '1';
			when others =>
				eoi_D(3) <= '1';
			end case;
		elsif(out_counter(5 downto 0)="000000") then
			case out_counter(7 downto 6) is
			when "00" =>
				eoi_D(0) <= '0';
				eoi_out_D <= eoi(0);
			when "01" =>
				eoi_D(1) <= '0';
				eoi_out_D <= eoi(1);
			when "10" =>
				eoi_D(2) <= '0';
				eoi_out_D <= eoi(2);
			when others =>
				eoi_D(3) <= '0';
				eoi_out_D <= eoi(3);
			end case;
		end if;

	end process;

	
	process(Clk)
	begin
		if rising_edge(Clk) then

			eoi 					<= eoi_D;
			eoi_out 				<= eoi_out_D;
			header_select		<= header_select_D;
			header_select_out	<= header_select_out_D;
			
			context <= '0' & context(2 downto 0);

			if reset_i='1' then
				eoi 		<= "0000";
				eoi_out	<= '0';
				context	<= (others=>'0');
				header_select		<= (others=>'0');
				header_select_out	<= '0';
			elsif(out_counter(5 downto 0)="000000") then
				context <= eoi_out & '0' & header_select_out & '0';
			end if;

		end if;
	end process;

	--------------------------------------------------------------

	
	

	--------------------------------------------------------------
	-- IDCT-Core
	--------------------------------------------------------------
	jpeg_idct_core_12_p : jpeg_idct_core_12
			port map (
   			ND => datavalid_i,
				RDY => datavalid,
				RFD => ready,
				CLK => CLK,
				RST => reset_i,
				DIN => data_i,
				DOUT => data_o);
	--------------------------------------------------------------
	
end IMP;
	
