--[[
CREDITS:
UI Library: Inori & wally
HUGE HELP WITH SCRIPT: DeityVarn
Script: goosebetter
]]

repeat
	task.wait()
until game:IsLoaded()

local start = tick()
local client = game:GetService('Players').LocalPlayer
local executor = identifyexecutor and identifyexecutor() or 'Unknown'

local UI = loadstring(game:HttpGet('https://raw.githubusercontent.com/bardium/LinoriaLib/main/Library.lua'))()
local themeManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/bardium/LinoriaLib/main/addons/ThemeManager.lua'))()

local metadata = loadstring(game:HttpGet('https://raw.githubusercontent.com/bardium/fire-force-online/main/metadata.lua'))()
local httpService = game:GetService('HttpService')
local repStorage = game:GetService('ReplicatedStorage')

local liveNPCS, alive, ignoreParts, events, markers
local counter = 0

while true do
	if typeof(liveNPCS) ~= 'Instance' then
		for _, obj in next, workspace:GetChildren() do
			if obj.Name == 'LiveNPCS' and obj:IsA('Folder') then 
				liveNPCS = obj
			end
		end
	end

	if typeof(alive) ~= 'Instance' then
		for _, obj in next, workspace:GetChildren() do
			if obj.Name == 'Alive' and obj:IsA('Folder') then 
				alive = obj
			end
		end
	end

	if typeof(ignoreParts) ~= 'Instance' then
		for _, obj in next, workspace:GetChildren() do
			if obj.Name == 'IgnoreParts' and obj:IsA('Folder') then 
				ignoreParts = obj
			end
		end
	end

	if typeof(markers) ~= 'Instance' then
		for _, obj in next, workspace:GetChildren() do
			if obj.Name == 'AllMissionMarkers' and obj:IsA('Folder') then 
				markers = obj
			end
		end
	end

	if typeof(events) ~= 'Instance' then
		for _, obj in next, repStorage:GetChildren() do
			if obj.Name == 'Events' and obj:IsA('Folder') then 
				events = obj
			end
		end
	end

    if (typeof(liveNPCS) == 'Instance' and typeof(alive) == 'Instance' and typeof(ignoreParts) == 'Instance' and typeof(events) == 'Instance' and typeof(markers) == 'Instance') then
        break
    end

    counter = counter + 1
    if counter > 6 then
        client:Kick(string.format('Failed to load game dependencies. Details: %s, %s, %s, %s, %s', typeof(liveNPCS), typeof(alive), typeof(ignoreParts), typeof(markers), typeof(events)))
    end
    task.wait(1)
end

local runService = game:GetService('RunService')
local virtualInputManager = game:GetService('VirtualInputManager')

do
	if shared._unload then
		pcall(shared._unload)
	end

	function shared._unload()
		if shared._id then
			pcall(runService.UnbindFromRenderStep, runService, shared._id)
		end

		UI:Unload()

		for i = 1, #shared.threads do
			coroutine.close(shared.threads[i])
		end

		for i = 1, #shared.callbacks do
			task.spawn(shared.callbacks[i])
		end
	end

	shared.threads = {}
	shared.callbacks = {}

	shared._id = httpService:GenerateGUID(false)
end

