This directory contains pinout files and constraint files to be used with the
GR-CPCI-AX board and associated accessory and mezzanine boards.

The GR-CPCI-AX board is designed for the CCGA 624 package, but also
supports the FBGA 896 package by means of an adapter. Pinouts are provided
for both devices.

In addition, pinout is provided for the CQFP 353 package.

The package choice can be done in the board specific make file Makefile.inc,
or locally in the design. Examples are provided the Makefile.inc and in
the Makefile of the reference designs.

Note that the pinout constraint files (*.pdc) might require some lines to
be commented out (#) if a pin is not used in a new design.


GR-CPCI-AX board with GR-AX-SPW accessory or GR-RTAX-MEZZ mezzanine board
-------------------------------------------------------------------------

The GR-AX-SPW accessory features 4x SpaceWire and 2x UART.

The GR-RTAX-MEZZ mezzanine board 3x SpaceWire, 1x CAN and 1x 1553 (redundant).

A common pinout constraint file is used for all three board combinations.

The timing constraint file might need modification, depending on the design.

Pinout and timing constraint files for CCGA 624 package:

  designer_624_CCGA.pdc
  designer_624_CCGA.sdc

Pinout and timing constraint files for FBGA 896 package:

  designer_896_FBGA.pdc
  designer_896_FBGA.sdc

Pinout and timing constraint files for CQFP 352 package:

  designer_352_CQFP.pdc
  designer_352_CQFP.sdc


GR-CPCI-AX board with GR-CPCI-1553 mezzanine board
--------------------------------------------------

The GR-CPCI-1553 mezzanine board features 1x CAN and 1x 1553 (redundant).

This board pinout is not compatible with LEON3-RTAX architecture.

Pinout constraint file for FBGA 896 package:

  designer_896_FBGA_1553.pdc
