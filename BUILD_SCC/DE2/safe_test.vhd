library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_bit.all;
use ieee.std_logic_arith.all;



entity safe_test is
generic(INPUT_LENGTH:integer:=6;OUTPUT_LENGTH:integer:=6);
	port(
		clk:in std_ulogic;
		rst:in std_ulogic;
		--Config Signals
		init_out:out std_ulogic;
		config_mode_out:out std_ulogic;
		config_out0:out std_ulogic;
		config_out1:out std_ulogic;
		config_ack_in:in std_ulogic;
		--DE2 Control SIgnals
		msg_out:out std_ulogic_vector(2 downto 0);
		Ack_count_out:out std_logic_vector(31 downto 0);
		cmd:in std_ulogic_vector(4 downto 0);
		--SRAM
		SRAM_DATA_OUT: OUT std_logic_vector(15 downto 0);
		SRAM_DATA: in std_logic_vector(15 downto 0);
		SRAM_ADDR: out std_logic_vector(23 downto 0);
		SRAM_WEN:  out std_logic;
		SRAM_OEN:  out std_logic;
		--SDRAM
		SDRAM_DATA: out std_logic_vector(15 downto 0);
		SDRAM_ADDR: out std_logic_vector(23 downto 0);
		SDRAM_WEN:  out std_logic;
		SDRAM_OEN:  out std_logic;
		--Result Vectors
		INPUT_ASYNC_0: in std_ulogic_vector(INPUT_LENGTH-1 downto 0);
		INPUT_ASYNC_1: in std_ulogic_vector(INPUT_LENGTH-1 downto 0);
		INPUT_ASYNC_ACKOUT: out std_ulogic_vector(INPUT_LENGTH-1 downto 0);
		--Test Vectors
		OUTPUT_ASYNC_0: out std_ulogic_vector(OUTPUT_LENGTH-1 downto 0);
		OUTPUT_ASYNC_1: out std_ulogic_vector(OUTPUT_LENGTH-1 downto 0);
		OUTPUT_ASYNC_ACKIN: in std_ulogic_vector(OUTPUT_LENGTH-1 downto 0);

		--Trigger for oscilloscope
		trigger: out std_ulogic

		);
end entity safe_test;


architecture machine_a_etat of safe_test is
component S_TO_AS_CONFIG is
generic (BEGIN_ADDR:integer:=0;END_ADDR:integer:=0;LENGTH:integer:=16);
	port(
		clk:in std_ulogic;
		rst:in std_ulogic;

		SRAM_DATA_OUT: out std_logic_vector(15 downto 0);
		SRAM_DATA: in std_logic_vector(15 downto 0);
		SRAM_ADDR: out std_logic_vector(23 downto 0);
		SRAM_WEN:  out std_logic;
		SRAM_OEN:  out std_logic;

		AS_OUT0: out std_ulogic;
		AS_OUT1: out std_ulogic;
		ACK_IN:  in std_ulogic;
		
		config_enable: in std_ulogic; -- Command from the state_machine up there
		ACK_COUNT_OUT: out std_logic_vector(31 downto 0)
		);
end component S_TO_AS_CONFIG;

component AS_TO_S_VECTOR is
generic (BEGIN_ADDR:integer:=0;END_ADDR:integer:=0;LENGTH:integer:=16);
	port(
		clk:in std_ulogic;
		rst:in std_ulogic;

		SRAM_DATA: out std_logic_vector(15 downto 0);
		SRAM_ADDR: out std_logic_vector(23 downto 0);
		SRAM_WEN:  out std_logic;
		SRAM_OEN:  out std_logic;

		I_ASYNC_0: in std_ulogic_vector(LENGTH-1 downto 0);
		I_ASYNC_1: in std_ulogic_vector(LENGTH-1 downto 0);
		I_ASYNC_ACK_OUT:  out std_ulogic_vector(LENGTH-1 downto 0);
		
		vector_enable: in std_ulogic; -- Command from the state_machine up there
		ACK_COUNT_OUT: out std_logic_vector(31 downto 0)
		);
end component AS_TO_S_VECTOR;

component S_TO_AS_VECTOR is
generic (BEGIN_ADDR:integer:=0;END_ADDR:integer:=0;LENGTH:integer:=16);
	port(
		clk:in std_ulogic;
		rst:in std_ulogic;
		trigger:out std_ulogic;

		SRAM_DATA: in std_logic_vector(15 downto 0);
		SRAM_ADDR: out std_logic_vector(23 downto 0);
		SRAM_WEN:  out std_logic;
		SRAM_OEN:  out std_logic;

		O_ASYNC_0: out std_ulogic_vector(LENGTH-1 downto 0);
		O_ASYNC_1: out std_ulogic_vector(LENGTH-1 downto 0);
		O_ASYNC_ACK_IN:  in std_ulogic_vector(LENGTH-1 downto 0);
		
		vector_enable: in std_ulogic; -- Command from the state_machine up there
		ACK_COUNT_OUT: out std_logic_vector(31 downto 0)
		);
