      subroutine pderhs(t)
************************************************************************
*
*   PDERHS -- RHS inner product for the convection-diffusion equation
*
*      du/dt = -du/dx + visc*d2u/dx2.
*
************************************************************************
      include "parameters.h"
      
      integer nnod,nelt
      common /mfe010/ nnod,nelt

      double precision visc,usera
      common /mfe100/ visc,usera(24)

      double precision gu0,gx0,gu1,gx1
      common /loc12/ gu0(mnod),gx0(mnod),gu1(mnod),gx1(mnod)

      double precision l,n1,n2,du,dx
      common /loc30/ l(mnod),n1(mnod),n2(mnod) /loc31/ du(mnod),dx(mnod)

      integer j
      double precision t,term

      do 10 j=1,nelt
       term = -.5d0*du(j)
       gx0(j) = term*n1(j)
       gu0(j) = term*n2(j)
       gx1(j) = term*n1(j)
       gu1(j) = term*n2(j)
   10 continue

      call lapl(1,visc)

      return
      end
