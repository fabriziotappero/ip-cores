-------------------------------------------------------------------------------
--
-- Title       : pcie_core64_wishbone_m8
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.0
--
-------------------------------------------------------------------------------
--
-- Description :  PCI Express controller
--				  Modification 8 - Wishbone - Virtex 5 PCI Express v1.1 x8
--
-------------------------------------------------------------------------------
-- 
-- Version 1.0 	20.04.2013
--          	Created from  pcie_core64_wishbone v1.3
-- 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package pcie_core64_wishbone_m8_pkg is

component pcie_core64_wishbone_m8 is
generic 
(
    Device_ID       : in std_logic_vector( 15 downto 0 ):=x"0000";  -- идентификатор модуля
    Revision        : in std_logic_vector( 15 downto 0 ):=x"0000";  -- версия модуля
    PLD_VER         : in std_logic_vector( 15 downto 0 ):=x"0000";  -- версия ПЛИС
    
    is_simulation   : integer:=0  	--! 0 - synthesis, 1 - simulation                            
);
port 
(
    ---- PCI-Express ----
    txp             : out std_logic_vector( 7 downto 0 );
    txn             : out std_logic_vector( 7 downto 0 );
    
    rxp             : in  std_logic_vector( 7 downto 0 );
    rxn             : in  std_logic_vector( 7 downto 0 );
    
    mgt250          : in  std_logic;    -- reference clock 250 MHz from PCI_Express
    
    perst           : in  std_logic;    -- 0 - reset
    
    px              : out std_logic_vector( 7 downto 0 );   --! контрольные точки 
    
    pcie_lstatus    : out std_logic_vector( 15 downto 0 );  -- регистр LSTATUS
    pcie_link_up    : out std_logic;                        -- 0 - завершена инициализация PCI-Express
    
    ---- Wishbone SYS_CON -----
    o_wb_clk        :   out std_logic;
    o_wb_rst        :   out std_logic;
    ---- Wishbone BUS -----
    ov_wbm_addr     :   out std_logic_vector(31 downto 0);
    ov_wbm_data     :   out std_logic_vector(63 downto 0);
    ov_wbm_sel      :   out std_logic_vector( 7 downto 0);
    o_wbm_we        :   out std_logic;
    o_wbm_cyc       :   out std_logic;
    o_wbm_stb       :   out std_logic;
    ov_wbm_cti      :   out std_logic_vector( 2 downto 0);  -- Cycle Type Identifier Address Tag
    ov_wbm_bte      :   out std_logic_vector( 1 downto 0);  -- Burst Type Extension Address Tag
    
    iv_wbm_data     :   in  std_logic_vector(63 downto 0);
    i_wbm_ack       :   in  std_logic;
    i_wbm_err       :   in  std_logic;                      -- error input - abnormal cycle termination
    i_wbm_rty       :   in  std_logic;                      -- retry input - interface is not ready
    
    i_wdm_irq_0     :   in  std_logic;
    iv_wbm_irq_dmar :   in  std_logic_vector( 1 downto 0)
    
);
end component pcie_core64_wishbone_m8;

end package pcie_core64_wishbone_m8_pkg;
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

