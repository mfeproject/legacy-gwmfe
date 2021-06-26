      subroutine laplvc(n,dalpha)
************************************************************************
*
*   LAPLVC --
*
************************************************************************
      double precision g,du,l,dudn
      common /loc012/ g(65,3,0:2)
      common /loc023/ du(65,3,0:2)
      common /loc040/ l(65,0:2) /loc041/ dudn(65,0:2)

      integer n,k,kp1,km1,j
      double precision dalpha(65,0:2,0:2),dudt,dS,dS0,e,i1,i2,term

*     Taylor expansion of .5*log((1+e)/(1-e)).
      double precision eta,c3,c5,c7,expan
      parameter(eta=1.e-2,c3=1./3.,c5=1./5.,c7=1./7.)
      expan(e) = e*(1. + (e**2)*(c3 + (e**2)*(c5 + c7*(e**2))))

      do 10 k=0,2

      kp1 = mod(k+1, 3)
      km1 = mod(k+2, 3)

      do 10 j=1,n
       dudt = du(j,1,k)/l(j,k)
       dS0 = sqrt(1. + dudt**2)
       dS  = sqrt(1. + dudt**2 + dudn(j,k)**2)

*      Compute I2.
       i2 = dudn(j,k)**2/(dS + dS0)

*      Compute I1.
       e = dudn(j,k)/dS
       if(abs(e) .gt. eta) then
        i1 = sign(log((abs(dudn(j,k))+dS)/dS0), dudn(j,k))
       else
        i1 = expan(e)
        endif

*      Load the inner products.
       term = l(j,k)*i1
       g(j,1,kp1) = g(j,1,kp1) - dalpha(j,kp1,k)*term
       g(j,1,km1) = g(j,1,km1) - dalpha(j,km1,k)*term

       term = ( i2*du(j,3,k) + dudt*i1*du(j,2,k))
       g(j,2,kp1) = g(j,2,kp1) + dalpha(j,kp1,k)*term
       g(j,2,km1) = g(j,2,km1) + dalpha(j,km1,k)*term

       term = (-i2*du(j,2,k) + dudt*i1*du(j,3,k))
       g(j,3,kp1) = g(j,3,kp1) + dalpha(j,kp1,k)*term
       g(j,3,km1) = g(j,3,km1) + dalpha(j,km1,k)*term
   10 continue

      return
      end
