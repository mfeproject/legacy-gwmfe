      subroutine pderhs(n)
************************************************************************
*
*   PDERHS -- RHS inner products.
*
*   RHS inner products for two phase incompressible flow through
*   a porous medium.
*
*            ds/dt = PSCF*F(s)*Grad(s)*Grad(P) + VISC*Lapl(s)
*
*        eps*dP/dt = Div(G(s)*Grad(P))
*
*                  = G'(s)*Grad(s)*Grad(P) + G(s)*Lapl(P)
*
*   where      F(s) = 2*MURATIO*s*(1 - s)/G(s)
*              G(s) = s**2 + MURATIO*(1 - s)**2
*
*   p = PSCF*P is the pressure.
*
************************************************************************
      double precision wpde,muratio,visc,eps,usera
      common /mfe020/ wpde(2) /mfe100/ muratio,visc,eps,usera(22)

      double precision s0,p0,x0,y0,s1,p1,x1,y1,s2,p2,x2,y2
      common /loc010/ s0(65),p0(65),x0(65),y0(65),
     +                s1(65),p1(65),x1(65),y1(65),
     +                s2(65),p2(65),x2(65),y2(65)

      double precision gs0,gp0,gx0,gy0,gs1,gp1,gx1,gy1,gs2,gp2,gx2,gy2
      common /loc012/ gs0(65),gp0(65),gx0(65),gy0(65),
     +                gs1(65),gp1(65),gx1(65),gy1(65),
     +                gs2(65),gp2(65),gx2(65),gy2(65)

      double precision a,n1,n2,n3
      common /loc020/ a(65,2) /loc021/ n1(65,2),n2(65,2),n3(65,2)

      double precision ayu,aux,axy
      common /loc022/ ayu(65,2),aux(65,2),axy(65)

      double precision g7w,g7a0,g7a1,g7a2
      common /g2d7/ g7w(7),g7a0(7),g7a1(7),g7a2(7)

      double precision pscf
      common /data1/ pscf

      integer n,j,k
      double precision g,f,s,gm0,gm1,gm2,c1,c2
      double precision h0,h1,h2,gpa0,gpa1,gpa2,tmp,term1,term2
      double precision ga(65,0:2,0:2),fa0(65),fa1(65),fa2(65)
      equivalence (fa0,ga(1,0,0)),(fa1,ga(1,1,1)),(fa2,ga(1,2,2))
*     ==================================================================
*      Function definitions.
*     ==================================================================
      g(s) = s**2 + muratio*(1. - s)**2
      f(s) = 2*muratio*s*(1. - s)/g(s)
*     ==================================================================
*      Averages of F(s)*alphas by 7-pt Gauss quadrature.
*     ==================================================================
      do 10 j=1,n
       fa0(j) = 0.
       fa1(j) = 0.
       fa2(j) = 0.
   10 continue

      do 20 k=1,7
      do 20 j=1,n
       s = g7a0(k)*s0(j) + g7a1(k)*s1(j) + g7a2(k)*s2(j)
       fa0(j) = fa0(j) + f(s)*(g7w(k)*g7a0(k))
       fa1(j) = fa1(j) + f(s)*(g7w(k)*g7a1(k))
       fa2(j) = fa2(j) + f(s)*(g7w(k)*g7a2(k))
   20 continue
*     ==================================================================
*      Averages of (1/eps)*G(s)*alphas on edges by Simpson's rule.
*     ==================================================================
      do 30 j=1,n
*      G(s) at the edge midpoints.
       gm0 = g((s1(j) + s2(j))/2.)
       gm1 = g((s2(j) + s0(j))/2.)
       gm2 = g((s0(j) + s1(j))/2.)
     
*      Averages; exact quadrature.
       ga(j,0,1) = (g(s0(j)) + 2.*gm1)/(6.*eps)
       ga(j,0,2) = (g(s0(j)) + 2.*gm2)/(6.*eps)
       ga(j,1,2) = (g(s1(j)) + 2.*gm2)/(6.*eps)
       ga(j,1,0) = (g(s1(j)) + 2.*gm0)/(6.*eps)
       ga(j,2,0) = (g(s2(j)) + 2.*gm0)/(6.*eps)
       ga(j,2,1) = (g(s2(j)) + 2.*gm1)/(6.*eps)
   30 continue
*     ==================================================================
*      Load the inner products.
*     ==================================================================
      c1 = wpde(1)*pscf
      c2 = wpde(2)/eps

      do 40 j=1,n
       h0 = s0(j) - muratio*(1. - s0(j))
       h1 = s1(j) - muratio*(1. - s1(j))
       h2 = s2(j) - muratio*(1. - s2(j))

       gpa0 = (2.*h0 + h1 + h2)/6.
       gpa1 = (2.*h1 + h2 + h0)/6.
       gpa2 = (2.*h2 + h0 + h1)/6.

       tmp = (ayu(j,1)*ayu(j,2) + aux(j,1)*aux(j,2))/axy(j)

       term1 = c1*tmp*fa0(j)
       term2 = c2*tmp*gpa0
       gx0(j) = term1*n1(j,1) + term2*n1(j,2)
       gy0(j) = term1*n2(j,1) + term2*n2(j,2)
       gs0(j) = term1*n3(j,1)
       gp0(j) = term2*n3(j,2)

       term1 = c1*tmp*fa1(j)
       term2 = c2*tmp*gpa1
       gx1(j) = term1*n1(j,1) + term2*n1(j,2)
       gy1(j) = term1*n2(j,1) + term2*n2(j,2)
       gs1(j) = term1*n3(j,1)
       gp1(j) = term2*n3(j,2)

       term1 = c1*tmp*fa2(j)
       term2 = c2*tmp*gpa2
       gx2(j) = term1*n1(j,1) + term2*n1(j,2)
       gy2(j) = term1*n2(j,1) + term2*n2(j,2)
       gs2(j) = term1*n3(j,1)
       gp2(j) = term2*n3(j,2)
   40 continue

      call lapl(n,1,visc)
      call laplvc(n,2,ga)

      return
      end
      subroutine pressure(y,bandw,a)
