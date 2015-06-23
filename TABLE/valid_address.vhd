library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
USE IEEE.STD_LOGIC_MISC.ALL;
entity valid_address is
generic (
        ADDR_WIDTH :integer := 10
    );
	port (
	clk: IN std_logic;
	reset : IN STD_LOGIC;
	in_wr_address : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
	in_wr: IN std_logic;
	in_rd : IN STD_LOGIC;
	in_key : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
	in_rm_address_no : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
	in_rm : IN STD_LOGIC;
	out_address : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
	out_rdy : OUT std_logic
	-------------------------------
--	full_out: OUT std_logic;
--	empty_out: OUT std_logic;
--	current_out: OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
--	last_out: OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
--	item_value_out: OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
--	item_ram_out : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
--	item_wr_out : OUT std_logic;
--	item_raddr_out: OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
--	item_waddr_out: OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
--	map_wr_out: OUT std_logic;
--	map_raddr_out: OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
--	map_waddr_out: OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
--	map_ram_out : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
--	map_value_out: OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
	);
end valid_address;

architecture Behavioral of valid_address is
-------------------------------------------------------------

	COMPONENT div_binary is 
	Port ( 

	ina : in std_logic_vector (11 downto 0);
	inb: in std_logic_vector (11 downto 0);
	quot: out std_logic_vector (11 downto 0)
	);

end COMPONENT div_binary; 
-------COMPONENET SMALL FIFO
		COMPONENT  small_fifo IS
	GENERIC(WIDTH :INTEGER := 8;
			MAX_DEPTH_BITS :INTEGER := 5);
	PORT(   
     SIGNAL din : IN STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);--input [WIDTH-1:0] din,     // Data in
     SIGNAL wr_en : IN STD_LOGIC;--input          wr_en,   // Write enable    
     SIGNAL rd_en : IN STD_LOGIC;--input          rd_en,   // Read the next word    
     SIGNAL dout :OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);--output reg [WIDTH-1:0]  dout,    // Data out
     SIGNAL full : OUT STD_LOGIC;--output         full,
     SIGNAL nearly_full : OUT STD_LOGIC;--output         nearly_full,
     SIGNAL empty : OUT STD_LOGIC;--output         empty,    	
     SIGNAL reset :IN STD_LOGIC;
     SIGNAL clk   :IN STD_LOGIC
	);
	END COMPONENT;
-------COMPONENET SMALL FIFO	
	TYPE state_type IS(IDLE,  ADD_1, ADD_2, REMOVE_1, REMOVE_2, REMOVE_3, REMOVE_4,REMOVE_5, READ_1, READ_2);
	SIGNAL state, state_next : state_type;
	attribute enum_encoding : string;
	attribute enum_encoding of state_type : type is "onehot";

