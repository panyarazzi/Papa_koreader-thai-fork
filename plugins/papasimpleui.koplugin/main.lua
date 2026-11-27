local ButtonDialog = require("ui/widget/buttondialog")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local _ = require("gettext")

local PapaSimpleUI = WidgetContainer:extend{
    name = "papasimpleui",
}

function PapaSimpleUI:init()
    self.ui.menu:registerToMainMenu(self)
end

function PapaSimpleUI:addToMainMenu(menu_items)
    menu_items.papa_simple_ui = {
        text = _("Papa Simple UI"),
        sorting_hint = "more_tools",
        callback = function()
            self:showDashboard()
        end,
    }
end

function PapaSimpleUI:showDashboard()
    local history = require("readhistory").hist or {}
    local buttons = {}
    local added = 0
    local limit = math.min(#history, 8)

    for i = 1, limit do
        local entry = history[i]
        if entry.file and not entry.dim then
            local book_path = entry.file
            local book_title = entry.text or book_path:match("([^/]+)$") or book_path
            local label = book_title
            if added == 0 then
                label = _("Continue reading") .. "\n" .. book_title
            end
            buttons[#buttons + 1] = {
                {
                    text = label,
                    callback = function()
                        UIManager:close(self.dashboard_dialog)
                        self.dashboard_dialog = nil
                        require("apps/filemanager/filemanagerutil").openFile(self.ui, book_path)
                    end,
                },
            }
            added = added + 1
        end
    end

    if added == 0 then
        buttons[#buttons + 1] = {
            {
                text = _("No recently opened books"),
                enabled = false,
            },
        }
    end

    self.dashboard_dialog = ButtonDialog:new{
        title = _("Papa Simple UI · Recent books"),
        buttons = buttons,
    }
    UIManager:show(self.dashboard_dialog)
end

return PapaSimpleUI
