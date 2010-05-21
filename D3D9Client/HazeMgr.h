// ==============================================================
// HazeMgr.h
// Part of the ORBITER VISUALISATION PROJECT (OVP)
// Released under GNU General Public License
// Copyright (C) 2007 Martin Schweiger
// ==============================================================

// ==============================================================
// class HazeManager (interface)
//
// Planetary atmospheric haze rendering
// Implemented as transparent overlay on planetary disc
// ==============================================================

#ifndef __HAZEMGR_H
#define __HAZEMGR_H

#include "D3D9Client.h"

#define HORIZON_NSEG 64  // number of mesh segments

class vPlanet;

class HazeManager {
public:
	HazeManager (const oapi::D3D9Client *gclient, const vPlanet *vplanet);

	static void GlobalInit (oapi::D3D9Client *gclient);

	void Render (LPDIRECT3DDEVICE9 dev, D3DMATRIX &wmat, bool dual = false);

private:
	const oapi::D3D9Client *gc;
	OBJHANDLE obj;
	const vPlanet *vp;
	VECTOR3 basecol;
	double rad;    // planet radius
	float  hralt;  // relative horizon altitude
	float  dens0;  // atmosphere density factor
	double hshift; // horizon reference shift factor
	double cloudalt; // cloud layer altitude
	float  hscale; // inner haze ring radius (in planet radii

	static WORD Idx[HORIZON_NSEG*2+2];
	static DWORD nIdx;
	static struct HVERTEX {
		float x,y,z;
		DWORD    dcol;
		float tu, tv; } Vtx[HORIZON_NSEG*2];
	static float CosP[HORIZON_NSEG], SinP[HORIZON_NSEG];
	static LPDIRECT3DTEXTURE9 horizon;
};

#endif // !__HAZEMGR_H