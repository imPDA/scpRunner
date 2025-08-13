local function Logger(name)
    if not LibDebugLogger then return function(...) end end

    local logger = LibDebugLogger:Create(name or 'IMP_STATS')
    logger:SetMinLevelOverride(LibDebugLogger.LOG_LEVEL_DEBUG)

    local level = LibDebugLogger.LOG_LEVEL_DEBUG

    local function inner(...)
        logger:Log(level, ...)
    end

    return inner
end

local Log = Logger('SCP')

--[Visual functions/definitions for the UI to de-clutter the main file and make it more readable]
-- ScpRunner.UI = {
--     HUDTimerIcon = scprHudTimer:GetNamedChild("Icon"),
--     HUDTimer = scprHudTimer:GetNamedChild("Timer"),
--     HUDSplitsIcon = scprHudTimer:GetNamedChild("SplitIcon"),
--     HUDSplitsTime = scprHudTimer:GetNamedChild("SplitTime"),

--     TopBG = scprStatsUI:GetNamedChild("TopBG"),
--     BottomBG = scprStatsUI:GetNamedChild("BottomBG"),
--     TopDivider = scprStatsUI:GetNamedChild("TopDivider"),
--     TopTopDivider = scprStatsUI:GetNamedChild("TopTopDivider"),
--     TopTopBG = scprStatsUI:GetNamedChild("loadscreenBG"),
--     TopSubDivider = scprStatsUI:GetNamedChild("TopSubDivider"),
--     BottomSubDivider = scprStatsUI:GetNamedChild("BottomSubDivider"),
--     BottomDivier = scprStatsUI:GetNamedChild("BottomDivider"),

--     DungeonIcon = scprStatsUI:GetNamedChild("DungeonIcon"),
--     DungeonName = scprStatsUI:GetNamedChild("DungeonName"),

--     TallyIcon = scprStatsUI:GetNamedChild("TimeTallyIcon"),
--     TallyLabel = scprStatsUI:GetNamedChild("TimeTally"),

--     SplitsLabel = scprStatsUI:GetNamedChild("SplitsLabel"),
--     SplitsIcon = scprStatsUI:GetNamedChild("SplitsIcon"),
--     SplitsTopDivider = scprStatsUI:GetNamedChild("SplitsTopDivider"),
--     SplitsBottomDivider = scprStatsUI:GetNamedChild("SplitsBottomDivider"),

--     TrifectasLabel = scprStatsUI:GetNamedChild("TrifectasLabel"),
--     TrifectasIcon = scprStatsUI:GetNamedChild("TrifectasIcon"),
--     TrifectasTopDivider = scprStatsUI:GetNamedChild("TrifectasTopDivider"),
--     TrifectasBottomDivider = scprStatsUI:GetNamedChild("TrifectasBottomDivider"),
-- }

------------------------------
--[[Timer and Splits Visuals]]
------------------------------

function ScpRunner:SplitsColors()
    local steepCurve = ZO_GenerateCubicBezierEase(.01,.5,.75,.33) --Bezier curve generate

    local normalizedTimeLoss = steepCurve(math.min(math.max(timeLoss / 10, 0), 1)) --Normalizes it to a numer between 1 and 0 so it can be used in a bezier curve, and also limits it to 10 (10 being always 1 in this case)
    local red = math.floor(255 * normalizedTimeLoss) --Red RGB value, this is gonna be 0 if its a perfect split, and as we approach 10 second split time, it will approach 255.
    local green = math.floor(math.max(255 - (255 * normalizedTimeLoss))) --Same as red but reversed, closest to 0 its gonna be 255, and closer to 10 it will approach 0.
    return string.format("%02X%02X%02X", red, green, 0) --Hexadecimal rgb converter.
end

function ScpRunner:ShowSplitsAnimation(control, startx, starty, endx, endy, endx2, endy2)
    local endCurve = ZO_GenerateCubicBezierEase(.6,.3,.3,1)
    local timeline = ANIMATION_MANAGER:CreateTimeline()
    timeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)

    local move1 = timeline:InsertAnimation(ANIMATION_TRANSLATE, control, 0)
    move1:SetTranslateOffsets(startx, starty, endx, endy) --start offsetx, startoffsety, endoffsets, endoffsets.
    move1:SetDuration(400)
    move1:SetEasingFunction(endCurve)

    local makeVisible = timeline:InsertAnimation(ANIMATION_ALPHA, control, 0)
    makeVisible:SetAlphaValues(0, 1)
    makeVisible:SetDuration(200)
    makeVisible:SetEasingFunction(endCurve)

    local move2 = timeline:InsertAnimation(ANIMATION_TRANSLATE, control, 5000)
    move2:SetTranslateOffsets(endx, endy, endx2, endy2) --start offsetx, startoffsety, endoffsets, endoffsets.
    move2:SetDuration(800)
    move2:SetEasingFunction(endCurve)

    local makeInvisible = timeline:InsertAnimation(ANIMATION_ALPHA, control, 5000)
    makeInvisible:SetAlphaValues(1, 0)
    makeInvisible:SetDuration(550)
    makeInvisible:SetEasingFunction(endCurve)
    timeline:PlayFromStart()
end

-------------------
--[[End Screen UI]]
-------------------

-- function ScpRunner:InitializeStatsScreen()
--     self.Scene = ZO_Scene:New("ScpRunnerStatsScene", SCENE_MANAGER)
--     self.fragment = ZO_FadeSceneFragment:New(scprStatsUI)

