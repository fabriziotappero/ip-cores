library verilog;
use verilog.vl_types.all;
entity r32_inst_reg is
    port(
        r32_i           : in     vl_logic_vector(31 downto 0);
        r32_o           : out    vl_logic_vector(31 downto 0);
        clk             : in     vl_logic;
        hold            : in     vl_logic;
        imds            : in     vl_logic;
        branch          : in     vl_logic
    );
end r32_inst_reg;
