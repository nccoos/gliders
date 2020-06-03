% define grid database directories
%
disp('adding grid database directories ...');
global DOMAIN GRIDS GRIDDIRS



% These lines demonstrate how grid names and paths can be 
% added so that LOADGRID looks for grids in "default" locations.
GRIDS=str2mat('qrtann','gmex','yessub','yessoj','fareast');
GRIDS=str2mat(GRIDS, 'pgsub4','pgsub2','pgulf','yesbit');
GRIDS=str2mat(GRIDS,'femadj','femadj_old','adjoint','eastcoast');
GRIDS=str2mat(GRIDS,'subadj','subadj2','redsea');
GRIDS=str2mat(GRIDS,'yessub.fundy','bay_st_louis','mssub','mssub6','mssub7');
GRIDS=str2mat(GRIDS,'mssubcre','ecgmex','msgmex','ec2001');
GRIDDIRS=str2mat('Z:\grids\qrtann\');
GRIDDIRS=str2mat(GRIDDIRS, 'Z:\grids\gmex\');
GRIDDIRS=str2mat(GRIDDIRS, 'Z:\grids\yessub\');
GRIDDIRS=str2mat(GRIDDIRS, 'Z:\grids\yessoj\');
GRIDDIRS=str2mat(GRIDDIRS, 'Z:\grids\fareast\');
GRIDDIRS=str2mat(GRIDDIRS, 'Z:\grids\pgsub4\');
GRIDDIRS=str2mat(GRIDDIRS, 'Z:\grids\pgsub2\');
GRIDDIRS=str2mat(GRIDDIRS, 'Z:\grids\pgulf\');
GRIDDIRS=str2mat(GRIDDIRS, 'Z:\grids\yesbit\');
GRIDDIRS=str2mat(GRIDDIRS, 'Z:\grids\femadj\');
GRIDDIRS=str2mat(GRIDDIRS, 'Z:\grids\femadj\old\');
GRIDDIRS=str2mat(GRIDDIRS, 'Z:\grids\adjoint\');
GRIDDIRS=str2mat(GRIDDIRS, 'Z:\grids\eastcoast\');
GRIDDIRS=str2mat(GRIDDIRS, 'Z:\grids\subadj\');
GRIDDIRS=str2mat(GRIDDIRS, 'Z:\grids\subadj2\');
GRIDDIRS=str2mat(GRIDDIRS, 'Z:\grids\redsea\');
GRIDDIRS=str2mat(GRIDDIRS, 'Z:\grids\yessub\fundy\');
GRIDDIRS=str2mat(GRIDDIRS, 'Z:\grids\bay_st_louis\');
GRIDDIRS=str2mat(GRIDDIRS, 'Z:\grids\mssub\');
GRIDDIRS=str2mat(GRIDDIRS, 'Z:\grids\mssub6\');
GRIDDIRS=str2mat(GRIDDIRS, 'Z:\grids\mssub7\');
GRIDDIRS=str2mat(GRIDDIRS, 'Z:\grids\mssubcre\');
GRIDDIRS=str2mat(GRIDDIRS, 'Z:\grids\ecgmex\');
GRIDDIRS=str2mat(GRIDDIRS, 'Z:\grids\msgmex\');
GRIDDIRS=str2mat(GRIDDIRS, 'Z:\grids\ec2001\');

