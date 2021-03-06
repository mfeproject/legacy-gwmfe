      subroutine gthvec(n,itri,y,z)
************************************************************************
*
*   GTHVEC -- For each element, gather the vector of unknowns Y and
*             its time derivative Z at each vertex of the element.
*
************************************************************************
      include "parameters.h"
      
      integer tvtx
      common /mfe011/ tvtx(0:2,mtri)

      double precision y0,y1,y2,z0,z1,z2
      common /loc010/ y0(65,3),y1(65,3),y2(65,3)
      common /loc011/ z0(65,3),z1(65,3),z2(65,3)

      double precision y(3,*),z(3,*)
      integer n,itri,j,k,v0,v1,v2

      do 10 j=1,n

      v0 = tvtx(0, j+itri-1)
      v1 = tvtx(1, j+itri-1)
      v2 = tvtx(2, j+itri-1)

      do 10 k=1,3
       y0(j,k) = y(k,v0)
       y1(j,k) = y(k,v1)
       y2(j,k) = y(k,v2)

       z0(j,k) = z(k,v0)
       z1(j,k) = z(k,v1)
       z2(j,k) = z(k,v2)
   10 continue

      return
      end