do
	local thread = task.spawn(function()
		local playerGui = client:WaitForChild('PlayerGui')
		local sideQuest = playerGui:WaitForChild('Status'):WaitForChild('SideQuest')
		local function clickUiButton(v, state)
			virtualInputManager:SendMouseButtonEvent(v.AbsolutePosition.X + v.AbsoluteSize.X / 2, v.AbsolutePosition.Y + 50, 0, state, game, 1)
		end
		while true do
			task.wait()
			if ((Toggles.CatQuests) and (Toggles.CatQuests.Value)) then
				if sideQuest.Visible == true and not sideQuest:WaitForChild('QuestName').Text:match('cat') then
					UI:Notify('You already have a quest. Cancel it or finish it before using cat quests.', 5)
					Toggles.CatQuests:SetValue(false)
				end
				if sideQuest.Visible == false then
					local catNPC = nil

					for _, npc in next, alive:GetChildren() do
						if npc:FindFirstChild('OfferedQuest') and npc.OfferedQuest.Value == 'CatMission' and npc:FindFirstChild('ClickPart') and npc.ClickPart:FindFirstChild('ClickDetector') then
							catNPC = npc
						end
					end

					repeat
						if typeof(catNPC) == 'Instance' then
							client.Character:PivotTo(catNPC:GetPivot() * CFrame.new(0, -10, 0))
							task.wait()
							fireclickdetector(catNPC.ClickPart.ClickDetector)
						else
							UI:Notify('No cat quests found', 30)
							Toggles.CatQuests:SetValue(false)
						end
					until (playerGui:FindFirstChild('TextGUI') and playerGui.TextGUI:FindFirstChild('Frame') and playerGui.TextGUI.Frame and playerGui.TextGUI.Frame:FindFirstChild('Accept')) or ((not Toggles.CatQuests) or (not Toggles.CatQuests.Value))
					if (playerGui:FindFirstChild('TextGUI') and playerGui.TextGUI:FindFirstChild('Frame') and playerGui.TextGUI.Frame and playerGui.TextGUI.Frame:FindFirstChild('Accept')) then 
						playerGui.TextGUI.Frame.Accept.Visible = true
					end
					local buttonPressed = false
					repeat
						if playerGui:FindFirstChild('TextGUI') and playerGui.TextGUI:FindFirstChild('Frame') and playerGui.TextGUI.Frame and playerGui.TextGUI.Frame:FindFirstChild('Accept') then
							clickUiButton(playerGui.TextGUI.Frame.Accept, true)
							clickUiButton(playerGui.TextGUI.Frame.Accept, false)
							if sideQuest.Visible == true then
								buttonPressed = true
							end
						else
							buttonPressed = true
						end
						task.wait()
					until (buttonPressed) or (not Toggles.CatQuests.Value)
				end
				
				if sideQuest.Visible == true and sideQuest:WaitForChild('QuestName').Text:match('cat known') then
					local targetCat = nil
					UI:Notify('Looking for cat', 5)
					repeat
						for _, cat in next, ignoreParts:GetChildren() do
							if cat.Name == 'Cat' and cat:FindFirstChild('ClickDetector') and sideQuest:WaitForChild('QuestName').Text ~= 'Return the cat back to the police station.. Or?' then
								targetCat = cat
							end
						end
						task.wait()
					until typeof(targetCat) == 'Instance'
					if typeof(targetCat) == 'Instance' then
						repeat
							client.Character:PivotTo(targetCat:GetPivot() * CFrame.new(0, -10, 0))
							task.wait()
							if targetCat:FindFirstChild('ClickDetector') then
								fireclickdetector(targetCat.ClickDetector)
							end
						until (not targetCat:IsDescendantOf(workspace.IgnoreParts) or sideQuest:WaitForChild('QuestName').Text == 'Return the cat back to the police station.. Or?') or ((not Toggles.CatQuests) or (not Toggles.CatQuests.Value))
					end
				end

				if sideQuest.Visible == true and not sideQuest:WaitForChild('QuestName').Text:match('cat known') then
					repeat
						if liveNPCS:FindFirstChild('Rick') then
							client.Character:PivotTo(liveNPCS.Rick:GetPivot() * CFrame.new(0, -10, 0))
							task.wait()
							fireclickdetector(liveNPCS.Rick.ClickPart.ClickDetector)
						end
					until (playerGui:FindFirstChild('TextGUI') and playerGui.TextGUI:FindFirstChild('Frame') and playerGui.TextGUI.Frame and playerGui.TextGUI.Frame:FindFirstChild('Accept')) or ((not Toggles.CatQuests) or (not Toggles.CatQuests.Value))
					if (playerGui:FindFirstChild('TextGUI') and playerGui.TextGUI:FindFirstChild('Frame') and playerGui.TextGUI.Frame and playerGui.TextGUI.Frame:FindFirstChild('Accept')) then 
						playerGui.TextGUI.Frame.Accept.Visible = true
					end
					repeat
						if (playerGui:FindFirstChild('TextGUI') and playerGui.TextGUI:FindFirstChild('Frame') and playerGui.TextGUI.Frame and playerGui.TextGUI.Frame:FindFirstChild('Accept')) then
							clickUiButton(playerGui.TextGUI.Frame.Accept, true)
						end
						task.wait()
						if (playerGui:FindFirstChild('TextGUI') and playerGui.TextGUI:FindFirstChild('Frame') and playerGui.TextGUI.Frame and playerGui.TextGUI.Frame:FindFirstChild('Accept')) then
							clickUiButton(playerGui.TextGUI.Frame.Accept, false)
						end
					until sideQuest.Visible == false or ((not Toggles.CatQuests) or (not Toggles.CatQuests.Value))
				end
			end
		end
	end)
	table.insert(shared.callbacks, function()
		pcall(task.cancel, thread)
	end)
