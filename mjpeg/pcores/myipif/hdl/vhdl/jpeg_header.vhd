library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity jpeg_header is
  port
    (	Clk			: in std_logic;
		data_i		: in std_logic_vector(7 downto 0);
		datavalid_i	: in std_logic;
		reset_i		: in std_logic;
		eoi_i			: in std_logic;
		
		header_valid_o	: out std_logic;
		header_error_o	: out std_logic;
		header_select_o: out std_logic;
		
		-- initialize the huffmann tables located in the huffmann-decoder entity
		ht_symbols_wea_o	: out std_logic;
		ht_tables_wea_o		: out std_logic;
		ht_select_o			: out std_logic_vector(2 downto 0);   -- bit 2: dc (low) or ac (high), bit 1 and 0: table-nr.
		ht_tables_address_o		: out std_logic_vector(7 downto 0);	-- address in bram:   ht_select_o & ht_tables_address_o
		ht_nr_of_symbols_address_o: out std_logic_vector(3 downto 0);	-- address in distrib-ram:   ht_select_o & ht_nr_of_symbols_address_o
		ht_data_o			: out std_logic_vector(7 downto 0);
		
		-- initialize the quantization tables located in the dequantisation entity
		qt_wea_o		: out std_logic;
		qt_select_o	: out std_logic_vector(1 downto 0);    		-- bit 1 and 0: table-nr.
		qt_data_o	: out std_logic_vector(7 downto 0);
		
		-- sos-field
		comp1_huff_dc_o : out std_logic_vector(3 downto 0);
		comp2_huff_dc_o : out std_logic_vector(3 downto 0);
		comp3_huff_dc_o : out std_logic_vector(3 downto 0);
		comp1_huff_ac_o : out std_logic_vector(3 downto 0);
		comp2_huff_ac_o : out std_logic_vector(3 downto 0);
		comp3_huff_ac_o : out std_logic_vector(3 downto 0);
		
		--sof-field
		height_o : out std_logic_vector(15 downto 0);
		width_o : out std_logic_vector(15 downto 0);
		sampling_o      : out std_logic_vector(1 downto 0); -- "00"->gray, "01"->4:2:0, "10"->4:2:2, "11"->4:4:4
		comp1_qt_number_o : out std_logic_vector(0 downto 0);
		comp2_qt_number_o : out std_logic_vector(0 downto 0);
		comp3_qt_number_o : out std_logic_vector(0 downto 0)
    );
end entity jpeg_header;



architecture IMP of jpeg_header is

	type states is (	st_start, st_search_ff, st_get_id, 
							
							st_sos_length1, st_sos_length2, st_sos_components, st_sos_id, st_sos_comp1_huff,
							st_sos_comp2_huff, st_sos_comp3_huff, st_sos_wait1, st_sos_wait2, st_sos_wait3,
							
							st_sof_length1, st_sof_length2, st_sof_precision, st_sof_height1, st_sof_height2, st_sof_width1,
							st_sof_width2, st_sof_components, st_sof_id, st_sof_comp1_sampl_factor, st_sof_comp1_qt_number,
							st_sof_comp2_sampl_factor, st_sof_comp2_qt_number, st_sof_comp3_sampl_factor, st_sof_comp3_qt_number,
							
							st_dht_length1, st_dht_length2, st_dht_info,
							st_dht_ht0_dc_table, st_dht_ht0_dc_symbols, st_dht_ht1_dc_table, st_dht_ht1_dc_symbols,
							st_dht_ht2_dc_table, st_dht_ht2_dc_symbols, st_dht_ht3_dc_table, st_dht_ht3_dc_symbols,
							st_dht_ht0_ac_table, st_dht_ht0_ac_symbols, st_dht_ht1_ac_table, st_dht_ht1_ac_symbols,
							st_dht_ht2_ac_table, st_dht_ht2_ac_symbols, st_dht_ht3_ac_table, st_dht_ht3_ac_symbols,
							
							st_dqt_length1, st_dqt_length2, st_dqt_info, st_dqt_qt0, st_dqt_qt1, st_dqt_qt2, st_dqt_qt3,
							
							st_other_length1, st_other_length2, st_skipfield1, 
							
							st_idle);
	
	
	
	
	signal state, 			next_state		: states := st_start;
	signal header_valid,	next_header_valid : std_logic :='0';
	signal header_select,next_header_select: std_logic :='0';
	signal error, 			next_error		: std_logic :='0';
	signal counter1,		next_counter1	: std_logic_vector(15 downto 0):=X"0000";
	signal counter2,		next_counter2	: std_logic_vector(15 downto 0):=X"0000";
	
