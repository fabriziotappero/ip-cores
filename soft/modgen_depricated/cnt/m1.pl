#!/usr/bin/perl

sub log2  {
    my ($v) = @_;
    my $r = 0;
    my $c = 1;
    while ($v > $c) {
	$r++;
	$c *= 2;
    }
    return $r;
}

sub log_width  {
    my ($v) = @_;
    my $cover = $width;
    my $r = 0;
    my $c = 1;
    while ( align($v,$cover)/$cover > 1) {
	$cover *= $width;
	$r++;
    }
    $r++;
    return $r;
}

sub log2x  {
    $v = @_;
    my $r = log2($v);
    if ($r == 0) {
	$r = 1;
    }
    return $r;
}

sub border  {
    my($a,$b) = @_;
    return $stgnr{$a} != $stgnr{$b};
}

sub getlevelname  {
    my($stgnr,$postfix) = @_;
    return sprintf("L%.3i_$postfix",$stgnr);
}

sub getstagename  {
    my($stgnr,$postfix) = @_;
    return sprintf("S%.3i_$postfix",$stgnr);
}

sub replc  {
    my($l,$str,$repl) = @_;
    $l =~ s/$str/$repl/gi;
    return $l;
}

sub align {
    my($n,$a) = @_;
    $n = int($n);
    $a = int($a);
    return int(($n+($a-1))/$a) * $a;
}

sub alignright {
    my($n,$a) = @_;
    if ($n < 0) {
	$n = $n - 1;
    }
    return int(($n/$a)) * $a;
}

sub isglobalright {
    #$i is level real index
    my ($i,$level) = @_;
    my $cover = $width ** ($level+1);
    return ($i < $cover);
}

sub islocalright {
    my ($i,$level) = @_;
    my $cover = $width ** ($level+1);
    my $elem = $width ** ($level);
    return (alignright($i,$cover) == alignright($i,$elem));
}

sub goright {
    my ($i,$level) = @_;
    my $cover = $width ** ($level+1);
    my $elem = $width ** ($level);
    $i = alignright($i,$elem);
    $i = $i-$elem;
    return $i;
}

sub localoffset {
    my ($i,$level) = @_;
    my $cover = $width ** ($level+1);
    my $elem = $width ** ($level);
    my $off = alignright($i,$elem)-alignright($i,$cover);
    return int($off/$elem);
}

sub baseindex {
    my ($i,$j,$level) = @_;
    my $cover = $width ** ($level+1);
    my $elem = $width ** ($level);
    return ($i*$cover)+($j*$elem);
}

sub down {
    my ($i) = @_;
    return alignright($i,$width)*$width;
}

sub up {
    my ($i) = @_;
    return alignright($i,$width)/$width;
}

sub upoffset {
    my ($i) = @_;
    my $p = alignright($i,$width)/$width;
    return $i - ($p * $width);
}


sub l0_off {
    my ($i,$off) = @_;
    return ($i * $width) + $off
}

1;

