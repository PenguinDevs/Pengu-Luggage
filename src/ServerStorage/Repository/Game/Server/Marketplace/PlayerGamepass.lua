local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local GamepassStats = Resources:LoadLibrary("GamepassStats")
local UniversalGamepasses = Resources:LoadLibrary("UniversalGamepass")
local MarketplaceService = game:GetService("MarketplaceService")
local Signal = Resources:LoadLibrary("Signal")
local GamepassRewards = Resources:LoadLibrary("GamepassRewards")

function module:playerProfileAssign(playerProfile)
    local self = {}
    
    self.finished = nil

    function self:update()
        self.finished = Signal.new()
        for _, pass in pairs(GamepassStats) do
            spawn(function()
                local success = pcall(function()
                    local gamepassOverrideList = UniversalGamepasses[playerProfile.id]
                    local gamepassOverride
                    if gamepassOverrideList then gamepassOverride = gamepassOverrideList[pass.name] end
                    if gamepassOverride ~= nil then
                        self[pass.name] = gamepassOverride
                    else
                        self[pass.name] = MarketplaceService:UserOwnsGamePassAsync(playerProfile.id, pass.id)
                    end

                    local ready = true
                    for _, pass in pairs(GamepassStats) do
                        if self[pass.name] == nil then
                            ready = false
                        end
                    end
                    if self.finished and ready then
                        local signal = self.finished
                        self.finished = nil
                        signal:Fire()
                        signal:Destroy()
                    end
                end)
                if not success then warn("failed to retrieve", pass.name, "due to marketplace error") end
            end)
        end
        
        if self.finished then self.finished:Wait() end
        GamepassRewards:playerProfileAssign(playerProfile, self)
    end
    self:update()
    
    local purchaseListener = MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, _, wasPurchased)
        if not wasPurchased then return end
        if player == playerProfile.obj then
            print("updating gamepass purchase for", player)
            self:update()
        end
    end)
    playerProfile.obj.AncestryChanged:Connect(function()
        if playerProfile.obj:IsDescendantOf(game) then return end
        if purchaseListener then
            purchaseListener:Disconnect()
        end
    end)

    return self
end

return module
