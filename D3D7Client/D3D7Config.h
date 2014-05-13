// ==============================================================
//   ORBITER VISUALISATION PROJECT (OVP)
//   D3D7 Client module
//   Copyright (C) 2006-2014 Martin Schweiger
//   Dual licensed under GPL v3 and LGPL v3
// ==============================================================

// ==============================================================
// D3D7Config.h
// Management of configuration parameters for the D3D7 client.
// ==============================================================

#ifndef __D3D7CONFIG_H
#define __D3D7CONFIG_H

class D3D7Config {
public:
	D3D7Config ();
	~D3D7Config ();

	void Reset ();
	bool ReadParams ();
	void WriteParams ();

	int PlanetPreloadMode;   // 0=load on demand, 1=preload
	int PlanetLoadFrequency; // load frequency for on-demand textures [Hz]
	int PlanetMipmapMode;    // 0=none, 1=point sampling, 2=linear interpolation
	int PlanetAnisoMode;     // anisotropic filtering (>= 1, 1=none)
	double PlanetMipmapBias; // LOD bias (-1=sharp ... +1=smooth)

private:
	static int def_PlanetPreloadMode;
	static int def_PlanetLoadFrequency;
	static int def_PlanetAnisoMode;
	static int def_PlanetMipmapMode;
	static double def_PlanetMipmapBias;
};

#endif // !__D3D7CONFIG_H
