      subroutine cdgl
************************************************************************
*
*  CDGL -- Local Mass matrix diagonal.
*
************************************************************************
      include "parameters.h"
      
      integer x
      parameter(x=npde+1)

      integer nnod,nelt
      common /mfe010/ nnod,nelt

      integer kreg
      double precision wpde,segvsc,segspr
      common /mfe020/ wpde(npde)
      common /mfe021/ segvsc(npde),segspr(npde),kreg

      double precision a00,a10,a01,a11
      common /loc20/ a00(mnod,nepn,nepn),a10(mnod,nepn,nepn),
     +               a01(mnod,nepn,nepn),a11(mnod,nepn,nepn)

      double precision l,n1,n2
      common /loc30/ l(mnod,npde),n1(mnod,npde),n2(mnod,npde)

      integer i,j,k
      double precision c,aa,ab,bb(mnod),term
*     ==================================================================
*      Load the zero elements of the local mass matrix diagonal.
*     ==================================================================
      do 10 k=2,npde
      do 10 i=1,k-1
      do 10 j=1,nelt
       a00(j,i,k) = 0.d0
       a11(j,i,k) = 0.d0
       a00(j,k,i) = 0.d0
       a11(j,k,i) = 0.d0
   10 continue
*     ==================================================================
*      Load the pure MFE mass matrix diagonal.
*     ==================================================================
      do 20 j=1,nelt
   20 bb(j) = 0.d0

      do 30 k=1,npde
      c = wpde(k)/3.d0
      do 30 j=1,nelt
       aa = (c*l(j,k))*n2(j,k)**2
       ab = (c*l(j,k))*n1(j,k)*n2(j,k)
       bb(j) = bb(j) + (c*l(j,k))*n1(j,k)**2

*      Load the (alpha,alpha) inner products.
       a00(j,k,k) = aa
       a11(j,k,k) = aa

*      Load the (alpha,beta) inner products.
       a00(j,k,x) = ab
       a00(j,x,k) = ab
       a11(j,k,x) = ab
       a11(j,x,k) = ab
   30 continue

*     Load the (beta,beta) inner products.
      do 40 j=1,nelt
       a00(j,x,x) = bb(j)
       a11(j,x,x) = bb(j)
   40 continue
*     ==================================================================
*      Regularization contribution to the mass matrix diagonal.
*     ==================================================================
      if(kreg .eq. 1) then
*     ----------------------------------------------------------
*      Old regularization on the grad of the tangential motion.
*     ----------------------------------------------------------
      do 100 k=1,npde
      c = wpde(k)*segvsc(k)
      do 100 j=1,nelt
       term = (c/l(j,k))*n1(j,k)**2
       a00(j,k,k) = a00(j,k,k) + term
       a11(j,k,k) = a11(j,k,k) + term

       term = (c/l(j,k))*n1(j,k)*n2(j,k)
       a00(j,k,x) = a00(j,k,x) - term
       a00(j,x,k) = a00(j,x,k) - term
       a11(j,k,x) = a11(j,k,x) - term
       a11(j,x,k) = a11(j,x,k) - term

       term = (c/l(j,k))*n2(j,k)**2
       a00(j,x,x) = a00(j,x,x) + term
       a11(j,x,x) = a11(j,x,x) + term
  100 continue

      elseif(kreg .eq. 2) then
*     ----------------------------------------------------
*      New regularization on the grad of x and u motions.
*     ----------------------------------------------------
      do 200 k=1,npde
      c = wpde(k)*segvsc(k)
      do 200 j=1,nelt
       a00(j,k,k) = a00(j,k,k) + (c/l(j,k))
       a11(j,k,k) = a11(j,k,k) + (c/l(j,k))

       a00(j,x,x) = a00(j,x,x) + (c/l(j,k))
       a11(j,x,x) = a11(j,x,x) + (c/l(j,k))
  200 continue
      endif

      return
      end