-- header data
	-- sos-field
	signal next_components, 			components 		: std_logic_vector(7 downto 0):=X"00";
	signal next_comp1_huff_dc,			comp1_huff_dc	: std_logic_vector(3 downto 0):=X"0";
	signal next_comp2_huff_dc,			comp2_huff_dc	: std_logic_vector(3 downto 0):=X"0";
	signal next_comp3_huff_dc,			comp3_huff_dc	: std_logic_vector(3 downto 0):=X"0";
	signal next_comp1_huff_ac,			comp1_huff_ac	: std_logic_vector(3 downto 0):=X"0";
	signal next_comp2_huff_ac,			comp2_huff_ac	: std_logic_vector(3 downto 0):=X"0";
	signal next_comp3_huff_ac,			comp3_huff_ac	: std_logic_vector(3 downto 0):=X"0";

	--sof-field
	signal next_height,					height : std_logic_vector(15 downto 0):=X"0000";
	signal next_width,					width : std_logic_vector(15 downto 0):=X"0000";
	signal next_precision,				precision : std_logic_vector(7 downto 0):=X"00";
	-- for signal components use registe defined in sos-field
	signal next_comp1_sampl_factor,	comp1_sampl_factor : std_logic_vector(7 downto 0):=X"00";
	signal next_comp1_qt_number,		comp1_qt_number : std_logic_vector(7 downto 0):=X"00";
	signal next_comp2_sampl_factor,	comp2_sampl_factor : std_logic_vector(7 downto 0):=X"00";
	signal next_comp2_qt_number,		comp2_qt_number : std_logic_vector(7 downto 0):=X"00";
	signal next_comp3_sampl_factor,	comp3_sampl_factor : std_logic_vector(7 downto 0):=X"00";
	signal next_comp3_qt_number,		comp3_qt_number : std_logic_vector(7 downto 0):=X"00";
	 
	-- dht-field
	signal next_nr_of_ht0_codes_ac,	nr_of_ht0_codes_ac : std_logic_vector(7 downto 0):=X"00";
	signal next_nr_of_ht0_codes_dc,	nr_of_ht0_codes_dc : std_logic_vector(7 downto 0):=X"00";
	signal next_nr_of_ht1_codes_ac,	nr_of_ht1_codes_ac : std_logic_vector(7 downto 0):=X"00";
	signal next_nr_of_ht1_codes_dc,	nr_of_ht1_codes_dc : std_logic_vector(7 downto 0):=X"00";
	signal next_nr_of_ht2_codes_ac,	nr_of_ht2_codes_ac : std_logic_vector(7 downto 0):=X"00";
	signal next_nr_of_ht2_codes_dc,	nr_of_ht2_codes_dc : std_logic_vector(7 downto 0):=X"00";
	signal next_nr_of_ht3_codes_ac,	nr_of_ht3_codes_ac : std_logic_vector(7 downto 0):=X"00";
	signal next_nr_of_ht3_codes_dc,	nr_of_ht3_codes_dc : std_logic_vector(7 downto 0):=X"00";
	-- initialize the huffmann tables located in the huffmann-decoder entity
	signal next_ht_symbols_wea,		ht_symbols_wea		: std_logic :='0';
	signal next_ht_tables_wea,			ht_tables_wea		: std_logic :='0';
	signal next_ht_select,				ht_select			: std_logic_vector(2 downto 0):="000";		-- bit 2: dc (low) or ac (high), bit 1 and 0: table-nr.
		
	
	-- dqt-field
	-- initialize the quantisation tables located in the dequantisation entity
	signal next_qt_wea,		qt_wea		: std_logic :='0';
	signal next_qt_select,	qt_select	: std_logic_vector(1 downto 0) :="00";
	
	-- other fields
	signal next_otherlength, otherlength : std_logic_vector(15 downto 0) :=X"0000";

begin

--------------------------------------------------------------
-- Signale von/nach draussen
--------------------------------------------------------------

	header_valid_o <= header_valid;
	header_select_o<= header_select;
	header_error_o <= error;

	-- dht-field
	ht_symbols_wea_o		<= ht_symbols_wea;
	ht_tables_wea_o		<= ht_tables_wea;
	ht_select_o				<= ht_select;
	ht_tables_address_o	<= counter1(7 downto 0); 
	ht_nr_of_symbols_address_o	<= counter1(3 downto 0);
	ht_data_o 				<= data_i;
	
	-- sos-field
	comp1_huff_dc_o	<= comp1_huff_dc;
	comp2_huff_dc_o	<= comp2_huff_dc;
	comp3_huff_dc_o	<= comp3_huff_dc;
	comp1_huff_ac_o	<= comp1_huff_ac;
	comp2_huff_ac_o	<= comp2_huff_ac;
	comp3_huff_ac_o	<= comp3_huff_ac;

	--sof-field
	height_o					<= height;
	width_o					<= width;
	comp1_qt_number_o		<= comp1_qt_number(0 downto 0);
	comp2_qt_number_o		<= comp2_qt_number(0 downto 0);
	comp3_qt_number_o		<= comp3_qt_number(0 downto 0);

	process(comp1_sampl_factor, comp2_sampl_factor, comp3_sampl_factor)
		variable sampl_factor : std_logic_vector(23 downto 0):=(others=>'0');
	begin
		sampl_factor := comp1_sampl_factor & comp2_sampl_factor & comp3_sampl_factor;
		case sampl_factor is
			when X"111111"	=> sampling_o <= "11";		-- 4:4:4  MDU = 8x8
			when X"211111"	=> sampling_o <= "10";		-- 4:2:2  MDU = 16x8
			when X"221111"	=> sampling_o <= "01";		-- 4:2:0  MDU = 16x16
			when others 	=>	sampling_o <= "00";		-- gray	 MDU = 8x8    (same as no upsampling)
		end case;
	end process;

	-- dqt-field
	-- initialize the quantization tables located in the dequantization entity
	qt_wea_o 	<= qt_wea;
	qt_select_o	<=	qt_select;
	qt_data_o	<=	data_i;
