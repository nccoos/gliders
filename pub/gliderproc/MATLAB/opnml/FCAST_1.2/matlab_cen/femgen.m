%***********************************************************************
%***********************************************************************
%     SUBROUTINE FEMGEN(nndim,nedim,nseg,nnv,x,y,nele,in)
%-----------------------------------------------------------------------
% purpose: This subroutine creates a 2-D Finite Element incidence list
%            for a 2-D grid of points (nseg+1)*nnv.
%
% restrictions: the coordinates of the nodes for which the
%               incidence list is being created must increase from
%               bottom to top and left to right, ie (for nseg=2,nnv=3):
%
%                             3 6 9
%                             2 5 8
%                             1 4 7
%
% index range: kk=1,nele
%
% inputs: Dimensioning parameters
%          nndim - parametered size of arrays indexed with i,m,n
%          nedim - parametered size of arrays indexed with kk
%         Vertical slice 2-D mesh data
%          nseg - number of horizontal sections
%          nnv - number of nodes in the vertical (constant)
%
% outputs: nele - number of elements = (nseg*(nnv-1))
%          in - incidence list
%
% history:  Written by Christopher E. Naimie
%           Dartmouth College
%           1993, MAY 4 - fortran version
%           1997, OCT 9 - matlab version
%-----------------------------------------------------------------------
%      integer in(3,nedim)
%      real x(nndim),y(nndim)
%
% START OF EXECUTABLE CODE
      clear in
      kk=0;
      for i=1:nseg
         for j=1:nnv-1
            n1=(i-1)*nnv+j;
            n2=n1+nnv;
            n3=n2+1;
            n4=n1+1;
            s21=(x(n3)-x(n1))^2.0+(y(n3)-y(n1))^2.0;
            s22=(x(n2)-x(n4))^2.0+(y(n4)-y(n2))^2.0;
            if s21<s22
               kk=kk+1;
               in(1,kk)=n1;
               in(2,kk)=n2;
               in(3,kk)=n3;
               kk=kk+1;
               in(1,kk)=n1;
               in(2,kk)=n3;
               in(3,kk)=n4;
            else
               kk=kk+1;
               in(1,kk)=n1;
               in(2,kk)=n2;
               in(3,kk)=n4;
               kk=kk+1;
               in(1,kk)=n2;
               in(2,kk)=n3;
               in(3,kk)=n4;
            end
         end
      end
      ne=kk;
      in=in';
%      if(nele.GT.nedim)then
%         write(*,*)' Increase nedim, the number of elements >',nedim
%         stop
%      endif
%
% END OF EXECUTABLE CODE
%      return
%      end
%***********************************************************************
%***********************************************************************
