// ==============================================================
//   ORBITER VISUALISATION PROJECT (OVP)
//   D3D7 Client module
//   Copyright (C) 2006-2014 Martin Schweiger
//   Dual licensed under GPL v3 and LGPL v3
// ==============================================================

// ==============================================================
// Texture.h
// Texture loading and management routines for the D3D7 client.
//
// Methods for loading single (.dds) and multi-texture files (.tex)
// stored in DXT? format into DIRECTDRAWSURFACE7 instances.
// ==============================================================

#ifndef __TEXTURE_H
#define __TEXTURE_H

#include "D3D7Client.h"
#include <stdio.h>

// ==============================================================
// Class TextureManager

class TextureManager {
public:
	TextureManager (oapi::D3D7Client *gclient);
	~TextureManager ();

	HRESULT LoadTexture (const char *fname, LPDIRECTDRAWSURFACE7 *ppdds, DWORD flags);
	// Read a texture from file 'fname' into the DX7 surface
	// pointed to by 'ppdds'.
	// flags: passed on to ReadTexture

	HRESULT LoadTexture (const char *fname, long ofs, LPDIRECTDRAWSURFACE7 *ppdds, DWORD flags = 0);
	// Read a single texture from a multi-texture file at offset ofs
	// Return number of loaded textures (1, or 0 on failure)
	// flags: passed on to ReadTexture

	int LoadTextures (const char *fname, LPDIRECTDRAWSURFACE7 *ppdds, DWORD flags, int n);
	// Read up to n textures from file 'fname' into the DX7 surface array.
	// Return value is the number of actually loaded textures (<=n)

	HRESULT ReadTexture (FILE *file, LPDIRECTDRAWSURFACE7 *ppdds, DWORD flags);
	// Read a single texture from open file stream 'file' into the
	// the DX7 surface pointed to by 'ppdds'.

	bool GetTexture (const char *fname, LPDIRECTDRAWSURFACE7 *ppdds, DWORD flags);
	// Retrieve a texture. First scans the repository of loaded textures.
	// If not found, loads the texture from file and adds it to the repository

protected:
	HRESULT LookupPixelFormat (DDPIXELFORMAT ddsdDDSTexture,
		DDPIXELFORMAT *pddsdBestMatch);
	// given a texture pixel format 'ddsdDDSTexture', return
	// the best match compatible with the current device in
	// 'pddsdBestMatch'. This is faster than the previous
	// routine because it checks for previously registered
	// matches.

	HRESULT FindBestPixelFormatMatch (DDPIXELFORMAT ddsdDDSTexture,
		DDPIXELFORMAT *pddsdBestMatch);
	// given a texture pixel format 'ddsdDDSTexture', return
	// the best match compatible with the current device in
	// 'pddsdBestMatch'

	HRESULT ReadDDSSurface (FILE *file,
		DDSURFACEDESC2 *pddsd, LPDIRECTDRAWSURFACE7 *ppddsDXT, DWORD flags = 0);
	// Read a compressed DDS surface from an open stream
	// pddsdComp    : DDS surface description
	// pppddsCompTop: DDS surface
	// flags: bit 0 set: force creation in system memory
	//        bit 1 set: decompress, even if format is supported by device
	//        bit 2 set: don't load mipmaps, even if supported by device

	HRESULT BltToUncompressedSurface (DDSURFACEDESC2 ddsd, 
		DDPIXELFORMAT ddpf, LPDIRECTDRAWSURFACE7 pddsDXT, 
	    LPDIRECTDRAWSURFACE7* ppddsNewSurface);
	// Creates an uncompressed surface and copies the DXT
	// surface into it

	DWORD MakeTexId (const char *fname);
	// simple checksum of a string. Used for speeding up texture searches.

private:
	oapi::D3D7Client *gc;
	LPDIRECTDRAW7 pDD;
	LPDIRECT3DDEVICE7 pDev;
	DWORD devMemType;
	bool bMipmap;

	struct PixelFormatPair {
		DDPIXELFORMAT pixelfmt;
		DDPIXELFORMAT bestmatch;
	} *pfp;        // list of pixel formats and best matches
	int npfp;      // number of valid entries in pfp

	// simple repository of loaded textures: linked list
	struct TexRec {
		LPDIRECTDRAWSURFACE7 tex;
		char fname[64];
		DWORD id;
		struct TexRec *next;
	} *firstTex;

	// Some repository management functions below.
	// This could be made more sophisticated (defining a maximum size of
	// the repository, deallocating unused textures as required, etc.)
	// Would also require a reference counter and a size parameter in the
	// TexRec structure.

	TexRec *ScanRepository (const char *fname);
	// Return a matching texture entry from the repository, if found.
	// Otherwise, return NULL.

	void AddToRepository (const char *fname, LPDIRECTDRAWSURFACE7 pdds);
	// Add a new entry to the repository

	void ClearRepository ();
	// De-allocates the repository and release the DX7 textures
};

// ==============================================================
// Non-member utility functions

#endif // !__TEXTURE_H