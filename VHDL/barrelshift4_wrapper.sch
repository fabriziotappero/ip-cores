VERSION 6
BEGIN SCHEMATIC
    BEGIN ATTR DeviceFamilyName "virtex2p"
        DELETE all:0
        EDITNAME all:0
        EDITTRAIT all:0
    END ATTR
    BEGIN NETLIST
        SIGNAL I0
        SIGNAL I1
        SIGNAL I2
        SIGNAL I3
        SIGNAL S0
        SIGNAL S1
        SIGNAL O3
        SIGNAL O2
        SIGNAL O1
        SIGNAL O0
        PORT Input I0
        PORT Input I1
        PORT Input I2
        PORT Input I3
        PORT Input S0
        PORT Input S1
        PORT Output O3
        PORT Output O2
        PORT Output O1
        PORT Output O0
        BEGIN BLOCKDEF brlshft4
            TIMESTAMP 2001 2 2 12 39 57
            LINE N 0 -128 64 -128 
            LINE N 0 -192 64 -192 
            LINE N 0 -320 64 -320 
            LINE N 384 -320 320 -320 
            LINE N 384 -512 320 -512 
            LINE N 0 -448 64 -448 
            LINE N 0 -512 64 -512 
            LINE N 384 -448 320 -448 
            LINE N 0 -384 64 -384 
            LINE N 384 -384 320 -384 
            RECTANGLE N 64 -576 320 -64 
        END BLOCKDEF
        BEGIN BLOCK XLXI_1 brlshft4
            PIN I0 I0
            PIN I1 I1
            PIN I2 I2
            PIN I3 I3
            PIN S0 S0
            PIN S1 S1
            PIN O0 O0
            PIN O1 O1
            PIN O2 O2
            PIN O3 O3
        END BLOCK
    END NETLIST
    BEGIN SHEET 1 3520 2720
        INSTANCE XLXI_1 1488 1520 R0
        BEGIN BRANCH I0
            WIRE 1456 1008 1488 1008
        END BRANCH
        IOMARKER 1456 1008 I0 R180 28
        BEGIN BRANCH I1
            WIRE 1456 1072 1488 1072
        END BRANCH
        IOMARKER 1456 1072 I1 R180 28
        BEGIN BRANCH I2
            WIRE 1456 1136 1488 1136
        END BRANCH
        IOMARKER 1456 1136 I2 R180 28
        BEGIN BRANCH I3
            WIRE 1456 1200 1488 1200
        END BRANCH
        IOMARKER 1456 1200 I3 R180 28
        BEGIN BRANCH S0
            WIRE 1456 1328 1488 1328
        END BRANCH
        IOMARKER 1456 1328 S0 R180 28
        BEGIN BRANCH S1
            WIRE 1456 1392 1488 1392
        END BRANCH
        IOMARKER 1456 1392 S1 R180 28
        BEGIN BRANCH O3
            WIRE 1872 1200 1904 1200
        END BRANCH
        IOMARKER 1904 1200 O3 R0 28
        BEGIN BRANCH O2
            WIRE 1872 1136 1904 1136
        END BRANCH
        IOMARKER 1904 1136 O2 R0 28
        BEGIN BRANCH O1
            WIRE 1872 1072 1904 1072
        END BRANCH
        IOMARKER 1904 1072 O1 R0 28
        BEGIN BRANCH O0
            WIRE 1872 1008 1904 1008
        END BRANCH
        IOMARKER 1904 1008 O0 R0 28
    END SHEET
END SCHEMATIC
