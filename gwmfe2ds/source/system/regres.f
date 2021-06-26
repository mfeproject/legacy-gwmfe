      subroutine regres(n)
************************************************************************
*
*   REGRES -- Regularization contribution to the residual.
*
************************************************************************
      include "parameters.h"

      double precision wpde,eltvsc,tensn,press,rad0
      common /mfe020/ wpde(npde)
      common /mfe021/ eltvsc(npde),tensn(npde),press(npde),rad0

      double precision zu0,zx0,zy0,zu1,zx1,zy1,zu2,zx2,zy2
      double precision ru0,rx0,ry0,ru1,rx1,ry1,ru2,rx2,ry2
      common /loc011/ zu0(65,npde),zx0(65),zy0(65),
     +                zu1(65,npde),zx1(65),zy1(65),
     +                zu2(65,npde),zx2(65),zy2(65)
      common /loc012/ ru0(65,npde),rx0(65),ry0(65),
     +                ru1(65,npde),rx1(65),ry1(65),
     +                ru2(65,npde),rx2(65),ry2(65)

      double precision a
      common /loc020/ a(65,npde)

      double precision q0q0,q1q1,q2q2,q1q2,q2q0,q0q1
      common /loc030/ q0q0(65,npde),q1q1(65,npde),q2q2(65,npde),
     +                q1q2(65,npde),q2q0(65,npde),q0q1(65,npde)

      integer n,j,k
      double precision c,tx,ty,tu

      do 10 k=1,npde
      c = wpde(k)*eltvsc(k)/4.
      do 10 j=1,n
       tx = q0q0(j,k)*zx0(j)   + q0q1(j,k)*zx1(j)   + q2q0(j,k)*zx2(j)
       ty = q0q0(j,k)*zy0(j)   + q0q1(j,k)*zy1(j)   + q2q0(j,k)*zy2(j)
       tu = q0q0(j,k)*zu0(j,k) + q0q1(j,k)*zu1(j,k) + q2q0(j,k)*zu2(j,k)
       rx0(j)   = rx0(j)   - (c/a(j,k))*tx
       ry0(j)   = ry0(j)   - (c/a(j,k))*ty
       ru0(j,k) = ru0(j,k) - (c/a(j,k))*tu

       tx = q0q1(j,k)*zx0(j)   + q1q1(j,k)*zx1(j)   + q1q2(j,k)*zx2(j)
       ty = q0q1(j,k)*zy0(j)   + q1q1(j,k)*zy1(j)   + q1q2(j,k)*zy2(j)
       tu = q0q1(j,k)*zu0(j,k) + q1q1(j,k)*zu1(j,k) + q1q2(j,k)*zu2(j,k)
       rx1(j)   = rx1(j)   - (c/a(j,k))*tx
       ry1(j)   = ry1(j)   - (c/a(j,k))*ty
       ru1(j,k) = ru1(j,k) - (c/a(j,k))*tu

       tx = q2q0(j,k)*zx0(j)   + q1q2(j,k)*zx1(j)   + q2q2(j,k)*zx2(j)
       ty = q2q0(j,k)*zy0(j)   + q1q2(j,k)*zy1(j)   + q2q2(j,k)*zy2(j)
       tu = q2q0(j,k)*zu0(j,k) + q1q2(j,k)*zu1(j,k) + q2q2(j,k)*zu2(j,k)
       rx2(j)   = rx2(j)   - (c/a(j,k))*tx
       ry2(j)   = ry2(j)   - (c/a(j,k))*ty
       ru2(j,k) = ru2(j,k) - (c/a(j,k))*tu
   10 continue
 
      return
      end