--------------------------------------------------------------



	
	process(eoi_i, header_select)
	begin
		next_header_select <= header_select;
		if eoi_i='1' then
			next_header_select <= not header_select;
		end if;
	end process;




	
	
	process(	data_i, datavalid_i, state, reset_i, eoi_i, counter1, counter2, error,
				components, comp1_huff_dc, comp2_huff_dc, comp3_huff_dc, comp1_huff_ac, comp2_huff_ac, comp3_huff_ac,
				height, width, precision,
				comp1_sampl_factor, comp1_qt_number, comp2_sampl_factor, comp2_qt_number, comp3_sampl_factor, comp3_qt_number,
				nr_of_ht0_codes_ac, nr_of_ht0_codes_dc, nr_of_ht1_codes_ac, nr_of_ht1_codes_dc,
				nr_of_ht2_codes_ac, nr_of_ht2_codes_dc, nr_of_ht3_codes_ac, nr_of_ht3_codes_dc,
				ht_select, qt_select, otherlength)
	begin
	
	next_state			<= state;
	next_header_valid	<= '0';	
	next_error			<= error;
	next_counter1		<= counter1;
	next_counter2		<= counter2;
	
	-- sos field
	next_components			<= components;
	next_comp1_huff_dc		<= comp1_huff_dc;
	next_comp2_huff_dc		<= comp2_huff_dc;
	next_comp3_huff_dc		<= comp3_huff_dc;
	next_comp1_huff_ac		<= comp1_huff_ac;
	next_comp2_huff_ac		<= comp2_huff_ac;
	next_comp3_huff_ac		<= comp3_huff_ac;

	-- sof-field
	next_height					<= height;
	next_width					<= width;
	next_precision				<= precision; 
	next_components			<= components; -- use register from sos-field
	next_comp1_sampl_factor	<= comp1_sampl_factor;
	next_comp1_qt_number		<= comp1_qt_number;
	next_comp2_sampl_factor	<= comp2_sampl_factor;
	next_comp2_qt_number		<= comp2_qt_number;
	next_comp3_sampl_factor	<= comp3_sampl_factor;
	next_comp3_qt_number		<= comp3_qt_number;

	-- dht-field
	next_nr_of_ht0_codes_ac <= nr_of_ht0_codes_ac;
	next_nr_of_ht0_codes_dc <= nr_of_ht0_codes_dc;
	next_nr_of_ht1_codes_ac <= nr_of_ht1_codes_ac;
	next_nr_of_ht1_codes_dc <= nr_of_ht1_codes_dc;
	next_nr_of_ht2_codes_ac <= nr_of_ht2_codes_ac;
	next_nr_of_ht2_codes_dc <= nr_of_ht2_codes_dc;
	next_nr_of_ht3_codes_ac <= nr_of_ht3_codes_ac;
	next_nr_of_ht3_codes_dc <= nr_of_ht3_codes_dc;
	next_ht_symbols_wea	<= '0';
	next_ht_tables_wea		<= '0';
	next_ht_select			<= ht_select;
	
	-- dqt-field
	next_qt_wea 	<= '0';
	next_qt_select	<=	qt_select;
	
	-- other field
	next_otherlength	<= otherlength;



	case state is

-----------------------------------------------------			
-- START
-----------------------------------------------------
		when st_start =>
			if (datavalid_i='1') and (data_i=X"FF") then
				next_state <= st_start;
				next_counter1 <= X"0001";
			elsif (datavalid_i='1') and (data_i=X"D8") and counter1=X"0001" then
				next_state		<= st_search_ff;
				next_counter1 <= X"0000";
			else
				next_state <= st_start;
				next_counter1 <= X"0000";
			end if;

-----------------------------------------------------			
-- SEARCH_FF
-----------------------------------------------------
		when st_search_ff =>
			next_state <= st_search_ff;	
			if (datavalid_i='1') and (data_i=X"FF") then
				next_state <= st_get_id;	
			end if;


-----------------------------------------------------			
-- GET_ID
-----------------------------------------------------
		when st_get_id =>
			if (datavalid_i='1') then
			case data_i is
				when X"DA" =>
					next_state <= st_sos_length1;
				when X"DB" =>
					next_state <= st_dqt_length1;
				when X"C4" =>
					next_state <= st_dht_length1;
				when X"C0" =>
					next_state <= st_sof_length1;
				when X"FF" =>
					next_state <= st_get_id;
				when X"E0" | X"FE" | X"E1" | X"EE"  =>				-- carefull: try only to skip that sort of fields which actually have length-bytes
					next_state <= st_other_length1;
				when others =>
					next_state <= st_search_ff;
			end case;
			end if;


