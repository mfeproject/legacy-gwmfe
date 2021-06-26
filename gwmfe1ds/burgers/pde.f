      subroutine pderhs(t)
************************************************************************
*
*   PDERHS -- RHS inner product for Burgers' equation with source
*
*      du/dt = -uscf*u*du/dx + visc^{-1}*g(u) + visc*d2u/dx2.
*
************************************************************************
      include "parameters.h"

      integer nnod,nelt
      common /mfe010/ nnod,nelt

      double precision visc,uscf,cg,usera
      common /mfe100/ visc,uscf,cg,usera(22)

      double precision u0,x0,u1,x1
      common /loc10/ u0(mnod),x0(mnod),u1(mnod),x1(mnod)

      double precision gu0,gx0,gu1,gx1
      common /loc12/ gu0(mnod),gx0(mnod),gu1(mnod),gx1(mnod)

      double precision l,n1,n2,du,dx
      common /loc30/ l(mnod),n1(mnod),n2(mnod) /loc31/ du(mnod),dx(mnod)

      double precision g5w,g5a0,g5a1
      common /g1d5/ g5w(5),g5a0(5),g5a1(5)

      integer j,k
      double precision t,c,g,u,gu,gua0,gua1

*     Source function
      g(u) = u**2 * (1.d0 - u)**6

      c = -uscf/6.d0
      do 10 j=1,nelt
       gx0(j) = ((c*du(j))*(2.d0*u0(j)+u1(j)))*n1(j)
       gu0(j) = ((c*du(j))*(2.d0*u0(j)+u1(j)))*n2(j)
       gx1(j) = ((c*du(j))*(2.d0*u1(j)+u0(j)))*n1(j)
       gu1(j) = ((c*du(j))*(2.d0*u1(j)+u0(j)))*n2(j)
   10 continue
   
      if (cg .gt. 0.0d0) then
        c = 256.d0*cg/(visc*uscf)
        do 20 j=1,nelt
*        Average of g(u)*alphas by 3 pt Gauss quadrature.
         gua0 = 0.d0
         gua1 = 0.d0
         do 21 k=1,5
          gu = g(uscf*(g5a0(k)*u0(j)+g5a1(k)*u1(j)))
          gua0 = gua0 + g5w(k)*g5a0(k)*gu
          gua1 = gua1 + g5w(k)*g5a1(k)*gu
   21    continue
         gx0(j) = gx0(j) + ((c*dx(j))*gua0)*n1(j)
         gu0(j) = gu0(j) + ((c*dx(j))*gua0)*n2(j)
         gx1(j) = gx1(j) + ((c*dx(j))*gua1)*n1(j)
         gu1(j) = gu1(j) + ((c*dx(j))*gua1)*n2(j)
   20   continue
      end if

      call lapl(1,visc)

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
      double precision g3w,g3a0,g3a1,g5w,g5a0,g5a1
      common /g1d3/ g3w(3),g3a0(3),g3a1(3)
      common /g1d5/ g5w(5),g5a0(5),g5a1(5)

      integer k

      data g3w/
     + 2.77777777777778d-1,4.44444444444444d-1,2.77777777777778d-1/
      data (g3a0(k),g3a1(k),k=1,3)/
     + 1.12701665379259d-1, 8.87298334620741d-1,
     + 5.00000000000000d-1, 5.00000000000000d-1,
     + 8.87298334620741d-1, 1.12701665379259d-1/
 
      data g5w/0.118463442528094d0,
     +         0.239314335249683d0,
     +         0.284444444444444d0,
     +         0.239314335249683d0,
     +         0.118463442528095d0/

      data (g5a0(k),g5a1(k),k=1,5)/
     +         0.046910077030668d0, 0.953089922969332d0,
     +         0.230765344947158d0, 0.769234655052841d0,
     +         0.5d0,               0.5d0,
     +         0.769234655052841d0, 0.230765344947158d0,
     +         0.953089922969332d0, 0.046910077030668d0/

      end
