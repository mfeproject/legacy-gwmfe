      subroutine regrhs(n)
************************************************************************
*
*   REGRHS -- Regularization contribution to the RHS.
*
************************************************************************
      double precision eltvsc,tensn,press,rad0
      common /mfe021/ eltvsc,tensn,press,rad0

      double precision gu0,gx0,gy0,gu1,gx1,gy1,gu2,gx2,gy2
      common /loc012/ gu0(65),gx0(65),gy0(65),
     +                gu1(65),gx1(65),gy1(65),
     +                gu2(65),gx2(65),gy2(65)

      double precision a,n1,n2,n3
      double precision du0,dx0,dy0,du1,dx1,dy1,du2,dx2,dy2
      common /loc020/ a(65)
      common /loc021/ n1(65),n2(65),n3(65)
      common /loc023/ du0(65),dx0(65),dy0(65),
     +                du1(65),dx1(65),dy1(65),
     +                du2(65),dx2(65),dy2(65)

      double precision q0q0,q1q1,q2q2,q1q2,q2q0,q0q1
      common /loc030/ q0q0(65),q1q1(65),q2q2(65),
     +                q1q2(65),q2q0(65),q0q1(65)

      integer n,j
      double precision third,c1,c2,t1,t2,t3,nxqx,nxqy,nxqu
      double precision l0,l1,l2,radsq

      parameter(third=1./3.)

      c1 = tensn/2.
      c2 = press
      do 10 j=1,n
       l0 = sqrt(q0q0(j))
       l1 = sqrt(q1q1(j))
       l2 = sqrt(q2q2(j))
       radsq = 4.*(a(j)/(l0+l1+l2))**2

       t1 = c1*(l2 - third*l1 + l0)
       t2 = c1*(l1 - third*l2 + l0)
       t3 = c2*(1./radsq)*(1. + rad0**2/radsq)
       nxqx = n2(j)*du0(j) - n3(j)*dy0(j)
       nxqy = n3(j)*dx0(j) - n1(j)*du0(j)
       nxqu = n1(j)*dy0(j) - n2(j)*dx0(j)
       gx0(j) = gx0(j) - t1*dx1(j) + t2*dx2(j) + t3*nxqx
       gy0(j) = gy0(j) - t1*dy1(j) + t2*dy2(j) + t3*nxqy
       gu0(j) = gu0(j) - t1*du1(j) + t2*du2(j) + t3*nxqu

       t1 = c1*(l0 - third*l2 + l1)
       t2 = c1*(l2 - third*l0 + l1)
       nxqx = n2(j)*du1(j) - n3(j)*dy1(j)
       nxqy = n3(j)*dx1(j) - n1(j)*du1(j)
       nxqu = n1(j)*dy1(j) - n2(j)*dx1(j)
       gx1(j) = gx1(j) - t1*dx2(j) + t2*dx0(j) + t3*nxqx
       gy1(j) = gy1(j) - t1*dy2(j) + t2*dy0(j) + t3*nxqy
       gu1(j) = gu1(j) - t1*du2(j) + t2*du0(j) + t3*nxqu
 
       t1 = c1*(l1 - third*l0 + l2)
       t2 = c1*(l0 - third*l1 + l2)
       nxqx = n2(j)*du2(j) - n3(j)*dy2(j)
       nxqy = n3(j)*dx2(j) - n1(j)*du2(j)
       nxqu = n1(j)*dy2(j) - n2(j)*dx2(j)
       gx2(j) = gx2(j) - t1*dx0(j) + t2*dx1(j) + t3*nxqx
       gy2(j) = gy2(j) - t1*dy0(j) + t2*dy1(j) + t3*nxqy
       gu2(j) = gu2(j) - t1*du0(j) + t2*du1(j) + t3*nxqu
   10 continue

      return
      end
