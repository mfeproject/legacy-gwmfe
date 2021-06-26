      subroutine pderhs(n)
************************************************************************
*
*   TRIRHS -- RHS inner products over triangles.
*
*   Inner products for the heat equation with source,
*
*     du/dt = Q + Lapl(u).
*
*   We take Q constant.
*
************************************************************************
      double precision srcq,usera
      common /mfe100/ srcq,usera(24)

      double precision gu0,gx0,gy0,gu1,gx1,gy1,gu2,gx2,gy2
      common /loc012/ gu0(65),gx0(65),gy0(65),
     +                gu1(65),gx1(65),gy1(65),
     +                gu2(65),gx2(65),gy2(65)

      double precision n1,n2,n3,ayu,aux,axy
      common /loc021/ n1(65),n2(65),n3(65)
      common /loc022/ ayu(65),aux(65),axy(65)

      integer n,j
      double precision term

      do 10 j=1,n
       term = srcq*axy(j)/3.
       gx0(j) = term*n1(j)
       gy0(j) = term*n2(j)
       gu0(j) = term*n3(j)

       gx1(j) = term*n1(j)
       gy1(j) = term*n2(j)
       gu1(j) = term*n3(j)

       gx2(j) = term*n1(j)
       gy2(j) = term*n2(j)
       gu2(j) = term*n3(j)
   10 continue

      call lapl(n,1.d0)

      return
      end