-----------------------------------------------------			
-- SOS
-----------------------------------------------------
		when st_sos_length1 => 
			if (datavalid_i='1') then
				next_state <= st_sos_length2; 
			end if;
		when st_sos_length2 => 
			if (datavalid_i='1') then
				next_state <= st_sos_components; 
			end if;
		when st_sos_components => 
			if (datavalid_i='1') then
				next_counter1 <= (others=>'0');
				next_components <= data_i;
				next_state <= st_sos_id; 
				if ((data_i /= 1) and (data_i /= 3)) then
					next_error <= '1';
					next_state <= st_idle;
				end if;
			end if;
		when st_sos_id => 
			if (datavalid_i='1') then
				next_counter1 <= counter1+1;
				if (data_i = 1) then
					next_state <= st_sos_comp1_huff; 
				elsif(data_i = 2) then
					next_state <= st_sos_comp2_huff; 
				elsif(data_i = 3) then
					next_state <= st_sos_comp3_huff; 
				else
					next_error <= '1';
					next_state <= st_idle;
				end if;
			end if;
		when st_sos_comp1_huff => 
			if (datavalid_i='1') then
				next_comp1_huff_dc <= data_i(7 downto 4);
				next_comp1_huff_ac <= data_i(3 downto 0);
				if (components = counter1(7 downto 0)) then
					next_state <= st_sos_wait1; 
				else
					next_state <= st_sos_id;
				end if;
			end if;
		when st_sos_comp2_huff => 
			if (datavalid_i='1') then
				next_comp2_huff_dc <= data_i(7 downto 4);
				next_comp2_huff_ac <= data_i(3 downto 0);
				if (components = counter1(7 downto 0)) then
					next_state <= st_sos_wait1; 
				else
					next_state <= st_sos_id;
				end if;
			end if;
		when st_sos_comp3_huff => 
			if (datavalid_i='1') then
				next_comp3_huff_dc <= data_i(7 downto 4);
				next_comp3_huff_ac <= data_i(3 downto 0);
				if (components = counter1(7 downto 0)) then
					next_state <= st_sos_wait1; 
				else
					next_state <= st_sos_id;
				end if;
			end if;
		when st_sos_wait1 =>
			if (datavalid_i='1') then
				next_state <= st_sos_wait2; 
			end if;
		when st_sos_wait2 =>
			if (datavalid_i='1') then
				next_state <= st_sos_wait3; 
			end if;
		when st_sos_wait3 =>
			if (datavalid_i='1') then
				next_header_valid <= not error;
				next_state <= st_idle; 
			end if;

		
-----------------------------------------------------			
-- DQT
-- * counter1: address for bram (and control variable)
-- * counter2: used to check if the field is at the end or if
--             another table is appended
-----------------------------------------------------
		when st_dqt_length1 => 
			if (datavalid_i='1') then
				next_counter2(15 downto 8) <= data_i;
				next_state <= st_dqt_length2; 
			end if;
		when st_dqt_length2 => 
			if (datavalid_i='1') then
				next_counter2 <= (counter2(15 downto 8) & data_i)-2;
				next_state <= st_dqt_info;
			end if;
		when st_dqt_info =>
			if (datavalid_i='1') then
				next_counter1 <= (others => '0');
				next_counter2 <= counter2 - 1;
				next_state <= st_dqt_info; 
				case data_i(3 downto 0) is
					when "0000" =>
						next_qt_select <= "00";
						next_state <= st_dqt_qt0;
						next_qt_wea <= '1';		
					when "0001" =>
						next_qt_select <= "01";
						next_state <= st_dqt_qt1;
						next_qt_wea <= '1';		
					when "0010" =>
						next_qt_select <= "10";
						next_state <= st_dqt_qt2;
						next_qt_wea <= '1';		
					when "0011" =>
						next_qt_select <= "11";
						next_state <= st_dqt_qt3;
						next_qt_wea <= '1';		
					when others =>	
						next_error <= '1';
						next_state <= st_idle;
				end case;
				if data_i(7 downto 4) /= "00" then			-- 16bit-precision not supported
					next_error <= '1';
					next_state <= st_idle;		
				end if;
			end if;
		when st_dqt_qt0 =>
			if (datavalid_i='1') then	
				next_counter1 <= counter1 + 1;
				next_counter2 <= counter2 - 1;
				next_qt_wea <= '1';		
				if (counter2=1) then
					next_qt_wea <= '0';	
					next_state <= st_search_ff;
				elsif (counter1 = 63) then
					next_qt_wea <= '0'; 
					next_state <= st_dqt_info;
				else
					next_qt_wea <= '1';
					next_state <= st_dqt_qt0;
				end if;
			end if;
		when st_dqt_qt1 =>
			if (datavalid_i='1') then	
				next_counter1 <= counter1 + 1;
				next_counter2 <= counter2 - 1;		
				next_qt_wea <= '1';
				if (counter2=1) then
					next_qt_wea <= '0'; 
					next_state <= st_search_ff;
				elsif (counter1 = 63) then 
					next_qt_wea <= '0'; 
					next_state <= st_dqt_info;
				else
					next_qt_wea <= '1';
					next_state <= st_dqt_qt1;
				end if;
			end if;
		when st_dqt_qt2 =>
			if (datavalid_i='1') then	
				next_counter1 <= counter1 + 1;
				next_counter2 <= counter2 - 1;
				next_qt_wea <= '1';
				if (counter2=1) then
					next_qt_wea <= '0';
					next_state <= st_search_ff;
				elsif (counter1 = 63) then 
					next_qt_wea <= '0';
					next_state <= st_dqt_info;
				else
					next_qt_wea <= '1';
					next_state <= st_dqt_qt2;
				end if;
			end if;
		when st_dqt_qt3 =>
			if (datavalid_i='1') then	
				next_counter1 <= counter1 + 1;
				next_counter2 <= counter2 - 1;
				next_qt_wea <= '1';	
				if (counter2=1) then
					next_qt_wea <= '0';
					next_state <= st_search_ff;
				elsif (counter1 = 63) then 
					next_qt_wea <= '0';
					next_state <= st_dqt_info;
				else
					next_qt_wea <= '1';
					next_state <= st_dqt_qt3;
				end if;
			end if;

