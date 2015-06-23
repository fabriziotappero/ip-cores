library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity jpeg_dequantize is
  port
    (	Clk				: in std_logic;
		reset_i			: in std_logic;

		-- storing the tables
		header_select_i: in std_logic;
		qt_wea_i		: in std_logic;
		qt_select_i	: in std_logic_vector(1 downto 0);    		-- bit 1 and 0: table-nr. (at the moment only two QTs supported)
		qt_data_i	: in std_logic_vector(7 downto 0);

		sampling_i	: in  std_logic_vector(3 downto 0);
				
		context_i		: in  std_logic_vector(3 downto 0);	
		data_i			: in  std_logic_vector(11 downto 0);
		context_o		: out std_logic_vector(3 downto 0) :=(others=>'0');	
		data_o			: out std_logic_vector(11 downto 0) :=(others=>'0');
		
		comp1_qt_number_i : in std_logic_vector(1 downto 0);
		comp2_qt_number_i : in std_logic_vector(1 downto 0);
		comp3_qt_number_i : in std_logic_vector(1 downto 0);
		
		-- flow control
		datavalid_i 	: in std_logic;
		datavalid_o 	: out std_logic;
		ready_i			: in  std_logic;
		ready_o			: out std_logic
    );
end entity jpeg_dequantize;









architecture IMP of jpeg_dequantize is

	component jpeg_dequant_multiplier
		port (
		a: IN std_logic_VECTOR(11 downto 0);
		b: IN std_logic_VECTOR(7 downto 0);
		o: OUT std_logic_VECTOR(19 downto 0));
	end component;

	-- store the tables in shift registers
	component jpeg_qt_sr IS
		port (
		d: IN std_logic_VECTOR(7 downto 0);
		clk: IN std_logic;
		ce: IN std_logic;
		q: OUT std_logic_VECTOR(7 downto 0));
	end component;



	signal qt0_0_data_in, qt1_0_data_in, qt0_1_data_in, qt1_1_data_in : std_logic_vector(7 downto 0) := (others=>'0');
	signal qt0_0_data_out, qt1_0_data_out, qt0_1_data_out, qt1_1_data_out : std_logic_vector(7 downto 0) := (others=>'0');
	signal qt0_0_ce, qt1_0_ce, qt0_1_ce, qt1_1_ce : std_logic :='0';
	signal qt_out : std_logic_vector(7 downto 0) :=(others=>'0');
	
	signal data : std_logic_vector(19 downto 0):=(others=>'0');
	signal context : std_logic_vector(3 downto 0) :=(others =>'0');
	signal select_qt, select_qt_D : std_logic_vector( 1 downto 0) :=(others=>'0');
	signal counter : std_logic_vector(5 downto 0) :=(others=>'0');
	signal sampling_counter, sampling_counter_D : std_logic_vector(2 downto 0) :=(others=>'0');
	signal sampling : std_logic_vector(1 downto 0) :=(others=>'0');
	signal comp1_qt_number : std_logic_vector(0 downto 0) :="0";
	signal comp2_qt_number : std_logic_vector(0 downto 0) :="0";
	signal comp3_qt_number : std_logic_vector(0 downto 0) :="0";

	-- flowcontroll
	signal datavalid : std_logic := '0';
	signal ce : std_logic :='0';
	signal reset : std_logic :='1';





