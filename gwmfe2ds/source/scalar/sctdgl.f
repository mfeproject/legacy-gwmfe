      subroutine sctdgl(n,itri,  adgl)
************************************************************************
*
*   SCTDGL -- For each element, scatter the diagonal contribution of
*             the local mass matrix to the global mass matrix diagonal.
*
************************************************************************
      include "parameters.h"
      
      integer tvtx
      common /mfe011/ tvtx(0:2,mtri)

      double precision a
      common /loc013/ a(65,9,0:2,0:2)

      integer n,itri,v0,v1,v2,i,j
      double precision adgl(9,*)

      do 10 j=1,n

      v0 = tvtx(0, j+itri-1)
      v1 = tvtx(1, j+itri-1)
      v2 = tvtx(2, j+itri-1)

      do 10 i=1,9
       adgl(i, v0) = adgl(i, v0) + a(j, i, 0,0)
       adgl(i, v1) = adgl(i, v1) + a(j, i, 1,1)
       adgl(i, v2) = adgl(i, v2) + a(j, i, 2,2)
   10 continue

      return
      end
