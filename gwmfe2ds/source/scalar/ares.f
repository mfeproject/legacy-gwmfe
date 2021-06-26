      subroutine ares(n)
************************************************************************
*
*   ARES -- MFE mass matrix contribution to the residual.
*
************************************************************************
      double precision zu0,zx0,zy0,zu1,zx1,zy1,zu2,zx2,zy2
      double precision ru0,rx0,ry0,ru1,rx1,ry1,ru2,rx2,ry2
      common /loc011/ zu0(65),zx0(65),zy0(65),
     +                zu1(65),zx1(65),zy1(65),
     +                zu2(65),zx2(65),zy2(65)
      common /loc012/ ru0(65),rx0(65),ry0(65),
     +                ru1(65),rx1(65),ry1(65),
     +                ru2(65),rx2(65),ry2(65)

      double precision a,n1,n2,n3
      common /loc020/ a(65) /loc021/ n1(65),n2(65),n3(65)

      integer n,j
      double precision c,t0,t1,t2,term

      c = 1./12.
      do 10 j=1,n
       t0 = zx0(j)*n1(j) + zy0(j)*n2(j) + zu0(j)*n3(j)
       t1 = zx1(j)*n1(j) + zy1(j)*n2(j) + zu1(j)*n3(j)
       t2 = zx2(j)*n1(j) + zy2(j)*n2(j) + zu2(j)*n3(j)

       term = (c*a(j))*(2.*t0 + t1 + t2)
       rx0(j) = rx0(j) - term*n1(j)
       ry0(j) = ry0(j) - term*n2(j)
       ru0(j) = ru0(j) - term*n3(j)

       term = (c*a(j))*(t0 + 2.*t1 + t2)
       rx1(j) = rx1(j) - term*n1(j)
       ry1(j) = ry1(j) - term*n2(j)
       ru1(j) = ru1(j) - term*n3(j)

       term = (c*a(j))*(t0 + t1 + 2.*t2)
       rx2(j) = rx2(j) - term*n1(j)
       ry2(j) = ry2(j) - term*n2(j)
       ru2(j) = ru2(j) - term*n3(j)
   10 continue

      return
      end
