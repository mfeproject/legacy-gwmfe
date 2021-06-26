      subroutine regrhs(n)
************************************************************************
*
*   REGRHS -- Regularization contribution to the RHS.
*
************************************************************************
      include "parameters.h"

      double precision wpde,eltvsc,tensn,press,rad0
      common /mfe020/ wpde(npde)
      common /mfe021/ eltvsc(npde),tensn(npde),press(npde),rad0

      double precision gu0,gx0,gy0,gu1,gx1,gy1,gu2,gx2,gy2
      common /loc012/ gu0(65,npde),gx0(65),gy0(65),
     +                gu1(65,npde),gx1(65),gy1(65),
     +                gu2(65,npde),gx2(65),gy2(65)

      double precision a,n1,n2,n3
      double precision du0,dx0,dy0,du1,dx1,dy1,du2,dx2,dy2
      common /loc020/ a(65,npde)
      common /loc021/ n1(65,npde),n2(65,npde),n3(65,npde)
      common /loc023/ du0(65,npde),dx0(65),dy0(65),
     +                du1(65,npde),dx1(65),dy1(65),
     +                du2(65,npde),dx2(65),dy2(65)

      double precision q0q0,q1q1,q2q2,q1q2,q2q0,q0q1
      common /loc030/ q0q0(65,npde),q1q1(65,npde),q2q2(65,npde),
     +                q1q2(65,npde),q2q0(65,npde),q0q1(65,npde)

      integer n,j,k
      double precision third,c1,c2,t1,t2,t3,nxqx,nxqy,nxqu
      double precision l0(65,npde),l1(65,npde),l2(65,npde),sradsq(65)

      parameter(third=1./3.)

      do 10 j=1,n
   10 sradsq(j) = 0.

      do 20 k=1,npde
      do 20 j=1,n
       l0(j,k) = sqrt(q0q0(j,k))
       l1(j,k) = sqrt(q1q1(j,k))
       l2(j,k) = sqrt(q2q2(j,k))
       sradsq(j) = sradsq(j) + 4.*(a(j,k)/(l0(j,k)+l1(j,k)+l2(j,k)))**2
   20 continue

      do 30 k=1,npde
      c1 = wpde(k)*tensn(k)/2.
      c2 = wpde(k)*press(k)
      do 30 j=1,n
       t1 = c1*(l2(j,k) - third*l1(j,k) + l0(j,k))
       t2 = c1*(l1(j,k) - third*l2(j,k) + l0(j,k))
       t3 = c2*(1./sradsq(j))*(1. + rad0**2/sradsq(j))
       nxqx = n2(j,k)*du0(j,k) - n3(j,k)*dy0(j)
       nxqy = n3(j,k)*dx0(j)   - n1(j,k)*du0(j,k)
       nxqu = n1(j,k)*dy0(j)   - n2(j,k)*dx0(j)
       gx0(j)   = gx0(j)   - t1*dx1(j)   + t2*dx2(j)   + t3*nxqx
       gy0(j)   = gy0(j)   - t1*dy1(j)   + t2*dy2(j)   + t3*nxqy
       gu0(j,k) = gu0(j,k) - t1*du1(j,k) + t2*du2(j,k) + t3*nxqu

       t1 = c1*(l0(j,k) - third*l2(j,k) + l1(j,k))
       t2 = c1*(l2(j,k) - third*l0(j,k) + l1(j,k))
       nxqx = n2(j,k)*du1(j,k) - n3(j,k)*dy1(j)
       nxqy = n3(j,k)*dx1(j)   - n1(j,k)*du1(j,k)
       nxqu = n1(j,k)*dy1(j)   - n2(j,k)*dx1(j)
       gx1(j)   = gx1(j)   - t1*dx2(j)   + t2*dx0(j)   + t3*nxqx
       gy1(j)   = gy1(j)   - t1*dy2(j)   + t2*dy0(j)   + t3*nxqy
       gu1(j,k) = gu1(j,k) - t1*du2(j,k) + t2*du0(j,k) + t3*nxqu
 
       t1 = c1*(l1(j,k) - third*l0(j,k) + l2(j,k))
       t2 = c1*(l0(j,k) - third*l1(j,k) + l2(j,k))
       nxqx = n2(j,k)*du2(j,k) - n3(j,k)*dy2(j)
       nxqy = n3(j,k)*dx2(j)   - n1(j,k)*du2(j,k)
       nxqu = n1(j,k)*dy2(j)   - n2(j,k)*dx2(j)
       gx2(j)   = gx2(j)   - t1*dx0(j)   + t2*dx1(j)   + t3*nxqx
       gy2(j)   = gy2(j)   - t1*dy0(j)   + t2*dy1(j)   + t3*nxqy
       gu2(j,k) = gu2(j,k) - t1*du0(j,k) + t2*du1(j,k) + t3*nxqu
   30 continue

      return
      end
