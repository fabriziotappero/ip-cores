-----------
 Synthesis
-----------
The code located in the 'mjpeg' folder can be syntesized with Xilinx EDK 8.2. 
(from the console: "make -f System.make init_bram")

-------------------
 Container formats
-------------------
Common avi containers containing just an mjpeg-video-stream will work. However to play the movie in a repeating loop, the Characters "ENDE ENDE ENDE ENDE ENDE" need to be appended to the end of the file (this is an fast and ugly hack due to lack of time). 

-------
 Tools
-------
There are some scripts inside the 'tools' folder:
'usbdownload' for downloading a bitfile without the gui of impact.
'xmddownload' for automatic downloading of a movie/image to RAM
'encode_mjpeg.sh' for creating compatiple movie-files

----------
 Licence
----------
All code and dokumentation located in the 'pcores/myipif/hdl/vhdl' and 'doc' folder respectively is released under the GPL Version 2 (a copy should be present in the doc-folder), with the following exceptions:
- jpeg_checkff_fifo.vhd
- jpeg_dequant_multiplier.vhd
- jpeg_ht_nr_of_symbols.vhd
- jpeg_ht_tables
- jpeg_huffman_input_sr
- jpeg_idct_core_12
- jpeg_input_fifo
- jpeg_qt_sr
- jpeg_qt_tables
- jpeg_upsampling_buffer
- vga_memory
which are all under Xilinx-License as provided inside the files.
