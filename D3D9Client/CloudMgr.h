// ==============================================================
// CloudMgr.h
// Part of the ORBITER VISUALISATION PROJECT (OVP)
// Released under GNU General Public License
// Copyright (C) 2007 Martin Schweiger
// ==============================================================

// ==============================================================
// class CloudManager (interface)
//
// Planetary rendering management for cloud layers, including a simple
// LOD (level-of-detail) algorithm for patch resolution.
// ==============================================================

#ifndef __CLOUDMGR_H
#define __CLOUDMGR_H

#include "TileMgr.h"

class CloudManager: public TileManager {
public:
	CloudManager (const oapi::D3D9Client *gclient, const vPlanet *vplanet);

	void Render (LPDIRECT3DDEVICE9 dev, D3DMATRIX &wmat, int level, double viewap = 0.0);

protected:
	void RenderTile (int lvl, int hemisp, int ilat, int nlat, int ilng, int nlng, double sdist,
		TILEDESC *tile, const TEXCRDRANGE &range, LPDIRECT3DTEXTURE9 tex, LPDIRECT3DTEXTURE9 ltex, DWORD flag);

private:
	int cloudtexidx;
};

#endif // !__CLOUDMGR_H