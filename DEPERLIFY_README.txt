
FILE
        deperlify.pl

AUTHOR
        David Fick - dfick@umich.edu

VERSION
        1.0 - June 27, 2010

DESCRIPTION
        Deperlify generates *.v files from *.perl.v.
        Deperlify can also generate *.io from *.perl.io

        *.perl.v files have Perl injected inside of them with the following syntax

        PERL begin /*

             <Perl Code>

        */
        end

        Deperlify finds these blocks, executes them, and replaces the block with
        its output. The output of the Perl code (that is, anything printed to 
        STDOUT) is what replaces the block.

        This style works well with emacs syntax highlighting and tabs. However, the
        Perl code is not syntax highlighted since it appears as a comment. It is
        sometimes beneficial to have a scratch Perl file to first the Perl code
        in and then copy from there to the Verilog.

        Deperlify also finds all of the defines from a file and inserts them
        where Perl code is used. $`define_name must be used instead of `define_name,
        however.

        Deperlify can be given multiple files. Variable definitions found in one 
        file roll over to the subsequent files.

        The order of files is important for variable replacement. *.vh files should
        be included before any *.perl.v files that needs those definitions.

        Additional Perl code may be included from other files. This can be
        particularly useful for using the same data structure across multiple files.
        The scan example takes advantage of this, by reusing a scan signal list 
        many times. Adding a signal to a scan chain would normally require adding
        the signal in nearly a dozen places. Using Deperlify, however, allows that
        change to be localized to only one place.

        The syntax to include a Perl file is:        
        DEPERLIFY_INCLUDE(another_perl_file.pl);

        