Shift-map library 
Linus Svärm and Petter Strandmark
{linus,petter}@maths.lth.se


This library has been tested in the following environments
* Windows 7 64-bit, Matlab 2010a, Microsoft Visual C++ 9.0
* Linux 64-bit, GCC 4


REQUIREMENTS
----------------------------
* C++ compiler with Matlab
* Alpha-expansion library (included; see separate readme in gc directory)
* DAISY library (available at http://cvlab.epfl.ch/~tola/daisy.html)

BINARIES
----------------------------
Binaries for Windows 64-bit and Linux 64-bit are included. However, we recommend compiling the library yourself.


USAGE
----------------------------
* Make sure your compiler is configured for Matlab with "mex -setup"
* Run "make_inpaint" and "make_registration" to build the needed MEX files
* Run "demo_shift_inpaint" and "demo_registration"
