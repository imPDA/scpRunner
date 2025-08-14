local fakeCurrentSplits = {
        {name = "Trash 1", time = 5.10, fightTime = 0},
        {name = "Trash 2", time = 923.000, fightTime = 0},
        {name = "Trash 3", time = 26.73, fightTime = 0},
        {name = "Trash 4", time = 36.85, fightTime = 0},
    }

local function SetupRow(control, data)
    d("SetupRow called for " .. tostring(data.name))
    -- Set big name label

    local nameLabel = control:GetNamedChild("NameLabel")
    local timesLabel = control:GetNamedChild("TimeLabel")

    if nameLabel then
        nameLabel:SetText(data.name)
    else
        d("Missing scpSplitsName label!")
    end

    if timesLabel then
        timesLabel:SetText(string.format("Time: %.2f, FightTime: %.2f", data.time, data.fightTime))
        timesLabel:SetColor(1, 0.8, 0.2)
    else
        d("Missing scpSplitsTime label!")
    end
end

local function CreateList()
    local control = scprStatsUIBodySplitsList
    local typeId = 1
    local templateName = 'scpRowTemplate'
    local height = 40
    local setupFunction = SetupRow
    local hideCallback = nil
	local dataTypeSelectSound = nil
	local resetControlCallback = nil

    ZO_ScrollList_AddDataType(control, typeId, templateName, height, setupFunction, hideCallback, dataTypeSelectSound, resetControlCallback)
end

local function PopulateList()
    d("called list populate")

    local listControl = scprStatsUIBodySplitsList
    local dataList = ZO_ScrollList_GetDataList(listControl)

    ZO_ScrollList_Clear(listControl)

    for _, entry in ipairs(fakeCurrentSplits) do
        d("called fake splits for loop")
        local newEntry = ZO_ScrollList_CreateDataEntry(1, entry)

        table.insert(dataList, newEntry)
    end

    d("DataList count: " .. #dataList)

    ZO_ScrollList_Commit(listControl)
end

do
    CreateList()
end

SLASH_COMMANDS['/scpl'] = PopulateList
