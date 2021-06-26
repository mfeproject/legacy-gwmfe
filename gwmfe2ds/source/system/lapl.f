      subroutine lapl(n,ieq,visc)
************************************************************************
*
*   LAPL --
*
************************************************************************
      include "parameters.h"

      integer nepn,xeq,yeq
      parameter(nepn=npde+2,xeq=npde+1,yeq=npde+2)

      double precision wpde
      common /mfe020/ wpde(npde)

      double precision g,du,l,dudn
      common /loc012/ g(65,nepn,0:2)
      common /loc023/ du(65,nepn,0:2)
      common /loc040/ l(65,0:2) /loc041/ dudn(65,npde,0:2)

      integer n,ieq,k,kp1,km1,j
      double precision visc,c,dudt,dS,dS0,e,i1,i2,term

*     Taylor expansion of .5*log((1+e)/(1-e)).
      double precision eta,c3,c5,c7,expan
      parameter(eta=1.e-2,c3=1./3.,c5=1./5.,c7=1./7.)
      expan(e) = e*(1. + (e**2)*(c3 + (e**2)*(c5 + c7*(e**2))))

      c = .5*visc*wpde(ieq)

      do 10 k=0,2

      kp1 = mod(k+1, 3)
      km1 = mod(k+2, 3)

      do 10 j=1,n
       dudt = du(j,ieq,k)/l(j,k)
       dS0 = sqrt(1. + dudt**2)
       dS  = sqrt(1. + dudt**2 + dudn(j,ieq,k)**2)

*      Compute I2.
       i2 = dudn(j,ieq,k)**2/(dS + dS0)

*      Compute I1.
       e = dudn(j,ieq,k)/dS
       if(abs(e) .gt. eta) then
        i1 = sign(log((abs(dudn(j,ieq,k))+dS)/dS0), dudn(j,ieq,k))
       else
        i1 = expan(e)
        endif

*      Load the inner products.
       term = c*l(j,k)*i1
       g(j,ieq,kp1) = g(j,ieq,kp1) - term
       g(j,ieq,km1) = g(j,ieq,km1) - term

       term = c*( i2*du(j,yeq,k) + dudt*i1*du(j,xeq,k))
       g(j,xeq,kp1) = g(j,xeq,kp1) + term
       g(j,xeq,km1) = g(j,xeq,km1) + term

       term = c*(-i2*du(j,xeq,k) + dudt*i1*du(j,yeq,k))
       g(j,yeq,kp1) = g(j,yeq,kp1) + term
       g(j,yeq,km1) = g(j,yeq,km1) + term
   10 continue

      return
      end