end component S_TO_AS_VECTOR;

--type STATE_TYPE is(IDLE,INIT,CONFIG,RUNNING);
--signal state,next_state:STATE_TYPE;
signal msg_out_int:std_ulogic_vector(2 downto 0);
signal count:integer range 0 to integer'high;
signal count_in,count_out:std_logic_vector(31 downto 0);
signal config_enable,run_enable,safe_rst:std_ulogic;
signal SRAM_DATA_TEST,SRAM_DATA_CONFIG:std_logic_vector(15 downto 0);
signal SRAM_ADDR_TEST,SRAM_ADDR_CONFIG:std_logic_vector(23 downto 0);
signal SRAM_WEN_CONFIG,SRAM_WEN_TEST,SRAM_OEN_CONFIG,SRAM_OEN_TEST:std_logic;
signal trig_count:integer range 0 to integer'high;
begin
	msg_out<=msg_out_int;
	TRANSLATE: S_TO_AS_CONFIG
				generic map(BEGIN_ADDR=>0,END_ADDR=>293,LENGTH=>1)
			 	port map(
					clk=>clk,
					rst=>rst,

					SRAM_DATA_OUT=>SRAM_DATA_OUT,
					SRAM_DATA=>SRAM_DATA,
					SRAM_ADDR=>SRAM_ADDR_CONFIG,
					SRAM_WEN=>SRAM_WEN_CONFIG,
					SRAM_OEN=>SRAM_OEN_CONFIG,

					AS_OUT0=>config_out0,
					AS_OUT1=>config_out1,
					ACK_IN=>config_ack_in,

					config_enable=>config_enable,
					ACK_COUNT_OUT=>Ack_count_out);


	TRANSLATE_S_TO_AS:S_TO_AS_VECTOR
	generic map(BEGIN_ADDR=>4096,END_ADDR=>4159,LENGTH=>OUTPUT_LENGTH)
		port map(
			clk=>clk,
			rst=>safe_rst,
			trigger=>trigger,
	
			SRAM_DATA=>SRAM_DATA,
			SRAM_ADDR=>SRAM_ADDR_TEST,
			SRAM_WEN=>SRAM_WEN_TEST,
			SRAM_OEN=>SRAM_OEN_TEST,
	
			O_ASYNC_0=>OUTPUT_ASYNC_0,
			O_ASYNC_1=>OUTPUT_ASYNC_1,
			O_ASYNC_ACK_IN=>OUTPUT_ASYNC_ACKIN,
			
			vector_enable=>run_enable,
			ACK_COUNT_OUT=>count_out
			);
	TRANSLATE_AS_TO_S:AS_TO_S_VECTOR
	generic map(BEGIN_ADDR=>0,END_ADDR=>63,LENGTH=>INPUT_LENGTH)
		port map(
			clk=>clk,
			rst=>safe_rst,
	
			SRAM_DATA=>SDRAM_DATA,
			SRAM_ADDR=>SDRAM_ADDR, 
			SRAM_WEN=>SDRAM_WEN,
			SRAM_OEN=>SDRAM_OEN,
	
			I_ASYNC_0=>INPUT_ASYNC_0,
			I_ASYNC_1=>INPUT_ASYNC_1,
			I_ASYNC_ACK_OUT=>INPUT_ASYNC_ACKOUT,
			
			vector_enable=>run_enable,
			ACK_COUNT_OUT=>count_in
			);
	p1:process(cmd,SRAM_ADDR_CONFIG,SRAM_WEN_CONFIG,SRAM_OEN_CONFIG,SRAM_ADDR_TEST,SRAM_WEN_TEST,SRAM_OEN_TEST)
	begin
