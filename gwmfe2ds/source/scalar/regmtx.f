      subroutine regmtx(n,factor,diag)
************************************************************************
*
*   REGMTX -- Regularization matrix.
*
*     If DIAG=1 only the diagonal blocks are loaded.
*
************************************************************************
      integer u,x,y
      parameter(u=1,x=2,y=3)

      double precision eltvsc,tensn,press,rad0
      common /mfe021/ eltvsc,tensn,press,rad0

      double precision a
      common /loc020/ a(65)

      double precision a00,a10,a20,a01,a11,a21,a02,a12,a22
      common /loc013/ a00(65,3,3),a10(65,3,3),a20(65,3,3),
     +                a01(65,3,3),a11(65,3,3),a21(65,3,3),
     +                a02(65,3,3),a12(65,3,3),a22(65,3,3)

      double precision q0q0,q1q1,q2q2,q1q2,q2q0,q0q1
      common /loc030/ q0q0(65),q1q1(65),q2q2(65),
     +                q1q2(65),q2q0(65),q0q1(65)

      integer n,diag,j
      double precision factor,c,term

      c = factor*eltvsc/4.
      do 10 j=1,n
       term = (c/a(j))*q0q0(j)
       a00(j,u,u) = a00(j,u,u) + term
       a00(j,x,x) = a00(j,x,x) + term
       a00(j,y,y) = a00(j,y,y) + term

       term = (c/a(j))*q1q1(j)
       a11(j,u,u) = a11(j,u,u) + term
       a11(j,x,x) = a11(j,x,x) + term
       a11(j,y,y) = a11(j,y,y) + term

       term = (c/a(j))*q2q2(j)
       a22(j,u,u) = a22(j,u,u) + term
       a22(j,x,x) = a22(j,x,x) + term
       a22(j,y,y) = a22(j,y,y) + term

       if(diag .eq. 1) go to 10

       term = (c/a(j))*q0q1(j)
       a01(j,u,u) = a01(j,u,u) + term
       a01(j,x,x) = a01(j,x,x) + term
       a01(j,y,y) = a01(j,y,y) + term

       term = (c/a(j))*q2q0(j)
       a02(j,u,u) = a02(j,u,u) + term
       a02(j,x,x) = a02(j,x,x) + term
       a02(j,y,y) = a02(j,y,y) + term

       term = (c/a(j))*q1q2(j)
       a12(j,u,u) = a12(j,u,u) + term
       a12(j,x,x) = a12(j,x,x) + term
       a12(j,y,y) = a12(j,y,y) + term
   10 continue

      return
      end
