      subroutine laplvc(ieq,a0,a1)
************************************************************************
*
*   LAPLVC -- RHS inner products with the laplacian with variable coef.
*
************************************************************************
      include "parameters.h"

      double precision wpde
      integer nnod,nelt
      common /mfe010/ nnod,nelt /mfe020/ wpde(npde)

      double precision bvl,bvr
      integer bcl,bcr
      common /mfe030/ bcl(nepn),bcr(nepn),bvl(nepn),bvr(nepn)

      double precision gu0,gx0,gu1,gx1
      common /loc12/ gu0(mnod,npde),gx0(mnod),gu1(mnod,npde),gx1(mnod)

      double precision du,dx
      common /loc31/ du(mnod,npde),dx(mnod)

      integer ieq,j
      double precision a0(*),a1(*)
      double precision dudx,dS,e,expan,i1(mnod),i2(mnod),eta,c3,c5,c7
      parameter(eta=1.d-2,c3=1.d0/3.d0,c5=1.d0/5.d0,c7=1.d0/7.d0)

*     Taylor expansion of .5*log((1+e)/(1-e)).
      expan(e) = e*(1.d0 + (e**2)*(c3 + (e**2)*(c5 + c7*(e**2))))

      do 10 j=1,nelt
       dudx = du(j,ieq)/dx(j)
       dS = sqrt(1.d0 + dudx**2)
       e = dudx/dS
       i2(j) = dudx**2/(1.d0 + dS)
       if(abs(e) .gt. eta) then
        i1(j) = sign(log(abs(dudx)+dS), dudx)
       else
        i1(j) = expan(e)
        endif
   10 continue

      gu1(1,ieq) = gu1(1,ieq) - (wpde(ieq)*a1(1))*i1(1)
      gx1(1)     = gx1(1)     + (wpde(ieq)*a1(1))*i2(1)
      do 20 j=2,nelt-1
       gu0(j,ieq) = gu0(j,ieq) + (wpde(ieq)*a0(j))*i1(j)
       gu1(j,ieq) = gu1(j,ieq) - (wpde(ieq)*a1(j))*i1(j)
       gx0(j)     = gx0(j)     - (wpde(ieq)*a0(j))*i2(j)
       gx1(j)     = gx1(j)     + (wpde(ieq)*a1(j))*i2(j)
   20 continue
      gu0(nelt,ieq) = gu0(nelt,ieq) + (wpde(ieq)*a0(j))*i1(nelt)
      gx0(nelt)     = gx0(nelt)     - (wpde(ieq)*a0(j))*i2(nelt)

      if(bcl(ieq).eq.2)
     +   gu0(1,ieq)    = gu0(1,ieq)    + (wpde(ieq)*a0(1))*i1(1)
      if(bcr(ieq).eq.2)
     +   gu1(nelt,ieq) = gu1(nelt,ieq) - (wpde(ieq)*a1(nelt))*i1(nelt)

      return
      end
