library verilog;
use verilog.vl_types.all;
entity wb_mux is
    port(
        alu_i           : in     vl_logic_vector(31 downto 0);
        dmem_i          : in     vl_logic_vector(31 downto 0);
        sel             : in     vl_logic;
        wb_o            : out    vl_logic_vector(31 downto 0)
    );
end wb_mux;
