library verilog;
use verilog.vl_types.all;
entity muldiv is
    port(
        ready           : out    vl_logic;
        rst             : in     vl_logic;
        op1             : in     vl_logic_vector(31 downto 0);
        op2             : in     vl_logic_vector(31 downto 0);
        clk             : in     vl_logic;
        dout            : out    vl_logic_vector(31 downto 0);
        func            : in     vl_logic_vector(4 downto 0)
    );
end muldiv;
