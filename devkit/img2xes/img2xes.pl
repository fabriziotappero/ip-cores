#
# img2xes - Convert various types of image files into an XES-formatted hexadecimal data file
#
# The man page for this program is stored at the end of this file in POD format.
# Use 'pod2text img2xes.pl' in order to generate the man page.
#



use Math::Complex;
use Getopt::Long;

#
# create pointers to the netpbm image translation programs
#
# $netpbm_bin_dir = "C:/progra~1/gnuwin32/bin/"; # set this to the location of the netpbm utilities if it's not in your path already
$bmptopnm = $netpbm_bin_dir . "bmptopnm.exe";
$pngtopnm = $netpbm_bin_dir . "pngtopnm.exe";
$giftopnm = $netpbm_bin_dir . "giftopnm.exe";
$tifftopnm = $netpbm_bin_dir . "tifftopnm.exe";
$jpegtopnm = $netpbm_bin_dir . "jpegtopnm.exe";

#
# get options for the program
#
GetOptions(
    "help"         => \$help,
    "width=i"      => \$screen_width,       # width of screen in pixels
    "x=i"          => \$screen_width,       # also width of screen
    "height=i"     => \$screen_height,      # height of screen in scanlines
    "y=i"          => \$screen_height,      # also height of screen
    "depth=s"      => \$screen_depth,       # #bits of each RGB component
    "pixelwidth=i" => \$pixel_width,        # #bits per pixel
    "memwidth=i"   => \$mem_width,          # #bits per word of memory
    "address=s"    => \$mem_start_address,  # starting address of image in memory
    "ifile=s"      => \$in_file,            # input image file
    "ofile=s"      => \$xes_file            # output hex file in XES format
);

# convert the hex or octal starting address to a decimal integer
$mem_start_address = oct($mem_start_address);

print "Unknown options:\n" if $ARGV[0];
foreach (@ARGV) {
    print "$_\n";
}

if ( $ARGV[0] || $help ) {
    print "perl $0 [-help] [(-width|-x) <#pixels>] [(-height|-y) <#lines>] [-depth <#R>+<#G>+<#B>] [-pixelwidth <#bits>] [-memwidth <#bits>] [-address <hex_or_oct_address>] [-ifile <file.pnm>] [-ofile <file.xes>]\n";
    die;
}

#
# set default parameter values if not already set by the program options
#
!$screen_width      && ( $screen_width      = 800 );
!$screen_height     && ( $screen_height     = 600 );
!$screen_depth      && ( $screen_depth      = "3+2+3" );
!$pixel_width       && ( $pixel_width       = 8 );
!$mem_width         && ( $mem_width         = 16 );
!$mem_start_address && ( $mem_start_address = 0 );

$pixel_width > $mem_width && die "Error: pixel width cannot exceed the memory width!\n";
($num_r_bits,$num_g_bits,$num_b_bits) = split(/\+/,$screen_depth);
$color_depth = $num_r_bits + $num_g_bits + $num_b_bits;
$pixel_width < $color_depth && die "Error: pixel width is too small to hold the RGB values!\n";

#
# open the file containing the image data or run the external program to convert the
# image file into a portable pixel map file (PGM, PPM or PNM)
#
if ( defined $in_file ) {
    if($in_file =~ /\.(\w+)$/) {
        $_ = $1;
        /^bmp/i && (open(IN,"$bmptopnm $in_file |") || die "$!\n");
        /^png/i && (open(IN,"$pngtopnm $in_file |") || die "$!\n");
        /^gif/i && (open(IN,"$giftopnm $in_file |") || die "$!\n");
        /^tif/i && (open(IN,"$tifftopnm $in_file |") || die "$!\n");
        /^jpeg/i && (open(IN,"$jpegtopnm $in_file |") || die "$!\n");
        /^jpg/i && (open(IN,"$jpegtopnm $in_file |") || die "$!\n");
        /^pnm/i && (open( IN, "$in_file" ) || die "$!\n");
        /^ppm/i && (open( IN, "$in_file" ) || die "$!\n");
        /^pgm/i && (open( IN, "$in_file" ) || die "$!\n");
    }
}
else {
    open( IN, "-" ) || die "$!\n";    # open the standard input if there is no file specified
}
binmode(IN);

