// ==============================================================
// VBase.h
// Part of the ORBITER VISUALISATION PROJECT (OVP)
// Released under GNU General Public License
// Copyright (C) 2007 Martin Schweiger
// ==============================================================

// ==============================================================
// class vBase (interface)
//
// A vBase is the visual representation of a surface base
// object (a "spaceport" on the surface of a planet or moon,
// usually with runways or landing pads where vessels can
// land and take off.
// ==============================================================

#ifndef __VBASE_H
#define __VBASE_H

#include "VObject.h"
#include "Mesh.h"

class vBase: public vObject {
	friend class vPlanet;

public:
	vBase (OBJHANDLE _hObj, const Scene *scene);
	~vBase();

	bool Update ();
	bool RenderSurface (LPDIRECT3DDEVICE9 dev);
	bool RenderStructures (LPDIRECT3DDEVICE9 dev);
	void RenderGroundShadow (LPDIRECT3DDEVICE9 dev);


private:
	void SetupShadowMeshes ();

	double Tchk;               // next update
	DWORD ntile;               // number of surface tiles
	const SurftileSpec *tspec; // list of tile specs
	struct SurfTile {
		D3D9Mesh *mesh;
	} *tile;
	D3D9Mesh **structure_bs;
	D3D9Mesh **structure_as;
	DWORD nstructure_bs, nstructure_as;
	bool lights;               // use nighttextures for base objects

	struct ShadowMesh {
		LPDIRECT3DVERTEXBUFFER9 vbuf;
		LPDIRECT3DINDEXBUFFER9 idx;
		DWORD nvtx, nidx;
		double ecorr;
	} *shmesh;
	DWORD nshmesh;
};

#endif // !__VBASE_H