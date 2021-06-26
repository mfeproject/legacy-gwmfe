************************************************************************
*
*   SBFCT -- SYMMETRIC BANDED MATRIX FACTORIZATION.
*   SBSLV -- SYMMETRIC BANDED MATRIX SOLVE.
*
*   THESE ROUTINES SOLVE LINEAR SYSTEMS A*X=B FOR THE VECTOR X WHEN A
*   IS A SYMMETRIC BANDED MATRIX.  THE ROUTINE SBFCT COMPUTES THE
*   LOWER CHOLESKI FACTOR OF THE COEFFICIENT MATRIX A.  IT IS ASSUMED
*   THAT GAUSSIAN ELIMINATION APPLIED TO A IS STABLE WITHOUT PIVOTING.
*   THE LOWER TRIANGULAR PART OF THE MATRIX A IS STORED BY COLUMN
*   AND THE ELEMENTS OF THE LOWER FACTOR OVERWRITE THOSE OF A IN THE
*   STANDARD MANNER.  SUBSEQUENT CALLS TO THE ROUTINE SBSLV SOLVE THE
*   SYSTEM, CARRYING OUT THE FORWARD AND BACKWARD SUBSTITUTIONS.
*
*   ARGUMENT  DESCRIPTION
*   --------  -----------
*    NEQNS    THE NUMBER OF EQATIONS.
*
*    BANDW    THE BANDWIDTH OF THE MATRIX.  THE BANDWIDTH IS DEFINED
*             TO BE THE MAX { |I-J| : AIJ .NE. 0 }.
*
*    A        ARRAY CONTAINING EITHER THE LOWER TRIANGULAR ELEMENTS OF
*             THE COEFFICIENT MATRIX A OR THE ELEMENTS OF ITS LOWER
*             CHOLESKI FACTOR.  THE ELEMENTS ARE STORED BY COLUMN SO
*             THAT AIJ, I.GE.J, IS STORED IN A(I-J,J).
*                      
*    B        ON INPUT THE ARRAY CONTAINS THE ELEMENTS OF THE RHS
*             VECTOR AND IS OVERWRITTEN WITH THE SOLUTION VECTOR.
*
************************************************************************
      subroutine sbfct(neqn,bandw,a)

      integer neqn,bandw,i,j,k
      double precision a(0:bandw,neqn)

      do 10 j=1,neqn
      do 11 k=1,min(bandw,j-1)
      do 11 i=0,min(bandw-k,neqn-j)
   11 a(i,j) = a(i,j) - a(k,j-k)*a(k+i,j-k)
      a(0,j) = 1./sqrt(a(0,j))
      do 10 i=1,min(bandw,neqn-j)
   10 a(i,j) = a(0,j)*a(i,j)

      return
      end
      subroutine sbslv(neqn,bandw,a,b)

      integer neqn,bandw,i,j
      double precision a(0:bandw,neqn),b(neqn)

      do 10 j=1,neqn
      b(j) = a(0,j)*b(j)
      do 10 i=1,min(bandw,neqn-j)
   10 b(j+i) = b(j+i) - b(j)*a(i,j)

      do 20 j=neqn,1,-1
      do 21 i=1,min(bandw,neqn-j)
   21 b(j) = b(j) - a(i,j)*b(j+i)
   20 b(j) = a(0,j)*b(j)

      return
      end
