// ==============================================================
// Mesh.h
// Part of the ORBITER VISUALISATION PROJECT (OVP)
// Released under GNU General Public License
// Copyright (C) 2006 Martin Schweiger
// ==============================================================

// ==============================================================
// class D3D9Mesh (interface)
//
// This class represents a mesh in terms of DX7 interface elements
// (vertex buffers, index lists, materials, textures) which allow
// it to be rendered to the D3D7 device.
// ==============================================================

#ifndef __MESH_H
#define __MESH_H

#include "D3D9Client.h"

#include <d3d9.h>
#include <d3dx9.h>
#include "D3D9Util.h"

const DWORD SPEC_DEFAULT = (DWORD)(-1); // "default" material/texture flag
const DWORD SPEC_INHERIT = (DWORD)(-2); // "inherit" material/texture flag

/**
 * \brief Mesh object with D3D9-specific vertex buffer
 *
 * Meshes consist of one or more vertex groups, and a set of materials and
 * textures.
 */
class D3D9Mesh {
public:
	struct GROUPREC {  // mesh group definition
		DWORD nVtx;      // number of vertices
		DWORD nIdx;      // number of indices
		LPDIRECT3DVERTEXBUFFER9 VtxBuf; // vertex buffer
		LPDIRECT3DINDEXBUFFER9 Idx;       // vertex index list
		DWORD MtrlIdx;   // material index
		DWORD TexIdx;    // texture index
		DWORD UsrFlag;   // user-defined flag
		WORD IntFlag;    // internal flags
		DWORD TexIdxEx[MAXTEX];
		float TexMixEx[MAXTEX];
	};

	/**
	 * \brief Create an empty mesh
	 * \param client graphics client
	 */
	D3D9Mesh (const oapi::D3D9Client *client);

	/**
	 * \brief Create a mesh consisting of a single mesh group
	 * \param client graphics client
	 * \param grp vertex group definition
	 * \param deepcopy if true, group contents are copied; otherwise, group
	 *   definition pointer is used directly
	 */
	D3D9Mesh (const oapi::D3D9Client *client, GROUPREC *grp, bool deepcopy=true);
	D3D9Mesh (const oapi::D3D9Client *client, MESHHANDLE hMesh, bool asTemplate = false);
	D3D9Mesh (const D3D9Mesh &mesh); // copy constructor
	~D3D9Mesh ();


	/**
	 * \brief Add a new vertex group to the mesh
	 * \param grp group definition
	 * \param deepcopy data copy flag (see notes)
	 * \return group index of the added group (>= 0)
	 * \note If deepcopy=true (default), the contents of the group definition
	 *   are copied into the mesh instance. deepcopy=false indicates that
	 *   the group definition was dynamically allocated, and that the pointer can
	 *   be used directly by the mesh. The calling function must not deallocate
	 *   the group after the call.
	 */
	DWORD AddGroup (GROUPREC *grp, bool deepcopy = true);

	/**
	 * \brief Returns number of vertex groups
	 * \return Number of groups
	 */
	inline DWORD GroupCount() const { return nGrp; }

	inline GROUPREC *GetGroup (DWORD idx) { return Grp[idx]; }
	void SetTexMixture (DWORD ntex, float mix);
	void RenderGroup (LPDIRECT3DDEVICE9 dev, GROUPREC *grp);
	void Render (LPDIRECT3DDEVICE9 dev);

	void TransformGroup (DWORD n, const D3DMATRIX *m);

protected:
	bool CopyGroup (GROUPREC *tgt, const GROUPREC *src);
	bool CopyGroup (GROUPREC *grp, const MESHGROUPEX *mg);
	void DeleteGroup (GROUPREC *grp);
	void ClearGroups ();
	bool CopyMaterial (D3DMATERIAL9 *mat7, MATERIAL *mat);

private:
	const oapi::D3D9Client *gc; // the graphics client instance
	GROUPREC **Grp;             // list of mesh groups
	DWORD nGrp;                 // number of mesh groups
	LPDIRECT3DTEXTURE9 *Tex;    // list of mesh textures
	DWORD nTex;                 // number of mesh textures
	D3DMATERIAL9 *Mtrl;         // list of mesh materials
	DWORD nMtrl;                // number of mesh materials
	bool bTemplate;             // mesh used as template only (not for rendering)
	bool bVideoMem;             // create vertex buffers in video memory
	                            // (can be overwritten by individual mesh groups)
};

#endif // !__MESH_H