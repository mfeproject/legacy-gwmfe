************************************************************************
*
*   This library consists of various Fortran routines which are useful
*   in generating the triangular meshes for the 2D MFE codes.  The
*   following is a very brief description of the routines.  See the
*   documentation for full details.
*
*   Routines for generating the triangle vertex list for triangulations
*   obtained from logically retangular grids by adding diagonals:
*
*       TRIRG -- selects one of the following meshes.
*       TSYM  -- Symmetric mesh.
*       TSYMV -- Variant of TSYM.
*       TRHX  -- Right-handed hexagonal mesh.
*       TLHX  -- Left-handed hexagonal mesh.
*       THHR  -- Horizontal-herringbone hexagonal mesh.
*       THHRV -- Variant of THHR.
*       TVHR  -- Vertical-herringbone hexagonal mesh.
*       TVHRV -- Variant of TVHR.
*
*   The corresponding routines for generating the edge-two-triangle/
*   edge-one-triangle vertex list.
*
*       EDGRG -- selects one of the following meshes.
*       ESYM  -- Symmetric mesh.
*       ESYMV -- Variant of ESYM.
*       ERHX  -- Right-handed hexagonal mesh.
*       ELHX  -- Left-handed hexagonal mesh.
*       EHHR  -- Horizontal-herringbone hexagonal mesh.
*       EHHRV -- Variant of EHHR.
*       EVHR  -- Vertical-herringbone hexagonal mesh.
*       EVHRV -- Variant of EVHR.
*
*   The following routines generate the adjacency structure of the
*   nodes in an arbitrary triangulation.
*
*       FNADJT -- Find adjacency structure from triangle vertex list.
*       FNADJE -- Find adjacency structure from edge vertex list.
*
*   
*   The following routines are associated with triangulations obtained
*   by globally subdividing unstructured triangular meshes.  The data
*   structure is based on that described by R. Bank.  (These are
*   undocumented and possibly buggy.)
*
*       REFINE -- Globally refines unstructured triangulations.
*       FNTVTX -- Generates the triangle vertex list.
*       FNEVTX -- Generates the edge vertex list.
*
*   Miscellaneous routines:
*
*       FILSEG  -- Generates a refined discretization of an interval.
*
*   These low level routines are also available: T0, T1, D0, D1, HE00,
*   HE10, HE01, HE11, VE00, VE10, VE01, VE11, BB0, BB1, RB0, RB1, TB0,
*   TB1, LB0 and LB1.  See the documentation for their use.
*
************************************************************************
************************************************************************
*
*   The following routines generate the triangle vertex list and the
*   edge-two-triangle/edge-one-triangle vertex list for triangulations
*   obtained by adding diagonals to a logically rectangular grid.  The
*   routines described here are
*
*       trirg, tsym, tsymv, trhx, tlhx, thhr, thhrv, tvhr, and tvhrv,
*       which generate the triangle vertex list;
*
*       edgrg, esym, esymv, erhx, elhx, ehhr, ehhrv, evhr, and evhrv,
*       which generate the edge-two-triangle/edge-one-triangle vertex
*       list.
*
*   See the diagrams below for the specific type of triangulation each
*   routine generates.  The routines "trirg" and "edgrg" are special
*   driver routines which call one of the other routines specified by
*   the value of the flag TYPE.  Thus one may either directly call the
*   specific routines which generate the type of mesh desired or call
*   "trirg" and "edgrg" with the appropriate choice of TYPE.  The call
*   sequences for "trirg" and "edgrg" are
*
*       call trirg(ncol,nrow,type,  ntr,l),
*       call edgrg(ncol,nrow,type,  nedg,niedg,nbedg,l).
*
*   The call sequence for the routines which generate the triangle
*   vertex list (routines prefixed with a 't') is
*
*       call t???(ncol,nrow,  ntr,l),
*
*   and that for the routines which generate the edge vertex list
*   (routines prefixed with a 'e') is
*
*       call e???(ncol,nrow,  nedg,niedg,nbedg,l)
*
*   The arguments are described below.
*
*     NCOL, NROW -- the number of grid columns and rows respectively.
*     The columns are numbered consecutively from left to right and the
*     rows are numbered consecutively from bottom to top.  The (i,j)th
*     node of the mesh lies on the intersection of the ith column and
*     the jth row.  The nodes are numbered by row from left to right
*     beginning with the bottom-most row.
*
*     TYPE -- an integer which specifies type of triangulation.  The
*     allowed values are
*
*         TYPE = 11, 12 <==> 'symmetric' meshes;
*         TYPE = 21, 22 <==> 'biased' hexagonal meshes;
*         TYPE = 31, 32, 33, 34 <==> 'herringbone' hexagonal meshes.
*
*     See the diagrams below for specific details.  If TYPE is not
*     assigned one of these values nothing is done.
*
*   The following arguments are returned values:
*
*     NTR -- the number of triangles in the mesh.
*     NEDG -- the number of edges in the mesh; NEDG=NIEDG+NBEDG.
*     NIEDG -- the number of interior edges in the mesh.
*     NBEDG -- the number of boundary edges in the mesh.
*
*     L -- the array of node numbers of the vertices of the triangles
*     or edges.  For the triangle routines, the array L must have
*     length at least 3*NTR.  When dimensioned (0:2,NTR), the second
*     index corresponds to the triangle (1 through NTR) and the first
*     index corresponds to the vertex (0, 1 or 2).  Thus L(k,j) is the
*     node number of the kth vertex of triangle j.  For each triangle,
*     the vertices 0, 1, and 2 are oriented counter-clockwise about
*     the triangle.  For the edge routines, the array L must have
*     length at least 4*NEDG.  When dimensioned (0:3,NEDG), the second
*     index corresponds to the edge (1 through NEDG) and the first
*     index corresponds to the vertex (0, 1, 2, or 3).  Vertices 0
*     and 1 are the endpoints of the edge itself and vertices 2 and 3
*     are the remaining vertices of the two triangles which share this
*     common edge.  Vertices 0, 1 and 2 are oriented counter-clockwise
*     about one of the triangles.  Vertices 0, 3 and 1 have the same
*     orientation about the other.  This describes the case for
*     interior edges (edge-two-triangles).  For boundary edges
*     (edge-one-triangles), there is only a single triangle which has
*     the edge 01 as an edge.  In this case L(3,.) is assigned the
*     value zero.  The vertices for all edge-two-triangles come first
*     in L (second index ranging from 1 through NIEDG) and the edge-
*     one-triangles come last (second index ranging from NIEDG+1
*     through NEDG).  The details on how the vertices are labeled are
*     documented elsewhere in this library.
*
*
*   MESH TYPES
*   ----------
*
*     Symmetric Meshes
*     ----------------
*       The diagonals alternate between    |\|/|\|/      TYPE=11
*       the 45 and -45 degree diagonals    +-+-+-+-
*       in both the horizontal and         |/|\|/|\   Routines "tsym"
*       vertical directions, beginning     +-+-+-+-   and "esym".
*       with the 45 degree diagonal in     |\|/|\|/
*       the lower left corner of the       +-+-+-+-
*       grid.                              |/|\|/|\
*                                          +-+-+-+-
*
*       This is a variant of the above     |/|\|/|\      TYPE=12
*       mesh which begins with the -45     +-+-+-+-
*       degree diagonal in the lower       |\|/|\|/   Routines "tsymv"
*       left corner of the grid.           +-+-+-+-   and "esymv".
*                                          |/|\|/|\
*                                          +-+-+-+-
*                                          |\|/|\|/
*                                          +-+-+-+-
*
*     Biased Hexagonal Meshes
*     -----------------------
*       Right-handed hexagonal mesh.       |/|/|/|/      TYPE=21
*       All diagonals are 45 degree        +-+-+-+-
*       diagonals.                         |/|/|/|/   Routines "trhx"
*                                          +-+-+-+-   and "erhx".
*                                          |/|/|/|/
*                                          +-+-+-+-
*                                          |/|/|/|/
*                                          +-+-+-+-
*
*       Left-handed hexagonal mesh.        |\|\|\|\      TYPE=22
*       All diagonals are -45 degree       +-+-+-+-
*       diagonals.                         |\|\|\|\   Routines "tlhx"
*                                          +-+-+-+-   and "elhx".
*                                          |\|\|\|\
*                                          +-+-+-+-
*                                          |\|\|\|\
*                                          +-+-+-+-
*
*     Herringbone Hexagonal Meshes
*     ----------------------------
*       Horizontal herringbone mesh.  The  |\|\|\|\      TYPE=31
*       diagonals alternate between the    +-+-+-+-
*       45 and -45 degree diagonals in     |/|/|/|/   Routines "thhr"
*       the vertical direction, beginning  +-+-+-+-   and "ehhr".
*       with 45 degree diagonals along     |\|\|\|\
*       the bottom of the grid.            +-+-+-+-
*                                          |/|/|/|/
*                                          +-+-+-+-
*
*       This is a variant of the above     |/|/|/|/      TYPE=32
*       mesh which begins with -45 degree  +-+-+-+-
*       diagonals along the bottom of the  |\|\|\|\   Routines "thhrv"
*       grid.                              +-+-+-+-   and "ehhrv".
*                                          |/|/|/|/
*                                          +-+-+-+-
*                                          |\|\|\|\
*                                          +-+-+-+-
*
*       Vertical herringbone mesh.  The    |/|\|/|\      TYPE=33
*       diagonals alternate between the    +-+-+-+-
*       45 and -45 degree diagonals in     |/|\|/|\   Routines "tvhr"
*       the horizontal direction, begin-   +-+-+-+-   and "evhr".
*       ning with 45 degree diagonals      |/|\|/|\
*       along the left side of the grid.   +-+-+-+-
*                                          |/|\|/|\
*                                          +-+-+-+-
*
*       This is a variant of the above     |\|/|\|/      TYPE=34
*       mesh which begins with -45 degree  +-+-+-+-
*       diagonals along the left side of   |\|/|\|/   Routines "tvhrv"
*       the grid.                          +-+-+-+-   and "evhrv".
*                                          |\|/|\|/
*                                          +-+-+-+-
*                                          |\|/|\|/
*                                          +-+-+-+-
*
************************************************************************
      subroutine trirg(ncol,nrow,type,  ntr,l)
