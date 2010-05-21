// ==============================================================
// MeshMgr.h
// Part of the ORBITER VISUALISATION PROJECT (OVP)
// Released under GNU General Public License
// Copyright (C) 2007 Martin Schweiger
// ==============================================================

#ifndef __MESHMGR_H
#define __MESHMGR_H

#include "D3D9Client.h"
#include "Mesh.h"

// ==============================================================
// class MeshManager (interface)
// ==============================================================
/**
 * \brief Simple management of persistent mesh templates
 */

class MeshManager {
public:
	MeshManager (const oapi::D3D9Client *gclient);
	~MeshManager();
	void Flush();
	void StoreMesh (MESHHANDLE hMesh);
	const D3D9Mesh *GetMesh (MESHHANDLE hMesh);

private:
	const oapi::D3D9Client *gc;
	struct MeshBuffer {
		MESHHANDLE hMesh;
		D3D9Mesh *mesh;
	} *mlist;
	int nmlist, nmlistbuf;
};

#endif // !__MESHMGR_H