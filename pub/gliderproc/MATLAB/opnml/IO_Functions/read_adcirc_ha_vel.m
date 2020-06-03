function [DATA,FREQ,PERNAMES]=read_adcirc_ha_vel(fname,flag,gname)
%READ_ADCIRC_HA_VEL read ADCIRC velocity output file
% This routine reads in the contents of an ADCIRC elevation file,
% as typically output from an harmonic analysis output to a fort.54
% file.  fort.54 is the default output file for the global harmonic
% analysis of the velocity field.  
%
%  Input : fname - filename to read velocity from.  If empty,
%                  routine reads from fort.54.  Analysis from
%                  specified stations (fort.52) can be read in
%                  by providing fname='fort.52'.
%          flag  - if flag==1, the contents of the velocity file 
%                  are output to disk in .v2c file format, one file
%                  per period. 
%          gname - if flag==1, then gname provides the grid name
%                  for the .v2c file output format.
% Output : DATA     -  matrix of amplitudes and phases, as in
%                      DATA = [uamp1 ... upha1 ... vamp1 ... vpha1 ...];
%          FREQ     -  vector of component frequencies
%          PERNAMES -  string vector of component names
%
% Call as: [DATA,FREQ,PERNAMES]=read_adcirc_ha_vel(fname,flag,gname);
% 
% Written by: Brian Blanton, Spring '99

% if no arguments, assume fort.54...

if nargin==0
   fname='fort.54';
   flag=0;  % no .v2c output to disk
   gname='';
elseif nargin==1
   % See if fname is string
   if ~isstr(fname)
      fname='fort.54';
      if flag~=0 | flag~=1
         error('FLAG to READ_ADCIRC_HA_VEL must be 0|1')
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

UA=NaN*ones(nnodes,ncomp);
UG=NaN*ones(nnodes,ncomp);
VA=NaN*ones(nnodes,ncomp);
VG=NaN*ones(nnodes,ncomp);

for i=1:nnodes
   n=fscanf(fid,'%d',1);
   for j=1:ncomp
      temp=fscanf(fid,'%f %f %f %f',[1 4]);
      UA(n,j)=temp(1);
      UG(n,j)=temp(2);
      VA(n,j)=temp(3);
      VG(n,j)=temp(4);
   end
end

DATA=[UA UG VA VG];



% if flag==1,output comstituents into .v2c files
if flag
   disp('Writing individual components to disk...')
   for i=1:ncomp
      if isempty(fpath)
         fname=[PERNAMES{i} '.v2c'];
      else
         fname=[fpath '/' PERNAMES{i} '.v2c'];    
      end
      disp(['   Writing ' fname '...'])
      comment=[PERNAMES{i} ' HA RESULTS'];
      D=[DATA(:,i) DATA(:,i+ncomp) DATA(:,i+2*ncomp) DATA(:,i+3*ncomp)];
      err=write_s2c(D,gname,comment,FREQ(i),fname);
   end
end   




