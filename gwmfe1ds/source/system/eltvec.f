      subroutine eltvec(y,z)
************************************************************************
*
*   ELTVEC -- Gather the element-wise vectors.
*  
************************************************************************
      include "parameters.h"

      integer nnod,nelt
      common /mfe010/ nnod,nelt

      double precision y0,y1,z0,z1
      common /loc10/ y0(mnod,nepn),y1(mnod,nepn)
      common /loc11/ z0(mnod,nepn),z1(mnod,nepn)

      integer k,j
      double precision y(nepn,*),z(nepn,*)

      do 10 k=1,nepn
      do 10 j=1,nelt
       y0(j,k) = y(k,j)
       y1(j,k) = y(k,j+1)

       z0(j,k) = z(k,j)
       z1(j,k) = z(k,j+1)
   10 continue

      return
      end
