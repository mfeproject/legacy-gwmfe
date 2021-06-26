      subroutine sctvec(n,itri,  r)
************************************************************************
*
*   SCTVEC -- For each element, scatter the contribution of the local
*             residual vector at each vertex to the global residual.
*
************************************************************************
      include "parameters.h"

      integer nepn
      parameter(nepn=npde+2)

      integer tvtx
      common /mfe011/ tvtx(0:2,mtri)

      double precision r0,r1,r2
      common /loc012/ r0(65,nepn),r1(65,nepn),r2(65,nepn)

      double precision r(nepn,*)
      integer n,itri,j,k,v0,v1,v2

      do 10 j=1,n

      v0 = tvtx(0, j+itri-1)
      v1 = tvtx(1, j+itri-1)
      v2 = tvtx(2, j+itri-1)

      do 10 k=1,nepn
       r(k,v0) = r(k,v0) + r0(j,k)
       r(k,v1) = r(k,v1) + r1(j,k)
       r(k,v2) = r(k,v2) + r2(j,k)
   10 continue

      return
      end
