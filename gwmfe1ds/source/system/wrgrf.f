      subroutine wrgrf(y,t)
************************************************************************
*
*   WRGRF -- Write solution to the graphics file.
*
************************************************************************
      include "parameters.h"
      
      integer nnod,nelt
      common /mfe010/ nnod,nelt

      integer nstep,stats
      double precision hlast
      real cpusec
      common /mfe070/ hlast,cpusec,nstep,stats(7)

      integer j,k
      double precision y(nepn,*),t
      character fmt*16

      write(7,110) t,nstep,cpusec
  110 format('t=',e13.6,', nstep=',i4,', cpu=',f8.1)

      write(fmt,120) npde
  120 format('(e17.9,',i2,'e12.4)')
      write(7,fmt) (y(nepn,j), (y(k,j), k=1,npde), j=1,nnod)

      return
      end
