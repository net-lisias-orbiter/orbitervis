// ==============================================================
// TileMgr.h
// Part of the ORBITER VISUALISATION PROJECT (OVP)
// Released under GNU General Public License
// Copyright (C) 2006-2007 Martin Schweiger
// ==============================================================

// ==============================================================
// class TileManager (interface)
//
// Planetary surface rendering management, including a simple
// LOD (level-of-detail) algorithm for surface patch resolution.
// ==============================================================

#ifndef __TILEMGR_H
#define __TILEMGR_H

#include "D3D9Util.h"
#include "Mesh.h"

struct VBMESH {
	LPDIRECT3DVERTEXBUFFER9 vb; // mesh vertex buffer
	D3DXVECTOR3	*bb;			// bounding box vertex buffer
	VERTEX_2TEX *vtx;           // separate storage of vertices (NULL if not available)
	DWORD nv;                   // number of vertices
	LPDIRECT3DINDEXBUFFER9 idx; // list of indices
	DWORD ni;                   // number of indices
};

#pragma pack(push,1)
	struct TILEFILESPEC {
		DWORD sidx;       // index for surface texture (-1: not present)
		DWORD midx;       // index for land-water mask texture (-1: not present)
		DWORD eidx;       // index for elevation data blocks (not used yet; always -1)
		DWORD flags;      // tile flags: bit 0: has diffuse component; bit 1: has specular component; bit 2: has city lights
		DWORD subidx[4];  // subtile indices
	};

struct LMASKFILEHEADER { // file header for contents file at level 1-8
	char id[8];          //    ID+version string
	DWORD hsize;         //    header size
	DWORD flag;          //    bitflag content information
	DWORD npatch;        //    number of patches
	BYTE minres;         //    min. resolution level
	BYTE maxres;         //    max. resolution level
};
#pragma pack(pop)

struct TILEDESC {
	LPDIRECT3DVERTEXBUFFER9 vtx;
	LPDIRECT3DTEXTURE9 tex;      // diffuse surface texture
	LPDIRECT3DTEXTURE9 ltex;     // landmask texture, if applicable
	DWORD flag;
	struct TILEDESC *subtile[4];   // sub-tiles for the next resolution level
	DWORD ofs;                     // refers back to the master list entry for the tile
};

typedef struct {
	float tumin, tumax;
	float tvmin, tvmax;
} TEXCRDRANGE;

class vPlanet;

class TileManager {
	friend class TileBuffer;

public:
	TileManager (const oapi::D3D9Client *gclient, const vPlanet *vplanet);
	virtual ~TileManager ();

	static void GlobalInit (oapi::D3D9Client *gclient);
	static void GlobalExit ();
	// One-time global initialisation/exit methods

	virtual void SetMicrotexture (const char *fname);
	virtual void SetMicrolevel (double lvl);

	virtual void Render (LPDIRECT3DDEVICE9 dev, D3DMATRIX &wmat, int level, double viewap = 0.0);

	static void CreateSphere (LPDIRECT3D9 d3d, LPDIRECT3DDEVICE9 dev, VBMESH &mesh, DWORD nrings, bool hemisphere, int which_half, int texres);
	static void CreateSpherePatch (LPDIRECT3D9 d3d, LPDIRECT3DDEVICE9 dev, VBMESH &mesh, int nlng, int nlat, int ilat, int res, int bseg = -1, bool reduce = true, bool outside = true, bool store_vtx = false);
	static void DestroyVBMesh (VBMESH &mesh);

protected:
	void RenderSimple (int level, TILEDESC *tile);

	void ProcessTile (int lvl, int hemisp, int ilat, int nlat, int ilng, int nlng,
		TILEDESC *tile, const TEXCRDRANGE &range, LPDIRECT3DTEXTURE9 tex, LPDIRECT3DTEXTURE9 ltex, DWORD flag);

	virtual void RenderTile (int lvl, int hemisp, int ilat, int nlat, int ilng, int nlng, double sdist,
		TILEDESC *tile, const TEXCRDRANGE &range, LPDIRECT3DTEXTURE9 tex, LPDIRECT3DTEXTURE9 ltex, DWORD flag) = 0;

	bool LoadPatchData ();
	// load binary definition file for LOD levels 1-8

	bool LoadTileData ();
	// load binary definition file for LOD levels > 8

	bool AddSubtileData (TILEDESC &td, TILEFILESPEC *tfs, DWORD idx, DWORD sub, DWORD lvl);
	// add a high-resolution subtile specification to the tree

	void LoadTextures (char *modstr = 0);
	// load patch textures for all LOD levels

	void AddSubtileTextures (TILEDESC *td);
	// add a high-resolution subtile texture to the tree

