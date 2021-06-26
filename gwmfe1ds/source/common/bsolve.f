************************************************************************
*
*   BBFCT -- BLOCK BANDED MATRIX FACTORIZATION.
*   BBSLV -- BLOCK BANDED MATRIX SOLVE.
*
*   THESE ROUTINES SOLVE UNIFORMLY PARTITIONED LINEAR SYSTEMS A*X=B
*   FOR THE VECTOR X WHEN A IS A BLOCK BANDED MATRIX.  THE ROUTINE
*   BBFCT COMPUTES THE BLOCK LU-FACTORIZATION OF THE COEFFICIENT
*   MATRIX A.  IT IS ASSUMED THAT GAUSSIAN ELIMINATION APPLIED TO A
*   IS STABLE WITHOUT PIVOTING.  THE MATRIX A IS STORED IN THE BLOCK
*   BANDED SCHEME.  THE ELEMENTS OF THE FACTORS OVERWRITE THOSE OF A
*   IN THE STANDARD MANNER.  SUBSEQUENT CALLS TO THE ROUTINE BBSLV
*   SOLVES THE SYSTEM, CARRYING OUT THE FORWARD AND BACKWARD
*   SUBSTITUTIONS.
*
*   ARGUMENT  DESCRIPTION
*   --------  -----------
*    NBLKS    THE NUMBER OF PARTITION BLOCKS.
*
*    N        THE NUMBER OF EQUATIONS PER BLOCK.
*
*    BANDW    THE BANDWIDTH OF THE MATRIX.  THE BANDWIDTH IS DEFINED TO
*             BE THE MAX { |I-J| : AIJ IS A NONZERO BLOCK }.
*
*    A        ARRAY CONTAINING EITHER THE ELEMENTS OF THE COEFFICIENT
*             MATRIX A OR THE ELEMENTS OF ITS LOWER AND UPPER FACTORS.
*                      
*    B        ON INPUT THE ARRAY CONTAINS THE ELEMENTS OF THE RHS
*             VECTOR AND IS OVERWRITTEN WITH THE SOLUTION VECTOR.
*
*   SUBROUTINES:  BBFCT -- CMAB, FCT, MSLV.
*                 BBSLV -- SLV, YMAX.
*
************************************************************************
      subroutine bbfct(nblks,n,bandw,a)

      integer nblks, n, bandw, j, k, l
      double precision a(n*n,-bandw:bandw,nblks)
 
      do 10 k=1,nblks
      l = min( bandw, nblks-k )
      call fct(a(1,0,k),  n)
      call mslv(a(1,0,k),  a(1,1,k),  n,l*n)
      do 10 j=1,l
      call cmab(a(1,-j,k+j),  a(1,1,k),  a(1,1-j,k+j),  n,n,l*n)
   10 continue
 
      return
      end
      subroutine bbslv(nblks,n,bandw,a,  b)

      integer nblks, n, bandw, k, l
      double precision a(n*n,-bandw:bandw,nblks), b(n,nblks)
 
*     forward substitution.
      call slv(a(1,0,1),  b(1,1),  n)
      do 10 k=2,nblks
      l = min( bandw, k-1 )
      call ymax(a(1,-l,k),  b(1,k-l),  b(1,k),  n,l*n)
      call slv(a(1,0,k),  b(1,k),  n)
   10 continue
 
*     backward substitution.
      do 20 k=nblks-1,1,-1
      l = min( bandw, nblks-k )
      call ymax(a(1,1,k),  b(1,k+1),  b(1,k),  n,l*n)
   20 continue
 
      return
      end
