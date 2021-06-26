      subroutine amtx(n,factor,diag)
************************************************************************
*
*   AMTX -- Local MFE mass matrix A(y).
*
*     If DIAG=1 only the diagonal blocks are loaded.
*
************************************************************************
      integer u,x,y
      parameter(u=1,x=2,y=3)

      double precision a00,a10,a20,a01,a11,a21,a02,a12,a22
      common /loc013/ a00(65,3,3),a10(65,3,3),a20(65,3,3),
     +                a01(65,3,3),a11(65,3,3),a21(65,3,3),
     +                a02(65,3,3),a12(65,3,3),a22(65,3,3)

      double precision a,n1,n2,n3
      common /loc020/ a(65)
      common /loc021/ n1(65),n2(65),n3(65)

      integer n,diag,j,k1,k2
      double precision factor,c,term

*     Load the nonzero elements.
      c = factor/6.
      do 10 j=1,n
       a00(j,u,u) = ((c*a(j))*n3(j))*n3(j)
       a00(j,u,x) = ((c*a(j))*n3(j))*n1(j)
       a00(j,x,u) = a00(j,u,x)
       a00(j,u,y) = ((c*a(j))*n3(j))*n2(j)
       a00(j,y,u) = a00(j,u,y)
       a00(j,x,x) = ((c*a(j))*n1(j))*n1(j)
       a00(j,x,y) = ((c*a(j))*n1(j))*n2(j)
       a00(j,y,x) = a00(j,x,y)
       a00(j,y,y) = ((c*a(j))*n2(j))*n2(j)
   10 continue
*     -----------------------
*      Copy the basic block.
*     -----------------------
      do 20 k1=1,3
      do 20 k2=1,3
      do 20 j=1,n
       term = a00(j,k1,k2)
       a11(j,k1,k2) = term
       a22(j,k1,k2) = term

       if(diag .eq. 1) go to 20

       a01(j,k1,k2) = .5*term
       a02(j,k1,k2) = .5*term
       a12(j,k1,k2) = .5*term
   20 continue

      return
      end
