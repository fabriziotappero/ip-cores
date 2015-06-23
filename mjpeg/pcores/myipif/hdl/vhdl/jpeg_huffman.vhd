----------------------------------------------------------------
-- TODO:
-- * select right Huffman-table according to  compX_huff_Xc
-- * store all tables in one bram (atm ht_nr_of_symbols are stored in distr.ram
-- * continue to decode while write zrl and eob zeroes are written
----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity jpeg_huffman is
  port
    (	Clk				: in std_logic;
		reset_i			: in std_logic;
		header_select_i: in std_logic;
		error_o			: out std_logic;
		
		-- to initialize the bram
		ht_symbols_wea_i	: in std_logic;
		ht_tables_wea_i	: in std_logic;
		ht_select_i			: in std_logic_vector(2 downto 0);   -- bit 2: dc (low) or ac (high), bit 1 and 0: table-nr.
		ht_tables_address_i			: in std_logic_vector(7 downto 0);	-- address in bram:   ht_select_i & ht_tables_address_i
		ht_nr_of_symbols_address_i	: in std_logic_vector(3 downto 0);	-- address in distrib-ram:   ht_select_i & ht_nr_of_symbols_address_i
		ht_data_i			: in std_logic_vector(7 downto 0);
	
		context_i		:  in std_logic_vector(3 downto 0);	
		data_i			:  in std_logic_vector(7 downto 0);
		context_o		: out std_logic_vector(3 downto 0);	
		data_o			: out std_logic_vector(15 downto 0);

		-- header data
		comp1_huff_dc_i : in std_logic_vector(3 downto 0);
		comp2_huff_dc_i : in std_logic_vector(3 downto 0);
		comp3_huff_dc_i : in std_logic_vector(3 downto 0);
		comp1_huff_ac_i : in std_logic_vector(3 downto 0);
		comp2_huff_ac_i : in std_logic_vector(3 downto 0);
		comp3_huff_ac_i : in std_logic_vector(3 downto 0);
		sampling_i      : in std_logic_vector(3 downto 0); -- "00"->gray, "01"->4:2:0, "10"->4:2:2, "11"->4:4:4
		
		-- flow control
		datavalid_i 	: in std_logic;
		datavalid_o 	: out std_logic;
		ready_i			: in  std_logic;
		ready_o			: out std_logic
    );
end entity jpeg_huffman;





architecture IMP of jpeg_huffman is


-- store the number of huffman codes with length n (cf. jpeg-standard)
component jpeg_ht_nr_of_symbols
	port (
	A	: IN std_logic_VECTOR(7 downto 0); --  n = A+1
	CLK: IN std_logic;
	D	: IN std_logic_VECTOR(7 downto 0);
	WE	: IN std_logic;
	DPRA: IN std_logic_VECTOR(7 downto 0);
	DPO: OUT std_logic_VECTOR(7 downto 0);
	SPO: OUT std_logic_VECTOR(7 downto 0));
end component;


-- store the values of the huffman codes
component jpeg_ht_tables
	port (
	clka	: IN std_logic;
	dina	: IN std_logic_VECTOR(7 downto 0);
	addra	: IN std_logic_VECTOR(11 downto 0);
	wea	: IN std_logic_VECTOR(0 downto 0);
	clkb: IN std_logic;
	addrb: IN std_logic_VECTOR(11 downto 0);
	doutb	: OUT std_logic_VECTOR(7 downto 0));
end component;



-- Shiftregister, used to read 8-bits from imput and
-- then provide it in the needed bit wise order
component jpeg_huffman_input_sr
	port (
	CLK	: IN std_logic;
	SDOUT	: OUT std_logic;
	P_LOAD: IN std_logic;
	D		: IN std_logic_VECTOR(7 downto 0);
	CE		: IN std_logic;
	SCLR	: IN std_logic);
end component;





signal err, err_D : std_logic :='0';

type states is (st_start1, st_start2, st_start3, st_get_code, st_check_code1, st_check_code2, st_write_zeros_zrl, st_write_zeros_eob, st_write_zeros, st_get_value1, st_get_value2);
signal state, state_D : states := st_start1;

-- flow controll
signal datavalid, datavalid_D : std_logic := '0';
signal ready, ready_D : std_logic := '0';
signal ce, ce_D : std_logic :='1';
signal reset_flowcontroll : std_logic :='1';

-- handle the "input shift register"
signal sr_load, sr_load_D, last_ready, last_ready_D, sr_ce, sr_init : std_logic :='0';
signal sr_empty : std_logic :='1';
signal sr_counter, sr_counter_D : std_logic_vector(2 downto 0) := (others=>'0');

-- final addresses
signal ht_tables_address_ram_rd : std_logic_vector(11 downto 0) := (others=>'0');
signal ht_tables_address_ram_wr : std_logic_vector(11 downto 0) := (others=>'0');
signal ht_nr_of_symbols_address_ram_rd : std_logic_vector(7 downto 0) := (others=>'0');
signal ht_nr_of_symbols_address_ram_wr : std_logic_vector(7 downto 0) := (others=>'0');

-- data from the RAM
signal data_symbols, data_tables : std_logic_vector(7 downto 0) := (others=>'0');

-- signals to work with
signal reset : std_logic :='0';
signal context, context_D : std_logic_vector(3 downto 0) :=(others=>'0');
signal data, data_D : std_logic_vector(15 downto 0) :=(others=>'0');
signal get_bit, get_bit_D : std_logic :='0';
signal dataready, dataready_D : std_logic :='0';
signal data_intern : std_logic_vector(0 downto 0) := (others=>'0');
signal code_read, code_read_D : std_logic_vector(15 downto 0) := (others=>'0');
signal code_build, code_build_D : std_logic_vector(15 downto 0) := (others=>'0');
signal symbols, symbols_D : std_logic_vector(7 downto 0) := (others=>'0'); 
signal zeros_counter, zeros_counter_D : std_logic_vector(5 downto 0) := (others=>'0');

-- internal address calculation
signal ht_select, ht_select_D : std_logic_vector(2 downto 0) := (others=>'0');
signal ht_tables_address, ht_tables_address_D : std_logic_vector(7 downto 0) := (others=>'0');
signal ht_nr_of_symbols_address, ht_nr_of_symbols_address_D : std_logic_vector(3 downto 0) := (others=>'0');

-- to choose between dc and ac table, also used as address to write data to													-- TODO
signal ac_dc_counter, ac_dc_counter_D : std_logic_vector(5 downto 0) := (others=>'0');

-- to do the sampling 
signal sampling_counter, sampling_counter_D : std_logic_vector(2 downto 0) := (others=>'0');

-- sign
signal is_negative, is_negative_D : std_logic := '0';

-- Context
signal eob, eob_D : std_logic :='0';
signal eoi, last_eoi : std_logic :='0';
signal header_valid_out : std_logic := '0';
signal header_select_out : std_logic := '0';
signal header_select : std_logic := '0';
signal sampling, sampling_D : std_logic_vector(1 downto 0) :=(others=>'0');

-- remember the dc-coeffizient
signal last_dc   , last_dc_D, last_dc_reg : std_logic_vector(15 downto 0) := (others=>'0');
signal last_dc_Y , last_dc_Cb, last_dc_Cr : std_logic_vector(15 downto 0) := (others=>'0');
signal last_dc_Y_ce , last_dc_Cb_ce, last_dc_Cr_ce : std_logic := '0';
signal last_dc_select, last_dc_select_D : std_logic_vector(1 downto 0) := (others=>'0');



begin



--***********************************************************************
-- portmaps
--***********************************************************************
ht_nr_of_symbols : jpeg_ht_nr_of_symbols
		port map (
			A => ht_nr_of_symbols_address_ram_wr,
			CLK => Clk,
			D => ht_data_i,
			WE => ht_symbols_wea_i,
			DPRA => ht_nr_of_symbols_address_ram_rd,
			DPO => data_symbols 
		);
		
ht_table : jpeg_ht_tables
		port map (
			clka => Clk,
			dina => ht_data_i,
			addra => ht_tables_address_ram_wr,
			wea(0) => ht_tables_wea_i,
			clkb => Clk,
			addrb => ht_tables_address_ram_rd,
			doutb => data_tables
		);	

jpeg_huffman_input_sr_p : jpeg_huffman_input_sr
		port map (
			CLK => Clk,
			SDOUT => data_intern(0),
			P_LOAD => sr_load,
			D => data_i,
			CE => sr_ce,
			SCLR => reset);		-- TODO: care about stuffed bits 
sr_ce <= (get_bit and ce) or sr_init;
--***********************************************************************









--***********************************************************************
-- processes and wires
--***********************************************************************

	

-------------------------------------------------------------------------	
-- connect signal to outside 
-------------------------------------------------------------------------	
	ready_o		<= ready;
	error_o		<= err;
	data_o		<= data;

	reset			<= reset_i or (eoi and not last_eoi);
	process(Clk)
	begin
	if rising_edge(Clk) then
		last_eoi <= eoi;
	end if;
	end process;

	--------------------------------------------------
	-- sampling
	process(header_select, sampling_i)
	begin
		if (header_select='0') then
			sampling_D <= sampling_i(1 downto 0);
		else
			sampling_D <= sampling_i(3 downto 2);
		end if; 
	end process;
	
	process(Clk)
	begin
		if(rising_edge(Clk)) then
			if reset='1' then 
				sampling <= (others=>'0');
			elsif(sr_ce='1') then
				sampling <= sampling_D;
			end if;
		end if;
	end process;
	--------------------------------------------------



--	context_o	<= eoi & eob & context_D(1 downto 0);		-- This may cause problems :(
	context_o	<= eoi & eob & header_select_out & header_valid_out;
	header_select <= context(1);
	
	process(Clk)
	begin
		if rising_edge(Clk) then
		if sr_ce = '1' then
			eoi 			<= context(3);
			header_select_out <= context(1);
			header_valid_out	<= context(0);
		end if;
		end if;
	end process;


	process(Clk)
	begin
		if rising_edge(Clk) then
		if sr_ce = '1' and sr_load='1' then
			context <= context_i;
		end if;
		end if;
	end process;

	process(code_read, last_dc, ac_dc_counter, is_negative, dataready)
	begin
		data_D 		<= (others=>'0');
		last_dc_D	<= last_dc;
		
		if(ac_dc_counter = 1 and dataready ='1') then
			if(is_negative='1') then
				data_D		<= last_dc - code_read;
				last_dc_D	<= last_dc - code_read;
			else
				data_D 		<= last_dc + code_read;
				last_dc_D	<= last_dc + code_read;
			end if;
		elsif(dataready='1') then
			if(is_negative='1') then
				data_D <= 0 - code_read;
			else
				data_D <= code_read;
			end if;
		end if;
	end process;

	
	-- last_dc_D handled later to do the right sampling-method
	process(Clk)
	begin
		if rising_edge(Clk) then
		if reset='1' then
			data <= (others=>'0');
		elsif ce='1' then
			data <= data_D;
		end if;
		end if;
	end process;
-------------------------------------------------------------------------	



-------------------------------------------------------------------------	
-- count the bits remaining in the shift register, refill it if neccessary
-------------------------------------------------------------------------	
process(sr_ce, sr_counter, sr_load, datavalid_i)
begin
	sr_counter_D <= sr_counter;
	sr_load_D	 <= sr_load;

	if (sr_ce='1') then
		sr_counter_D <= sr_counter+1;
	end if;
	
	if (sr_counter="000" and sr_ce='1') then
		sr_load_D <= '1';
	end if;
		
	if sr_load='1' and datavalid_i='1' and sr_ce='1' then
		sr_load_D <='0';
	end if;

	ready_D	 		<= sr_load and sr_ce and not last_ready;
	last_ready_D	<= (ready or last_ready) and sr_load; 		-- last_ready to prevent multiple loads on ce=0
end process;

process(Clk)
begin
	if rising_edge(Clk) then
		sr_counter	<= sr_counter;
		sr_load	 	<= sr_load;
		sr_init		<= '0';
		ready	 		<= ready_D;
		last_ready	<= last_ready_D;	
		sr_empty		<= sr_empty;

		if reset='1' then
			sr_counter	<= "000";
			sr_load		<= '0';
			last_ready	<= '0';
			ready			<= '0';
			sr_empty		<= '1';
		elsif sr_empty='1' and datavalid_i='1' then
			sr_counter	<= "001";
			sr_load 		<= '1';
			sr_init		<= '1';
			sr_empty 	<= '0';
		elsif ce='1' then
			sr_load	 	<= sr_load_D;
			sr_counter	<= sr_counter_D;
		end if;

	end if;
end process;
-------------------------------------------------------------------------	


-------------------------------------------------------------------------
-- flowcontroll with reset
-------------------------------------------------------------------------
datavalid_o	<= datavalid 													and not (reset_i or reset_flowcontroll);
ce				<= datavalid_i and (ready_i or not datavalid) 		and not (reset_i or reset_flowcontroll);
datavalid_D	<= (dataready or (datavalid and (not ready_i))) 	and not (reset_i or reset_flowcontroll);

process(Clk)
begin
	if rising_edge(Clk) then
		datavalid 			 <= datavalid_D; -- or (eoi and not last_eoi);
		reset_flowcontroll <= reset_i;
	end if;
end process;
-------------------------------------------------------------------------



-------------------------------------------------------------------------	
-- store and recall the right diff-value for the dc-components 
-------------------------------------------------------------------------	
process(last_dc_select, sampling_counter, sampling)
begin
	last_dc_select_D <= last_dc_select;

	case sampling is

	---------------------------------------
	-- gray
	---------------------------------------
	when "00" => 
		last_dc_select_D <= "00";

	---------------------------------------
	-- 4:2:0
	---------------------------------------
	when "01" => 
		case sampling_counter is
			when "000"|"001"|"010"|"011" =>
				last_dc_select_D <= "00";
			when "100" => 
				last_dc_select_D <= "01";
			when "101" => 
				last_dc_select_D <= "10";
			when others =>
				last_dc_select_D <= "11";
		end case;
		
	---------------------------------------
	-- 4:2:2
	---------------------------------------
	when "10" => 
		case sampling_counter is
			when "000"|"001" =>
				last_dc_select_D <= "00";
			when "010" => 
				last_dc_select_D <= "01";
			when "011" => 
				last_dc_select_D <= "10";
			when others =>
				last_dc_select_D <= "11";
		end case;
	
	---------------------------------------
	-- 4:4:4
	---------------------------------------
	when others => 
		case sampling_counter is
			when "000" =>
				last_dc_select_D <= "00";
			when "001" => 
				last_dc_select_D <= "01";
			when "010" => 
				last_dc_select_D <= "10";
			when others =>
				last_dc_select_D <= "11";
		end case;
		
	end case;

end process;


process(last_dc_select, last_dc_Y ,last_dc_Cr, last_dc_Cb)
begin
	last_dc_Y_ce  <= '0';
	last_dc_Cb_ce <= '0';
	last_dc_Cr_ce <= '0';
	last_dc <= (others=>'0');

	case last_dc_select is
		when "00" => 
			last_dc_Y_ce <= '1';
			last_dc <= last_dc_Y;
		when "01" =>
			last_dc_Cb_ce <= '1';
			last_dc <= last_dc_Cb;
		when "10" => 
			last_dc_Cr_ce <= '1';
			last_dc <= last_dc_Cr;
		when others =>
			-- this should not happen, maybe put some errordetection here
	end case;
end process;


process(Clk)
begin
	if rising_edge(Clk) then
		if (reset='1') then
			last_dc_select	<= (others=>'0');
		elsif ce='1' then
			last_dc_select	<= last_dc_select_D;
		end if;

 	 	if (reset='1') then
			last_dc_Y	<= (others=>'0');
		elsif ce='1' and last_dc_Y_ce='1' then
			last_dc_Y	<= last_dc_D;
		end if;

		if (reset='1') then
			last_dc_Cb	<= (others=>'0');
		elsif ce='1' and last_dc_Cb_ce='1' then
			last_dc_Cb	<= last_dc_D;
		end if;

		if (reset='1') then
			last_dc_Cr	<= (others=>'0');
		elsif ce='1' and last_dc_Cr_ce='1' then
			last_dc_Cr	<= last_dc_D;
		end if;
	end if;
end process;
-------------------------------------------------------------------------	








-------------------------------------------------------------------------	
-- choose right address for bram/distr-ram.
-------------------------------------------------------------------------	
	ht_tables_address_ram_wr 			<= header_select_i & ht_select_i & ht_tables_address_i;
	ht_nr_of_symbols_address_ram_wr	<= header_select_i & ht_select_i & ht_nr_of_symbols_address_i;
	ht_tables_address_ram_rd 			<= header_select   & ht_select   & ht_tables_address;
	ht_nr_of_symbols_address_ram_rd 	<= header_select   & ht_select   & ht_nr_of_symbols_address;
-------------------------------------------------------------------------	









-------------------------------------------------------------------------	
-- switch between ac/dc and between Y/Cb/Cr decoding by choosing right huffman-table
-------------------------------------------------------------------------	
process(dataready, eob, sampling_counter, ht_select, sampling, state)
begin
	ht_select_D			<= ht_select;
	sampling_counter_D	<= sampling_counter;
	

	case sampling is
	
	---------------------------------------
	-- gray		Y -> Y -> Y ...
	---------------------------------------
	when "00" =>
		ht_select_D(1 downto 0) <= "00";

		if (eob='1') then
			ht_select_D(2)	<= '0';
		elsif(dataready='1' and state/=st_write_zeros_eob) then
			ht_select_D(2)	<= '1';
		end if;
		
	---------------------------------------
	-- 4:2:0		Y -> Y -> Y -> Y -> Cb -> Cr -> Y -> Y ...
	---------------------------------------
	when "01" =>
		if (sampling_counter < 4) then
			ht_select_D(1 downto 0) <= "00";
		elsif (sampling_counter="100") then
			ht_select_D(1 downto 0) <= "01";
		elsif (sampling_counter="101") then
			ht_select_D(1 downto 0) <= "01";
		end if;	

		if (eob='1') then
			ht_select_D(2)	<= '0';
			sampling_counter_D <= sampling_counter + 1;
			if	(sampling_counter="101") then
				sampling_counter_D <= "000";
			end if;
		elsif(dataready='1' and state/=st_write_zeros_eob) then
			ht_select_D(2)	<= '1';
		end if;
	
	---------------------------------------
	-- 4:2:2		Y -> Y -> Cb -> Cr -> Y -> Y ...
	---------------------------------------
	when "10" =>
		if (sampling_counter < 2) then
			ht_select_D(1 downto 0) <= "00";
		else
			ht_select_D(1 downto 0) <= "01";
		end if;	

		if (eob='1') then
			ht_select_D(2)	<= '0';
			sampling_counter_D <= sampling_counter + 1;
			if	(sampling_counter="011") then
				sampling_counter_D <= "000";
			end if;
		elsif(dataready='1' and state/=st_write_zeros_eob) then
			ht_select_D(2)	<= '1';
		end if;
	
	---------------------------------------
	-- 4:4:4		Y -> Cb -> Cr -> Y -> Cb ...
	---------------------------------------
	when others =>
		if (sampling_counter = 0) then
			ht_select_D(1 downto 0) <= "00";
		else
			ht_select_D(1 downto 0) <= "01";
		end if;	

		if (eob='1') then
			ht_select_D(2)	<= '0';
			sampling_counter_D <= sampling_counter + 1;
			if	(sampling_counter="010") then
				sampling_counter_D <= "000";
			end if;
		elsif(dataready='1' and state/=st_write_zeros_eob) then
			ht_select_D(2)	<= '1';
		end if;
	
	end case;
	
end process;


process(Clk)
begin
	if (rising_edge(Clk)) then
	if (reset='1') then
		ht_select			<= (others=>'0'); 
		sampling_counter	<= (others=>'0'); 
	elsif ce='1' then
		ht_select			<= ht_select_D;
		sampling_counter	<= sampling_counter_D;
	end if;
	end if;
end process;
-------------------------------------------------------------------------	








-------------------------------------------------------------------------	
-- the huffman decoding
-------------------------------------------------------------------------	
process(data_intern, datavalid_i, ready_i, state, code_read, code_build, 
			symbols, data_symbols, data_tables, get_bit, err, ht_tables_address, 
			ht_nr_of_symbols_address, is_negative, ac_dc_counter, zeros_counter, 
			ht_select, dataready)
begin
	err_D				<= err;
	state_D			<= state;
	dataready_D 	<= '0';
	get_bit_D		<= '0';
	code_read_D		<= code_read;
	code_build_D	<= code_build;
	ht_tables_address_D			<= ht_tables_address;			
	ht_nr_of_symbols_address_D <= ht_nr_of_symbols_address;  
	symbols_D		<= symbols;
	is_negative_D	<= is_negative;
	ac_dc_counter_D<= ac_dc_counter;
	zeros_counter_D<= zeros_counter;
	eob_D				<= eob;


	-- with the last of the 64 words signal eob as well
	if ((ac_dc_counter = 0) and (dataready = '1')) then
		eob_D				<= '1';
	else
		eob_D				<= '0';
	end if;



	case state is
	when st_start1 =>
		-- start reading a new huffman code
		state_D 			<= st_start2;
		ht_tables_address_D			<= (others=>'0');
		ht_nr_of_symbols_address_D <= (others=>'0');
		code_build_D 	<= (others=>'0');
		code_read_D		<= (others=>'0');
	
	-- important, do not remove
	when st_start2 =>
		state_D 		<= st_start3;

	when st_start3 =>
		state_D 		<= st_get_code;
		get_bit_D 	<= '1';
	
	-- append bit to existing code
	when st_get_code => 
		state_D 				<= st_check_code1;
		code_read_D 		<= code_read(14 downto 0) & data_intern;
		code_build_D 		<= code_build(14 downto 0) & '0';
		ht_nr_of_symbols_address_D <= ht_nr_of_symbols_address + 1;
		symbols_D 			<= data_symbols;
		if (data_symbols=0) then
			state_D 			<= st_get_code;
			get_bit_D 		<= '1';
		end if;

	
	-- decode
	when st_check_code1 =>
		if (symbols = 0) then
			state_D 			<= st_get_code;
			get_bit_D 		<= '1';
		elsif (code_build < code_read) then 
			code_build_D	<= code_build + 1;
			ht_tables_address_D <= ht_tables_address + 1;			
			symbols_D 		<= symbols - 1;
		elsif (code_build = code_read) then
			state_D 			<= st_check_code2;
			code_read_D 	<= (others=>'0');
			code_build_D	<= (others=>'0');
		else
			state_D 			<= st_start1;
			err_D 			<= '1';
		end if;


	-- check for EOB and ZRL, initialize value-readout otherwise
	when st_check_code2 =>
		if (data_tables = 0 and (ht_select(2) = '1')) then			-- EOB
			state_D <= st_write_zeros_eob;		
			dataready_D <='1';
			zeros_counter_D <= 64 - ac_dc_counter;
			ac_dc_counter_D <= ac_dc_counter + 1;
		
		elsif (data_tables = 0 and (ht_select(2) = '0')) then		-- to avoid overflow of code_build in next cycle
			state_D <= st_start1;
			ac_dc_counter_D <= ac_dc_counter + 1;
			if (ac_dc_counter=0) then										-- value 0 for dc component must be written (diff-value 0)
				dataready_D <= '1';
			end if;

		elsif (data_tables = X"F0" and not (ht_select(2) = '0')) then 	-- ZRL
			state_D <= st_write_zeros_zrl;
			dataready_D<='1';
			zeros_counter_D <= "010000"; 
			ac_dc_counter_D <= ac_dc_counter + 1;
		
		elsif(data_tables(7 downto 4)="0000") then
			state_D <= st_get_value1;
			code_build_D <= X"000" & data_tables(3 downto 0);		-- in the next state this will be the counter
			get_bit_D <= '1';
		else
			state_D <= st_write_zeros;
			dataready_D<='1';
			code_build_D <= X"000" & data_tables(3 downto 0);		-- in the state st_get_valueX this will be the counter
			zeros_counter_D <= "00" & data_tables(7 downto 4);
			ac_dc_counter_D <= ac_dc_counter+1;
		end if;

	
	-- write zeroes and start with new code
	when st_write_zeros_zrl | st_write_zeros_eob =>
			dataready_D <='1';
			ac_dc_counter_D <= ac_dc_counter+1;
			zeros_counter_D <= zeros_counter-1; 
			if (zeros_counter=1) then
				ac_dc_counter_D <= ac_dc_counter;
				state_D <= st_start1;
				dataready_D <='0';
			end if;
		
	-- write zeroes and read code 
	when st_write_zeros =>
			dataready_D<='1';
			ac_dc_counter_D <= ac_dc_counter+1;
			zeros_counter_D <= zeros_counter-1; 
			if (zeros_counter=1) then
				ac_dc_counter_D <= ac_dc_counter;
				state_D <= st_get_value1;
				dataready_D<='0';
				get_bit_D <= '1';
			end if;


	-- read value
	when st_get_value1 =>
		if (data_intern = "1") then	
			code_read_D <= code_read(14 downto 0) & data_intern;
			is_negative_D <= '0';
		else
			code_read_D <= code_read(14 downto 0) & (not data_intern);
			is_negative_D <= '1';
		end if;

		if (code_build = 1) then
			state_D <= st_start1;
			dataready_D <='1';
			ac_dc_counter_D <= ac_dc_counter + 1;
		else
			code_build_D <= code_build - 1;
			get_bit_D <= '1';
			state_D <= st_get_value2;
		end if;




	when st_get_value2 =>
		if (is_negative='0') then
			code_read_D <= code_read(14 downto 0) & data_intern;
		else
			code_read_D <= code_read(14 downto 0) & (not data_intern);
		end if;

		if (code_build = 1) then
			state_D <= st_start1;
			dataready_D <='1';
			ac_dc_counter_D <= ac_dc_counter + 1;
		else
			code_build_D <= code_build - 1;
			get_bit_D <= '1';
			state_D <= st_get_value2;
		end if;

	end case;


end process;
-------------------------------------------------------------------------	
	




-------------------------------------------------------------------------	
-- Update registers on rising edge
-------------------------------------------------------------------------	
process(Clk)
begin
	if (rising_edge(Clk)) then
	if(reset = '1') then
		err				<= '0';
		state				<= st_start1;
		dataready	 	<= '0';
		get_bit			<= '0';
		code_read		<= (others =>'0');
		code_build		<= (others =>'0');
		ht_tables_address			<= (others =>'0');
		ht_nr_of_symbols_address <= (others =>'0');
		symbols			<= (others =>'0');
		ac_dc_counter	<= (others =>'0');
		zeros_counter	<= (others =>'0');
		is_negative		<= '0';
		eob				<= '0'; 
	elsif ce='1' then
		err				<= err_D;
		state				<= state_D;
		dataready 		<= dataready_D;
		get_bit			<= get_bit_D;
		code_read		<= code_read_D;
		code_build		<= code_build_D;
		ht_tables_address				<= ht_tables_address_D;			
		ht_nr_of_symbols_address	<= ht_nr_of_symbols_address_D;  
		symbols			<= symbols_D;
		ac_dc_counter	<= ac_dc_counter_D;
		zeros_counter	<= zeros_counter_D;
		is_negative		<= is_negative_D;
		eob				<= eob_D;
	end if;
	end if;
end process;
-------------------------------------------------------------------------	



end IMP;
