/* Sublime AMXX Editor v4.2 */

#include <amxmodx>
#include <precache_list>

#define PLUGIN  "Test API [Precache list]"
#define AUTHOR  "Shadows Adi"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_concmd("debug", "show_precache")
}

public show_precache(id)
{
	new iSize = precache_get_size(TypeModel)
	new szTemp[MAX_RESOURCE_SIZE]

	for(new i; i < iSize; i++)
	{
		precache_get_item(i, szTemp, charsmax(szTemp), TypeModel)

		log_to_file("debug.log", "Model: %s", szTemp)
	}

	iSize = precache_get_size(TypeSound)

	for(new i; i < iSize; i++)
	{
		precache_get_item(i, szTemp, charsmax(szTemp), TypeSound)

		log_to_file("debug.log", "Sound: %s", szTemp)
	}

	iSize = precache_get_size(TypeDecal)

	for(new i; i < iSize; i++)
	{
		precache_get_item(i, szTemp, charsmax(szTemp), TypeDecal)

		log_to_file("debug.log", "Decal: %s", szTemp)
	}

	iSize = precache_get_size(TypeGeneric)

	for(new i; i < iSize; i++)
	{
		precache_get_item(i, szTemp, charsmax(szTemp), TypeGeneric)

		log_to_file("debug.log", "Generic: %s", szTemp)
	}

	iSize = precache_get_size(TypeEvent)

	for(new i; i < iSize; i++)
	{
		precache_get_item(i, szTemp, charsmax(szTemp), TypeEvent)

		log_to_file("debug.log", "Event: %s", szTemp)
	}

	log_to_file("debug.log", "Precached? %s", is_resource_precached("models/p_usp.mdl", TypeModel) ? "true" : "false")

	if(is_resource_precached("models/p_usp.mdl", TypeModel))
	{
		log_to_file("debug.log", "Replaced? %s", unprecache_resource("models/p_usp.mdl", REPLACE, true, "models/p_glock18.mdl") ? "successfull" : "unsuccessfull")
	}
}