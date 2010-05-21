// ====================================================================================
// DD and D3D device enumeration (DX9)
// ====================================================================================

// DX9 port: Device enumeration is totally different in DX9. This has been rewritten.
// Unfortunately, there's no easy way to find the bits per pixel value in DX9, since it
// works with a D3DFORMAT enum. I've added getBPP(), but I doubt that BPP values in DX9 
// are used for anything other than displaying video mode descriptions to users.


#define STRICT

// Must include OrbiterAPI.h *first* to fix compiler warnings on VS2003+
#include "OrbiterAPI.h"
#include <stdio.h>
#include "D3D9Enum.h"
#include "D3D9Util.h"

char D3Ddevicename[256];
char g_buf[256];

// ------------------------------------------------------------------------------------
// Global data for the enumerator functions
// ------------------------------------------------------------------------------------
//static HRESULT (*g_fnAppConfirmFn)(DDCAPS*, D3DDEVICEDESC7*) = NULL;
static D3D9Enum_DeviceInfo g_pDeviceList[20];
static DWORD g_dwNumDevicesEnumerated = 0L;
static DWORD g_dwNumDevices           = 0L;

//-------------------------------------------------------------------------------------
// Name: SortModesCallback()
// Desc: Callback function for sorting display modes.
//-------------------------------------------------------------------------------------
int SortModesCallback (const VOID* arg1, const VOID* arg2)
{
    D3DDISPLAYMODE* p1 = (D3DDISPLAYMODE*)arg1;
    D3DDISPLAYMODE* p2 = (D3DDISPLAYMODE*)arg2;

    if (p1->Width < p2->Width)
        return -1;
    if (p1->Width > p2->Width)
        return +1;

    if (p1->Height < p2->Height)
        return -1;
    if (p1->Height > p2->Height)
        return +1;

	if (getBPP(p1->Format) < getBPP(p2->Format))
        return -1;
	if (getBPP(p1->Format) > getBPP(p2->Format))
        return +1;

    return 0;
}

