// ==============================================================
// VStar.h
// Part of the ORBITER VISUALISATION PROJECT (OVP)
// Released under GNU General Public License
// Copyright (C) 2006-2007 Martin Schweiger
// ==============================================================

// ==============================================================
// class vStar (interface)
//
// Renders the central star as a billboard mesh.
// ==============================================================

#ifndef __VSTAR_H
#define __VSTAR_H

#include "VObject.h"

class D3D7Mesh;

class vStar: public vObject {
public:
	vStar (OBJHANDLE _hObj, const Scene *scene);
	~vStar ();

	static void GlobalInit (oapi::D3D7Client *gc);
	static void GlobalExit ();

	bool Update ();
	bool Render (LPDIRECT3DDEVICE7 dev);

private:
	double size;       ///< physical size of central body
	double maxdist;    ///< max render distance
	D3DMATERIAL7 mtrl; ///< Material definition for rendering

	static D3D7Mesh *billboard;         ///< visual
	static LPDIRECTDRAWSURFACE7 deftex; ///< default texture
};

#endif // !__VSTAR_H