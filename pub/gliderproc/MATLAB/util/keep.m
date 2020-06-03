function keep(varargin);
%KEEP keeps the base workspace variables of your choice and clear the rest.
%	
%     CALL: keep var1 var2 var3 ...
%	
%
% Yoram Tal 5/7/98    yoramtal@internet-zahav.net
% MATLAB version 5.2
% Based on a program by Xiaoning (David) Yang
% 15/9/99 Bug fix - empty delete sring (due to Hyrum D Johnson)
% 
% 29 Mar 2000 Catherine R. Edwards - Feature added to keep all globals
%

% Find variables in base workspace
wh = evalin('base','who');

% Remove variables in the "keep" list
del = setdiff(wh,varargin);

% Keep all global variables
isglo=nan*ones(1,length(del));
for i=1:length(del)
  isglo(i)=evalin('base',['isglobal(' char(wh(i)) ')']);   
end
del(find(isglo==1))=[];

% Nothing to remove - return
if isempty(del),
   return;
end

% Construct the clearing command string
str=blank(column([repmat(',''',length(del),1),char(del),repmat('''',length(del),1)]')'); 

% Clear
evalin('base',['clear(',str(2:end),');'])
