      subroutine scheck(y,kvec,  errc)
************************************************************************
*
*   SCHECK -- Check solution vector.
*
************************************************************************
      include "parameters.h"
      
      integer nnod,nelt
      common /mfe010/ nnod,nelt

      double precision fdinc,dxmin
      common /mfe022/ fdinc,dxmin

      double precision dx
      common /mfe061/ dx(mnod)

      integer kvec,errc,j
      double precision y(nepn,*)

*     Check for bad elements, saving lengths for ENORM.
      do 10 j=1,nelt
       dx(j) = y(nepn,j+1) - y(nepn,j)
       if(dx(j) .lt. dxmin) go to 910
   10 continue
      errc = 0
      return
*     ==================================================================
*      Error return.
*     ==================================================================
  910 write(6,911) j
  911 format(/'** SCHECK: Bad element -- no. ',i4)
      errc = 1
      end
