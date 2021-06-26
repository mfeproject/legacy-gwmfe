      subroutine regrhs
************************************************************************
*
*  REGRHS -- Spring force regularization.
*
************************************************************************
      include "parameters.h"

      integer nnod,nelt
      common /mfe010/ nnod,nelt

      integer kreg
      double precision wpde,segvsc,segspr
      common /mfe020/ wpde(npde)
      common /mfe021/ segvsc(npde),segspr(npde),kreg

      double precision gu0,gx0,gu1,gx1
      common /loc12/ gu0(mnod,npde),gx0(mnod),gu1(mnod,npde),gx1(mnod)

      double precision l,n1,n2
      common /loc30/ l(mnod,npde),n1(mnod,npde),n2(mnod,npde)

      double precision c
      integer j,k

      do 10 k=1,npde
      c = wpde(k)*segspr(k)
      do 10 j=1,nelt
       gx0(j)   = gx0(j)   - (c/l(j,k)**2)*n2(j,k)
       gu0(j,k) = gu0(j,k) + (c/l(j,k)**2)*n1(j,k)

       gx1(j)   = gx1(j)   + (c/l(j,k)**2)*n2(j,k)
       gu1(j,k) = gu1(j,k) - (c/l(j,k)**2)*n1(j,k)
   10 continue

      return
      end
