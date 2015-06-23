library verilog;
use verilog.vl_types.all;
entity r2_reg_cls is
    port(
        r2_i            : in     vl_logic_vector(1 downto 0);
        r2_o            : out    vl_logic_vector(1 downto 0);
        clk             : in     vl_logic;
        cls             : in     vl_logic;
        hold            : in     vl_logic
    );
end r2_reg_cls;
