#include "D3D7Config.h"
#include "orbitersdk.h"

static char *cfgfile = "D3D7Client.cfg";

// ==============================================================
// default values

int D3D7Config::def_PlanetPreloadMode = 0;     // don't preload hires tiles
int D3D7Config::def_PlanetLoadFrequency = 20;  // On-demand texture load frequency [Hz]
int D3D7Config::def_PlanetMipmapMode = 2;      // interpolated mipmaps
int D3D7Config::def_PlanetAnisoMode = 1;       // no anisotropic filtering
double D3D7Config::def_PlanetMipmapBias = 0.0; // Mipmap LOD bias (no bias)

// ==============================================================

D3D7Config::D3D7Config ()
{
	Reset ();
	ReadParams ();
}

D3D7Config::~D3D7Config ()
{
	WriteParams ();
}

void D3D7Config::Reset ()
{
	PlanetPreloadMode   = def_PlanetPreloadMode;
	PlanetLoadFrequency = def_PlanetLoadFrequency;
	PlanetMipmapMode    = def_PlanetMipmapMode;
	PlanetAnisoMode     = def_PlanetAnisoMode;
	PlanetMipmapBias    = def_PlanetMipmapBias;
}

bool D3D7Config::ReadParams ()
{
	int i;
	double d;

	FILEHANDLE hFile = oapiOpenFile (cfgfile, FILE_IN, ROOT);
	if (!hFile) return false;
	if (oapiReadItem_int (hFile, "PlanetPreloadMode", i))
		PlanetPreloadMode = max (0, min (1, i));
	if (oapiReadItem_int (hFile, "PlanetTexLoadFreq", i))
		PlanetLoadFrequency = max (1, min (1000, i));
	if (oapiReadItem_int (hFile, "PlanetMipmapMode", i))
		PlanetMipmapMode = max (0, min (2, i));
	if (oapiReadItem_int (hFile, "PlanetAnisoMode", i))
		PlanetAnisoMode = max (1, min (16, i));
	if (oapiReadItem_float (hFile, "PlanetMipmapBias", d))
		PlanetMipmapBias = max (-1.0, min (1.0, d));
	oapiCloseFile (hFile, FILE_IN);
	return true;
}

void D3D7Config::WriteParams ()
{
	FILEHANDLE hFile = oapiOpenFile (cfgfile, FILE_OUT, ROOT);
	oapiWriteItem_int (hFile, "PlanetPreloadMode", PlanetPreloadMode);
	oapiWriteItem_int (hFile, "PlanetTexLoadFreq", PlanetLoadFrequency);
	oapiWriteItem_int (hFile, "PlanetAnisoMode", PlanetAnisoMode);
	oapiWriteItem_int (hFile, "PlanetMipmapMode", PlanetMipmapMode);
	oapiWriteItem_float (hFile, "PlanetMipmapBias", PlanetMipmapBias);
	oapiCloseFile (hFile, FILE_OUT);
}