<?php

class CSV {
    
    protected $file = null;
    protected $header = array();
    
    function __construct($fileName) {
        
        $this->file = fopen($fileName,'r');
        
        $this->parseHeader();
        
    }
    
    protected function getLine() {
        
        $line = fgetcsv($this->file);
        
        if($this->isEmpty($line)) {
            return false;
        } else {
            return $line;
        }
        
    }
    
    function parseHeader() {
        
        do {
            
            $this->header = $this->getLine();
            
        } while($this->header === false and !feof($this->file));
        
        return (count($this->header) > 0);
        
    }
    
    function getRow() {
        
        $array = $this->getLine();
        
        if($array === false) {
            
            return false;
            
        } else {
            
            $return = array();
            
            foreach($array as $key => $val) {
                $return[$this->header[$key]] = $val;
            }
            
            return $return;
            
        }
        
    }
    
    function getRows() {
        
        $return = array();
        
        while($row = $this->getRow()) {
            $return[] = $row;
        }
        
        return $return;
        
    }
    
    function isEmpty($row) {
        if($row === false or $row === array(null)) {
            return true;
        } else {
            foreach($row as $cur) {
                if(trim($cur) != '') {
                    return false;
                }
            }
            return true;
        }
    }
    
    function __destruct() {
        fclose($this->file);
    }
    
}
