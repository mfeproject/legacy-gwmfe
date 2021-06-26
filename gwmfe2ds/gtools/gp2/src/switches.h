/*
	This header file contains several compiler "switches", definitions
	which select alternative code to compile.
*/

/*
	The two following switches select which of three plotting alternatives
	to include in the code. If neither "FILEPLOT" nor "PIPEPLOT" is
	defined, then the "plot" command in gp2 is effectively disabled.
	If "FILEPLOT" only is defined, then an ascii description of the screen
	is written to a file named "plotXXXXXX" whenever a "plot" command is
	issued. ("XXXXXX" is a unique number.)
	If "PIPEPLOT" only is defined, then gp2 looks for and sends picture
	descriptions to a program named "gplot2", which typically will create
	a plotfile ready for a hard-copy plotter.
	It is an error for both "FILEPLOT" and "PIPEPLOT" to be defined at once.
*/

/*#define	FILEPLOT*/
#define	PIPEPLOT

/*
	The next switch, if defined, causes code which attempts to catch
	interrupt signals to be included in the source. If not defined, then
	interrupts will typically terminate "gp2" and return the user to the
	shell.
*/
/* #define	HANDLE_INTERRUPTS */
