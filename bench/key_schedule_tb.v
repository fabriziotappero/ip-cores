// the test bench module for key_schedule
`timescale 10ns/1ns

module key_schedule_tb;
reg     [8*8-1:0]  ck;
reg                clk;
reg                rst;
reg                start;
wire    [56*8-1:0] kk;
wire               done;
wire               busy;

        initial
        begin
        clk<=1'h0;
        forever #5 clk=~clk;
        end

        initial
        begin
        @(posedge clk);
        rst<=1'h1;
        @(posedge clk);
        @(posedge clk);
        rst=1'h0;
        @(posedge clk);
        end

        initial
        begin

        // read CK
        $read_data(
                                "../test_dat/key_schedule.in"
                               ,ck
                  );
        start=1'h0;

        repeat (4) @(posedge clk);
        start=1'h1;
        @(posedge clk);
        start=1'h0;
        repeat (20) @(posedge clk);

        $display("ck=%h",ck);
        $display("kk=%h",kk);

        // output kk

        $write_data(
                        "../test_dat/key_schedule.out.v"
                       ,kk
                   );
        $stop;
        end

        key_schedule key_schedule(
                         .clk     (clk)
                        ,.rst     (rst)
                        ,.start   (start)
                        ,.ck      (ck)
                        ,.busy    (busy)
                        ,.done    (done)
                        ,.kk      (kk)
                        );
endmodule
