#include <sourcemod>
#include <sdktools>
#include <cstrike>


new bool:HasUseMenu[MAXPLAYERS] = false;
new bool:HasMenu[MAXPLAYERS] = false;
new menu_times[MAXPLAYERS] = 0;
new String:steamid[64];
new String:TagTeam[64];

new Handle:g_menu = INVALID_HANDLE; 

new menuv = 0;  

public Plugin:myInfo = {
  name = "VIPMenu",
  author = "DiogoOnAir",
  description = "Menu Para VIP`s Servidor De AWP",
  version = "v1Beta"
};

new iHealth = 115;

public OnPluginStart()
{
    LoadTranslations("vip_menu.phrases");
	HookEvent("round_start", OnRoundStart);
    RegAdminCmd("sm_vipmenu", VipMenu, ADMFLAG_GENERIC, "Escolher o Item Do Menu");
	HookEvent("decoy_firing", OnDecoyFiring);
	g_menu = CreateConVar("sm_vip_menu", "1", "Maximo De Utilizaçoes Por Ronda");
	menuv = GetConVarInt(g_menu);
}

public Action:OnRoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	for(new i = 1; i <= MaxClients; i++)
	{
		HasMenu[i] = false;
		HasUseMenu[i] = false;
		menu_times[i] = 0;
    }
}

public Action:VipMenu(client, args)
{
  GetClientAuthString(client, steamid, sizeof(steamid));
  if (GetUserFlagBits(client))
	{
	    if(GetClientTeam(client) == 1)
		{
			PrintToChat(client, "%s {olivegreen}Nao Podes Usar Este Comando Enquanto Estas Espectador", TagTeam);
			return Plugin_Handled;
		}
		if(HasMenu[client])
		{
			PrintToChat(client, menu_times[client] >= menuv ? "[VipMenu]Ja Usaste O VipMenu":"You can not open the menu", TagTeam);
			return Plugin_Handled;
		}
		else
		{
		HasUseMenu[client] = true;
		new Handle:VipMenu = CreateMenu(VipMenu_Handler);
        SetMenuTitle(VipMenu, "[VipMenu] MenuVIP");
        AddMenuItem(VipMenu, "Health", "+15 Vida");
        AddMenuItem(VipMenu, "Grenade", "Granadas");
	    AddMenuItem(VipMenu, "Teleport", "Granada De Teleport");
        DisplayMenu(VipMenu, client, MENU_TIME_FOREVER);
		menu_times[client]++;
			if(menu_times[client] >= menuv) 
			{
				HasMenu[client] = true;
			}
		}
		return Plugin_Continue;
	}
	return Plugin_Continue;
}

public OnDecoyFiring(Handle:event, const String:name[], bool:dontBroadcast)
{
	new userid = GetEventInt(event, "userid");
	new client = GetClientOfUserId(userid);
	
	new Float:f_Pos[3];
	new entityid = GetEventInt(event, "entityid");
	f_Pos[0] = GetEventFloat(event, "x");
	f_Pos[1] = GetEventFloat(event, "y");
	f_Pos[2] = GetEventFloat(event, "z");
	
	TeleportEntity(client, f_Pos, NULL_VECTOR, NULL_VECTOR);
	RemoveEdict(entityid);
}

public VipMenu_Handler(Handle:VipMenu, MenuAction:WhatTheFreakingUserDoAgain, NoobIdentifier, VipMenuIndex)
{
    if (WhatTheFreakingUserDoAgain == MenuAction_Select)
    {
      decl String:selectedBonus[200];
      GetMenuItem(VipMenu, VipMenuIndex, selectedBonus, sizeof(selectedBonus));

      if(StrEqual(selectedBonus, "Grenade"))
      {
        PrintToChat( NoobIdentifier, "[VipMenu]Tu escolheste o bonus :Granadas." , TagTeam);
        GivePlayerItem(NoobIdentifier, "weapon_flashbang");
        GivePlayerItem(NoobIdentifier, "weapon_hegrenade");
        GivePlayerItem(NoobIdentifier, "weapon_smokegrenade");
        GivePlayerItem(NoobIdentifier, "weapon_molotov");
      }
      if(StrEqual(selectedBonus, "Health"))
      {
        SetEntProp(NoobIdentifier, PropType:0, "m_iHealth", iHealth, 4, 0);
        PrintToChat( NoobIdentifier, "[VipMenu] Tu escolheste o bonus :Vida Extra." , TagTeam);
      }
	  if(StrEqual(selectedBonus, "Teleport"))
      {
        PrintToChat( NoobIdentifier, "[VipMenu] Tu escolheste o bonus : Granada De Teleporte." , TagTeam);
        GivePlayerItem(NoobIdentifier, "weapon_decoy");
      }
    }
    else if (WhatTheFreakingUserDoAgain == MenuAction_End)
    {
        CloseHandle(VipMenu);
    }
}

public OnClientDisconnect_Post(client)
{
    HasMenu[client] = true;
    menu_times[client] = 0;
}
