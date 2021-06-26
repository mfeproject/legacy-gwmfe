      subroutine pderhs(n)
************************************************************************
*
*   TRIRHS -- RHS inner products over triangles.
*
*   Inner products for the equation of motion by mean curvature
*   with internal pressure,
*
*     . ^              ^
*     n N = (C[u] + H) N, (we take H constant).
*
************************************************************************
      double precision h,usera
      common /mfe100/ h,usera(24)

      double precision gu0,gx0,gy0,gu1,gx1,gy1,gu2,gx2,gy2
      common /loc012/ gu0(65),gx0(65),gy0(65),
     +                gu1(65),gx1(65),gy1(65),
     +                gu2(65),gx2(65),gy2(65)

      double precision a,n1,n2,n3
      common /loc020/ a(65) /loc021/ n1(65),n2(65),n3(65)

      double precision du0,dx0,dy0,du1,dx1,dy1,du2,dx2,dy2
      common /loc023/ du0(65),dx0(65),dy0(65),
     +                du1(65),dx1(65),dy1(65),
     +                du2(65),dx2(65),dy2(65)

      integer n,j
      double precision term

      do 10 j=1,n
       term = h*a(j)/3.
       gx0(j) = .5*(dy0(j)*n3(j) - du0(j)*n2(j)) + term*n1(j)
       gy0(j) = .5*(du0(j)*n1(j) - dx0(j)*n3(j)) + term*n2(j)
       gu0(j) = .5*(dx0(j)*n2(j) - dy0(j)*n1(j)) + term*n3(j)

       gx1(j) = .5*(dy1(j)*n3(j) - du1(j)*n2(j)) + term*n1(j)
       gy1(j) = .5*(du1(j)*n1(j) - dx1(j)*n3(j)) + term*n2(j)
       gu1(j) = .5*(dx1(j)*n2(j) - dy1(j)*n1(j)) + term*n3(j)

       gx2(j) = .5*(dy2(j)*n3(j) - du2(j)*n2(j)) + term*n1(j)
       gy2(j) = .5*(du2(j)*n1(j) - dx2(j)*n3(j)) + term*n2(j)
       gu2(j) = .5*(dx2(j)*n2(j) - dy2(j)*n1(j)) + term*n3(j)
   10 continue

      return
      end
