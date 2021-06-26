      subroutine regres(n)
************************************************************************
*
*   REGRES -- Regularization contribution to the residual.
*
************************************************************************
      double precision eltvsc,tensn,press,rad0
      common /mfe021/ eltvsc,tensn,press,rad0

      double precision zu0,zx0,zy0,zu1,zx1,zy1,zu2,zx2,zy2
      double precision ru0,rx0,ry0,ru1,rx1,ry1,ru2,rx2,ry2
      common /loc011/ zu0(65),zx0(65),zy0(65),
     +                zu1(65),zx1(65),zy1(65),
     +                zu2(65),zx2(65),zy2(65)
      common /loc012/ ru0(65),rx0(65),ry0(65),
     +                ru1(65),rx1(65),ry1(65),
     +                ru2(65),rx2(65),ry2(65)

      double precision a
      common /loc020/ a(65)

      double precision q0q0,q1q1,q2q2,q1q2,q2q0,q0q1
      common /loc030/ q0q0(65),q1q1(65),q2q2(65),
     +                q1q2(65),q2q0(65),q0q1(65)

      integer n,j
      double precision c,tx,ty,tu

      c = eltvsc/4.
      do 10 j=1,n
       tx = q0q0(j)*zx0(j) + q0q1(j)*zx1(j) + q2q0(j)*zx2(j)
       ty = q0q0(j)*zy0(j) + q0q1(j)*zy1(j) + q2q0(j)*zy2(j)
       tu = q0q0(j)*zu0(j) + q0q1(j)*zu1(j) + q2q0(j)*zu2(j)
       rx0(j) = rx0(j) - (c/a(j))*tx
       ry0(j) = ry0(j) - (c/a(j))*ty
       ru0(j) = ru0(j) - (c/a(j))*tu

       tx = q0q1(j)*zx0(j) + q1q1(j)*zx1(j) + q1q2(j)*zx2(j)
       ty = q0q1(j)*zy0(j) + q1q1(j)*zy1(j) + q1q2(j)*zy2(j)
       tu = q0q1(j)*zu0(j) + q1q1(j)*zu1(j) + q1q2(j)*zu2(j)
       rx1(j) = rx1(j) - (c/a(j))*tx
       ry1(j) = ry1(j) - (c/a(j))*ty
       ru1(j) = ru1(j) - (c/a(j))*tu

       tx = q2q0(j)*zx0(j) + q1q2(j)*zx1(j) + q2q2(j)*zx2(j)
       ty = q2q0(j)*zy0(j) + q1q2(j)*zy1(j) + q2q2(j)*zy2(j)
       tu = q2q0(j)*zu0(j) + q1q2(j)*zu1(j) + q2q2(j)*zu2(j)
       rx2(j) = rx2(j) - (c/a(j))*tx
       ry2(j) = ry2(j) - (c/a(j))*ty
       ru2(j) = ru2(j) - (c/a(j))*tu
   10 continue
 
      return
      end
