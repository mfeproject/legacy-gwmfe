      double precision function enorm(e,kvec)
************************************************************************
*
*   ENORM -- Error norm.
*
************************************************************************
      include "parameters.h"
      
      integer nnod,nelt
      common /mfe010/ nnod,nelt

      double precision ptol,rtol,dx
      common /mfe060/ ptol(nepn),rtol /mfe061/ dx(mnod)

      integer kvec,j,k
      double precision e(nepn,*)

*     Absolute norm on each unknown.
      enorm = 0.d0
      do 10 k=1,nepn
      do 10 j=1,nnod
   10 enorm = max( enorm, abs(e(k,j))/ptol(k) )

*     Relative norm on the element lengths.
      do 20 j=1,nelt
   20 enorm = max( enorm, abs(e(nepn,j+1)-e(nepn,j))/(dx(j)*rtol) )

      return
      end
