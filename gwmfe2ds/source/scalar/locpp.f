      subroutine locpp(n,  errc,trix,triy)
************************************************************************
*
*   LOCPP -- Triangle term pre-processor.
*
************************************************************************
      double precision u0,x0,y0,u1,x1,y1,u2,x2,y2
      common /loc010/ u0(65),x0(65),y0(65),
     +                u1(65),x1(65),y1(65),
     +                u2(65),x2(65),y2(65)

      double precision a,n1,n2,n3,ayu,aux,axy
      double precision du0,dx0,dy0,du1,dx1,dy1,du2,dx2,dy2
      common /loc020/ a(65) /loc021/ n1(65),n2(65),n3(65)
      common /loc022/ ayu(65),aux(65),axy(65)
      common /loc023/ du0(65),dx0(65),dy0(65),
     +                du1(65),dx1(65),dy1(65),
     +                du2(65),dx2(65),dy2(65)

      double precision q0q0,q1q1,q2q2,q1q2,q2q0,q0q1
      common /loc030/ q0q0(65),q1q1(65),q2q2(65),
     +                q1q2(65),q2q0(65),q0q1(65)

      double precision l0,l1,l2,dudn0,dudn1,dudn2
      common /loc040/ l0(65),l1(65),l2(65)
      common /loc041/ dudn0(65),dudn1(65),dudn2(65)

      integer n,errc,j
      double precision trix,triy,dudx,dudy

      do 10 j=1,n
*      Differences in x and y along the edges.
       dx0(j) = x2(j) - x1(j)
       dx1(j) = x0(j) - x2(j)
       dx2(j) = x1(j) - x0(j)

       dy0(j) = y2(j) - y1(j)
       dy1(j) = y0(j) - y2(j)
       dy2(j) = y1(j) - y0(j)

*      X-y projected area.
       axy(j) = .5*(dx1(j)*dy2(j) - dx2(j)*dy1(j))

*      Edge lengths in the x-y plane.
       l0(j) = sqrt(dx0(j)**2 + dy0(j)**2)
       l1(j) = sqrt(dx1(j)**2 + dy1(j)**2)
       l2(j) = sqrt(dx2(j)**2 + dy2(j)**2)
   10 continue

*     Check for positive triangle areas.
      errc = 0
      do 20 j=1,n
       if(axy(j) .le. 0.) then
       trix = (x0(j) + x1(j) + x2(j))/3.
       triy = (y0(j) + y1(j) + y2(j))/3.
       errc = j
       return
       endif
   20 continue

      do 30 j=1,n
*      Differences in u along the edges.
       du0(j) = u2(j) - u1(j)
       du1(j) = u0(j) - u2(j)
       du2(j) = u1(j) - u0(j)

*      Y-u and u-x projected areas.
       ayu(j) = .5*(dy1(j)*du2(j) - dy2(j)*du1(j))
       aux(j) = .5*(du1(j)*dx2(j) - du2(j)*dx1(j))

*      Surface area.
       a(j) = sqrt(ayu(j)**2 + aux(j)**2 + axy(j)**2)

*      Components of the unit normal to the surface.
       n1(j) = ayu(j)/a(j)
       n2(j) = aux(j)/a(j)
       n3(j) = axy(j)/a(j)

*      Normal derivatives to the edges.
       dudx = -ayu(j)/axy(j)
       dudy = -aux(j)/axy(j)
       dudn0(j) = (dy0(j)*dudx - dx0(j)*dudy)/l0(j)
       dudn1(j) = (dy1(j)*dudx - dx1(j)*dudy)/l1(j)
       dudn2(j) = (dy2(j)*dudx - dx2(j)*dudy)/l2(j)

*      Edge vector inner products in the graph.
       q0q0(j) = l0(j)**2 + du0(j)**2
       q1q1(j) = l1(j)**2 + du1(j)**2
       q2q2(j) = l2(j)**2 + du2(j)**2
       
       q1q2(j) = dx1(j)*dx2(j) + dy1(j)*dy2(j) + du1(j)*du2(j)
       q2q0(j) = dx2(j)*dx0(j) + dy2(j)*dy0(j) + du2(j)*du0(j)
       q0q1(j) = dx0(j)*dx1(j) + dy0(j)*dy1(j) + du0(j)*du1(j)
   30 continue

      return
      end
