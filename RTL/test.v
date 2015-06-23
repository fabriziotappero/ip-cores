/******************************************************************
 *                                                                * 
 *    Author: Liwei                                               * 
 *                                                                * 
 *    This file is part of the "ClaiRISC" project,                *
 *    The folder in CVS is named as "lwrisc"                      * 
 *    Downloaded from:                                            * 
 *    http://www.opencores.org/pdownloads.cgi/list/lwrisc         * 
 *                                                                * 
 *    If you encountered any problem, please contact me via       * 
 *    Email:mcupro@opencores.org  or mcupro@163.com               * 
 *                                                                * 
 ******************************************************************/

`timescale 10ns / 10ns

module test;

    reg clk;
    reg  rst;

    initial	begin
        #1 clk = 0;
        #10 rst = 0;
        #10 rst = 1;
        #10 rst = 0;
    end

    always #1 clk=~clk ;

    ClaiRISC_core I_ClaiRISC_core
                    (
                        .clk(clk),
                        .rst(rst)
                    ) ;

endmodule