-----------------------------------------------------			
-- DHT
-- * counter1: address for bram (and control variable)
-- * counter2: used to check if the field is at the end or if
--             another table is appended
-----------------------------------------------------
		when st_dht_length1 => 
			if (datavalid_i='1') then
				next_counter2(15 downto 8) <= data_i;
				next_state <= st_dht_length2; 
			end if;
		when st_dht_length2 => 
			if (datavalid_i='1') then
				next_counter2 <= (counter2(15 downto 8) & data_i)-2;
				next_state <= st_dht_info;
			end if;
		when st_dht_info =>
			if (datavalid_i='1') then
				next_counter1 <= (others => '0');
				next_counter2 <= counter2 - 1;
				next_state <= st_dht_info; 
				case data_i(4 downto 0) is
					when "00000" =>
						next_ht_symbols_wea <= '1';
						next_ht_select <= "000";
						next_state <= st_dht_ht0_dc_symbols;
						next_nr_of_ht0_codes_dc <= (others =>'0');
					when "00001" =>
						next_ht_symbols_wea <= '1';
						next_ht_select <= "001";
						next_state <= st_dht_ht1_dc_symbols;
						next_nr_of_ht1_codes_dc <= (others =>'0');
					when "00010" =>
						next_ht_symbols_wea <= '1';
						next_ht_select <= "010";
						next_state <= st_dht_ht2_dc_symbols;
						next_nr_of_ht2_codes_dc <= (others =>'0');
					when "00011" =>
						next_ht_symbols_wea <= '1';
						next_ht_select <= "011";
						next_state <= st_dht_ht3_dc_symbols;
						next_nr_of_ht3_codes_dc <= (others =>'0');
					when "10000" =>
						next_ht_symbols_wea <= '1';
						next_ht_select <= "100";
						next_state <= st_dht_ht0_ac_symbols;		
						next_nr_of_ht0_codes_ac <= (others =>'0');
					when "10001" =>
						next_ht_symbols_wea <= '1';
						next_ht_select <= "101";
						next_state <= st_dht_ht1_ac_symbols;
						next_nr_of_ht1_codes_ac <= (others =>'0');
					when "10010" =>
						next_ht_symbols_wea <= '1';
						next_ht_select <= "110";
						next_state <= st_dht_ht2_ac_symbols;
						next_nr_of_ht2_codes_ac <= (others =>'0');
					when "10011" =>
						next_ht_symbols_wea <= '1';
						next_ht_select <= "111";
						next_state <= st_dht_ht3_ac_symbols;
						next_nr_of_ht3_codes_ac <= (others =>'0');
					when others =>	
						next_ht_symbols_wea <= '0';
						next_error <= '1';
						next_state <= st_idle;
				end case;
			end if;
		when st_dht_ht0_dc_symbols =>
			if (datavalid_i='1') then	
				next_counter1 <= counter1 + 1;
				next_counter2 <= counter2 - 1;		
				next_nr_of_ht0_codes_dc <= nr_of_ht0_codes_dc + data_i;
				next_ht_symbols_wea <= '1';
				next_state <= st_dht_ht0_dc_symbols;
				if (counter1=15) then
					next_counter1 <= (others=>'0');
					next_ht_tables_wea <= '1';
					next_ht_symbols_wea <= '0';
					next_state <= st_dht_ht0_dc_table;
				end if;
			end if;
		when st_dht_ht0_dc_table =>
			if (datavalid_i='1') then		
				next_counter1 <= counter1 + 1;
				next_counter2 <= counter2 - 1;	
				next_ht_tables_wea <= '1';
				if (counter2=1) then
					next_ht_tables_wea <= '0';
					next_state <= st_search_ff;
				elsif (counter1 = nr_of_ht0_codes_dc-1) then 
					next_ht_tables_wea <= '0';
					next_state <= st_dht_info;
				else
					next_ht_tables_wea <= '1';
					next_state <= st_dht_ht0_dc_table;
				end if;
			end if;
		when st_dht_ht1_dc_symbols =>
			if (datavalid_i='1') then	
				next_counter1 <= counter1 + 1;
				next_counter2 <= counter2 - 1;		
				next_nr_of_ht1_codes_dc <= nr_of_ht1_codes_dc + data_i;
				next_ht_symbols_wea <= '1';
				next_state <= st_dht_ht1_dc_symbols;
				if (counter1=15) then
					next_ht_symbols_wea <= '0';
					next_ht_tables_wea <= '1';
					next_counter1 <= (others=>'0');
					next_state <= st_dht_ht1_dc_table;
				end if;
			end if;
		when st_dht_ht1_dc_table =>
			if (datavalid_i='1') then		
				next_counter1 <= counter1 + 1;
				next_counter2 <= counter2 - 1;
				next_ht_tables_wea <= '1';
				if (counter2=1) then
					next_ht_tables_wea <= '0';
					next_state <= st_search_ff;
				elsif (counter1 = nr_of_ht1_codes_dc-1) then 
					next_ht_tables_wea <= '0';
					next_state <= st_dht_info;
				else
					next_ht_tables_wea <= '1';
					next_state <= st_dht_ht1_dc_table;
				end if;
			end if;
		when st_dht_ht2_dc_symbols =>
			if (datavalid_i='1') then	
				next_counter1 <= counter1 + 1;
				next_counter2 <= counter2 - 1;		
				next_nr_of_ht2_codes_dc <= nr_of_ht2_codes_dc + data_i;
				next_ht_symbols_wea <= '1';
				next_state <= st_dht_ht2_dc_symbols;
				if (counter1=15) then
					next_ht_symbols_wea <= '0';
					next_ht_tables_wea <= '1';
					next_counter1 <= (others=>'0');
					next_state <= st_dht_ht2_dc_table;
				end if;
			end if;
		when st_dht_ht2_dc_table =>
			if (datavalid_i='1') then		
				next_counter1 <= counter1 + 1;
				next_counter2 <= counter2 - 1;
				next_ht_tables_wea <= '1';
				if (counter2=1) then
					next_ht_tables_wea <= '0';
					next_state <= st_search_ff;
				elsif (counter1 = nr_of_ht2_codes_dc-1) then 
					next_ht_tables_wea <= '0';
					next_state <= st_dht_info;
				else
					next_ht_tables_wea <= '1';
					next_state <= st_dht_ht2_dc_table;
				end if;
			end if;
		when st_dht_ht3_dc_symbols =>
			if (datavalid_i='1') then	
				next_counter1 <= counter1 + 1;
				next_counter2 <= counter2 - 1;		
				next_nr_of_ht3_codes_dc <= nr_of_ht3_codes_dc + data_i;
				next_ht_symbols_wea <= '1';
				next_state <= st_dht_ht3_dc_symbols;
				if (counter1=15) then
					next_ht_symbols_wea <= '0';
					next_ht_tables_wea <= '1';
					next_counter1 <= (others=>'0');
					next_state <= st_dht_ht3_dc_table;
				end if;
			end if;
		when st_dht_ht3_dc_table =>
			if (datavalid_i='1') then		
				next_counter1 <= counter1 + 1;
				next_counter2 <= counter2 - 1;
				next_ht_tables_wea <= '1';
				if (counter2=1) then
					next_ht_tables_wea <= '0';
					next_state <= st_search_ff;
				elsif (counter1 = nr_of_ht3_codes_dc-1) then 
					next_ht_tables_wea <= '0';
					next_state <= st_dht_info;
				else
					next_ht_tables_wea <= '1';
					next_state <= st_dht_ht3_dc_table;
				end if;
			end if;
		when st_dht_ht0_ac_symbols =>
			if (datavalid_i='1') then	
				next_counter1 <= counter1 + 1;
				next_counter2 <= counter2 - 1;		
				next_nr_of_ht0_codes_ac <= nr_of_ht0_codes_ac + data_i;
				next_ht_symbols_wea <= '1';
				next_state <= st_dht_ht0_ac_symbols;
				if (counter1=15) then
					next_ht_symbols_wea <= '0';
					next_ht_tables_wea <= '1';
					next_counter1 <= (others=>'0');
					next_state <= st_dht_ht0_ac_table;
				end if;
			end if;
		when st_dht_ht0_ac_table =>
			if (datavalid_i='1') then		
				next_counter1 <= counter1 + 1;
				next_counter2 <= counter2 - 1;	
				next_ht_tables_wea <= '0';
				if (counter2=1) then
					next_ht_tables_wea <= '0';
					next_state <= st_search_ff;
				elsif (counter1 = nr_of_ht0_codes_ac-1) then 
					next_ht_tables_wea <= '0';
					next_state <= st_dht_info;
				else
					next_ht_tables_wea <= '1';
					next_state <= st_dht_ht0_ac_table;
				end if;
			end if;
		when st_dht_ht1_ac_symbols =>
			if (datavalid_i='1') then	
				next_counter1 <= counter1 + 1;
				next_counter2 <= counter2 - 1;		
				next_nr_of_ht1_codes_ac <= nr_of_ht1_codes_ac + data_i;
				next_ht_symbols_wea <= '1';
				next_state <= st_dht_ht1_ac_symbols;
				if (counter1=15) then
					next_ht_symbols_wea <= '0';
					next_ht_tables_wea <= '1';
					next_counter1 <= (others=>'0');
					next_state <= st_dht_ht1_ac_table;
				end if;
			end if;
		when st_dht_ht1_ac_table =>
			if (datavalid_i='1') then		
				next_counter1 <= counter1 + 1;
				next_counter2 <= counter2 - 1;	
				next_ht_tables_wea <= '0';
				if (counter2=1) then
					next_ht_tables_wea <= '0';
					next_state <= st_search_ff;
				elsif (counter1 = nr_of_ht1_codes_ac-1) then 
					next_ht_tables_wea <= '0';
					next_state <= st_dht_info;
				else
					next_ht_tables_wea <= '1';
					next_state <= st_dht_ht1_ac_table;
				end if;
			end if;
		when st_dht_ht2_ac_symbols =>
			if (datavalid_i='1') then	
				next_counter1 <= counter1 + 1;
				next_counter2 <= counter2 - 1;		
				next_nr_of_ht2_codes_ac <= nr_of_ht2_codes_ac + data_i;
				next_ht_symbols_wea <= '1';
				next_state <= st_dht_ht2_ac_symbols;
				if (counter1=15) then
					next_ht_symbols_wea <= '0';
					next_ht_tables_wea <= '1';
					next_counter1 <= (others=>'0');
					next_state <= st_dht_ht2_ac_table;
				end if;
			end if;
		when st_dht_ht2_ac_table =>
			if (datavalid_i='1') then		
				next_counter1 <= counter1 + 1;
				next_counter2 <= counter2 - 1;
				next_ht_tables_wea <= '0';
				if (counter2=1) then
					next_ht_tables_wea <= '0';
					next_state <= st_search_ff;
				elsif (counter1 = nr_of_ht2_codes_ac-1) then 
					next_ht_tables_wea <= '0';
					next_state <= st_dht_info;
				else
					next_ht_tables_wea <= '1';
					next_state <= st_dht_ht2_ac_table;
				end if;
			end if;
		when st_dht_ht3_ac_symbols =>
			if (datavalid_i='1') then	
				next_counter1 <= counter1 + 1;
				next_counter2 <= counter2 - 1;		
				next_nr_of_ht3_codes_ac <= nr_of_ht3_codes_ac + data_i;
				next_ht_symbols_wea <= '1';
				next_state <= st_dht_ht3_ac_symbols;
				if (counter1=15) then
					next_ht_symbols_wea <= '0';
					next_ht_tables_wea <= '1';
					next_counter1 <= (others=>'0');
					next_state <= st_dht_ht3_ac_table;
				end if;
			end if;
		when st_dht_ht3_ac_table =>
			if (datavalid_i='1') then		
				next_counter1 <= counter1 + 1;
				next_counter2 <= counter2 - 1;	
				next_ht_tables_wea <= '0';
				if (counter2=1) then
					next_ht_tables_wea <= '0';
					next_state <= st_search_ff;
				elsif (counter1 = nr_of_ht3_codes_ac-1) then 
					next_ht_tables_wea <= '0';
					next_state <= st_dht_info;
				else
					next_ht_tables_wea <= '1';
					next_state <= st_dht_ht3_ac_table;
				end if;
			end if;