************************************************************************
*
*   Generates the triangle vertex list by calling the appropriate
*   routine for the mesh specified by TYPE.
*
************************************************************************
      integer ncol, nrow, type, ntr, l(1)

      if(type .eq. 11) then
       call tsym(ncol,nrow,  ntr,l)

      elseif(type .eq. 12) then
       call tsymv(ncol,nrow,  ntr,l)

      elseif(type .eq. 21) then
       call trhx(ncol,nrow,  ntr,l)

      elseif(type .eq. 22) then
       call tlhx(ncol,nrow,  ntr,l)

      elseif(type .eq. 31) then
       call thhr(ncol,nrow,  ntr,l)

      elseif(type .eq. 32) then
       call thhrv(ncol,nrow,  ntr,l)

      elseif(type .eq. 33) then
       call tvhr(ncol,nrow,  ntr,l)

      elseif(type .eq. 34) then
       call tvhrv(ncol,nrow,  ntr,l)
       endif

      return
      end
      subroutine tsym(ncol,nrow,  ntr,l)
************************************************************************
*
*   Generate the triangle vertex list for the symmetric mesh.
*
************************************************************************
      integer ncol, nrow, ntr, l(0:2,1), nodij, i, j

      ntr = 0

      do 11 j=1,nrow-1,2
      do 11 i=1,ncol-1,2
       nodij = i + ncol*(j-1)
       call t0(nodij,ncol,1,  l(0,ntr+1))
       ntr = ntr + 2
   11 continue

      do 12 j=1,nrow-1,2
      do 12 i=2,ncol-1,2
       nodij = i + ncol*(j-1)
       call t1(nodij,ncol,1,  l(0,ntr+1))
       ntr = ntr + 2
   12 continue

      do 13 j=2,nrow-1,2
      do 13 i=1,ncol-1,2
       nodij = i + ncol*(j-1)
       call t1(nodij,ncol,1,  l(0,ntr+1))
       ntr = ntr + 2
   13 continue

      do 14 j=2,nrow-1,2
      do 14 i=2,ncol-1,2
       nodij = i + ncol*(j-1)
       call t0(nodij,ncol,1,  l(0,ntr+1))
       ntr = ntr + 2
   14 continue

      return
      end
      subroutine tsymv(ncol,nrow,  ntr,l)
************************************************************************
*
*   Generate the triangle vertex list for the variant of the
*   symmetric mesh.
*
************************************************************************
      integer ncol, nrow, ntr, l(0:2,1), nodij, i, j

      ntr = 0

      do 11 j=1,nrow-1,2
      do 11 i=1,ncol-1,2
       nodij = i + ncol*(j-1)
       call t1(nodij,ncol,1,  l(0,ntr+1))
       ntr = ntr + 2
   11 continue

      do 12 j=1,nrow-1,2
      do 12 i=2,ncol-1,2
       nodij = i + ncol*(j-1)
       call t0(nodij,ncol,1,  l(0,ntr+1))
       ntr = ntr + 2
   12 continue

      do 13 j=2,nrow-1,2
      do 13 i=1,ncol-1,2
       nodij = i + ncol*(j-1)
       call t0(nodij,ncol,1,  l(0,ntr+1))
       ntr = ntr + 2
   13 continue

      do 14 j=2,nrow-1,2
      do 14 i=2,ncol-1,2
       nodij = i + ncol*(j-1)
       call t1(nodij,ncol,1,  l(0,ntr+1))
       ntr = ntr + 2
   14 continue

      return
      end
      subroutine trhx(ncol,nrow,  ntr,l)
************************************************************************
*
*   Generate the triangle vertex list for the right-handed hexagonal
*   mesh.
*
************************************************************************
      integer ncol, nrow, ntr, l(0:2,1), nodij, i, j

      ntr = 0

      do 11 j=1,nrow-1,2
      do 11 i=1,ncol-1
       nodij = i + ncol*(j-1)
       call t0(nodij,ncol,1,  l(0,ntr+1))
       ntr = ntr + 2
   11 continue

      do 13 j=2,nrow-1,2
      do 13 i=1,ncol-1
       nodij = i + ncol*(j-1)
       call t0(nodij,ncol,1,  l(0,ntr+1))
       ntr = ntr + 2
   13 continue

      return
      end
      subroutine tlhx(ncol,nrow,  ntr,l)
************************************************************************
*
*   Generate the triangle vertex list for the left-handed hexagonal
*   mesh.
*
************************************************************************
      integer ncol, nrow, ntr, l(0:2,1), nodij, i, j

      ntr = 0

      do 11 j=1,nrow-1,2
      do 11 i=1,ncol-1
       nodij = i + ncol*(j-1)
       call t1(nodij,ncol,1,  l(0,ntr+1))
       ntr = ntr + 2
   11 continue

      do 13 j=2,nrow-1,2
      do 13 i=1,ncol-1
       nodij = i + ncol*(j-1)
       call t1(nodij,ncol,1,  l(0,ntr+1))
       ntr = ntr + 2
   13 continue

      return
      end
      subroutine thhr(ncol,nrow,  ntr,l)
************************************************************************
*
*   Generate the triangle vertex list for the "horizontal-herringbone"
*   hexagonal mesh.
*
************************************************************************
      integer ncol, nrow, ntr, l(0:2,1), nodij, i, j

      ntr = 0

      do 11 j=1,nrow-1,2
      do 11 i=1,ncol-1
       nodij = i + ncol*(j-1)
       call t0(nodij,ncol,1,  l(0,ntr+1))
       ntr = ntr + 2
   11 continue

      do 13 j=2,nrow-1,2
      do 13 i=1,ncol-1
       nodij = i + ncol*(j-1)
       call t1(nodij,ncol,1,  l(0,ntr+1))
       ntr = ntr + 2
   13 continue

      return
      end
      subroutine thhrv(ncol,nrow,  ntr,l)
************************************************************************
*
*   Generate the triangle vertex list for the variant of the
*   "horizontal-herringbone" hexagonal mesh.
*
************************************************************************
      integer ncol, nrow, ntr, l(0:2,1), nodij, i, j

      ntr = 0

      do 11 j=1,nrow-1,2
      do 11 i=1,ncol-1
       nodij = i + ncol*(j-1)
       call t1(nodij,ncol,1,  l(0,ntr+1))
       ntr = ntr + 2
   11 continue

      do 13 j=2,nrow-1,2
      do 13 i=1,ncol-1
       nodij = i + ncol*(j-1)
       call t0(nodij,ncol,1,  l(0,ntr+1))
       ntr = ntr + 2
   13 continue

      return
      end
      subroutine tvhr(ncol,nrow,  ntr,l)
************************************************************************
*
*   Generate the triangle vertex list for the "vertical-herringbone"
*   hexagonal mesh.
*
************************************************************************
      integer ncol, nrow, ntr, l(0:2,1), nodij, i, j

      ntr = 0

      do 11 j=1,nrow-1
      do 11 i=1,ncol-1,2
       nodij = i + ncol*(j-1)
       call t0(nodij,ncol,1,  l(0,ntr+1))
       ntr = ntr + 2
   11 continue

      do 13 j=1,nrow-1
      do 13 i=2,ncol-1,2
       nodij = i + ncol*(j-1)
       call t1(nodij,ncol,1,  l(0,ntr+1))
       ntr = ntr + 2
   13 continue

      return
      end
      subroutine tvhrv(ncol,nrow,  ntr,l)
************************************************************************
*
*   Generate the triangle vertex list for the variant of the
*   "vertical-herringbone" hexagonal mesh.
*
************************************************************************
      integer ncol, nrow, ntr, l(0:2,1), nodij, i, j

      ntr = 0

      do 11 j=1,nrow-1
      do 11 i=1,ncol-1,2
       nodij = i + ncol*(j-1)
       call t1(nodij,ncol,1,  l(0,ntr+1))
       ntr = ntr + 2
   11 continue

      do 13 j=1,nrow-1
      do 13 i=2,ncol-1,2
       nodij = i + ncol*(j-1)
       call t0(nodij,ncol,1,  l(0,ntr+1))
       ntr = ntr + 2
   13 continue

      return
      end
      subroutine edgrg(ncol,nrow,type,  nedg,niedg,nbedg,l)
