GEMFINDER_VERSION = "GemSearch 1.0.0";

if(GemFinderOptions == nil) then
    GemFinderOptions = {};
end

if ( GemFinderOptions["MinimapButton"] == nil ) then
    GemFinderOptions["MinimapButton"] = true;
end
if ( GemFinderOptions["MinimapButtonAngle"] == nil ) then
    GemFinderOptions["MinimapButtonAngle"] = 310;
end

if ( GemFinderOptions["Scale"] == nil ) then
    GemFinderOptions["Scale"] = 1;
end

if ( GemFinderOptions["SelectedStat"]  == nil ) then
    GemFinderOptions["SelectedStat"] = 0;
end

if ( GemFinderOptions["SelectedSlot"] == nil ) then
    GemFinderOptions["SelectedSlot"] = 0;
end

if ( GemFinderOptions["SelectedQuality"] == nil ) then
    GemFinderOptions["SelectedQuality"] = 0;
end

local events = CreateFrame("Frame");

local GREY = "|cff999999";
local RED = "|cffff0000";
local WHITE = "|cffFFFFFF";
local GREEN = "|cff1eff00";
local PURPLE = "|cff9F3FFF";
local BLUE = "|cff0070dd";
local ORANGE = "|cffFF8400";

function fixcolor(text)
    --Text colouring
    text = gsub(text, "=0=", "|cff9d9d9d");
    text = gsub(text, "=1=", "|cffFFFFFF");
    text = gsub(text, "=2=", "|cff1eff00");
    text = gsub(text, "=3=", "|cff0070dd");
    text = gsub(text, "=4=", "|cffa335ee");
    text = gsub(text, "=5=", "|cffFF8000");
    text = gsub(text, "=6=", "|cffFF0000");
    return text;
end

function out(text)
 DEFAULT_CHAT_FRAME:AddMessage(text)
 UIErrorsFrame:AddMessage(text, 1.0, 1.0, 0, 1, 10)
end

function GemFinder_OnLoad()

  events:RegisterEvent("VARIABLES_LOADED");
  SELECTEDITEM = 0;

  out("GemSearch Loaded...");
  SLASH_GEMFINDER1 = "/gemsearch";
  SLASH_GEMFINDER2 = "/gs";
  SlashCmdList["GEMFINDER"] = function(msg)
		GemFinder_SlashCommandHandler(msg);
  end
end

function GemFinder_OnVariablesLoaded()
    if ( GemFinderOptions["SelectedStat"] == nil ) then
        GemFinderOptions["SelectedStat"] = 0;
    end

    if ( GemFinderOptions["SelectedSlot"] == nil ) then
        GemFinderOptions["SelectedSlot"] = 0;
    end

    if ( GemFinderOptions["SelectedQuality"] == nil ) then
        GemFinderOptions["SelectedQuality"] = 0;
    end

  GemFinderMinimapButton_Init();
  GemFinderScale_Init();
end

function GemFinder_OnEvent(event)
    if(event == "VARIABLES_LOADED") then
        GemFinder_OnVariablesLoaded();
    end
end


function GemFinder_SlashCommandHandler(msg)
  if (msg == "0") then
    ReloadUI();
  end
  GemFinder_Toggle();
end

function GemFinder_Toggle()
  local frame = getglobal("GemFinderForm")
  if (frame) then
    if(  frame:IsVisible() ) then
      frame:Hide();
    else
      frame:Show();
    end
  end
end

function GemFinderForm_OnShow()
  GemFinderTooltip:Hide();
end

function GemFinderForm_OnHide()
  GemFinderTooltip:Hide();
  GemFinderOptionsFrame:Hide();
end

function GemFinderItem_OnEnter(self)
  GemFinderTooltip:ClearLines();
  local id = self:GetID() + FauxScrollFrame_GetOffset(GemListScrollBar);

  if(GetItemInfo(GemList[id]["ItemInfoId"]) ~= nil) then

  	local iteminfo = GetItemInfo(GemList[id]["ItemInfoId"]);
    local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemTexture = GetItemInfo(GemList[id]["ItemInfoId"])

    --GemFinderTooltip:SetOwner(self, "ANCHOR_RIGHT", -(self:GetWidth() / 2), 24);
    GemFinderTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0,0);
    GemFinderTooltip:SetHyperlink("item:"..GemList[id]["ItemInfoId"]..":0:0:0");
    GemFinderTooltip:Show();

	if EnhTooltip and EnhTooltip.TooltipCall then
	  quantity = 1;
	  EnhTooltip.TooltipCall(GemFinderTooltip, itemName, itemLink, itemQuality, quantity);
	end
  end