***********************************************************************
*
*   BTFCT -- BLOCK TRIDIAGONAL MATRIX FACTORIZATION.
*   BTSLV -- BLOCK TRIDIAGONAL MATRIX SOLVE.
*
*   THESE ROUTINES SOLVE UNIFORMLY PARTITIONED LINEAR SYSTEMS A*X=B
*   FOR THE VECTOR X WHEN A IS A BLOCK TRIDIAGONAL MATRIX.  THE ROUTINE
*   BTFCT COMPUTES THE BLOCK LU-FACTORIZATION OF THE COEFFICIENT
*   MATRIX A.  IT IS ASSUMED THAT GAUSSIAN ELIMINATION APPLIED TO A
*   IS STABLE WITHOUT PIVOTING.  THE MATRIX A IS STORED BY BLOCK
*   DIAGONALS.  THE ELEMENTS OF THE FACTORS OVERWRITE THOSE OF A
*   IN THE STANDARD MANNER.  SUBSEQUENT CALLS TO THE ROUTINE BTSLV
*   SOLVES THE SYSTEM, CARRYING OUT THE FORWARD AND BACKWARD
*   SUBSTITUTIONS.
*
*   ARGUMENT  DESCRIPTION
*   --------  -----------
*    NBLKS    THE NUMBER OF PARTITION BLOCKS.
*
*    N        THE NUMBER OF EQUATIONS PER BLOCK.
*
*    D,U,L    ON ENTRY, D, U, AND L CONTAIN THE ELEMENTS OF THE
*             DIAGONAL, UPPER DIAGONAL, AND LOWER DIAGONAL BLOCKS,
*             RESPECTIVELY, OF THE COEFFICIENT MATRIX A.  THEY ARE
*             OVERWRITTEN WITH THE ELEMENTS OF THE LOWER AND UPPER
*             FACTORS.
*        
*    B        ON ENTRY, THE ARRAY CONTAINS THE ELEMENTS OF THE RHS
*             VECTOR AND IS OVERWRITTEN WITH THE SOLUTION VECTOR.
*
*   SUBROUTINES:  BTFCT -- CMAB, FCT, MSLV.
*                 BTSLV -- SLV, YMAX.
*
************************************************************************
      subroutine btfct(nblks,n,  d,u,l)

      integer nblks, n, j
      double precision d(n*n,nblks), u(n*n,nblks), l(n*n,nblks)

      if(n .le. 1) return

      if(n .eq. 2) then
      do 20 j=1,nblks-1
*      d(j) <-- lu decomposition of d(j).
       d(1,j) = 1./d(1,j)
       d(3,j) = d(1,j)*d(3,j)
       d(4,j) = 1./(d(4,j) - d(2,j)*d(3,j))

*      u(j) <-- inverse(d(j))*u(j).
       u(1,j) = d(1,j)*u(1,j)
       u(2,j) = d(4,j)*(u(2,j) - d(2,j)*u(1,j))
       u(1,j) = u(1,j) - d(3,j)*u(2,j)

       u(3,j) = d(1,j)*u(3,j)
       u(4,j) = d(4,j)*(u(4,j) - d(2,j)*u(3,j))
       u(3,j) = u(3,j) - d(3,j)*u(4,j)

*      d(j+1) <-- d(j+1) - l(j+1)*u(j).
       d(1,j+1) = d(1,j+1) - l(1,j+1)*u(1,j) - l(3,j+1)*u(2,j)
       d(2,j+1) = d(2,j+1) - l(2,j+1)*u(1,j) - l(4,j+1)*u(2,j)
       d(3,j+1) = d(3,j+1) - l(1,j+1)*u(3,j) - l(3,j+1)*u(4,j)
       d(4,j+1) = d(4,j+1) - l(2,j+1)*u(3,j) - l(4,j+1)*u(4,j)
   20 continue

*     d(nb) <-- lu decomposition of d(nb).
      d(1,nblks) = 1./d(1,nblks)
      d(3,nblks) = d(1,nblks)*d(3,nblks)
      d(4,nblks) = 1./(d(4,nblks) - d(2,nblks)*d(3,nblks))

      elseif(n .eq. 3) then
      do 30 j=1,nblks-1
