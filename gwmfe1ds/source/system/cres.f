      subroutine cres
************************************************************************
*
*   CRES -- MFE mass matrix contribution to the residual.
*
************************************************************************
      include "parameters.h"

      integer nnod,nelt
      common /mfe010/ nnod,nelt

      integer kreg
      double precision wpde,segvsc,segspr
      common /mfe020/ wpde(npde)
      common /mfe021/ segvsc(npde),segspr(npde),kreg

      double precision udot0,xdot0,udot1,xdot1
      common /loc11/ udot0(mnod,npde),xdot0(mnod),
     +               udot1(mnod,npde),xdot1(mnod)

      double precision ru0,rx0,ru1,rx1
      common /loc12/ ru0(mnod,npde),rx0(mnod),ru1(mnod,npde),rx1(mnod)

      double precision l,n1,n2
      common /loc30/ l(mnod,npde),n1(mnod,npde),n2(mnod,npde)

      integer j,k
      double precision c,nU0,nU1,term
*     ==================================================================
*      Pure MFE mass matrix terms.
*     ==================================================================
      do 10 k=1,npde
      c = wpde(k)/6.d0
      do 10 j=1,nelt
       nU0 = n1(j,k)*xdot0(j) + n2(j,k)*udot0(j,k)
       nU1 = n1(j,k)*xdot1(j) + n2(j,k)*udot1(j,k)

       rx0(j)   = rx0(j)   - ((c*l(j,k))*(2.d0*nU0 + nU1))*n1(j,k)
       ru0(j,k) = ru0(j,k) - ((c*l(j,k))*(2.d0*nU0 + nU1))*n2(j,k)

       rx1(j)   = rx1(j)   - ((c*l(j,k))*(nU0 + 2.d0*nU1))*n1(j,k)
       ru1(j,k) = ru1(j,k) - ((c*l(j,k))*(nU0 + 2.d0*nU1))*n2(j,k)
   10 continue
*     ==================================================================
*      Regularization contribution to the mass matrix.
*     ==================================================================
      if(kreg .eq. 1) then
*       --------------------------------------------------
*        Old regularization on grad of tangential motion.
*       --------------------------------------------------
        do 20 k=1,npde
        c = wpde(k)*segvsc(k)
        do 20 j=1,nelt
         term = (c/l(j,k))*(n2(j,k)*(xdot1(j)   - xdot0(j))
     +                    - n1(j,k)*(udot1(j,k) - udot0(j,k)))

         rx0(j)   = rx0(j)   + (term*n2(j,k))
         ru0(j,k) = ru0(j,k) - (term*n1(j,k))

         rx1(j)   = rx1(j)   - (term*n2(j,k))
         ru1(j,k) = ru1(j,k) + (term*n1(j,k))
   20   continue

      elseif(kreg .eq. 2) then
*       -----------------------------------------------
*        New regularization on grad of x and u motion.
*       -----------------------------------------------
        do 30 k=1,npde
        c = wpde(k)*segvsc(k)
        do 30 j=1,nelt
         rx0(j)   = rx0(j)   - ((c/l(j,k))*(xdot0(j)   - xdot1(j)))
         ru0(j,k) = ru0(j,k) - ((c/l(j,k))*(udot0(j,k) - udot1(j,k)))

         rx1(j)   = rx1(j)   + ((c/l(j,k))*(xdot0(j)   - xdot1(j)))
         ru1(j,k) = ru1(j,k) + ((c/l(j,k))*(udot0(j,k) - udot1(j,k)))
   30   continue
        endif

      return
      end
