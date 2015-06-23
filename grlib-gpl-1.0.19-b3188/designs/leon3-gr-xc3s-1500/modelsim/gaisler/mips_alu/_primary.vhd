library verilog;
use verilog.vl_types.all;
entity mips_alu is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        a               : in     vl_logic_vector(31 downto 0);
        b               : in     vl_logic_vector(31 downto 0);
        c               : out    vl_logic_vector(31 downto 0);
        ctl             : in     vl_logic_vector(4 downto 0)
    );
end mips_alu;