end

do
	local thread = task.spawn(function()
		while true do
			task.wait()
			if ((Toggles.KillAura) and (Toggles.KillAura.Value)) then
				if typeof(client.Character) == 'Instance' and client.Character:IsDescendantOf(alive) then
					local closestMob = nil
					for _, v in next, alive:GetChildren() do
						if v:IsA('Model') and v:FindFirstChildOfClass('Humanoid') and not game.Players:FindFirstChild(v.Name) then
							if closestMob == nil then
								closestMob = v
							else
								if (client.Character:GetPivot().Position - v:GetPivot().Position).Magnitude < (closestMob:GetPivot().Position - client.Character:GetPivot().Position).Magnitude then
									closestMob = v
								end
							end
						end
					end

					if typeof(closestMob) == 'Instance' then
						local weapon = client.Character:FindFirstChild('FistCombat')
						if client.Character:FindFirstChildOfClass('Tool') and client.Character:FindFirstChildOfClass('Tool'):FindFirstChildOfClass('LocalScript') then
							if client.Character:FindFirstChildOfClass('Tool'):FindFirstChildOfClass('LocalScript'):FindFirstChild('SS1') then
								weapon = client.Character:FindFirstChildOfClass('Tool'):FindFirstChildOfClass('LocalScript'):FindFirstChild('SS1')
							else
								weapon = client.Character:FindFirstChildOfClass('Tool'):FindFirstChildOfClass('LocalScript')
							end
						end
						if events:FindFirstChild('CombatEvent') then
							events.CombatEvent:FireServer(1, weapon, closestMob:GetPivot(), true)
						end
					end
				end
			end
		end
	end)
	table.insert(shared.callbacks, function()
		pcall(task.cancel, thread)
	end)
end

do
	local thread = task.spawn(function()
		while true do
			task.wait()
			if ((Toggles.TeleportToMobs) and (Toggles.TeleportToMobs.Value)) then
				if typeof(client.Character) == 'Instance' and client.Character:IsDescendantOf(alive) then
					local closestMob = alive:FindFirstChild(tostring(Options.TargetMob.Value))
					if closestMob ~= nil and closestMob:IsDescendantOf(alive) and closestMob:FindFirstChildOfClass('Humanoid') and typeof(closestMob:GetPivot()) == 'CFrame' and typeof(closestMob:GetExtentsSize()) == 'Vector3' and closestMob:FindFirstChildWhichIsA('BasePart') then
						if closestMob:FindFirstChild('HumanoidRootPart') then
							local offset = Vector3.new(Options.XOffset.Value, Options.YOffset.Value, Options.ZOffset.Value)
							client.Character:PivotTo(CFrame.new(closestMob.HumanoidRootPart:GetPivot().Position + offset))
						else
							local offset = Vector3.new(Options.XOffset.Value, Options.YOffset.Value, Options.ZOffset.Value)
							client.Character:PivotTo(CFrame.new(closestMob:GetPivot().Position + offset))
						end
					end
				end
			end
		end
	end)
	table.insert(shared.callbacks, function()
		pcall(task.cancel, thread)
	end)
