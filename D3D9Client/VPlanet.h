// ==============================================================
// VPlanet.h
// Part of the ORBITER VISUALISATION PROJECT (OVP)
// Released under GNU General Public License
// Copyright (C) 2006-2007 Martin Schweiger
// ==============================================================

// ==============================================================
// class vPlanet (interface)
//
// A vPlanet is the visual representation of a "planetary" object
// (planet, moon, asteroid).
// Currently this only supports spherical objects, without
// variations in elevation.
// ==============================================================

#ifndef __VPLANET_H
#define __VPLANET_H

#include "VObject.h"

class vPlanet: public vObject {
	friend class TileManager;
	friend class SurfaceManager;
	friend class CloudManager;
	friend class HazeManager;
	friend class RingManager;
	friend class vBase;

public:
	vPlanet (OBJHANDLE _hObj, const Scene *scene);
	~vPlanet ();

	bool Update ();
	void CheckResolution ();
	void RenderZRange (double *nplane, double *fplane);
	bool Render (LPDIRECT3DDEVICE9 dev);

protected:
	void RenderDot (LPDIRECT3DDEVICE9 dev);
	void RenderSphere (LPDIRECT3DDEVICE9 dev);
	void RenderCloudLayer (LPDIRECT3DDEVICE9 dev, DWORD cullmode);
	void RenderBaseSurfaces (LPDIRECT3DDEVICE9 dev);
	void RenderBaseStructures (LPDIRECT3DDEVICE9 dev);
	void RenderBaseShadows (LPDIRECT3DDEVICE9 dev, float depth);
	void RenderCloudShadows (LPDIRECT3DDEVICE9 dev);

private:
	float rad;                // planet radius [m]
	float render_rad;         // distance to be rendered past planet centre
	float dist_scale;         // planet rescaling factor
	float shadowalpha;        // alpha value for surface shadows
	double cloudrad;          // cloud layer radius [m]
	int patchres;             // surface LOD level
	bool hashaze;             // render atmospheric haze
	DWORD nbase;              // number of surface bases
	vBase **vbase;            // list of base visuals
	SurfaceManager *surfmgr;  // planet surface tile manager
	HazeManager *hazemgr;     // horizon haze rendering
	RingManager *ringmgr;   // ring manager
	bool bRipple;             // render specular ripples on water surfaces
	bool bVesselShadow;       // render vessel shadows on surface

	struct CloudData {        // cloud render parameters
		CloudManager *cloudmgr; // cloud tile manager
		double cloudrad;        // cloud layer radius [m]
		double viewap;          // visible radius
		D3DMATRIX mWorldC;      // cloud world matrix
		D3DMATRIX mWorldC0;     // cloud shadow world matrix
		DWORD rendermode;		// bit 0: render from below, bit 1: render from above
		bool cloudshadow;       // render cloud shadows on the surface
		float shadowalpha;      // alpha value for cloud shadows
		double microalt0, microalt1; // altitude limits for micro-textures
	} *clouddata;
};

#endif // !__VPLANET_H