************************************************************************
*
*   Generates the edge-two-triangle/edge-one-triangle vertex list by
*   calling the appropriate routine for the mesh specified by TYPE.
*
************************************************************************
      integer ncol, nrow, type, nedg, niedg, nbedg, l(1)

      if(type .eq. 11) then
       call esym(ncol,nrow,  nedg,niedg,nbedg,l)

      elseif(type .eq. 12) then
       call esymv(ncol,nrow,  nedg,niedg,nbedg,l)

      elseif(type .eq. 21) then
       call erhx(ncol,nrow,  nedg,niedg,nbedg,l)

      elseif(type .eq. 22) then
       call elhx(ncol,nrow,  nedg,niedg,nbedg,l)

      elseif(type .eq. 31) then
       call ehhr(ncol,nrow,  nedg,niedg,nbedg,l)

      elseif(type .eq. 32) then
       call ehhrv(ncol,nrow,  nedg,niedg,nbedg,l)

      elseif(type .eq. 33) then
       call evhr(ncol,nrow,  nedg,niedg,nbedg,l)

      elseif(type .eq. 34) then
       call evhrv(ncol,nrow,  nedg,niedg,nbedg,l)
       endif

      return
      end
      subroutine esym(ncol,nrow,  nedg,niedg,nbedg,l)
************************************************************************
*
*   Generate the edge-two-triangle/edge-one-triangle vertex list for
*   the symmetric mesh.
*
************************************************************************
      logical even
      integer ncol,nrow, nedg,niedg,nbedg,l(0:3,1), nodij,i,j,k

      even(k) = (mod(k,2) .eq. 0)

      nedg = 0

*     ----------------
*      Diagonal edges
*     ----------------
      do 11 j=1,nrow-1,2
      do 11 i=1,ncol-1
       nodij = i + ncol*(j-1)
       nedg = nedg + 1
       if(even(i)) then
        call de1(nodij,ncol,1,  l(0,nedg))
       else
        call de0(nodij,ncol,1,  l(0,nedg))
        endif
   11 continue

      do 13 j=2,nrow-1,2
      do 13 i=1,ncol-1
       nodij = i + ncol*(j-1)
       nedg = nedg + 1
       if(even(i)) then
        call de0(nodij,ncol,1,  l(0,nedg))
       else
        call de1(nodij,ncol,1,  l(0,nedg))
        endif
   13 continue
*     ---------------------------
*      Interior horizontal edges
*     ---------------------------
      do 21 j=2,nrow-1
      do 21 i=1,ncol-1
       nodij = i + ncol*(j-1)
       nedg = nedg + 1
       if(even(i+j)) then
        call he11(nodij,ncol,1,  l(0,nedg))
       else
        call he00(nodij,ncol,1,  l(0,nedg))
        endif
   21 continue
*     -------------------------
*      Interior vertical edges
*     -------------------------
      do 31 j=1,nrow-1
      do 31 i=2,ncol-1
       nodij = i + ncol*(j-1)
       nedg = nedg + 1
       if(even(i+j)) then
        call ve11(nodij,ncol,1,  l(0,nedg))
       else
        call ve00(nodij,ncol,1,  l(0,nedg))
        endif
   31 continue

      niedg = nedg

*     ----------------
*      Boundary edges
*     ----------------
*     Bottom boundary edges, left to right
      do 110 i=1,ncol-1
       nodij = i
       nedg = nedg + 1
       if(even(i)) then
        call bb0(nodij,ncol,1,  l(0,nedg))
       else
        call bb1(nodij,ncol,1,  l(0,nedg))
        endif
  110 continue

*     Right boundary edges, bottom to top
      do 120 j=1,nrow-1
       nodij = ncol*j
       nedg = nedg + 1
       if(even(j+ncol)) then
        call rb1(nodij,ncol,1,  l(0,nedg))
       else
        call rb0(nodij,ncol,1,  l(0,nedg))
        endif
  120 continue

*     Top boundary edges, right to left
      do 130 i=ncol,2,-1
       nodij = i + ncol*(nrow-1)
       nedg = nedg + 1
       if(even(i+nrow)) then
        call tb1(nodij,ncol,1,  l(0,nedg))
       else
        call tb0(nodij,ncol,1,  l(0,nedg))
        endif
  130 continue

*     Left boundary edges, top to bottom
      do 140 j=nrow,2,-1
       nodij = 1 + ncol*(j-1)
       nedg = nedg + 1
       if(even(j)) then
        call lb0(nodij,ncol,1,  l(0,nedg))
       else
        call lb1(nodij,ncol,1,  l(0,nedg))
        endif
  140 continue

      nbedg = nedg - niedg

      return
      end
      subroutine esymv(ncol,nrow,  nedg,niedg,nbedg,l)
************************************************************************
*
*   Generate the edge-two-triangle/edge-one-triangle vertex list for
*   the symmetric mesh variant.
*
************************************************************************
      logical even
      integer ncol,nrow, nedg,niedg,nbedg,l(0:3,1), nodij,i,j,k

      even(k) = (mod(k,2) .eq. 0)

      nedg = 0

*     ----------------
*      Diagonal edges
*     ----------------
      do 11 j=1,nrow-1,2
      do 11 i=1,ncol-1
       nodij = i + ncol*(j-1)
       nedg = nedg + 1
       if(even(i)) then
        call de0(nodij,ncol,1,  l(0,nedg))
       else
        call de1(nodij,ncol,1,  l(0,nedg))
        endif
   11 continue

      do 13 j=2,nrow-1,2
      do 13 i=1,ncol-1
       nodij = i + ncol*(j-1)
       nedg = nedg + 1
       if(even(i)) then
        call de1(nodij,ncol,1,  l(0,nedg))
       else
        call de0(nodij,ncol,1,  l(0,nedg))
        endif
   13 continue
*     ---------------------------
*      Interior horizontal edges
*     ---------------------------
      do 21 j=2,nrow-1
      do 21 i=1,ncol-1
       nodij = i + ncol*(j-1)
       nedg = nedg + 1
       if(even(i+j)) then
        call he00(nodij,ncol,1,  l(0,nedg))
       else
        call he11(nodij,ncol,1,  l(0,nedg))
        endif
   21 continue
*     -------------------------
*      Interior vertical edges
*     -------------------------
      do 31 j=1,nrow-1
      do 31 i=2,ncol-1
       nodij = i + ncol*(j-1)
       nedg = nedg + 1
       if(even(i+j)) then
        call ve00(nodij,ncol,1,  l(0,nedg))
       else
        call ve11(nodij,ncol,1,  l(0,nedg))
        endif
   31 continue

      niedg = nedg

*     ----------------
*      Boundary edges
*     ----------------
*     Bottom boundary edges, left to right
      do 110 i=1,ncol-1
       nodij = i
       nedg = nedg + 1
       if(even(i)) then
        call bb1(nodij,ncol,1,  l(0,nedg))
       else
        call bb0(nodij,ncol,1,  l(0,nedg))
        endif
  110 continue

*     Right boundary edges, bottom to top
      do 120 j=1,nrow-1
       nodij = ncol*j
       nedg = nedg + 1
       if(even(j+ncol)) then
        call rb0(nodij,ncol,1,  l(0,nedg))
       else
        call rb1(nodij,ncol,1,  l(0,nedg))
        endif
  120 continue

*     Top boundary edges, right to left
      do 130 i=ncol,2,-1
       nodij = i + ncol*(nrow-1)
       nedg = nedg + 1
       if(even(i+nrow)) then
        call tb0(nodij,ncol,1,  l(0,nedg))
       else
        call tb1(nodij,ncol,1,  l(0,nedg))
        endif
  130 continue

*     Left boundary edges, top to bottom
      do 140 j=nrow,2,-1
       nodij = 1 + ncol*(j-1)
       nedg = nedg + 1
       if(even(j)) then
        call lb1(nodij,ncol,1,  l(0,nedg))
       else
        call lb0(nodij,ncol,1,  l(0,nedg))
        endif
  140 continue

      nbedg = nedg - niedg

      return
      end
      subroutine erhx(ncol,nrow,  nedg,niedg,nbedg,l)
************************************************************************
*
*   Generate the edge-two-triangle/edge-one-triangle vertex list for
*   the right-handed hexagonal mesh.
*
************************************************************************
      integer ncol,nrow, nedg,niedg,nbedg,l(0:3,1), nodij,i,j

      nedg = 0

*     ----------------
*      Diagonal edges
*     ----------------
      do 11 j=1,nrow-1
      do 11 i=1,ncol-1
      nodij = i + ncol*(j-1)
      nedg = nedg + 1
   11 call de0(nodij,ncol,1,  l(0,nedg))
*     ---------------------------
*      Interior horizontal edges
*     ---------------------------
      do 21 j=2,nrow-1
      do 21 i=1,ncol-1
      nodij = i + ncol*(j-1)
      nedg = nedg + 1
   21 call he10(nodij,ncol,1,  l(0,nedg))
*     -------------------------
*      Interior vertical edges
*     -------------------------
      do 31 j=1,nrow-1
      do 31 i=2,ncol-1
      nodij = i + ncol*(j-1)
      nedg = nedg + 1
   31 call ve01(nodij,ncol,1,  l(0,nedg))

      niedg = nedg

*     ----------------
*      Boundary edges
*     ----------------
*     Bottom boundary edges, left to right
      do 110 i=1,ncol-1
      nodij = i
      nedg = nedg + 1
  110 call bb1(nodij,ncol,1,  l(0,nedg))

*     Right boundary edges, bottom to top
      do 120 j=1,nrow-1
      nodij = ncol*j
      nedg = nedg + 1
  120 call rb0(nodij,ncol,1,  l(0,nedg))