end

do
	local thread = task.spawn(function()
		while true do
			task.wait()
			if ((Toggles.AutoKeysDefense) and (Toggles.AutoKeysDefense.Value)) then
				if client:FindFirstChildOfClass('PlayerGui') and client:FindFirstChildOfClass('PlayerGui'):FindFirstChild('TrainingGui') and client:FindFirstChildOfClass('PlayerGui').TrainingGui:FindFirstChild('DefenseTraining') and client:FindFirstChildOfClass('PlayerGui').TrainingGui.DefenseTraining.Value == true and client:FindFirstChildOfClass('PlayerGui').TrainingGui.DefenseTraining.Pause.Value == false and events:FindFirstChild('TrainingEvent') then
					local KeyToPress = client:FindFirstChildOfClass('PlayerGui').TrainingGui.DefenseTraining.CurrentKeyToPress.Value
					local TrainingGUI = client:FindFirstChildOfClass('PlayerGui').TrainingGui.DefenseTraining
					local keyToPress = TrainingGUI:FindFirstChild(KeyToPress).Value
			
					events.TrainingEvent:FireServer('Defense', keyToPress)
					task.wait(.2)
				end
			end
		end
	end)
	table.insert(shared.callbacks, function()
		pcall(task.cancel, thread)
	end)
end

local function addRichText(label)
	label.TextLabel.RichText = true
end

local Window = UI:CreateWindow({
	Title = string.format('fire force online - version %s | updated: %s', metadata.version, metadata.updated),
	AutoShow = true,

	Center = true,
	Size = UDim2.fromOffset(550, 567),
})

local Tabs = {}
local Groups = {}

Tabs.Main = Window:AddTab('Main')
Tabs.UISettings = Window:AddTab('UI Settings')

Groups.Main = Tabs.Main:AddLeftGroupbox('Main')
local oldPivot = typeof(client.Character) == 'Instance' and client.Character:GetPivot() or CFrame.new(-535, 555, 4638)
Groups.Main:AddToggle('CatQuests', { Text = 'Complete cat quests', Default = false, Callback = function(Value)
	if Value == true then
		oldPivot = typeof(client.Character) == 'Instance' and client.Character:GetPivot() or CFrame.new(-535, 555, 4638)
	else
		if typeof(client.Character) == 'Instance' and typeof(oldPivot) == 'CFrame' then
			client.Character:PivotTo(oldPivot)
		end
	end
end })
local Depbox = Groups.Main:AddDependencyBox();
Depbox:AddLabel('If you experience problems with the cat quests, please re-execute. Also make sure the UI isnt covering the dialog text UI.\n', true)
Depbox:SetupDependencies({
	{ Toggles.CatQuests, true }
});
Groups.Main:AddToggle('KillAura', { Text = 'Kill aura', Default = false } )

local function removeDuplicates(inputTable)
    local outputTable = {}
    local seen = {}

    for _, value in ipairs(inputTable) do
        if not seen[value] then
            table.insert(outputTable, value)
            seen[value] = true
        end
    end

    return outputTable
end

local function GetAliveNPCsString()
	local AliveList = {};

	for _, aliveNPC in next, alive:GetChildren() do
		if aliveNPC:IsA('Model') and not aliveNPC:FindFirstChild('ClientInfo') and not game.Players:GetPlayerFromCharacter(aliveNPC) then
			table.insert(AliveList, aliveNPC.Name)
		end
	end

	AliveList = removeDuplicates(AliveList)

	table.sort(AliveList, function(str1, str2) return str1 < str2 end);

	return AliveList;
end;

