*     Number of PDEs in the system.
      integer npde
      parameter (npde=2)
      
*     Maximum number of nodes, triangles, edges, and boundary nodes.
      integer mnod, mtri, medg, mbnd
      parameter (mnod=693, mtri=1280, medg=1972, mbnd=108)
      
*     Array size used to store the Jacobian matrix.
      integer smax
      parameter (smax=500000)
