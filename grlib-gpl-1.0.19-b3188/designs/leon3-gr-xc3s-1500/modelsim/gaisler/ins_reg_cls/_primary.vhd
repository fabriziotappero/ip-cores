library verilog;
use verilog.vl_types.all;
entity ins_reg_cls is
    port(
        ins_i           : in     vl_logic_vector(31 downto 0);
        ins_o           : out    vl_logic_vector(31 downto 0);
        clk             : in     vl_logic;
        cls             : in     vl_logic;
        hold            : in     vl_logic
    );
end ins_reg_cls;