end

function GemFinderItem_OnLeave()
  SELECTEDITEM = 0;
  GemFinderTooltip:Hide();
end


function GemFinderFrameSlotDropDown_Init()
    local i;

    for i=0,4 do
            local slotName = GemFinder_SlotList[i]["SlotName"];

    	    info = {
               	text = slotName;
               	func = GemFinderFrameSlotDropDown_OnClick;
       	    };
            UIDropDownMenu_AddButton(info);
    end
end

function GemFinderFrameStatDropDown_Init()
    local i;
    for i=0, 33 do
            local statName = GemFinder_StatList[i]["StatName"];
    	    info = {
               	text = statName;
               	func = GemFinderFrameStatDropDown_OnClick;
       	    };
            UIDropDownMenu_AddButton(info);
    end
end

function GemFinderFrameQualityDropDown_Init()
    local i;
    for i=0, 3 do
            local qualityName = fixcolor(GemFinder_QualityList[i]["QualityName"]);
    	    info = {
               	text = qualityName;
               	func = GemFinderFrameQualityDropDown_OnClick;
       	    };
            UIDropDownMenu_AddButton(info);
    end
end

function GemFinderFrameSlotDropDown_OnShow()
    UIDropDownMenu_Initialize(GemFinderFrameSlotDropDown, GemFinderFrameSlotDropDown_Init);
    UIDropDownMenu_SetSelectedID(GemFinderFrameSlotDropDown, GemFinderOptions["SelectedSlot"] + 1);
    UIDropDownMenu_SetWidth(GemFinderFrameSlotDropDown, 110);
end

function GemFinderFrameSlotDropDown_OnClick(self)
    i = self:GetID();
    if i ~= nil and i ~= 0 then
        UIDropDownMenu_SetSelectedID(GemFinderFrameSlotDropDown, i);
        GemFinderOptions["SelectedSlot"] = i-1;
        GemListScrollBar_Update();
    end
end

function GemFinderFrameStatDropDown_OnShow()
    UIDropDownMenu_Initialize(GemFinderFrameStatDropDown, GemFinderFrameStatDropDown_Init);
    UIDropDownMenu_SetSelectedID(GemFinderFrameStatDropDown, GetStatIndexById(GemFinderOptions["SelectedStat"])+1);
    UIDropDownMenu_SetWidth(GemFinderFrameStatDropDown, 200);
end

function GemFinderFrameStatDropDown_OnClick(self)
    i = self:GetID();
    if i ~= nil and i ~= 0 then
        UIDropDownMenu_SetSelectedID(GemFinderFrameStatDropDown, i);
        GemFinderOptions["SelectedStat"] = GemFinder_StatList[i-1]["StatId"];
        GemListScrollBar_Update();
    end
end

function GemFinderFrameQualityDropDown_OnShow()
    UIDropDownMenu_Initialize(GemFinderFrameQualityDropDown, GemFinderFrameQualityDropDown_Init);
    UIDropDownMenu_SetSelectedID(GemFinderFrameQualityDropDown, GetQualityIndexById(GemFinderOptions["SelectedQuality"])+1);
    UIDropDownMenu_SetWidth(GemFinderFrameQualityDropDown, 100);
end

function GemFinderFrameQualityDropDown_OnClick(self)
    i = self:GetID();
    if i ~= nil and i ~= 0 then
        UIDropDownMenu_SetSelectedID(GemFinderFrameQualityDropDown, i);

        GemFinderOptions["SelectedQuality"] = GemFinder_QualityList[i-1]["QualityId"];
        GemListScrollBar_Update();
    end
end


