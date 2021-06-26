      subroutine regmtx(n,factor,diag)
************************************************************************
*
*   REGMTX -- Regularization matrix.
*
*     If DIAG=1 only the diagonal blocks are loaded.
*
************************************************************************
      include "parameters.h"

      integer nepn,x,y
      parameter(nepn=npde+2,x=npde+1,y=npde+2)

      double precision wpde,eltvsc,tensn,press,rad0
      common /mfe020/ wpde(npde)
      common /mfe021/ eltvsc(npde),tensn(npde),press(npde),rad0

      double precision a
      common /loc020/ a(65,npde)

      double precision a00,a10,a20,a01,a11,a21,a02,a12,a22
      common /loc013/
     +       a00(65,nepn,nepn),a10(65,nepn,nepn),a20(65,nepn,nepn),
     +       a01(65,nepn,nepn),a11(65,nepn,nepn),a21(65,nepn,nepn),
     +       a02(65,nepn,nepn),a12(65,nepn,nepn),a22(65,nepn,nepn)

      double precision q0q0,q1q1,q2q2,q1q2,q2q0,q0q1
      common /loc030/ q0q0(65,npde),q1q1(65,npde),q2q2(65,npde),
     +                q1q2(65,npde),q2q0(65,npde),q0q1(65,npde)

      integer n,diag,j,k
      double precision factor,c,term

      do 10 k=1,npde
      c = factor*wpde(k)*eltvsc(k)/4.
      do 10 j=1,n
       term = (c/a(j,k))*q0q0(j,k)
       a00(j,k,k) = a00(j,k,k) + term
       a00(j,x,x) = a00(j,x,x) + term
       a00(j,y,y) = a00(j,y,y) + term

       term = (c/a(j,k))*q1q1(j,k)
       a11(j,k,k) = a11(j,k,k) + term
       a11(j,x,x) = a11(j,x,x) + term
       a11(j,y,y) = a11(j,y,y) + term

       term = (c/a(j,k))*q2q2(j,k)
       a22(j,k,k) = a22(j,k,k) + term
       a22(j,x,x) = a22(j,x,x) + term
       a22(j,y,y) = a22(j,y,y) + term

       if(diag .eq. 1) go to 10

       term = (c/a(j,k))*q0q1(j,k)
       a01(j,k,k) = a01(j,k,k) + term
       a01(j,x,x) = a01(j,x,x) + term
       a01(j,y,y) = a01(j,y,y) + term

       term = (c/a(j,k))*q2q0(j,k)
       a02(j,k,k) = a02(j,k,k) + term
       a02(j,x,x) = a02(j,x,x) + term
       a02(j,y,y) = a02(j,y,y) + term

       term = (c/a(j,k))*q1q2(j,k)
       a12(j,k,k) = a12(j,k,k) + term
       a12(j,x,x) = a12(j,x,x) + term
       a12(j,y,y) = a12(j,y,y) + term
   10 continue

      return
      end
