module  mod3_tb ();
    reg [ 7: 0] dat_i;
    reg [ 1: 0] comp;
    reg [ 1: 0] err_cnt;
    
    wire    [ 1: 0] reminder;
    
    initial begin
        $display("------------------The self_check begin ------------------");
        dat_i   = 0;
        err_cnt = 0;
        repeat(256) begin
            comp    = dat_i % 3;
            #5;
            if (reminder != comp)   begin
                $display("comp = %d, calc data = %d", comp, reminder);
                err_cnt = err_cnt + 1;
            end
            dat_i   = dat_i + 1;
        end
        
        if (err_cnt == 0)
            $display("------------------The self_check passed------------------");
        else
            $display("------------------The self_check failed------------------");
        $stop;
        
    end

    mod3 M0(
        .dat_i(dat_i),
        .reminder(reminder)
    );
endmodule
