      subroutine pderhs(n)
************************************************************************
*
*   PDERHS -- RHS inner products over triangles.
*
*   RHS inner products for Kent Smith's arsenic diffusion problem,
*   using the transformation
*
*      USCF*U(x,T) + GAMMA = C(x,t)/MU + log(C(x,t)/MU)
*
*   where C(x,t) is the scaled concentration of arsenic, USCF is
*   the scaling factor for U and the scaled time T = t/TSCF.  The
*   equation for U is
*
*      dU/dT = TSCF*A(C)*Lapl(U) + (TSCF*USCF)*B(C)*|Grad(U)|**2
*
*   where
*
*      A(C) = N(C)*(D0 + D1*N(C))/sqrt(1 + C**2)
*
*               C*A'(C)        A(C)
*      B(C) = ---------- + -------------
*             (1 + C/MU)   (1 + C/MU)**2
*
*      N(C) = C + sqrt(1 + C**2)
*
************************************************************************
      double precision u
      common /loc010/ u(65,3,0:2)

      double precision gu0,gx0,gy0,gu1,gx1,gy1,gu2,gx2,gy2
      common /loc012/ gu0(65),gx0(65),gy0(65),
     +                gu1(65),gx1(65),gy1(65),
     +                gu2(65),gx2(65),gy2(65)

      double precision a,n1,n2,n3
      common /loc020/ a(65) /loc021/ n1(65),n2(65),n3(65)

      double precision ayu,aux,axy
      common /loc022/ ayu(65),aux(65),axy(65)

      double precision cscf,uscf,tscf,gamma,mu,d0,d1
      common /data1/ cscf,uscf,tscf,gamma,mu
      common /data2/ d0,d1
      save /data1/,/data2/

      double precision numvisc,usera
      common /mfe100/ numvisc,usera(24)

      double precision g7w,g7a0,g7a1,g7a2,g3w,g3a0,g3a1
      common /g2d7/ g7w(7),g7a0(7),g7a1(7),g7a2(7)
      common /g1d3/ g3w(3),g3a0(3),g3a1(3)

      integer n,i,j,k,kp1,km1
      double precision c(65),cc,r,afun,dafun,bfun,term
      double precision aa(65,0:2,0:2),ba0(65),ba1(65),ba2(65)
      equivalence (ba0,aa(1,0,0)),(ba1,aa(1,1,1)),(ba2,aa(1,2,2))
*     ==================================================================
*      Function definitions.
*     ==================================================================
      r(cc) = cc + sqrt(1. + cc**2)
      afun(cc)  = r(cc)*(d0 + d1*r(cc))/sqrt(1. + cc**2)
      dafun(cc) = (r(cc)*(d0 + 2.*d1*r(cc)) - cc*afun(cc))/(1. + cc**2)
      bfun(cc)  = cc*dafun(cc)/(1. + cc/mu) + afun(cc)/(1. + cc/mu)**2
*     ==================================================================
*      Averages of TSCF*USCF*B(c)*alphas by 7-pt Gauss quadrature.
*     ==================================================================
      do 10 i=0,8
      do 10 j=1,n
   10 aa(j,i,0) = 0.

      do 20 i=1,7
      do 21 j=1,n
   21 c(j) = u(j,1,0)*g7a0(i) + u(j,1,1)*g7a1(i) + u(j,1,2)*g7a2(i)
      call vcofu(n,c)
      do 20 j=1,n
       ba0(j) = ba0(j) + bfun(c(j))*((tscf*uscf)*g7w(i)*g7a0(i))
       ba1(j) = ba1(j) + bfun(c(j))*((tscf*uscf)*g7w(i)*g7a1(i))
       ba2(j) = ba2(j) + bfun(c(j))*((tscf*uscf)*g7w(i)*g7a2(i))
   20 continue
*     ==================================================================
*      Averages of TSCF*A(C)*alphas on edges by 3-pt Gauss quadrature.
*     ==================================================================
      do 30 k=0,2
      kp1 = mod(k+1,3)
      km1 = mod(k+2,3)
      do 30 i=1,3
      do 31 j=1,n
   31 c(j) = u(j,1,kp1)*g3a0(i) + u(j,1,km1)*g3a1(i)
      call vcofu(n,c)
      do 30 j=1,n
       aa(j,kp1,k) = aa(j,kp1,k) + afun(c(j))*(tscf*g3w(i)*g3a0(i))
       aa(j,km1,k) = aa(j,km1,k) + afun(c(j))*(tscf*g3w(i)*g3a1(i))
   30 continue
