      double precision function enorm(e,kvec)
************************************************************************
*
*   ENORM -- Error norm.
*
************************************************************************
      include "parameters.h"
      
      integer nnod,ntri
      common /mfe010/ nnod,ntri

      double precision ptol,rtol,dxy0,dxy1,dxy
      common /mfe060/ ptol(3),rtol
      common /mfe061/ dxy0(mtri),dxy1(mtri),dxy(mtri)

      double precision e(3,*)
      integer kvec,j,k

      enorm = 0.
      do 10 k=1,3
      do 10 j=1,nnod
   10 enorm = max( enorm, abs(e(k,j))/ptol(k) )

      if(kvec .eq. 1) then
        do 20 j=1,ntri
   20   enorm = max( enorm, abs((dxy(j)-dxy1(j))/dxy(j))/rtol )

      elseif(kvec .eq. 2) then
        do 30 j=1,ntri
   30   enorm = max( enorm, abs((dxy(j)-dxy0(j))/dxy(j))/rtol )
        endif

      return
      end
