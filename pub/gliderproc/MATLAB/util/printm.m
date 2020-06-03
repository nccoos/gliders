function [] = printm( filename )
% function [] = printm( filename )
% 
% print Postscript file with a signature

timestamp(filename)
eval(['print -dps ',filename])
