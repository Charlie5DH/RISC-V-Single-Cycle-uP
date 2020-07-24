/* MDH WCET BENCHMARK SUITE. */
/* 2012/09/28, Jan Gustafsson <jan.gustafsson@mdh.se>
 * Changes:
 *  - This program redefines the C standard function fabs and sqrt. Therefore, these functions has been renamed with prefix qurt_.
 *  - qurt.c:95:6: warning: explicitly assigning a variable of type 'float' to itself: fixed
 *  - qurt.c:105:6: warning: unused variable 'flag' [-Wunused-variable]: fixed
 */

/*************************************************************************/
/*                                                                       */
/*   SNU-RT Benchmark Suite for Worst Case Timing Analysis               */
/*   =====================================================               */
/*                              Collected and Modified by S.-S. Lim      */
/*                                           sslim@archi.snu.ac.kr       */
/*                                         Real-Time Research Group      */
/*                                        Seoul National University      */
/*                                                                       */
/*                                                                       */
/*        < Features > - restrictions for our experimental environment   */
/*                                                                       */
/*          1. Completely structured.                                    */
/*               - There are no unconditional jumps.                     */
/*               - There are no exit from loop bodies.                   */
/*                 (There are no 'break' or 'return' in loop bodies)     */
/*          2. No 'switch' statements.                                   */
/*          3. No 'do..while' statements.                                */
/*          4. Expressions are restricted.                               */
/*               - There are no multiple expressions joined by 'or',     */
/*                'and' operations.                                      */
/*          5. No library calls.                                         */
/*               - All the functions needed are implemented in the       */
/*                 source file.                                          */
/*                                                                       */
/*                                                                       */
/*************************************************************************/
/*                                                                       */
/*  FILE: qurt.c                                                         */
/*  SOURCE : Turbo C Programming for Engineering by Hyun Soo Ahn         */
/*                                                                       */
/*  DESCRIPTION :                                                        */
/*                                                                       */
/*     Root computation of quadratic equations.                          */
/*     The real and imaginary parts of the solution are stored in the    */
/*     array x1[] and x2[].                                              */
/*                                                                       */
/*  REMARK :                                                             */
/*                                                                       */
/*  EXECUTION TIME :                                                     */
/*                                                                       */
/*                                                                       */
/*************************************************************************/

#include <hf-risc.h>

/*
** Benchmark Suite for Real-Time Applications, by Sung-Soo Lim
**     
**    III-7. qurt.c : the root computation of a quadratic equation
**                 (from the book C Programming for EEs by Hyun Soon Ahn)
*/


float a[3], x1[2], x2[2];
int flag;

int  qurt();


float qurt_fabs(float n)
{
  float f;

  if (n >= 0) f = n;
  else f = -n;
  return f;
}

float qurt_sqrt(val)
float val;
{
  float x = val/10;

  float dx;

  float diff;
  float min_tol = 0.00001;

  int i, flag;

  flag = 0;
  if (val == 0 ) x = 0;
  else {
    for (i=1;i<20;i++)
      {
	if (!flag) {
	  dx = (val - (x*x)) / (2.0 * x);
	  x = x + dx;
	  diff = val - (x*x);
	  if (qurt_fabs(diff) <= min_tol) flag = 1;
	}
	else {} /* JG */
/*	  x =x; */
      }
  }
  return (x);
}


int _main()
{

/*	int flag; */ /* JG */


	a[0] =  1.0;
	a[1] = -3.0;
	a[2] =  2.0;

	qurt();


  a[0] =  1.0;
	a[1] = -2.0;
	a[2] =  1.0;

  qurt();


  a[0] =  1.0;
	a[1] = -4.0;
	a[2] =  8.0;

  qurt();
  return 0;
}

int  qurt()
{
	float  d, w1, w2;

	if(a[0] == 0.0) return(999);
	d = a[1]*a[1] - 4 * a[0] * a[2];
	w1 = 2.0 * a[0];
	w2 = qurt_sqrt(qurt_fabs(d));
	if(d > 0.0)
	{
		 flag = 1;
		 x1[0] = (-a[1] + w2) / w1;
		 x1[1] = 0.0;
		 x2[0] = (-a[1] - w2) / w1;
		 x2[1] = 0.0;
		 return(0);
	}
	else if(d == 0.0)
	{
		 flag = 0;
		 x1[0] = -a[1] / w1;
		 x1[1] = 0.0;
		 x2[0] = x1[0];
		 x2[1] = 0.0;
		 return(0);
	}
	else
	{
		 flag = -1;
		 w2 /= w1;
		 x1[0] = -a[1] / w1;
		 x1[1] = w2;
		 x2[0] = x1[0];
		 x2[1] = -w2;
		 return(0);
	}
}

void main(void){
	volatile unsigned int cycles;

	printf("\nQURT benchmark");
	cycles = TIMER0;
	_main();
	cycles = TIMER0 - cycles;
	printf("\nWCET: %d cycles\n", cycles);
	
}

