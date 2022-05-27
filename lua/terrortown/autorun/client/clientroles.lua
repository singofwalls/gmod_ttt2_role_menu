RoleFrame = vgui.Create("DFrame")
RoleFrame:SetSkin("ttt2_default")
RoleFrame:SetSize(ScrW() * 0.5, ScrH() * 0.75)
RoleFrame:SetTitle("")
RoleFrame:Center()
RoleFrame:SetDraggable(false)
RoleFrame:ShowCloseButton(false)
RoleFrame:SetDeleteOnClose(false)
RoleFrame:MakePopup()
RoleFrame.Paint = function(self, w, h)
end

RoleFrameHTML = vgui.Create("DHTML", RoleFrame)
RoleFrameHTML:Dock(FILL)
RoleFrameHTML:SetAllowLua(true)
RoleFrame:SetVisible(false)

function startMenu()
    RoleFrame:SetVisible(true)
    timer.Create("rolePanel", .1, 0, function ()
        if not input.IsKeyDown( bind.Find("RoleDescriptionsBind") ) then
            RoleFrame:SetVisible(false)
            timer.Remove("rolePanel")
        end
    end )
end

function write_roles()
    local f = file.Open("roles.json", "r", "DATA")
    local role_info = util.JSONToTable(f:Read())
    f:Close()

    -- sort roles
    local tkeys = {}
    for k in pairs(role_info) do table.insert(tkeys, k) end
    table.sort(tkeys)

    local current_role = LocalPlayer():GetRoleStringRaw()
    -- Title case the role -- TODO: probably lower case all role infos instead
    current_role = string.sub(current_role, 1, 1):upper() .. string.sub(current_role, 2, -1):lower()

    local html_str = [[
    <style>
        *::-webkit-scrollbar {
            display: none;
          }
        * {
            font-family: Verdana, sans-serif;
        }
        table {
            border-collapse: collapse;
            margin: 25px 0;
            font-size: 1em;
            font-family: sans-serif;
            width: 100%;
            font-weight: 300;
            color: #ffffff;
            opacity: 1;
            box-shadow: 0 0 20px rgba(0, 0, 0, 0.15);
        }
        thead tr {
            background-color: #3f4754;
            text-align: left;
        }
        th,
        td {
            padding: 12px 15px;
        }
        tbody tr {
            border-bottom: 1px solid #dddddd;
        }
        tbody tr:nth-of-type(even) {
            background-color: #3b3b3b;
        }
        tbody tr:nth-of-type(odd) {
            background-color: #2f2f2f;
        }
        tbody tr:last-of-type {
            border-bottom: 2px solid #3f4754;
        }
        tbody tr.active-row {
            font-weight: bold;
        }
    </style>
    ]]

    -- Get role icon and colors
    local current_desc, color, color_str, icon = getRoleStrs(current_role, role_info)

    html_str = html_str .. "<table><thead><th>Your Role</th><th></th></thead><tbody>"
    html_str = html_str .. "<tr><td style='font-weight: bold;'>" .. color_str .. current_role .. "</td><td>" .. current_desc .. "</td></tr>"
    html_str = html_str .. "</tbody></table><br><br>"

    html_str = html_str .. "<table><thead><th>Role</th><th>Description</th></thead><tbody>"
    for _, roleName in ipairs(tkeys) do
        local desc, color, color_str, icon = getRoleStrs(roleName, role_info)

        html_str = html_str .. "<tr><td style='font-weight: bold;'>" .. color_str .. roleName ..  "</td><td>" .. desc .. "</td></tr>"
    end

    html_str = html_str .. "</tbody></table>"

    RoleFrameHTML:SetHTML(html_str)

    -- TODO: Fix icons
    -- TODO: Display random convar value and min players convar value
    -- TODO: Teams, colors, shop access
    -- TODO: None role support
    -- TODO: Put your role in its own panel so that it doesn't scroll of screen
end

function getRoleStrs(roleName, role_info)
    role_obj = roles.GetByName(roleName:lower())

    local icon = ""
    local color = "#ffffff"
    if role_obj ~= nil then
        icon = "<br><img src='asset://garrysmod/download/materials/" .. role_obj["icon"] .. "'>"
        r, g, b, a = role_obj["color"]:Unpack()
        color = "rgba(".. r ..", ".. g ..", ".. b ..", ".. a ..")"
    end
    color_str = "<span style='color: " .. color .. "'>◼</span> "

    local desc = role_info[roleName]
    if roleName == "None" then
        desc = "The round is starting."
    elseif desc == nil then
        desc = "This role was not found in the descriptions list. Tell an admin."
    end

    return desc, color, color_str, icon
end

net.Receive( "role_descriptions_update", function()
    print("Received roles from server")

    local role_string = net.ReadString()
    file.Write("roles.json", role_string)
    write_roles()

    bind.Register("RoleDescriptionsBind", startMenu, nil, "Role Descriptions", "Role Decsriptions Menu", KEY_LALT)

    hook.Add("TTT2UpdateSubrole", "UpdateRoleMenu", function ()
        write_roles()
    end )
end )

local roles_loaded = false;

hook.Add("InitPostEntity", "role_request_hook", function ()
    if not roles_loaded then 
        print("Requesting roles from server")
        net.Start("role_descriptions_update_request")
        net.SendToServer()
        roles_loaded = true
    end
end )