------------------------------------------------------------

	SIGNAL item_raddr 			:  STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
	SIGNAL item_waddr 			:  STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
	SIGNAL item_value 			:  STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);	
	SIGNAL item_wr_en 			:  STD_LOGIC;
	SIGNAL item_ram 			:  STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
	SIGNAL item_raddr_i 		:  STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
	SIGNAL item_waddr_i 		:  STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
	SIGNAL item_value_i 		:  STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);	
	SIGNAL item_wr_en_i 		:  STD_LOGIC;

	
	SIGNAL map_raddr 			:  STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
	SIGNAL map_waddr 			:  STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
	SIGNAL map_value 			:  STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);	
	SIGNAL map_wr_en 			:  STD_LOGIC;
	SIGNAL map_ram 				:  STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
	SIGNAL map_raddr_i 			:  STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
	SIGNAL map_waddr_i 			:  STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
	SIGNAL map_value_i 			:  STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);	
	SIGNAL map_wr_en_i 			:  STD_LOGIC;

	
	SIGNAL last 				:  STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
	SIGNAL last_up 				:  STD_LOGIC;
	SIGNAL last_down 			:  STD_LOGIC;
	SIGNAL current 				:  STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
	SIGNAL current_up 			:  STD_LOGIC;
	SIGNAL last_i 				:  STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
	SIGNAL last_up_i 			:  STD_LOGIC;
	SIGNAL last_down_i 			:  STD_LOGIC;
	SIGNAL current_i 			:  STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
	SIGNAL current_up_i 		:  STD_LOGIC;
	SIGNAL out_rdy_i 			:  STD_LOGIC;
	SIGNAL out_rdy_ii 			:  STD_LOGIC;
	SIGNAL empty 				:  STD_LOGIC;
	SIGNAL full		 			:  STD_LOGIC;
	-------------Fifos Signals-------------------------------
	SIGNAL write_cmd_rd 		: STD_LOGIC;
	SIGNAL write_cmd_address 	:  STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
	SIGNAL write_cmd_empty 		: STD_LOGIC;       
	SIGNAL remove_cmd_rd 		: STD_LOGIC;
	SIGNAL remove_cmd_address 	:  STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
	SIGNAL remove_cmd_empty 	: STD_LOGIC;
	SIGNAL read_cmd_rd 			: STD_LOGIC;
	SIGNAL read_cmd_empty 		: STD_LOGIC;
	SIGNAL write_cmd_rd_i 		: STD_LOGIC;
	SIGNAL write_cmd_address_i 	:  STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
	SIGNAL write_cmd_empty_i 	: STD_LOGIC;       
	SIGNAL remove_cmd_rd_i 		: STD_LOGIC;
	SIGNAL remove_cmd_address_i :  STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
	SIGNAL remove_cmd_empty_i 	: STD_LOGIC;
	SIGNAL read_cmd_rd_i 		: STD_LOGIC;
	SIGNAL read_cmd_empty_i 	: STD_LOGIC;
	---------------------------------------------------------
	COMPONENT ram_256x48 is

	generic 
	(
		DATA_WIDTH : natural := ADDR_WIDTH;
		ADDR_WIDTH : natural := ADDR_WIDTH
	);

	port 
	(
		clk		: in std_logic;
		raddr	: in natural range 0 to 2**ADDR_WIDTH - 1;
		waddr	: in natural range 0 to 2**ADDR_WIDTH - 1;
		data	: in std_logic_vector((DATA_WIDTH-1) downto 0);
		we		: in std_logic := '1';
		q		: out std_logic_vector((DATA_WIDTH -1) downto 0)
	);

end COMPONENT ram_256x48;

begin
-------------timeout management code------------------------
-------------Fifos to collect all the commands for farther processing
	write_command_Inst :  small_fifo 
	GENERIC MAP(WIDTH  => ADDR_WIDTH,
			MAX_DEPTH_BITS  => 5)
	PORT MAP(				   
			  din =>in_wr_address,    
			  wr_en =>in_wr, 		
			  rd_en => write_cmd_rd,     
			  dout =>write_cmd_address,   
			  full =>open,
			  nearly_full =>open,
			  empty => write_cmd_empty,
			  reset => reset ,
			  clk  => clk 
	);
	remove_command_Inst :  small_fifo 
		GENERIC MAP(WIDTH  => ADDR_WIDTH,
				MAX_DEPTH_BITS  => 5)
		PORT MAP(				   
				  din =>in_rm_address_no,    
				  wr_en =>in_rm, 		
				  rd_en => remove_cmd_rd,       
				  dout =>remove_cmd_address,   
				  full =>open,
				  nearly_full =>open,
				  empty => remove_cmd_empty,
				  reset => reset ,
				  clk  => clk 
		);
	read_command_Inst :  small_fifo 
		GENERIC MAP(WIDTH  => 1,
				MAX_DEPTH_BITS  => 5)
		PORT MAP(				   
				  din =>"1",    
				  wr_en =>in_rd, 		
				  rd_en => read_cmd_rd,       
				  dout =>open,   
				  full =>open,
				  nearly_full =>open,
				  empty => read_cmd_empty,
				  reset => reset ,
				  clk  => clk 
		);
		
--Map between the Value and the address used  inside the table the address is provided by out side 
		valid_mac_Map_256x48_Inst : ram_256x48 

			GENERIC MAP	(
					DATA_WIDTH => ADDR_WIDTH, ADDR_WIDTH => ADDR_WIDTH)

				port MAP (
					clk			=>	 clk		,
					raddr	    =>	 CONV_INTEGER(map_raddr)			,
					waddr	    =>	 CONV_INTEGER(map_waddr)			,---last
					data	    =>	 map_value		,
					we		    =>	 map_wr_en		,
					q		    =>	 map_ram		
				);	