//-------------------------------------------------------------------------------------
// Name: ModeEnumCallback()
// Desc: Callback function for enumerating display modes.
//-------------------------------------------------------------------------------------
/*
static HRESULT WINAPI ModeEnumCallback (DDSURFACEDESC2* pddsd, VOID* pParentInfo)
{
    D3D9Enum_DeviceInfo* pDevice = (D3D9Enum_DeviceInfo*)pParentInfo;

	// Check valid mode
	if (pddsd->dwWidth < 640) return DDENUMRET_OK;
	if (pddsd->ddpfPixelFormat.dwRGBBitCount < 16) return DDENUMRET_OK;

    // Reallocate storage for the modes
    DDSURFACEDESC2* pddsdNewModes = new DDSURFACEDESC2[pDevice->dwNumModes+1];
    memcpy (pddsdNewModes, pDevice->pddsdModes, pDevice->dwNumModes * sizeof(DDSURFACEDESC2));
    delete pDevice->pddsdModes;
    pDevice->pddsdModes = pddsdNewModes;

    // Add the new mode
    pDevice->pddsdModes[pDevice->dwNumModes++] = (*pddsd);

    return DDENUMRET_OK;
}

//-------------------------------------------------------------------------------------
// Name: DeviceEnumCallback()
// Desc: Callback function for enumerating devices
//-------------------------------------------------------------------------------------
static HRESULT WINAPI DeviceEnumCallback (TCHAR* strDesc, TCHAR* strName,
                                          D3DDEVICEDESC7* pDesc, VOID* pParentInfo)
{
	HRESULT hr;

    // Keep track of # of devices that were enumerated
    g_dwNumDevicesEnumerated++;

    D3D9Enum_DeviceInfo* pDriverInfo = (D3D9Enum_DeviceInfo*)pParentInfo;
    D3D9Enum_DeviceInfo* pDeviceInfo = &g_pDeviceList[g_dwNumDevices];
    ZeroMemory (pDeviceInfo, sizeof(D3D9Enum_DeviceInfo));

    // Select either the HAL or the HEL device desc:
    pDeviceInfo->bHardware = pDesc->dwDevCaps & D3DDEVCAPS_HWRASTERIZATION;
    memcpy (&pDeviceInfo->ddDeviceDesc, pDesc, sizeof(D3DDEVICEDESC7));

    // Set up device info for this device
    pDeviceInfo->bDesktopCompatible = pDriverInfo->bDesktopCompatible;
    pDeviceInfo->ddDriverCaps       = pDriverInfo->ddDriverCaps;
    pDeviceInfo->ddHELCaps          = pDriverInfo->ddHELCaps;
    pDeviceInfo->guidDevice         = pDesc->deviceGUID;
    pDeviceInfo->pDeviceGUID        = &pDeviceInfo->guidDevice;
    pDeviceInfo->pddsdModes         = new DDSURFACEDESC2[pDriverInfo->dwNumModes];

    // Copy the driver GUID and description for the device
    if (pDriverInfo->pDriverGUID) {
        pDeviceInfo->guidDriver  = pDriverInfo->guidDriver;
        pDeviceInfo->pDriverGUID = &pDeviceInfo->guidDriver;
		char cbuf[256];
		sprintf (cbuf, "%s (%s)", strName, pDriverInfo->strDesc);
        lstrcpyn (pDeviceInfo->strDesc, cbuf, 79);
    } else {
        pDeviceInfo->pDriverGUID = NULL;
        lstrcpyn (pDeviceInfo->strDesc, strName, 79);
    }

    // Avoid duplicates: only enum HW devices for secondary DDraw drivers.
    if (NULL != pDeviceInfo->pDriverGUID && FALSE == pDeviceInfo->bHardware)
		return D3DENUMRET_OK;

    // Give the app a chance to accept or reject this device.
    if (g_fnAppConfirmFn) {
		hr = g_fnAppConfirmFn (&pDeviceInfo->ddDriverCaps, &pDeviceInfo->ddDeviceDesc);
		if (hr < 0) { // macro FAILED doesn't work here for some strange reason!
			return D3DENUMRET_OK;
		}
	}

    // Build list of supported modes for the device
	DWORD i;    // define here for VC7 compatibility
    for (i = 0; i < pDriverInfo->dwNumModes; i++) {
        DDSURFACEDESC2 ddsdMode = pDriverInfo->pddsdModes[i];
        DWORD dwRenderDepths    = pDeviceInfo->ddDeviceDesc.dwDeviceRenderBitDepth;
        DWORD dwDepth           = ddsdMode.ddpfPixelFormat.dwRGBBitCount;

        // Accept modes that are compatable with the device
        if (((dwDepth == 32) && (dwRenderDepths & DDBD_32)) ||
            ((dwDepth == 24) && (dwRenderDepths & DDBD_24)) ||
            ((dwDepth == 16) && (dwRenderDepths & DDBD_16))) {
            // Copy compatible modes to the list of device-supported modes
            pDeviceInfo->pddsdModes[pDeviceInfo->dwNumModes++] = ddsdMode;

            // Record whether the device has any stereo modes
            if (ddsdMode.ddsCaps.dwCaps2 & DDSCAPS2_STEREOSURFACELEFT)
                pDeviceInfo->bStereoCompatible = TRUE;
        }
    }

    // Bail if the device has no supported modes
    if (0 == pDeviceInfo->dwNumModes)
        return D3DENUMRET_OK;

	// Try to find a 800x600 default mode. If not available, fall back to 640x480
    for (i = 0; i < pDeviceInfo->dwNumModes; i++) {
		DDSURFACEDESC2* mode = pDeviceInfo->pddsdModes+i;
		if (mode->ddpfPixelFormat.dwRGBBitCount < 16) continue;
		if (mode->dwWidth == 800 && mode->dwHeight == 600) {
            pDeviceInfo->ddsdFullscreenMode = *mode;
            pDeviceInfo->dwCurrentMode      = i;
			break;
		}
		if (mode->dwWidth == 640 && mode->dwHeight == 480) {
            pDeviceInfo->ddsdFullscreenMode = *mode;
            pDeviceInfo->dwCurrentMode      = i;
		}
	}

    // Select fullscreen by default
    pDeviceInfo->bWindowed = FALSE;

    // Accept the device and return
    g_dwNumDevices++;
    return D3DENUMRET_OK;
}

// ------------------------------------------------------------------------------------
// Name: DriverEnumCallback
// Desc: Callback function for enumerating drivers
// ------------------------------------------------------------------------------------
static BOOL DriverEnumCallback (LPDIRECT3D9 pD3D, D3DADAPTER_IDENTIFIER9 *Identifier, UINT adapter)
{
	D3D9Enum_DeviceInfo d3dDeviceInfo;
	HRESULT             hr;

	GUID* pGUID = Identifier->DeviceIdentifier;
	TCHAR* strDesc = Identifier->Description;
	TCHAR* strName = Identifier->DeviceName;

	// STEP 3
	// Copy data to a device information structure
	ZeroMemory (&d3dDeviceInfo, sizeof (d3dDeviceInfo));
	lstrcpyn (d3dDeviceInfo.strDesc, strDesc, 79);
	pD3D->GetDeviceCaps(adapter, D3DDEVTYPE_HAL, &d3dDeviceInfo.ddDriverCaps);

	if (pGUID) {
		d3dDeviceInfo.guidDriver = (*pGUID);
		d3dDeviceInfo.pDriverGUID = &d3dDeviceInfo.guidDriver;
	}
	strcpy (D3Ddevicename, d3dDeviceInfo.strDesc);



	UINT adapterModes = pD3D->GetAdapterModeCount(adapter)

	// Record whether the device can render into a desktop window
	if (d3dDeviceInfo.ddDriverCaps.dwCaps2 & DDCAPS2_CANRENDERWINDOWED)
		//if (NULL == d3dDeviceInfo.pDriverGUID)  // check removed 040116
			d3dDeviceInfo.bDesktopCompatible = TRUE;

	// STEP 4
	// Enumerate the fullscreen display modes
	pDD->EnumDisplayModes (0, NULL, &d3dDeviceInfo, ModeEnumCallback);


	// Sort the list of display modes
	qsort (d3dDeviceInfo.pddsdModes, d3dDeviceInfo.dwNumModes,
		sizeof (D3DDISPLAYMODE), SortModesCallback);

	// Now enumerate all the 3D devices
	pD3D->EnumDevices (DeviceEnumCallback, &d3dDeviceInfo);

	// Clean up and return
	SAFE_DELETE (d3dDeviceInfo.pddsdModes);

	return DDENUMRET_OK;
}
*/
// ------------------------------------------------------------------------------------
// Name: D3D9Enum_ReadDeviceList()
// Read device information from file
// ------------------------------------------------------------------------------------
int D3D9Enum_ReadDeviceList (CHAR *fname)
{
	int i;
	FILE *ifs = fopen (fname, "rb");
	if (!ifs) return 0;
	for (i = 0; i < 20; i++) {
		D3D9Enum_DeviceInfo *pInfo = g_pDeviceList+i;
		if (!fread (pInfo, sizeof(D3D9Enum_DeviceInfo), 1, ifs)) break;
		pInfo->pDeviceGUID = &pInfo->guidDevice;
		pInfo->pddsdModes = new D3DDISPLAYMODE[pInfo->dwNumModes];
		if (fread (pInfo->pddsdModes, sizeof(D3DDISPLAYMODE), pInfo->dwNumModes, ifs)
			< pInfo->dwNumModes) break;
	}
	g_dwNumDevices = i;
	return i;
}