begin

	ce 			<= datavalid_i and ready_i;
	datavalid	<= ce;
	ready_o 		<= ready_i;
	reset 		<= reset_i;	

	process(Clk)
	begin
		if rising_edge(Clk) then

		datavalid_o	<= datavalid;
		data_o 		<= data(19) & data(10 downto 0);
		context		<= context_i;
		context_o	<= context;	

			if reset='1' then
				datavalid_o	<= '0';
				context_o	<= "0000";	
				context		<= "0000";	
			end if;
		end if;
	end process;



	process(Clk)
	begin
		if rising_edge(Clk) then
			if reset='1' then
				counter <= (others=>'0');
			elsif(ce='1') then
				counter <= counter + 1;
			end if;
		end if;
	end process;




	-------------------------------------------------------------------------	
	-- store the context
	-------------------------------------------------------------------------	
	process(sampling_i, context(1))
	begin
		if (context(1)='0') then
			sampling <= sampling_i(1 downto 0);
			comp1_qt_number <= comp1_qt_number_i(0 downto 0);  
			comp2_qt_number <= comp2_qt_number_i(0 downto 0);  
			comp3_qt_number <= comp3_qt_number_i(0 downto 0);  
		else
			sampling <= sampling_i(3 downto 2);
			comp1_qt_number <= comp1_qt_number_i(1 downto 1);  
			comp2_qt_number <= comp2_qt_number_i(1 downto 1);  
			comp3_qt_number <= comp3_qt_number_i(1 downto 1);  
		end if;
	end process;
	-------------------------------------------------------------------------	




	-------------------------------------------------------------------------	
	-- count the data processed
	-------------------------------------------------------------------------	
	process(sampling_counter, sampling, counter)
	begin
		sampling_counter_D	<= sampling_counter;

		case sampling is
		---------------------------------------
		-- gray		Y -> Y -> Y ...
		---------------------------------------
		when "00" =>
			sampling_counter_D	<= "000";
		---------------------------------------
		-- 4:2:0		Y -> Y -> Y -> Y -> Cb -> Cr -> Y -> Y ...
		---------------------------------------
		when "01" =>
			if (counter=63) then
				sampling_counter_D <= sampling_counter + 1;
				if	(sampling_counter="101") then
					sampling_counter_D <= "000";
				end if;
			end if;
		---------------------------------------
		-- 4:2:2		Y -> Y -> Cb -> Cr -> Y -> Y ...
		---------------------------------------
		when "10" =>
			if (counter=63) then
				sampling_counter_D <= sampling_counter + 1;
				if	(sampling_counter="011") then
					sampling_counter_D <= "000";
				end if;
			end if;
		---------------------------------------
		-- 4:4:4		Y -> Cb -> Cr -> Y -> Cb ...
		---------------------------------------
		when others =>
			if (counter=63) then
				sampling_counter_D <= sampling_counter + 1;
				if	(sampling_counter="010") then
					sampling_counter_D <= "000";
				end if;
			end if;
		end case;
	end process;


	process(Clk)
	begin
		if (rising_edge(Clk)) then
		if (reset='1') then
			sampling_counter	<= (others=>'0'); 
		elsif ce='1' then
			sampling_counter	<= sampling_counter_D;
		end if;
		end if;
	end process;
	-------------------------------------------------------------------------	



	-------------------------------------------------------------------------	
	-- decide which table to use
	-------------------------------------------------------------------------	
	process(select_qt, sampling_counter, sampling)
	begin
		select_qt_D <= select_qt;
	
		case sampling is
	
		---------------------------------------
		-- gray
		---------------------------------------
		when "00" => 
			select_qt_D <= context(1) & comp1_qt_number;
	
		---------------------------------------
		-- 4:2:0
		---------------------------------------
		when "01" => 
			case sampling_counter is
				when "000"|"001"|"010"|"011" =>
					select_qt_D <= context(1) & comp1_qt_number;
				when "100" => 
					select_qt_D <= context(1) & comp2_qt_number;
				when "101" => 
					select_qt_D <= context(1) & comp3_qt_number;
				when others =>
			end case;
			
		---------------------------------------
		-- 4:2:2
		---------------------------------------
		when "10" => 
			case sampling_counter is
				when "000"|"001" =>
					select_qt_D <= context(1) & comp1_qt_number;
				when "010" =>
					select_qt_D <= context(1) & comp2_qt_number;
				when "011" => 
					select_qt_D <= context(1) & comp3_qt_number;
				when others =>
			end case;
	
		---------------------------------------
		-- 4:4:4
		---------------------------------------
		when others => 
			case sampling_counter is
				when "000" =>
					select_qt_D <= context(1) & comp1_qt_number;
				when "001" =>
					select_qt_D <= context(1) & comp2_qt_number;
				when "010" => 
					select_qt_D <= context(1) & comp3_qt_number;
				when others =>
			end case;
		
		end case;
	
	end process;


	process(Clk)
	begin
		if rising_edge(Clk) then
			select_qt <= select_qt_D;
		end if;
	end process;
	-------------------------------------------------------------------------	




	-------------------------------------------------------------------------	
	-- process the right table
	-------------------------------------------------------------------------	
	process(	qt0_0_data_out, qt1_0_data_out, qt0_1_data_out, qt1_1_data_out, 
				ce, context, select_qt, qt_wea_i, header_select_i, qt_select_i, qt_data_i)
	begin

		qt0_0_ce <= '0';
		qt1_0_ce <= '0';
		qt0_1_ce <= '0';
		qt1_1_ce <= '0';
		qt0_0_data_in <= qt0_0_data_out;
		qt1_0_data_in <= qt1_0_data_out;
		qt0_1_data_in <= qt0_1_data_out;
		qt1_1_data_in <= qt1_1_data_out;

		if ce='1' and context(1)='0' and select_qt(0)='0' then
			qt0_0_ce <= '1';
		elsif ce='1' and context(1)='0' and select_qt(0)='1' then
			qt1_0_ce <= '1';
		elsif ce='1' and context(1)='1' and select_qt(0)='0' then
			qt0_1_ce <= '1';
		elsif ce='1' and context(1)='1' and select_qt(0)='1' then
			qt1_1_ce <= '1';
		end if;

		-- fill the tables 
		if qt_wea_i='1' and header_select_i='0' and qt_select_i="00" then
			qt0_0_ce <= '1';
			qt0_0_data_in <= qt_data_i;
		elsif qt_wea_i='1' and header_select_i='0' and qt_select_i="01" then
			qt1_0_ce <= '1';
			qt1_0_data_in <= qt_data_i;
		elsif qt_wea_i='1' and header_select_i='1' and qt_select_i="00" then
			qt0_1_ce <= '1';
			qt0_1_data_in <= qt_data_i;
		elsif qt_wea_i='1' and header_select_i='1' and qt_select_i="01" then
			qt1_1_ce <= '1';
			qt1_1_data_in <= qt_data_i;
		end if;