-------------------------------------------------------			
---- SOF
-------------------------------------------------------
		when st_sof_length1 => 
			if (datavalid_i='1') then
				next_state <= st_sof_length2; 
			end if;
		when st_sof_length2 => 
			if (datavalid_i='1') then
				next_state <= st_sof_precision; 
			end if;
		when st_sof_precision => 
			if (datavalid_i='1') then
				next_precision <= data_i;	
				next_state <= st_sof_height1; 
				if (data_i /= 8) then
					next_error <= '1';
					next_state <= st_idle;
				end if;
			end if;
		when st_sof_height1 => 
			if (datavalid_i='1') then
				next_height(15 downto 8) <= data_i;
				next_state <= st_sof_height2; 
			end if;
		when st_sof_height2 => 
			if (datavalid_i='1') then
				next_height(7 downto 0) <= data_i;
				next_state <= st_sof_width1; 
			end if;
		when st_sof_width1 => 
			if (datavalid_i='1') then
				next_width(15 downto 8) <= data_i;
				next_state <= st_sof_width2; 
			end if;
		when st_sof_width2 => 
			if (datavalid_i='1') then
				next_width(7 downto 0) <= data_i;
				next_state <= st_sof_components; 
			end if;
		when st_sof_components => 
			if (datavalid_i='1') then
				next_components <= data_i;
				next_counter1 <= (others => '0');
				next_state <= st_sof_id; 
				if ((data_i /= 1) and (data_i /= 3)) then
					next_error <= '1';
					next_state <= st_idle;
				end if;
			end if;
		when st_sof_id => 
			if (datavalid_i='1') then
				next_counter1 <= counter1+1;
				if (data_i = 1) then
					next_state <= st_sof_comp1_sampl_factor; 
				elsif(data_i = 2) then
					next_state <= st_sof_comp2_sampl_factor; 
				elsif(data_i = 3) then
					next_state <= st_sof_comp3_sampl_factor; 
				else
					next_error <= '1';
					next_state <= st_idle;
				end if;
			end if;			
		when st_sof_comp1_sampl_factor => 
			if (datavalid_i='1') then
				next_comp1_sampl_factor <= data_i;
				next_state <= st_sof_comp1_qt_number; 
			end if;
		when st_sof_comp1_qt_number => 
			if (datavalid_i='1') then
				next_comp1_qt_number <= data_i;
				if (components = counter1(7 downto 0)) then
					next_state <= st_search_ff; 
				else
					next_state <= st_sof_id;
				end if;
			end if;
		when st_sof_comp2_sampl_factor => 
			if (datavalid_i='1') then
				next_comp2_sampl_factor <= data_i;
				next_state <= st_sof_comp2_qt_number; 
			end if;
		when st_sof_comp2_qt_number => 
			if (datavalid_i='1') then
				next_comp2_qt_number <= data_i;
				if (components = counter1(7 downto 0)) then
					next_state <= st_search_ff; 
				else
					next_state <= st_sof_id;
				end if;
			end if;
		when st_sof_comp3_sampl_factor => 
			if (datavalid_i='1') then
				next_comp3_sampl_factor <= data_i;
				next_state <= st_sof_comp3_qt_number; 
			end if;
		when st_sof_comp3_qt_number => 
			if (datavalid_i='1') then
				next_comp3_qt_number <= data_i;
				if (components = counter1(7 downto 0)) then
					next_state <= st_search_ff; 
				else
					next_state <= st_sof_id;
				end if;
			end if;
			
			
