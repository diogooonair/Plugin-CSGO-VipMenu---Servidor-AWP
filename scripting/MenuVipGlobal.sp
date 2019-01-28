#pragma semicolon 1
#pragma tabsize 0

#define PLUGIN_AUTHOR "DiogoOnAir"
#define PLUGIN_VERSION "1.1"

#include <sourcemod>
#include <sdktools>
#include <cstrike>

bool UsouMenu[MAXPLAYERS] = false;

int Vida = 115;

public Plugin myinfo = 
{
	name = "",
	author = PLUGIN_AUTHOR,
	description = "",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	HookEvent("round_start", RoundStart);
    RegAdminCmd("sm_vipmenu", VipMenu, ADMFLAG_GENERIC, "AbrirVipMenu");
	HookEvent("decoy_firing", OnDecoyFiring);
}

public Action RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    for(new i = 1; i <= MaxClients; i++)
	{
		UsouMenu[i] = false;
		int flags = GetUserFlagBits(i);
	    if(flags & ADMFLAG_RESERVATION) 
	    {
	    	ShowVipMenu(i);
        }
    }
}

public void OnDecoyFiring(Event event, const char[] name, bool dontBroadcast)
{
	int userid = GetEventInt(event, "userid");
	int client = GetClientOfUserId(userid);

	float f_Pos[3];
	int entityid = GetEventInt(event, "entityid");
	f_Pos[0] = GetEventFloat(event, "x");
	f_Pos[1] = GetEventFloat(event, "y");
	f_Pos[2] = GetEventFloat(event, "z");

	TeleportEntity(client, f_Pos, NULL_VECTOR, NULL_VECTOR);
	RemoveEdict(entityid);
}

public void ShowVipMenu(int client)
{
	if(IsValidClient(client) && IsPlayerAlive(client))
   {
   	    UsouMenu[client] = true;
		Menu menu = new Menu(VipMenuS);

		menu.SetTitle("[VipMenu] MenuVIP");
		menu.AddItem("Health", "+15 Vida");
		menu.AddItem("Grenade", "Granadas");
		menu.AddItem("Teleport", "Granada De Teleport");
		menu.ExitButton = false;
		menu.Display(client, MENU_TIME_FOREVER);
   }
}

public int VipMenuS(Menu menu, MenuAction action, int client, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char info[32];
			menu.GetItem(param2, info, sizeof(info));

		    if (StrEqual(info, "Grenade"))
			{
				PrintToChat(client , "[VipMenu]Tu escolheste o bonus :Granadas.");
                GivePlayerItem(client, "weapon_flashbang");
                GivePlayerItem(client, "weapon_hegrenade");
                GivePlayerItem(client, "weapon_smokegrenade");
                GivePlayerItem(client, "weapon_molotov");
			}
			else if (StrEqual(info, "Health"))
			{
				PrintToChat(client , "[VipMenu] Tu escolheste o bonus :Vida Extra.");
				SetEntityHealth(client, Vida);
			}
			else if (StrEqual(info, "Teleport"))
			{
				 PrintToChat(client , "[VipMenu] Tu escolheste o bonus : Granada De Teleporte.");
                 GivePlayerItem(client, "weapon_decoy");
			}
		}

		case MenuAction_End:{delete menu;}
	}

	return 0;
}

public Action VipMenu(int client, int args)  
{
  if(GetClientTeam(client) == 1)
  {
		PrintToChat(client, "{olivegreen}Nao Podes Usar Este Comando Enquanto Estas Espectador");
		return Plugin_Handled;
  }
  if(UsouMenu[client])
  {
		PrintToChat(client, "[VipMenu]Ja Usaste O VipMenu");
		return Plugin_Handled;
  }
  else
  {
   if(IsValidClient(client) && IsPlayerAlive(client))
   {
   	    UsouMenu[client] = true;
	    ShowVipMenu(client);
   }
  }
  return Plugin_Handled; 
}

public OnClientDisconnect_Post(client)
{
    UsouMenu[client] = true;
}

stock bool IsValidClient(int client)
{
	if(client <= 0 ) return false;
	if(client > MaxClients) return false;
	if(!IsClientConnected(client)) return false;
	return IsClientInGame(client);
}