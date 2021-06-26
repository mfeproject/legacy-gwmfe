      subroutine linsol(x)
************************************************************************
*
*   LINSOL -- Linear equation solver.
*
************************************************************************
      include "parameters.h"
      
      integer smax
      parameter(smax=mnod*nepn**2)

      integer nnod,nelt
      common /mfe010/ nnod,nelt

      double precision a,b,c
      common /mfe040/ a(smax),b(smax),c(smax)

      double precision x(*)

      call btslv(nnod,nepn,  a,b,c,  x)

      return
      end