--		end if;
	end process;
	-------------------------------------------------------------------------	

	-------------------------------------------------------------------------	
	-- select the right table for the multiplication 
	-------------------------------------------------------------------------	
	process(qt0_0_data_out, qt1_0_data_out, qt0_1_data_out, qt1_1_data_out, select_qt)
	begin
		if select_qt="00" then 
			qt_out <= qt0_0_data_out;
		elsif select_qt="01" then 
			qt_out <= qt1_0_data_out;
		elsif select_qt="10" then 
			qt_out <= qt0_1_data_out;
		elsif select_qt="11" then 
			qt_out <= qt1_1_data_out;
		end if;
	end process; 
	-------------------------------------------------------------------------	


	-------------------------------------------------------------------------	
	-- Multiply
	-------------------------------------------------------------------------	
	jpeg_dequant_multiplier_p : jpeg_dequant_multiplier
		port map (
			a => data_i,
			b => qt_out,
			o => data
		);
	-------------------------------------------------------------------------	

	-------------------------------------------------------------------------	
	-- circular shift registers for the tables 
	-------------------------------------------------------------------------	
	jpeg_qt_sr_0_0_p : jpeg_qt_sr 
		port map(
			d		=> qt0_0_data_in,
			clk	=> Clk,
			ce		=> qt0_0_ce,
			q		=> qt0_0_data_out
		);

	jpeg_qt_sr_1_0_p : jpeg_qt_sr 
		port map(
			d		=> qt1_0_data_in,
			clk	=> Clk,
			ce		=> qt1_0_ce,
			q		=> qt1_0_data_out
		);

	jpeg_qt_sr_0_1_p : jpeg_qt_sr 
		port map(
			d		=> qt0_1_data_in,
			clk	=> Clk,
			ce		=> qt0_1_ce,
			q		=> qt0_1_data_out
		);

	jpeg_qt_sr_1_1_p : jpeg_qt_sr 
		port map(
			d		=> qt1_1_data_in,
			clk	=> Clk,
			ce		=> qt1_1_ce,
			q		=> qt1_1_data_out
		);
	-------------------------------------------------------------------------	


end IMP;