--	item_wr_out<=item_wr_en;
--	item_raddr_out<=item_raddr;
--	item_waddr_out<=item_waddr;
--	item_value_out<=item_value;
--	item_ram_out <=item_ram;
--	map_wr_out<=map_wr_en;
--	map_raddr_out<=map_raddr;
--	map_waddr_out<=map_waddr;
--	map_value_out<=map_value;
--	map_ram_out <=map_ram;
--Write new MAC inside the table the address is provided by out side 
		valid_mac_256x48_Inst : ram_256x48 

			GENERIC MAP	(
					DATA_WIDTH => ADDR_WIDTH, ADDR_WIDTH => ADDR_WIDTH)

				port MAP (
					clk			=>	 clk		,
					raddr	    =>	 CONV_INTEGER(item_raddr)			,
					waddr	    =>	 CONV_INTEGER(item_waddr)			,---last
					data	    =>	 item_value		,
					we		    =>	 item_wr_en		,
					q		    =>	 item_ram		
				);
			out_address			<= 	item_ram  ;
			
--			last_out <=item_waddr;
--			current_out <=item_raddr;
--			out_rdy <=item_wr_en;
	-----------------------------------------------------------------------	

		PROCESS(clk, reset)
				BEGIN
					IF reset= '1' THEN
								state	<=	IDLE	;
					ELSIF clk'EVENT AND clk = '1' THEN
								state		<=	state_next	;
								out_rdy <= out_rdy_ii;
								out_rdy_ii <= out_rdy_i;						
					END IF;		
	END PROCESS;
	
	PROCESS(state ,write_cmd_empty, remove_cmd_empty, read_cmd_empty )
		BEGIN
								state_next	<=	state	;
								
								
		CASE state IS
		WHEN IDLE => 
						
					IF (write_cmd_empty = '0')  THEN
								state_next	 	<= ADD_1;
					ELSIF (remove_cmd_empty = '0')  THEN
								state_next	 	<= REMOVE_1;
					ELSIF(read_cmd_empty = '0')THEN
								state_next	 	<= READ_1;
					END IF;
		WHEN ADD_1		=>	    state_next	 	<=	ADD_2	;			
		WHEN ADD_2		=>	    state_next	 	<=	IDLE	;			  							   
		WHEN REMOVE_1	=>	    state_next	 	<=	REMOVE_2	;			  							   
		WHEN REMOVE_2	=>	    state_next	 	<=	REMOVE_3	;							   
		WHEN REMOVE_3	=>	    state_next	 	<=	REMOVE_4	;
		WHEN REMOVE_4	=>	    state_next	 	<=	REMOVE_5	;	
		WHEN REMOVE_5	=>	    state_next	 	<=	IDLE	;						
		WHEN READ_1		=>	    state_next	 	<=	READ_2	;
		WHEN READ_2		=>	    state_next	 	<=	IDLE	;			  	
		WHEN OTHERS		=>	    state_next	 	<=	IDLE	;
			
		END CASE;
	END PROCESS;	
	----------------------------------------------------
--	div_Inst :  div_binary  
--	Port MAP ( 
--
--	ina =>in_key,
--	inb=>last,
--	quot => current
--	);

PROCESS(state, remove_cmd_address, last ,in_key,item_ram, write_cmd_address, full, map_ram)
		BEGIN
								
								last_up		<= '0' ;
								last_down 	<= '0' ;
								current_up_i	<= '0' ;
							    out_rdy_i		<= '0';
							    item_wr_en_i 	<= '0';
								item_raddr_i	<= (OTHERS=>'0');
								item_waddr_i	<= (OTHERS=>'0');
								item_value_i	<= (OTHERS=>'0');
								map_raddr_i		<= (OTHERS=>'0');
								map_waddr_i		<= (OTHERS=>'0');
								map_value_i		<= (OTHERS=>'0');
								map_wr_en_i		<= '0';
								item_raddr_i    <= current;
								write_cmd_rd	<='0';
								remove_cmd_rd	<= '0';
								read_cmd_rd 	<='0';
								
		CASE state IS
		WHEN ADD_1 => 			write_cmd_rd	<='1';	-- pop write fifo 					
		WHEN ADD_2	=>
							    map_waddr_i	 	<= write_cmd_address;
							    map_value_i		<= last ;
							    map_wr_en_i	 	<= NOT full;
							    item_value_i	<= write_cmd_address;
							    item_waddr_i    <= last  ;
							    item_wr_en_i 	<= NOT full;
							    last_up 		<= NOT full ;
							  
		WHEN REMOVE_1	=>	    remove_cmd_rd	<= '1'; 	-- pop remove fifo 
								last_down		<= '1';
		WHEN REMOVE_2	=>		map_raddr_i     <= remove_cmd_address;
							    item_raddr_i    <= last ;
							    
		WHEN REMOVE_3	=>		--map_raddr_i     <= remove_cmd_address;
							    --item_raddr_i    <= last ;