// ------------------------------------------------------------------------------------
// Name: D3D9Enum_WriteDeviceList()
// Write the device information stored in the device list to a file (binary format)
// ------------------------------------------------------------------------------------
VOID D3D9Enum_WriteDeviceList (CHAR *fname)
{
	FILE *ofs = fopen (fname, "wb");
	DWORD i, n = g_dwNumDevices;
	for (i = 0; i < n; i++) {
		D3D9Enum_DeviceInfo *pInfo = g_pDeviceList+i;
		fwrite (pInfo, sizeof(D3D9Enum_DeviceInfo), 1, ofs);
		fwrite (pInfo->pddsdModes, sizeof(D3DDISPLAYMODE), pInfo->dwNumModes, ofs);
	}
}

// ------------------------------------------------------------------------------------
// Name: D3D9Enum_EnumerateDevices()
// Desc: Enumerates all drivers, devices, and modes. The callback function is called
//       for each device to confirm that the device supports the feature set the
//       application requires.
// ------------------------------------------------------------------------------------
HRESULT D3D9Enum_EnumerateDevices ()
{
	LPDIRECT3D9 g_pD3D = NULL;	
	if ((g_pD3D = Direct3DCreate9(D3D_SDK_VERSION)) == NULL)
		return E_FAIL;

	g_dwNumDevices = g_pD3D->GetAdapterCount();
	for (UINT adapter = 0; adapter < g_dwNumDevices; adapter++)
	{
		D3DADAPTER_IDENTIFIER9 Identifier;
		g_pD3D->GetAdapterIdentifier(adapter, 0, &Identifier);

		D3D9Enum_DeviceInfo &d3dDeviceInfo = g_pDeviceList[adapter];
		ZeroMemory (&d3dDeviceInfo, sizeof (d3dDeviceInfo));
		lstrcpyn (d3dDeviceInfo.strDesc, Identifier.Description, 79);
		d3dDeviceInfo.bDesktopCompatible = TRUE;
		d3dDeviceInfo.bStereo = FALSE;
		d3dDeviceInfo.guidDevice = Identifier.DeviceIdentifier;
		d3dDeviceInfo.pDeviceGUID = &d3dDeviceInfo.guidDevice;
		d3dDeviceInfo.AdapterId = adapter;

		D3DFORMAT fmtValidFullScreenFormats[] =
		{
		   D3DFMT_X8R8G8B8,
		   D3DFMT_X1R5G5B5,
		   D3DFMT_R5G6B5,
		   D3DFMT_X4R4G4B4,
		   D3DFMT_R8G8B8
		};
		for(UINT format = 0; format < (sizeof(fmtValidFullScreenFormats) / sizeof(D3DFORMAT)); format++) {
			 UINT uiModes = g_pD3D->GetAdapterModeCount(adapter, fmtValidFullScreenFormats[format] );
			 for (UINT modeId = 0; modeId < uiModes; modeId++) {
				D3DFORMAT DisplayFormat = fmtValidFullScreenFormats[format];

				if( FAILED( g_pD3D->CheckDeviceType(adapter, D3DDEVTYPE_HAL, DisplayFormat, DisplayFormat, FALSE)))
					continue;

				D3DCAPS9 caps;
				g_pD3D->GetDeviceCaps(adapter, D3DDEVTYPE_HAL, &caps);
				if (caps.DevCaps & D3DDEVCAPS_PUREDEVICE)
					d3dDeviceInfo.bHardware = TRUE;
				d3dDeviceInfo.DevType = caps.DeviceType;
				d3dDeviceInfo.DevCaps = caps.DevCaps;

				D3DDISPLAYMODE mode;
				g_pD3D->EnumAdapterModes(adapter, fmtValidFullScreenFormats[format], modeId, &mode );
				D3DDISPLAYMODE *newModes = new D3DDISPLAYMODE[d3dDeviceInfo.dwNumModes+1];
				if (d3dDeviceInfo.dwNumModes > 0)
					memcpy(newModes, d3dDeviceInfo.pddsdModes, sizeof(D3DDISPLAYMODE)*d3dDeviceInfo.dwNumModes);
				newModes[d3dDeviceInfo.dwNumModes] = mode;
				d3dDeviceInfo.pddsdModes = newModes;
				d3dDeviceInfo.dwNumModes++;
				g_dwNumDevicesEnumerated++;				
			 }			 
		}
	}

	g_pD3D->Release();

	// Make sure that devices were enumerated
	if (0 == g_dwNumDevicesEnumerated) {
		//LOGOUT("No devices and/or modes were enumerated!");
		return D3DENUMERR_ENUMERATIONFAILED;
	}
	if (0 == g_dwNumDevices) {
		//LOGOUT("No enumerated devices were accepted!");
		//LOGOUT("Try enabling the D3D Reference Rasterizer.");
		return D3DENUMERR_SUGGESTREFRAST;
	}
	//sprintf (g_buf, "D3D7: Found %d graphics devices, accepted %d:", g_dwNumDevicesEnumerated, g_dwNumDevices);
	//oapiWriteLog (g_buf);
	//LOGOUT1P("Devices enumerated: %d", g_dwNumDevicesEnumerated);
	//LOGOUT1P("Devices accepted: %d", g_dwNumDevices);
	//for (DWORD i = 0; i < g_dwNumDevices; i++) {
		//LOGOUT1P("==> %s", g_pDeviceList[i].strDesc);
		//sprintf (g_buf, "D3D7: ==> %s", g_pDeviceList[i].strDesc);
		//oapiWriteLog (g_buf);
	//}

	return S_OK;
}

