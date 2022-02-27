/* Sublime AMXX Editor v4.2 */

#if defined _prcache_list_included
	#endinput
#endif
#define _prcache_list_included

#define MAX_RESOURCE_SIZE 25

enum _:Data
{
	Resource[MAX_RESOURCE_SIZE],
	Type
}

enum _:Types
{
	TypeModel = 1,
	TypeSound,
	TypeDecal,
	TypeGeneric,
	TypeEvent
}

/**
 * Gets the resource name from array.
 *
 * @param iNum		Index of resource in array.
 * @param szItem[]	Buffer to copy resource name.
 * @param iLen		Lenght of buffer.
 * @param iType		Type of the resource. See _:Types Enum
 * 
 * @type 			Integer
 * 
 * @return			1 on succes, -1 on error.
 */
native precache_get_item(iNum, szItem[], iLen, iType)

/**
 * Returns total of the precached resources of a type.
 *
 * @param iType		Type of the resource. See _:Types Enum
 * 
 * @type 			Integer
 * 
 * @return			Total of the precached resources.
 */
native precache_get_size(iType)

/**
 * Returns if the resource is precached.
 *
 * @param szItem[]	Buffer to copy resource name.
 * @param iType		Type of the resource. See _:Types Enum
 * 
 * @type 			Boolean
 * 
 * @return			True if it is, false otherwise.
 */
native bool:is_resource_precached(szItem[], iType)