sub d6_createheader
{
    my ($filename,$headerfile) = @_;
    my @ar = @d3_files;
    my $html = "";
    my $body = d3_readfile($headerfile,0);
    my ($fl_title,$fl_html);
    my @cur = ();
    my @next = ();
    my $id = 1;
    
    $fl_html = "<pre>";
    foreach(sort (@ar)) {
	s/[\s\n\r]//g;
	if (not($_ eq "")) {
	    my @c = @cur;
	    my $p = "";
	    my $pdir = "<base>";
	    my $fnn_fry = d3_gethtmlname($_);
	    @next = split("[\\/]",$fnn_fry);
	    my $fnn = $next[$#next];
	    @next = split("[\\/]",$fnn_fry);
	    splice(@next,$#next,1);
	    @cur = @next;
	    while ($#next != -1 && $#c != -1) {
		if ($next[0] eq $c[0]) { 
		    $p .= "|";
		    splice(@next,0,1);
		    splice(@c,0,1);
		    $pdir .= "/".$next[0];
		} else { last; }
	    } 
	    while ($#c>=0) {
		$fl_html .= "</div>";	
		splice(@c,0,1);
	    }
	    while ($#next>=0) {
		#visibility:hidden; 
		$fl_html .= "<a href=\"javascript:toggle('$id')\"><img name=\"I$id\" src=\"%img_docopen%\" alt=\"close\"></a><b>$next[0]</b><br><div  id=\"T$id\" style=\"margin-left:18px;visibility:hidden;position:absolute;BACKGROUND-COLOR:white;\">";
		splice(@next,0,1);
		$id++;
	    }
	    
	    $d3_pathreplace{"%$d3_pathreplaceid%"} = $fnn_fry;
	    $fl_html .= "<a href=\"%$d3_pathreplaceid%\" target=\"contents\">$fnn</a><br>";
	    

	    $d3_pathreplaceid++;
	}
    }
    while ($#cur>=0) {
	$fl_html .= "</div>";	
	splice(@cur,0,1);
    }

    $fl_html .= "</pre>";



#    $fl_title = "&nbsp;&nbsp;&nbsp;Filelist:<br> ";
#    $fl_title = $d5_divstart."$fl_title<br>";
#    $fl_title =~ s/%id%/$d2_id/g;
#    $fl_html = $fl_title.$fl_html.$d5_divend;
    
    $d2_id++;
    
    $body = d3_template_replace($body);

    $body =~ s/%filelist%/$html/;

    $html = $body.$fl_html;
    return $html;
}

sub d6_createusage
{
    my ($compbody) = @_;
    my @ar = @d3_files;
    my ($usagereg,$pos,$fn,$cfn,$pfn,$body);
    my $reg = "($id)\\.vhd\$";
    my (@usage,$htmlname,$vhdlname);
    %d3_usedby_set = ();
    foreach(@ar) {
	$pfn = $_;
	if (/$reg/) {
	    $cfn = $1;
	    
	    $usagereg = "use".$sp."work".$sp."\\.".$sp."$cfn".$sp."\\.".$sp."all".$sp.";";
	    if ($dbgon == 1) {
		print ("Creating usage for $cfn: $usagereg\n");
	    }
	    $pos = 0;
	    $body = $compbody;
	    @usage = ();
	    while (length($body) != 0) {
		($body,@match) = d2_scannext($body,$usagereg);
		if ($#match != -1) {
		    $fn = d3_filename($pos + $match[6]);
		    if ($dbgon == 1) {
			print ("Found using file:$fn\n"); 
		    }
		    push (@usage,$fn);
		    $pos = $pos + $match[6] + $match[0];
		}
	    }
	    $html = "";
	    foreach(@usage) {
		$vhdlname = $_;
		$htmlname = d3_gethtmlname($vhdlname);
		$html .= "used by <a href=\"$htmlname\">$_</a>\n<br>";
	    }
	    
	    $vhdlname = $pfn;
	    $htmlname = d3_gethtmlname($vhdlname);
		
	    $d3_pathreplace{"%$d3_pathreplaceid%"} = $htmlname;

	    $title = "&nbsp;&nbsp;&nbsp;File <b><a href=\"%$d3_pathreplaceid%\">$vhdlname</a></b> ";
	    $title = $d5_divstart."$title<br>";
	    $title =~ s/%id%/$d2_id/g;

	    $d3_pathreplaceid++;
	    
	    $html = $title.$html.$d5_divend;
	    
	    %tmp = ( id   => $d2_id++,
		     html => $html
		     );
	    $d3_usedby_set{$cfn} = [%tmp];
	}
    }
}


1;
