*     Number of PDEs in the system.
      integer npde
      parameter (npde=2)
      
*     Maximum number of nodes, triangles, edges, and boundary nodes.
      integer mnod, mtri, medg, mbnd
      parameter (mnod=1089, mtri=2048, medg=3136, mbnd=128)
      
*     Array size used to store the Jacobian matrix.
      integer smax
      parameter (smax=1210000)
