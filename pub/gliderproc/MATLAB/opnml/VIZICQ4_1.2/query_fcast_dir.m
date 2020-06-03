function [starting_time,ending_time]=query_fcast_dir(dirname)
%QUERY_FCAST_DIR
% QUERY_FCAST_DIR determines the starting and ending
% simulation times for a specified forecast directory.
% Two time structures are returned.

if exist(dirname)~=7
   error([dirname ' does not exist.']);
   return
end

d=dir([dirname '/*.icq4']);
filenames={d.name}';
nfiles=length(filenames);

% If the forecast .icq4 files are in order,
% the first and last entries in filenames
% are the starting and ending times in the
% forecast.  Read the headers to get the times.

startingicq4struct=read_icq4([dirname '/' filenames{1}],0);
endingicq4struct=read_icq4([dirname '/' filenames{nfiles}],0);

starting_time.day  =startingicq4struct.day;
starting_time.month=startingicq4struct.month;
starting_time.year =startingicq4struct.year;
starting_time.sec  =startingicq4struct.curr_seconds;

ending_time.day  =endingicq4struct.day;
ending_time.month=endingicq4struct.month;
ending_time.year =endingicq4struct.year;
ending_time.sec  =endingicq4struct.curr_seconds;


