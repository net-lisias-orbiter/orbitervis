// ====================================================================================
// File: D3D9Enum.h
// Desc: DD and D3D device enumeration (DX7)
// ====================================================================================

#ifndef D3D9Enum_H
#define D3D9Enum_H
#include "debug.h"
#include <d3d9.h>
#include <d3dx9.h>

// ------------------------------------------------------------------------------------
// Flag and error definitions
// ------------------------------------------------------------------------------------
#define D3DENUM_SOFTWAREONLY           0x00000001 // Software-devices only flag

#define D3DENUMERR_NODIRECTDRAW        0x81000001 // Could not create DDraw
#define D3DENUMERR_ENUMERATIONFAILED   0x81000002 // Enumeration failed
#define D3DENUMERR_SUGGESTREFRAST      0x81000003 // Suggest using the RefRast
#define D3DENUMERR_NOCOMPATIBLEDEVICES 0x81000004 // No appropriate devices found

// ------------------------------------------------------------------------------------
// Name: Structure D3D9Enum_DeviceInfo
// Desc: Structure to hold information about the enumerated Direct3D devices
// ------------------------------------------------------------------------------------
struct D3D9Enum_DeviceInfo
{
	// Direct3D device information
	CHAR            strDesc[80];        // device description
	GUID*           pDeviceGUID;        // points to guidDevice
//	D3DDEVICEDESC7  ddDeviceDesc;
	BOOL            bHardware;          // hardware device
	D3DDEVTYPE		DevType;
	UINT			AdapterId;

	// DirectDraw driver information
//	GUID*           pDriverGUID;        // points to guidDriver
	D3DCAPS9        ddDriverCaps;
	//D3DCAPS9        ddHELCaps;
	DWORD			DevCaps;

	// DirectDraw selected mode information
	D3DDISPLAYMODE  ddsdFullscreenMode; // current mode (pddsdModes[dwCurrentMode])
	BOOL            bWindowed;          // flag: use device in window mode
	BOOL            bStereo;            // flag: use device in stereo mode

	// For internal use (Applications shouldn't need these members)
	GUID            guidDevice;
//	GUID            guidDriver;
	D3DDISPLAYMODE* pddsdModes;         // list of modes
	DWORD           dwNumModes;         // number of modes
	DWORD           dwCurrentMode;      // currently selected mode
	BOOL            bDesktopCompatible; // can be run in window mode
	BOOL            bStereoCompatible;  // can be run in stereo mode
};

// ------------------------------------------------------------------------------------
// Name: D3D9Enum_EnumerateDevices
// Desc: Enumerates all drivers, devices, and modes. The callback function is called
//       for each device to confirm that the device supports the feature set the
//       application requires.
// ------------------------------------------------------------------------------------
HRESULT D3D9Enum_EnumerateDevices ();

//-----------------------------------------------------------------------------
// Name: D3DEnum_FreeResources()
// Desc: Cleans up any memory allocated during device enumeration
//-----------------------------------------------------------------------------
VOID D3D9Enum_FreeResources ();

// ------------------------------------------------------------------------------------
// Name: D3D9Enum_SelectDefaultDevice()
// Desc: Pick a device from the enumeration list based on required caps
// Flag: D3DENUM_SOFTWAREONLY: pick only from software devices
// ------------------------------------------------------------------------------------
HRESULT D3D9Enum_SelectDefaultDevice (D3D9Enum_DeviceInfo **ppDevice, DWORD dwFlags = 0);

// ------------------------------------------------------------------------------------
// Name: D3D9Enum_GetDevices()
// Desc: Returns a ptr to the array of enumerated D3D9Enum_DeviceInfo structures.
// ------------------------------------------------------------------------------------
VOID D3D9Enum_GetDevices (D3D9Enum_DeviceInfo **ppDevices, DWORD *pdwCount);

// ------------------------------------------------------------------------------------
// Name: D3D9Enum_GetDevice()
// Desc: Returns a ptr to device idx or NULL if i is out of range
// ------------------------------------------------------------------------------------
D3D9Enum_DeviceInfo *D3D9Enum_GetDevice (DWORD idx);

// ------------------------------------------------------------------------------------
// Name: D3D9Enum_ReadDeviceList()
// Desc: Read device information from file
//       Return value is number of devices (0=error)
// ------------------------------------------------------------------------------------
int D3D9Enum_ReadDeviceList (CHAR *fname);

// ------------------------------------------------------------------------------------
// Name: D3D9Enum_WriteDeviceList()
// Desc: Write the device information stored in the device list to a file (binary)
// ------------------------------------------------------------------------------------
VOID D3D9Enum_WriteDeviceList (CHAR *fname);

int getBPP(D3DFORMAT format);

#endif // !D3D9Enum_H