*      d(j) <-- lu decomposition of d(j).
       d(1,j) = 1./d(1,j)
       d(4,j) = d(1,j)*d(4,j)
       d(7,j) = d(1,j)*d(7,j)
       d(5,j) = 1./(d(5,j) - d(2,j)*d(4,j))
       d(8,j) = d(5,j)*(d(8,j) - d(2,j)*d(7,j))
       d(6,j) = d(6,j) - d(3,j)*d(4,j)
       d(9,j) = 1./(d(9,j) - d(3,j)*d(7,j) - d(6,j)*d(8,j))

*      u(j) <-- inverse(d(j))*u(j).
       u(1,j) = d(1,j)*u(1,j)
       u(2,j) = d(5,j)*(u(2,j) - d(2,j)*u(1,j))
       u(3,j) = d(9,j)*(u(3,j) - d(6,j)*u(2,j) - d(3,j)*u(1,j))
       u(2,j) = u(2,j) - d(8,j)*u(3,j)
       u(1,j) = u(1,j) - d(4,j)*u(2,j) - d(7,j)*u(3,j)

       u(4,j) = d(1,j)*u(4,j)
       u(5,j) = d(5,j)*(u(5,j) - d(2,j)*u(4,j))
       u(6,j) = d(9,j)*(u(6,j) - d(6,j)*u(5,j) - d(3,j)*u(4,j))
       u(5,j) = u(5,j) - d(8,j)*u(6,j)
       u(4,j) = u(4,j) - d(4,j)*u(5,j) - d(7,j)*u(6,j)

       u(7,j) = d(1,j)*u(7,j)
       u(8,j) = d(5,j)*(u(8,j) - d(2,j)*u(7,j))
       u(9,j) = d(9,j)*(u(9,j) - d(6,j)*u(8,j) - d(3,j)*u(7,j))
       u(8,j) = u(8,j) - d(8,j)*u(9,j)
       u(7,j) = u(7,j) - d(4,j)*u(8,j) - d(7,j)*u(9,j)

*      d(j+1) <-- d(j+1) - l(j+1)*u(j).
       d(1,j+1)=d(1,j+1)-l(1,j+1)*u(1,j)-l(4,j+1)*u(2,j)-l(7,j+1)*u(3,j)
       d(2,j+1)=d(2,j+1)-l(2,j+1)*u(1,j)-l(5,j+1)*u(2,j)-l(8,j+1)*u(3,j)
       d(3,j+1)=d(3,j+1)-l(3,j+1)*u(1,j)-l(6,j+1)*u(2,j)-l(9,j+1)*u(3,j)

       d(4,j+1)=d(4,j+1)-l(1,j+1)*u(4,j)-l(4,j+1)*u(5,j)-l(7,j+1)*u(6,j)
       d(5,j+1)=d(5,j+1)-l(2,j+1)*u(4,j)-l(5,j+1)*u(5,j)-l(8,j+1)*u(6,j)
       d(6,j+1)=d(6,j+1)-l(3,j+1)*u(4,j)-l(6,j+1)*u(5,j)-l(9,j+1)*u(6,j)

       d(7,j+1)=d(7,j+1)-l(1,j+1)*u(7,j)-l(4,j+1)*u(8,j)-l(7,j+1)*u(9,j)
       d(8,j+1)=d(8,j+1)-l(2,j+1)*u(7,j)-l(5,j+1)*u(8,j)-l(8,j+1)*u(9,j)
       d(9,j+1)=d(9,j+1)-l(3,j+1)*u(7,j)-l(6,j+1)*u(8,j)-l(9,j+1)*u(9,j)
   30 continue

