library verilog;
use verilog.vl_types.all;
entity shifter_tak is
    port(
        a               : in     vl_logic_vector(31 downto 0);
        shift_out       : out    vl_logic_vector(31 downto 0);
        shift_func      : in     vl_logic_vector(4 downto 0);
        shift_amount    : in     vl_logic_vector(31 downto 0)
    );
end shifter_tak;
