-- Globals Section
Bubble_UpdateInterval = 0.5; -- How often the OnUpdate code will run (in seconds)
CurrentMonitoredPlayersCount = 0;
CurrentMonitoredPlayers = {};
CellHeight = 25;
BaseHeight = 30;
NAME = "NAME";
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
            names[i] = UnitName(allPWS[i][NAME]);
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
    print("Bubble loaded succesfully !");
    Bubble_Frame_Title:SetFont("Fonts\\FRIZQT__.TTF",9);
    Bubble_Frame_Names:SetFont("Fonts\\FRIZQT__.TTF",9);
    Bubble_Frame_Values:SetFont("Fonts\\FRIZQT__.TTF",9);
end

function GetAllShields()
    local ret = {};
    local units = GetAllUnitsInParty();
    for i=1,#units do
        local pws, clarity = GetShields(units[i]);
        if pws > 0 or clarity > 0 then
            local table = {};
            table[NAME] = UnitName(units[i]);
            table[PWS] = pws;
            table[CLARITY] = clarity;
            ret[#ret+1]=table;
        end
    end
    return ret;
end

function GetAllUnitsInParty()
    if not IsInGroup() then
        return {"player"};
    else
        local ret = {};
        ret[1] = "player";
        for i=1,GetNumGroupMembers()-1 do
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
    if spellId then
        pws = value2;
    end
    name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable,
    shouldConsolidate, spellId, canApplyAura, isBossDebuff, value1, value2, value3 = UnitBuff(unit,GetSpellInfo("152118"));
    if spellId then
        clarity = value2;
    end
    return pws,clarity;
end