*     Top boundary edges, right to left
      do 130 i=ncol,2,-1
      nodij = i + ncol*(nrow-1)
      nedg = nedg + 1
  130 call tb1(nodij,ncol,1,  l(0,nedg))

*     Left boundary edges, top to bottom
      do 140 j=nrow,2,-1
      nodij = 1 + ncol*(j-1)
      nedg = nedg + 1
  140 call lb0(nodij,ncol,1,  l(0,nedg))

      nbedg = nedg - niedg

      return
      end
      subroutine elhx(ncol,nrow,  nedg,niedg,nbedg,l)
************************************************************************
*
*   Generate the edge-two-triangle/edge-one-triangle vertex list for
*   the left-handed hexagonal mesh.
*
************************************************************************
      integer ncol,nrow, nedg,niedg,nbedg,l(0:3,1), nodij,i,j

      nedg = 0

*     ----------------
*      Diagonal edges
*     ----------------
      do 11 j=1,nrow-1
      do 11 i=1,ncol-1
      nodij = i + ncol*(j-1)
      nedg = nedg + 1
   11 call de1(nodij,ncol,1,  l(0,nedg))
*     ---------------------------
*      Interior horizontal edges
*     ---------------------------
      do 21 j=2,nrow-1
      do 21 i=1,ncol-1
      nodij = i + ncol*(j-1)
      nedg = nedg + 1
   21 call he01(nodij,ncol,1,  l(0,nedg))
*     -------------------------
*      Interior vertical edges
*     -------------------------
      do 31 j=1,nrow-1
      do 31 i=2,ncol-1
      nodij = i + ncol*(j-1)
      nedg = nedg + 1
   31 call ve10(nodij,ncol,1,  l(0,nedg))

      niedg = nedg

*     ----------------
*      Boundary edges
*     ----------------
*     Bottom boundary edges, left to right
      do 110 i=1,ncol-1
      nodij = i
      nedg = nedg + 1
  110 call bb0(nodij,ncol,1,  l(0,nedg))

*     Right boundary edges, bottom to top
      do 120 j=1,nrow-1
      nodij = ncol*j
      nedg = nedg + 1
  120 call rb1(nodij,ncol,1,  l(0,nedg))

*     Top boundary edges, right to left
      do 130 i=ncol,2,-1
      nodij = i + ncol*(nrow-1)
      nedg = nedg + 1
  130 call tb0(nodij,ncol,1,  l(0,nedg))

*     Left boundary edges, top to bottom
      do 140 j=nrow,2,-1
      nodij = 1 + ncol*(j-1)
      nedg = nedg + 1
  140 call lb1(nodij,ncol,1,  l(0,nedg))

      nbedg = nedg - niedg

      return
      end
      subroutine ehhr(ncol,nrow,  nedg,niedg,nbedg,l)
************************************************************************
*
*   Generate the edge-two-triangle/edge-one-triangle vertex list for
*   the "horizontal-herringbone" hexagonal mesh.
*
************************************************************************
      logical even
      integer ncol,nrow, nedg,niedg,nbedg,l(0:3,1), nodij,i,j,k

      even(k) = (mod(k,2) .eq. 0)

      nedg = 0

*     ----------------
*      Diagonal edges
*     ----------------
      do 11 j=1,nrow-1
      do 11 i=1,ncol-1
       nodij = i + ncol*(j-1)
       nedg = nedg + 1
       if(even(j)) then
        call de1(nodij,ncol,1,  l(0,nedg))
       else
        call de0(nodij,ncol,1,  l(0,nedg))
        endif
   11 continue
*     ---------------------------
*      Interior horizontal edges
*     ---------------------------
      do 21 j=2,nrow-1
      do 21 i=1,ncol-1
       nodij = i + ncol*(j-1)
       nedg = nedg + 1
       if(even(j)) then
        call he00(nodij,ncol,1,  l(0,nedg))
       else
        call he11(nodij,ncol,1,  l(0,nedg))
        endif
   21 continue
*     -------------------------
*      Interior vertical edges
*     -------------------------
      do 31 j=1,nrow-1
      do 31 i=2,ncol-1
       nodij = i + ncol*(j-1)
       nedg = nedg + 1
       if(even(j)) then
        call ve10(nodij,ncol,1,  l(0,nedg))
       else
        call ve01(nodij,ncol,1,  l(0,nedg))
        endif
   31 continue

      niedg = nedg

*     ----------------
*      Boundary edges
*     ----------------
*     Bottom boundary edges, left to right
      do 110 i=1,ncol-1
      nodij = i
      nedg = nedg + 1
  110 call bb1(nodij,ncol,1,  l(0,nedg))

*     Right boundary edges, bottom to top
      do 120 j=1,nrow-1
       nodij = ncol*j
       nedg = nedg + 1
       if(even(j)) then
        call rb1(nodij,ncol,1,  l(0,nedg))
       else
        call rb0(nodij,ncol,1,  l(0,nedg))
        endif
  120 continue

*     Top boundary edges, right to left
      do 130 i=ncol,2,-1
       nodij = i + ncol*(nrow-1)
       nedg = nedg + 1
       if(even(nrow)) then
        call tb1(nodij,ncol,1,  l(0,nedg))
       else
        call tb0(nodij,ncol,1,  l(0,nedg))
        endif
  130 continue

*     Left boundary edges, top to bottom
      do 140 j=nrow,2,-1
       nodij = 1 + ncol*(j-1)
       nedg = nedg + 1
       if(even(j)) then
        call lb0(nodij,ncol,1,  l(0,nedg))
       else
        call lb1(nodij,ncol,1,  l(0,nedg))
        endif
  140 continue

      nbedg = nedg - niedg

      return
      end
      subroutine ehhrv(ncol,nrow,  nedg,niedg,nbedg,l)
************************************************************************
*
*   Generate the edge-two-triangle/edge-one-triangle vertex list for
*   the variant of the "horizontal-herringbone" hexagonal mesh.
*
************************************************************************
      logical even
      integer ncol,nrow, nedg,niedg,nbedg,l(0:3,1), nodij,i,j,k

      even(k) = (mod(k,2) .eq. 0)

      nedg = 0

*     ----------------
*      Diagonal edges
*     ----------------
      do 11 j=1,nrow-1
      do 11 i=1,ncol-1
       nodij = i + ncol*(j-1)
       nedg = nedg + 1
       if(even(j)) then
        call de0(nodij,ncol,1,  l(0,nedg))
       else
        call de1(nodij,ncol,1,  l(0,nedg))
        endif
   11 continue
*     ---------------------------
*      Interior horizontal edges
*     ---------------------------
      do 21 j=2,nrow-1
      do 21 i=1,ncol-1
       nodij = i + ncol*(j-1)
       nedg = nedg + 1
       if(even(j)) then
        call he11(nodij,ncol,1,  l(0,nedg))
       else
        call he00(nodij,ncol,1,  l(0,nedg))
        endif
   21 continue
*     -------------------------
*      Interior vertical edges
*     -------------------------
      do 31 j=1,nrow-1
      do 31 i=2,ncol-1
       nodij = i + ncol*(j-1)
       nedg = nedg + 1
       if(even(j)) then
        call ve01(nodij,ncol,1,  l(0,nedg))
       else
        call ve10(nodij,ncol,1,  l(0,nedg))
        endif
   31 continue

      niedg = nedg

*     ----------------
*      Boundary edges
*     ----------------
*     Bottom boundary edges, left to right
      do 110 i=1,ncol-1
      nodij = i
      nedg = nedg + 1
  110 call bb0(nodij,ncol,1,  l(0,nedg))

*     Right boundary edges, bottom to top
      do 120 j=1,nrow-1
       nodij = ncol*j
       nedg = nedg + 1
       if(even(j)) then
        call rb0(nodij,ncol,1,  l(0,nedg))
       else
        call rb1(nodij,ncol,1,  l(0,nedg))
        endif
  120 continue

*     Top boundary edges, right to left
      do 130 i=ncol,2,-1
       nodij = i + ncol*(nrow-1)
       nedg = nedg + 1
       if(even(nrow)) then
        call tb0(nodij,ncol,1,  l(0,nedg))
       else
        call tb1(nodij,ncol,1,  l(0,nedg))
        endif
  130 continue

*     Left boundary edges, top to bottom
      do 140 j=nrow,2,-1
       nodij = 1 + ncol*(j-1)
       nedg = nedg + 1
       if(even(j)) then
        call lb1(nodij,ncol,1,  l(0,nedg))
       else
        call lb0(nodij,ncol,1,  l(0,nedg))
        endif
  140 continue

      nbedg = nedg - niedg

      return
      end
      subroutine evhr(ncol,nrow,  nedg,niedg,nbedg,l)
************************************************************************
*
*   Generate the edge-two-triangle/edge-one-triangle vertex list for
*   the "vertical-herringbone" hexagonal mesh.
*
************************************************************************
      logical even
      integer ncol,nrow, nedg,niedg,nbedg,l(0:3,1), nodij,i,j,k

      even(k) = (mod(k,2) .eq. 0)

      nedg = 0

*     ----------------
*      Diagonal edges
*     ----------------
      do 11 j=1,nrow-1
      do 11 i=1,ncol-1
       nodij = i + ncol*(j-1)
       nedg = nedg + 1
       if(even(i)) then
        call de1(nodij,ncol,1,  l(0,nedg))
       else
        call de0(nodij,ncol,1,  l(0,nedg))
        endif
   11 continue
