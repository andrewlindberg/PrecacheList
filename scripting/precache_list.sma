#include <amxmodx>
#include <precache_list>
#include <reapi>

#define PLUGIN "[Precache List]"
#define VERSION "1.1"
#define AUTHOR "Shadows Adi"

new Array:g_aResources
new g_iPrecachedNum[Types]

new HookChain:g_hConPrintf
new g_iType

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	g_aResources = ArrayCreate(Data)
}

public plugin_natives()
{
	register_library("prcache_list")

	register_native("precache_get_item", "native_get_item")
	register_native("precache_get_size", "native_get_size")
	register_native("is_resource_precached", "native_resource_precached")
}

public plugin_cfg()
{
	set_task(0.1, "StartCount")
}

public StartCount()
{
	g_hConPrintf = RegisterHookChain(RH_Con_Printf, "RH_ConPrintf_Post", 1)

	g_iType = TypeModel
	server_cmd("reslist model")
	server_exec()

	RequestFrame("StopCount")

	set_task(0.2, "CountSound")
}

public CountSound()
{
	EnableHookChain(g_hConPrintf)

	g_iType = TypeSound
	server_cmd("reslist sound")
	server_exec()

	RequestFrame("StopCount")

	set_task(0.2, "CountDecal")
}

public CountDecal()
{
	EnableHookChain(g_hConPrintf)

	g_iType = TypeDecal
	server_cmd("reslist decal")
	server_exec()

	RequestFrame("StopCount")


	set_task(0.2, "CountGeneric")
}

public CountGeneric()
{
	EnableHookChain(g_hConPrintf)

	g_iType = TypeGeneric
	server_cmd("reslist generic")
	server_exec()

	RequestFrame("StopCount")

	set_task(0.2, "CountEvent")
}

public CountEvent()
{
	EnableHookChain(g_hConPrintf)

	g_iType = TypeEvent
	server_cmd("reslist event")
	server_exec()

	set_task(0.1, "StopCount")
}

public StopCount()
{
	DisableHookChain(g_hConPrintf)
}

public RH_ConPrintf_Post(const szBuffer[])
{
	if(containi(szBuffer, "FATALIFMISSING") != -1 || containi(szBuffer, "CHECKFILE") != -1 || containi(szBuffer, "-") != -1)
	{
		new szUnused[2], szTemp[Data]
		parse(szBuffer, szUnused, charsmax(szUnused), szUnused, charsmax(szUnused), szUnused, charsmax(szUnused), szTemp[Resource], charsmax(szTemp[Resource]))

		if(containi(szTemp, "'s") == -1)
		{
			szTemp[Type] = g_iType
			g_iPrecachedNum[g_iType]++

			ArrayPushArray(g_aResources, szTemp)
		}
	}
}

public plugin_end()
{
	ArrayDestroy(g_aResources)
}

// native precache_get_item(iNum, szItem[], iLen, iType)
public native_get_item(iPluginID, iParamNum)
{
	if(iParamNum != 4)
	{
		log_error(AMX_ERR_NATIVE, "%s Incorrect param num. Valid: iNum, szItem[], iLen, iType", PLUGIN)
		return -1
	}

	new szTemp[Data]
	new iNum = get_param(1)
	new iSize = get_param(3)
	new iType = get_param(4)

	if(iType < 0 || iType > TypeEvent)
	{
		log_error(AMX_ERR_NATIVE, "%s Incorrect param value. Min(%d) | Max(%d)", PLUGIN, 0, TypeEvent)
		return -1
	}

	new iIterator

	switch(iType)
	{
		case TypeSound:
		{
			iIterator = g_iPrecachedNum[TypeModel]
		}
		case TypeDecal:
		{
			iIterator = g_iPrecachedNum[TypeModel] + g_iPrecachedNum[TypeSound]
		}
		case TypeGeneric:
		{
			iIterator = g_iPrecachedNum[TypeModel] + g_iPrecachedNum[TypeSound] + g_iPrecachedNum[TypeDecal]
		}
		case TypeEvent:
		{
			iIterator = g_iPrecachedNum[TypeModel] + g_iPrecachedNum[TypeSound] + g_iPrecachedNum[TypeDecal] + g_iPrecachedNum[TypeGeneric]
		}
	}

	iNum += iIterator

	ArrayGetArray(g_aResources, iNum, szTemp)

	set_string(2, szTemp[Resource], iSize)
	return 1
}

// native precache_get_size(iType)
public native_get_size(iPluginID, iParamNum)
{
	new iType = get_param(1)
	if(iType < 0 || iType > TypeEvent)
	{
		log_error(AMX_ERR_NATIVE, "%s Incorrect param value. Min(%d) | Max(%d)", PLUGIN, 0, TypeEvent)
		return -1
	}

	return g_iPrecachedNum[iType]
}

// native is_resource_precached(szItem[], iType)
public native_resource_precached(iPluginID, iParamNum)
{
	if(iParamNum != 2)
	{
		log_error(AMX_ERR_NATIVE, "%s Incorrect param num. Valid: szItem[], iType", PLUGIN)
		return false
	}

	new szResource[MAX_RESOURCE_SIZE]
	new iType = get_param(2)
	get_string(1, szResource, charsmax(szResource))

	if(iType < 0 || iType > TypeEvent)
	{
		log_error(AMX_ERR_NATIVE, "%s Incorrect param value. Min(%d) | Max(%d)", PLUGIN, 0, TypeEvent)
		return false
	}

	new szTemp[Data]

	for(new i; i < ArraySize(g_aResources); i++)
	{
		ArrayGetArray(g_aResources, i, szTemp)

		if(equali(szTemp[Resource], szResource) && szTemp[Type] == iType)
		{
			return true
		}
	}

	return false
}