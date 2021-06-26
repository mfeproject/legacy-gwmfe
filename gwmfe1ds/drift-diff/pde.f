      subroutine pderhs(t)
************************************************************************
*
*   PDERHS -- RHS inner products on elements.
*
*   RHS inner products for the single carrier semiconductor equations
*   where the hole density is given by p = exp(SCF*U) and the voltage
*   is v = VSCF*V.  The equations for U and V are
*
*      dU/dt = Grad(U)*(VSCF*Grad(V) + LAMBDA*USCF*Grad(U))
*
*               + (1 - exp(USCF*U))/USCF + LAMBDA*Lapl(U)
*
*      dV/dt = (1/EPS)*(Lapl(V) - (1 - exp(USCF*U))/VSCF)
*
*   LAMBDA and EPS are parameters and USCF and VSCF are scaling factors.
*
************************************************************************
      include "parameters.h"
      
      double precision wpde
      integer nnod,nelt
      common /mfe010/ nnod,nelt /mfe020/ wpde(npde)

      double precision lambda0,eps,uscf,vscf,usera
      common /mfe100/ lambda0,eps,uscf,vscf,usera(21)

      double precision u0,x0,u1,x1
      common /loc10/ u0(mnod,npde),x0(mnod),u1(mnod,npde),x1(mnod)

      double precision gu0,gx0,gu1,gx1
      common /loc12/ gu0(mnod,npde),gx0(mnod),gu1(mnod,npde),gx1(mnod)

      double precision l,n1,n2,du,dx
      common /loc30/ l(mnod,npde),n1(mnod,npde),n2(mnod,npde)
      common /loc31/ du(mnod,npde),dx(mnod)

      double precision g3w,g3a0,g3a1
      common /g1d3/ g3w(3),g3a0(3),g3a1(3)

      integer j
      double precision t,c1,c2,c3,c4,pa0,pa1,term1,term2,lambda

      if(t .le. 40.d0) then
       lambda = lambda0
      else
       lambda = lambda0 / 10.**((t-40.)/100.)
      end if

      c1 = .5*wpde(1)*vscf
      c2 = .5*wpde(1)*uscf*lambda
      c3 = wpde(1)/uscf
      c4 = -wpde(2)/(eps*vscf)

      do 10 j=1,nelt
*      =================================================================
*       Average of p*alphas by 3 pt Gauss quadrature.
*      =================================================================
       pa0 = g3w(1)*g3a0(1)*exp(uscf*(g3a0(1)*u0(j,1)+g3a1(1)*u1(j,1)))
     +     + g3w(2)*g3a0(2)*exp(uscf*(g3a0(2)*u0(j,1)+g3a1(2)*u1(j,1)))
     +     + g3w(3)*g3a0(3)*exp(uscf*(g3a0(3)*u0(j,1)+g3a1(3)*u1(j,1)))

       pa1 = g3w(1)*g3a1(1)*exp(uscf*(g3a0(1)*u0(j,1)+g3a1(1)*u1(j,1)))
     +     + g3w(2)*g3a1(2)*exp(uscf*(g3a0(2)*u0(j,1)+g3a1(2)*u1(j,1)))
     +     + g3w(3)*g3a1(3)*exp(uscf*(g3a0(3)*u0(j,1)+g3a1(3)*u1(j,1)))
*      =================================================================
*       Load the inner products.
*      =================================================================
       term1 = du(j,1)*(c1*du(j,2) + c2*du(j,1))/dx(j)
       term2 = dx(j)*(.5 - pa0)
       gx0(j) = (term1 + c3*term2)*n1(j,1) + (c4*term2)*n1(j,2)
       gu0(j,1) = (term1 + c3*term2)*n2(j,1)
       gu0(j,2) = (c4*term2)*n2(j,2)

       term2 = dx(j)*(.5 - pa1)
       gx1(j) = (term1 + c3*term2)*n1(j,1) + (c4*term2)*n1(j,2)
       gu1(j,1) = (term1 + c3*term2)*n2(j,1)
       gu1(j,2) = (c4*term2)*n2(j,2)
   10 continue

      call lapl(1,lambda)
      call lapl(2,1.d0/eps)

      return
      end
      block data
************************************************************************
*
*   Quadrature formula:
*
*   G1D3 -- 3 point 1D Gaussian quadrature formula.  Fifth order
*   accurate.  The weights are g3w(.) and the corresponding quadrature
*   points are (g3a0(.), g3a1(.)) given as the isoparametric coordinates
*   (alpha_0, alpha_1) of the interval.
*
************************************************************************
      double precision g3w,g3a0,g3a1
      common /g1d3/ g3w(3),g3a0(3),g3a1(3)

      integer k

      data g3w/
     + 2.77777777777778d-1,4.44444444444444d-1,2.77777777777778d-1/
      data (g3a0(k),g3a1(k),k=1,3)/
     + 1.12701665379259d-1, 8.87298334620741d-1,
     + 5.00000000000000d-1, 5.00000000000000d-1,
     + 8.87298334620741d-1, 1.12701665379259d-1/
 
      end
