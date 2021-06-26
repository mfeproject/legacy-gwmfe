      subroutine voltage(y,bandw,a)
************************************************************************
*
*   VOLTAGE -- Solve the voltage equation.
*
************************************************************************
      include "parameters.h"
      
      integer nepn
      parameter(nepn=npde+2)

      double precision g7w,g7a0,g7a1,g7a2
      common /g2d7/ g7w(7),g7a0(7),g7a1(7),g7a2(7)

      double precision uscf,vscf
      common /data1/ uscf,vscf

      integer nnod,ntri,tvtx
      common /mfe010/ nnod,ntri /mfe011/ tvtx(0:2,mtri)

      double precision bv
      integer nbnod,bnod,bc
      common /mfe030/ bv(nepn,mbnd),nbnod,bnod(2,mbnd),bc(nepn,10)

      double precision lambda,eps,usera
      common /mfe100/ lambda,eps,usera(23)

      integer bandw,i,j,k,vtx0,vtx1,vtx2,jbnod,jbc
      double precision y(nepn,nnod),a(0:bandw,nnod),b(mnod)
      double precision u0,x0,y0,u1,x1,y1,u2,x2,y2
      double precision dx0,dx1,dx2,dy0,dy1,dy2,area
      double precision a00,a10,a20,a11,a21,a22,fa0,fa1,fa2,fatuk,bval
*     ==================================================================
*      Zero the storage for the stiffness matrix and RHS vector.
*     ==================================================================
      do 110 i=0,bandw
      do 110 j=1,nnod
  110 a(i,j) = 0.

      do 120 j=1,nnod
  120 b(j) = 0.
*     ==================================================================
*      Compute the stiffness matrix and RHS vector triangle by triangle.
*     ==================================================================
      do 200 j=1,ntri
        vtx0 = tvtx(0,j)
        vtx1 = tvtx(1,j)
        vtx2 = tvtx(2,j)
*       -----------------------------
*        Gather the local variables.
*       -----------------------------
        u0 = y(1,vtx0)
        x0 = y(3,vtx0)
        y0 = y(4,vtx0)
        u1 = y(1,vtx1)
        x1 = y(3,vtx1)
        y1 = y(4,vtx1)
        u2 = y(1,vtx2)
        x2 = y(3,vtx2)
        y2 = y(4,vtx2)
*       ------------------------------------------------
*        Differences along the edges and triangle area.
*       ------------------------------------------------
        dx0 = x2 - x1
        dx1 = x0 - x2
        dx2 = x1 - x0
        dy0 = y2 - y1
        dy1 = y0 - y2
        dy2 = y1 - y0
        area = .5*(dx1*dy2 - dx2*dy1)
*       ----------------------------------------------------------
*        Lower triangular elements of the local stiffness matrix.
*       ----------------------------------------------------------
        a00 = (.25/area)*(dx0*dx0 + dy0*dy0)
        a10 = (.25/area)*(dx1*dx0 + dy1*dy0)
        a20 = (.25/area)*(dx2*dx0 + dy2*dy0)
        a11 = (.25/area)*(dx1*dx1 + dy1*dy1)
        a21 = (.25/area)*(dx2*dx1 + dy2*dy1)
        a22 = (.25/area)*(dx2*dx2 + dy2*dy2)
*       ------------------------------------------------------------
*        Local RHS vector using a 7-pt gaussian quadrature formula.
*       ------------------------------------------------------------
        fa0 = 0.
        fa1 = 0.
        fa2 = 0.
        do 210 k=1,7
         fatuk = (1.-exp(uscf*(u0*g7a0(k)+u1*g7a1(k)+u2*g7a2(k))))/vscf
         fa0 = fa0 + g7w(k)*fatuk*g7a0(k)
         fa1 = fa1 + g7w(k)*fatuk*g7a1(k)
         fa2 = fa2 + g7w(k)*fatuk*g7a2(k)
  210   continue
        fa0 = area*fa0
        fa1 = area*fa1
        fa2 = area*fa2
*       ----------------------------------------------------
*        Scatter the local stiffness matrix and RHS vector.
*       ----------------------------------------------------
        b(vtx0) = b(vtx0) - fa0
        b(vtx1) = b(vtx1) - fa1
        b(vtx2) = b(vtx2) - fa2

        a(0,vtx0) = a(0,vtx0) + a00
        a(0,vtx1) = a(0,vtx1) + a11
        a(0,vtx2) = a(0,vtx2) + a22

        if(vtx1 .gt. vtx0) then
         a(vtx1-vtx0,vtx0) = a(vtx1-vtx0,vtx0) + a10
        else
         a(vtx0-vtx1,vtx1) = a(vtx0-vtx1,vtx1) + a10
         endif

        if(vtx2 .gt. vtx0) then
         a(vtx2-vtx0,vtx0) = a(vtx2-vtx0,vtx0) + a20
        else
         a(vtx0-vtx2,vtx2) = a(vtx0-vtx2,vtx2) + a20
         endif

        if(vtx2 .gt. vtx1) then
         a(vtx2-vtx1,vtx1) = a(vtx2-vtx1,vtx1) + a21
        else
         a(vtx1-vtx2,vtx2) = a(vtx1-vtx2,vtx2) + a21
         endif
  200 continue
*     ==================================================================
*      Modify the equations for Dirichlet boundary conditions.
*     ==================================================================
      do 300 j=1,nbnod

        jbnod = bnod(1,j)
        jbc   = bnod(2,j)
        if(bc(2,jbc) .ne. 1) go to 300

        bval = bv(2,j)

        do 320 i=1,min(bandw,nnod-jbnod)
         b(jbnod+i) = b(jbnod+i) - bval*a(i,jbnod)
         a(i,jbnod) = 0.
  320   continue

        do 310 i=1,min(bandw,jbnod-1)
         b(jbnod-i) = b(jbnod-i) - bval*a(i,jbnod-i)
         a(i,jbnod-i) = 0.
  310   continue

        a(0,jbnod) = 1.
        b(jbnod) = bval

  300 continue
*     ==================================================================
*      Solve the equations.
*     ==================================================================
      call sbfct(nnod,bandw,a)
      call sbslv(nnod,bandw,a,b)

*     Store the solution.
      do 400 j=1,nnod
  400 y(2,j) = b(j)

      return
      end