Groups.Main:AddToggle('TeleportToMobs', { Text = 'Teleport to mobs', Default = false } )
local aliveNPCs = GetAliveNPCsString()
Groups.Main:AddDropdown('TargetMob', {
	Text = 'Target mob',
	AllowNull = true,
	Compact = false,
	Values = aliveNPCs,
	Default = aliveNPCs[1]
})
Groups.Main:AddSlider('YOffset', { Text = 'Height offset', Min = -50, Max = 50, Default = 2, Suffix = ' studs', Rounding = 1, Compact = true, Tooltip = 'Height offset when teleporting to mobs' })
Groups.Main:AddSlider('XOffset', { Text = 'X position offset', Min = -50, Max = 50, Default = 0, Suffix = ' studs', Rounding = 1, Compact = true, Tooltip = 'X offset when teleporting to mobs' })
Groups.Main:AddSlider('ZOffset', { Text = 'Z position offset', Min = -50, Max = 50, Default = 10, Suffix = ' studs', Rounding = 1, Compact = true, Tooltip = 'Z offset when teleporting to mobs' })

Groups.Main:AddDropdown('AliveNPCTeleports', {
	Text = 'Teleport to moving npc',
	AllowNull = true,
	Compact = false,
	Values = aliveNPCs,
	Default = aliveNPCs[1],
	Callback = function(targetAliveNPC)
		if alive:FindFirstChild(tostring(targetAliveNPC)) and alive[tostring(targetAliveNPC)]:IsA('Model') then
			if alive:FindFirstChild(tostring(targetAliveNPC)):FindFirstChild('HumanoidRootPart') then
				client.Character:PivotTo(alive[tostring(targetAliveNPC)].HumanoidRootPart:GetPivot() * CFrame.new(0, 2, 0))
			else
				client.Character:PivotTo(alive[tostring(targetAliveNPC)]:GetPivot() * CFrame.new(0, 2, 0))
			end
			client.Character:PivotTo(alive[tostring(targetAliveNPC)]:GetPivot() * CFrame.new(0, 2, 0))
		end
	end,
})

local function OnAliveNPCsChanged()
	if Options.TargetMob ~= nil then
		Options.TargetMob:SetValues(GetAliveNPCsString());
	end
	Options.AliveNPCTeleports:SetValues(GetAliveNPCsString());
end;

alive.ChildAdded:Connect(OnAliveNPCsChanged);
alive.ChildRemoved:Connect(OnAliveNPCsChanged);

local function GetLiveNPCsString()
	local LiveList = {};

	for _, liveNPC in next, liveNPCS:GetChildren() do
		if liveNPC:IsA('Model') and not liveNPC:FindFirstChild('ClientInfo') and not game.Players:GetPlayerFromCharacter(liveNPC) then
			if liveNPC.Name == 'PoliceMan' then
				table.insert(LiveList, 'Officer Jones')
			else
				table.insert(LiveList, liveNPC.Name)
			end
		end
	end

	if workspace:FindFirstChild('HelpfulNPCS') and workspace.HelpfulNPCS:IsA('Folder') then
		for _, liveNPC in next, workspace.HelpfulNPCS:GetDescendants() do
			if liveNPC:IsA('Model') and liveNPC:FindFirstChildOfClass('Humanoid') then
				table.insert(LiveList, liveNPC.Name)
			end
		end
	end

	LiveList = removeDuplicates(LiveList)

	table.sort(LiveList, function(str1, str2) return str1 < str2 end);

	return LiveList;
end;

local liveNPCs = GetLiveNPCsString()
Groups.Main:AddDropdown('LiveNPCTeleports', {
	Text = 'Teleport to regular npc',
	AllowNull = true,
	Compact = false,
	Values = liveNPCs,
	Default = liveNPCs[1],
	Callback = function(targetLiveNPC)
		if targetLiveNPC == 'Officer Jones' then
			if liveNPCS:FindFirstChild('PoliceMan') and liveNPCS.PoliceMan:IsA('Model') then
				client.Character:PivotTo(liveNPCS.PoliceMan:GetPivot() * CFrame.new(0, 2, 0))
			end
		end
		if liveNPCS:FindFirstChild(tostring(targetLiveNPC)) and liveNPCS[tostring(targetLiveNPC)]:IsA('Model') then
			client.Character:PivotTo(liveNPCS[tostring(targetLiveNPC)]:GetPivot() * CFrame.new(0, 2, 0))
		elseif workspace:FindFirstChild('HelpfulNPCS') then
			for _, helpfulNPC in next, workspace.HelpfulNPCS:GetDescendants() do
				if helpfulNPC.Name == targetLiveNPC and helpfulNPC:IsA('Model') then
					client.Character:PivotTo(helpfulNPC:GetPivot() * CFrame.new(0, 2, 0))
				end
			end
		end
	end,
})