function GemListScrollBar_Update()

    local line, lineplusoffset, text, extratext;
    local check, currentgem, currentSlotA, currentSlotB;

    GemList = {};

    currentgem = 1;
    for value,_ in pairs(GemFinder_GemList) do
	    additem = true;

	    qualityGem = gsub(GemFinder_GemList[value]["GemLevel"], "=", "");
	    qualityGem = gsub(qualityGem, "=", "");

	    qualitySelected = gsub(GemFinderOptions["SelectedQuality"], "=", "");
	    qualitySelected = gsub(qualitySelected, "=", "");

		if GemFinderOptions["SelectedStat"] ~= 0 and
		   (GemFinder_GemList[value]["GemStatA"] ~= GemFinderOptions["SelectedStat"] and GemFinder_GemList[value]["GemStatB"] ~= GemFinderOptions["SelectedStat"] and GemFinder_GemList[value]["GemStatC"] ~= GemFinderOptions["SelectedStat"]) then
			additem = false;
	    end

	    if GemFinderOptions["SelectedSlot"] ~= 0 and
	           (GemFinderOptions["SelectedSlot"] == 1 and GemFinder_GemList[value]["SocketYellow"] == "False") or
			   (GemFinderOptions["SelectedSlot"] == 2 and GemFinder_GemList[value]["SocketBlue"] == "False") or
			   (GemFinderOptions["SelectedSlot"] == 3 and GemFinder_GemList[value]["SocketRed"] == "False") or
			   (GemFinderOptions["SelectedSlot"] == 4 and GemFinder_GemList[value]["SocketMeta"] == "False") then
			additem = false;
		end

	    if qualitySelected > qualityGem then
			additem = false;
	    end

        if additem == true then
            tinsert(GemList, GemFinder_GemList[value]);
        end

        currentgem = currentgem + 1;
    end

    GemFinderTooltip:Hide();
    table.sort(GemList, function(a, b) return a["GemName"]<b["GemName"] end);
    GemFinder_ShowGemList();


end

function GemFinder_ShowGemList()

    MaxItems = table.getn(GemList);

    FauxScrollFrame_Update(GemListScrollBar,MaxItems,15,16);

    for line=1,15 do
        lineplusoffset = line + FauxScrollFrame_GetOffset(GemListScrollBar);
        if lineplusoffset < MaxItems+1 then

            text = GemList[lineplusoffset]["GemLevel"]..GemList[lineplusoffset]["GemName"];
            text = fixcolor(text);

            getglobal("GemFinderItem_"..line.."_Icon"):SetTexture("Interface\\Icons\\"..GemList[lineplusoffset]["GemIcon"] );

            extratext = "";
            if GemList[lineplusoffset]["GemStatA"] then
                if GemList[lineplusoffset]["GemStatA"] ~= 0 then
                    extratext = extratext..GemList[lineplusoffset]["GemStatAmountA"].." "..GemFinder_StatList[GetStatIndexById(GemList[lineplusoffset]["GemStatA"])]["StatName"];
                end
            end

            if GemList[lineplusoffset]["GemStatB"] then
                if GemList[lineplusoffset]["GemStatB"] ~= 0 then
                    extratext = extratext.." / "..GemList[lineplusoffset]["GemStatAmountB"].." "..GemFinder_StatList[GetStatIndexById(GemList[lineplusoffset]["GemStatB"])]["StatName"];
                end
            end

            if GemList[lineplusoffset]["GemStatC"] then
                if GemList[lineplusoffset]["GemStatC"] ~= 0 then
                    extratext = extratext.." / "..GemList[lineplusoffset]["GemStatAmountC"].." "..GemFinder_StatList[GetStatIndexById(GemList[lineplusoffset]["GemStatC"])]["StatName"];
                end
            end

            getglobal("GemFinderItem_"..line.."_Name"):SetText(text);
            getglobal("GemFinderItem_"..line.."_Extra"):SetText(extratext);
            getglobal("GemFinderItem_"..line.."_SourceCaption"):SetText("|cffFFFFFFSource:");
            getglobal("GemFinderItem_"..line.."_SourceText"):SetText(GemList[lineplusoffset]["ItemSource"]);

            if GemList[lineplusoffset]["ItemSourceItemImage"] ~= "" then
                getglobal("GemFinderItem_"..line.."_SourceItemCaption"):SetText("|cffFFFFFFRequires:");
				getglobal("GemFinderItem_"..line.."_SourceItemIcon"):SetTexture("Interface\\Icons\\"..GemList[lineplusoffset]["ItemSourceItemImage"] );
				getglobal("GemFinderItem_"..line.."_SourceItemName"):SetText(GemList[lineplusoffset]["ItemSourceItemName"]);
				getglobal("GemFinderItem_"..line.."_SourceItemCaption"):Show();
				getglobal("GemFinderItem_"..line.."_SourceItemIcon"):Show();
				getglobal("GemFinderItem_"..line.."_SourceItemName"):Show();
			else
				getglobal("GemFinderItem_"..line.."_SourceItemCaption"):Hide();
				getglobal("GemFinderItem_"..line.."_SourceItemIcon"):Hide();
				getglobal("GemFinderItem_"..line.."_SourceItemName"):Hide();
			end
            getglobal("GemFinderItem_"..line.."_ItemID"):SetText(GemList[lineplusoffset]["ItemInfoId"]);
            getglobal("GemFinderItem_"..line):Show();
        else
            getglobal("GemFinderItem_"..line):Hide();
        end
    end