#
# open the file where the hexadecimal data will be stored
#
if ( defined $xes_file ) {
    open( OUT, ">$xes_file" ) || die "$!\n";
}
else {
    open( OUT, ">-" ) || die "$!\n";    # open the standard output if there is no file specified
}

#
# read the header that gives the image type, dimensions and grayscale/color range
#
while (<IN>) {
    /^\s*#/ && next;    # skip comment lines
    $_ =~ s/\s*#.*$//;  # strip comments from the ends of lines
    chomp;              # remove newlines from ends of lines
    $header .= "$_ ";   # append current field to the header information
    @header = split( /\s+/, $header );
    ( $header[0] =~ /^P[2356]$/ ) && ( @header == 4 ) && last;    # got all the header information for PGM and PPM files
    ( $header[0] =~ /^P[14]$/ )   && ( @header == 3 ) && last;    # got all the header information for PBM files
    ( $header[0] !~ /^P[123456]$/ ) && die "unknown type of PNM file!!\n";
    ( @header < 4 )                 && next;                                 # keep going until we have all the info from the header
}

#
# get the dimensions of the image and the range of each pixel value
#
$image_width  = $header[1];
$image_height = $header[2];
( $header[0] =~ /^P[2356]$/ ) && ( $num_img_pixel_bits = int( logn( $header[3] + 1, 2 ) ) );

#
# determine some characteristics of the image data
#
$is_bitmap = ( $header[0] =~ /P[14]/ );                                      # is it a bitmap, graymap or pixelmap?
$is_text   = ( $header[0] =~ /P[123]/ );                                     # is the data stored as ASCII text or binary values?
$is_color  = ( $header[0] =~ /P[36]/ );                                      # is the data RGB or grayscale/BW?