local function OnLiveNPCsChanged()
	Options.LiveNPCTeleports:SetValues(GetLiveNPCsString());
end;

liveNPCS.ChildAdded:Connect(OnLiveNPCsChanged);
liveNPCS.ChildRemoved:Connect(OnLiveNPCsChanged);

local function GetMarkersString()
	local MarkerList = {};

	for _, marker in next, markers:GetChildren() do
		if marker:IsA('BillboardGui') and marker.Enabled == true and marker.Adornee ~= nil and typeof(marker.Adornee) == 'Instance' and marker.Adornee:IsDescendantOf(workspace) then
			table.insert(MarkerList, marker.Name)
		end
	end

	MarkerList = removeDuplicates(MarkerList)

	table.sort(MarkerList, function(str1, str2) return str1 < str2 end);

	return MarkerList;
end;

local markersString = GetMarkersString()
Groups.Main:AddDropdown('MarkerTeleports', {
	Text = 'Teleport to marker',
	AllowNull = true,
	Compact = false,
	Values = markersString,
	Default = markersString[1] or 'No markers found',
	Callback = function(marker)
		if type(marker) ~= 'nil' and markers:FindFirstChild(marker) and markers[marker].Adornee:IsDescendantOf(workspace) and client.Character:IsDescendantOf(alive) then
			client.Character:PivotTo(markers[marker].Adornee:GetPivot())
		end
	end,
})

local function OnMarkersChanged()
	Options.MarkerTeleports:SetValues(GetMarkersString());
end;

markers.ChildAdded:Connect(OnMarkersChanged);
markers.ChildRemoved:Connect(OnMarkersChanged);

Groups.Main:AddButton('Refresh markers', function()
	Options.MarkerTeleports:SetValues(GetMarkersString());
end)

Groups.Main:AddToggle('AutoKeysDefense', { Text = 'Auto press keys', Default = false, Tooltip = 'Auto presses correct keys for defense training.' } )

Groups.Credits = Tabs.UISettings:AddRightGroupbox('Credits')

addRichText(Groups.Credits:AddLabel('<font color="#0bff7e">Goose Better</font> - script'))
addRichText(Groups.Credits:AddLabel('<font color="#3da5ff">wally & Inori</font> - ui library'))

Groups.UISettings = Tabs.UISettings:AddRightGroupbox('UI Settings')
Groups.UISettings:AddLabel('Changelogs:\n' .. metadata.message or 'no message found!', true)
Groups.UISettings:AddDivider()
Groups.UISettings:AddButton('Unload Script', function() pcall(shared._unload) end)
Groups.UISettings:AddButton('Copy Discord', function()
	if pcall(setclipboard, 'https://discord.gg/hSm6DyF6X7') then
		UI:Notify('Successfully copied discord link to your clipboard!', 5)
	end
end)

Groups.UISettings:AddLabel('Menu toggle'):AddKeyPicker('MenuToggle', { Default = 'Delete', NoUI = true })

UI.ToggleKeybind = Options.MenuToggle

themeManager:SetLibrary(UI)
themeManager:ApplyToGroupbox(Tabs.UISettings:AddLeftGroupbox('Themes'))

UI:Notify(string.format('Loaded script in %.4f second(s)!', tick() - start), 3)
if executor ~= 'Fluxus' and executor ~= 'Electron' and executor ~= 'Valyse' then
	UI:Notify(string.format('You may experience problems with the script/UI because you are using %s', executor), 30)
	task.wait()
	UI:Notify(string.format('Exploits this script works well with currently: Fluxus, Electron, and Valyse'), 30)
end
