ORBITER VISUALISATION PROJECT

The aim of the Orbiter Visualisation Project (OVP) is to provide 3-D
visualisation support for Orbiter Space Flight Simulator via external plugin
modules.

The next Orbiter release distribution will include a "non-graphics" version
of the Orbiter core executable. This can be used as a standalone application
(e.g. as a server in a multi-user environment), but it also allows to load
a graphics client module to provide visualisation support. 

Separating the physics engine (orbiter core) and 3-D graphics support
(graphics clients) will ease code maintenance and provide an upgrade path
for future versions of rendering interfaces. It also allows developers to
implement new graphics features not found in the standard Orbiter
distribution.

OVP is an open source project that spans a number of (relatively independent)
client implementations.

- A DirectX-7 client (D3D7Client) which implements most of the graphics
  features of the Orbiter inline graphics engine. This is intended as a
  reference implementation.

- A DirectX-9 client

- An OpenGL client

Other clients may be added in the future.


Installing OVP
--------------
The installation requirements for the different clients may vary. Check the
documentation in the individual client directories for installation and
compilation prerequisites.

Graphics clients are currently only supported by Orbiter beta snapshots. To
install Orbiter-Beta:

- Create a new Orbiter 2006-P1 (v.060929) installation from the Orbiter Base
  and SDK packages found at orbit.medphys.ucl.ac.uk

- Patch to an Orbiter Beta version by downloading one of the beta diffs
  found at download.orbit.m6.net/betaNG/orbiter_beta.html. Note that different
  clients may be compiled against different beta snapshots. Always check
  the individual client documentation to get the right version.

- Download the OVP sources from http://sourceforge.net/projects/orbitervis
  You need a CVS client for this. Download the CVS source tree with

  cvs -d:pserver:anonymous@orbitervis.cvs.sourceforge.net:/cvsroot/orbitervis login
  cvs -z3 -d:pserver:anonymous@orbitervis.cvs.sourceforge.net:/cvsroot/orbitervis co -P orbitervis

  You should end up with a directory "orbitervis" inside you Orbiter root
  directory.

- Then consult the documentation of the individual clients for further
  instructions.


Martin Schweiger
