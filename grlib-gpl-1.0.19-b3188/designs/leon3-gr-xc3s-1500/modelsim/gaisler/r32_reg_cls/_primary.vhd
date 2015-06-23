library verilog;
use verilog.vl_types.all;
entity r32_reg_cls is
    port(
        r32_i           : in     vl_logic_vector(31 downto 0);
        r32_o           : out    vl_logic_vector(31 downto 0);
        clk             : in     vl_logic;
        cls             : in     vl_logic;
        hold            : in     vl_logic
    );
end r32_reg_cls;