#
# process pixelmap and graymap image data
#
if ( !$is_bitmap ) {
    $address = $mem_start_address;                                           # initialize address pointer

    # create hexadecimal data records of pixel data for each line of the screen
    for ( $r = 0 ; $r < $screen_height ; $r++ ) {

        # clear the RGB values for the pixels in this row of the image
        @row_r = ();
        @row_g = ();
        @row_b = ();

        #
        # Read the current line of pixel data from the image file until all the lines are processed.
        # Once all image lines are processed, the RGB arrays for any further screen lines will be left with
        # all zeroes (blank pixels).  If there are more image lines than screen lines, then the excess
        # image lines will be ignored.
        #

        for ( $c = 0 ; $r < $image_height && $c < $image_width ; $c++ ) {
            if ($is_color) {

                # read RGB values for the current pixel
                if ($is_text) {

                    # RGB values are stored as decimal number text strings
                    # if the data array is empty, then refill it with data from lines of the image data file
                    while(@data == 0){
                      $t = <IN>; # get a line from the file
                      $t =~ s/^\s+//; # strip off leading whitespace
                      $t =~ s/\s+$//; # strip off trailing whitespace
                      @data = split(/\s+/,$t); # split the rest into individual numbers and store them in the array
                    }
                    $row_r[$c] = shift @data; # extract next number from array and store it in the current pixel's red component

                    # now get the value of the green component
                    while(@data == 0){
                      $t = <IN>;
                      $t =~ s/^\s+//;
                      $t =~ s/\s+$//;
                      @data = split(/\s+/,$t);
                    }
                    $row_g[$c] = shift @data;

                    # finally, get the value of the blue component
                    while(@data == 0){
                      $t = <IN>;
                      $t =~ s/^\s+//;
                      $t =~ s/\s+$//;
                      @data = split(/\s+/,$t);
                    }
                    $row_b[$c] = shift @data;
                }
                else {

                    # RGB values are stored as bytes of binary data
                    read( IN, $t, 1 );
                    $row_r[$c] = ord($t); # store the value of the red component for this pixel
                    read( IN, $t, 1 );
                    $row_g[$c] = ord($t); # store the value of the green component
                    read( IN, $t, 1 );
                    $row_b[$c] = ord($t); # store the value of the blue component
                }
            }
            else {

                # read gray value for the current pixel
                if ($is_text) {

                    # gray value is stored as a decimal number text string
                    # if the data array is empty, then refill it with data from lines of the image data file
                    while(@data == 0){
                      $t = <IN>; # get a line from the file
                      $t =~ s/^\s+//; # strip off leading whitespace
                      $t =~ s/\s+$//; # strip off trailing whitespace
                      @data = split(/\s+/,$t); # split the rest into individual numbers and store them in the array
                    }
                    $row_r[$c] = shift @data; # extract next number from array and store it in the current pixel's red component
                }
                else {

                    # gray value is stored as a byte of binary data
                    read( IN, $t, 1 );
                    $row_r[$c] = ord($t); # store the value of the red component for this pixel
                }

                # gray value is created by making the green and blue components identical to the red component
                $row_g[$c] = $row_r[$c];
                $row_b[$c] = $row_r[$c];
            }

            # scale the RGB components of each image pixel so they fit the color depth of the screen
            $row_r[$c] = ( $row_r[$c] >> ( $num_img_pixel_bits - $num_r_bits ) ) & ( ( 1 << $num_r_bits ) - 1 );
            $row_g[$c] = ( $row_g[$c] >> ( $num_img_pixel_bits - $num_g_bits ) ) & ( ( 1 << $num_g_bits ) - 1 );
            $row_b[$c] = ( $row_b[$c] >> ( $num_img_pixel_bits - $num_b_bits ) ) & ( ( 1 << $num_b_bits ) - 1 );
        }

        #
        # Now create the hex records in XES hex format for the current row of pixel RGB data.
        # Read the pixel RGB values from the current line of image data until all the pixels are processed.
        # Once all image pixels are processed, the RGB values for any further screen pixels will be read as
        # all zeroes (blank pixels).  But if there are more image pixels than screen pixels, then the excess
        # image pixelss will be ignored.
        #

        $hex_record = ""; # start with an empty hex record
        $nbytes = 0; # number of bytes of data in the hex record
        $mem_word = 0; # current word to be stored in memory (composed of packed pixels)
        $npixels = 0; # number of pixels packed into a word of memory
        for ( $c = 0 ; $c < $screen_width ; $c++ ) {

            # pack the RGB components for the current pixel into a single pixel value with red, green, blue
            # data arranged from the most to least significant bit
            $pixel_value = ( $row_r[$c] << ($num_g_bits+$num_b_bits) ) | ( $row_g[$c] << $num_b_bits ) | $row_b[$c];

            # pack the pixel value into the memory word
            $mem_word = $mem_word | ( $pixel_value << ( $pixel_width * $npixels ) );
            $npixels++;    # increment the number of pixels currently stored in the memory word

            # if the memory word is full, then append it to the hex record
            if ( $pixel_width * $npixels >= $mem_width ) {

                # divide the memory word into bytes, starting with the least-significant, and append them
                # into a string that proceeds from the most-to-least significant
                for ( $hex = "", $w = 0 ; $w < $mem_width ; $w += 8 ) {
                    $hex = sprintf( " %02X%s", $mem_word & 0xFF, $hex );    # put the current byte at the head of the string
                    $mem_word = $mem_word >> 8;                             # shift the current byte off the end of the memory word
                    $nbytes++;                                              # increment the number of bytes stored in the hex record
                }
                $hex_record .= $hex;                                        # append the hex data for the current memory word to the hex record
                $npixels = 0;                                               # all pixels were removed from the memory word
                $mem_word = 0;

                # create a complete hex record if enough bytes have been appended
                if ( $nbytes >= 16 || (($address+$nbytes) & 0xF)==0 ) {
                    printf OUT "+ %02X %08X%s\n", $nbytes, $address, $hex_record; # prepend record length and address
                    $address += $nbytes;                                        # compute the address for the next hex record
                    $hex_record = "";                                           # clear the string for the next hex record
                    $nbytes     = 0;                                            # no bytes in the new hex record
                }
            }
        }

        # take care of any partial memory words that were in-process at the end of the line
        if ( $npixels > 0 ) {

            # divide the memory word into bytes, starting with the least-significant, and append them
            # into a string that proceeds from the most-to-least significant
            for ( $hex = "", $w = 0 ; $w < $mem_width ; $w += 8 ) {
                $hex = sprintf( " %02X%s", $mem_word & 0xFF, $hex );
                $mem_word = $mem_word >> 8;                         
                $nbytes++;                     
            }
            $hex_record .= $hex;               
            $npixels = 0;                      
        }

        # take care of any partial hex records that were in process at the end of a line
        if ( $nbytes > 0 ) {
            printf OUT "+ %02X %08X%s\n", $nbytes, $address, $hex_record;
            $address += $nbytes;                                         
            $hex_record = "";                                            
            $nbytes     = 0;                                             
        }
    }
}




