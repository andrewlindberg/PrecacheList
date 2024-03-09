/* Sublime AMXX Editor v4.2 */

#if defined _prcache_list_included
	#endinput
#endif
#define _prcache_list_included

#define MAX_RESOURCE_SIZE 256

#define VERSION "2.0"

#include <reapi>

enum _:Data
{
	Resource[MAX_RESOURCE_SIZE],
	ResourceType_t:Type,
	Size,
	Flags,
	Index
}

enum _:ResourceData
{
    REPLACE = 0,
    REMOVE
}

enum _:FileData
{
	ResourceName[MAX_RESOURCE_SIZE],
	TypeResource,
	NewResource[MAX_RESOURCE_SIZE]
}

/**
 * Gets the resource name from array.
 *
 * @param iID				Index of resource in array.
 * @param szItem[]			Buffer to copy resource name.
 * @param iLen				Lenght of buffer.
 * @param rtType			Type of the resource. See ResourceType_t: Enum
 * 
 * @type 					Integer
 * 
 * @return					1 on succes, -1 on error.
 */
native precache_get_item(iID, szResource[], iLen, ResourceType_t:rtType)

/**
 * Returns total of the precached resources of a type.
 *
 * @param iType				Type of the resource. See ResourceType_t: Enum
 * 
 * @type 					Integer
 * 
 * @return					Total of the precached resources.
 */
native precache_get_size(ResourceType_t:iType)

/**
 * Returns if the resource is precached.
 *
 * @param szItem[]			Buffer to copy resource name.
 * @param rtType			Type of the resource. See ResourceType_t: Enum
 * 
 * @type 					Boolean
 * 
 * @return					True if it is, false otherwise.
 */
native bool:is_resource_precached(szItem[], ResourceType_t:rtType)

/**
 * Returns if the resource is unprecached.
 *
 * @param szItem[]			Buffer to copy resource name.
 * 
 * @type 					Boolean
 * 
 * @return					True if it is, false otherwise.
 */
native bool:is_resource_unprecached(szItem[])

/**
 * Adds a resource to unprecaching queue.
 *
 * @param szItem[]			Buffer to copy resource name.
 * @param iType				0 = Replace the resource ( implies szNewResource[] ) 1 = Remove the resource 
 * @param bForceChange		Forces a map change to apply the new resources
 * @param szNewResource		Sets the new resource name ( imples iType = 1 )
 * 
 * @type 					Boolean
 * 
 * @return					True if the resource info was successfully written to the file, false otherwise.
 */
native bool:unprecache_resource(szResource[], iType, bool:bForceChange, szNewResource[] = "")