c
      program sortv
c
      parameter(nndim=5000,nkdim=100)
      real c(nndim,4),x(nndim,nkdim),y(nndim,nkdim),cv,cs(2,nndim)
      integer ikeep(nndim),jpk(nndim),jmk(nndim),inot(nndim)
c
      open(10,file='c.dat')
      do i=1,nndim
      read(10,*,end=100)(c(i,j),j=1,4)
      ikeep(i)=0
      enddo
 100      ndim=i-1
      open(30,file='cv.dat')
      read(30,*)cv
      open(20,file='cxy.dat')
c
      ns=1
      do k=1,nkdim
c start with maximum y
      cymax=-1.0e06
      do l=1,ndim
        do ill=1,ndim
          if(ikeep(ill).eq.l)goto 80
        enddo
        if(c(l,2).gt.cymax)then
          cymax=c(l,2)
          lmax=l
          jp=2
          jm=4
        endif
        if(c(l,4).gt.cymax)then
          cymax=c(l,4)
          lmax=l
          jp=4
          jm=2
        endif
 80      enddo
c
c set first point
      x(1,k)=c(lmax,jp-1)
      y(1,k)=c(lmax,jp)
      x(2,k)=c(lmax,jm-1)
      y(2,k)=c(lmax,jm)      
      il=il+1
      ikeep(il)=lmax
      jpk(il)=jp-1
      jmk(il)=jm-1
c
c 
      xc=x(2,k)
      yc=y(2,k)
      do l=3,2*ndim-1,2
        do i=1,ndim
          do ill=1,ndim
            if(ikeep(ill).eq.i)goto 110
          enddo
          if(xc.eq.c(i,1).and.yc.eq.c(i,2))then
            il=il+1
            ikeep(il)=i
            jpk(il)=1
            jmk(il)=3
            xc=c(i,3)
            yc=c(i,4)
            goto 115
          elseif(xc.eq.c(i,3).and.yc.eq.c(i,4))then
            il=il+1
            ikeep(il)=i
            jpk(il)=3
            jmk(il)=1
            xc=c(i,1)
            yc=c(i,2)
            goto 115
          endif
 110      enddo
 115      enddo
      nl=il
c
c
      write(20,*)il,k,cv,2*(nl-ns)+2
      do i=2*ns-1,2*nl-1,2
        ik=ik+1
       ii=ikeep(ik)
       x(i,k)=c(ii,jpk(ik))
       y(i,k)=c(ii,jpk(ik)+1)
       x(i+1,k)=c(ii,jmk(ik))
       y(i+1,k)=c(ii,jmk(ik)+1)
       write(20,*)i,k,x(i,k),y(i,k)
       write(20,*)i+1,k,x(i+1,k),y(i+1,k)
      enddo
      ns=nl+1
      if(nl.ge.ndim)goto 200
      enddo
c
c
 200      return
      end
