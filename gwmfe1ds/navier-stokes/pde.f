      subroutine pderhs(t)
************************************************************************
*
*   Inner products for gasdynamics.
*
*     u1(.,1) == mass density,
*     u2(.,2) == momentum density,
*     u3(.,3) == total energy density (internal plus kinetic)
*
*   Each equation is in conservation law form
*
*     du/dt = -df/dx + visc* d2u/dx2
*
************************************************************************
      include "parameters.h"
      
      double precision wpde
      integer nnod,nelt
      common /mfe010/ nnod,nelt /mfe020/ wpde(npde)

      double precision u0,x0,u1,x1
      common /loc10/ u0(mnod,npde),x0(mnod),u1(mnod,npde),x1(mnod)

      double precision gu0,gx0,gu1,gx1
      common /loc12/ gu0(mnod,npde),gx0(mnod),gu1(mnod,npde),gx1(mnod)

      double precision l,n1,n2
      common /loc30/ l(mnod,npde),n1(mnod,npde),n2(mnod,npde)

      double precision visc,usera
      common /mfe100/ visc,usera(24)

      integer j,k
      double precision t,c1,c2,u(mnod,npde),f(mnod,npde)
      double precision f0(mnod,npde),f1(mnod,npde),favg(mnod,npde)
      equivalence (u,f0),(f,f1)
      parameter(c1=1.d0/6.d0,c2=4.d0/6.d0)
*     ==================================================================
*      Average fluxes using Simpson's rule.
*     ==================================================================
*     Variables at the midpoint.
      do 110 k=1,npde
      do 110 j=1,nelt
  110 u(j,k) = .5d0*(u0(j,k) + u1(j,k))

*     Fluxes at midpoint.
      call fluxes(nelt,u,  f)
      do 120 k=1,npde
      do 120 j=1,nelt
  120 favg(j,k) = c2*f(j,k)

*     Fluxes at left endpoint.
      call fluxes(nelt,u0,  f0)
      do 130 k=1,npde
      do 130 j=1,nelt
  130 favg(j,k) = favg(j,k) + c1*f0(j,k)

*     Fluxes at right endpoint.
      call fluxes(nelt,u1,  f1)
      do 140 k=1,npde
      do 140 j=1,nelt
  140 favg(j,k) = favg(j,k) + c1*f1(j,k)
*     ==================================================================
*      Load the inner products.
*     ==================================================================
      do 210 j=1,nelt
       gx0(j) = 0.d0
       gx1(j) = 0.d0
  210 continue

      do 220 k=1,npde
      do 220 j=1,nelt
       gx0(j) = gx0(j) - (wpde(k)*(favg(j,k)-f0(j,k)))*n1(j,k)
       gu0(j,k) =      - (wpde(k)*(favg(j,k)-f0(j,k)))*n2(j,k)

       gx1(j) = gx1(j) - (wpde(k)*(f1(j,k)-favg(j,k)))*n1(j,k)
       gu1(j,k) =      - (wpde(k)*(f1(j,k)-favg(j,k)))*n2(j,k)
  220 continue

      call lapl(1,visc)
      call lapl(2,visc)
      call lapl(3,visc)

      return
      end
      
      
      
      subroutine fluxes(n,u,  f)
***************************************************************
*
*   FLUXES --  Fluxes for gasdynamics.
*
*     u1 = mass density,
*     u2 = momentum density,
*     u3 = total energy density (internal plus kinetic)
*
*     Each equation is in conservation law form
*     du/dt = - df/dx + visc* d2u/dx2
*
***************************************************************
      include "parameters.h"

      integer n,j
      double precision u(mnod,npde),f(mnod,npde)
      double precision gamma,c1,c2,c3,c4

      parameter(gamma = 1.4d0, c1 = (3.d0 - gamma)/2.d0,
     +                         c2 = gamma - 1.d0,
     +                         c3 = (1.d0 - gamma)/2.d0,
     +                         c4 = gamma)

      do 10 j=1,n
*      Mass flux (equation 1).
       f(j,1) = u(j,2)

*      Momentum flux (equation 2).
       f(j,2) = c1*u(j,2)*(u(j,2)/u(j,1)) + c2*u(j,3)

*      Energy flux (equation 3).
       f(j,3) = (c3*u(j,2)*(u(j,2)/u(j,1)) + c4*u(j,3))*(u(j,2)/u(j,1))
   10 continue

      return
      end