*     ==================================================================
*      Load the inner products.
*     ==================================================================
      do 40 j=1,n
       term = (ayu(j)**2 + aux(j)**2)/axy(j)
       gx0(j) = (term*ba0(j))*n1(j)
       gy0(j) = (term*ba0(j))*n2(j)
       gu0(j) = (term*ba0(j))*n3(j)

       gx1(j) = (term*ba1(j))*n1(j)
       gy1(j) = (term*ba1(j))*n2(j)
       gu1(j) = (term*ba1(j))*n3(j)

       gx2(j) = (term*ba2(j))*n1(j)
       gy2(j) = (term*ba2(j))*n2(j)
       gu2(j) = (term*ba2(j))*n3(j)
   40 continue

      call laplvc(n,aa)

*     Simulate numerical diffusion by pure laplacian.
      call lapl(n,numvisc*tscf)

      return
      end
      double precision function cofu(u)
************************************************************************
*
*   COFU -- Compute c(u).
*
*   Using a Newton iteration, this routine inverts the function
*
*      U(C) = (C/MU + log(C/MU) - GAMMA)/USCF.
*
*   This is done by writing
*
*      USCF*U + GAMMA = (C/MU) + log(C/MU)
*
*   and then inverting the function y(x) = x + log(x).
*
************************************************************************
      double precision cscf,uscf,tscf,gamma,mu
      common /data1/ cscf,uscf,tscf,gamma,mu
      save /data1/

      double precision u,x,y,fact

      y = uscf*u + gamma

*     Initial guess for x.
      x = y
      if(y .lt. 1.) x = exp(y-1.)

*     Interate to a relative accuracy of 1e-10.
   10 fact = (1. + y - log(x))/(1. + x)
      x = fact*x
      if (abs((1. - fact)/fact) .gt. 1.e-10) go to 10

      cofu = mu*x

      return
      end
      subroutine vcofu(n,c)
************************************************************************
*
*   VCOFU -- Compute c(u).
*
*   Using a Newton iteration, this routine inverts the function
*
*      U(C) = (C/MU + log(C/MU) - GAMMA)/USCF.
*
*   This is done by writing
*
*      USCF*U + GAMMA = (C/MU) + log(C/MU)
*
*   and then inverting the function y(x) = x + log(x).
*
************************************************************************
      double precision cscf,uscf,tscf,gamma,mu
      common /data1/ cscf,uscf,tscf,gamma,mu
      save /data1/

      integer n,j,k,NITR
      double precision c(65),y(65)

      parameter(NITR=4)

      do 10 j=1,n
       y(j) = uscf*c(j) + gamma
       if(y(j) .lt. 1.) then
        c(j) = exp(y(j)-1.)
       else
        c(j) = y(j)
        endif
   10 continue

      do 20 k=1,NITR
      do 20 j=1,n
   20 c(j) = c(j)*(1. + y(j) - log(c(j)))/(1. + c(j))

      do 30 j=1,n
   30 c(j) = mu*c(j)

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
*   G1D3 -- 3 point 1D Gaussion quadrature formula.  Fifth order
*   accurate.  The weights are g3w(.) and the corresponding quadrature
*   points are (g3a0(.), g3a1(.)) given as the isoparametric coordinates
*   (alpha_0, alpha_1) of the interval.
*
************************************************************************
      double precision g7w,g7a0,g7a1,g7a2,g3w,g3a0,g3a1
      common /g2d7/ g7w(7),g7a0(7),g7a1(7),g7a2(7)
      common /g1d3/ g3w(3),g3a0(3),g3a1(3)

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

      data g3w/
     + 2.77777777777778e-1,4.44444444444444e-1,2.77777777777778e-1/
      data (g3a0(k),g3a1(k),k=1,3)/
     + 1.12701665379259e-1, 8.87298334620741e-1,
     + 5.00000000000000e-1, 5.00000000000000e-1,
     + 8.87298334620741e-1, 1.12701665379259e-1/

      end