--		if(rst='0') then
--			--state<=IDLE;
--			msg_out_int<="111";
--			init_out<='0';
--			config_mode_out<='0';
--			config_enable<='0';
--			I_OL7_JP2_53<='0';		
--		elsif rising_edge(clk) then
		--	state<=next_state;
			case cmd is
				when "00000"=>--IDLE
					msg_out_int<="111";
					init_out<='0';
					config_mode_out<='0';
					config_enable<='0';
					run_enable<='0';
					SRAM_ADDR<=SRAM_ADDR_CONFIG;
					SRAM_WEN<=SRAM_WEN_CONFIG;
					SRAM_OEN<=SRAM_OEN_CONFIG;
					safe_rst<='0';
				
				when "00001"=>--CONNECTED
					msg_out_int<="000";
					init_out<='0';
					config_mode_out<='0';
					config_enable<='0';
					run_enable<='0';
					SRAM_ADDR<=SRAM_ADDR_CONFIG;
					SRAM_WEN<=SRAM_WEN_CONFIG;
					SRAM_OEN<=SRAM_OEN_CONFIG;
					safe_rst<='0';

				when "00011"=>--INIT
					msg_out_int<="001";
					init_out<='0';
					config_mode_out<='0';
					config_enable<='0';
					run_enable<='0';
					SRAM_ADDR<=SRAM_ADDR_CONFIG;
					SRAM_WEN<=SRAM_WEN_CONFIG;
					SRAM_OEN<=SRAM_OEN_CONFIG;
					safe_rst<='0';

				when "00101"=>--CONFIG
					msg_out_int<="010";
					init_out<='1';
					config_mode_out<='0';
					config_enable<='1';
					run_enable<='0';
					SRAM_ADDR<=SRAM_ADDR_CONFIG;
					SRAM_WEN<=SRAM_WEN_CONFIG;
					SRAM_OEN<=SRAM_OEN_CONFIG;
					safe_rst<='0';

				when "10001"=>--SAFE_RESET,Only I/Os there is no reset for safe!! 
					msg_out_int<="011";
					init_out<='1';
					config_mode_out<='1';
					config_enable<='1';
					run_enable<='0';
					SRAM_ADDR<=SRAM_ADDR_TEST;
					SRAM_WEN<=SRAM_WEN_TEST;
					SRAM_OEN<=SRAM_OEN_TEST;
					safe_rst<='0';
				when "01001"=>--RUNNING
					msg_out_int<="011";
					init_out<='1';
					config_mode_out<='1';
					config_enable<='1';
					run_enable<='1';
					SRAM_ADDR<=SRAM_ADDR_TEST;
					SRAM_WEN<=SRAM_WEN_TEST;
					SRAM_OEN<=SRAM_OEN_TEST;
					safe_rst<='1';
				
				when others=>
					msg_out_int<= "111";
					init_out<='1';
					config_mode_out<='0';
					config_enable<='0';
					run_enable<='0';
					SRAM_ADDR<=SRAM_ADDR_CONFIG;
					SRAM_WEN<=SRAM_WEN_CONFIG;
					SRAM_OEN<=SRAM_OEN_CONFIG;
					safe_rst<='0';
			end case;
--		end if;
	end process;

--	p2:process(state,init_config,config_mode)
--	begin
--		case state is
--			
--			when IDLE=>
--					if(init_config='0') then 
--						next_state<=INIT;
--					else
--						next_state<=IDLE;
--					end if;
----			when CONNECT=>
----					
----					if(init_config='0') then 
----						next_state<= INIT;
----					else
----						next_state<= CONNECT;
----					end if;
--
--			when INIT=>
--					if(config_mode='1') then
--						next_state<=CONFIG;
--					else 
--						next_state<=INIT;
--					end if;
--
--			when CONFIG=>
--		--			if(init_config='0') then
--		--				next_state<=INIT;
--					if(config_mode='0') then
--						next_state<=RUNNING;
--					elsif(config_mode='1') then
--						next_state<=CONFIG;
--					end if;
--
--			when RUNNING=>
--					--if(init_config='0') then
--					--	next_state<=INIT;
--					if(config_mode='1') then
--						next_state<=CONFIG;
--					elsif(config_mode='0') then
--						next_state<=RUNNING;
--					end if;
--
--			when others=>
--					next_state<=state;
--		end case;
--	end process;

--	p3:process(state)
--	begin
--		case state is
--			when IDLE=>
--				msg_out_int<="111";
--				init_out<='0';
--				config_mode_out<='0';
--				config_enable<='0';
--				I_OL7_JP2_53<='0';		
--			
--			when CONNECT=>
--				msg_out_int<="000";
--				init_out<='0';
--				config_mode_out<='0';
--				config_enable<='0';
--				I_OL7_JP2_53<='0';		
--
--			when INIT=>
--				msg_out_int<="001";
--				init_out<='0';
--				config_mode_out<='0';
--				config_enable<='0';
--				I_OL7_JP2_53<='0';		
--
--			when CONFIG=>
--				msg_out_int<="010";
--				init_out<='1';
--				config_mode_out<='0';
--				config_enable<='1';
--				I_OL7_JP2_53<='0';		
--
--			when RUNNING=>
--				msg_out_int<="011";
--				init_out<='1';
--				config_mode_out<='1';
--				config_enable<='0';
--				I_OL7_JP2_53<='1';		
--			
--			when others=>
--				msg_out_int<= "111";
--				init_out<='1';
--				config_mode_out<='0';
--				config_enable<='0';
--				I_OL7_JP2_53<='0';		
--		end case;
--	end process;
--	--Main State Machine------------------------------------
--p_trigger:process(clk,rst)
--	begin
--	if(rst='0') then
--		trig_count<=0;
--		trigger<='0';
--	elsif rising_edge(clk) then
--		trig_count<=trig_count+1;
--		if(trig_count=1024) then
--			trigger<='1';
--		elsif(trig_count=2048) then
--			trig_count<=0;
--			trigger<='0';
--		end if;
--	end if;
--	end process;
--trigger<=clk;
end architecture machine_a_etat;
