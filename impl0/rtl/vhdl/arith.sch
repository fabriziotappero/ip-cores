VERSION 6
BEGIN SCHEMATIC
    BEGIN ATTR DeviceFamilyName "spartan3"
        DELETE all:0
        EDITNAME all:0
        EDITTRAIT all:0
    END ATTR
    BEGIN NETLIST
        SIGNAL c_out
        SIGNAL ofl_out
        SIGNAL XLXN_14
        SIGNAL XLXN_15
        SIGNAL s0
        SIGNAL XLXN_18
        SIGNAL zero_i
        SIGNAL XLXN_24
        SIGNAL c_in
        SIGNAL XLXN_29
        SIGNAL XLXN_30
        SIGNAL s1
        SIGNAL a(15:0)
        SIGNAL b(15:0)
        SIGNAL XLXN_35
        SIGNAL result(15:0)
        PORT Output c_out
        PORT Output ofl_out
        PORT Input s0
        PORT Input c_in
        PORT Input s1
        PORT Input a(15:0)
        PORT Input b(15:0)
        PORT Output result(15:0)
        BEGIN BLOCKDEF adsu16
            TIMESTAMP 2001 2 2 12 35 41
            LINE N 240 -64 384 -64 
            LINE N 240 -124 240 -64 
            RECTANGLE N 0 -204 64 -180 
            RECTANGLE N 0 -332 64 -308 
            RECTANGLE N 384 -268 448 -244 
            LINE N 128 -448 64 -448 
            LINE N 128 -416 128 -448 
            LINE N 128 -64 48 -64 
            LINE N 128 -96 128 -64 
            LINE N 64 -288 64 -432 
            LINE N 128 -256 64 -288 
            LINE N 64 -224 128 -256 
            LINE N 64 -80 64 -224 
            LINE N 384 -160 64 -80 
            LINE N 384 -336 384 -160 
            LINE N 384 -352 384 -336 
            LINE N 64 -432 384 -352 
            LINE N 336 -128 336 -148 
            LINE N 384 -128 336 -128 
            LINE N 448 -256 384 -256 
            LINE N 448 -128 384 -128 
            LINE N 448 -64 384 -64 
            LINE N 0 -448 64 -448 
            LINE N 0 -192 64 -192 
            LINE N 0 -320 64 -320 
            LINE N 0 -64 64 -64 
        END BLOCKDEF
        BEGIN BLOCKDEF m2_1
            TIMESTAMP 2001 2 2 12 39 29
            LINE N 96 -64 96 -192 
            LINE N 256 -96 96 -64 
            LINE N 256 -160 256 -96 
            LINE N 96 -192 256 -160 
            LINE N 176 -32 96 -32 
            LINE N 176 -80 176 -32 
            LINE N 0 -32 96 -32 
            LINE N 320 -128 256 -128 
            LINE N 0 -96 96 -96 
            LINE N 0 -160 96 -160 
        END BLOCKDEF
        BEGIN BLOCKDEF gnd
            TIMESTAMP 2001 2 2 12 37 29
            LINE N 64 -64 64 -96 
            LINE N 76 -48 52 -48 
            LINE N 68 -32 60 -32 
            LINE N 88 -64 40 -64 
            LINE N 64 -64 64 -80 
            LINE N 64 -128 64 -96 
        END BLOCKDEF
        BEGIN BLOCKDEF inv
            TIMESTAMP 2001 2 2 12 38 38
            LINE N 0 -32 64 -32 
            LINE N 224 -32 160 -32 
            LINE N 64 -64 128 -32 
            LINE N 128 -32 64 0 
            LINE N 64 0 64 -64 
            CIRCLE N 128 -48 160 -16 
        END BLOCKDEF
        BEGIN BLOCK XLXI_1 adsu16
            PIN A(15:0) a(15:0)
            PIN ADD s0
            PIN B(15:0) b(15:0)
            PIN CI XLXN_35
            PIN CO XLXN_14
            PIN OFL ofl_out
            PIN S(15:0) result(15:0)
        END BLOCK
        BEGIN BLOCK XLXI_2 m2_1
            PIN D0 XLXN_15
            PIN D1 XLXN_14
            PIN S0 s0
            PIN O c_out
        END BLOCK
        BEGIN BLOCK XLXI_10 inv
            PIN I XLXN_14
            PIN O XLXN_15
        END BLOCK
        BEGIN BLOCK XLXI_3 m2_1
            PIN D0 XLXN_29
            PIN D1 XLXN_30
            PIN S0 s1
            PIN O XLXN_35
        END BLOCK
        BEGIN BLOCK XLXI_11 m2_1
            PIN D0 XLXN_18
            PIN D1 zero_i
            PIN S0 s0
            PIN O XLXN_29
        END BLOCK
        BEGIN BLOCK XLXI_8 inv
            PIN I zero_i
            PIN O XLXN_18
        END BLOCK
        BEGIN BLOCK XLXI_4 m2_1
            PIN D0 XLXN_24
            PIN D1 c_in
            PIN S0 s0
            PIN O XLXN_30
        END BLOCK
        BEGIN BLOCK XLXI_13 inv
            PIN I c_in
            PIN O XLXN_24
        END BLOCK
        BEGIN BLOCK XLXI_14 gnd
            PIN G zero_i
        END BLOCK
    END NETLIST
    BEGIN SHEET 1 3520 2720
        INSTANCE XLXI_1 1824 1552 R0
        INSTANCE XLXI_2 2576 1648 R0
        BEGIN BRANCH c_out
            WIRE 2896 1520 2960 1520
            WIRE 2960 1520 3024 1520
            BEGIN DISPLAY 2960 1520 ATTR Name
                ALIGNMENT SOFT-BCENTER
            END DISPLAY
        END BRANCH
        BEGIN BRANCH ofl_out
            WIRE 2272 1424 2336 1424
            WIRE 2336 1424 2416 1424
            BEGIN DISPLAY 2336 1424 ATTR Name
                ALIGNMENT SOFT-BCENTER
            END DISPLAY
        END BRANCH
        INSTANCE XLXI_10 2320 1520 R0
        BEGIN BRANCH XLXN_14
            WIRE 2272 1488 2320 1488
            WIRE 2272 1488 2272 1552
            WIRE 2272 1552 2576 1552
        END BRANCH
        BEGIN BRANCH XLXN_15
            WIRE 2544 1488 2576 1488
        END BRANCH
        BEGIN BRANCH s0
            WIRE 544 1616 816 1616
            WIRE 816 1616 1824 1616
            WIRE 1824 1616 2576 1616
            WIRE 816 912 944 912
            WIRE 816 912 816 1232
            WIRE 816 1232 816 1616
            WIRE 816 1232 944 1232
            WIRE 1824 1488 1824 1616
            BEGIN DISPLAY 816 912 ATTR Name
                ALIGNMENT SOFT-BCENTER
            END DISPLAY
        END BRANCH
        INSTANCE XLXI_3 1360 1232 R0
        BEGIN BRANCH XLXN_18
            WIRE 912 784 944 784
        END BRANCH
        INSTANCE XLXI_11 944 944 R0
        INSTANCE XLXI_8 688 816 R0
        BEGIN BRANCH zero_i
            WIRE 592 784 656 784
            WIRE 656 784 656 848
            WIRE 656 848 944 848
            WIRE 656 784 688 784
        END BRANCH
        INSTANCE XLXI_4 944 1264 R0
        INSTANCE XLXI_13 640 1136 R0
        BEGIN BRANCH XLXN_24
            WIRE 864 1104 944 1104
        END BRANCH
        BEGIN BRANCH c_in
            WIRE 464 1104 528 1104
            WIRE 528 1104 640 1104
            WIRE 528 1104 528 1168
            WIRE 528 1168 944 1168
        END BRANCH
        BEGIN BRANCH XLXN_29
            WIRE 1264 816 1312 816
            WIRE 1312 816 1312 1072
            WIRE 1312 1072 1360 1072
        END BRANCH
        BEGIN BRANCH XLXN_30
            WIRE 1264 1136 1360 1136
        END BRANCH
        BEGIN BRANCH s1
            WIRE 1152 1296 1360 1296
            WIRE 1360 1200 1360 1296
        END BRANCH
        BEGIN BRANCH a(15:0)
            WIRE 1648 1232 1824 1232
        END BRANCH
        BEGIN BRANCH b(15:0)
            WIRE 1648 1360 1824 1360
        END BRANCH
        BEGIN BRANCH XLXN_35
            WIRE 1680 1104 1824 1104
        END BRANCH
        BEGIN BRANCH result(15:0)
            WIRE 2272 1296 2448 1296
        END BRANCH
        INSTANCE XLXI_14 528 912 R0
        IOMARKER 3024 1520 c_out R0 28
        IOMARKER 2416 1424 ofl_out R0 28
        IOMARKER 464 1104 c_in R180 28
        IOMARKER 1152 1296 s1 R180 28
        IOMARKER 544 1616 s0 R180 28
        IOMARKER 1648 1232 a(15:0) R180 28
        IOMARKER 1648 1360 b(15:0) R180 28
        IOMARKER 2448 1296 result(15:0) R0 28
    END SHEET
END SCHEMATIC