*     d(nb) <-- lu decomposition of d(nb).
      d(1,nblks) = 1./d(1,nblks)
      d(4,nblks) = d(1,nblks)*d(4,nblks)
      d(7,nblks) = d(1,nblks)*d(7,nblks)
      d(5,nblks) = 1./(d(5,nblks) - d(2,nblks)*d(4,nblks))
      d(8,nblks) = d(5,nblks)*(d(8,nblks) - d(2,nblks)*d(7,nblks))
      d(6,nblks) = d(6,nblks) - d(3,nblks)*d(4,nblks)
      d(9,nblks) = 1./(d(9,nblks) - d(3,nblks)*d(7,nblks)
     +                              - d(6,nblks)*d(8,nblks))

      else
       do 100 j=1,nblks-1
       call fct(d(1,j),  n)
       call mslv(d(1,j),  u(1,j),  n,n)
       call cmab(l(1,j+1),  u(1,j),  d(1,j+1),  n,n,n)
  100  continue
       call fct(d(1,nblks),  n)
       endif

      return
      end
      subroutine btslv(nblks,n,d,u,l,  b)

      integer nblks, n, j
      double precision d(n*n,nblks), u(n*n,nblks), l(n*n,nblks)
      double precision b(n,nblks)

      if(n .le. 1) return

      if(n .eq. 2) then
*      forward substitution.
*      b(1) <-- inverse(d(1))*b(1)
       b(1,1) = d(1,1)*b(1,1)
       b(2,1) = d(4,1)*(b(2,1) - d(2,1)*b(1,1))
       b(1,1) = b(1,1) - d(3,1)*b(2,1)

       do 20 j=2,nblks
*       b(j) <-- b(j) - l(j)*b(j-1)
        b(1,j) = b(1,j) - l(1,j)*b(1,j-1) - l(3,j)*b(2,j-1)
        b(2,j) = b(2,j) - l(2,j)*b(1,j-1) - l(4,j)*b(2,j-1)

*       b(j) <-- inverse(d(j))*b(j)
        b(1,j) = d(1,j)*b(1,j)
        b(2,j) = d(4,j)*(b(2,j) - d(2,j)*b(1,j))
        b(1,j) = b(1,j) - d(3,j)*b(2,j)
   20  continue

*      backward substitution.
       do 25 j=nblks-1,1,-1
*       b(j) <-- b(j) - u(j)*b(j+1)
        b(1,j) = b(1,j) - u(1,j)*b(1,j+1) - u(3,j)*b(2,j+1)
        b(2,j) = b(2,j) - u(2,j)*b(1,j+1) - u(4,j)*b(2,j+1)
   25  continue

      elseif(n .eq. 3) then
*      forward substitution.
*      b(1) <-- inverse(d(1))*b(1)
       b(1,1) = d(1,1)*b(1,1)
       b(2,1) = d(5,1)*(b(2,1) - d(2,1)*b(1,1))
       b(3,1) = d(9,1)*(b(3,1) - d(6,1)*b(2,1) - d(3,1)*b(1,1))
       b(2,1) = b(2,1) - d(8,1)*b(3,1)
       b(1,1) = b(1,1) - d(4,1)*b(2,1) - d(7,1)*b(3,1)

       do 30 j=2,nblks
*       b(j) <-- b(j) - l(j)*b(j-1)
        b(1,j) = b(1,j)-l(1,j)*b(1,j-1)-l(4,j)*b(2,j-1)-l(7,j)*b(3,j-1)
        b(2,j) = b(2,j)-l(2,j)*b(1,j-1)-l(5,j)*b(2,j-1)-l(8,j)*b(3,j-1)
        b(3,j) = b(3,j)-l(3,j)*b(1,j-1)-l(6,j)*b(2,j-1)-l(9,j)*b(3,j-1)

*       b(j) <-- inverse(d(j))*b(j)
        b(1,j) = d(1,j)*b(1,j)
        b(2,j) = d(5,j)*(b(2,j) - d(2,j)*b(1,j))
        b(3,j) = d(9,j)*(b(3,j) - d(6,j)*b(2,j) - d(3,j)*b(1,j))
        b(2,j) = b(2,j) - d(8,j)*b(3,j)
        b(1,j) = b(1,j) - d(4,j)*b(2,j) - d(7,j)*b(3,j)
   30  continue

*      backward substitution.
       do 35 j=nblks-1,1,-1