--								item_value_i	<= item_ram;--last
--							    item_waddr_i    <= map_ram ;--last address
--								item_wr_en_i 	 <= '1';
--							    map_waddr_i	 	<= item_ram;--Update the Map Ram=last
--							    map_value_i	 	<= map_ram;--last = deleted
--							    map_wr_en_i	 	<= '1';
							   
							  				   
		WHEN REMOVE_4	=>		item_value_i	<= item_ram;--last
							    item_waddr_i    <= map_ram ;--last address
							    item_wr_en_i 	 <= '1';
							    map_waddr_i	 	<= item_ram;--Update the Map Ram=last
							    map_value_i	 	<= map_ram;--last = deleted
							    map_wr_en_i	 	<= '1';
		WHEN REMOVE_5	=>		item_value_i	<= (OTHERS=>'0');--last
							    item_waddr_i    <= last ;--last address
							    item_wr_en_i 	 <= '1';
							    map_waddr_i	 	<= remove_cmd_address;--Update the Map Ram=last
							    map_value_i	 	<= (OTHERS=>'0');--last = deleted
							    map_wr_en_i	 	<= '1';
							   
							
		WHEN READ_1	=>			read_cmd_rd 	<='1';		-- pop read fifo 
							
								item_raddr_i    <= current;
								
		WHEN READ_2	=>		  		   
							    
							    out_rdy_i	 	<= '1';
							    current_up_i	<= '1' ;
	
		WHEN OTHERS	=>			

			
		END CASE;
	END PROCESS;
	-----------------Register Output
	process (clk)
	begin
		if (rising_edge(clk)) then

--								last_up 		<= 	last_up_i ;
--								last_down	 	<= 	last_down_i ;
								current_up		<= 	current_up_i ;
								item_wr_en		<= 	item_wr_en_i;
								item_raddr		<= 	item_raddr_i;
								item_waddr		<= 	item_waddr_i;
								item_value		<= 	item_value_i;
								map_raddr		<= 	map_raddr_i;
								map_waddr		<= 	map_waddr_i;
								map_value		<= 	map_value_i;
								map_wr_en		<= 	map_wr_en_i;
								item_raddr    	<= 	item_raddr_i;
--								write_cmd_rd	<=	write_cmd_rd_i;
--								remove_cmd_rd	<= 	remove_cmd_rd_i;
--								read_cmd_rd		<=	read_cmd_rd_i;
			end if;
		end PROCESS;
--------------------empty full controls----------------
   empty<='1' when last=1   else '0';
   full<='1'  when  AND_REDUCE(last)='1' else '0';
--   empty_out<=empty;
--	full_out<= full;
	----------------------last counter------------------
	process (clk,last)
		variable   cnt		   : integer range 0 to 2**ADDR_WIDTH-1;
	begin
		if (rising_edge(clk)) then

			if reset = '1' then
				-- Reset the counter to 0
				cnt := 0;

			elsif last_up = '1' then
				-- Increment the counter if counting is enabled			   
				cnt := cnt + 1;
			elsif last_down = '1' then
				-- Increment the counter if counting is enabled			   
				cnt := cnt - 1;

			end if;
		end if;

		-- Output the current count
		last <= std_logic_vector(to_unsigned(cnt, ADDR_WIDTH)); 
--		last_out <= last;
		END PROCESS;
----------------------last counter------------------
	process (clk)
		variable   cnt1		   : integer range 0 to 2**ADDR_WIDTH-1;
		variable   cnt2		   : integer range 0 to 2**ADDR_WIDTH-1;
	begin
		if (rising_edge(clk)) then

			if ( current + 1 >=  last )AND current_up = '1'  then
				-- Increment the counter if counting is enabled			   
				cnt1 :=0 ;
			elsif current_up = '1' then
				-- Increment the counter if counting is enabled			   
				cnt1 := cnt1 + 1;
			
		end if;
		end if;
		-- Output the current count
--		cnt2 := cnt1 mod CONV_INTEGER(last); 
		current <= std_logic_vector(to_unsigned(cnt1, ADDR_WIDTH));
--	   current_out <= current;

		END PROCESS;
---------------------------------------------------------
	
	END Behavioral;