use work.core64_type_pkg.all;
use work.pcie_core64_m1_pkg.all;
use work.core64_pb_wishbone_pkg.all;
use work.block_pe_main_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity pcie_core64_wishbone_m8 is
generic 
(
    Device_ID       : in std_logic_vector( 15 downto 0 ):=x"0000";  -- идентификатор модуля
    Revision        : in std_logic_vector( 15 downto 0 ):=x"0000";  -- версия модуля
    PLD_VER         : in std_logic_vector( 15 downto 0 ):=x"0000";  -- версия ПЛИС
    
    is_simulation   : integer:=0   	--! 0 - synthesis, 1 - simulation                                  --! 0 - синтез, 1 - моделирование 
);
port 
(
    ---- PCI-Express ----
    txp             : out std_logic_vector( 7 downto 0 );
    txn             : out std_logic_vector( 7 downto 0 );
    
    rxp             : in  std_logic_vector( 7 downto 0 );
    rxn             : in  std_logic_vector( 7 downto 0 );
    
    mgt250          : in  std_logic;    -- reference clock 250 MHz from PCI_Express
    
    perst           : in  std_logic;    -- 0 - reset
    
    px              : out std_logic_vector( 7 downto 0 );   --! контрольные точки 
    
    pcie_lstatus    : out std_logic_vector( 15 downto 0 );  -- регистр LSTATUS
    pcie_link_up    : out std_logic;                        -- 0 - завершена инициализация PCI-Express
    
    ---- Wishbone SYS_CON -----
    o_wb_clk        :   out std_logic;
    o_wb_rst        :   out std_logic;
    ---- Wishbone BUS -----
    ov_wbm_addr     :   out std_logic_vector(31 downto 0);
    ov_wbm_data     :   out std_logic_vector(63 downto 0);
    ov_wbm_sel      :   out std_logic_vector( 7 downto 0);
    o_wbm_we        :   out std_logic;
    o_wbm_cyc       :   out std_logic;
    o_wbm_stb       :   out std_logic;
    ov_wbm_cti      :   out std_logic_vector( 2 downto 0);  -- Cycle Type Identifier Address Tag
    ov_wbm_bte      :   out std_logic_vector( 1 downto 0);  -- Burst Type Extension Address Tag
    
    iv_wbm_data     :   in  std_logic_vector(63 downto 0);
    i_wbm_ack       :   in  std_logic;
    i_wbm_err       :   in  std_logic;                      -- error input - abnormal cycle termination
    i_wbm_rty       :   in  std_logic;                      -- retry input - interface is not ready
    
    i_wdm_irq_0     :   in  std_logic;
    iv_wbm_irq_dmar :   in  std_logic_vector( 1 downto 0)
    
);
end pcie_core64_wishbone_m8;

architecture pcie_core64_wishbone_m8 of pcie_core64_wishbone_m8 is
-------------------------------------------------------------------------------
--
-- BAR0 - блоки управления ----
signal	bp_host_data	: std_logic_vector( 31 downto 0 );	--! шина данных - выход 
signal	bp_data			: std_logic_vector( 31 downto 0 );  --! шина данных - вход
signal	bp_adr			: std_logic_vector( 19 downto 0 );	--! адрес регистра внутри блока 
signal	bp_we			: std_logic_vector( 3 downto 0 ); 	--! 1 - запись в регистры 
signal	bp_rd			: std_logic_vector( 3 downto 0 );   --! 1 - чтение из регистров блока 
signal	bp_sel			: std_logic_vector( 1 downto 0 );	--! номер блока для чтения 
signal	bp_reg_we		: std_logic;			--! 1 - запись в регистр по адресам   0x100000 - 0x1FFFFF 
signal	bp_reg_rd		: std_logic; 			--! 1 - чтение из регистра по адресам 0x100000 - 0x1FFFFF 
signal	bp_irq			: std_logic;						--! 1 - запрос прерывания 

signal	pb_master		: type_pb_master;		--! запрос 
signal	pb_slave		: type_pb_slave;		--! ответ  

signal	pb_reset		: std_logic;
signal	brd_mode		: std_logic_vector( 15 downto 0 );

signal	bp0_data		: std_logic_vector( 31 downto 0 );
-------------------------------------------------------------------------------
--
-- Declare Global SYS_CON stuff:
signal  clk  			: std_logic;
signal  reset     		: std_logic;
signal  dcm_rst_out   	: std_logic;	
signal	reset_p			: std_logic;
signal	reset_p_z1		: std_logic;
signal	reset_p_z2		: std_logic;

signal	clk125x			: std_logic:='0';
signal	clk125			: std_logic;

-------------------------------------------------------------------------------
begin
-------------------------------------------------------------------------------
--
-- Instantiate CORE64_M6 module with PB BUS:
--
CORE    :   pcie_core64_m1 
generic map
(
    is_simulation   => is_simulation    --! 0 - synthesis, 1 - simulation 
)
port map
(
    ---- PCI-Express ----
    txp             => txp,
    txn             => txn,
    
    rxp             => rxp,
    rxn             => rxn,
    
    mgt250          => mgt250,
    
    perst           => perst,
    
    px              => px,
    
    pcie_lstatus    => pcie_lstatus,
    pcie_link_up    => pcie_link_up,
    
    ---- Локальная шина ----
    clk_out         => clk,  -- S6 PCIE x1 module clock output
    reset_out       => reset,     -- 
    dcm_rstp        => dcm_rst_out,   -- S6 PCIE x1 module INV trn_reset_n_c
    
    ---- BAR1 (PB bus) ----
    aclk            => clk125,  
    aclk_lock       => '1',             -- 
    pb_master       => pb_master,       --
    pb_slave        => pb_slave,        -- 
    
    ---- BAR0 (to PE_MAIN) - блоки управления ----
    bp_host_data    => bp_host_data,
    bp_data         => bp_data,
    bp_adr          => bp_adr,
    bp_we           => bp_we,
    bp_rd           => bp_rd,
    bp_sel          => bp_sel,
    bp_reg_we       => bp_reg_we,
    bp_reg_rd       => bp_reg_rd,
    bp_irq          => bp_irq
    
);	  