*       b(j) <-- b(j) - u(j)*b(j+1)
        b(1,j) = b(1,j)-u(1,j)*b(1,j+1)-u(4,j)*b(2,j+1)-u(7,j)*b(3,j+1)
        b(2,j) = b(2,j)-u(2,j)*b(1,j+1)-u(5,j)*b(2,j+1)-u(8,j)*b(3,j+1)
        b(3,j) = b(3,j)-u(3,j)*b(1,j+1)-u(6,j)*b(2,j+1)-u(9,j)*b(3,j+1)
   35  continue

      else
*      forward substitution.
       call slv(d(1,1),  b(1,1),  n)
       do 110 j=2,nblks
       call ymax(l(1,j),  b(1,j-1),  b(1,j),  n,n)
       call slv(d(1,j),  b(1,j),  n)
  110  continue

*      backward substitution
       do 120 j=nblks-1,1,-1
       call ymax(u(1,j),  b(1,j+1),  b(1,j),  n,n)
  120  continue
       endif

      return
      end
************************************************************************
*
*   VFCT  -- VECTOR OF MATRIX FACTORIZATIONS.
*   VSLV  -- VECTOR OF FORWARD AND BACKWARD SOLVES.
*   VMSLV -- VECTOR OF FORWARD AND BACKWARD MATRIX SOLVES.
*
*   THESE ROUTINES SOLVE "VECTORS" OF LINEAR SYSTEMS A*X=B FOR X WHERE
*   A IS A SQUARE MATRIX AND EITHER B AND X ARE BOTH VECTORS OR BOTH
*   MATRICES.  THE ROUTINE VFCT COMPUTES THE LU-FACTORIZATION OF EACH
*   COEFFICIENT MATRIX A.  IT IS ASSUMED THAT GAUSSIAN ELIMINATION
*   APPLIED TO EACH A IS STABLE WITHOUT PIVOTING.  THE ELEMENTS OF THE
*   FACTORS OVERWRITE THOSE OF A IN THE STANDARD MANNER.  A SUBSEQUENT
*   CALL TO THE ROUTINE VSLV THEN SOLVES THE SYSTEMS WHEN THE B'S ARE
*   VECTORS, CARRYING OUT THE FORWARD AND BACKWARD SUBSTITUTIONS.  THE
*   ROUTINE VMSLV SOLVES THE SYSTEMS WHEN THE B'S ARE MATRICIES.
*
*   ARGUMENT   DESCRIPTION
*   --------   -----------
*     NM       NUMBER OF MATRICES.
*
*     N        ORDER OF THE COEFFICIENT MATRICES A.  THIS IMPLIES
*              THAT EITHER B IS AN N-VECTOR OR HAS N ROWS.
*
*     NCB      THE NUMBER OF COLUMNS OF THE MATRICES B.
*
*     A        ON ENTRY, THE ARRAY CONTAINS THE ELEMENTS OF THE
*              COEFFICIENT MATRICES.  IT IS OVERWRITTEN WITH THE
*              FACTORIZATIONS.
*
*     B        ON ENTRY, THE VECTOR CONTAINS THE ELEMENTS OF THE RHS
*              VECTORS OR MATRICES.  IT IS OVERWRITTEN WITH THE
*              SOLUTION.
*
************************************************************************
      subroutine vfct(nm,  a,  n)

      integer nm, n, i, j, k, l
      double precision a(n,n,nm)

      do 10 k=1,n
      do 11 j=1,k-1
      do 12 i=1,j-1
      do 12 l=1,nm
      a(j,k,l) = a(j,k,l) - a(j,i,l)*a(i,k,l)
   12 a(k,j,l) = a(k,j,l) - a(i,j,l)*a(k,i,l)
      do 11 l=1,nm
      a(j,k,l) = a(j,j,l)*a(j,k,l)
   11 a(k,k,l) = a(k,k,l) - a(k,j,l)*a(j,k,l)
      do 10 l=1,nm
   10 a(k,k,l) = 1./a(k,k,l)

      return
      end
      subroutine vslv(nm,  a,b,  n)

      integer nm, n, j, k, l
      double precision a(n,n,nm), b(n,nm)

