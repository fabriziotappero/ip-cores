-------------------------------------------------------------------------------
--                                                                           --
--                                                                           --
--                                                                           --
--                                 		                             --
-------------------------------------------------------------------------------
--
-- unit name: register_rx_handler
--
-- author: Mauro Predonzani (predmauro@libero.it)
--         Andrea Borga     (andrea.borga@nikhef.nl)
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
--                      -----------------------------------------------------
--                      |    	 ADDRESS	       |	DATA	|
--                      -----------------------------------------------------
--            		| 15-08 | 07-00 | 31-24 | 23-16	| 15-08	|07-00 |	
--			| reghnd_full_add | reghnd_full_data  |
--                      -----------------------------------------------------
--          BYTE NUM    | BYTEO | BYTE1 | BYTE2 | BYTE3 | BYTE4 | BYTE5 |
--                      -----------------------------------------------------
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
--               04-08-2011 Andrea Borga
--                   missing s_tick reset value
--               18-08-2011 Andrea Borga
--                   removed unused vraious v_registers
--
-------------------------------------------------------------------------------
-- last changes: <date> <initials> <log>
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

entity register_rx_handler is
  port(
    reghnd_clk          : in std_logic;		-- system clock
    reghnd_rst          : in std_logic;		-- system reset
    reghnd_data_in      : in std_logic_vector(7 downto 0);			-- 8 bits fragments 
    reghnd_data_cs_rd	: in std_logic;   -- cs strobe of gh16550 during a read process
    reghnd_data_wr_rd	: in std_logic;   -- wr state of gh16550 during a read process
    reghnd_rd_rdy       : out std_logic;	-- Read data ready
    reghnd_full_add     : out std_logic_vector(15 downto 0);		-- 16 bits RAM address
    reghnd_full_data    : out std_logic_vector(31 downto 0);  	-- 32 bits RAM data
    reghnd_full_cs	: in std_logic		-- strobe data/address acquired (1 acquired - 0 not acquired)
    );
end entity;

--=============================================================================
-- architecture declaration
--=============================================================================

architecture a of register_rx_handler is

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Components declaration 
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  --
  -- Internal signal declaration 
  --

  signal s_rst                  : std_logic;                    -- global reset
  signal s_clk                  : std_logic;                    -- uart to parallel interface clock

  signal s_read_mem             : std_logic;                     -- read data from memory
  
  signal s_write_mem            : std_logic;                     -- write data into memory
  signal v_wr_add               : std_logic_vector(15 downto 0); -- full write ADDRESS
  signal v_wr_data              : std_logic_vector(31 downto 0); -- full write DATA
  
  signal s_tick									: std_logic;
  
  --
  -- State Machine states 
  --
  
  type t_reg_decoder is (IDLE, BYTE0, BYTE1, BYTE2, BYTE3, BYTE4, BYTE5, WRITE_MEM);
  signal s_reg_decoder  : t_reg_decoder;

--=============================================================================
-- architecture begin
--=============================================================================
	
begin
    
  s_rst                 <= reghnd_rst;
  s_clk                 <= reghnd_clk;           
	reghnd_rd_rdy         <= s_write_mem;

