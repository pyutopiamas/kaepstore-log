-- ============================================================================
--  KAEP STORE - Login Token (GrowLauncher)
--  Paste akun: email|mac:rid:wk:token  ATAU  email:mac:rid:wk:token
--  Pilih platform (Windows / macOS), lalu nyalakan Login.
-- ============================================================================

local pref = require("preferences")
pref:new("kaepstore_ltoken.json")
pcall(function() pref:load() end)

local ltoken_account      = pref:get("account", "")
local ltoken_platform_idx = tonumber(pref:get("platform_idx", 0)) or 0
local platform_map        = {0, 2}   -- 1=Windows(0), 2=macOS(2)
if ltoken_platform_idx < 0 or ltoken_platform_idx > 1 then ltoken_platform_idx = 0 end
local ltoken_platform     = platform_map[ltoken_platform_idx + 1] or 0

local json = require("json")

local _ltoken_ui = [[
    {"sub_name":"Login Token","description":"Login with token account","icon":"Login","menu":[
        {"type":"labelapp","icon":"Storefront","text":"Kaep Store"},
        {"type":"input_string","text":"Account","default":]] .. json:encode(ltoken_account) .. [[,"placeholder":"email|mac:rid:wk:token / email:mac:rid:wk:token","icon":"Key","alias":"ltoken_account"},
        {"type":"dropdown","text":"Platform","description":"Select platform","alias":"ltoken_platform","value":"[\"Windows\",\"macOS\"]","default":]] .. ltoken_platform_idx .. [[},
        {"type":"toggle_button","text":"Login","default":false,"alias":"ltoken_login"},
        {"type":"tooltip","icon":"TipsAndUpdates","text":"How to use?","support_text":"Paste your account in email|mac:rid:wk:token or email:mac:rid:wk:token, select platform, then toggle Login on. Toggle off to disable login."}
    ]}
]]

addCategory("Kaep Store", "Storefront")
addIntoModule(_ltoken_ui, "Kaep Store")
sendNotification("Kaep Store Login ditambahkan")

local function parseAndLogin(account, platformID)
    local mac, rid, wk, ltoken = account:match("(%x%x:%x%x:%x%x:%x%x:%x%x:%x%x):([^:]+):([^:]+):(.+)")
    if not mac then
        local raw = account:match("|(.+)") or account
        mac, rid, wk, ltoken = raw:match("^[^:]+:([^:]+):([^:]+):([^:]+):(.+)$")
        if not mac then
            mac, rid, wk, ltoken = raw:match("^([^:]+):([^:]+):([^:]+):(.+)$")
        end
    end
    if not (mac and rid and wk and ltoken) then
        sendNotification("Invalid account format!")
        return
    end

    setLogin(platformID, mac, rid, wk, ltoken)
end

AddHook(function(t, n, v)
    if n == "ltoken_account" then
        ltoken_account = v
        pref:set("account", v)
        pref:save()
    elseif n == "ltoken_platform" then
        ltoken_platform_idx = tonumber(v) or 0
        ltoken_platform = platform_map[ltoken_platform_idx + 1] or 0
        pref:set("platform_idx", ltoken_platform_idx)
        pref:save()
    elseif n == "ltoken_login" then
        if v then
            if ltoken_account == "" then
                sendNotification("Please enter an account first!")
                editToggle("ltoken_login", false)
                return
            end
            parseAndLogin(ltoken_account, ltoken_platform)
        else
            setLoginEnabled(false)
        end
    end
end, "onValue")