end


function GetStatIndexById(id)
    local index = 0;
	for i,_ in pairs(GemFinder_StatList) do
		if GemFinder_StatList[i]["StatId"] == id then
			index = i;
		end
	end
	return index
end

function GetQualityIndexById(id)
    local index = 0;
	for i,_ in pairs(GemFinder_QualityList) do
		if GemFinder_QualityList[i]["QualityId"] == id then
			index = i;
		end
	end
	return index
end

function GemFinderItem_OnClick(self)
	local id = self:GetID() + FauxScrollFrame_GetOffset(GemListScrollBar);
	local iteminfo = GetItemInfo(GemList[id]["ItemInfoId"]);
    local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemTexture = GetItemInfo(GemList[id]["ItemInfoId"]);
    if AuctionFrame then
        if (AuctionFrame:IsVisible() and CanSendAuctionQuery()) then
            if (iteminfo) then
              BrowseName:SetText(itemName);
              AuctionFrameBrowse_Search();
            else
              BrowseName:SetText(GemList[id]["GemName"]);
              AuctionFrameBrowse_Search();
            end
        end
    end
    if(DEFAULT_CHAT_FRAME.editBox:IsVisible() and IsShiftKeyDown() and iteminfo) then
  	    DEFAULT_CHAT_FRAME.editBox:Insert(itemLink);
    end
end


-- Minimap functions
function GemFinderMinimapButton_OnClick(self, arg1)


	if arg1=="LeftButton" then
        GemFinder_Toggle();
    elseif arg1=="RightButton" then
        GemFinderOptions_Toggle();
    end
end

function GemFinderMinimapButton_Init()
    if GemFinderMinimapButtonFrame then
	    if(GemFinderOptions["MinimapButton"]==true) then
            GemFinderMinimapButtonFrame:SetPoint("TOPLEFT","Minimap", "TOPLEFT",54 - (78 * cos(GemFinderOptions["MinimapButtonAngle"])),(78 * sin(GemFinderOptions["MinimapButtonAngle"])) - 55);
		    GemFinderMinimapButtonFrame:Show();
	    else
		    GemFinderMinimapButtonFrame:SetPoint("CENTER", "UIParent", "CENTER");
            GemFinderMinimapButtonFrame:Hide();
	    end
    end
end

function GemFinderScale_Init()
    if GemFinderForm then
        GemFinderForm:SetScale(GemFinderOptions["Scale"]);
    end
end

function GemFinderMinimapButton_OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_LEFT");
    GameTooltip:SetText(string.sub(GemFinder_VERSION, 11, 28));
    GameTooltip:AddLine(GemFinder_MINIMAPBUTTON_LINE1);
    GameTooltip:AddLine(GemFinder_MINIMAPBUTTON_LINE2);
    GameTooltip:Show();
end



-- Option Functions
function GemFinderOptions_OnLoad()
    GemFinderOptions_Init();
    UIPanelWindows['GemFinderOptionsFrame'] = {area = 'center', pushable = 0};
end

function GemFinderOptions_Init()
    GemFinderOptionsFrameMinimap:SetChecked(GemFinderOptions["MinimapButton"]);
    GemFinder_MinimapPosSlider:SetValue(GemFinderOptions["MinimapButtonAngle"]);
    GemFinder_ScaleSlider:SetValue(GemFinderOptions["Scale"]);
end

function GemFinderOptions_Toggle()
    if(GemFinderOptionsFrame:IsVisible()) then
        GemFinderOptionsFrame:Hide();
    else
        GemFinderOptionsFrame:Show();
        GemFinderOptions_Init();
    end
end


--Search Functions
function GemFinder_GetSearchTable(text)
    local tGemList = {};
    for i,_ in pairs(GemFinder_GemList) do
        local gemName = GemFinder_GemList[i]["GemName"];
        if string.match(string.lower(gemName), string.lower(text)) ~= nil then
            tinsert(tGemList, GemFinder_GemList[i]);
        end
    end
    return tGemList;
end

function GemFinder_Search(text)
    SELECTEDITEM = 0;
    local result = GemFinder_GetSearchTable(text);
    if table.getn(result) == 0 then
        DEFAULT_CHAT_FRAME:AddMessage("GemFinder : No gems match the the following criteria \""..text.."\".");
    else
        GemList = result;
        GemFinder_ShowGemList();
    end
end

function GemFinder_ClearSearch()
    GemListScrollBar_Update();
end
