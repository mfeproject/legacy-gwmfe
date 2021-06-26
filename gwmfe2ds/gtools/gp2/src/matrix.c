/*
	The routines in this file are general utility routines for operating
	on 4x4 matrices encountered in 3-d graphics problems. Only the cross
	section routines currently require the functions in this file.
*/
#include	<stdio.h>
#include	<ctype.h>
#include	<strings.h>
#include	<math.h>
#include	"defs2.h"


/*	make the matrix 'a' an identity matrix
*/
makeident(a)
double a[4][4];
{
	register int i,j;

	for(i=0;i<4;i++)
		for(j=0;j<4;j++)
			a[i][j] = (i==j) ? 1.0 : 0.0;
}


/*	multiply 'a' on the left by 'b' on the right, leaving the result
*	in 'c'
*/
matmult(a,b,c)
double a[4][4],b[4][4],c[4][4];
{
	double d[4][4];
	register int k,j,i;

	for(i=0;i<4;i++)
		for(j=0;j<4;j++){
			d[i][j] = 0.0;
			for(k=0;k<4;k++)
				d[i][j] += a[i][k] * b[k][j];
		}
	copytransform(d,c);
}


/*	copy the matrix 'a' into the matrix 'b'
*/
copytransform(a,b)
double a[4][4], b[4][4];
{
	register int i,j;

	for(i=0;i<4;i++)
		for(j=0;j<4;j++)
			b[i][j] = a[i][j];
}


/*	Given a matrix 'a', a direction 'dir', and a value 'val', apply
*	the appropriate translation matrix to 'a'.(Post-multiply 'a'.)
*/
translate(a,dir,val)
double a[4][4],val;
char dir;
{
	if(dir == 'x'){
		a[0][0] += val*a[0][3];
		a[1][0] += val*a[1][3];
		a[2][0] += val*a[2][3];
		a[3][0] += val*a[3][3];
	}else if(dir == 'y'){
		a[0][1] += val*a[0][3];
		a[1][1] += val*a[1][3];
		a[2][1] += val*a[2][3];
		a[3][1] += val*a[3][3];
	}else{
		a[0][2] += val*a[0][3];
		a[1][2] += val*a[1][3];
		a[2][2] += val*a[2][3];
		a[3][2] += val*a[3][3];
	}
}


/*	Given a matrix 'a', a direction 'dir', and a value 'val', apply
*	the appropriate scaling matrix to 'a'. (Post-multiply 'a'.)
*/
rescale(a,dir,val)
double a[4][4],val;
char dir;
{

	if(dir == 'x' || dir == 'a'){
		a[0][0] *= val;
		a[1][0] *= val;
		a[2][0] *= val;
		a[3][0] *= val;
	}
	if(dir == 'y' || dir == 'a'){
		a[0][1] *= val;
		a[1][1] *= val;
		a[2][1] *= val;
		a[3][1] *= val;
	}
	if(dir == 'z' || dir == 'a'){
		a[0][2] *= val;
		a[1][2] *= val;
		a[2][2] *= val;
		a[3][2] *= val;
	}
}


/*	Given a matrix 'a', a direction 'dir', and a value 'val', apply
*	the appropriate rotation matrix to 'a'. Rotation is assumed to be
*	given in decimal degrees. 'a' is post-multiplied by the rotation
*	matrix.
*/
rotate(a,dir,val)
double a[4][4],val;
char dir;
{
	double cose,sine;

	cose = cos(val*PI/180.0);
	sine = sin(val*PI/180.0);
	if(dir == 'x')
		rot2(a,cose,sine,1,2);
	else if(dir == 'y')
		rot2(a,cose,-sine,0,2);
	else
		rot2(a,cose,sine,0,1);
}


rot2(a,cose,sine,c1,c2)
double a[4][4],cose,sine;
int c1,c2;
{
	register int i;
	double t1,t2;

	for(i=0;i<4;i++){
		t1 = a[i][c1]*cose;
		t2 = a[i][c1]*sine;
		a[i][c1] = t1 - a[i][c2]*sine;
		a[i][c2] = t2 + a[i][c2]*cose;
	}
}


/*	It seems natural to define shear with two parameters 'u' and 'v'.
*	For example, the call "shear(I,'z',u,v)" where I is the 4x4 identity
*	would produce a matrix mapping (x,y,z,1) into (x + uz,y + vz,z,1).
*	And similarly for the x or y axes.
*/
shear(a,dir,u,v)
double a[4][4],u,v;
char dir;
{
	if(dir == 'x'){
		a[0][1] += u*a[0][0];
		a[1][1] += u*a[1][0];
		a[2][1] += u*a[2][0];
		a[3][1] += u*a[3][0];
		a[0][2] += v*a[0][0];
		a[1][2] += v*a[1][0];
		a[2][2] += v*a[2][0];
		a[3][2] += v*a[3][0];
	}else if(dir == 'y'){
		a[0][0] += u*a[0][1];
		a[1][0] += u*a[1][1];
		a[2][0] += u*a[2][1];
		a[3][0] += u*a[3][1];
		a[0][2] += v*a[0][1];
		a[1][2] += v*a[1][1];
		a[2][2] += v*a[2][1];
		a[3][2] += v*a[3][1];
	}else{
		a[0][0] += u*a[0][2];
		a[1][0] += u*a[1][2];
		a[2][0] += u*a[2][2];
		a[3][0] += u*a[3][2];
		a[0][1] += v*a[0][2];
		a[1][1] += v*a[1][2];
		a[2][1] += v*a[2][2];
		a[3][1] += v*a[3][2];
	}
}
