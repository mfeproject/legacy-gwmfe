      subroutine ivals(y)
************************************************************************
*
*   IVALS -- Compute the initial value of the solution vector.
*
************************************************************************
      include "parameters.h"

      double precision yseg
      integer nseg,niseg
      common /tmp020/ nseg,niseg(mnod),yseg(nepn,mnod)

      integer node,i,j,k
      double precision y(nepn,*),h

      do 10 k=1,nepn
       node = 0
       do 11 i=1,nseg
        h = (yseg(k,i+1) - yseg(k,i))/dble(niseg(i))
        do 11 j=0,niseg(i)-1
         node = node + 1
         y(k,node) = yseg(k,i) + dble(j)*h
   11  continue
       node = node + 1
       y(k,node) = yseg(k,nseg+1)
   10 continue

      return
      end
