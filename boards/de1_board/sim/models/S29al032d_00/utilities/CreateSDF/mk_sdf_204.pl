#!/usr/local/bin/perl
#
#   mk_sdf   : Perl replacement for C mk_sdf
#
#   Copyright (C) 2000, 1999 Free Model Foundry; http:/vhdl.org/fmf/
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License version 2 as
#   published by the Free Software Foundation.
#
#   Author  : R. Munden
#   Date    : 20001115
#   Version : 2.0.4
#
#   Revision history:
#   2.0: 19990702
#      o Intial release of perl version
#   2.0.1: 19990722
#      o fixed problem with . in path for TimingModels
#   2.0.2: 20000616
#      o changed instance search to work with Mentor
#   2.0.3: 20001115
#      o changed to parse ":" without leading space
#      o fixed problem with . in path for TimingModels again
#   2.0.4: 20030405
#      o chaged SDF version to 3.0
#
#################################################################
#
# command line arguments:

# ARGV[0] - name of VHDL netlist

# global variables:

# %component_list - list of instance names by component name
# %instance_isin - list architectures by instances contained therein
# %instance_comp - list of component names by instance name
# %comp_lib - library each component (by name) is configured to
# @instance_list - array of all instance names in design in order found

$version = "2.0.4";
$design_name = '';
$timing_dir = '';
$diags = "off";

%keywords = (architecture => 1,
             component => 1,
             timingmodel => 1);

#    INPUT files
$CMD = "mk_sdf.cmd";
$VHD = '';  #  name of VHDL netlist

#    OUTPUT files
$RFV = "/tmp/short.vhd";  # reformatted VHDL
$sdf_file = '';   # name of SDF file

&read_cmd_file;
&get_names;
&reformat;

open INPUT, $RFV;
@lines = <INPUT>;
close INPUT;

$current_architecture = "";

foreach $line (@lines)
{
    @words = split / /, $line;
    foreach $word (@words)
    {
        $keywords{$word} == "1" and do { &$word(@words);};
        if ($component_list{$word})
        {
            $line =~ /(.+) : $word/ and do {
                if ($1 !~ /for/) {          # instantiation found
                $component_list{$word} = $component_list{$word} . $1;
                push (@instance_list, $1);
                $instance_name = $1;
                }
            };
            $instance_comp{$1} = $word;
            $instance_isin{$1} = $current_architecture;
            if ( $diags ne off ) {
                print "reading instance $instance_name: $word in $current_architecture\n";
            }
            $line =~ /for all : $word use entity (.+)/ and do
            {
                @config = split(/\./, $1);
                $comp_lib{$word} = $config[0];};
        }
    }
}
if ( $diags ne off ) {
    print "finished with netlist\n\n";
}

&begin_sdf;
&build_paths;
&close_sdf;
`rm $RFV`;

print "$time\n";

sub architecture
{
    $current_architecture = $_[3];
    push (@architectures, $current_architecture);
}

sub component
{
    if ($_[0] ne "end")
    {
	$name = $_[1];
	$arch_list{$current_architecture} = 
	    $arch_list{$current_architecture} . " " . $name;
    unless ($component_list{$name}) { $component_list{$name} = " ";}
    }
}

sub timingmodel
{
    $line =~ /timingmodel => \"(.+)\"/ and do {
        $model = $1;
        $model_name{$instance_name} = $model;
    };
}

sub begin_sdf
{
    if ( $diags ne off ) {
        print "writing SDF boilerplate\n";
    }
    $time = localtime;
    if (open(SDF, ">$sdf_file") !=1) { die "can't open $sdf_file\n";}
    print "Opening $sdf_file\n";
    print SDF "(DELAYFILE\n";
    print SDF " (SDFVERSION \"3.0\")\n";
    print SDF " (DESIGN \"$design_name\")\n";
    print SDF " (DATE \"$time\")\n";
    print SDF " (VENDOR \"Free Model Foundry\")\n";
    print SDF " (PROGRAM \"SDF timing utility(tm)\")\n";
    print SDF " (VERSION \"$version\")\n";
    print SDF " (DIVIDER /)\n";
    print SDF " (VOLTAGE)\n";
    print SDF " (PROCESS)\n";
    print SDF " (TEMPERATURE)\n";
    print SDF " (TIMESCALE 1ns)\n";
}

