/* Sublime AMXX Editor v4.2 */

#include <amxmodx>
#include <amxmisc>
#include <precache_list>
#include <orpheu_stocks>

enum _:FileData
{
	ResourceName[MAX_RESOURCE_SIZE],
	TypeResource,
	NewResource[MAX_RESOURCE_SIZE]
}

enum _:Forwards
{
	FW_PRECACHE_MODEL = 0,
	FW_PRECACHE_SOUND,
	FW_PRECACHE_GENERIC,
	FW_PRECACHE_EVENT
}

#define PLUGIN  "[Precache list] Replace / Remove Resources"
#define AUTHOR  "Shadows Adi"

new OrpheuHook:g_iHooks[Forwards]
new Array:g_aUnprecached
new g_szConfigsDir[128]

public plugin_natives()
{
	register_library("precache_list")

	register_native("unprecache_resource", "native_unprecache_resource")
}

public plugin_precache()
{
	g_aUnprecached = ArrayCreate(FileData)

	ReadFile()

	g_iHooks[FW_PRECACHE_MODEL] = OrpheuRegisterHook(OrpheuGetEngineFunction("pfnPrecacheModel", "PrecacheModel"), "Orpheu_PrecacheResource_Pre", OrpheuHookPre)
	g_iHooks[FW_PRECACHE_SOUND] = OrpheuRegisterHook(OrpheuGetEngineFunction("pfnPrecacheSound", "PrecacheSound"), "Orpheu_PrecacheResource_Pre", OrpheuHookPre)
	g_iHooks[FW_PRECACHE_GENERIC] = OrpheuRegisterHook(OrpheuGetEngineFunction("pfnPrecacheSound", "PrecacheSound"), "Orpheu_PrecacheResource_Pre", OrpheuHookPre)

	// Need another hook for pfnPrecacheEvent, because it has two params, second one containing the resource name. See http://metamod.org/sdk/dox/eiface_8h-source.html
	g_iHooks[FW_PRECACHE_EVENT] = OrpheuRegisterHook(OrpheuGetEngineFunction("pfnPrecacheEvent", "PrecacheEvent"), "Orpheu_PrecacheEvent_Pre", OrpheuHookPre)
}

ReadFile()
{
	get_configsdir(g_szConfigsDir, charsmax(g_szConfigsDir))
	format(g_szConfigsDir, charsmax(g_szConfigsDir), "%s/unprecache_list.ini", g_szConfigsDir)

	if (!file_exists(g_szConfigsDir))
		set_fail_state("%s File not found: ...%s", PLUGIN, g_szConfigsDir)

	new iFile = fopen(g_szConfigsDir, "rt")
	new iLine = 0
	new szBuffer[MAX_RESOURCE_SIZE]
	new szTemp[FileData], szTempInfo[4]

	if (!iFile)
	{
		set_fail_state("%s Could not open file %s.", PLUGIN, g_szConfigsDir)
	}

	while (!feof(iFile))
	{
		fgets(iFile, szBuffer, charsmax(szBuffer))

		trim(szBuffer)
		iLine += 1

		if(szBuffer[0] == EOS || szBuffer[0] == ';' || szBuffer[0] == '#' || !szBuffer[0])
			continue

		if(parse(szBuffer, szTemp[ResourceName], charsmax(szTemp[ResourceName]), szTempInfo, charsmax(szTempInfo), szTemp[NewResource], charsmax(szTemp[NewResource])) < 2)
		{
			log_to_file("unprecache_list.log", "A problem has been detected inside %s. Line: %d", g_szConfigsDir, iLine)
			continue
		}
		szTemp[TypeResource] = str_to_num(szTempInfo)

		ArrayPushArray(g_aUnprecached, szTemp)
	}

	fclose(iFile)
}

public OrpheuHookReturn:Orpheu_PrecacheResource_Pre(szResource[])
{
	if(szResource[0] == EOS || !szResource[0])
		return OrpheuIgnored

	new szTemp[FileData]

	switch(CheckResource(szResource, szTemp))
	{
		case REPLACE:
		{
			OrpheuSetParam(1, szResource)

			return OrpheuOverride
		}
		case REMOVE:
		{
			return OrpheuSupercede
		}
	}

	return OrpheuIgnored
}

public OrpheuHookReturn:Orpheu_PrecacheEvent_Pre(type, szResource[])
{
	if(szResource[0] == EOS || !szResource[0])
		return OrpheuIgnored

	new szTemp[FileData]

	switch(CheckResource(szResource, szTemp))
	{
		case REPLACE:
		{
			OrpheuSetParam(2, szResource)

			return OrpheuOverride
		}
		case REMOVE:
		{
			return OrpheuSupercede
		}
	}

	return OrpheuIgnored
}

CheckResource(szResource[], szArray[FileData])
{
	for(new i; i < ArraySize(g_aUnprecached); i++)
	{
		ArrayGetArray(g_aUnprecached, i, szArray)

		switch(szArray[TypeResource])
		{
			case REPLACE:
			{
				if(equali(szResource, szArray[ResourceName]))
				{
					copy(szResource, charsmax(szArray[NewResource]), szArray[NewResource])

					return REPLACE
				}
			}
			case REMOVE:
			{
				if(equali(szResource, szArray[ResourceName]))
					return REMOVE
			}
		}
	}

	return -1
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_cvar("unprecache_list", VERSION + " " + AUTHOR, FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_UNLOGGED|FCVAR_SPONLY)
	
	for(new i; i < FW_PRECACHE_EVENT; i++)
	{
		OrpheuUnregisterHook(g_iHooks[i])
	}
}

// native bool:unprecache_resource(szResource[], iType, bool:ForceChange, szNewResource[] = "")
public native_unprecache_resource(iPluginID, iParamNum)
{
	if(iParamNum < 3 || iParamNum > 4)
	{
		log_error(AMX_ERR_NATIVE, "%s Incorrect param value. szResource[], iType, bForceChange, szNewResource[] ( optional )")
	}

	new szResource[MAX_RESOURCE_SIZE]
	new iType
	new szNewResource[MAX_RESOURCE_SIZE]
	new iForceChange
	new bool:bSuccess

	get_string(1, szResource, charsmax(szResource))
	iType = get_param(2)
	iForceChange = get_param(3)
	get_string(4, szNewResource, charsmax(szNewResource))

	new iFile = fopen(g_szConfigsDir, "at")

	if(iFile)
	{
		bSuccess = fprintf(iFile, "^n^"%s^" ^"%d^" ^"%s^"", szResource, iType, (szNewResource[0] != EOS ? szNewResource : "")) > 0 ? true : false
	}

	fclose(iFile)

	if(iForceChange && bSuccess)
	{
		new szMapName[32]
		get_mapname(szMapName, charsmax(szMapName))
		server_cmd("changelevel ^"%s^"", szMapName)
	}

	return bSuccess
}