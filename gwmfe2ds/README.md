Using GWMFE2DS
==============
This file describes how to compile GWMFE2DS and run some example problems
from [1]. Development of this Fortran 77 code ended around 1991. A few minor
changes have been made to allow the code to build with contemporary compilers
(mostly in the visualization tool), but otherwise this is exactly the code
used to generate the results in [1]. I've retained it for historical and
reference purposes. Modern implementations of the GWMFE method are available.

Neil Carlson, June 2021

What's Here?
------------
The `source` directory contains all the source code for GWMFE2DS except for
a header file, `parameters.h`, that sets problem size parameters, and files
defining the `setup` and `pderhs` subroutines that are specific to the problem
and PDE system being solved. Versions of these files are found in each of
the problem directories described below.

The compiled executables will be installed into the `bin` directory.

The `gtools` directory contains a custom visualization tool for GWMFE2DS
output; more on this below.

Directories for problems from [1]:
* `arsenic`: Nonlinear arsenic diffusion problem from semiconductor
  process (section 6.1)
* `heat`: Heat equation example illustrating grid collapse (Section 5)
* `oil`: Buckley-Leverett 5-spot problem (Section 6.3)
* `semi`: Drift-diffusion equations from semiconductor device modeling
  (Section 6.2)
* `soap`: Motion by mean curvature (soap bubble problem) (Section 6.4)
* `burgers`: 2D Burgers' equation test problem (from earlier 2D work)

Compiling
---------
The build system has been updated to use CMake (version 3.16 or later).
Compiling is straightforward:

```sh
mkdir build
cd build
cmake -D CMAKE_BUILD_TYPE=Release ..
make
make install
```
If CMake has trouble finding the Fortran and C compiler you want to use, set
your environment variables `FC` and `CC` to the compiler paths before running
`cmake`.

This will install the compiled executables into the `bin` directory:
a customized executable for each problem (same name as the directory) and the
visualization tools `mkgrf` and `gp2` described below.

This is known to work on Linux using the GNU, Intel and NAG Fortran compilers.
It should work for other compilers too. The only obstacle may be the need to
use a compiler flag that allows the compiler to handle this old F77 code
without complaint; see, for example, the flags for the GNU compiler in
`CMakeLists.txt`

Running the Examples
--------------------
The GWMFE2DS executables read their input from a file named `mfein` and
write their output to `mfelog` and `mfeout`. The former contains simulation
diagnostic information, and the latter the computed solution at a sequence
of times. Each directory contains a shortcut (symbolic link) named `go` that
points to the installed example executable. So running `go` in a problem
directory will run the program provided there is a `mfein` input file.

Each problem directory also has inputs and reference outputs for one or more
examples that are stored in the `Data` subdirectory. Use the small helper
shell script `run-example.sh` to run the examples: `run-example.sh 1` will
run the first example input file, and so forth. The inputs are echoed to
`mfelog` together with periodic progress reports from the ODE integrator
(indicating number of steps taken, number of residuals, number of Jacobians,
etc.) You should compare the results in that file to those archived in the
`Data` directory to verify that things are running properly. The number of
residual and Jacobian evaluations (NRE and NJE) should match fairly closely
(within 5%) at corresponding times. It is unreasonable, though, to expect an
exact match due to differences in compilers, math libraries, etc.

Viewing the Results
-------------------
The computed solution is written to the binary format file `mfeout` at
a sequence of times. The format is described below. A post-processing
utility is then used to convert this data to a suitable format for a given
visualization tool.

The `mkgrf` program is such a utility for GP2, which is an interactive
visualization program written specifically for 2D MFE by Lee Busby in the
mid-1980s. The program takes no command line arguments, reads a file named
`mfeout` and creates a file named `mfegrf` that can be read by GP2.

GP2 produces output for a
[Tektronixs 4010 display](https://en.wikipedia.org/wiki/Tektronix_4010).
If you're running the X11 windowing system, its venerable xterm window
includes a Tektronix display emulator mode. `xterm -t` will start the window
in Tek emulation mode. With an existing xterm window, hover the mouse over
the window and click-and-hold the middle mouse button while the control key
is pressed. This will bring up a menu, and near the bottom are items for
switching between modes. Run `gp2` (installed into the `bin` directory by the
compilation procedure above) from this Tek emulation window. See the man page
in `gtools/gp2/man` for instructions on using `gp2`.  Note that `gp2` will
invoke two helper programs `gpp` and `gplot2` that are also installed by
the compilation procedure above, and it is more or less necessary that you
add the `bin` directory to your search path (the `PATH` environment variable)
for `gp2` to run without error.



#### Binary output format
The `mfeout` file is created using Fortran unformatted output, which consists
of a sequence of data records. The first part of the file describes the mesh
connectivity and other time-invariant data.

* The first record consists of 3 integers: the number of components in the PDE
  system (`NPDE`), the number of nodes in the mesh (`NNOD`), and the number of
  triangles in the mesh (`NTRI`).

* The second record describes the mesh connectivity. This is an integer array
  of size `3*NTRI`. The first group of 3 integers are the node indices of the
  first mesh triangle, the next group of 3 integers are the node indices of
  the second mesh triangle, and so forth.

The remaining records give the solution at a sequence of times. The solution
at each time consists of 3 records.
* The first is just the problem time (double precision).
* The second is a double precision array of size `NNOD*(2+NPDE)`. Each group
  of `2+NPDE` values are the X and Y coordinates of a node and the values of
  the PDE variables at that node.
* The third record contains some diagnostic data (double precision, real, and
  8 integers) that is also written to `mfelog`. This record can be ignored.

Note that a Fortran unformatted record contains a small compiler-dependent
header and trailer that the I/O runtime uses to navigate the file. This means
that a program to read the output file is best written in Fortran and compiled
with the same compiler as GWMFE2DS.

Applying GWMFE2DS to a New Problem
----------------------------------   
Here is an outline for how to go about applying GWMFE2DS to a new problem.
You'll need to use the provided examples and [1] as your guide.

1. Create a new directory at the same level as the other problem directories,
   and copy the `CMakeLists.txt` file from another problem into it. If you
   have a scalar problem, get it from one of the scalar problem, or if you
   have a system, from one of the system problems. In steps 2 and 3 you'll
   want to copy several other files from the directory as starting points /
   examples. You'll also need to create a symlink to the source directory
   as with the other problems: either `ln -s ../source/scalar source` for a
   scalar PDE problem, or `ln -s ../source/system source` for a PDE system
   problem.
2. You need to provide two subroutines, `pderhs` and `psetup`:
   * `pderhs` evaluates the inner products of the PDE right hand side with
     the GWMFE basis functions. The name varies, but typically it is found
     in the file `pde.f`
   * `psetup` sets up the problem, describing boundary conditions, initial
     grid, initial solution, etc. Again the file name varies but this is
     typically found in `psetup.f`
3. Copy a `parameters.h` file from a problem and modify it appropriately.
   This defines basic parameters used to dimension arrays in the code.
4. Modify your problem's `CMakeLists.txt` file to set the value of the `EXE`
   variable (the name of the executable) to something new. Following the
   pattern of the other problems by using the name of the directory works
   well. You also need to ensure that all your source files are listed for
   the executable.
5. In the top-level `CMakeLists.txt` file add another `add_subdirectory`
   line to include your new problem directory.

References
----------
[1] Carlson and Miller, "Design and application of a gradient-weighted moving
    finite element code II: In two dimensions", SIAM J. Sci. Comput., 19 (1998).
