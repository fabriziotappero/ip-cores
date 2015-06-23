library verilog;
use verilog.vl_types.all;
entity spc_reg is
    port(
        spc_i           : in     vl_logic_vector(31 downto 0);
        spc_o           : out    vl_logic_vector(31 downto 0);
        clk             : in     vl_logic;
        hold            : in     vl_logic
    );
end spc_reg;