--     self.Scene:AddFragment(self.fragment)
--     self.Scene:AddFragment(MINIMIZE_CHAT_FRAGMENT)
--     self.Scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)

--     SCENE_MANAGER:Show("ScpRunnerStatsScene")

--     self.Scene:RegisterCallback("StateChange", function(oldState, newState)
--         ScpRunner:OnSceneStateChanged(oldState, newState)
--     end)
-- end

-- function ScpRunner:OnSceneStateChanged(oldState, newState)
--     d("scenestatechanged")

--     if (newState == SCENE_SHOWN and self.wasStatsScreenOpened == false) then
--         scprStatsUI:SetHidden(false)

--         self.wasStatsScreenOpened = true
--     elseif (newState == SCENE_HIDDEN) then
--         d("scene hidden waow")
--         scprStatsUI:SetHidden(true)
--         scprStatsUI:SetAlpha(0)
--     end
-- end

local OFFSETS = {
    {scprStatsUIHeader,                            0, 400},
    {scprStatsUIBodyTopBG,                         0, -150},
    {scprStatsUIBodyBottomBG,                      0, -700},

    {scprStatsUIBodySplitsHeader,                  300, -100},
    {scprStatsUIBodySplitsTopDivider,              0, 0},
    {scprStatsUIBodySplitsBottomDivider,           0, 0},

    {scprStatsUIBodyTrifectasHeader,               -300, -100},
    {scprStatsUIBodyTrifectasTopDivider,           0, 0},
    {scprStatsUIBodyTrifectasBottomDivider,        0, 0},

    {scprStatsUIBodyCentralColumnTimeTally,        0, 0},
    {scprStatsUIBodyCentralColumnMap,              0, -400},
    {scprStatsUIBodyCentralColumnTopSubDivider,    0, 0},
    {scprStatsUIBodyCentralColumnBottomSubDivider, 0, -800},
    {scprStatsUIBottomDivider,                     0, -1000},
}

local Curve = ZO_GenerateCubicBezierEase(1,.08,.69,.63)

local function CreateCloseAnimation()
    local openTimeline = ANIMATION_MANAGER:CreateTimeline()

    -- openTimeline:SetHandler("OnStop", function() self:TimeTallyer() end)
    openTimeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)

    -- local toX, toY = scprStatsUI:GetCenter()
    local endAlpha = 0
    local duration = 600
    local delay = 0

    --[[
    local function collectToCenterAnimation(control)
        local numChildren = control:GetNumChildren()
        local parentCenterX, parentCenterY = control:GetCenter()
        Log('Parent: %s, cX: %.2f, cY: %.2f', control:GetName(), parentCenterX, parentCenterY)

        for i = 1, numChildren do
            local childControl = control:GetChild(i)

            if childControl then
                -- if ANIMATE_THESE[childControl:GetType()] then
                    local x, y = childControl:GetCenter()
                    Log('Child: %s, cX: %.2f, cY: %.2f', childControl:GetName(), x, y)
                    local startAlpha = childControl:GetAlpha()

                    local move = openTimeline:InsertAnimation(ANIMATION_TRANSLATE, childControl, delay)
                    move:SetTranslateDeltas(parentCenterX - x, parentCenterY - y, TRANSLATE_ANIMATION_DELTA_TYPE_FROM_START)
                    move:SetDuration(duration)
                    move:SetEasingFunction(Curve)

                    -- local makeVisible = openTimeline:InsertAnimation(ANIMATION_ALPHA, childControl, delay)
                    -- makeVisible:SetAlphaValues(startAlpha, endAlpha)
                    -- makeVisible:SetDuration(duration)
                    -- makeVisible:SetEasingFunction(Curve)
                -- end

                -- collectToCenterAnimation(childControl)
            end
        end
    end

    collectToCenterAnimation(scprStatsUI)
    --]]

    ---[[
    for _, controlData in ipairs(OFFSETS) do
        -- local x, y = controlData:GetCenter()
        local startAlpha = controlData[1]:GetAlpha()

        local move = openTimeline:InsertAnimation(ANIMATION_TRANSLATE, controlData[1], delay)
        -- move:SetTranslateDeltas(toX - x, toY - y)
        move:SetTranslateDeltas(controlData[2], controlData[3])
        move:SetDuration(duration)
        move:SetEasingFunction(Curve)

        local makeVisible = openTimeline:InsertAnimation(ANIMATION_ALPHA, controlData[1], delay)
        makeVisible:SetAlphaValues(startAlpha, endAlpha)
        makeVisible:SetDuration(duration)
        makeVisible:SetEasingFunction(Curve)
    end

    local scale = openTimeline:InsertAnimation(ANIMATION_SCALE, scprStatsUIBodyCentralColumnMap, delay)
        -- move:SetTranslateDeltas(toX - x, toY - y)
        scale:SetScaleValues(scprStatsUIBodyCentralColumnMap:GetScale(), 0.3)
        scale:SetDuration(duration)
        scale:SetEasingFunction(Curve)
    --]]

    return openTimeline
end


SLASH_COMMANDS["/createscene1"] = function()
    ScpRunner:InitializeStatsScreen()
end

local timeline = CreateCloseAnimation()
SLASH_COMMANDS["/scpgo"] = function()
    -- local timeline = CreateOpenAnimation()
    timeline:PlayFromStart(0)
end

SLASH_COMMANDS["/scpgob"] = function()
    -- local timeline = CreateOpenAnimation()
    timeline:PlayFromEnd(0)
end