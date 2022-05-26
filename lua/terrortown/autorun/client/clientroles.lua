RoleFrame = vgui.Create("DFrame")
RoleFrame:SetSkin("ttt2_default")
RoleFrame:SetPos(ScrW() / 2 - ScrW() / 4, ScrH() / 2 - ScrH() * 0.4 / 2)
RoleFrame:SetSize(ScrW() * 0.5, ScrH() * 0.4)
RoleFrame:SetTitle("")
RoleFrame:SetDraggable(false)
RoleFrame:ShowCloseButton(false)
RoleFrame:SetDeleteOnClose(false)
RoleFrame:MakePopup()
RoleFrame.Paint = function(self, w, h)
    draw.RoundedBox(0, 0, 0, w, h, Color(42, 46, 44, 190))
end

RoleFrameHTML = vgui.Create("DHTML", RoleFrame)
RoleFrameHTML:Dock(FILL)
RoleFrameHTML:SetAllowLua(true)
RoleFrame:SetVisible(false)

function startMenu()
    RoleFrame:SetVisible(true)
    RoleFrame:MakePopup()
    timer.Create("rolePanel", .1, 0, function ()
        if not input.IsKeyDown( bind.Find("RoleDescriptionsBind") ) then
            RoleFrame:SetVisible(false)
            timer.Remove("rolePanel")
        end
    end )
end

function write_roles()
    local f = file.Open("roles.json", "r", "DATA")
    local role_string = f:Read()
    f:Close()
    print(role_string)
    RoleFrameHTML:SetHTML(role_string)
end


bind.Register("RoleDescriptionsBind", startMenu, nil, "Role Descriptions", "Role Decsriptions Menu", KEY_LALT)

net.Receive( "role_descriptions_update", function()
    local role_string = net.ReadString()
    file.Write("roles.json", role_string)
    write_roles()
end )

write_roles()
