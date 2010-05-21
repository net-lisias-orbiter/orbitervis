// ==============================================================
// Texture.cpp
// Part of the ORBITER VISUALISATION PROJECT (OVP)
// Released under GNU General Public License
// Copyright (C) 2006 Martin Schweiger
// ==============================================================

// ==============================================================
// Texture loading and management routines for the D3D7 client.
//
// Methods for loading single (.dds) and multi-texture files (.tex)
// stored in DXT? format into DIRECTDRAWSURFACE7 instances.
// ==============================================================

// DX9 port:
// The loading of textures has been completely rewritten. DX9 offers
// functions to do the loading for you. Unfortunately, the orbiter .tex
// format is a bit awkward to use, since it is a concatenation of .dds
// files and DX9 functions have no way of reporting how much bytes were
// actually processed in a texture loading, nor can they work with an
// open file handle. We have to figure out the boundaries between the 
// .dds files ourselves. This code works by opening the file in memory
// and examining the dds headers and calculating the .dds size, feeding
// each .dds block to D3DXCreateTextureFromFileInMemoryEx(). Seems to work
// ok for now.

#include "Texture.h"
#include <ddraw.h>

using namespace oapi;

// ==============================================================
// Local prototypes

WORD GetNumberOfBits (DWORD dwMask);

// ==============================================================
// ==============================================================
// Class TextureManager
// ==============================================================
// ==============================================================

TextureManager::TextureManager (D3D9Client *gclient)
{
	gc         = gclient;
	pDev       = gclient->GetDevice();
//	devMemType = gclient->GetFramework()->GetDeviceMemType();
//	bMipmap    = (gclient->GetFramework()->SupportsMipmaps() ? true:false);
	firstTex   = NULL;
}

// ==============================================================

TextureManager::~TextureManager ()
{
	ClearRepository();
}


HRESULT TextureManager::LoadTexture (const char *fname, LPDIRECT3DTEXTURE9 *ppdds)
{
	HRESULT hr = S_OK;
	char cpath[256];
	*ppdds = NULL;
	if (gc->TexturePath (fname, cpath)) {
			return D3DXCreateTextureFromFile(pDev, cpath, ppdds);
	}
	return hr;
}

int TextureManager::LoadTextures (const char *fname, LPDIRECT3DTEXTURE9 *ppdds, int amount)
{
	HRESULT hr = S_OK;
	char cpath[256];
	int ntex = 0;
	if (gc->TexturePath (fname, cpath)) {
			FILE *f = fopen(cpath, "rb");
			if (f) {
				char *buffer, *location;
				fseek(f, 0, SEEK_END);
				long size = ftell(f);
				long BytesLeft = size;
				buffer = new char[size];
				rewind(f);
				fread(buffer, 1, size, f);
				fclose(f);

				location = buffer;
				while (ntex < amount && BytesLeft > 0)
				{
					DWORD Magic = *(DWORD*)location;
					if (Magic != MAKEFOURCC('D','D','S',' '))
						break;
					
					DDSURFACEDESC2 *header = (DDSURFACEDESC2*)(location + sizeof(Magic));
					long bytes = (header->dwFlags & DDSD_LINEARSIZE) ? header->dwLinearSize : (header->dwHeight * header->dwWidth * header->ddpfPixelFormat.dwRGBBitCount/8);
					bytes += sizeof(Magic) + sizeof(DDSURFACEDESC2);

					D3DXIMAGE_INFO Info;
					D3DXCreateTextureFromFileInMemoryEx(pDev, location, bytes, 0, 0, 0, 0, D3DFMT_UNKNOWN, 
						D3DPOOL_DEFAULT,D3DX_DEFAULT, D3DX_DEFAULT,0, &Info, NULL, ppdds + ntex);

					location += bytes;
					BytesLeft -= bytes;
					ntex++;
				}
				delete buffer;
			}
	}
	return ntex;
}

// =======================================================================
// Retrieve a texture. First scans the repository of loaded textures.
// If not found, loads the texture from file and adds it to the repository

bool TextureManager::GetTexture (const char *fname, LPDIRECT3DTEXTURE9 *pd3dt)
{
	TexRec *texrec = ScanRepository (fname);
	if (texrec) {
		// found in repository
		*pd3dt = texrec->tex;
		texrec->tex->AddRef();
		return true;
	} else if (SUCCEEDED (LoadTexture (fname, pd3dt))) {
		// loaded from file
		AddToRepository (fname, *pd3dt);
		return true;
	} else {
		// not found
		return false;
	}
}

// =======================================================================
// Return a matching texture entry from the repository, if found.
// Otherwise, return NULL.

TextureManager::TexRec *TextureManager::ScanRepository (const char *fname)
{
	TexRec *texrec;
	DWORD id = MakeTexId (fname);
	for (texrec = firstTex; texrec; texrec = texrec->next) {
		if (id == texrec->id && !strncmp (fname, texrec->fname, 64))
			return texrec;
	}
	return NULL;
}

// =======================================================================
// Add a new entry to the repository

void TextureManager::AddToRepository (const char *fname, LPDIRECT3DTEXTURE9 pdds)
{
	TexRec *texrec = new TexRec;
	texrec->tex = pdds;
	texrec->tex->AddRef();
	strncpy (texrec->fname, fname, 64);
	texrec->id = MakeTexId (fname);
	texrec->next = firstTex; // add to beginning of list
	firstTex = texrec;
}

// =======================================================================
// De-allocates the repository and release the DX7 textures

void TextureManager::ClearRepository ()
{
	while (firstTex) {
		TexRec *tmp = firstTex;
		firstTex = firstTex->next;
		if (tmp->tex) tmp->tex->Release();
		delete tmp;
	}
}

// =======================================================================

DWORD TextureManager::MakeTexId (const char *fname)
{
	DWORD id = 0;
	for (const char *c = fname; *c; c++)
		id += *c;
	return id;
}
