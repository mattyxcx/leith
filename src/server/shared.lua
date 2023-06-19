local sv = {
    workspace = game:GetService("Workspace"),
	players = game:GetService("Players"),
	lighting = game:GetService("Lighting"),
	replicatedFirst = game:GetService("ReplicatedFirst"),
	replicatedStorage = game:GetService("ReplicatedStorage"),
	serverScriptService = game:GetService("ServerScriptService"),
	serverStorage = game:GetService("ServerStorage"),
	starterGui = game:GetService("StarterGui"),
	starterPack = game:GetService("StarterPack"),
	starterPlayer = game:GetService("StarterPlayer"),
	teams = game:GetService("Teams"),
	soundService = game:GetService("SoundService"),
	chat = game:GetService("Chat"),
	textChatService = game:GetService("TextChatService"),
	voiceChatService = game:GetService("VoiceChatService"),
	localizationService = game:GetService("LocalizationService"),
	testService = game:GetService("TestService"),
	textService = game:GetService("TextService"),
	tweenService = game:GetService("TweenService"),
	marketplaceService = game:GetService("MarketplaceService"),
	httpService = game:GetService("HttpService"),
	dataStoreService = game:GetService("DataStoreService"),
	runService = game:GetService("RunService"),
	userInputService = game:GetService("UserInputService"),
	insertService = game:GetService("InsertService"),
}

local dir = {
    ct_fld = sv.replicatedStorage.M.Catalog,
    an_fld = sv.replicatedStorage.M.Animations,
    ct_event = sv.replicatedStorage.M.Catalog.Remotes.RemoteEvent,
    ct_func = sv.replicatedStorage.M.Catalog.Remotes.RemoteFunction,
    an_event = sv.replicatedStorage.M.Animations.Remotes.RemoteEvent,
    an_func = sv.replicatedStorage.M.Animations.Remotes.RemoteFunction,
}

return { dir,sv }