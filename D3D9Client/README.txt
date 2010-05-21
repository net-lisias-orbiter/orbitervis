ORBITER VISUALISATION PROJECT -
DirectX 9 port

1. Overview
-----------
This is a direct translation of the DirectX 7 code into DirectX 9 code. This port
focusses on implementing the reference DirectX 7 client, using DirectX 9 conventions.
Main differences between the DirectX 7 and DirectX 9 clients are:
- Deprecation of DirectDraw; DirectDraw calls has been translated in this port.
- Use of hardware index buffers where possible; DirectX 9 offers support for hardware index buffers
- Render loop is updated to more modern DirectX 9 approach. No more manual managing of backbuffers.
- Device enumeration was completely rewritten.
- Texture loading is delegated to standard library functions.
- Matrix transformations are delegated to hardware whereever possible.

2. Compatibility
----------------
The current code set is compatible with orbiter beta release orbiter_beta_070927 found at
http://download.orbit.m6.net/betaNG/orbiter_beta.html
