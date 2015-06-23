library verilog;
use verilog.vl_types.all;
entity alu is
    port(
        a               : in     vl_logic_vector(31 downto 0);
        b               : in     vl_logic_vector(31 downto 0);
        alu_out         : out    vl_logic_vector(31 downto 0);
        alu_func        : in     vl_logic_vector(4 downto 0)
    );
end alu;
