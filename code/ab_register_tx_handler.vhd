-------------------------------------------------------------------------------
--                                                                           --
--                                                                           --
--                                                                           --
--                               		                             --
-------------------------------------------------------------------------------
--
-- unit name: register_tx_handler
--
-- author: Mauro Predonzani (predmauro@libero.it)
--
-- date: 20/02/2009    $: created
--
-- version: $Rev 1.0      $:
--
-- description: 
--
--      the module acquires byte
--      and decodes the data as follows:
--
--    reghnd_addr_wwo_i= 1	(with)
--                      -----------------------------------------------------
--                      |    	 ADDRESS			|							DATA							|
--                      -----------------------------------------------------
--          						|  15-08 	| 07-00 	| 31-24 | 23-16	| 15-08	|	07-00 |	
--											|	 full_add_ram_i		| 		reghnd_full_data_ram_i		|
--                      -----------------------------------------------------
--          BYTE NUM    |	 BYTEO 	| BYTE1 	| BYTE2 | BYTE3 | BYTE4 | BYTE5 |
--                      -----------------------------------------------------
--
--    reghnd_addr_wwo_i= 0	(without)
--                      ---------------------------------
--                      |							DATA							|
--                      ---------------------------------
--          						| 31-24 | 23-16	| 15-08	|	07-00 |	
--											| 		reghnd_full_data_ram_i		|
--                      ---------------------------------
--          BYTE NUM    | BYTE0 | BYTE1 | BYTE2 | BYTE3 |
--                      ---------------------------------
--
--      number of register cells: 2^16
--      data word lenght: 32 bits
--
--
-- dependencies:	uart_wrapper
--								uart_lbus_slave
--								gh_uart_16550
--
-- references: <reference one>
-- <reference two> ...
--
-- modified by: $Author:: $:
--
-------------------------------------------------------------------------------
-- last changes: 2010-06-09		enable/disable TX address byte			-- Mauro Predonzani
-- <extended description>
-------------------------------------------------------------------------------
-- TODO:
--
--
-- 
--
-------------------------------------------------------------------------------

--=============================================================================
-- Libraries
--=============================================================================

library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--=============================================================================
-- Entity declaration for ada_register_handler
--=============================================================================

entity register_tx_handler is
  port(
    reghnd_clk          			: in std_logic;		-- system clock
    reghnd_rst          			: in std_logic;		-- system reset
		reghnd_addr_wwo_i					: in std_logic;		-- control of TX process With or WithOut address W/WO=(1/0)
    reghnd_full_data_ram_i 		: in std_logic_vector(31 downto 0);	-- 32 bits full data
		reghnd_full_add_ram_i			: in std_logic_vector(15 downto 0);	-- 16 bits full addr
		reghnd_stb_data_ram_rdy_i	: in std_logic;		-- strobe ram data ready
		reghnd_data_acq_gh16550_i	: in std_logic;		-- data acquired from gh16550
    reghnd_wr_enable_i				: in std_logic;		-- enable the tx process
		reghnd_txrdy_n_gh16550_i	: in std_logic;		-- gh16550 ready to trasmit
    reghnd_wr_enable_o				: out std_logic;	-- enable the tx process
		reghnd_output_rdy_o				: out std_logic;	-- Read data ready
    reghnd_pdata_o						: out std_logic_vector(7 downto 0);	-- 8 bits parallel
		reghnd_stb_acq_ram_o			: out std_logic		-- strobe data/address acquired (1 acquired - 0 not acquired)
   );
end entity;

--=============================================================================
-- architecture declaration
--=============================================================================

architecture tx_handler of register_tx_handler is

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Components declaration 
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  --
  -- Internal signal declaration 
  --

  signal s_rst                  : std_logic;                    -- global reset
  signal s_clk                  : std_logic;                    -- uart to parallel interface clock
	signal s_tick									: std_logic_vector (1 downto 0);
  signal v_tx_stream						: std_logic_vector(47 downto 0);
  --	
  -- State Machine states 
  --
  
  type t_reg_decoder is (IDLE, READ_RAM, BYTE0, BYTE1, BYTE2, BYTE3, BYTE4, BYTE5	);
  signal s_reg_decoder  : t_reg_decoder;

--=============================================================================
-- architecture begin
--=============================================================================
	
begin
 
  s_rst                 <= reghnd_rst;
  s_clk                 <= reghnd_clk;           
	