=pod


=head1 NAME

img2xes - Convert various types of image files into an XES-formatted hexadecimal data file


=head1 SYNOPSIS

perl img2xes.pl [B<-width>=I<integer>]  [B<-x>=I<integer>]
[B<-height>=I<integer>]  [B<-y>=I<integer>]
[B<-depth>=I<string>] [B<-pixelwidth>=I<number>] [B<-memwidth>=I<number>]
[B<-address>=I<integer>] [B<-ifile>=I<filename>] [B<-ofile>=I<filename>]

perl img2xes.pl B<-help>


=head1 DESCRIPTION

B<img2xes> converts image files into hexadecimal data files in the XES format.
These hex files can be downloaded into the memory on an XS Board and displayed
on a VGA monitor.


=head1 OPTIONS

=over 4

=item B<-width> I<integer>

Sets width of the image (in pixels) that will be displayed on the VGA monitor.  This is not necessarily
the same as the width of the image in the image file.  The default value is 800.

=item B<-x> I<integer>

Same as the B<-width> option.

=item B<-height> I<integer>

Sets height of the image (in scanlines) that will be displayed on the VGA monitor.  This is not necessarily
the same as the height of the image in the image file.  The default value is 600.

=item B<-y> I<integer>

Same as the B<-height> option.

=item B<-depth> I<string>

Sets the depth of the image that will be displayed on the VGA monitor.  This is not necessarily
the same as the depth of the image in the image file.  The depth is expressed as a string with the
format I<R+G+B> where R, G and B are the number of bits of resolution of the red, green and blue
components of the colors displayed on the monitor.  The default value is 3+2+3.

=item B<-pixelwidth> I<integer>

Sets the width (in bits) of a pixel.  A pixel should be at least R+G+B bits wide.  The default value is 8.

=item B<-memwidth> I<integer>

Sets the width (in bits) of the memory word that contains one or more pixels.  The memory width should be
at least as wide as the pixels.  The default value is 16.

=item B<-address> I<hex or octal address>

Sets the starting address in memory for the hexadecimal image data.  The image data proceeds upward from there.
The address is interpreted as an octal number unless you precede it with an initial "0x" to indicate
it is a hexadecimal address.  The default value is 0.

=item B<-ifile> I<filename>

Gives the name of the file containing the image data.  The suffix of I<filename> is used to determine the
type of the image data as follows:

=over

=item B<.bmp> Windows bitmap file.

=item B<.png> PNG file.

=item B<.gif> GIF file.

=item B<.tif> TIF file.

=item B<.jpeg>, B<.jpg> JPEG file.

=item B<.pgm> Portable gray-map file.
 
=item B<.ppm> Portable pixel-map file.
 