*     forward substitution.
      do 10 k=1,n
      do 11 j=1,k-1
      do 11 l=1,nm
   11 b(k,l) = b(k,l) - a(k,j,l)*b(j,l)
      do 10 l=1,nm
   10 b(k,l) = a(k,k,l)*b(k,l)

*     backward substitution.
      do 20 k=n-1,1,-1
      do 20 j=k+1,n
      do 20 l=1,nm
   20 b(k,l) = b(k,l) - a(k,j,l)*b(j,l)

      return
      end
      subroutine vmslv(nm,  a,b,  n,ncb)

      integer nm, n, ncb, i, j, k, l
      double precision a(n,n,nm), b(n,ncb,nm)

*     forward substitution.
      do 10 k=1,n
      do 11 j=1,k-1
      do 11 i=1,ncb
      do 11 l=1,nm
   11 b(k,i,l) = b(k,i,l) - a(k,j,l)*b(j,i,l)
      do 10 i=1,ncb
      do 10 l=1,nm
   10 b(k,i,l) = a(k,k,l)*b(k,i,l)

*     backward substitution.
      do 20 k=n-1,1,-1
      do 20 j=k+1,n
      do 20 i=1,ncb
      do 20 l=1,nm
   20 b(k,i,l) = b(k,i,l) - a(k,j,l)*b(j,i,l)

      return
      end