//-----------------------------------------------------------------------------
// Name: D3D9Enum_FreeResources ()
// Desc: Cleans up any memory allocated during device enumeration
//-----------------------------------------------------------------------------
VOID D3D9Enum_FreeResources ()
{
    for (DWORD i = 0; i < g_dwNumDevices; i++) {
        SAFE_DELETE (g_pDeviceList[i].pddsdModes);
    }
	g_dwNumDevicesEnumerated = 0L;
	g_dwNumDevices           = 0L;
}

// ------------------------------------------------------------------------------------
// Name: D3D9Enum_SelectDefaultDevice()
// Desc: Pick a device from the enumeration list based on required caps
// ------------------------------------------------------------------------------------
HRESULT D3D9Enum_SelectDefaultDevice (D3D9Enum_DeviceInfo **ppDevice, DWORD dwFlags)
{
	// Check arguments
	if (NULL == ppDevice) return E_INVALIDARG;

	// Get access to the enumerated device list
	D3D9Enum_DeviceInfo *pDeviceList;
	DWORD                dwNumDevices;
	D3D9Enum_GetDevices (&pDeviceList, &dwNumDevices);

	// Pick TnL, hardware, software and reference device
	// If given a choice, use a windowable device
    D3D9Enum_DeviceInfo* pRefRastDevice     = NULL;
    D3D9Enum_DeviceInfo* pSoftwareDevice    = NULL;
    D3D9Enum_DeviceInfo* pHardwareDevice    = NULL;
    D3D9Enum_DeviceInfo* pHardwareTnLDevice = NULL;

	for (DWORD i = 0; i < dwNumDevices; i++) {
		if (pDeviceList[i].bHardware) {
			if (pDeviceList[i].DevCaps & D3DDEVCAPS_HWTRANSFORMANDLIGHT) {
		        if (!pHardwareTnLDevice || pDeviceList[i].bDesktopCompatible)
                    pHardwareTnLDevice = &pDeviceList[i];
			} else {
				if (!pHardwareDevice || pDeviceList[i].bDesktopCompatible)
                    pHardwareDevice = &pDeviceList[i];
			}
		} else {
			if (pDeviceList[i].DevType == D3DDEVTYPE_REF) {
				if (!pRefRastDevice || pDeviceList[i].bDesktopCompatible)
                    pRefRastDevice = &pDeviceList[i];
			} else {
				if (!pSoftwareDevice || pDeviceList[i].bDesktopCompatible)
                    pSoftwareDevice = &pDeviceList[i];
			}
		}
	}

	// Pick a device in this order: TnL, hardware, software, reference
    if (0 == (dwFlags & D3DENUM_SOFTWAREONLY) && pHardwareTnLDevice)
        (*ppDevice) = pHardwareTnLDevice;
    else if (0 == (dwFlags & D3DENUM_SOFTWAREONLY) && pHardwareDevice)
        (*ppDevice) = pHardwareDevice;
    else if (pSoftwareDevice)
        (*ppDevice) = pSoftwareDevice;
    else if (pRefRastDevice)
        (*ppDevice) = pRefRastDevice;
    else
        return D3DENUMERR_NOCOMPATIBLEDEVICES;

    // Set fullscreen mode by default
    (*ppDevice)->bWindowed = FALSE;
	return S_OK;
}

