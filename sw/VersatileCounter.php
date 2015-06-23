#!/usr/bin/php
<?php

include (dirname(__FILE__) . '/VersatileCounter.class.php');

if(isset($argv[1]) and !isset(VersatileCounter::$masks[$argv[1]])) {
    echo "Error: Bitmask not found" . PHP_EOL;
    die(1);
}

$c = new VersatileCounter(isset($argv[1])?$argv[1]:8);
$c->run(isset($argv[2])?$argv[2]:2,isset($argv[3]));

if(!isset($argv[3])) {
    echo $c->state() . PHP_EOL;
}