=item B<.pnm> Portable any-map file. 

=back

If B<-ifile> is not used, then the image data is read from the standard input and is assumed to be in 
portable any-map format.

=item B<-ofile> I<filename>

Gives the name of the file where the XES-formatted hexadecimal data will be stored.  If B<-ofile> is not used,
then the hexadecimal data is written to the standard output.

=back


=head1 DIAGNOSTICS

B<img2xes> will abort if it does not recognize the suffix of the input image file or if the following
contraint is not met:

=over

R+G+B <= pixel width <= memory width

=back


=head1 EXAMPLES

For the XSA Boards using the VGA generator circuit described in 
http://www.xess.com/appnotes/an-101204-vgagen.pdf, here are the commands to convert a JPEG file
and produce an S<800 x 600> display with
pixel widths of 4, 8 and 16.  (We will not explicitly set some options since the default settings
will work in this case)

=over

perl img2xes.pl -depth 1+1+1 -pixelwidth 4 -ifile image.jpg -ofile image.xes

perl img2xes.pl -depth 3+2+3 -pixelwidth 8 -ifile image.jpg -ofile image.xes

perl img2xes.pl -depth 3+3+3 -pixelwidth 16 -ifile image.jpg -ofile image.xes

=back

To display a PNG file on a S<1024 x 768> display, then do this:

=over

perl img2xes.pl -x 1024 -y 768 -depth 1+1+1 -pixelwidth 4 -ifile image.png -ofile image.xes

perl img2xes.pl -x 1024 -y 768 -depth 3+2+3 -pixelwidth 8 -ifile image.png -ofile image.xes

perl img2xes.pl -x 1024 -y 768 -depth 3+3+3 -pixelwidth 16 -ifile image.png -ofile image.xes

=back


=head1 ENVIRONMENT

B<img2xes> requires a perl interpreter for its execution.  You can get a free perl interpreter
for Windows at www.activestate.com.  You already have a perl interpreter if you are running
linux, solaris or unix.

B<img2xes> requires the I<netpbm> suite of image conversion programs in order to convert
the various image file formats.
You can get these from http://netpbm.sourceforge.net.
Once installed, you need to place the I<netpbm> directory in your path or store
it directly in the C<$netpbm_bin_dir> variable in F<img2xes.pl>. 


=head1 FILES

None.


=head1 CAVEATS

None.


=head1 BUGS

Portable bitmap files (.pbm) are not handled, yet.


=head1 RESTRICTIONS

None.


=head1 NOTES

B<img2xes> takes the red, green and blue component values of each pixel in the image file and
does the following:

=over

=item 1.

Each color component is truncated to the number of bits specified for that component by the B<-depth> option.

=item 2.

The truncated color components are concatenated with the blue component in the least-significant bit positions,
the red component in the most-significant bit positions, and the green component in between.

=item 3.

The concatenated components are placed into the least-significant bit positions of a pixel field whose
width is set using the B<-pixelwidth> option.  Any unused bits in the upper portion of the pixel field
are set to zero.

=item 4.

Pixel fields are concatenated until no more will fit into a memory word whose width is set using the
B<-memwidth> option.  Pixel I<N> occupies the least-significant bit positions while
pixels I<N+1>, I<N+2>, ... occupy successively more-significant bit positions in the memory word.

=item 5.

The memory word is chopped into eight-bit bytes and output as two-digit hexadecimal values starting
with the most-significant byte and proceeding to the least-significant byte.

=back


=head1 SEE ALSO

The most-current version of B<img2xes.pl> can be found at http://wwww.xess.com/ho07000.html.


=head1 AUTHOR

Dave Vanden Bout, X Engineering Software Systems Corp.

Send bug reports to bugs@xess.com.


=head1 COPYRIGHT AND LICENSE

Copyright 2004 by X Engineering Software Systems Corporation.

This library is free software; you may redistribute it and/or modify
it under the same terms as Perl itself.


=head1 HISTORY

10/12/04 - Version 1.0


=cut