************************************************************************
*
*   FCT  -- MATRIX FACTORIZATION.
*   SLV  -- FORWARD AND BACKWARD SOLVE.
*   MSLV -- FORWARD AND BACKWARD MATRIX SOLVE.
*
*   THESE ROUTINES SOLVE LINEAR SYSTEMS OF THE FORM A*X=B FOR X WHERE
*   A IS A SQUARE MATRIX AND B AND X ARE EITHER BOTH VECTORS OR BOTH
*   MATRICES.  THE ROUTINE FCT COMPUTES THE LU-FACTORIZATION OF THE
*   COEFFICIENT MATRIX A.  IT IS ASSUMED THAT GAUSSIAN ELIMINATION
*   APPLIED TO A IS STABLE WITHOUT PIVOTING.  THE ELEMENTS OF THE
*   FACTORS OVERWRITE THOSE OF A IN THE STANDARD MANNER.  A SUBSEQUENT
*   CALL TO THE ROUTINE SLV THEN SOLVES THE SYSTEM WHEN B IS A VECTOR,
*   CARRYING OUT THE FORWARD AND BACKWARD SUBSTITUTIONS.  THE ROUTINE
*   MSLV SOLVES THE SYSTEM WHEN B IS A MATRIX.
*
*   ARGUMENT  DESCRIPTION
*   --------  -----------
*    N        ORDER OF THE MATRIX A.  THIS IMPLIES THAT B IS A N-VECTOR
*             AND THAT B HAS N ROWS.
*                      
*    NCB      NUMBER OF COLUMNS OF THE MATRIX B.
*
*    A        ARRAY CONTAINING EITHER THE ELEMENTS OF THE COEFFICIENT
*             MATRIX A OR THE ELEMENTS OF ITS LOWER AND UPPER FACTORS.
*                      
*    B        ON INPUT THE ARRAY CONTAINS THE ELEMENTS OF THE RIGHT
*             HAND SIDE VECTOR (MATRIX) AND IS OVERWRITTEN WITH THE
*             SOLUTION VECTOR (MATRIX).
*
************************************************************************
      subroutine fct(a,n)

      double precision a(*)
      integer n, i, j, k, ld, la
 
      if(n .le. 1) return

      if(n .eq. 2) then
       a(1) = 1./a(1)
       a(3) = a(1)*a(3)
       a(4) = 1./(a(4) - a(2)*a(3))

      elseif(n .eq. 3) then
       a(1) = 1./a(1)
       a(4) = a(1)*a(4)
       a(7) = a(1)*a(7)
       a(5) = 1./(a(5) - a(2)*a(4))
       a(8) = a(5)*(a(8) - a(2)*a(7))
       a(6) = a(6) - a(3)*a(4)
       a(9) = 1./(a(9) - a(3)*a(7) - a(6)*a(8))

      elseif(n .eq. 4) then
       a(1)  = 1./a(1)
       a(5)  = a(1)*a(5)
       a(9)  = a(1)*a(9)
       a(13) = a(1)*a(13)
       a(6)  = 1./(a(6) - a(2)*a(5))
       a(10) = a(6)*(a(10) - a(2)*a(9))
       a(14) = a(6)*(a(14) - a(2)*a(13))
       a(7)  = a(7) - a(3)*a(5)
       a(8)  = a(8) - a(4)*a(5)
       a(11) = 1./(a(11) - a(3)*a(9) - a(7)*a(10))
       a(15) = a(11)*(a(15) - a(3)*a(13) - a(7)*a(14))
       a(12) = a(12) - a(4)*a(9) - a(8)*a(10)
       a(16) = 1./(a(16) - a(4)*a(13) - a(8)*a(14) - a(12)*a(15))

      else
       ld = 1
       do 10 k=1,n-1
       a(ld) = 1./a(ld)
       la = ld
       do 11 j=1,n-k
       la = la + n
       a(la) = a(la)*a(ld)
       do 11 i=1,n-k
   11  a(i+la) = a(i+la) - a(i+ld)*a(la)
       ld = ld + n + 1
   10  continue
       a(ld) = 1./a(ld)
       endif

      return
      end
      subroutine slv(a,b,n)

      integer n, j, k, ld, la
      double precision a(*), b(*)
 
      if(n .le. 1) return

      if(n .eq. 2) then
       b(1) = a(1)*b(1)
       b(2) = a(4)*(b(2) - a(2)*b(1))
       b(1) = b(1) - a(3)*b(2)

      elseif(n .eq. 3) then
       b(1) = a(1)*b(1)
       b(2) = a(5)*(b(2) - a(2)*b(1))
       b(3) = a(9)*(b(3) - a(3)*b(1) - a(6)*b(2))
       b(2) = b(2) - a(8)*b(3)
       b(1) = b(1) - a(4)*b(2) - a(7)*b(3)

      elseif(n .eq. 4) then
       b(1) = a(1)*b(1)
       b(2) = a( 6)*(b(2) - a(2)*b(1))
       b(3) = a(11)*(b(3) - a(3)*b(1) - a(7)*b(2))
       b(4) = a(16)*(b(4) - a(4)*b(1) - a(8)*b(2) - a(12)*b(3))
       b(3) = b(3) - a(15)*b(4)
       b(2) = b(2) - a(10)*b(3) - a(14)*b(4)
       b(1) = b(1) - a( 5)*b(2) - a( 9)*b(3) - a(13)*b(4)

      else
       ld = 1
       b(1) = b(1)*a(1)
       do 10 k=2,n
       ld = ld + n + 1
       la = ld
       do 11 j=k-1,1,-1
       la = la - n
   11  b(k) = b(k) - a(la)*b(j)
   10  b(k) = b(k)*a(ld)
 
       do 20 k=n-1,1,-1
       ld = ld - n - 1
       la = ld
       do 20 j=k+1,n
       la = la + n
   20  b(k) = b(k) - a(la)*b(j)
       endif

      return
      end
      subroutine mslv(a,b,n,ncb)

      integer n, ncb, i, j, k, ld, la
      double precision a(*), b(*)
 
      if(n .le. 1) return

      if(n .eq. 2) then
       do 20 i=0,ncb-1
       b(2*i+1) = a(1)*b(2*i+1)
       b(2*i+2) = a(4)*(b(2*i+2) - a(2)*b(2*i+1))
       b(2*i+1) = b(2*i+1) - a(3)*b(2*i+2)
   20  continue

      elseif(n .eq. 3) then
       do 30 i=0,ncb-1
       b(3*i+1) = a(1)*b(3*i+1)
       b(3*i+2) = a(5)*(b(3*i+2) - a(2)*b(3*i+1))
       b(3*i+3) = a(9)*(b(3*i+3) - a(3)*b(3*i+1) - a(6)*b(3*i+2))
       b(3*i+2) = b(3*i+2) - a(8)*b(3*i+3)
       b(3*i+1) = b(3*i+1) - a(4)*b(3*i+2) - a(7)*b(3*i+3)
   30  continue

      elseif(n .eq. 4) then
       do 40 i=0,ncb-1
       b(4*i+1) = a(1)*b(4*i+1)
       b(4*i+2) = a( 6)*(b(4*i+2) - a(2)*b(4*i+1))
       b(4*i+3) = a(11)*(b(4*i+3) - a(3)*b(4*i+1) - a(7)*b(4*i+2))
       b(4*i+4) = a(16)*(b(4*i+4) - a(4)*b(4*i+1) - a(8)*b(4*i+2)
     +                                            - a(12)*b(4*i+3))
       b(4*i+3) = b(4*i+3) - a(15)*b(4*i+4)
       b(4*i+2) = b(4*i+2) - a(10)*b(4*i+3) - a(14)*b(4*i+4)
       b(4*i+1) = b(4*i+1) - a( 5)*b(4*i+2) - a( 9)*b(4*i+3)
     +                                      - a(13)*b(4*i+4)
   40  continue

      else
       ld = 1
       do 110 i=0,ncb-1
  110  b(1+n*i) = a(1)*b(1+n*i)

       do 120 k=2,n
       ld = ld + n + 1
       la = ld
       do 121 j=k-1,1,-1
       la = la - n
       do 121 i=0,ncb-1
  121  b(k+n*i) = b(k+n*i) - a(la)*b(j+n*i)
       do 120 i=0,ncb-1
  120  b(k+n*i) = a(ld)*b(k+n*i)

       do 130 k=n-1,1,-1
       ld = ld - n - 1
       la = ld
       do 130 j=k+1,n
       la = la + n
       do 130 i=0,ncb-1
       b(k+n*i) = b(k+n*i) - a(la)*b(j+n*i)
  130  continue
       endif

      return
      end