************************************************************************
*
*   PRESSURE -- Solve the pressure equation.
*
************************************************************************
      include "parameters.h"

      integer nepn
      parameter(nepn=npde+2)

      integer nnod,ntri,tvtx
      common /mfe010/ nnod,ntri /mfe011/ tvtx(0:2,mtri)

      double precision bv
      integer nbnod,bnod,bc
      common /mfe030/ bv(nepn,mbnd),nbnod,bnod(2,mbnd),bc(nepn,10)

      double precision muratio,visc,eps,usera
      common /mfe100/ muratio,visc,eps,usera(22)

      integer bandw,i,j,vtx0,vtx1,vtx2,jbnod,jbc
      double precision y(nepn,nnod),a(0:bandw,nnod),b(mnod)
      double precision s0,x0,y0,s1,x1,y1,s2,x2,y2
      double precision dx0,dx1,dx2,dy0,dy1,dy2,area
      double precision a00,a10,a20,a11,a21,a22,gavg,g,s,bval

*     Conductivity function.
      g(s) = s**2 + muratio*(1. - s)**2

*     ==================================================================
*      Zero the storage for the stiffness matrix and RHS vector.
*     ==================================================================
      do 110 i=0,bandw
      do 110 j=1,nnod
  110 a(i,j) = 0.

      do 120 j=1,nnod
  120 b(j) = 0.
*     ==================================================================
*      Compute the stiffness matrix.
*     ==================================================================
      do 200 j=1,ntri
        vtx0 = tvtx(0,j)
        vtx1 = tvtx(1,j)
        vtx2 = tvtx(2,j)

*       Gather the local variables.
        s0 = y(1,vtx0)
        x0 = y(3,vtx0)
        y0 = y(4,vtx0)
        s1 = y(1,vtx1)
        x1 = y(3,vtx1)
        y1 = y(4,vtx1)
        s2 = y(1,vtx2)
        x2 = y(3,vtx2)
        y2 = y(4,vtx2)

*       Differences along the edges and triangle area.
        dx0 = x2 - x1
        dx1 = x0 - x2
        dx2 = x1 - x0
        dy0 = y2 - y1
        dy1 = y0 - y2
        dy2 = y1 - y0
        area = .5*(dx1*dy2 - dx2*dy1)

*       Average of the "conductivity" over the triangle.
        gavg = (g(.5*(s0+s1)) + g(.5*(s1+s2)) + g(.5*(s2+s0)))/3.

*       Lower triangular elements of the local stiffness matrix.
        a00 = (gavg*.25/area)*(dx0*dx0 + dy0*dy0)
        a10 = (gavg*.25/area)*(dx1*dx0 + dy1*dy0)
        a20 = (gavg*.25/area)*(dx2*dx0 + dy2*dy0)
        a11 = (gavg*.25/area)*(dx1*dx1 + dy1*dy1)
        a21 = (gavg*.25/area)*(dx2*dx1 + dy2*dy1)
        a22 = (gavg*.25/area)*(dx2*dx2 + dy2*dy2)

*       Scatter the local stiffness matrix.
        a(0,vtx0) = a(0,vtx0) + a00
        a(0,vtx1) = a(0,vtx1) + a11
        a(0,vtx2) = a(0,vtx2) + a22

        if(vtx1 .gt. vtx0) then
         a(vtx1-vtx0,vtx0) = a(vtx1-vtx0,vtx0) + a10
        else
         a(vtx0-vtx1,vtx1) = a(vtx0-vtx1,vtx1) + a10
         endif

        if(vtx2 .gt. vtx0) then
         a(vtx2-vtx0,vtx0) = a(vtx2-vtx0,vtx0) + a20
        else
         a(vtx0-vtx2,vtx2) = a(vtx0-vtx2,vtx2) + a20
         endif

        if(vtx2 .gt. vtx1) then
         a(vtx2-vtx1,vtx1) = a(vtx2-vtx1,vtx1) + a21
        else
         a(vtx1-vtx2,vtx2) = a(vtx1-vtx2,vtx2) + a21
         endif
  200 continue
*     ==================================================================
*      Modify the equations for Dirichlet boundary conditions.
*     ==================================================================
      do 300 j=1,nbnod

        jbnod = bnod(1,j)
        jbc   = bnod(2,j)
        if(bc(2,jbc) .ne. 1) go to 300

        bval = bv(2,j)

        do 320 i=1,min(bandw,nnod-jbnod)
         b(jbnod+i) = b(jbnod+i) - bval*a(i,jbnod)
         a(i,jbnod) = 0.0
  320   continue

        do 310 i=1,min(bandw,jbnod-1)
         b(jbnod-i) = b(jbnod-i) - bval*a(i,jbnod-i)
         a(i,jbnod-i) = 0.0
  310   continue

        a(0,jbnod) = 1.0
        b(jbnod) = bval

  300 continue
*     ==================================================================
*      Solve the equations.
*     ==================================================================
      call sbfct(nnod,bandw,a)
      call sbslv(nnod,bandw,a,b)

*     Store the solution.
      do 400 j=1,nnod
  400 y(2,j) = b(j)

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
