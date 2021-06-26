      subroutine cmtx(n,factor,diag)
************************************************************************
*
*   CMTX -- Compute the local mass matrix C(y).
*
*     If DIAG=1 only the block diagonal is loaded.
*
************************************************************************
      double precision a00,a10,a20,a01,a11,a21,a02,a12,a22
      common /loc013/ a00(65,3,3),a10(65,3,3),a20(65,3,3),
     +                a01(65,3,3),a11(65,3,3),a21(65,3,3),
     +                a02(65,3,3),a12(65,3,3),a22(65,3,3)

      integer n,diag,j,k1,k2
      double precision factor

*     Load the block upper triangular part of the local mass matrix.
      call amtx(n,factor,diag)
      call regmtx(n,factor,diag)

      if(diag .eq. 1) return

*     Complete the local mass matrix, using symmetry.
      do 10 k2=1,3
      do 10 k1=1,3
      do 10 j=1,n
       a10(j,k2,k1) = a01(j,k1,k2)
       a20(j,k2,k1) = a02(j,k1,k2)
       a21(j,k2,k1) = a12(j,k1,k2)
   10 continue

      return
      end