************************************************************************
*
*   YMAX -- VECTOR MINUS MATRIX-VECTOR PRODUCT.
*   CMAB -- MATRIX MINUS MATRIX-MATRIX PRODUCT.
*
*   THESE ROUTINES COMPUTE THE TERMS Y-A*X AND C-A*B RESPECTIVELY
*   WHERE A, B, AND C ARE MATRICES AND X AND Y ARE VECTORS.  THESE
*   ARE NOT GENERAL ROUTINES AND ARE INTENDED TO BE USED ONLY BY
*   BBFCT AND BBSLV.
*
*   ARGUMENT  DESCRIPTION
*   --------  -----------
*   NRA,NCA   NUMBER OF ROWS AND COLUMNS OF A.  THIS IMPLIES THAT B
*             HAS NCA ROWS AND THAT C HAS NRA ROWS.
*
*    NCB      NUMBER OF COLUMNS OF B.  THIS IMPLIES THAT C HAS NCB
*             COLUMNS
*
*    A,B,C    ARRAYS CONTAINING THE ELEMENTS OF THE MATRICES A, B AND C.
*
*    X,Y      ARRAYS CONTAINING THE ELEMENTS OF THE VECTORS X AND Y.
*
************************************************************************
      subroutine ymax(a,x,y,nra,nca)

      integer nra, nca, i, j
      double precision a(nra,nca), x(nca), y(nra)
      
      do 10 i=1,nra
      do 10 j=1,nca
   10 y(i) = y(i) - a(i,j)*x(j)
 
      return
      end
      subroutine cmab(a,b,c,nra,nca,ncb)

      integer nra, nca, ncb, i, j, k
      double precision a(nra,nca), b(nca,ncb), c(nra,ncb)
 
      do 10 i=1,nra
      do 10 k=1,nca
      do 10 j=1,ncb
   10 c(i,j) = c(i,j) - a(i,k)*b(k,j)
 
      return
      end
