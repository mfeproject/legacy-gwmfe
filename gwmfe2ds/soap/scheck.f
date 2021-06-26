      subroutine scheck(y,kvec,  errc)
************************************************************************
*
*   SCHECK -- Check solution vector.
*
************************************************************************
      include "parameters.h"
      
      integer kx,ky
      parameter(kx=2,ky=3)

      integer nnod,ntri,tvtx
      common /mfe010/ nnod,ntri /mfe011/ tvtx(0:2,mtri)

      double precision fdinc,dxymin
      common /mfe022/ fdinc,dxymin

      double precision dxy0,dxy1,dxy
      common /mfe061/ dxy0(mtri),dxy1(mtri),dxy(mtri)

      integer kvec,errc,j
      double precision y(3,*),x0,x1,x2,y0,y1,y2

C=======================================================================
C
C     No need to check the solution for "negative" areas in the
C     case of the motion of a manifold
C
C     if(kvec .eq. 1) then
C       do 10 j=1,ntri
C  10   dxy1(j) = dxy(j)
C       endif
C
C     do 20 j=1,ntri
C      x0 = y(kx,tvtx(0,j))
C      y0 = y(ky,tvtx(0,j))
C      x1 = y(kx,tvtx(1,j))
C      y1 = y(ky,tvtx(1,j))
C      x2 = y(kx,tvtx(2,j))
C      y2 = y(ky,tvtx(2,j))
C      dxy(j) = (x0-x2)*(y1-y0) - (x1-x0)*(y0-y2)
C      if(dxy(j) .lt. dxymin) go to 910
C  20 continue
C
C     if(kvec .eq. 0) then
C       do 30 j=1,ntri
C  30   dxy0(j) = dxy(j)
C       endif
C
C=======================================================================

      errc = 0
      return

  910 write(8,911) j, dxy(j), (x0+x1+x2)/3., (y0+y1+y2)/3.
  911 format(/'** SCHECK: Bad triangle -- no. ',i5,
     +       '  dxy=',e10.3,' (',e10.3,',',e10.3,')')
      errc = 1
      return
      end