clk125x <= not clk125x after 0.5 ns when rising_edge( clk );
xclk125: bufg port map( clk125, clk125x );

reset_p <= (not reset) or (not brd_mode(3));	  
reset_p_z1 <= reset_p 	 after 1 ns when rising_edge( clk125 );
reset_p_z2 <= reset_p_z1 after 1 ns when rising_edge( clk125 );

-- Deal with CORE BP Input data:
bp_data <= bp0_data when bp_sel="00" else (others=>'0');
-------------------------------------------------------------------------------
--
-- Instantiate PE_MAIN module:
--
PE_MAIN    :   block_pe_main 
generic map
(
    Device_ID       => Device_ID,   -- идентификатор модуля
    Revision        => Revision,    -- версия модуля
    PLD_VER         => PLD_VER,     -- версия ПЛИС
    BLOCK_CNT       => x"0008"      -- число блоков управления 
)
port map
(
    ---- Global ----
    reset_hr1       => reset,     -- 0 - сброс
    clk             => clk,  -- Тактовая частота PCIE x1 S6
    pb_reset        => pb_reset,        -- 0 - сброс ведомой ПЛИС
    
    ---- HOST ----
    bl_adr          => bp_adr( 4 downto 0 ),    -- адрес
    bl_data_in      => bp_host_data,            -- данные
    bl_data_out     => bp0_data,                -- данные
    bl_data_we      => bp_we(0),                -- 1 - запись данных   
    
    ---- Управление ----
    brd_mode        => brd_mode                 -- регистр BRD_MODE
    
);
-------------------------------------------------------------------------------
--
-- Instantiate PB BUS <-> WB BUS translator module:
--
PW_WB   :   core64_pb_wishbone 
port map
(
    reset           => reset_p_z2,  	--! 1 - сброс
    clk             => clk125,  			--! тактовая частота локальной шины 
    
    ---- BAR1 ----
    pb_master       => pb_master,       --! запрос 
    pb_slave        => pb_slave,        --! ответ  
    
    ---- Wishbone BUS -----
    ov_wbm_addr     => ov_wbm_addr,     
    ov_wbm_data     => ov_wbm_data,     
    ov_wbm_sel      => ov_wbm_sel,      
    o_wbm_we        => o_wbm_we,        
    o_wbm_cyc       => o_wbm_cyc,       
    o_wbm_stb       => o_wbm_stb,       
    ov_wbm_cti      => ov_wbm_cti,      -- Cycle Type Identifier Address Tag
    ov_wbm_bte      => ov_wbm_bte,      -- Burst Type Extension Address Tag
    
    iv_wbm_data     => iv_wbm_data,     
    i_wbm_ack       => i_wbm_ack,       
    i_wbm_err       => i_wbm_err,       -- error input - abnormal cycle termination
    i_wbm_rty       => i_wbm_rty,       -- retry input - interface is not ready
    
    i_wdm_irq_0     => i_wdm_irq_0,     
    iv_wbm_irq_dmar => iv_wbm_irq_dmar  
);
-------------------------------------------------------------------------------
--
-- Module Output route:
--
o_wb_clk    <= clk125;  -- route from PW_WB wrk clock
--						  
pr_o_wb_rst: process( reset_p, clk125 ) begin
	if( reset_p='1' ) then
		o_wb_rst <= '1' after 1 ns;
	elsif( rising_edge( clk125 ) ) then
		o_wb_rst <= reset_p_z2 after 1 ns;
	end if;
end process;


-------------------------------------------------------------------------------
end pcie_core64_wishbone_m8;
