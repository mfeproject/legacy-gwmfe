      subroutine cpmtx(nnod,xadj,adjncy,anonz,adgl,  bandw,aband)
************************************************************************
*
*   CPMTX -- Copy compactly stored matrix to banded storage.
*
************************************************************************
      include "parameters.h"

      integer nepn2
      parameter(nepn2=(npde+2)**2)

      integer nnod,xadj(*),adjncy(*),bandw,i,j,k
      double precision anonz(nepn2,*),adgl(nepn2,*)
      double precision aband(nepn2,-bandw:bandw,*)

*     Zero the banded storage initially.
      do 10 j=1,(2*bandw+1)*nnod*nepn2
   10 aband(j,1,1) = 0.

*     Store the diagonal blocks.
      do 20 j=1,nnod
      do 20 i=1,nepn2
   20 aband(i, 0, j) = adgl(i, j)

*     Store the off-diagonal blocks.
      do 30 j=1,nnod
      do 30 k=xadj(j),xadj(j+1)-1
      do 30 i=1,nepn2
   30 aband(i, adjncy(k)-j, j) = anonz(i, k)

      return
      end
