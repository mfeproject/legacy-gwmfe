      subroutine pderhs(n)
************************************************************************
*
*   TRIRHS -- RHS inner products over triangles.
*
*   Inner products for Burgers' equation,
*
*      du/dt = - u*du/dx - v*du/dx + visc*Lapl(u)
*      dv/dt = - u*dv/dx - v*dv/dx + visc*Lapl(v)
*
************************************************************************
      integer npde
      parameter(npde=2)

      double precision wpde
      common /mfe020/ wpde(npde)

      double precision visc,usera
      common /mfe100/ visc,usera(24)

      double precision u0,v0,x0,y0,u1,v1,x1,y1,u2,v2,x2,y2
      common /loc010/ u0(65),v0(65),x0(65),y0(65),
     +                u1(65),v1(65),x1(65),y1(65),
     +                u2(65),v2(65),x2(65),y2(65)

      double precision gu0,gv0,gx0,gy0,gu1,gv1,gx1,gy1,gu2,gv2,gx2,gy2
      common /loc012/ gu0(65),gv0(65),gx0(65),gy0(65),
     +                gu1(65),gv1(65),gx1(65),gy1(65),
     +                gu2(65),gv2(65),gx2(65),gy2(65)

      double precision a,n1,n2,n3,ayu,aux,axy
      common /loc020/ a(65,npde)
      common /loc021/ n1(65,npde),n2(65,npde),n3(65,npde)
      common /loc022/ ayu(65,npde),aux(65,npde),axy(65)

      integer n,j
      double precision cu,cv,su,sv,tu,tv

      cu = wpde(1)/12.
      cv = wpde(2)/12.

      do 10 j=1,n
       su = u0(j) + u1(j) + u2(j)
       sv = v0(j) + v1(j) + v2(j)

       tu = cu*(ayu(j,1)*(u0(j)+su) + aux(j,1)*(v0(j)+sv))
       tv = cv*(ayu(j,2)*(u0(j)+su) + aux(j,2)*(v0(j)+sv))
       gx0(j) = tu*n1(j,1) + tv*n1(j,2)
       gy0(j) = tu*n2(j,1) + tv*n2(j,2)
       gu0(j) = tu*n3(j,1)
       gv0(j) = tv*n3(j,2)

       tu = cu*(ayu(j,1)*(u1(j)+su) + aux(j,1)*(v1(j)+sv))
       tv = cv*(ayu(j,2)*(u1(j)+su) + aux(j,2)*(v1(j)+sv))
       gx1(j) = tu*n1(j,1) + tv*n1(j,2)
       gy1(j) = tu*n2(j,1) + tv*n2(j,2)
       gu1(j) = tu*n3(j,1)
       gv1(j) = tv*n3(j,2)

       tu = cu*(ayu(j,1)*(u2(j)+su) + aux(j,1)*(v2(j)+sv))
       tv = cv*(ayu(j,2)*(u2(j)+su) + aux(j,2)*(v2(j)+sv))
       gx2(j) = tu*n1(j,1) + tv*n1(j,2)
       gy2(j) = tu*n2(j,1) + tv*n2(j,2)
       gu2(j) = tu*n3(j,1)
       gv2(j) = tv*n3(j,2)
   10 continue

      call lapl(n,1,visc)
      call lapl(n,2,visc)

      return
      end
