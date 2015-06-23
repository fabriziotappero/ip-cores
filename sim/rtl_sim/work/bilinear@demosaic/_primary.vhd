library verilog;
use verilog.vl_types.all;
entity bilinearDemosaic is
    generic(
        DATA_WIDTH      : integer := 8;
        X_RES_WIDTH     : integer := 11;
        Y_RES_WIDTH     : integer := 11;
        BUFFER_SIZE     : integer := 4
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        dIn             : in     vl_logic_vector;
        dInValid        : in     vl_logic;
        nextDin         : out    vl_logic;
        start           : in     vl_logic;
        rOut            : out    vl_logic_vector;
        gOut            : out    vl_logic_vector;
        bOut            : out    vl_logic_vector;
        dOutValid       : out    vl_logic;
        nextDout        : in     vl_logic;
        bayerPattern    : in     vl_logic_vector(1 downto 0);
        xRes            : in     vl_logic_vector;
        yRes            : in     vl_logic_vector
    );
end bilinearDemosaic;
