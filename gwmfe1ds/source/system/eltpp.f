      subroutine eltpp(errc)
************************************************************************
*
*   ELTPP -- Element term pre-processor.
*
************************************************************************
      include "parameters.h"

      integer nnod,nelt
      common /mfe010/ nnod,nelt

      double precision fdinc,dxmin
      common /mfe022/ fdinc,dxmin

      double precision u0,x0,u1,x1
      common /loc10/ u0(mnod,npde),x0(mnod),u1(mnod,npde),x1(mnod)

      double precision l,n1,n2,du,dx
      common /loc30/ l(mnod,npde),n1(mnod,npde),n2(mnod,npde)
      common /loc31/ du(mnod,npde),dx(mnod)

      double precision dx2(mnod)
      integer errc,j,k

      do 10 j=1,nelt
       dx(j) = x1(j) - x0(j)
       if(dx(j) .lt. dxmin) then
         errc = j
         return
         endif
       dx2(j) = dx(j)**2
   10 continue

      do 20 k=1,npde
      do 20 j=1,nelt
       du(j,k) = u1(j,k) - u0(j,k)
       l(j,k) = sqrt(du(j,k)**2 + dx2(j))
       n1(j,k) = -du(j,k)/l(j,k)
       n2(j,k) = dx(j)/l(j,k)
   20 continue

      errc = 0
      return
      end
