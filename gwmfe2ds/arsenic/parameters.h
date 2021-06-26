*     Maximum number of nodes, triangles, edges, and boundary nodes.
      integer mnod, mtri, medg, mbnd
      parameter (mnod=289, mtri=512, medg=800, mbnd=64)
      
*     Array size used to store the Jacobian matrix.
      integer smax
      parameter (smax=100000)
