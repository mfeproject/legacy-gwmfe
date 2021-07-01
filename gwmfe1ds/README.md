Using GWMFE1DS
==============
This file describes how to compile GWMFE1DS and run some example problems
from [1]. Development of this Fortran 77 code ended around 1991. A few minor
changes have been made to allow the code to build with contemporary compilers
(mostly in the visualization tool), but otherwise this is exactly the code
used to generate the results in [1]. I've retained it for historical and
reference purposes. Modern implementations of the GWMFE method are available.

Neil Carlson, June 2021

What's Here?
------------
The `source` directory contains all the source code for GWMFE1DS except for
a header file, `parameters.h`, that sets problem size parameters, and a
Fortran function, `pde.f`, that computes terms specific to the PDE system
being solved. Versions of these files are found in each of the problem
directories described below.

The compiled executables will be installed into the `bin` directory.

The `gtools` directory contains a custom visualization tool for GWMFE1DS
output; more on this below.

Directories for problems from [1]:
* `conv-diff`: Convection-diffusion problem (section 6.1)
* `burgers`: Burgers' equation. Double-sine and nonlinear source problems
  (sections 6.2--6.4)
* `drift-diff`: Drift-diffusion equation for semiconductors (section 7.1)
* `navier-stokes`: Navier-Stokes Sod shock-tube problem (section 7.2)

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
visualization tools `gp1` and `gplot1` described below.

This is known to work on Linux using the GNU, Intel and NAG Fortran compilers.
It should work for other compilers too. The only obstacle may be the need to
use a compiler flag that allows the compiler to handle this old F77 code
without complaint; see, for example, the flags for the GNU compiler in
`CMakeLists.txt`

Running the Examples
--------------------
The GWMFE1DS executables read their input from a file named `mfein` and
write their output to `mfelog` and `mfegrf`. The former contains simulation
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
The format of the output file `mfegrf` is quite simple.  It consists of a
time sequence of frames. The initial line of each frame gives the problem
time and other info, and is followed by the GWMFE solution proper, each
line giving the values of the unknowns (x, u, v, ...) at a node, in sequence.

There are a multitude of tools that could be used to visualize the results;
e.g. gnuplot or matlab. This may require hand editing mfegrf to suit the
requirements of the tool. Better yet is to modify the source code `wrgrf.f`
to write the solution in the required format.

GP1 is an interactive visualization program written specifically for 1D MFE
by Lee Busby in the mid-1980s. The program produces output for a
[Tektronixs 4010 display](https://en.wikipedia.org/wiki/Tektronix_4010).
If you're running the X11 windowing system, its venerable xterm window
includes a Tektronix display emulator mode. `xterm -t` will start the window
in Tek emulation mode. With an existing xterm window, hover the mouse over
the window and click-and-hold the middle mouse button while the control key
is pressed. This will bring up a menu, and near the bottom are items for
switching between modes. Run `gp1` (installed into the `bin` directory by the
compilation procedure above) from this Tek emulation window. See the man page
in `gtools/gp1/man` for instructions on using `gp1`. Note that `gp1` may
invoke the helper program `gplot`, and it is more or less necessary that
you add the `bin` directory to your search path (the `PATH` environment
variable) for `gp1` to run without error.

Applying GWMFE1DS to a New Problem
----------------------------------
Here is an outline for how to go about applying GWMFE1DS to a new problem.
You'll need to use the provided examples and [1] as your guide.

1. Create a new directory at the same level as the other problem directories,
   and copy the `CMakeLists.txt`, `parameters.h`, and `pde.f` files from
   another problem into it. If you have a scalar problem, get them from one
   of the scalar problem, or if you have a system, from one of the system
   problems. You'll also need to create a symlink to the source directory as
   with the other problems: `ln -s ../source .`
2. You need to modify the `pde.f` code to compute the inner products of the
   your PDE right hand side with the GWMFE basis functions.
3. The `parameters.h` file defines basic parameters used to dimension arrays
   in the code, and these will need to be defined appropriately.
4. Modify your problem's `CMakeLists.txt` file to set the value of the `EXE`
   variable (the name of the executable) to something new. Following the
   pattern of the other problems by using the name of the directory works
   well.
5. In the top-level `CMakeLists.txt` file add another `add_subdirectory`
   line to include your new problem directory.

References
----------
[1] Carlson and Miller, "Design and application of a gradient-weighted moving
    finite element code I: In one dimension", SIAM J. Sci. Comput., 19 (1998).