*     ---------------------------
*      Interior horizontal edges
*     ---------------------------
      do 21 j=2,nrow-1
      do 21 i=1,ncol-1
       nodij = i + ncol*(j-1)
       nedg = nedg + 1
       if(even(i)) then
        call he01(nodij,ncol,1,  l(0,nedg))
       else
        call he10(nodij,ncol,1,  l(0,nedg))
        endif
   21 continue
*     -------------------------
*      Interior vertical edges
*     -------------------------
      do 31 j=1,nrow-1
      do 31 i=2,ncol-1
       nodij = i + ncol*(j-1)
       nedg = nedg + 1
       if(even(i)) then
        call ve00(nodij,ncol,1,  l(0,nedg))
       else
        call ve11(nodij,ncol,1,  l(0,nedg))
        endif
   31 continue

      niedg = nedg

*     ----------------
*      Boundary edges
*     ----------------
*     Bottom boundary edges, left to right
      do 110 i=1,ncol-1
       nodij = i
       nedg = nedg + 1
       if(even(i)) then
        call bb0(nodij,ncol,1,  l(0,nedg))
       else
        call bb1(nodij,ncol,1,  l(0,nedg))
        endif
  110 continue

*     Right boundary edges, bottom to top
      do 120 j=1,nrow-1
       nodij = ncol*j
       nedg = nedg + 1
       if(even(ncol)) then
        call rb0(nodij,ncol,1,  l(0,nedg))
       else
        call rb1(nodij,ncol,1,  l(0,nedg))
        endif
  120 continue

*     Top boundary edges, right to left
      do 130 i=ncol,2,-1
       nodij = i + ncol*(nrow-1)
       nedg = nedg + 1
       if(even(i)) then
        call tb1(nodij,ncol,1,  l(0,nedg))
       else
        call tb0(nodij,ncol,1,  l(0,nedg))
        endif
  130 continue

*     Left boundary edges, top to bottom
      do 140 j=nrow,2,-1
      nodij = 1 + ncol*(j-1)
      nedg = nedg + 1
  140 call lb0(nodij,ncol,1,  l(0,nedg))

      nbedg = nedg - niedg

      return
      end
      subroutine evhrv(ncol,nrow,  nedg,niedg,nbedg,l)
************************************************************************
*
*   Generate the edge-two-triangle/edge-one-triangle vertex list for
*   the variant of the "vertical-herringbone" hexagonal mesh.
*
************************************************************************
      logical even
      integer ncol,nrow, nedg,niedg,nbedg,l(0:3,1), nodij,i,j,k

      even(k) = (mod(k,2) .eq. 0)

      nedg = 0

*     ----------------
*      Diagonal edges
*     ----------------
      do 11 j=1,nrow-1
      do 11 i=1,ncol-1
       nodij = i + ncol*(j-1)
       nedg = nedg + 1
       if(even(i)) then
        call de0(nodij,ncol,1,  l(0,nedg))
       else
        call de1(nodij,ncol,1,  l(0,nedg))
        endif
   11 continue
*     ---------------------------
*      Interior horizontal edges
*     ---------------------------
      do 21 j=2,nrow-1
      do 21 i=1,ncol-1
       nodij = i + ncol*(j-1)
       nedg = nedg + 1
       if(even(i)) then
        call he10(nodij,ncol,1,  l(0,nedg))
       else
        call he01(nodij,ncol,1,  l(0,nedg))
        endif
   21 continue
*     -------------------------
*      Interior vertical edges
*     -------------------------
      do 31 j=1,nrow-1
      do 31 i=2,ncol-1
       nodij = i + ncol*(j-1)
       nedg = nedg + 1
       if(even(i)) then
        call ve11(nodij,ncol,1,  l(0,nedg))
       else
        call ve00(nodij,ncol,1,  l(0,nedg))
        endif
   31 continue

      niedg = nedg

*     ----------------
*      Boundary edges
*     ----------------
*     Bottom boundary edges, left to right
      do 110 i=1,ncol-1
       nodij = i
       nedg = nedg + 1
       if(even(i)) then
        call bb1(nodij,ncol,1,  l(0,nedg))
       else
        call bb0(nodij,ncol,1,  l(0,nedg))
        endif
  110 continue

*     Right boundary edges, bottom to top
      do 120 j=1,nrow-1
       nodij = ncol*j
       nedg = nedg + 1
       if(even(ncol)) then
        call rb1(nodij,ncol,1,  l(0,nedg))
       else
        call rb0(nodij,ncol,1,  l(0,nedg))
        endif
  120 continue

*     Top boundary edges, right to left
      do 130 i=ncol,2,-1
       nodij = i + ncol*(nrow-1)
       nedg = nedg + 1
       if(even(i)) then
        call tb0(nodij,ncol,1,  l(0,nedg))
       else
        call tb1(nodij,ncol,1,  l(0,nedg))
        endif
  130 continue

*     Left boundary edges, top to bottom
      do 140 j=nrow,2,-1
      nodij = 1 + ncol*(j-1)
      nedg = nedg + 1
  140 call lb1(nodij,ncol,1,  l(0,nedg))

      nbedg = nedg - niedg

      return
      end
