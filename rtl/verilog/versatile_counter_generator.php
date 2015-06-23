#!/usr/bin/php
<?php

function __autoload($className) {
    include "$className.class.php";
}

if(!isset($argv[1])) {
    ?>
    
        Usage: <?php echo basename($argv[0]); ?> <fileName>
    
<?php
    die(1);
}

$csv = new CSV($argv[1]);

$counter    = $csv->getRow();
$csv->parseHeader();
$inputs     = $csv->getRow();
$csv->parseHeader();
$outputs    = $csv->getRow();
$csv->parseHeader();
$wrap       = $csv->getRow();
$csv->parseHeader();
$parameters = $csv->getRow();

$length = $parameters['length'];

# copyright
echo "//////////////////////////////////////////////////////////////////////" . PHP_EOL;
echo "////                                                              ////" . PHP_EOL;
echo "////  Versatile counter                                           ////" . PHP_EOL;
echo "////                                                              ////" . PHP_EOL;
echo "////  Description                                                 ////" . PHP_EOL;
echo "////  Versatile counter, a reconfigurable binary, gray or LFSR    ////" . PHP_EOL;
echo "////  counter                                                     ////" . PHP_EOL;
echo "////                                                              ////" . PHP_EOL;
echo "////  To Do:                                                      ////" . PHP_EOL;
echo "////   - add LFSR with more taps                                  ////" . PHP_EOL;
echo "////                                                              ////" . PHP_EOL;
echo "////  Author(s):                                                  ////" . PHP_EOL;
echo "////      - Michael Unneback, unneback@opencores.org              ////" . PHP_EOL;
echo "////        ORSoC AB                                              ////" . PHP_EOL;
echo "////                                                              ////" . PHP_EOL;
echo "//////////////////////////////////////////////////////////////////////" . PHP_EOL;
echo "////                                                              ////" . PHP_EOL;
echo "//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////" . PHP_EOL;
echo "////                                                              ////" . PHP_EOL;
echo "//// This source file may be used and distributed without         ////" . PHP_EOL;
echo "//// restriction provided that this copyright statement is not    ////" . PHP_EOL;
echo "//// removed from the file and that any derivative work contains  ////" . PHP_EOL;
echo "//// the original copyright notice and the associated disclaimer. ////" . PHP_EOL;
echo "////                                                              ////" . PHP_EOL;
echo "//// This source file is free software; you can redistribute it   ////" . PHP_EOL;
echo "//// and/or modify it under the terms of the GNU Lesser General   ////" . PHP_EOL;
echo "//// Public License as published by the Free Software Foundation; ////" . PHP_EOL;
echo "//// either version 2.1 of the License, or (at your option) any   ////" . PHP_EOL;
echo "//// later version.                                               ////" . PHP_EOL;
echo "////                                                              ////" . PHP_EOL;
echo "//// This source is distributed in the hope that it will be       ////" . PHP_EOL;
echo "//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////" . PHP_EOL;
echo "//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////" . PHP_EOL;
echo "//// PURPOSE.  See the GNU Lesser General Public License for more ////" . PHP_EOL;
echo "//// details.                                                     ////" . PHP_EOL;
echo "////                                                              ////" . PHP_EOL;
echo "//// You should have received a copy of the GNU Lesser General    ////" . PHP_EOL;
echo "//// Public License along with this source; if not, download it   ////" . PHP_EOL;
echo "//// from http://www.opencores.org/lgpl.shtml                     ////" . PHP_EOL;
echo "////                                                              ////" . PHP_EOL;
echo "//////////////////////////////////////////////////////////////////////" . PHP_EOL;

echo PHP_EOL . "// " . $counter['type'] . " counter" . PHP_EOL;
echo "module " . $counter['Name']. " (";

if ($inputs['clear']=="1") { echo " clear,"; }
if ($inputs['set']=="1")   { echo " set,"; }
if ($inputs['cke']=="1")   { echo " cke,"; }
if ($inputs['rew']=="1")   { echo " rew,"; }