	void LoadSpecularMasks ();
	// load specular and night light textures

	void AddSubtileMasks (TILEDESC *td);
	// add specular masks for the subtiles of td

	VECTOR3 TileCentre (int hemisp, int ilat, int nlat, int ilng, int nlng);
	// direction to tile centre from planet centre in planet frame

	bool TileInView (int lvl, int ilat);
	// checks if a given tile is observable from camera position

	void SetWorldMatrix (int ilng, int nlng);
	// set the world transformation for a particular tile

	bool SpecularColour (D3DCOLORVALUE *col);
	// adjust specular reflection through atmosphere

	const oapi::D3D9Client *gc;      // the client
	const vPlanet *vp;               // the planet visual
	OBJHANDLE obj;                   // the planet object

	int maxlvl;                      // max LOD level
	int maxbaselvl;                  // max LOD level, capped at 8
	DWORD ntex;                      // total number of loaded textures for levels <= 8
	DWORD nhitex;                    // number of textures for levels > 8
	DWORD nhispec;                   // number of specular reflection masks (level > 8)
	double hipatchrad;               // angular aperture fraction at which to downgrade patch resolution
	double lightfac;                 // city light intensity factor
	double microlvl;                 // intensity of microtexture
	DWORD nmask;                     // number of specular reflection masks/light maps (level <= 8)
	VECTOR3 pcdir;                   // previous camera direction
	static D3DMATRIX Rsouth;         // rotation matrix for mapping tiles to southern hemisphere
	float spec_base;                 // base intensity for specular reflections
	const ATMCONST *atmc;            // atmospheric parameters (used for specular colour modification)

	TILEDESC *tiledesc;              // tile descriptors for levels 1-8
	static TileBuffer *tilebuf;      // subtile manager

	LPDIRECT3DTEXTURE9 *texbuf;    // texture buffer for surface textures (level <= 8)
	LPDIRECT3DTEXTURE9 *hitexbuf;  // texture buffer for surface textures (level > 8)
	LPDIRECT3DTEXTURE9 *specbuf;   // texture buffer for specular masks (level <= 8);
	LPDIRECT3DTEXTURE9 *hispecbuf; // texture buffer for specular masks (level > 8)
	LPDIRECT3DTEXTURE9 microtex;   // microtexture overlay

	// object-independent configuration data
	static bool bGlobalSpecular;     // user wants specular reflections
	static bool bGlobalRipple;       // user wants specular microtextures
	static bool bGlobalLights;       // user wants planet city lights

	// tile patch templates
	static VBMESH PATCH_TPL_1;
	static VBMESH PATCH_TPL_2;
	static VBMESH PATCH_TPL_3;
	static VBMESH PATCH_TPL_4[2];
	static VBMESH PATCH_TPL_5;
	static VBMESH PATCH_TPL_6[2];
	static VBMESH PATCH_TPL_7[4];
	static VBMESH PATCH_TPL_8[8];
	static VBMESH PATCH_TPL_9[16];
	static VBMESH PATCH_TPL_10[32];
	static VBMESH *PATCH_TPL[11];
	static int patchidx[9];          // texture offsets for different LOD levels
	static int NLAT[9];
	static int NLNG5[1], NLNG6[2], NLNG7[4], NLNG8[8], *NLNG[9];
	static DWORD vpX0, vpX1, vpY0, vpY1; // viewport boundaries

	struct RENDERPARAM {
		LPDIRECT3DDEVICE9 dev;       // render device
		D3DMATRIX wmat;              // world matrix
		int tgtlvl;                  // target resolution level
		VECTOR3 sdir;                // sun direction from planet centre (in planet frame)
		VECTOR3 cdir;                // camera direction from planet centre (in planet frame)
		double cdist;                // camera distance from planet centre (in units of planet radii)
		double viewap;               // aperture of surface cap visible from camera pos
	} RenderParam;

	friend void ApplyPatchTextureCoordinates (VBMESH &mesh, LPDIRECT3DVERTEXBUFFER9 vtx, const TEXCRDRANGE &range);
};


// =======================================================================
// Class TileBuffer: Global resource; holds a collection of
// tile specifications across all planets

class TileBuffer {
public:
	TileBuffer ();
	~TileBuffer ();
	TILEDESC *AddTile ();
	void DeleteSubTiles (TILEDESC *tile);

private:
	bool DeleteTile (TILEDESC *tile);

	DWORD nbuf;     // buffer size;
	DWORD nused;    // number of active entries
	DWORD last;     // index of last activated entry
	TILEDESC **buf; // tile buffer
};

#endif // !__TILEMGR_H