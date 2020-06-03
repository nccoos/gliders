function [DATA,FREQ,PERNAMES]=read_adcirc_ha_elev(fname,flag,gname)
%READ_ADCIRC_HA_ELEV read ADCIRC elevation output file
% This routine reads in the contents of an ADCIRC elevation file,
% as typically output from an harmonic analysis output to a fort.53
% file.  fort.53 is the default output file for the global harmonic
% analysis of the elevation field.  
%
%  Input : fname - filename to read elevation from.  If empty,
%                  routine reads from fort.53.  Analysis from
%                  specified stations (fort.51) can be read in
%                  by providing fname='fort.51'.
%          flag  - if flag==1, the contents of the elevation file 
%                  are output to disk in .s2c file format, one file
%                  per period. 
%          gname - if flag==1, then gname provides the grid name
%                  for the .s2c file output format.
% Output : DATA     -  matrix of amplitudes and phases, as in
%                      DATA = [amp1 amp2 ... pha1 pha2 ...];
%          FREQ     -  vector of component frequencies
%          PERNAMES -  string vector of component names
%
% Call as: [DATA,FREQ,PERNAMES]=read_adcirc_ha_elev(fname,flag,gname);
% 
% Written by: Brian Blanton, Spring '99

% if no arguments, assume fort.53...

if nargin==0
   fname='fort.53';
   flag=0;  % no .s2c output to disk
   gname='';
elseif nargin==1
   % See if fname is string
   if ~isstr(fname)
      fname='fort.53';
      if flag~=0 | flag~=1
         error('FLAG to READ_ADCIRC_HA_ELEV must be 0|1')
      end
   else
      % Try to open fname
      [fid,message]=fopen(fname,'r');
      if fid==-1
         error(['Could not open ' fname ' because ' message])
      end
      fclose(fid);
      flag=0;
      gname='';
   end
end

% Determine if there is a path on the fname, that may have been 
% passed in.
[fpath,fname,ext,ver] = fileparts(fname);

if isempty(fpath)
   filename=[fname ext]
   fid=fopen([fname ext],'r');
else
   fid=fopen([fpath '/' fname ext],'r');
end
ncomp=fscanf(fid,'%d',1);

for i=1:ncomp
   temp=fscanf(fid,'%f %f %f',[1 3]);
   FREQ(i)=temp(1);
   PERNAMES{i}=fscanf(fid,'%s',[1]);
end

nnodes=fscanf(fid,'%d',1);

A=NaN*ones(nnodes,ncomp);
G=NaN*ones(nnodes,ncomp);

for i=1:nnodes
   n=fscanf(fid,'%d',1);
   for j=1:ncomp
      temp=fscanf(fid,'%f %f',[1 2]);
      A(n,j)=temp(1);
      G(n,j)=temp(2);
   end
end

DATA=[A G];

% if flag==1,output constituents into .s2c files
if flag
   disp('Writing individual components to disk...')
   for i=1:ncomp
      if isempty(fpath)
         fname=[PERNAMES{i} '.s2c'];
      else
         fname=[fpath '/' PERNAMES{i} '.s2c'];    
      end
      disp(['   Writing ' fname '...'])
      comment=[PERNAMES{i} ' HA RESULTS'];
      err=write_s2c([DATA(:,i) DATA(:,i+ncomp)],gname,comment,FREQ(i),fname);
   end
end   