if ($outputs['q']=="1")      { echo " q,"; }
if ($outputs['q_bin']=="1" and $counter['type']=="GRAY")  { echo " q_bin,"; }
if ($outputs['z']=="1")      { echo " z,"; }
if ($outputs['zq']=="1")     { echo " zq,"; }
if ($outputs['level1']=="1") { echo " level1,"; }
if ($outputs['level2']=="1") { echo " level2,"; }
    
echo " rst,";
echo " clk);" . PHP_EOL;
echo PHP_EOL;

echo "   parameter length = " . $length . ";" . PHP_EOL;

if ($inputs['clear']=="1") { echo "   input " . "clear;" . PHP_EOL; }
if ($inputs['set']=="1")   { echo "   input " . "set;" . PHP_EOL; }
if ($inputs['cke']=="1")   { echo "   input " . "cke;" . PHP_EOL; }
if ($inputs['rew']=="1")   { echo "   input " . "rew;" . PHP_EOL; }

if ($counter['type']=="GRAY") {
    if ($outputs['q']=="1")      { echo "   output reg [length:1] q;" . PHP_EOL; }    
} else {
    if ($outputs['q']=="1")      { echo "   output [length:1] q;" . PHP_EOL; }
}
if ($outputs['q_bin']=="1" and $counter['type']=="GRAY")  { echo "   output [length:1] q_bin;" . PHP_EOL; }
if ($outputs['z']=="1")      { echo "   output z;" . PHP_EOL; }
if ($outputs['zq']=="1")     { echo "   output reg zq;" . PHP_EOL; }
if ($outputs['level1']=="1") { echo "   output reg level1;" . PHP_EOL; }
if ($outputs['level2']=="1") { echo "   output reg level2;" . PHP_EOL; }
    
echo "   input rst;" . PHP_EOL;
echo "   input clk;" . PHP_EOL;
echo PHP_EOL;

    if ($parameters['clear_value']!="") { echo "   parameter clear_value = " . $parameters['clear_value'] . ";" . PHP_EOL; }
    if ($parameters['set_value']!="")   { echo "   parameter set_value = " . $parameters['set_value'] . ";" . PHP_EOL; }
    if ($parameters['wrap_value']!="")  { echo "   parameter wrap_value = " . $parameters['wrap_value'] . ";" . PHP_EOL; }
    if ($parameters['level1']!="")      { echo "   parameter level1_value = " . $parameters['level1'] . ";" . PHP_EOL; }
    if ($parameters['level2']!="")      { echo "   parameter level2_value = " . $parameters['level2'] . ";" . PHP_EOL; }

echo PHP_EOL;
if ($outputs['level1']=="1" and $inputs['clear']=="0") { echo  "   wire clear;" . PHP_EOL . "   assign clear = 1'b0;" . PHP_EOL; }
if ($outputs['level1']=="1" and $inputs['rew']=="0") { echo  "   wire rew;" . PHP_EOL . "   assign rew = 1'b0;" . PHP_EOL; }

echo "   reg  [length:1] qi;" . PHP_EOL;
if ($counter['type']=="LFSR") { echo "   reg lfsr_fb";}
if ($counter['type']=="LFSR" and $inputs['rew']==1) { echo ", lfsr_fb_rew;" . PHP_EOL; } else { if ($counter['type']=="LFSR") echo ";" . PHP_EOL; }
if ($inputs['rew']==1) { echo "   wire  [length:1] q_next, q_next_fw, q_next_rew;" . PHP_EOL; }
else { echo "   wire [length:1] q_next;" . PHP_EOL; }
if ($counter['type']=="LFSR" and $inputs['rew']==1) {
    echo "   reg [32:1] polynom_rew;" . PHP_EOL;
    echo "   integer j;" . PHP_EOL;
}

