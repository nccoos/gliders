% LCONTOUR2
%
% STOP STOP STOP STOP
%
% In MATLAB5.0, the name of LCONTOUR2 has been changed to LCONTOUR4.
% LCONTOUR4 is a MATLAB5.0-compatible version of the MATLAB 4 routine
% LCONTOUR2 and has EXACTLY the same calling sequence. You MUST
% use LCONTOUR4.  (The MATLAB5.0-compliant version is called LCONTOUR.
% Type "help lcontour" for how it is called.) 
%
% The call that used to look like:
%        h=lcontour2(elems,x,y,Q,cval,p1,v1,p2,v2,...)
% now needs to look like:
%        h=lcontour4(elems,x,y,Q,cval,p1,v1,p2,v2,...)
%
% Sorry, but this is unavoidable and terminal !!

function chandle=lcontour2(elems,x,y,Q,cval,p1,v1,p2,v2,p3,v3,p4,v4,...
                                            p5,v5,p6,v6,p7,v7,p8,v8) 
disp(' STOP   STOP   STOP')
disp(' In MATLAB5.0, the name of LCONTOUR2 has been changed to LCONTOUR4. ')
disp(' LCONTOUR4 is a MATLAB5.0-compatible version of the MATLAB 4 routine ')
disp(' LCONTOUR2 and has EXACTLY the same calling sequence. You MUST ')
disp(' use LCONTOUR4. ')
disp(' ')
disp(' The call that used to look like:')
disp(' ')
disp('         h=lcontour2(elems,x,y,Q,cval,p1,v1,p2,v2,...)')
disp(' ')
disp(' now needs to look like:')
disp('         h=lcontour4(elems,x,y,Q,cval,p1,v1,p2,v2,...)')
disp(' ')
disp('  Sorry, but this is unavoidable and terminal !!')
disp(' ')
return

