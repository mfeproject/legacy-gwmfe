      subroutine amtx(n,factor,diag)
************************************************************************
*
*   AMTX -- Local MFE mass matrix A(y).
*
*     If DIAG=1 only the diagonal blocks are loaded.
*
************************************************************************
      include "parameters.h"

      integer nepn,x,y
      parameter(nepn=npde+2,x=npde+1,y=npde+2)

      double precision wpde
      common /mfe020/ wpde(npde)

      double precision a00,a10,a20,a01,a11,a21,a02,a12,a22
      common /loc013/
     +       a00(65,nepn,nepn),a10(65,nepn,nepn),a20(65,nepn,nepn),
     +       a01(65,nepn,nepn),a11(65,nepn,nepn),a21(65,nepn,nepn),
     +       a02(65,nepn,nepn),a12(65,nepn,nepn),a22(65,nepn,nepn)

      double precision a,n1,n2,n3
      common /loc020/ a(65,npde)
      common /loc021/ n1(65,npde),n2(65,npde),n3(65,npde)

      integer n,diag,j,k,k1,k2
      double precision factor,c,term

*     Zero the basic block initially.
      do 10 k2=1,nepn
      do 10 k1=1,nepn
      do 10 j=1,n
   10 a00(j,k1,k2) = 0.

*     Load the nonzero elements.
      do 20 k=1,npde
      c = factor*wpde(k)/6.
      do 20 j=1,n
       a00(j,k,k) = ((c*a(j,k))*n3(j,k))*n3(j,k)
       a00(j,k,x) = ((c*a(j,k))*n3(j,k))*n1(j,k)
       a00(j,x,k) = a00(j,k,x)
       a00(j,k,y) = ((c*a(j,k))*n3(j,k))*n2(j,k)
       a00(j,y,k) = a00(j,k,y)
       a00(j,x,x) = a00(j,x,x) + ((c*a(j,k))*n1(j,k))*n1(j,k)
       a00(j,x,y) = a00(j,x,y) + ((c*a(j,k))*n1(j,k))*n2(j,k)
       a00(j,y,y) = a00(j,y,y) + ((c*a(j,k))*n2(j,k))*n2(j,k)
   20 continue

      do 21 j=1,n
   21 a00(j,y,x) = a00(j,x,y)
*     -----------------------
*      Copy the basic block.
*     -----------------------
      do 30 k1=1,nepn
      do 30 k2=1,nepn
      do 30 j=1,n
       term = a00(j,k1,k2)
       a11(j,k1,k2) = term
       a22(j,k1,k2) = term

       if(diag .eq. 1) go to 30

       a01(j,k1,k2) = .5*term
       a02(j,k1,k2) = .5*term
       a12(j,k1,k2) = .5*term
   30 continue

      return
      end
