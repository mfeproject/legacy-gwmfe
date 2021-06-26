      subroutine rdhead
************************************************************************
*
*   RDHEAD -- Read the title strings from mfein and write to mfelog
*
************************************************************************
      include "parameters.h"
      
      character*8 title*72
      integer i

      open(5,file='mfein')
      open(8,file='mfelog')
*     -----------------------------------------------
*      Read title strings and write log file header.
*     -----------------------------------------------
  110 format(79a)
  130 format(a)
  140 format('*  ',a,t79,'*')

      write(8,110) ('*', i=1,79)
   10 read (5,130,end=910) title
      if ( title .eq. '$' ) go to 11
      write(8,140) title
      go to 10
   11 write(8,110) ('*', i=1,79)
*     -----------------------------
*      Output the code parameters.
*     -----------------------------
  200 format(//a/)
  210 format(t3,a,t42,'=',i7)

      write(8,200) 'I N T E R N A L   C O D E   P A R A M E T E R S'
      write(8,210) 'Max number of nodes (MNOD)', mnod
      write(8,210) 'Max number of triangles (MTRI)', mtri
      write(8,210) 'Max number of edges (MEDG)', medg
      write(8,210) 'LE solver storage allocation (SMAX)', smax
      write(8,210) 'Max number of boundary nodes (MBND)', mbnd

      return

  910 write(8,911)
  911 format(/'** RDHEAD: Bad file format -- at EOF.',
     +       /'** Aborting execution.')
      stop
      end
