      subroutine ares(n)
************************************************************************
*
*   ARES -- MFE mass matrix contribution to the residual.
*
************************************************************************
      include "parameters.h"

      double precision wpde
      common /mfe020/ wpde(npde)

      double precision zu0,zx0,zy0,zu1,zx1,zy1,zu2,zx2,zy2
      double precision ru0,rx0,ry0,ru1,rx1,ry1,ru2,rx2,ry2
      common /loc011/ zu0(65,npde),zx0(65),zy0(65),
     +                zu1(65,npde),zx1(65),zy1(65),
     +                zu2(65,npde),zx2(65),zy2(65)
      common /loc012/ ru0(65,npde),rx0(65),ry0(65),
     +                ru1(65,npde),rx1(65),ry1(65),
     +                ru2(65,npde),rx2(65),ry2(65)

      double precision a,n1,n2,n3
      common /loc020/ a(65,npde)
      common /loc021/ n1(65,npde),n2(65,npde),n3(65,npde)

      integer n,j,k
      double precision c,t0,t1,t2,term

      do 10 k=1,npde
      c = wpde(k)/12.
      do 10 j=1,n
       t0 = zx0(j)*n1(j,k) + zy0(j)*n2(j,k) + zu0(j,k)*n3(j,k)
       t1 = zx1(j)*n1(j,k) + zy1(j)*n2(j,k) + zu1(j,k)*n3(j,k)
       t2 = zx2(j)*n1(j,k) + zy2(j)*n2(j,k) + zu2(j,k)*n3(j,k)

       term = (c*a(j,k))*(2.*t0 + t1 + t2)
       rx0(j)   = rx0(j)   - term*n1(j,k)
       ry0(j)   = ry0(j)   - term*n2(j,k)
       ru0(j,k) = ru0(j,k) - term*n3(j,k)

       term = (c*a(j,k))*(t0 + 2.*t1 + t2)
       rx1(j)   = rx1(j)   - term*n1(j,k)
       ry1(j)   = ry1(j)   - term*n2(j,k)
       ru1(j,k) = ru1(j,k) - term*n3(j,k)

       term = (c*a(j,k))*(t0 + t1 + 2.*t2)
       rx2(j)   = rx2(j)   - term*n1(j,k)
       ry2(j)   = ry2(j)   - term*n2(j,k)
       ru2(j,k) = ru2(j,k) - term*n3(j,k)
   10 continue

      return
      end