p_register_decoder : process(s_rst, s_clk)    
begin  
  if s_rst = '1' then	-- reset
      s_write_mem       <= '0';
      reghnd_full_add		<= (others => '0');
      reghnd_full_data  <= (others => '0');
      v_wr_add          <= (others => '0');
      v_wr_data         <= (others => '0');
      s_tick <= '0';
      s_reg_decoder <= IDLE;
    elsif Rising_edge(s_clk) then
      case s_reg_decoder is
        when IDLE =>                            -- IDLE state
          s_write_mem           <= '0';
          reghnd_full_add		<= (others => '0');
          reghnd_full_data  <= (others => '0');
          v_wr_add          <= (others => '0');
          v_wr_data         <= (others => '0');
          if reghnd_data_cs_rd  = '1' and reghnd_data_wr_rd = '0' then  -- check if BYTE0 is ready
            s_reg_decoder <= BYTE0;
          else
            s_reg_decoder <= IDLE;
            s_tick <= '0';
          end if;
        when BYTE0 =>                       		    -- decode byte 0 ADDRESS upper
          s_write_mem						<= '0';
          if s_tick = '0' then	-- only first time in this cycle acq the byte
            v_wr_add (15 downto 8)  <= reghnd_data_in;
            s_tick <= '1';
          elsif reghnd_data_cs_rd  = '1' and reghnd_data_wr_rd = '0' then	-- check if BYTE1 is ready
            s_reg_decoder <= BYTE1;
            s_tick <= '0';
          else
            s_reg_decoder <= BYTE0;
            s_tick <= '1';
          end if;
        when BYTE1 =>               		   	  -- decode byte 1 ADDRESS lower
          s_write_mem		<= '0';
          if s_tick = '0' then		-- only first time in this cycle acq the byte
            v_wr_add (7 downto 0)  <= reghnd_data_in;
            s_tick <= '1';
          elsif reghnd_data_cs_rd  = '1' and reghnd_data_wr_rd = '0' then	-- check if BYTE2 is ready
            s_reg_decoder <= BYTE2;
            s_tick <= '0';
          else
            s_reg_decoder <= BYTE1;
            s_tick <= '1';
          end if;
        when BYTE2  =>                          		-- decode byte 2 = DATA1
          s_write_mem						<= '0';
          if s_tick = '0' then		-- only first time in this cycle acq the byte
            v_wr_data (31 downto 24)  <= reghnd_data_in;
            s_tick <= '1';
          elsif reghnd_data_cs_rd  = '1' and reghnd_data_wr_rd = '0' then	-- check if BYTE3 is ready
            s_reg_decoder <= BYTE3;
            s_tick <= '0';
          else
            s_reg_decoder <= BYTE2;
            s_tick <= '1';
          end if;
        when BYTE3 =>                           		-- decode byte 3 = DATA2 
          s_write_mem						<= '0';
          if s_tick = '0' then		-- only first time in this cycle acq the byte
            v_wr_data (23 downto 16)  <= reghnd_data_in;
            s_tick <= '1';
          elsif reghnd_data_cs_rd  = '1' and reghnd_data_wr_rd = '0' then	-- check if BYTE4 is ready
            s_reg_decoder <= BYTE4;
            s_tick <= '0';
          else
            s_reg_decoder <= BYTE3;
            s_tick <= '1';
          end if;
        when BYTE4 =>		-- decode byte 4 = DATA3
          s_write_mem	     				<= '0';
          if s_tick = '0' then	-- only first time in this cycle acq the byte
            v_wr_data (15 downto 8)  <= reghnd_data_in;
            s_tick <= '1';
          elsif reghnd_data_cs_rd  = '1' and reghnd_data_wr_rd = '0' then	-- check if BYTE5 is ready
            s_reg_decoder <= BYTE5;
            s_tick <= '0';
          else
            s_reg_decoder <= BYTE4;
            s_tick <= '1';
          end if;
        when BYTE5 =>                           		-- decode byte 5 = DATA4
          s_write_mem						<= '0';
          if s_tick = '0' then	-- only first time in this cycle acq the byte
            v_wr_data (7 downto 0)  <= reghnd_data_in;
            s_tick <= '1';
          else		-- add and data are ready => ready to use
            s_reg_decoder <= WRITE_MEM;
            s_tick <= '0';
            reghnd_full_add          <= v_wr_add;		-- address latch to the ouput
            reghnd_full_data         <= v_wr_data;	-- data latch to the output
          end if;
        when WRITE_MEM =>                      			-- write data into RAM
          s_write_mem           <= '1';  			-- data and address stable and ready
          if reghnd_full_cs = '1' then				-- check if data is transfer to RAM or not
            s_reg_decoder <= IDLE;
          else 
            s_reg_decoder <= WRITE_MEM;
          end if;
        when others =>
          s_reg_decoder <= IDLE;
      end case;
    end if;
end process p_register_decoder;

        
end a;

--=============================================================================
-- architecture end
--=============================================================================