************************************************************************
*
*   The following routines label the vertices of individual triangles,
*   edge-two-triangles, and edge-one-triangles for the various possible
*   orientations (see diagrams below).  The routines are t0 and t1
*   (triangles), de0, de1, he00, he10, he01, he11, ve00, ve10, ve01,
*   and ve11 (edge-two-triangles), and bb0, bb1, rb0, rb1, tb0, tb1,
*   lb0, and lb1 (edge-one-triangles).  The arguments to all these
*   routines are similar and are described here.
*
*     N -- the node number of the local reference node for the
*     triangle pair or edge.  The reference node for each orientation
*     is indicated in the diagrams by an "*".
*
*     JC, JR -- the increments in node number between consecutive nodes
*     in a column (bottom to top) and between consecutive nodes in a
*     row (left to right).  Thus if we are at node number N, the node
*     immediately above in the same column is node N+JC, the node to
*     the right in the same row is node N+JR, the node to the left is
*     node N-JR, and so on.  Such a relationship between node numbers
*     will hold if the nodes are numbered by column or by row.  Note
*     that JC and JR may be given negative values.
*
*     L -- the array of node numbers of the vertices of a triangle or
*     edge.  Triangles are done by pairs which are formed when a grid
*     cell in divided by a diagonal (see diagrams below).  For these
*     two routines, "t0" and "t1", L has length 6, dimensioned (0:2,2).
*     The second index corresponds to the triangle, 1 or 2, and the
*     first index corresponds to the vertex number.  Thus L(j,1) is
*     the node number of the jth vertex of the first triangle, and so
*     on.  Notice that the vertices are oriented counter-clockwise
*     about the boundary of each triangle.  For the remaining routines
*     which label the vertices of edges, L is a vector of length 4,
*     dimensioned (0:3).  L(j) is the node number of the jth vertex.
*     Vertices 0 and 1 are the endpoints of the edge and vertices 2
*     and 3 are the remaining vertices of the two triangles which share
*     this common edge.  Notice that vertices 0, 1, and 2 are oriented
*     counter-clockwise about one of the triangles.  Vertices 0, 3, and
*     1 have the same orientation about the other triangle.  This
*     describes the case for all interior edges (edge-two-triangles).
*     For edges lying on the boundary, there is only a single triangle
*     which has the edge 01 as an edge (edge-one-triangles).  In this
*     case L(3) is assigned the value zero.  Note also that the edge 01
*     is oriented counter-clockwise about the boundary of the domain.
*
*   Triangles.
*                         "t0"                             "t1"
*
*        +-----+        2-----1           +-----+         1-----0
*        |    /|        |    / 0          |\    |        2 \    |
*        |   / |        | 1 / /|          | \   |        |\ \ 2 |
*        |  /  |  ===>  |  / / |          |  \  |  ===>  | \ \  |
*        | /   |        | / /  |          |   \ |        |  \ \ |
*        |/    |        |/ / 2 |          |    \|        | 1 \ \|
*        +-----+        0 /    |          +-----+        |    \ 2
*       *                1-----2         *               0-----1
*
*   Interior edges (edge-two-triangles).
*
*     diagonal edges:
*
*                      "de0"            "de1"
*
*                      2----1           0----2
*                      |   /|           |\   |
*                      |  / |           | \  |
*                      | /  |           |  \ |
*                      |/   |           |   \|
*                     *0----3          *3----1
*
*     horizontal edges:
*
*         "he00"        "he10"        "he01"        "he11"
*
*          2                 2         2                 2
*          |\               /|         |\               /|
*          | \             / |         | \             / |
*          |  \           /  |         |  \           /  |
*         *0---1        *0---1        *0---1        *0---1
*          |  /          |  /           \  |          \  |      
*          | /           | /             \ |           \ |      
*          |/            |/               \|            \|      
*          3             3                 3             3
*
*     vertical edges:
*
*         "ve00"        "ve10"        "ve01"        "ve11"
*
*            1         2---1             1---3     2---1---3
*           /|\         \  |\           /|  /       \  |  /
*          / | \         \ | \         / | /         \ | /
*         /  |  \         \|  \       /  |/           \|/
*        2---0---3         0---3     2---0             0
*            *             *             *             *
*
*   Boundary edges (edge-one-triangles).
*
*     bottom boundary:            right boundary:
*
*         "bb0"     "bb1"             "rb0"     "rb1"
*
*         2             2                 1     2---1
*         |\           /|                /|      \  |
*         | \         / |               / |       \ |
*         |  \       /  |              /  |        \|
*        *0---1    *0---1             2---0*        0*
*
*     top boundary:               left boundary:
*
*         "tb0"     "tb1"             "lb0"     "lb1"
*
*         1---0*    1---0*           *0---2    *0
*          \  |     |  /              |  /      |\
*           \ |     | /               | /       | \
*            \|     |/                |/        |  \
*             2     2                 1         1---2
*
************************************************************************
      subroutine t0(n,jc,jr,  l)

      integer n, jc, jr, l(0:2,2)

      l(0,1) = n
      l(1,1) = n + jr + jc
      l(2,1) = n + jc

      l(0,2) = n + jr + jc
      l(1,2) = n
      l(2,2) = n + jr

      return
      end
      subroutine t1(n,jc,jr,  l)

      integer n, jc, jr, l(0:2,2)

      l(0,1) = n
      l(1,1) = n + jr
      l(2,1) = n + jc

      l(0,2) = n + jr + jc
      l(1,2) = n + jc
      l(2,2) = n + jr

      return
      end
      subroutine de0(n,jc,jr,  l)

      integer n, jc, jr, l(0:3)

      l(0) = n
      l(1) = n + jr + jc
      l(2) = n + jc
      l(3) = n + jr

      return
      end
      subroutine de1(n,jc,jr,  l)

      integer n, jc, jr, l(0:3)

      l(0) = n + jc
      l(1) = n + jr
      l(2) = n + jr + jc
      l(3) = n

      return
      end
      subroutine he00(n,jc,jr,  l)

      integer n, jc, jr, l(0:3)

      l(0) = n
      l(1) = n + jr
      l(2) = n + jc
      l(3) = n - jc

      return
      end
      subroutine he10(n,jc,jr,  l)

      integer n, jc, jr, l(0:3)

      l(0) = n
      l(1) = n + jr
      l(2) = n + jr + jc
      l(3) = n - jc

      return
      end
      subroutine he01(n,jc,jr,  l)

      integer n, jc, jr, l(0:3)

      l(0) = n
      l(1) = n + jr
      l(2) = n + jc
      l(3) = n + jr - jc

      return
      end
      subroutine he11(n,jc,jr,  l)

      integer n, jc, jr, l(0:3)

      l(0) = n
      l(1) = n + jr
      l(2) = n + jr + jc
      l(3) = n + jr - jc

      return
      end
      subroutine ve00(n,jc,jr,  l)

      integer n, jc, jr, l(0:3)

      l(0) = n
      l(1) = n + jc
      l(2) = n - jr
      l(3) = n + jr

      return
      end
      subroutine ve10(n,jc,jr,  l)

      integer n, jc, jr, l(0:3)

      l(0) = n
      l(1) = n + jc
      l(2) = n - jr + jc
      l(3) = n + jr

      return
      end
      subroutine ve01(n,jc,jr,  l)

      integer n, jc, jr, l(0:3)

      l(0) = n
      l(1) = n + jc
      l(2) = n - jr
      l(3) = n + jr + jc

      return
      end
      subroutine ve11(n,jc,jr,  l)

      integer n, jc, jr, l(0:3)

      l(0) = n
      l(1) = n + jc
      l(2) = n - jr + jc
      l(3) = n + jr + jc

      return
      end
      subroutine bb0(n,jc,jr,  l)

      integer n, jc, jr, l(0:3)

      l(0) = n
      l(1) = n + jr
      l(2) = n + jc
      l(3) = 0

      return
      end
      subroutine bb1(n,jc,jr,  l)

      integer n, jc, jr, l(0:3)

      l(0) = n
      l(1) = n + jr
      l(2) = n + jr + jc
      l(3) = 0

      return
      end
      subroutine rb0(n,jc,jr,  l)

      integer n, jc, jr, l(0:3)

      l(0) = n
      l(1) = n + jc
      l(2) = n - jr
      l(3) = 0

      return
      end
      subroutine rb1(n,jc,jr,  l)

      integer n, jc, jr, l(0:3)

      l(0) = n
      l(1) = n + jc
      l(2) = n - jr + jc
      l(3) = 0

      return
      end
      subroutine tb0(n,jc,jr,  l)

      integer n, jc, jr, l(0:3)

      l(0) = n
      l(1) = n - jr
      l(2) = n - jc
      l(3) = 0

      return
      end
      subroutine tb1(n,jc,jr,  l)

      integer n, jc, jr, l(0:3)

      l(0) = n
      l(1) = n - jr
      l(2) = n - jr - jc
      l(3) = 0

      return
      end
      subroutine lb0(n,jc,jr,  l)

      integer n, jc, jr, l(0:3)

      l(0) = n
      l(1) = n - jc
      l(2) = n + jr
      l(3) = 0

      return
      end
      subroutine lb1(n,jc,jr,  l)

      integer n, jc, jr, l(0:3)

      l(0) = n
      l(1) = n - jc
      l(2) = n + jr - jc
      l(3) = 0

      return
      end
      subroutine fnadjt(ntri,tvtx,  nnod,xadj,adjncy,madj,  xladj,errc)
************************************************************************
*
*   FNADJT -- FIND ADJACENCY STRUCTURE FROM TRIANGLE VERTEX LIST.
*
*   THIS ROUTINE FINDS THE ADJACENCY STRUCTURE OF THE NODES IN A
*   TRIANGULAR MESH GIVEN A LIST OF THE TRIANGLE VERTICES.  THE
*   RESULTING ADJACENCY LIST FOR EACH NODE IS ORDERED.
*
*   ARGUMENT  I/O/M/T  DESCRIPTION
*   --------  -------  -----------
*    NTRI        I     NUMBER OF TRIANGLES IN THE MESH.
*
*    TVTX        I     TRIANGLE VERTEX LIST.  TVTX(I,J), I=0,1,2,
*                      ARE THE THREE VERTICES OF THE JTH TRIANGLE.
*
*    NNOD        I     NUMBER OF NODES IN THE MESH.
*
*    XADJ        O     INDEX ARRAY OF LENGTH NNOD+1 CONTAINING POINTERS
*                      TO THE BEGINNING OF EACH ADJACENCY LIST IN
*                      ADJNCY.
*
*    ADJNCY      O     ARRAY CONTAINING THE NODE ADJACENCY LISTS.
*
*    MADJ        I     DECLARED LENGTH OF ADJNCY.
*
*    XLADJ       T     TEMPORARY ARRAY OF LENGTH NNOD+1.
*
*    ERRC        O     SET TO 1 IF THERE WAS INSUFFICIENT STORAGE TO
*                      STORE THE ADJACENCY LISTS.  SET TO 0 OTHERWISE.
*
************************************************************************
      integer ntri,tvtx(0:2,*),nnod,xadj(*),adjncy(*),xladj(*),madj,errc
      integer i,j,k,l,nedg,itri,ivtx,jvtx,inod,iedg,jdeg,shift

*     =======================================
*      i. generate the sorted list of edges.
*     =======================================

      nedg = 0

      do 100 itri=1,ntri
      do 100 ivtx=0,2

*      next edge to be inserted is (i,j).
       jvtx = mod(ivtx+1,3)
       i = min( tvtx(ivtx,itri), tvtx(jvtx,itri) )
       j = max( tvtx(ivtx,itri), tvtx(jvtx,itri) )

*      sort on first component.
       iedg = nedg
  110  if(iedg .lt. 1) go to 130
       if(adjncy(2*iedg-1) .le. i) go to 115
       iedg = iedg - 1
       go to 110

  115  if(adjncy(2*iedg-1) .lt. i) go to 130

*      first components are equal.  sort on second.
  120  if(adjncy(2*iedg) .le. j) go to 125
       iedg = iedg - 1
       if(iedg .ge. 1 .and. adjncy(2*iedg-1) .eq. i) go to 120
       go to 130

*      if second components are equal, its a duplicate edge.
  125  if(adjncy(2*iedg) .eq. j) go to 100

*      insert edge (i,j) into list at location iedg+1.
  130  if(2*(nedg+1) .gt. madj) go to 910
       nedg = nedg + 1

       do 135 k=2*nedg,2*iedg+3,-1
  135  adjncy(k) = adjncy(k-2)

       adjncy(2*iedg+1) = i 
       adjncy(2*iedg+2) = j 

  100 continue

*     =========================================
*      ii. find the lower adjacency structure.
*     =========================================

*     generate the index array xladj.
      xladj(1) = 1
      inod = 2
      iedg = 0
  212 iedg = iedg + 1
      if(iedg .gt. nedg) go to 210
  211 if(adjncy(2*iedg-1) .lt. inod) go to 212
      xladj(inod) = iedg
      inod = inod + 1
      go to 211

  210 continue

      do 220 j=inod,nnod+1
  220 xladj(j) = nedg + 1

*     generate the lower adjacency lists by compression.
      do 230 i=1,nedg
  230 adjncy(i) = adjncy(2*i)

*     =========================================
*      iii. find the full adjacency structure.
*     =========================================

