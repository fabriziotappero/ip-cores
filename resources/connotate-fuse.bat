Rem Fuse tests are read from the fuse directory and modified versions
Rem are stored in the same folder, but with the .out extension

connotate-fuse.py ..\cpu\toplevel\fuse\regress.in
connotate-fuse.py ..\cpu\toplevel\fuse\regress.expected
connotate-fuse.py ..\cpu\toplevel\fuse\tests.in
connotate-fuse.py ..\cpu\toplevel\fuse\tests.expected
