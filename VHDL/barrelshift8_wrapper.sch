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
        SIGNAL I4
        SIGNAL I5
        SIGNAL I6
        SIGNAL I7
        SIGNAL O7
        SIGNAL O6
        SIGNAL O5
        SIGNAL O4
        SIGNAL O3
        SIGNAL O2
        SIGNAL O1
        SIGNAL O0
        SIGNAL S2
        SIGNAL S1
        SIGNAL S0
        PORT Input I0
        PORT Input I1
        PORT Input I2
        PORT Input I3
        PORT Input I4
        PORT Input I5
        PORT Input I6
        PORT Input I7
        PORT Output O7
        PORT Output O6
        PORT Output O5
        PORT Output O4
        PORT Output O3
        PORT Output O2
        PORT Output O1
        PORT Output O0
        PORT Input S2
        PORT Input S1
        PORT Input S0
        BEGIN BLOCKDEF brlshft8
            TIMESTAMP 2001 2 2 12 39 57
            LINE N 0 -192 64 -192 
            RECTANGLE N 64 -896 320 -64 
            LINE N 384 -576 320 -576 
            LINE N 0 -576 64 -576 
            LINE N 0 -512 64 -512 
            LINE N 384 -512 320 -512 
            LINE N 384 -448 320 -448 
            LINE N 0 -448 64 -448 
            LINE N 0 -384 64 -384 
            LINE N 384 -384 320 -384 
            LINE N 384 -640 320 -640 
            LINE N 384 -704 320 -704 
            LINE N 384 -768 320 -768 
            LINE N 384 -832 320 -832 
            LINE N 0 -832 64 -832 
            LINE N 0 -768 64 -768 
            LINE N 0 -704 64 -704 
            LINE N 0 -640 64 -640 
            LINE N 0 -128 64 -128 
            LINE N 0 -256 64 -256 
        END BLOCKDEF
        BEGIN BLOCK XLXI_1 brlshft8
            PIN I0 I0
            PIN I1 I1
            PIN I2 I2
            PIN I3 I3
            PIN I4 I4
            PIN I5 I5
            PIN I6 I6
            PIN I7 I7
            PIN S0 S0
            PIN S1 S1
            PIN S2 S2
            PIN O0 O0
            PIN O1 O1
            PIN O2 O2
            PIN O3 O3
            PIN O4 O4
            PIN O5 O5
            PIN O6 O6
            PIN O7 O7
        END BLOCK
    END NETLIST
    BEGIN SHEET 1 3520 2720
        INSTANCE XLXI_1 1584 1744 R0
        BEGIN BRANCH I0
            WIRE 1552 912 1584 912
        END BRANCH
        IOMARKER 1552 912 I0 R180 28
        BEGIN BRANCH I1
            WIRE 1552 976 1584 976
        END BRANCH
        IOMARKER 1552 976 I1 R180 28
        BEGIN BRANCH I2
            WIRE 1552 1040 1584 1040
        END BRANCH
        IOMARKER 1552 1040 I2 R180 28
        BEGIN BRANCH I3
            WIRE 1552 1104 1584 1104
        END BRANCH
        IOMARKER 1552 1104 I3 R180 28
        BEGIN BRANCH I4
            WIRE 1552 1168 1584 1168
        END BRANCH
        IOMARKER 1552 1168 I4 R180 28
        BEGIN BRANCH I5
            WIRE 1552 1232 1584 1232
        END BRANCH
        IOMARKER 1552 1232 I5 R180 28
        BEGIN BRANCH I6
            WIRE 1552 1296 1584 1296
        END BRANCH
        IOMARKER 1552 1296 I6 R180 28
        BEGIN BRANCH I7
            WIRE 1552 1360 1584 1360
        END BRANCH
        IOMARKER 1552 1360 I7 R180 28
        BEGIN BRANCH O7
            WIRE 1968 1360 2000 1360
        END BRANCH
        IOMARKER 2000 1360 O7 R0 28
        BEGIN BRANCH O6
            WIRE 1968 1296 2000 1296
        END BRANCH
        IOMARKER 2000 1296 O6 R0 28
        BEGIN BRANCH O5
            WIRE 1968 1232 2000 1232
        END BRANCH
        IOMARKER 2000 1232 O5 R0 28
        BEGIN BRANCH O4
            WIRE 1968 1168 2000 1168
        END BRANCH
        IOMARKER 2000 1168 O4 R0 28
        BEGIN BRANCH O3
            WIRE 1968 1104 2000 1104
        END BRANCH
        IOMARKER 2000 1104 O3 R0 28
        BEGIN BRANCH O2
            WIRE 1968 1040 2000 1040
        END BRANCH
        IOMARKER 2000 1040 O2 R0 28
        BEGIN BRANCH O1
            WIRE 1968 976 2000 976
        END BRANCH
        IOMARKER 2000 976 O1 R0 28
        BEGIN BRANCH O0
            WIRE 1968 912 2000 912
        END BRANCH
        IOMARKER 2000 912 O0 R0 28
        BEGIN BRANCH S2
            WIRE 1552 1616 1584 1616
        END BRANCH
        IOMARKER 1552 1616 S2 R180 28
        BEGIN BRANCH S1
            WIRE 1552 1552 1584 1552
        END BRANCH
        IOMARKER 1552 1552 S1 R180 28
        BEGIN BRANCH S0
            WIRE 1552 1488 1584 1488
        END BRANCH
        IOMARKER 1552 1488 S0 R180 28
    END SHEET
END SCHEMATIC