if ($counter['type']=="LFSR") {
    echo "   reg [32:1] polynom;" . PHP_EOL;
    echo "   integer i;" . PHP_EOL . PHP_EOL;
    echo "   always @ (qi)" . PHP_EOL;
    echo "   begin
        case (length) 
         2: polynom = 32'b11;                               // 0x3
         3: polynom = 32'b110;                              // 0x6
         4: polynom = 32'b1100;                             // 0xC
         5: polynom = 32'b10100;                            // 0x14
         6: polynom = 32'b110000;                           // 0x30
         7: polynom = 32'b1100000;                          // 0x60
         8: polynom = 32'b10111000;                         // 0xb8
         9: polynom = 32'b100010000;                        // 0x110
        10: polynom = 32'b1001000000;                       // 0x240
        11: polynom = 32'b10100000000;                      // 0x500
        12: polynom = 32'b100000101001;                     // 0x829
        13: polynom = 32'b1000000001100;                    // 0x100C
        14: polynom = 32'b10000000010101;                   // 0x2015
        15: polynom = 32'b110000000000000;                  // 0x6000
        16: polynom = 32'b1101000000001000;                 // 0xD008
        17: polynom = 32'b10010000000000000;                // 0x12000
        18: polynom = 32'b100000010000000000;               // 0x20400
        19: polynom = 32'b1000000000000100011;              // 0x40023
        20: polynom = 32'b10010000000000000000;             // 0x90000
        21: polynom = 32'b101000000000000000000;            // 0x140000
        22: polynom = 32'b1100000000000000000000;           // 0x300000
        23: polynom = 32'b10000100000000000000000;          // 0x420000
        24: polynom = 32'b111000010000000000000000;         // 0xE10000
        25: polynom = 32'b1001000000000000000000000;        // 0x1200000
        26: polynom = 32'b10000000000000000000100011;       // 0x2000023
        27: polynom = 32'b100000000000000000000010011;      // 0x4000013
        28: polynom = 32'b1100100000000000000000000000;     // 0xC800000
        29: polynom = 32'b10100000000000000000000000000;    // 0x14000000
        30: polynom = 32'b100000000000000000000000101001;   // 0x20000029
        31: polynom = 32'b1001000000000000000000000000000;  // 0x48000000
        32: polynom = 32'b10000000001000000000000000000011; // 0x80200003
        default: polynom = 32'b0;
        endcase
        lfsr_fb = qi[length];
        for (i=length-1; i>=1; i=i-1) begin
            if (polynom[i])
                lfsr_fb = lfsr_fb  ~^ qi[i];
        end
    end";
echo PHP_EOL;
}

if ($inputs['rew']!=1) { echo "   assign q_next = "; } else { echo "   assign q_next_fw  = "; }
if ($inputs['clear']==1)  { echo " clear ? {length{1'b0}} :";}
if ($inputs['set']==1)    { echo " set ? set_value :";}
if ($wrap['wrap']==1)     { echo "(qi == wrap_value) ? {length{1'b0}} :";}
if ($counter['type']=="LFSR") { echo "{qi[length-1:1],lfsr_fb};"; } else { echo "qi + {{length-1{1'b0}},1'b1};"; }
echo PHP_EOL;

