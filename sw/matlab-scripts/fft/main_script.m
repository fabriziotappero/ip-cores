%Main script for the 1024 point Wishbone compatible FFT-core
%Thanks to Adam Robert Miller
clc;
clear all;
close all;

N=1024;
tbits=16;

twiddlegen_rc(N,tbits);