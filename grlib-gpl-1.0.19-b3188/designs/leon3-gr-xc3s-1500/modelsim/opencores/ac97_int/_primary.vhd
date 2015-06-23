library verilog;
use verilog.vl_types.all;
entity ac97_int is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        int_set         : out    vl_logic_vector(2 downto 0);
        cfg             : in     vl_logic_vector(7 downto 0);
        status          : in     vl_logic_vector(1 downto 0);
        full_empty      : in     vl_logic;
        full            : in     vl_logic;
        empty           : in     vl_logic;
        re              : in     vl_logic;
        we              : in     vl_logic
    );
end ac97_int;
