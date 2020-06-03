function R=eqnstate2(T,S)
%EQNSTATE2 - Matlab implementation of QUODDY's Equation of State.
%-----------------------------------------------------------------------
% purpose: This subroutine computes the perturbation density (R; in 
%          sigmat units) as a function of two variables; temperature 
%          (T; 0 to 40 degrees C) and salinity (S; 0 to 42 psu).
%
% reference: UNESCO equation of state as published in Gill(1982)
% Contributed by Douglas T. Morgan
%
% Vectorized version; BOB for FCAST work

if min(T)<0 | max(T)>40.
   error('Temperature outside of allowable range: (0<T<40)')
end
if min(S)<0 | max(S)>42. 
   error('Salinity outside of allowable range: (0<S<42)')
end

[mT,nT]=size(T);
[mS,nS]=size(S);
   
if (mS ~= mT) | (nS ~= nT)
   if mT*nT~=1 & mS*nS~=1 
      disp('Size of Temp array and Sal array must be the same')
      disp('or one must be 1x1.')
      R=[];
      return
   end
end

%
%...Density of pure water
%
R=-0.157406 ...  
  +6.793952E-2*T ...
  -9.095290E-3*T.^2 ...
  +1.001685E-4*T.^3 ...
  -1.120083E-6*T.^4 ...
  +6.536332E-9*T.^5;
%
%...Density at one standard atmosphere
F1=0.824493...
        -4.0899E-3*T ...
	+7.6438E-5*T.^2 ...
	-8.2467E-7*T.^3 ...
	+5.3875E-9*T.^4.0;
F2=-5.72466E-3 + 1.0227E-4*T - 1.6546E-6*T.^2;

R=R+S.*F1+(S.^1.5).*F2+4.8314E-4*S.^2;
