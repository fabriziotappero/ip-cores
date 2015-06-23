--------------------------------------------------------------------
-- This entity is not very well written. A redesign may not be the worst idea.
--------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity jpeg_check_FF is
  port
    (	Clk				: in  std_logic;
		reset_i			: in  std_logic;
		header_valid_i	: in  std_logic;
		header_select_i: in  std_logic;
		eoi_o				: out std_logic :='0';

		data_i			: in  std_logic_vector(7 downto 0);
		data_o			: out std_logic_vector(7 downto 0);

		-- bit occupancy
		-- 0: header_valid
		-- 1: header_select
		-- 2: end of block
		-- 3: end of image
		context_o		: out std_logic_vector(3 downto 0);	
	
		-- flow control
		datavalid_i 	: in  std_logic;
		datavalid_o 	: out std_logic;
		ready_i			: in  std_logic;
		ready_o			: out std_logic
    );
end entity jpeg_check_FF;





architecture IMP of jpeg_check_FF is

	signal data			: std_logic_vector(7 downto 0) :=(others => '0');
	signal ff_received, ff_received_D : std_logic :='0';
	signal eoi, eoi_D, eoi_for_context : std_logic :='0';		-- End of Image
	signal header_valid : std_logic :='0';

	signal context : std_logic_vector(3 downto 0) :=(others =>'0');

	-- flowcontroll
	signal datavalid : std_logic := '0';
	signal ce : std_logic :='0';
	signal reset : std_logic :='1';
	


begin

	ce 			<= datavalid_i and ready_i;
	datavalid	<= (ce and not ff_received_D and header_valid and header_valid_i)
						 or (context(3) and ready_i);	-- write random data with eoi-flag set in fifo
	datavalid_o <= datavalid;
	ready_o 		<= ce;
	reset 		<= reset_i;	
	context_o	<= context;	

	process(data_i, data, ff_received, ff_received_D)
	begin
			
		data			<= data;
		ff_received	<= ff_received;
		eoi 			<= '0';
		
		if(data_i=X"FF") then
			ff_received <= '1';
		else
			ff_received <= '0';
		end if;
	
		if(data_i=X"00" and ff_received_D='1') then
			data <= X"FF";
		elsif(data_i=X"D9" and ff_received_D='1') then
			eoi  <= '1';
			data <= (others=>'0');
		else
			data <= data_i;
		end if;
	
	end process;




	-- to write an "eoi"-word 
	process(Clk)
	begin	
		if rising_edge(Clk) then
--			eoi_for_context <=  eoi_for_context;
			if(datavalid='1' or reset='1') then
				eoi_for_context <= '0';
			elsif eoi='1' then
				eoi_for_context <= '1';
			end if;
		end if;
	end process;	


	context(3) <= eoi_for_context;
	process(Clk)
	begin
	if rising_edge(Clk) then
		if (reset='1') then
			eoi_o		<= '0';
			eoi_D		<=	'0';
			context(2 downto 0)	<= (others=>'0');
		else
			eoi_D		<= eoi;
			eoi_o		<= header_valid_i and eoi and not eoi_D;		-- use "rising_edge(eoi)" to prevent deadlock with input_fifo,
																					-- header_valid_i to prevent loop (under impropable circumstance)
			context(2 downto 0)	<= '0' & header_select_i & header_valid_i;
		end if;
	end if;
	end process;

	process(Clk)
	begin
		if rising_edge(Clk) then

			if reset='1' then
				data_o			<= (others=>'0');
				ff_received_D	<= '0';
				header_valid	<= '0';
			elsif ce ='1' then
				data_o			<= data;
				ff_received_D	<= ff_received;
				header_valid	<= header_valid_i;
			end if;
			
		end if;
	end process;
	
end IMP;