p_tx_handler : process(s_rst, s_clk)    
begin  
  if s_rst = '1' then													-- reset
    reghnd_wr_enable_o		<= '0';
    reghnd_output_rdy_o		<= '0';
    reghnd_pdata_o		<= (others => '0');
    reghnd_stb_acq_ram_o	<= '0';
    s_tick 			<= "00";
    v_tx_stream			<= (others => '0');
    s_reg_decoder <= IDLE;
  elsif Rising_edge(s_clk) then
    case s_reg_decoder is
      when IDLE =>                            -- IDLE state
        reghnd_wr_enable_o		<= '0';
        reghnd_output_rdy_o		<= '0';
        reghnd_pdata_o			<= (others => '0');
        reghnd_stb_acq_ram_o		<= '0';
        s_tick 				<= "00";
        if reghnd_txrdy_n_gh16550_i = '0' and reghnd_stb_data_ram_rdy_i = '1' then  -- check if BYTE0 is ready
          s_reg_decoder <= READ_RAM;
        else
          s_reg_decoder <= IDLE;
        end if;
      when READ_RAM =>                       		    
        if s_tick = "00" then	-- only first time in this cycle acq the byte
          v_tx_stream (47 downto 32)  <= reghnd_full_add_ram_i;
          v_tx_stream (31 downto 0)  	<= reghnd_full_data_ram_i;
          reghnd_pdata_o <= (others => '0');
          reghnd_stb_acq_ram_o <= '1';
          s_tick <= "01";
          reghnd_wr_enable_o		<= '0';
        elsif reghnd_wr_enable_i = '0' then
          s_reg_decoder <= IDLE;
          reghnd_pdata_o <= (others => '0');
          s_tick <= "00";
          reghnd_stb_acq_ram_o <= '0';
          reghnd_wr_enable_o	 <= '0';
        elsif reghnd_txrdy_n_gh16550_i = '0' and reghnd_wr_enable_i = '1' then	-- if uart is lbus and gh16550 is ready then tx BYTE0
          if reghnd_addr_wwo_i = '1' then
            s_reg_decoder <= BYTE0;
            reghnd_pdata_o <= v_tx_stream (47 downto 40);
          else
            s_reg_decoder <= BYTE2;
            reghnd_pdata_o <= v_tx_stream (31 downto 24);
          end if;	
            s_tick <= "00";
            reghnd_stb_acq_ram_o <= '0';
            reghnd_wr_enable_o	 <= '1';  -- inizio la trasmissione
          else
            reghnd_pdata_o <= v_tx_stream (47 downto 40);
            s_reg_decoder <= READ_RAM;
            s_tick <= "01";
            reghnd_stb_acq_ram_o <= '0';
            reghnd_wr_enable_o				<= '0';
          end if;
        when BYTE0 =>                      		   	  -- send byte 0 ADDRESS higher
          reghnd_wr_enable_o				<= '1';
          if s_tick = "00" then			-- only first time in this cycle acq the byte
            s_reg_decoder <= BYTE0;
            reghnd_output_rdy_o <= '1';
            reghnd_pdata_o <= v_tx_stream (47 downto 40);
            if reghnd_data_acq_gh16550_i = '1' then
              s_tick <= "01";
            else
              s_tick <= "00";
            end if;
          elsif s_tick = "01" then
            s_tick <= "11";
            s_reg_decoder <= BYTE0;
            reghnd_output_rdy_o <= '1';
            reghnd_pdata_o <= v_tx_stream (47 downto 40);
          elsif s_tick = "11" then
            s_tick <= "10";
            s_reg_decoder <= BYTE0;
            reghnd_output_rdy_o <= '1';
            reghnd_pdata_o <= v_tx_stream (47 downto 40);				
          elsif reghnd_txrdy_n_gh16550_i = '0' and reghnd_wr_enable_i = '1' then	-- if uart is lbus and gh16550 is ready then tx BYTE0
            s_reg_decoder <= BYTE1;
            reghnd_stb_acq_ram_o <= '0';
            reghnd_pdata_o <= v_tx_stream (39 downto 32);
            reghnd_output_rdy_o <= '0';
            s_tick <= "00";
          else
            s_reg_decoder <= BYTE0;
            reghnd_stb_acq_ram_o <= '0';
            reghnd_pdata_o <= v_tx_stream (39 downto 32);
            reghnd_output_rdy_o <= '0';
            s_tick <= "10";
          end if;
        when BYTE1 =>                      		   	  -- send byte 1 ADDRESS lower
          reghnd_wr_enable_o				<= '1';
          if s_tick = "00" then											-- only first time in this cycle acq the byte
            s_reg_decoder <= BYTE1;
						reghnd_output_rdy_o <= '1';
            reghnd_pdata_o <= v_tx_stream (39 downto 32);
            if reghnd_data_acq_gh16550_i = '1' then
              s_tick <= "01";
            else 
              s_tick <= "00";
            end if;
          elsif s_tick = "01" then
            s_tick <= "11";
            s_reg_decoder <= BYTE1;
            reghnd_output_rdy_o <= '1';
            reghnd_pdata_o <= v_tx_stream (39 downto 32);
          elsif s_tick = "11" then
            s_tick <= "10";
            s_reg_decoder <= BYTE1;
            reghnd_output_rdy_o <= '1';
            reghnd_pdata_o <= v_tx_stream (39 downto 32);
          elsif reghnd_txrdy_n_gh16550_i = '0' and reghnd_wr_enable_i = '1' then	-- if uart is lbus and gh16550 is ready then tx BYTE0
            s_reg_decoder <= BYTE2;
            reghnd_stb_acq_ram_o <= '0';
            reghnd_pdata_o <= v_tx_stream (31 downto 24);
            reghnd_output_rdy_o <= '0';
            s_tick <= "00";
          else
            s_reg_decoder <= BYTE1;
            reghnd_stb_acq_ram_o <= '0';
            reghnd_pdata_o <= v_tx_stream (31 downto 24);
            reghnd_output_rdy_o <= '0';
            s_tick <= "10";
          end if;
        when BYTE2 =>                      		   	  -- send byte 2 DATA1
          reghnd_wr_enable_o				<= '1';
          if s_tick = "00" then		-- only first time in this cycle acq the byte
            s_reg_decoder <= BYTE2;
            reghnd_output_rdy_o <= '1';
            reghnd_pdata_o <= v_tx_stream (31 downto 24);
            if reghnd_data_acq_gh16550_i = '1' then
              s_tick <= "01";
            else 
              s_tick <= "00";
            end if;
          elsif s_tick = "01" then
            s_tick <= "11";
            s_reg_decoder <= BYTE2;
            reghnd_output_rdy_o <= '1';
            reghnd_pdata_o <= v_tx_stream (31 downto 24);
          elsif s_tick = "11" then
            s_tick <= "10";
            s_reg_decoder <= BYTE2;
            reghnd_output_rdy_o <= '1';
            reghnd_pdata_o <= v_tx_stream (31 downto 24);
          elsif reghnd_txrdy_n_gh16550_i = '0' and reghnd_wr_enable_i = '1' then	-- if uart is lbus and gh16550 is ready then tx BYTE0
            s_reg_decoder <= BYTE3;
            reghnd_stb_acq_ram_o <= '0';
            reghnd_pdata_o <= v_tx_stream (23 downto 16);
            reghnd_output_rdy_o <= '0';
            s_tick <= "00";
          else
            s_reg_decoder <= BYTE2;
            reghnd_stb_acq_ram_o <= '0';
            reghnd_pdata_o <= v_tx_stream (23 downto 16);
            reghnd_output_rdy_o <= '0';
            s_tick <= "10";
          end if;				
        when BYTE3 =>                      		   	  -- send byte 3 DATA2
          reghnd_wr_enable_o				<= '1';
          if s_tick = "00" then			-- only first time in this cycle acq the byte
            s_reg_decoder <= BYTE3;
            reghnd_output_rdy_o <= '1';
            reghnd_pdata_o <= v_tx_stream (23 downto 16);
            if reghnd_data_acq_gh16550_i = '1' then
              s_tick <= "01";
            else 
              s_tick <= "00";
            end if;
          elsif s_tick = "01" then
            s_tick <= "11";
            s_reg_decoder <= BYTE3;
            reghnd_output_rdy_o <= '1';
            reghnd_pdata_o <= v_tx_stream (23 downto 16);
          elsif s_tick = "11" then
            s_tick <= "10";
            s_reg_decoder <= BYTE3;
            reghnd_output_rdy_o <= '1';
            reghnd_pdata_o <= v_tx_stream (23 downto 16);
          elsif reghnd_txrdy_n_gh16550_i = '0' and reghnd_wr_enable_i = '1' then	-- if uart is lbus and gh16550 is ready then tx BYTE0
            s_reg_decoder <= BYTE4;
            reghnd_stb_acq_ram_o <= '0';
            reghnd_pdata_o <= v_tx_stream (15 downto 8);
            reghnd_output_rdy_o <= '0';
            s_tick <= "00";
          else
            s_reg_decoder <= BYTE3;
            reghnd_stb_acq_ram_o <= '0';
            reghnd_pdata_o <= v_tx_stream (15 downto 8);
            reghnd_output_rdy_o <= '0';
            s_tick <= "10";
          end if;
        when BYTE4 =>                      		   	  -- send byte 4 DATA3
          reghnd_wr_enable_o				<= '1';
          if s_tick = "00" then		-- only first time in this cycle acq the byte
            s_reg_decoder <= BYTE4;
            reghnd_output_rdy_o <= '1';
            reghnd_pdata_o <= v_tx_stream (15 downto 8);
            if reghnd_data_acq_gh16550_i = '1' then
              s_tick <= "01";
            else 
              s_tick <= "00";
            end if;
          elsif s_tick = "01" then
            s_tick <= "11";
            s_reg_decoder <= BYTE4;
            reghnd_output_rdy_o <= '1';
            reghnd_pdata_o <= v_tx_stream (15 downto 8);
          elsif s_tick = "11" then
            s_tick <= "10";
            s_reg_decoder <= BYTE4;
            reghnd_output_rdy_o <= '1';
            reghnd_pdata_o <= v_tx_stream (15 downto 8);
          elsif reghnd_txrdy_n_gh16550_i = '0' and reghnd_wr_enable_i = '1' then	-- if uart is lbus and gh16550 is ready then tx BYTE0
            s_reg_decoder <= BYTE5;
            reghnd_stb_acq_ram_o <= '0';
            reghnd_pdata_o <= v_tx_stream (7 downto 0);
            reghnd_output_rdy_o <= '0';
            s_tick <= "00";
          else
            s_reg_decoder <= BYTE4;
            reghnd_stb_acq_ram_o <= '0';
            reghnd_pdata_o <= v_tx_stream (7 downto 0);
            reghnd_output_rdy_o <= '0';
            s_tick <= "10";
          end if;
          when BYTE5 =>                      		   	  -- send byte 5 DATA4
          reghnd_wr_enable_o				<= '1';
          if s_tick = "00" then			-- only first time in this cycle acq the byte
            s_reg_decoder <= BYTE5;
            reghnd_output_rdy_o <= '1';
            reghnd_pdata_o <= v_tx_stream (7 downto 0);
            if reghnd_data_acq_gh16550_i = '1' then
              s_tick <= "01";
            else 
              s_tick <= "00";
            end if;
          elsif s_tick = "01" then
            s_tick <= "11";
            s_reg_decoder <= BYTE5;
            reghnd_output_rdy_o <= '1';
            reghnd_pdata_o <= v_tx_stream (7 downto 0);
          elsif s_tick = "11" then
            s_tick <= "10";
            s_reg_decoder <= BYTE5;
            reghnd_output_rdy_o <= '0';
            reghnd_pdata_o <= v_tx_stream (7 downto 0);
          elsif reghnd_txrdy_n_gh16550_i = '0' and reghnd_wr_enable_i = '1' and reghnd_stb_data_ram_rdy_i = '1' then	-- if uart is lbus and gh16550 is ready then tx BYTE0
            s_reg_decoder <= READ_RAM;
            reghnd_stb_acq_ram_o <= '0';
            reghnd_pdata_o <= (others => '0');
            reghnd_output_rdy_o <= '0';
            s_tick <= "00";
          elsif reghnd_txrdy_n_gh16550_i = '0' then	-- if uart is lbus and gh16550 is ready then tx BYTE0
            s_reg_decoder <= IDLE;
            reghnd_stb_acq_ram_o <= '0';
            reghnd_pdata_o <= (others => '0');
            reghnd_output_rdy_o <= '0';
            s_tick <= "00";
          else
            s_reg_decoder <= BYTE5;
            reghnd_stb_acq_ram_o <= '0';
            reghnd_pdata_o <= (others => '0');
            s_tick <= "10";
          end if;
        when others =>
          s_reg_decoder <= IDLE;
      end case;
    end if;
end process p_tx_handler;

        
end tx_handler;

--=============================================================================
-- architecture end
--=============================================================================
