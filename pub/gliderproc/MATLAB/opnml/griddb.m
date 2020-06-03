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
GRIDS=str2mat(GRIDS,'mssubcre','ecgmex','msgmex','ec2001','pearl');
GRIDS=str2mat(GRIDS,'spain','spainarc','spportsub');
GRIDDIRS=str2mat('/home/wahoo/edwards/grids/qrtann/');
GRIDDIRS=str2mat(GRIDDIRS, '/home/wahoo/edwards/grids/gmex/');
GRIDDIRS=str2mat(GRIDDIRS, '/home/wahoo/edwards/grids/yessub/');
GRIDDIRS=str2mat(GRIDDIRS, '/home/wahoo/edwards/grids/yessoj/');
GRIDDIRS=str2mat(GRIDDIRS, '/home/wahoo/edwards/grids/fareast/');
GRIDDIRS=str2mat(GRIDDIRS, '/home/wahoo/edwards/grids/pgsub4/');
GRIDDIRS=str2mat(GRIDDIRS, '/home/wahoo/edwards/grids/pgsub2/');
GRIDDIRS=str2mat(GRIDDIRS, '/home/wahoo/edwards/grids/pgulf/');
GRIDDIRS=str2mat(GRIDDIRS, '/home/wahoo/edwards/grids/yesbit/');
GRIDDIRS=str2mat(GRIDDIRS, '/home/wahoo/edwards/grids/femadj/');
GRIDDIRS=str2mat(GRIDDIRS, '/home/wahoo/edwards/grids/femadj/old/');
GRIDDIRS=str2mat(GRIDDIRS, '/home/wahoo/edwards/grids/adjoint/');
GRIDDIRS=str2mat(GRIDDIRS, '/home/wahoo/edwards/grids/eastcoast/');
GRIDDIRS=str2mat(GRIDDIRS, '/home/wahoo/edwards/grids/subadj/');
GRIDDIRS=str2mat(GRIDDIRS, '/home/wahoo/edwards/grids/subadj2/');
GRIDDIRS=str2mat(GRIDDIRS, '/home/wahoo/edwards/grids/redsea/');
GRIDDIRS=str2mat(GRIDDIRS, '/home/wahoo/edwards/grids/yessub/fundy/');
GRIDDIRS=str2mat(GRIDDIRS, '/home/wahoo/edwards/grids/bay_st_louis/');
GRIDDIRS=str2mat(GRIDDIRS, '/home/wahoo/edwards/grids/mssub/');
GRIDDIRS=str2mat(GRIDDIRS, '/home/wahoo/edwards/grids/mssub6/');
GRIDDIRS=str2mat(GRIDDIRS, '/home/wahoo/edwards/grids/mssub7/');
GRIDDIRS=str2mat(GRIDDIRS, '/home/wahoo/edwards/grids/mssubcre/');
GRIDDIRS=str2mat(GRIDDIRS, '/home/wahoo/edwards/grids/ecgmex/');
GRIDDIRS=str2mat(GRIDDIRS, '/home/wahoo/edwards/grids/msgmex/');
GRIDDIRS=str2mat(GRIDDIRS, '/home/wahoo/edwards/grids/ec2001/');
GRIDDIRS=str2mat(GRIDDIRS, '/home/wahoo/edwards/grids/pearl/');
GRIDDIRS=str2mat(GRIDDIRS, '/home/wahoo/edwards/grids/spain/');
GRIDDIRS=str2mat(GRIDDIRS, '/home/wahoo/edwards/grids/spainarc/');
GRIDDIRS=str2mat(GRIDDIRS, '/home/wahoo/edwards/grids/spportsub/');

% UNC grids 
GRIDS=str2mat(GRIDS,'ec_2001','edisto','empanada','ga_la', ...
'peach','pelosab24','pelosab25','sab_clim2','sab_clim3','sab_clim3ll','sab_clim4', ...
'sab_ec2000_200','sab_ec95_nq','sab_mab','sab_mab2','sab_mab5','sab_mab7', ...
'sab_mab8','sabre1','satilla','seacoos','seacoos_coarse_sabll');

GRIDDIRS=str2mat(GRIDDIRS, '/scratch/credward/grids/ec_2001/');
GRIDDIRS=str2mat(GRIDDIRS, '/scratch/credward/grids/edisto/');
GRIDDIRS=str2mat(GRIDDIRS, '/scratch/credward/grids/empanada/');
GRIDDIRS=str2mat(GRIDDIRS, '/scratch/credward/grids/ga_la/');
GRIDDIRS=str2mat(GRIDDIRS, '/scratch/credward/grids/peach/');
GRIDDIRS=str2mat(GRIDDIRS, '/scratch/credward/grids/pelosab24/');
GRIDDIRS=str2mat(GRIDDIRS, '/scratch/credward/grids/pelosab25/');
GRIDDIRS=str2mat(GRIDDIRS, '/scratch/credward/grids/sab_clim2/');
GRIDDIRS=str2mat(GRIDDIRS, '/scratch/credward/grids/sab_clim3/');
GRIDDIRS=str2mat(GRIDDIRS, '/scratch/credward/grids/sab_clim3/');
GRIDDIRS=str2mat(GRIDDIRS, '/scratch/credward/grids/sab_clim4/');
GRIDDIRS=str2mat(GRIDDIRS, '/scratch/credward/grids/sab_ec2000_200/');
GRIDDIRS=str2mat(GRIDDIRS, '/scratch/credward/grids/sab_ec95_nq/');
GRIDDIRS=str2mat(GRIDDIRS, '/scratch/credward/grids/sab_mab/');
GRIDDIRS=str2mat(GRIDDIRS, '/scratch/credward/grids/sab_mab2/');
GRIDDIRS=str2mat(GRIDDIRS, '/scratch/credward/grids/sab_mab5/');
GRIDDIRS=str2mat(GRIDDIRS, '/scratch/credward/grids/sab_mab7/');
GRIDDIRS=str2mat(GRIDDIRS, '/scratch/credward/grids/sab_mab8/');
GRIDDIRS=str2mat(GRIDDIRS, '/scratch/credward/grids/sabre1/');
GRIDDIRS=str2mat(GRIDDIRS, '/scratch/credward/grids/satilla/');
GRIDDIRS=str2mat(GRIDDIRS, '/scratch/credward/grids/seacoos/');
GRIDDIRS=str2mat(GRIDDIRS, '/scratch/credward/grids/seacoos/');