*     generate the index array xadj.
      xadj(1) = xladj(1)
      xadj(2) = xladj(2)
      do 310 j=2,nnod
*      compute the degree of node j.
       jdeg = xladj(j+1) - xladj(j)
       do 311 k=1,xladj(j)-1
  311  if(adjncy(k) .eq. j) jdeg = jdeg + 1
       xadj(j+1) = xadj(j) + jdeg
  310 continue

*     generate the full adjacency lists.
      do 320 j=nnod,2,-1

*      move lower adjacency list for node j to new location.
       shift = xadj(j+1) - xladj(j+1)
       if(shift .ne. 0) then
        do 323 i=xladj(j+1)-1,xladj(j),-1
  323   adjncy(i+shift) = adjncy(i)
        endif

*      complete the adjacency list for node j.
       l = xadj(j)
       do 321 i=1,j-1
*       search lower adjacency list of node i for node j.
        k = xladj(i) - 1
  322   k = k + 1
        if(k .ge. xladj(i+1)) go to 321
        if(adjncy(k) .ne. j) go to 322

*       node j is adjacent to node i.
        adjncy(l) = i
        l = l + 1
  321  continue

  320 continue

      errc = 0
      return

*     =======================================
*      error return -- insufficient storage.
*     =======================================

  910 errc = 1
      return
      end
      subroutine fnadje(nedg,evtx,  nnod,xadj,adjncy,  xladj)
************************************************************************
*
*   fnadje -- find adjacency structure from edge vertex list.
*
*   this routine finds the adjacency structure of the nodes in a
*   triangular mesh given a list of the edge vertices.  the resulting
*   adjacency list for each node is ordered.
*
*   argument  i/o/m/t  description
*   --------  -------  -----------
*    nedg        i     number of edges in the mesh.
*
*    evtx        i     edge vertex list.  evtx(i,j), i=0,1, are the
*                      two vertices of the jth edge.  evtx(i,j), i=2,3,
*                      are the remaining vertices of the two triangles
*                      sharing the jth edge.  they are ignored here.
*                      
*    nnod        i     number of nodes in the mesh.
*
*    xadj        o     index array of length nnod+1 containing pointers
*                      to the beginning of each adjacency list in
*                      adjncy.
*
*    adjncy      o     array of length 2*nedg containing the node
*                      adjacency lists.
*
*    xladj       t     temporary array of length nnod+1.
*
************************************************************************
      integer nedg,evtx(0:3,*),nnod,xadj(*),adjncy(*),xladj(*)
      integer i,j,k,l,iedg,jedg,inod,jdeg,shift

*     =======================================
*      i. generate the sorted list of edges.
*     =======================================

      do 100 jedg=1,nedg

*      next edge to be inserted is (i,j).
       i = min( evtx(0,jedg), evtx(1,jedg) )
       j = max( evtx(0,jedg), evtx(1,jedg) )

*      sort on first component.
       iedg = jedg - 1
  110  if(iedg .lt. 1) go to 130
       if(adjncy(2*iedg-1) .le. i) go to 115
       iedg = iedg - 1
       go to 110

  115  if(adjncy(2*iedg-1) .lt. i) go to 130

*      first components are equal.  sort on second.
  120  if(adjncy(2*iedg) .le. j) go to 125
       iedg = iedg - 1
       if(iedg .ge. 1 .and. adjncy(2*iedg-1) .eq. i) go to 120
       go to 130

*      if second components are equal, its a duplicate edge.
  125  if(adjncy(2*iedg) .eq. j) go to 100

*      insert edge (i,j) into list at location iedg+1.
  130  continue

       do 135 k=2*jedg,2*iedg+3,-1
  135  adjncy(k) = adjncy(k-2)

       adjncy(2*iedg+1) = i 
       adjncy(2*iedg+2) = j 

  100 continue

*     =========================================
*      ii. find the lower adjacency structure.
*     =========================================

*     generate the index array xladj.
      xladj(1) = 1
      inod = 2
      iedg = 0
  212 iedg = iedg + 1
      if(iedg .gt. nedg) go to 210
  211 if(adjncy(2*iedg-1) .lt. inod) go to 212
      xladj(inod) = iedg
      inod = inod + 1
      go to 211

  210 continue

      do 220 j=inod,nnod+1
  220 xladj(j) = nedg + 1

*     generate the lower adjacency lists by compression.
      do 230 i=1,nedg
  230 adjncy(i) = adjncy(2*i)

*     =========================================
*      iii. find the full adjacency structure.
*     =========================================

*     generate the index array xadj.
      xadj(1) = xladj(1)
      xadj(2) = xladj(2)
      do 310 j=2,nnod
*      compute the degree of node j.
       jdeg = xladj(j+1) - xladj(j)
       do 311 k=1,xladj(j)-1
  311  if(adjncy(k) .eq. j) jdeg = jdeg + 1
       xadj(j+1) = xadj(j) + jdeg
  310 continue

*     generate the full adjacency lists.
      do 320 j=nnod,2,-1

*      move lower adjacency list for node j to new location.
       shift = xadj(j+1) - xladj(j+1)
       if(shift .ne. 0) then
        do 323 i=xladj(j+1)-1,xladj(j),-1
  323   adjncy(i+shift) = adjncy(i)
        endif

*      complete the adjacency list for node j.
       l = xadj(j)
       do 321 i=1,j-1
*       search lower adjacency list of node i for node j.
        k = xladj(i) - 1
  322   k = k + 1
        if(k .ge. xladj(i+1)) go to 321
        if(adjncy(k) .ne. j) go to 322

*       node j is adjacent to node i.
        adjncy(l) = i
        l = l + 1
  321  continue

  320 continue

      return
      end
      subroutine filseg(nseg,niseg,x)
************************************************************************
*
*   Generates a refined discretization of an interval by equally
*   spacing points within each segment of a coarse discretization.
*
*     NSEG -- the number of segments.
*
*     NISEG -- an integer vector of length NSEG.  NISEG(i) is the
*     number of points to be equally spaced within the ith segment.
*     It is overwritten with an indexing vector where NISEG(i) points
*     to the location in X where the first point of the ith segment
*     will be stored.
*
*     X -- on input the vector contains the coordinates of the endpoints
*     of the segments.  X(i) and X(i+1) are the left and right endpoints
*     of the ith segment.  It is overwritten with the coordinates of the
*     points of the resulting refined discretization.  The length of X
*     must be large enough to store the coordinates of the interpolated
*     points specified by NISEG as well as the coordinates of the coarse
*     discretization given initially by X.
*
************************************************************************
      double precision x(1), dx
      integer nseg, niseg(1), k, j, n

      do 10 k=2,nseg
   10 niseg(k) = niseg(k) + niseg(k-1)

      do 11 k=nseg+1,2,-1
   11 niseg(k) = niseg(k-1) + k
      niseg(1) = 1

      do 12 k=nseg,1,-1
      n = niseg(k+1) - niseg(k)
      dx = (x(k+1) - x(k))/float(n)
      do 12 j=1,n
   12 x(niseg(k)+j) = x(k) + float(j)*dx

      return
      end
      subroutine refine(nlvl,nt0,nv0,usrt,xrfnt,rfnt,xvert,vert)

      integer nlvl, nt0, nv0, usrt(6,*)
      integer xrfnt(*), rfnt(3,*), xvert(*), vert(2,*)

      integer i, k, n, shft, nt, nv

*     we require that nt0 = 3 mod 4 for the refinement process.  if
*     necessary, we renumber the macro triangles begining with 2, 3,
*     or 4 to achieve this.
      shft = 3 - mod(nt0,4)
      if (shft .gt. 0) then
        do 10 i=nt0,1,-1
          do 11 k=1,3
   11     usrt(k,i+shft) = usrt(k,i)

          do 12 k=4,6
            if (usrt(k,i) .gt. 0) then
              usrt(k,i+shft) = usrt(k,i) + shft

            else
              usrt(k,i+shft) = usrt(k,i)
              endif
   12     continue
   10   continue
        endif

      nt = nt0 + shft
      nv = nv0
      xrfnt(1) = 1 + shft
      xvert(1) = 1
      do 20 n=1,nlvl-1
        xrfnt(n+1) = nt + 1
        xvert(n+1) = nv + 1
        do 20 i=xrfnt(n),xrfnt(n+1)-1
        call divide(i,xrfnt(2)-1,usrt,nt,rfnt,nv,vert)
   20 continue
      xrfnt(nlvl+1) = nt + 1
      xvert(nlvl+1) = nv + 1

      return
      end
      subroutine divide(i,nt0,usrt,nt,rfnt,nv,vert)

      integer i,nt0,usrt(6,1),nt,rfnt(3,1),nv,vert(2,1)
      integer j,k,l,ison,vtx,km1,kp1,vf,kbar,jbar,nbr

      if (i .le. nt0) then
*       ---------------------------------------------
*        triangle to be divided is a macro triangle.
*       ---------------------------------------------
*       set the son field for triangle i and set the
*       father, level, and son fields for its descendent quartet.
        ison = nt + 1
        rfnt(3,i) = ison
        rfnt(1,ison) = i
        rfnt(2,ison) = 2
        do 10 l=0,3
   10   rfnt(3,ison+l) = 0

*       set the fields refering to the vertices of the father of ison.
        do 20 l=1,3
   20   rfnt(2,ison+l) = usrt(l,i)

