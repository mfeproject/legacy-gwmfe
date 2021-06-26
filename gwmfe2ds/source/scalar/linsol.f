      subroutine linsol(b)
************************************************************************
*
*   LINSOL -- Linear equation solver.
*
************************************************************************
      include "parameters.h"
      
      integer nnod,ntri
      common /mfe010/ nnod,ntri

      double precision s
      integer bandw,xadj,adjncy
      common /mfe040/ s(smax),bandw,xadj(mnod+1),adjncy(2*medg)

      double precision b(*)

      if(.true.) then
*       ----------------------
*        Block banded solver.
*       ----------------------
        call bbslv(nnod,3,bandw,s,  b)

      else
C*       ------------------------
C*        Block envelope solver.
C*       ------------------------
C*       Input RHS vector to BENVPAK and solve.
C        call inrhs(b,  s)
C        call solve(s)
C
C*       Copy solution from S.
C        do 10 j=1,3*nnod
C   10   b(j) = s(j)
        endif

      return
      end
