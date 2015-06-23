<?php

class VersatileCounter {
    
    static $masks = array(
        
         2 => 0x3,
         3 => 0x6,
         4 => 0xC,
         5 => 0x14,
         6 => 0x30,
         7 => 0x60,
         8 => 0xB8,
         9 => 0x110,
        10 => 0x240,
        11 => 0x500,
        12 => 0x829,
        13 => 0x100C,
        14 => 0x2015,
        15 => 0x6000,
        16 => 0xD008,
        17 => 0x12000,
        18 => 0x20400,
        19 => 0x40023,
        20 => 0x90000,
        21 => 0x140000,
        22 => 0x300000,
        23 => 0x420000,
        24 => 0xE10000,
        25 => 0x1200000,
        26 => 0x2000023,
        27 => 0x4000013,
        28 => 0xC800000,
        29 => 0x14000000,
        30 => 0x20000029,
        31 => 0x48000000,
        32 => 0x80200003

    );
    
    private $length, $mask;
    
    private $state = 0;
    
    function __construct($length = 8) {
        $this->length = $length;
        $this->mask = self::$masks[$length];
    }
    
    function state() {
        return sprintf("%0" . $this->length . "b",$this->state);
    }
    
    function tick() {
        
        $ns = ($this->state * 2) & (pow(2,$this->length) - 1);
        
        $new = $this->state & pow(2,$this->length - 1);
        
        for($i = $this->length - 2;$i >= 0;$i--) {
            
            if($this->mask & pow(2,$i)) {
                $new = (int) ($new xor ($this->state & pow(2,$i)));
            }
            
        }
        
        if($new == 0) {
            $ns++;
        }
        
        $this->state = $ns;
        
    }
    
    function run($ticks,$output = false) {
        
        if($output) {
            printf("%" . strlen($ticks) . "u: %0" . $this->length . "b\n",0,$this->state);
        }
        
        for($i=0;$i<$ticks;$i++) {
            $this->tick();
            if($output) {
                printf("%" . strlen($ticks) . "u: %0" . $this->length . "b\n",$i+1,$this->state);
            }
        }
        
    }
    
    static function GetState($length,$ticks) {
        
        $VC = new self($length);
        $VC->run($ticks);
        
        return $VC->state;
        
    }
    
}
