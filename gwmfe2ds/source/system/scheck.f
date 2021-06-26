      subroutine scheck(y,kvec,  errc)
************************************************************************
*
*   SCHECK -- Check solution vector.
*
************************************************************************
      include "parameters.h"

      integer nepn,kx,ky
      parameter(nepn=npde+2,kx=npde+1,ky=npde+2)

      integer nnod,ntri,tvtx
      common /mfe010/ nnod,ntri /mfe011/ tvtx(0:2,mtri)

      double precision fdinc,dxymin
      common /mfe022/ fdinc,dxymin

      double precision dxy0,dxy1,dxy
      common /mfe061/ dxy0(mtri),dxy1(mtri),dxy(mtri)

      integer kvec,errc,j
      double precision y(nepn,*),x0,x1,x2,y0,y1,y2

      if(kvec .eq. 1) then
        do 10 j=1,ntri
   10   dxy1(j) = dxy(j)
        endif

      do 20 j=1,ntri
       x0 = y(kx,tvtx(0,j))
       y0 = y(ky,tvtx(0,j))
       x1 = y(kx,tvtx(1,j))
       y1 = y(ky,tvtx(1,j))
       x2 = y(kx,tvtx(2,j))
       y2 = y(ky,tvtx(2,j))
       dxy(j) = (x0-x2)*(y1-y0) - (x1-x0)*(y0-y2)
       if(dxy(j) .lt. dxymin) go to 910
   20 continue

      if(kvec .eq. 0) then
        do 30 j=1,ntri
   30   dxy0(j) = dxy(j)
        endif

      errc = 0
      return

  910 write(8,911) j, dxy(j), (x0+x1+x2)/3., (y0+y1+y2)/3.
  911 format(/'** SCHECK: Bad triangle -- no. ',i5,
     +       '  dxy=',e10.3,' (',e10.3,',',e10.3,')')
      errc = 1
      return
      end
