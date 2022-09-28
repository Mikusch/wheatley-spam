/**
 * Copyright (C) 2022  Mikusch
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

#include <sourcemod>
#include <dhooks>

#pragma semicolon 1
#pragma newdecls required

enum
{
	TF_SAPEVENT_NONE = 0,
	TF_SAPEVENT_PLACED,
	TF_SAPEVENT_DONE,
};

int g_iOffsetSappingEvent;
DynamicHook g_hDHookUpdateOnRemove;

public Plugin myinfo =
{
	name = "Wheatley Sapper Spam",
	author = "Mikusch",
	description = "Restores the infamous Ap-Sap voice line spam exploit.",
	version = "1.0.0",
	url = "https://github.com/Mikusch/wheatley-spam"
}

public void OnPluginStart()
{
	GameData hGameData = new GameData("wheatley-spam");
	if (hGameData)
	{
		g_hDHookUpdateOnRemove = DynamicHook.FromConf(hGameData, "CBaseEntity::UpdateOnRemove");
		if (!g_hDHookUpdateOnRemove)
		{
			SetFailState("Failed to setup hook for CBaseEntity::UpdateOnRemove");
		}
		
		g_iOffsetSappingEvent = hGameData.GetOffset("CTFPlayer::m_iSappingEvent");
		if (!g_iOffsetSappingEvent)
		{
			SetFailState("Failed to retrieve offset for CTFPlayer::m_iSappingEvent");
		}
		
	}
	delete hGameData;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (StrEqual(classname, "obj_attachment_sapper"))
	{
		g_hDHookUpdateOnRemove.HookEntity(Hook_Post, entity, DHookCallback_UpdateOnRemove_Post);
	}
}

static MRESReturn DHookCallback_UpdateOnRemove_Post(int entity)
{
	int builder = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
	if (builder != -1)
	{
		SetEntData(builder, g_iOffsetSappingEvent, TF_SAPEVENT_DONE);
	}
	
	return MRES_Ignored;
}