if ($inputs['rew']) {
    if ($counter['type']=="LFSR") {
            echo "   always @ (qi)" . PHP_EOL;
    echo "   begin
        case (length) 
         2: polynom_rew = 32'b11;
         3: polynom_rew = 32'b110;
         4: polynom_rew = 32'b1100;
         5: polynom_rew = 32'b10100;
         6: polynom_rew = 32'b110000;
         7: polynom_rew = 32'b1100000;
         8: polynom_rew = 32'b10111000;
         9: polynom_rew = 32'b100010000;
        10: polynom_rew = 32'b1001000000;
        11: polynom_rew = 32'b10100000000;
        12: polynom_rew = 32'b100000101001;
        13: polynom_rew = 32'b1000000001100;
        14: polynom_rew = 32'b10000000010101;
        15: polynom_rew = 32'b110000000000000;
        16: polynom_rew = 32'b1101000000001000;
        17: polynom_rew = 32'b10010000000000000;
        18: polynom_rew = 32'b100000010000000000;
        19: polynom_rew = 32'b1000000000000100011;
        20: polynom_rew = 32'b10000010000000000000;
        21: polynom_rew = 32'b101000000000000000000;
        22: polynom_rew = 32'b1100000000000000000000;
        23: polynom_rew = 32'b10000100000000000000000;
        24: polynom_rew = 32'b111000010000000000000000;
        25: polynom_rew = 32'b1001000000000000000000000;
        26: polynom_rew = 32'b10000000000000000000100011;
        27: polynom_rew = 32'b100000000000000000000010011;
        28: polynom_rew = 32'b1100100000000000000000000000;
        29: polynom_rew = 32'b10100000000000000000000000000;
        30: polynom_rew = 32'b100000000000000000000000101001;
        31: polynom_rew = 32'b1001000000000000000000000000000;
        32: polynom_rew = 32'b10000000001000000000000000000011;
        default: polynom_rew = 32'b0;
        endcase
        // rotate left
        polynom_rew[length:1] = { polynom_rew[length-2:1],polynom_rew[length] };
        lfsr_fb_rew = qi[length];
        for (i=length-1; i>=1; i=i-1) begin
            if (polynom_rew[i])
                lfsr_fb_rew = lfsr_fb_rew  ~^ qi[i];
        end
    end";
echo PHP_EOL;

    }
    echo "   assign q_next_rew = ";
    if ($inputs['clear']==1)  { echo " clear ? clear_value :";}
    if ($inputs['set']==1)    { echo " set ? set_value :";}
    if ($wrap['wrap']==1)     { echo "(qi == wrap_value) ? {length{1'b0}} :";}
    if ($counter['type']=="LFSR") { echo "{lfsr_fb_rew,qi[length:2]};"; } else { echo "qi - {{length-1{1'b0}},1'b1};"; }
    echo PHP_EOL;
    echo "   assign q_next = rew ? q_next_rew : q_next_fw;" . PHP_EOL;
} 

echo "
   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= {length{1'b0}};
     else" . PHP_EOL;
if ($inputs['cke']) { echo "     if (cke)" . PHP_EOL;}
echo "       qi <= q_next;" . PHP_EOL;
echo PHP_EOL;

if ($outputs['q']) {
    if ($counter['type'] == "GRAY" or $counter['type'] == "gray") {
        echo "   always @ (posedge clk or posedge rst)
     if (rst)
       q <= {length{1'b0}};
     else" . PHP_EOL;
        if ($inputs['cke']) { echo "       if (cke)" . PHP_EOL; }
        echo "         q <= (q_next>>1) ^ q_next;" . PHP_EOL;
        if ($outputs['q_bin']) { echo PHP_EOL . "   assign q_bin = qi;" . PHP_EOL; }
    } else {
        echo "   assign q = qi;" . PHP_EOL;
    }
}
echo PHP_EOL;

if ($outputs['z']) { echo "   assign z = (q == {length{1'b0}});" . PHP_EOL; }

if ($outputs['zq']) {
    echo "
   always @ (posedge clk or posedge rst)
     if (rst)
       zq <= 1'b1;
     else" . PHP_EOL;
    if ($inputs['cke']) { echo "     if (cke)" . PHP_EOL; }
    echo "       zq <= q_next == {length{1'b0}};" . PHP_EOL;
}

if ($outputs['level1']) {
    echo "
    always @ (posedge clk or posedge rst)
    if (rst)
        level1 <= 1'b0;
    else" . PHP_EOL;
    if ($inputs['cke']) { echo "    if (cke)" . PHP_EOL; }
    echo "    if (clear)
        level1 <= 1'b0;
    else if (q_next == level1_value)
        level1 <= 1'b1;
    else if (qi == level1_value & rew)
        level1 <= 1'b0;" . PHP_EOL;
}

if ($outputs['level2']) {
    echo "
    always @ (posedge clk or posedge rst)
    if (rst)
        level2 <= 1'b0;
    else" . PHP_EOL;
    if ($inputs['cke']) { echo "    if (cke)" . PHP_EOL; }
    echo "    if (clear)
        level2 <= 1'b0;
    else if (q_next == level2_value)
        level2 <= 1'b1;
    else if (qi == level2_value & rew)
        level2 <= 1'b0;" . PHP_EOL;
}

echo "endmodule" . PHP_EOL;
