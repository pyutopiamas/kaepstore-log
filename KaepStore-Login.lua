-- ============================================================================
--  KAEP STORE - Login Token (GrowLauncher)
--  Paste akun: email|mac:rid:wk:token:platform
--  Platform diambil OTOMATIS dari angka di ujung:
--     0 = Windows , 1 = iOS , 2 = macOS , 4 = Android
--  Contoh: email|02:00:...:rid:wk:token:0   (0 = Windows)
-- ============================================================================

local pref = require("preferences")
pref:new("kaepstore_ltoken.json")
pcall(function() pref:load() end)

local ltoken_account = pref:get("account", "")

local json = require("json")

local _ltoken_ui = [[
    {"sub_name":"Login Token","description":"Login with token account","icon":"Login","menu":[
        {"type":"labelapp","icon":"Storefront","text":"Kaep Store"},
        {"type":"input_string","text":"Account","default":]] .. json:encode(ltoken_account) .. [[,"placeholder":"email|mac:rid:wk:token:platform","icon":"Key","alias":"ltoken_account"},
        {"type":"toggle_button","text":"Login","default":false,"alias":"ltoken_login"},
        {"type":"tooltip","icon":"TipsAndUpdates","text":"How to use?","support_text":"Paste: email|mac:rid:wk:token:platform . Angka di ujung = platform (0=Windows, 1=iOS, 2=macOS, 4=Android), ke-detect otomatis. Lalu nyalakan Login. Matikan untuk nonaktif."}
    ]}
]]

addCategory("Kaep Store", "Storefront")
addIntoModule(_ltoken_ui, "Kaep Store")
sendNotification("Kaep Store Login ditambahkan")

local function parseAndLogin(account)
    account = account:gsub("^%s+", ""):gsub("%s+$", "")     -- trim spasi/enter

    -- Utama: cari MAC (6 pasang hex) di mana pun, lalu rid:wk:token:platform.
    -- Tahan ke pemisah "|" maupun ":" di depan email.
    local mac, rid, wk, token, plat =
        account:match("(%x%x:%x%x:%x%x:%x%x:%x%x:%x%x):([^:]+):([^:]+):([^:]+):(%d+)$")

    -- Cadangan 1: format lama tanpa platform -> default 0 (Windows)
    if not mac then
        mac, rid, wk, token = account:match("(%x%x:%x%x:%x%x:%x%x:%x%x:%x%x):([^:]+):([^:]+):([^:]+)$")
        plat = nil
    end

    -- Cadangan 2: MAC bukan format hex biasa -> buang prefix "email|" lalu pisah per ":"
    if not mac then
        local raw = account:match("|(.+)") or account
        mac, rid, wk, token, plat = raw:match("^([^:]+):([^:]+):([^:]+):([^:]+):(%d+)$")
        if not mac then
            mac, rid, wk, token = raw:match("^([^:]+):([^:]+):([^:]+):(.+)$")
            plat = nil
        end
    end

    if not (mac and rid and wk and token) then
        sendNotification("Format akun salah!")
        return
    end

    local platform = tonumber(plat) or 0                    -- default Windows kalau ga ada
    setLogin(platform, mac, rid, wk, token)
end

AddHook(function(t, n, v)
    if n == "ltoken_account" then
        ltoken_account = v
        pref:set("account", v)
        pref:save()
    elseif n == "ltoken_login" then
        if v then
            if ltoken_account == "" then
                sendNotification("Please enter an account first!")
                editToggle("ltoken_login", false)
                return
            end
            parseAndLogin(ltoken_account)
        else
            setLoginEnabled(false)
        end
    end
end, "onValue")
