library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.whisk_constants.all;
use work.all;

entity instr_fetch is
    port( 
    -- data lines
    instruction : out std_logic_vector(MC_INSTR_BITS - 1 downto 0);
    next_pc : out std_logic_vector(MC_ADDR_BITS - 1 downto 0);

    branch_target : in std_logic_vector(MC_ADDR_BITS - 1 downto 0);

    -- control lines
    core_clk : in std_logic;
    core_rst : in std_logic;
    pc_mux : in std_logic_vector(1 downto 0)
    );
end entity;

architecture mixed of instr_fetch is
    -- Program counter
    signal pc : std_logic_vector(MC_ADDR_BITS - 1 downto 0);
    signal pc_inc : std_logic_vector(MC_ADDR_BITS - 1 downto 0);
--    signal IFID : IFID_t; -- pipeline register

begin

    imem : entity preload_mem
    generic map ( 
        memsize => INSTR_MEM_SIZE, 
        addrbits => MC_ADDR_BITS,
        databits => MC_INSTR_BITS, 
        initfile => INSTR_MEM_INIT )
    port map ( 
        clk => core_clk,
        addr => pc,
        dout => instruction,
        -- just push 0 to the write port.
		din => "000000000000000000000000000000000000000000000000",
        we => '0' );

    pc_inc <= std_logic_vector(unsigned(pc) + 1); 

    -- PC MUX
    instr_fetch : process (core_clk)
    begin
        --pc_inc <= std_logic_vector(unsigned(pc) + 1); 
        if rising_edge(core_clk) then
            if core_rst = '0' then 
                pc <= (others => '0');
            elsif pc_mux = PCMUX_STALL then
                pc <= pc; -- uh
            elsif pc_mux = PCMUX_BRANCH then
                pc <= branch_target;
            elsif pc_mux = PCMUX_NOBRANCH then
                pc <= pc_inc; -- is this even legal
            else
                pc <= pc_inc;
            end if;
           
            -- Write pipeline registers. 
            next_pc <= pc;

        end if;
    end process;
end architecture;