sub build_paths
{
    foreach $instance_list (@instance_list)
    {
        @instance = $instance_list;
        foreach $instance (@instance)
        {
            if ( $diags ne off ) {
                print "working on $instance\n";
            }
            if ($gtd =~ /true/i) {
                $path = "$lib_path{$comp_lib{$instance_comp{$instance}}}/$timing_dir";
#                $path = "$lib_path{$comp_lib{$instance_comp{$instance}}}./$timing_dir";
            } else {
                $path = "$lib_path{$comp_lib{$instance_comp{$instance}}}/$timing_dir";
            }
            $timing_file = "$path/$instance_comp{$instance}_vhd.ftm";
            $timing_file =~ s/\s//;
            if ( $diags ne off ) {
                print "$instance should be in $timing_file\n";
            }
            if (-e $timing_file) {
                if ($model_name{$instance} ne "") {
                    print SDF " (CELL\n";
                    print SDF "  (CELLTYPE \"$instance_comp{$instance}\")\n";
                    $inst = $instance;
                    $full_inst = $instance;
                    while ($component_list{$instance_isin{$inst}}) {
                        $full_inst = "$component_list{$instance_isin{$inst}}/$full_inst";
                        $full_inst =~ s/\s+//;
                        $inst = $component_list{$instance_isin{$inst}};
                        $inst =~ s/\s+//;
#                print SDF "  (INSTANCE $component_list{$instance_isin{$instance}}/$instance)\n";
                    }
                    print SDF "  (INSTANCE $full_inst)\n";
                    &add_timing;
                }
            } else {
            if ( $diags ne off ) {
                print "$timing_file not found!\n";
            }
            }
        }
    }
}

sub add_timing
{
    $timing_found = "false";
    $part_found = "false";
#    unless ($lib_path{$comp_lib{$instance_comp{$instance}}})
    unless ($timing_file)
    {
        print "path to $timing_file not found\n";
        exit;
    }
    if ($gtd =~ /true/i) {
        $path = "$lib_path{$comp_lib{$instance_comp{$instance}}}/$timing_dir";
#        $path = "$lib_path{$comp_lib{$instance_comp{$instance}}}./$timing_dir";
    } else {
        $path = "$lib_path{$comp_lib{$instance_comp{$instance}}}/$timing_dir";
    }
    $timing_file = "$path/$instance_comp{$instance}_vhd.ftm";
    if (open(TF, "<$timing_file") !=1) { warn "can't open $timing_file\n"; }
    if ( $diags ne off ) {
        print "reading $timing_file\n";
    }
    $section_found = "false";
    while (<TF>)
    {
        next unless (/$model_name{$instance}/i || ($part_found eq "true"));
        $part_found = "true";
        if ( $diags ne off ) {
            print "found entry for $model_name{$instance}\n";
        }
        next unless (/<timing>/i || ($timing_found eq "true"));
        $timing_found = "true";
        next if (/<timing>/i);
        if (/<\/timing>/i)
        {
            print SDF " )\n";
            $timing_found = "false";
            $part_found = "false";
            $section_found = "true";
            last;
        } else {
            if (/%LABEL%/)
            {
                if ($component_list{$instance_isin{$instance}})
                {
                    $_ =~ s/%LABEL%/$component_list{$instance_isin{$instance}}\/$instance/;
                } else {
                    $_ =~ s/%LABEL%/$instance/;
                }
            }
            print SDF $_;
        }
    }
    unless ($section_found eq "true") {
        print "$model_name not found\n";
    }
}

sub close_sdf
{
    print SDF ")\n";
    print "closing $sdf_file\n";
    close(SDF);
}

# read mk_sdf.cmd

sub read_cmd_file {

    if (open(CMD, $CMD) !=1) { die "can't open $CMD\n"; }
    while (<CMD>) {
        chop;
        @fields = '';
        @fields = split;
        unless ($fields[0] =~ /#/) {
            if ($fields[0] =~ /SET/) {
                if ($fields[1] =~ /vhdl_file/) {$VHD = $fields[2]}
                if ($fields[1] =~ /sdffile_suffix/) {$suffix = $fields[2]}
                if ($fields[1] =~ /use_global_timing_dir/) {$gtd = $fields[2]}
                if ($fields[1] =~ /timingfile_dir/) {$timing_dir = $fields[2]}
                if ($fields[1] =~ /vendor/) {$vendor = $fields[2]}
                if ($fields[1] =~ /diagnostics/) {$diags = $fields[2]}
            }
        }
    }
    if ( $diags ne off ) {
        print "\nmk_sdf diagnostics on\n\n";
        print "vhdl_file $VHD\n";
        print "sdffile_suffix $suffix\n";
        print "use_global_timing_dir $gtd\n";
        print "timingfile_dir $timing_dir\n";
        print "vendor $vendor\n\n";
    }
}
#