*       set the fields refering to the vertices of ison.
        do 30 l=1,3
          nbr = usrt(3+l,i)
          if (nbr .lt. 0) then
*           edge l of triangle i is a boundary edge.
*           create a boundary vertex.
            nv = nv + 1
            rfnt(1,ison+l) = nv
            vert(1,nv) = ison+l
            vert(2,nv) = nbr

          else if (rfnt(3,nbr) .eq. 0) then
*           neighboring triangle across edge l is unrefined.
*           create an irregular vertex.
            nv = nv + 1
            rfnt(1,ison+l) = nv
            vert(1,nv) = -(ison+l)
            vert(2,nv) = nbr

          else
*           neighboring triangle is refined.
*           vertex exists; change it to a regular vertex.
            k = 1
            if (usrt(5,nbr) .eq. i) k = 2
            if (usrt(6,nbr) .eq. i) k = 3
            vtx = rfnt(1,rfnt(3,nbr)+k)
            rfnt(1,ison+l) = vtx
            vert(1,vtx) = abs(vert(1,vtx))
            vert(2,vtx) = ison+l
          endif
   30   continue

      else
*       -------------------------------------------------
*        triangle to be divided is not a macro triangle.
*       -------------------------------------------------
*       decompose i.
        k = mod(i,4)
        j = i - k

*       set the son field for triangle i and set the 
*       father, level, and son fields for its descendent quartet.
        ison = nt + 1
        rfnt(3,i) = ison
        rfnt(1,ison) = i
        rfnt(2,ison) = rfnt(2,j) + 1
        do 40 l=0,3
   40   rfnt(3,ison+l) = 0

        if (k .eq. 0) then
*         --------------------------------------------------------------
*          triangle to be divided is the central member of the quartet.
*         --------------------------------------------------------------
*         set the fields refering to the vertices of the father of ison.
          do 50 l=1,3
   50     rfnt(2,ison+l) = rfnt(1,j+l)

*         set the fields refering to the vertices of ison.
          do 60 l=1,3
            if (rfnt(3,j+l) .eq. 0) then
*             neighboring triangle across edge l is unrefined.
*             create an irregular vertex.
              nv = nv + 1
              rfnt(1,ison+l) = nv
              vert(1,nv) = -(ison+l)
              vert(2,nv) = j+l

            else
*             neighboring triangle is refined.
*             vertex exists; change it to a regular vertex.
              vtx = rfnt(1,rfnt(3,j+l)+l)
              rfnt(1,ison+l) = vtx
              vert(1,vtx) = abs(vert(1,vtx))
              vert(2,vtx) = ison+l
            endif
   60     continue

        else
          km1 = 1 + mod(k+1,3)
          kp1 = 1 + mod(k,3)

*         set the fields refering to the vertices
*         of the father of ison.
          rfnt(2,ison+k) = rfnt(2,j+k)
          rfnt(2,ison+km1) = rfnt(1,j+kp1)
          rfnt(2,ison+kp1) = rfnt(1,j+km1)

*         set the field refering to vertex k of ison.
          if(rfnt(3,j) .eq. 0) then
*           neighboring triangle across edge k is unrefined.
*           create an irregular vertex.
            nv = nv + 1
            rfnt(1,ison+k) = nv
            vert(1,nv) = -(ison+k)
            vert(2,nv) = j

          else
*           neighboring triangle is refined.
*           vertex exists; change it to a regular vertex.
            vtx = rfnt(1,rfnt(3,j)+k)
            rfnt(1,ison+k) = vtx
            vert(1,vtx) = abs(vert(1,vtx))
            vert(2,vtx) = ison+k
            endif

*         set the field refering to vertex kp1 of ison.
          vf = vert(2,rfnt(1,j+kp1))
          if (vf .lt. 0) then
*           edge kp1 of triangle i is a boundary edge.
*           create a boundary vertex.
            nv = nv + 1
            rfnt(1,ison+kp1) = nv
            vert(1,nv) = ison+kp1
            vert(2,nv) = vf

          else
*           find neighboring triangle across edge kp1 of triangle i.
            kbar = mod(vf,4)
            jbar = vf - kbar
            if (jbar .eq. j) then
              vf = vert(1,rfnt(1,j+kp1))
              kbar = mod(vf,4)
              jbar = vf - kbar
              endif
            nbr = jbar + (1 + mod(kbar,3))

            if (rfnt(3,nbr) .eq. 0) then
*             neighbor is unrefined.  create an irregular vertex.
              nv = nv + 1
              rfnt(1,ison+kp1) = nv
              vert(1,nv) = -(ison+kp1)
              vert(2,nv) = nbr

            else
*             neighbor is refined.
*             vertex exists; change it to a regular vertex.
              vtx = rfnt(1,rfnt(3,nbr)+kbar)
              rfnt(1,ison+kp1) = vtx
              vert(1,vtx) = abs(vert(1,vtx))
              vert(2,vtx) = ison+kp1
            endif
          endif

*         set the field refering to vertex km1 of ison.
          vf = vert(2,rfnt(1,j+km1))
          if (vf .lt. 0) then
*           edge km1 of triangle i is a boundary edge.
*           create a boundary vertex.
            nv = nv + 1
            rfnt(1,ison+km1) = nv
            vert(1,nv) = ison+km1
            vert(2,nv) = vf

          else
*           find neighboring triangle across edge km1 of triangle i.
            kbar = mod(vf,4)
            jbar = vf - kbar
            if (jbar .eq. j) then
              vf = vert(1,rfnt(1,j+km1))
              kbar = mod(vf,4)
              jbar = vf - kbar
              endif
            nbr = jbar + (1 + mod(kbar+1,3))

            if (rfnt(3,nbr) .eq. 0) then
*             neighbor is unrefined.  create an irregular vertex.
              nv = nv + 1
              rfnt(1,ison+km1) = nv
              vert(1,nv) = -(ison+km1)
              vert(2,nv) = nbr

            else
*             neighbor is refined.
*             vertex exists; change it to a regular vertex.
              vtx = rfnt(1,rfnt(3,nbr)+kbar)
              rfnt(1,ison+km1) = vtx
              vert(1,vtx) = abs(vert(1,vtx))
              vert(2,vtx) = ison+km1
            endif
          endif
        endif
      endif

      nt = nt + 4

      return
      end
      subroutine fntvtx(nlvl,xrfnt,rfnt,  ntri,tvtx)

      integer nlvl,xrfnt(*),rfnt(3,*),  ntri,tvtx(0:2,*), j

      ntri = 0

      do 10 j=xrfnt(nlvl),xrfnt(nlvl+1)-1,4
       ntri = ntri + 1
       tvtx(0,ntri) = rfnt(1,j+1)
       tvtx(1,ntri) = rfnt(1,j+2)
       tvtx(2,ntri) = rfnt(1,j+3)

       ntri = ntri + 1
       tvtx(0,ntri) = rfnt(2,j+1)
       tvtx(1,ntri) = rfnt(1,j+3)
       tvtx(2,ntri) = rfnt(1,j+2)

       ntri = ntri + 1
       tvtx(0,ntri) = rfnt(1,j+3)
       tvtx(1,ntri) = rfnt(2,j+2)
       tvtx(2,ntri) = rfnt(1,j+1)

       ntri = ntri + 1
       tvtx(0,ntri) = rfnt(1,j+2)
       tvtx(1,ntri) = rfnt(1,j+1)
       tvtx(2,ntri) = rfnt(2,j+3)
   10 continue

      return
      end
      subroutine fnevtx(nlvl,xrfnt,rfnt,xvert,vert,  nedg,evtx)

      integer nlvl,xrfnt(1),rfnt(3,1),xvert(1),vert(2,1)
      integer nedg,evtx(0:3,1)
      integer i,j,k,km1,kp1

      nedg = 0

      do 10 i=xvert(nlvl),xvert(nlvl+1)-1
       k = mod(vert(1,i),4)
       j = vert(1,i) - k
       km1 = 1 + mod(k+1,3)
       kp1 = 1 + mod(k,3)

       nedg = nedg + 1
       evtx(0,nedg) = rfnt(2,j+kp1)
       evtx(1,nedg) = rfnt(1,j+k)
       evtx(2,nedg) = rfnt(1,j+km1)

       nedg = nedg + 1
       evtx(0,nedg) = rfnt(1,j+k)
       evtx(1,nedg) = rfnt(2,j+km1)
       evtx(2,nedg) = rfnt(1,j+kp1)

       if(vert(2,i).le.0) then
        evtx(3,nedg-1) = vert(2,i)
        evtx(3,nedg)   = vert(2,i)

       else
        k = mod(vert(2,i),4)
        j = vert(2,i) - k
        km1 = 1 + mod(k+1,3)
        kp1 = 1 + mod(k,3)
        evtx(3,nedg-1) = rfnt(1,j+kp1)
        evtx(3,nedg)   = rfnt(1,j+km1)
        endif
   10 continue

      do 20 j=xrfnt(nlvl),xrfnt(nlvl+1)-1,4
      do 20 k=1,3
       km1 = 1 + mod(k+1,3)
       kp1 = 1 + mod(k,3)
        
       nedg = nedg + 1
       evtx(0,nedg) = rfnt(1,j+kp1)
       evtx(1,nedg) = rfnt(1,j+km1)
       evtx(2,nedg) = rfnt(1,j+k)
       evtx(3,nedg) = rfnt(2,j+k)
   20 continue

      return
      end
