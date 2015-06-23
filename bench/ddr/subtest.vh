/****************************************************************************************
*
*    File Name:  subtest.vh
*
*  Description:  Micron SDRAM DDR2 (Double Data Rate 2)
*                This file is included by tb.v
*
*   Disclaimer   This software code and all associated documentation, comments or other 
*  of Warranty:  information (collectively "Software") is provided "AS IS" without 
*                warranty of any kind. MICRON TECHNOLOGY, INC. ("MTI") EXPRESSLY 
*                DISCLAIMS ALL WARRANTIES EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
*                TO, NONINFRINGEMENT OF THIRD PARTY RIGHTS, AND ANY IMPLIED WARRANTIES 
*                OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. MTI DOES NOT 
*                WARRANT THAT THE SOFTWARE WILL MEET YOUR REQUIREMENTS, OR THAT THE 
*                OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE. 
*                FURTHERMORE, MTI DOES NOT MAKE ANY REPRESENTATIONS REGARDING THE USE OR 
*                THE RESULTS OF THE USE OF THE SOFTWARE IN TERMS OF ITS CORRECTNESS, 
*                ACCURACY, RELIABILITY, OR OTHERWISE. THE ENTIRE RISK ARISING OUT OF USE 
*                OR PERFORMANCE OF THE SOFTWARE REMAINS WITH YOU. IN NO EVENT SHALL MTI, 
*                ITS AFFILIATED COMPANIES OR THEIR SUPPLIERS BE LIABLE FOR ANY DIRECT, 
*                INDIRECT, CONSEQUENTIAL, INCIDENTAL, OR SPECIAL DAMAGES (INCLUDING, 
*                WITHOUT LIMITATION, DAMAGES FOR LOSS OF PROFITS, BUSINESS INTERRUPTION, 
*                OR LOSS OF INFORMATION) ARISING OUT OF YOUR USE OF OR INABILITY TO USE 
*                THE SOFTWARE, EVEN IF MTI HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH 
*                DAMAGES. Because some jurisdictions prohibit the exclusion or 
*                limitation of liability for consequential or incidental damages, the 
*                above limitation may not apply to you.
*
*                Copyright 2003 Micron Technology, Inc. All rights reserved.
*
****************************************************************************************/

    initial begin : test
        cke     <=  1'b0;
        cs_n    <=  1'b1;
        ras_n   <=  1'b1;
        cas_n   <=  1'b1;
        we_n    <=  1'b1;
        ba      <=  {BA_BITS{1'bz}};
        a       <=  {ADDR_BITS{1'bz}};
        odt     <=  1'b0;
        dq_en   <=  1'b0;
        dqs_en  <=  1'b0;

        cke     <=  1'b1;

        // POWERUP SECTION 
        power_up;

        // INITIALIZE SECTION
        precharge       (0, 1);                         // Precharge all banks
        nop             (trp);
        
        load_mode       (2, 0);                         // Extended Mode Register (2)
        nop             (tmrd-1);
        
        load_mode       (3, 0);                         // Extended Mode Register (3)
        nop             (tmrd-1);
        
        load_mode       (1, 13'b0_0_0_000_0_000_1_0_0); // Extended Mode Register with DLL Enable
        nop             (tmrd-1);
        
        load_mode       (0, 13'b0_000_1_0_000_0_011 | (twr-1)<<9 | taa<<4); // Mode Register without DLL Reset (bl=8)
        nop             (tmrd-1);
        
        precharge       (0, 1);                         // Precharge all banks
        nop             (trp);
        
        refresh;
        nop             (trfc-1);

        refresh;
        nop             (trfc-1);
        
        load_mode       (0, 13'b0_000_0_0_000_0_011 | (twr-1)<<9 | taa<<4); // Mode Register without DLL Reset (bl=8)
        nop             (tmrd-1);

        load_mode       (1, 13'b0_0_0_111_0_000_1_0_0); // Extended Mode Register with OCD Default
        nop             (tmrd-1);
        
        load_mode       (1, 13'b0_0_0_000_0_000_1_0_0); // Extended Mode Register with OCD Exit
        nop             (tmrd-1);
        
        // DLL RESET ENABLE - you will need 200 TCK before any read command.
        nop             (200);

        // WRITE SECTION
        activate        (0, 0);                       // Activate Bank 0, Row 0
        nop             (trcd-1);
        write           (0, 4, 0, 0, 'h3210);         // Write  Bank 0, Col 0
        nop             (tccd-1);
        write           (0, 0, 1, 0, 'h0123);         // Write  Bank 0, Col 0

        activate        (1, 0);                       // Activate Bank 1, Row 0
        nop             (trcd-1);
        write           (1, 0, 1, 0, 'h4567);         // Write  Bank 1, Col 0

        activate        (2, 0);                       // Activate Bank 2, Row 0
        nop             (trcd-1);
        write           (2, 0, 1, 0, 'h89AB);         // Write  Bank 2, Col 0

        activate        (3, 0);                       // Activate Bank 3, Row 0
        nop             (trcd-1);
        write           (3, 0, 1, 0, 'hCDEF);         // Write  Bank 3, Col 0

        nop             (cl - 1 + bl/2 + twtr-1);

        nop             (tras);

        // READ SECTION
        activate        (0, 0);                       // Activate Bank 0, Row 0
        nop             (trrd-1);
        activate        (1, 0);                       // Activate Bank 1, Row 0
        nop             (trrd-1);
        activate        (2, 0);                       // Activate Bank 2, Row 0
        nop             (trrd-1);
        activate        (3, 0);                       // Activate Bank 3, Row 0
        read            (0, 0, 1);                    // Read   Bank 0, Col 0
        nop             (bl/2);
        read            (1, 1, 1);                    // Read   Bank 1, Col 1
        nop             (bl/2);
        read            (2, 2, 1);                    // Read   Bank 2, Col 2
        nop             (bl/2);
        read            (3, 3, 1);                    // Read   Bank 3, Col 3
        nop             (rl + bl/2);

        activate        (0, 0);                       // Activate Bank 0, Row 0
        nop             (trrd-1);
        activate        (1, 0);                       // Activate Bank 1, Row 0
        nop             (trcd-1);
        $display ("%m at time %t: Figure 22: Consecutive READ Bursts", $time);
        read            (0, 0, 0);                    // Read   Bank 0, Col 0
        nop             (bl/2-1);
        read            (0, 4, 0);                    // Read   Bank 0, Col 4
        nop             (rl + bl/2);

        $display ("%m at time %t: Figure 23: Nonconsecutive READ Bursts", $time);
        read            (0, 0, 0);                    // Read   Bank 0, Col 0
        nop             (bl/2);
        read            (0, 4, 0);                    // Read   Bank 0, Col 4
        nop             (rl + bl/2);

        $display ("%m at time %t: Figure 24: READ Interrupted by READ", $time);
        read            (0, 0, 0);                    // Read   Bank 0, Col 0
        nop             (tccd-1);
        read            (1, 0, 0);                    // Read   Bank 0, Col 0
        nop             (rl + bl/2);

        $display ("%m at time %t: Figure 25 & 26: READ to PRECHARGE", $time);
        read            (0, 0, 0);                    // Read   Bank 0, Col 0
        nop             (al + bl/2 + trtp - 2);
        precharge       (0, 0);                       // Precharge Bank 0
        nop             (trp-1);

        activate        (0, 0);                       // Activate Bank 0, Row 0
        nop             (trcd-1);
        $display ("%m at time %t: Figure 27: READ to WRITE", $time);
        read            (0, 0, 0);                    // Read   Bank 0, Col 0
        nop             (rl + bl/2 - wl);
        write           (0, 0, 1, 0, 'h0123);         // Write  Bank 0, Col 0
        nop             (wl + bl/2 + twr + trp-1);

        activate        (0, 0);                       // Activate Bank 0, Row 0
        nop             (trcd-1);
        $display ("%m at time %t: Figure 36: Nonconsecutive WRITE to WRITE", $time);
        write           (0, 0, 0, 0, 'h0123);         // Write  Bank 0, Col 0
        nop             (bl/2);
        write           (0, 4, 0, 0, 'h0123);         // Write  Bank 0, Col 0
        nop             (wl + bl/2);

        $display ("%m at time %t: Figure 37: Random WRITE Cycles", $time);
        write           (0, 0, 0, 0, 'h0123);         // Write  Bank 0, Col 0
        nop             (bl/2-1);
        write           (0, 4, 0, 0, 'h0123);         // Write  Bank 0, Col 0
        nop             (wl + bl/2);

        $display ("%m at time %t: Figure 37: Figure 38: WRITE Interrupted by WRITE", $time);
        write           (0, 0, 0, 0, 'h0123);         // Write  Bank 0, Col 0
        nop             (tccd-1);
        write           (1, 4, 0, 0, 'h0123);         // Write  Bank 0, Col 0
        nop             (wl + bl/2);

        $display ("%m at time %t: Figure 39: WRITE to READ", $time);
        write           (0, 0, 0, 0, 'h0123);         // Write  Bank 0, Col 0
        nop             (wl + bl/2 + twtr-1);
        read_verify     (0, 0, 0, 0, 'h0123);         // Read   Bank 0, Col 0
        nop             (rl + bl/2);

        $display ("%m at time %t: Figure 40: WRITE to PRECHARGE", $time);
        write           (0, 0, 0, 0, 'h0123);         // Write  Bank 0, Col 0
        nop             (wl + bl/2 + twr-1);
        precharge       (0, 1);                       // Precharge all banks
        nop             (trp-1);

        // odt Section
        $display ("%m at time %t: Figure 60: odt Timing for Active or Fast-Exit Power-Down Mode", $time);
        odt             = 1'b1;
        nop             (1);
        odt             = 1'b0;
        nop             (tanpd);

        $display ("%m at time %t: Figure 61: odt timing for Slow-Exit or Precharge Power-Down Modes", $time);
        cke             = 1'b0;
        @(negedge ck);
        odt             = 1'b1;
        @(negedge ck);
        odt             = 1'b0;
        repeat(tanpd)@(negedge ck);
        nop             (taxpd);

        $display ("%m at time %t: Figure 62 & 63: odt Transition Timings when Entering Power-Down Mode", $time);
        odt             = 1'b1;
        nop             (tanpd);
        power_down      (tcke);

        // Self Refresh Section
        nop             (taxpd);
        odt             = 1'b0;
        nop             (3); // taofd
        self_refresh    (tcke);
        nop             (tdllk);
        nop             (tcke);

        test_done;
    end
