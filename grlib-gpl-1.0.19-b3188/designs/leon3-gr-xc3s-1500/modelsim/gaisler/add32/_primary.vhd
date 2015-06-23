library verilog;
use verilog.vl_types.all;
entity add32 is
    port(
        d_i             : in     vl_logic_vector(31 downto 0);
        d_o             : out    vl_logic_vector(31 downto 0)
    );
end add32;
