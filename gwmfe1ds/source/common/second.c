void second_(c)
float *c;
{
   float u,s;
   void second();
   second(c);
   return;
}

void second(c)
float *c;
{
#include <sys/types.h>
#include <sys/times.h>
#include <sys/param.h> /* for HZ */
   clock_t times();
   clock_t t1;
   struct tms t2;
   float *c,u,s;

   t1=times(&t2);
   u = ((float)t2.tms_utime)/((float)HZ);
   s = ((float)t2.tms_stime)/((float)HZ);
   *c = u + s;
   return;
}