-------------------------------------------------------			
-- Get length for app0- and com-field and skip it
-- (this is done because these fields may contain 
--  "FFxx"-Bytes (e.g. in thumbnail pictures) that 
--  are not to be interpreted) 
-------------------------------------------------------
		when st_other_length1 =>
			if (datavalid_i='1') then
				next_otherlength(15 downto 8) <= data_i;
				next_state <= st_other_length2; 
			end if;

		when st_other_length2 =>
			if (datavalid_i='1') then
				next_state <= st_skipfield1; 
				next_otherlength	<= (otherlength(15 downto 8) & data_i);
				if (otherlength(15 downto 8) & data_i) = 2 then 		-- handle empty fields
					next_state <= st_search_ff;
				end if;
			end if;
		
		when st_skipfield1 =>
			if (datavalid_i='1') then
				next_otherlength <= otherlength - 1;
				next_state <= st_skipfield1;
				if otherlength <= 5 then
					next_state <= st_search_ff;
				end if;
			end if;

-----------------------------------------------------			
-- IDLE
-----------------------------------------------------
		when st_idle =>
			next_header_valid <= not error;
			if (eoi_i)='1' then
				next_state <= st_start;
				next_header_valid <= '0';
			end if;
			
	end case; 		

-----------------------------------------------------			





