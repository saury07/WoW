-- Globals Section
Bubble_UpdateInterval = 0.5; -- How often the OnUpdate code will run (in seconds)
BubbleSettings = nil;
local SHOW_SPEC_1 = "SHOW_SPEC_1";
local SHOW_SPEC_2 = "SHOW_SPEC_2";

CurrentMonitoredPlayersCount = 0;
CurrentMonitoredPlayers = {};
CellHeight = 12;
BaseHeight = 30;
BUBBLE_NAME = "NAME";
PWS = "PWS";
CLARITY = "CLARITY";



-- Functions Section
function Bubble_OnUpdate(self, elapsed)
    self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
    if (self.TimeSinceLastUpdate > Bubble_UpdateInterval) then
        self.TimeSinceLastUpdate = 0;
        AddNewMonitoredUnits();
    end
end

function AddNewMonitoredUnits()
    local allPWS = GetAllShields();
    if #allPWS > 0 then
        CurrentMonitoredPlayersCount = #allPWS;
        Bubble_Frame:SetHeight(BaseHeight+CellHeight*CurrentMonitoredPlayersCount);
        local names = {};
        local values = {};
        for i=1,#allPWS do
            names[i] = UnitName(allPWS[i][BUBBLE_NAME]);
            local pws = allPWS[i][PWS];
            local clarity = allPWS[i][CLARITY];
            if pws > 0 and clarity > 0 then
                values[i] = math.floor(pws/1000).."k / "..math.floor(clarity/1000).."k";
            elseif pws > 0 then
                values[i] = math.floor(pws/1000).."k / -";
            else
                values[i] = "- / "..math.floor(clarity/1000).."k";
            end

        end
        Bubble_Frame_Names:SetText(table.concat(names,"\n"));
        Bubble_Frame_Values:SetText(table.concat(values,"\n"));
    else
        Bubble_Frame:SetHeight(BaseHeight);
        Bubble_Frame_Names:SetText("");
        Bubble_Frame_Values:SetText("");
    end
end

function Bubble_OnLoad()
    Bubble_Frame_Title:SetFont("Fonts\\FRIZQT__.TTF",9);
    Bubble_Frame_Names:SetFont("Fonts\\FRIZQT__.TTF",9);
    Bubble_Frame_Values:SetFont("Fonts\\FRIZQT__.TTF",9);
    Bubble_Frame:RegisterEvent("ADDON_LOADED");
    Bubble_Frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
end

function GetAllShields()
    local ret = {};
    local units = GetAllUnitsInParty();
    for i=1,#units do
        local pws, clarity = GetShields(units[i]);
        if pws > 0 or clarity > 0 then
            local table = {};
            table[BUBBLE_NAME] = UnitName(units[i]);
            table[PWS] = pws;
            table[CLARITY] = clarity;
            ret[#ret+1]=table;
        end
    end
    return ret;
end

function GetAllUnitsInParty()
    if not IsInGroup() and not IsInRaid() then
        return {"player"};
    end
    if IsInRaid() then
        local ret = {};
        for i=1,GetNumGroupMembers() do
            ret[i] = "raid"..i;
        end
        return ret;
    else
        local ret = {};
        ret[1] = "player";
        for i=1,GetNumGroupMembers() do
            ret[i+1] = "party"..i;
        end
        return ret;
    end
end

function GetShields(unit)
    local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable,
    shouldConsolidate, spellId, canApplyAura, isBossDebuff, value1, value2, value3 = UnitBuff(unit,GetSpellInfo("17"));
    local pws = -1;
    local clarity = -1;
    if spellId and unitCaster == "player" then
        pws = value2;
    end
    name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable,
    shouldConsolidate, spellId, canApplyAura, isBossDebuff, value1, value2, value3 = UnitBuff(unit,GetSpellInfo("152118"));
    if spellId and unitCaster == "player" then
        clarity = value2;
    end
    return pws,clarity;
end

function SetSetting(key,value)
    if BubbleSettings == nil then
        BubbleSettings = {};
    end
    BubbleSettings[key] = value;
end

function GetSetting(key)
    if BubbleSettings == nil then return nil; end;
    return BubbleSettings[key];
end

function SetDisplay(value)
    if value then
        Bubble_Frame:Show();
    else
        Bubble_Frame:Hide();
    end
end

function SaveDisplayProperty(value)
    local currentSpec = GetSpecialization();
    if currentSpec == 1 then
        SetSetting(SHOW_SPEC_1,value);
    else
        SetSetting(SHOW_SPEC_2,value);
    end
end

function DisplayBasedOnSpec(spec)
    if (spec == 1 and GetSetting(SHOW_SPEC_1)) or (spec == 2 and GetSetting(SHOW_SPEC_2)) then
        SetDisplay(true);
    else
        SetDisplay(false);
    end
end

function Bubble_OnEvent(self,event, ...)
    local arg1 = ...;
    if event == "ADDON_LOADED" and arg1 == "Bubble" then
        DisplayBasedOnSpec(GetSpecialization());
    end
    if event == "ACTIVE_TALENT_GROUP_CHANGED" then
        DisplayBasedOnSpec(arg1);
    end
end

SLASH_BUBBLE1 = '/bubble';
function SlashCmdList.BUBBLE(msg, editbox)
    if Bubble_Frame:IsVisible() then
        SetDisplay(false);
        SaveDisplayProperty(false);
    else
        SetDisplay(true);
        SaveDisplayProperty(true);
    end
end