library ieee;
use ieee.std_logic_1164.all;

use work.whisk_constants.all;

entity mem is
    port (
    -- Pipeline control signals
    clk : in std_logic; 
    exec_reg_write : in std_logic; -- Register write control signal

    mem_reg_write : out std_logic; -- Register write enable signal feed forward
    mem_mem_to_reg : out std_logic; -- Write result from memory (indiates a load, basically)

    -- Pipeline data signals
    address : in std_logic_vector(WORD_BITS - 1 downto 0); -- address to write to (also result from alu)
    data : in std_logic_vector(WORD_BITS - 1 downto 0); -- data to be written
    
    mem_loaded_data : out std_logic_vector(WORD_BITS - 1 downto 0); -- Data fetched from memory
    mem_alu_result : out std_logic_vector(WORD_BITS - 1 downto 0); -- Result from ALU

    -- To/From bidirectional bus interface
    mem_read_data : in std_logic_vector(WORD_BITS - 1 downto 0);
    mem_write_data : out std_logic_vector(WORD_BITS - 1 downto 0);
    mem_address : out std_logic_vector(ADDR_BITS - 1 downto 0);

     -- Control signals  memory
    write_mem : out std_logic; -- Indicates a memory write
    read_mem : out std_logic; -- Indicates a memory read
    memory_wait : in std_logic -- Stall for memory.

);
end entity;

architecture mixed of mem is
begin
    -- cache
    
    mem_stage : process 
    begin
        if rising_edge(clk) then
            -- Control signals feed forward.
            --mem_reg_write <= exec_reg_write;
            --mem_mem_to_reg <= read_mem; -- For write-back mux.

            -- Data paths
            --mem_alu_result <= address; -- Address is also result.
            --mem_loaded_data <= mem_read_data; -- From bus interface.
        end if;
    end process;
end architecture;
   
