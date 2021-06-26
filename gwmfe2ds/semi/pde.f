      subroutine pderhs(n)
************************************************************************
*
*   PDERHS -- RHS inner products.
*
*   RHS inner products for the single carrier semiconductor equations.
*   We make the transformation
*
*      p(x,t) = Exp[USCF*U(x,t)].
*
*   The equations for U and the scaled voltage V = v/VSCF are
*
*      dU/dt = (VSCF*Grad[V] + LAMBDA*USCF*Grad[U])*Grad[U]
*
*            + (1 - p)/USCF + LAMBDA*Lapl[U]
*
*      dV/dt = (1/EPS)*(Lapl[V] - (1 - p)/VSCF)
*
************************************************************************
      include "parameters.h"

      double precision g7w,g7a0,g7a1,g7a2
      common /g2d7/ g7w(7),g7a0(7),g7a1(7),g7a2(7)

      double precision uscf,vscf
      common /data1/ uscf,vscf

      double precision wpde,lambda,eps,usera
      common /mfe020/ wpde(npde) /mfe100/ lambda,eps,usera(23)

      double precision u0,v0,x0,y0,u1,v1,x1,y1,u2,v2,x2,y2
      common /loc010/ u0(65),v0(65),x0(65),y0(65),
     +                u1(65),v1(65),x1(65),y1(65),
     +                u2(65),v2(65),x2(65),y2(65)

      double precision gu0,gv0,gx0,gy0,gu1,gv1,gx1,gy1,gu2,gv2,gx2,gy2
      common /loc012/ gu0(65),gv0(65),gx0(65),gy0(65),
     +                gu1(65),gv1(65),gx1(65),gy1(65),
     +                gu2(65),gv2(65),gx2(65),gy2(65)

      double precision a,n1,n2,n3,ayu,aux,axy
      common /loc020/ a(65,npde)
      common /loc021/ n1(65,npde),n2(65,npde),n3(65,npde)
      common /loc022/ ayu(65,npde),aux(65,npde),axy(65)

      integer n,j,k
      double precision ba0(65),ba1(65),ba2(65),bofp
      double precision p(65),c1,c2,c3,c4,tmp1,tmp2,term1,term2
*     ==================================================================
*      Averages of B(p) = 1 - p times alphas by 7-pt Gauss quad.
*     ==================================================================
      do 10 j=1,n
       ba0(j) = 0.
       ba1(j) = 0.
       ba2(j) = 0.
   10 continue

*     7-point Gaussian quadrature.
      do 20 k=1,7

      do 21 j=1,n
   21 p(j) = exp(uscf*(u0(j)*g7a0(k) + u1(j)*g7a1(k) + u2(j)*g7a2(k)))

      do 20 j=1,n
       bofp = 1. - p(j)

       ba0(j) = ba0(j) + bofp*(g7w(k)*g7a0(k))
       ba1(j) = ba1(j) + bofp*(g7w(k)*g7a1(k))
       ba2(j) = ba2(j) + bofp*(g7w(k)*g7a2(k))
   20 continue
*     ==================================================================
*      Load the inner products.
*     ==================================================================
      c1 = wpde(1)*vscf/3.
      c2 = wpde(1)*uscf*lambda/3.
      c3 = wpde(1)/uscf
      c4 = -wpde(2)/(eps*vscf)

      do 40 j=1,n
       tmp1  = c1*(ayu(j,1)*ayu(j,2) + aux(j,1)*aux(j,2))/axy(j)
       tmp2  = c2*(ayu(j,1)*ayu(j,1) + aux(j,1)*aux(j,1))/axy(j)
       term1 = tmp1 + tmp2 + c3*axy(j)*ba0(j)
       term2 = c4*axy(j)*ba0(j)
       gx0(j) = term1*n1(j,1) + term2*n1(j,2)
       gy0(j) = term1*n2(j,1) + term2*n2(j,2)
       gu0(j) = term1*n3(j,1)
       gv0(j) = term2*n3(j,2)

       term1 = tmp1 + tmp2 + c3*axy(j)*ba1(j)
       term2 = c4*axy(j)*ba1(j)
       gx1(j) = term1*n1(j,1) + term2*n1(j,2)
       gy1(j) = term1*n2(j,1) + term2*n2(j,2)
       gu1(j) = term1*n3(j,1)
       gv1(j) = term2*n3(j,2)

       term1 = tmp1 + tmp2 + c3*axy(j)*ba2(j)
       term2 = c4*axy(j)*ba2(j)
       gx2(j) = term1*n1(j,1) + term2*n1(j,2)
       gy2(j) = term1*n2(j,1) + term2*n2(j,2)
       gu2(j) = term1*n3(j,1)
       gv2(j) = term2*n3(j,2)
   40 continue

      call lapl(n,1,lambda)
      call lapl(n,2,1.0d0/eps)

      return
      end
      block data
************************************************************************
*
*   Quadrature formula:
*
*   G2D7 -- 7 point 2D Gaussian quadrature formula.  Fifth order
*   accurate.  The weights are g7w(.) and the corresponding quadrature
*   points are (g7a0(.), g7a1(.), g7a2(.)), given as the isoparametric
*   coordinates (alpha_0, alpha_1, alpha_2) of the triangle.
*
************************************************************************
      double precision g7w,g7a0,g7a1,g7a2
      common /g2d7/ g7w(7),g7a0(7),g7a1(7),g7a2(7)

      integer k

      data g7w/.225e0,
     + 1.323941527885062e-1, 1.323941527885062e-1, 1.323941527885062e-1,
     + 1.259391805448271e-1, 1.259391805448271e-1, 1.259391805448271e-1/
      data (g7a0(k),g7a1(k),g7a2(k),k=1,7)/
     + 3.333333333333333e-1, 3.333333333333333e-1, 3.333333333333333e-1,
     + 5.971587178976982e-2, 4.701420641051151e-1, 4.701420641051151e-1,
     + 4.701420641051151e-1, 5.971587178976982e-2, 4.701420641051151e-1,
     + 4.701420641051151e-1, 4.701420641051151e-1, 5.971587178976982e-2,
     + 7.974269853530873e-1, 1.012865073234563e-1, 1.012865073234563e-1,
     + 1.012865073234563e-1, 7.974269853530873e-1, 1.012865073234563e-1,
     + 1.012865073234563e-1, 1.012865073234563e-1, 7.974269853530873e-1/

      end