// ------------------------------------------------------------------------------------
// Name: D3D9Enum_GetDevices()
// Desc: Returns a ptr to the array of D3D9Enum_DeviceInfo structures.
// ------------------------------------------------------------------------------------
VOID D3D9Enum_GetDevices (D3D9Enum_DeviceInfo **ppDevices, DWORD *pdwCount)
{
	if (ppDevices) (*ppDevices) = g_pDeviceList;
	if (pdwCount)  (*pdwCount)  = g_dwNumDevices;
}

// ------------------------------------------------------------------------------------
// Name: D3D9Enum_GetDevice()
// Desc: Returns a ptr to device idx or NULL if i is out of range
// ------------------------------------------------------------------------------------
D3D9Enum_DeviceInfo *D3D9Enum_GetDevice (DWORD idx)
{
	return (idx < g_dwNumDevices ? g_pDeviceList+idx : NULL);
}

int getBPP(D3DFORMAT format)
{
	switch (format)
	{
		case   D3DFMT_X8R8G8B8: return 32;
		case   D3DFMT_X1R5G5B5: return 16;
		case   D3DFMT_R5G6B5:   return 16;
		case   D3DFMT_X4R4G4B4: return 16;
		case   D3DFMT_R8G8B8  : return 24;
		case   D3DFMT_A8R8G8B8: return 32;

	}
	return 0;
}