-----------------------------------------------------			
-- RESET 
-----------------------------------------------------
	if (reset_i='1') then
		next_state 				<= st_start;
		next_header_valid 	<= '0';
		next_error				<= '0';
		next_counter1			<= (others=>'0');
		next_counter2			<= (others=>'0');


		-- sos field
		next_components 			<= X"00";
		next_comp1_huff_dc 		<= X"0";
		next_comp2_huff_dc 		<= X"0";
		next_comp3_huff_dc 		<= X"0";
		next_comp1_huff_ac 		<= X"0";
		next_comp2_huff_ac 		<= X"0";
		next_comp3_huff_ac 		<= X"0";
	
		-- sof-field
		next_height					<= X"0000";
		next_width					<= X"0000";
		next_precision				<= X"00";
		next_comp1_sampl_factor	<= X"00";
		next_comp1_qt_number		<= X"00";
		next_comp2_sampl_factor	<= X"00";
		next_comp2_qt_number		<= X"00";
		next_comp3_sampl_factor	<= X"00";
		next_comp3_qt_number		<= X"00";
		
		-- dht-field
		next_nr_of_ht0_codes_ac <= (others=>'0');
		next_nr_of_ht0_codes_dc <= (others=>'0');
		next_nr_of_ht1_codes_ac <= (others=>'0');
		next_nr_of_ht1_codes_dc <= (others=>'0');
		next_nr_of_ht2_codes_ac <= (others=>'0');
		next_nr_of_ht2_codes_dc <= (others=>'0');
		next_nr_of_ht3_codes_ac <= (others=>'0');
		next_nr_of_ht3_codes_dc <= (others=>'0');
		next_ht_symbols_wea		<= '0';
		next_ht_tables_wea			<= '0';
		next_ht_select				<= (others=>'0');

		-- dqt-field
		next_qt_wea 	<= '0';
		next_qt_select	<=	(others=>'0');
		
		-- other field
		next_otherlength <= (others =>'0');
		
	end if;
-----------------------------------------------------	

	end process;
-------------------------------------------

	
	
	
-------------------------------------------
-- Update registers on rising edge
-------------------------------------------
	process(Clk)
	begin
		if (rising_edge(Clk)) then
			state 			<= next_state;
			header_valid	<= next_header_valid;	
			header_select	<= next_header_select;	
			error				<= next_error;
			counter1			<= next_counter1;
			counter2			<= next_counter2;
			
			-- sos field
			components 				<= next_components;
			comp1_huff_dc			<= next_comp1_huff_dc;
			comp2_huff_dc			<= next_comp2_huff_dc;
			comp3_huff_dc			<= next_comp3_huff_dc;
			comp1_huff_ac			<= next_comp1_huff_ac;
			comp2_huff_ac			<= next_comp2_huff_ac;
			comp3_huff_ac			<= next_comp3_huff_ac;
			
			-- sof-field
			height					<= next_height;
			width						<= next_width;
			precision				<= next_precision; 
			comp1_sampl_factor	<= next_comp1_sampl_factor;
			comp1_qt_number		<= next_comp1_qt_number;
			comp2_sampl_factor	<= next_comp2_sampl_factor;
			comp2_qt_number		<= next_comp2_qt_number;
			comp3_sampl_factor	<= next_comp3_sampl_factor;
			comp3_qt_number		<= next_comp3_qt_number;
			
			-- dht-field
			nr_of_ht0_codes_ac	<= next_nr_of_ht0_codes_ac;
			nr_of_ht0_codes_dc	<= next_nr_of_ht0_codes_dc;
			nr_of_ht1_codes_ac	<= next_nr_of_ht1_codes_ac;
			nr_of_ht1_codes_dc	<= next_nr_of_ht1_codes_dc;
			nr_of_ht2_codes_ac	<= next_nr_of_ht2_codes_ac;
			nr_of_ht2_codes_dc	<= next_nr_of_ht2_codes_dc;
			nr_of_ht3_codes_ac	<= next_nr_of_ht3_codes_ac;
			nr_of_ht3_codes_dc	<= next_nr_of_ht3_codes_dc;
			ht_symbols_wea			<= next_ht_symbols_wea;
			ht_tables_wea			<= next_ht_tables_wea;
			ht_select				<= next_ht_select;

			-- dqt-field
			qt_wea 		<=	next_qt_wea;
			qt_select	<=	next_qt_select;
			
			-- other field
			otherlength	<= next_otherlength;

		end if;
	end process;
--------------------------------------------

end IMP;

