      subroutine sctmtx(n,itri,xadj,adjncy,  anonz,adgl)
************************************************************************
*
*   SCTMTX -- For each element, scatter the contribution of the local
*             Jacobian (or mass) matrix to the global Jacobian matrix.
*
************************************************************************
      include "parameters.h"
      
      integer tvtx
      common /mfe011/ tvtx(0:2,mtri)

      double precision a
      common /loc013/ a(65,9,0:2,0:2)

      integer n,itri,xadj(*),adjncy(*),v0,v1,v2,i,j,k,ivtx,jvtx
      double precision anonz(9,*),adgl(9,*)

      do 10 j=1,n

      v0 = tvtx(0, j+itri-1)
      v1 = tvtx(1, j+itri-1)
      v2 = tvtx(2, j+itri-1)

*     Scatter the diagonal blocks.
      do 13 i=1,9
       adgl(i, v0) = adgl(i, v0) + a(j, i, 0,0)
       adgl(i, v1) = adgl(i, v1) + a(j, i, 1,1)
       adgl(i, v2) = adgl(i, v2) + a(j, i, 2,2)
   13 continue

*     Scatter the off-diagonal blocks.
      do 10 ivtx=0,2
      do 10 jvtx=0,2
       if(ivtx.eq.jvtx) go to 10
       k = xadj(tvtx(ivtx,j+itri-1))-1
   12  k = k+1
       if(adjncy(k) .ne. tvtx(jvtx,j+itri-1)) go to 12
       do 11 i=1,9
   11  anonz(i, k) = anonz(i, k) + a(j, i, ivtx,jvtx)
   10 continue

      return
      end
