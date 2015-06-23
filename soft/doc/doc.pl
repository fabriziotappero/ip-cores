#!/usr/bin/perl 
# Purpose: Generate annotated .html files out of list of .vhdl files
# call:
# $ doc.pl <filelist-filename>

#$dbgon = 1;

$sp = "[\\s]*";
$id = "[a-zA-Z][a-zA-Z0-9_]*";
$spid = "[a-zA-Z0-9_]*";

print("Require doc1.pl\n");
require "doc1.pl";
print("Require doc2.pl\n");
require "doc2.pl";
print("Require doc3.pl\n");
require "doc3.pl";
print("Require doc4.pl\n");
require "doc4.pl";
print("Require doc5.pl\n");
require "doc5.pl";
print("Require doc6.pl\n");
require "doc6.pl";

if ($d3_maintemplate eq "") {
    die ("The [main] entry for the main template is missing in the config file\n");
}

$body_all = "";
print("Read all files\n");
$body_all = d3_readallfiles();
print("Createusage\n");
d3_createusage($body_all);

d2_dumpmasks();
d3_dumpfilelist();

print("Scanning for records\n");
d2_scanrecords($body_all);
print("Scanning for functions\n");
d2_scanfuncs($body_all);
print("Scanning for procedures\n");
d2_scanprocedures($body_all);
print("Scanning for constants\n");
d2_scanconsts($body_all);
print("Scanning for enums\n");
d2_scanenums($body_all);
print("Scanning for entities\n");
d2_scanentities($body_all);
print("Scanning for architectures\n");
d2_scanarchs($body_all);

d2_dumpscan();


if (!($d3_header eq "" || $d3_fileselect eq "")) {
    
    $header = d6_createheader($filename,$d3_header);
    $header = d3_template_pathreplace($header,$d3_fileselect);
    
    if (-e $d3_fileselect) {
	`cp $d3_fileselect $d3_fileselect.back`;
    }

    open $F,">$d3_fileselect" or die ("Unable to open output $d3_fileselect\n");
    print $F $header; 
    close $F;
    print("Save fileselect $d3_fileselect\n");
}

if (!($d3_frame eq "" || $d3_framebase eq "")) {

    $d3_header = d3_relpath($d3_framebase,$d3_fileselect);
    $d3_frame =~ s/%fileselect%/$d3_header/gi;

    if (-e $d3_framebase) {
	`cp $d3_framebase $d3_framebase.back`;
    }
    open $F,">$d3_framebase" or die ("Unable to open output $d3_framebase\n");
    print $F $d3_frame; 
    close $F;
    print("Save index $d3_framebase\n");
}

print("Assembling output\n");

@ar = @d3_files;
$body = "";
$off = 0;
$filename;
foreach(@ar) {
    $filename = $_;
    
    print ("Processing file $_\n");
    
    $body = d3_readfile($filename,1);
    d1_process($body,$off);
    $html = d5_gethtml($off,$off + length($body),"");
    
    $header = "";
    
    $html = d5_assemblehtml($filename,$html,$d5_dumphtml_types,$d3_maintemplate,$header);
    $html =~ s/(--[^\n]*\n)/<span class="comment">\1<\/span>/g;
    $html = d3_template_replace($html);
    
    if (not ($filename =~ /\.htlm$/)) {
	$filename =~ s/\.[a-zA-Z]*?$/\.html/i;
	
	$html = d3_template_pathreplace($html,$filename);

	if (-e $filename) {
	    `cp $filename $filename.back`;
	}
	open $F,">$filename" or die ("Unable to open output $filename\n");
	print $F $html; 
	close $F;
	print("Save $filename\n");
    }
    $d5_dumphtml_types = "";
    %d5_dumphtml_types_alloc = ();
    $off += length($body);
}

#d5_dumpcut();


