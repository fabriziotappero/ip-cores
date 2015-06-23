-------------------------------------------------------------------------------
--
-- Title       : core64_pb_wishbone
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.0
--
-------------------------------------------------------------------------------
--
-- Description : Узел управления локальной шиной 
--												
--		pb_master.cmd	- команда управления, сопровождается стробом stb0
--					0: 	- 1 запись данных
--					1:  - 1 чтение данных
--					2:  - 0 - одно слово, 1 - пакет 512 слов (4096 байт)
--
-------------------------------------------------------------------------------
--
--  Version 1.0  07.10.2011 Dmitry Smekhov
--				 Создан из core64_pb_transaction v1.1
--
--  Version 1.1  14.10.2011, Kuzmi4
--                  Add PB_WB converter
--
--  Version 1.2  19.10.2011, Kuzmi4
--                  Move "core64_pb_wishbone_ctrl" component declaration for PKG to here 
--                    (in accordance to http://ds-dev.ru/boards/1/topics/4, point#4)
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.core64_type_pkg.all;

package core64_pb_wishbone_pkg is

component core64_pb_wishbone is
port
(
    reset               : in std_logic;     --! 1 - сброс
    clk                 : in std_logic;     --! тактовая частота локальной шины 
    
    ---- BAR1 ----
    pb_master           : in  type_pb_master;   --! запрос 
    pb_slave            : out type_pb_slave;    --! ответ  
    
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
end component core64_pb_wishbone;

end package core64_pb_wishbone_pkg;

-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;	   
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.core64_type_pkg.all;

entity core64_pb_wishbone is
port
(
    reset               : in std_logic;     --! 1 - сброс
    clk                 : in std_logic;     --! тактовая частота локальной шины 
    
    ---- BAR1 ----
    pb_master           : in  type_pb_master;   --! запрос 
    pb_slave            : out type_pb_slave;    --! ответ  
    
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
end core64_pb_wishbone;

architecture core64_pb_wishbone of core64_pb_wishbone is
-------------------------------------------------------------------------------
--
-- Declare "core64_pb_wishbone_ctrl" component here:
component core64_pb_wishbone_ctrl is
port 
( 
    --
    -- SYS_CON
    i_clk : in  STD_LOGIC;
    i_rst : in  STD_LOGIC;
    --
    -- PB_MASTER (in) IF
    i_pb_master_stb0    :   in  std_logic;
    i_pb_master_stb1    :   in  std_logic;
    iv_pb_master_cmd    :   in  std_logic_vector( 2 downto 0);
    iv_pb_master_addr   :   in  std_logic_vector(31 downto 0);
    iv_pb_master_data   :   in  std_logic_vector(63 downto 0);
    --
    -- PB_SLAVE (out) IF:
    o_pb_slave_ready    :   out std_logic;
    o_pb_slave_complete :   out std_logic;
    o_pb_slave_stb0     :   out std_logic;
    o_pb_slave_stb1     :   out std_logic;
    ov_pb_slave_data    :   out std_logic_vector(63 downto 0);
    ov_pb_slave_dmar    :   out std_logic_vector( 1 downto 0);
    o_pb_slave_irq      :   out std_logic;
    --
    -- WB BUS:
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
end component core64_pb_wishbone_ctrl;
-------------------------------------------------------------------------------
begin
-------------------------------------------------------------------------------
--
-- Instantiate PB_WB_BRIDGE (and route PB wires):
--
PB_WB_BRIDGE    :   core64_pb_wishbone_ctrl
port map
( 
    --
    -- SYS_CON
    i_clk => clk,           -- 
    i_rst => reset,         -- 
    --
    -- PB_MASTER (in) IF
    i_pb_master_stb0    => pb_master.stb0, 
    i_pb_master_stb1    => pb_master.stb1, 
    iv_pb_master_cmd    => pb_master.cmd, 
    iv_pb_master_addr   => pb_master.adr, 
    iv_pb_master_data   => pb_master.data, 
    --
    -- PB_SLAVE (out) IF:
    o_pb_slave_ready    => pb_slave.ready, 
    o_pb_slave_complete => pb_slave.complete, 
    o_pb_slave_stb0     => pb_slave.stb0, 
    o_pb_slave_stb1     => pb_slave.stb1, 
    ov_pb_slave_data    => pb_slave.data, 
    ov_pb_slave_dmar    => pb_slave.dmar, 
    o_pb_slave_irq      => pb_slave.irq, 
    --
    -- WB BUS:
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
end core64_pb_wishbone;