# get name of netlist

sub get_names 
{

    if ($ARGV[0] ne "") { $VHD = "$ARGV[0]"; }

    if ($ARGV[1] eq "") 
    {
        @name = split(/\./,$VHD);
        $design_name = $name[0];
        } else {
        $design_name = "$ARGV[1]";
    }
    $sdf_file = $design_name . $suffix;
    if ($gtd =~ /false/i)
    {
        if ($vendor =~ /modeltech/i) { &read_mti; }
        if ($vendor =~ /cadence/i) { &read_cds; }
    }
    if ( $diags ne off ) {
        print "design name is $design_name\n\n";
    }
}
#
################################################################
#

# reformat netlist

sub reformat
{
    $entfound = false;

    if (open(VHD, $VHD) !=1) { die "can't open $VHD\n"; }
    if (open(OUT, ">$RFV") !=1) { die "can't open $OUT\n"; }

    while (<VHD>) {
        if (/^--|library|package/i) { next }
        if (/--/) {              # strip embeded comments
            @line = split("--");
            $_ = $line[0];
        }
        s/:/ : /g;
        s/;/ ;/g;
        s/\s+/ /g;      # reduces spaces and tabs
        s/^\s//g;        # no leading spaces
        if (/entity/i) {
            $entfound = "true";
        }
        chomp;
        if ( $entfound eq true ) {
            print OUT lc($_);
            if (/;|is|begin/i) { print OUT "\n"; }
        }
    }

    close OUT;
    if ( $diags ne off ) {
        print "reformatted netlist written to $RFV\n\n";
    }

}

# read ModelTech's modelsim.ini file

sub read_mti
{
    $lib_found = "false";
    if ($ENV{MODELPATH})
    {
        $ini_file = "$ENV{MODELPATH}/../modelsim.ini";
        if (open(INI, "$ini_file") !=1) { die "can't open $ini_file\n";}
        if ( $diags ne off ) {
            print "reading $ini_file\n\n";
        }
        while (<INI>)
        {
           if ($lib_found eq "true")
           {
               chomp;
               if (/\[.+\]/) { last; }
               s/\s+//;
               @lib_line = split(/=/);
               $lib_line[1] =~ s/\/work//;
               $lib_path{$lib_line[0]} = $lib_line[1];
           } elsif (/\[Library\]/i)
           {
               $lib_found = "true";
               next;
           }
        }
    } else {
        print "\$MODELPATH environment variable not found\n";
    }
    $lib_found = "false";
    if (-e "modelsim.ini")
    {
        $ini_file = "modelsim.ini";
        if (open(INI, "$ini_file") !=1) { die "can't open $ini_file\n";}
        if ( $diags ne off ) {
            print "reading $ini_file\n\n";
        }
        while (<INI>)
        {
           if ($lib_found eq "true")
           {
               chomp;
               if (/\[.+\]/) { last; }
               s/\s+//;
               @lib_line = split(/=/);
               $lib_line[1] =~ s/\/work//;
               $lib_path{$lib_line[0]} = $lib_line[1];
           } elsif (/\[Library\]/i)
           {
               $lib_found = "true";
               next;
           }
        }
    } else {
        print "local modelsim.ini file not found, may not be needed\n";
    }
}

# read Cadence's cds.lib file

sub read_cds
{
    if ($ENV{CDS_VHDL})
    {
        $ini_file = "$ENV{CDS_VHDL}/files/cds.lib";
        if (open(INI, "$ini_file") !=1) { die "can't open $ini_file\n";}
        if ( $diags ne off ) {
            print "reading $ini_file\n\n";
        }
        while (<INI>)
        {
           chomp;
           s/\s+/ /;
           if (/define/i)
           {
               @lib_line = split;
               $lib_path{$lib_line[1]} = $lib_line[2];
           }
        }
    } else {
        print "\$CDS_VHDL environment variable not found\n";
    }
    if (-e "cds.lib")
    {
        $ini_file = "cds.lib";
        if (open(INI, "$ini_file") !=1) { die "can't open $ini_file\n";}
        if ( $diags ne off ) {
            print "reading $ini_file\n\n";
        }
        while (<INI>)
        {
           chomp;
           s/\s+/ /;
           if (/define/i)
           {
               @lib_line = split;
               $lib_path{$lib_line[1]} = $lib_line[2];
           }
        }
    } else {
        print "local cds.lib file not found, may not be needed\n";
    }
}
