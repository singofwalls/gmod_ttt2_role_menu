resource.AddSingleFile("data/roles.json")
util.AddNetworkString( "role_descriptions_update" )
CreateConVar( "roledescriptions", "{}", FCVAR_ARCHIVE)

function reload_role_menu(ply, cmd, args, argStr)
    if ply:IsValid() and cmd ~= nil then
        ply:ChatPrint("Only the server can run this command")
        return
    end
    local f = file.Open("data/roles.json", "r", "thirdparty")
    local role_string = f:Read()
    f:Close()
    net.Start("role_descriptions_update")
    net.WriteString(role_string)
    if ply:IsValid() then
        net.Send(ply)
        print("Sending to player")
    else
        net.Broadcast()
        print("Broadcasting roles")
    end
    -- Todo: Make editable from within game by admins
end


concommand.Add("reload_role_menu", reload_role_menu, nil, "Reloads and resends the json file containing roles and descriptions to the clients", FCVAR_PROTECTED)

net.Receive( "role_descriptions_update_request", function(len, ply)
    if ( IsValid( ply ) and ply:IsPlayer() ) then
        reload_role_menu(ply)
    end
end )