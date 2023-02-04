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
}

local dir = {
    ct_fld = sv.replicatedStorage.Catalog,
    event = sv.replicatedStorage.Catalog.Remotes.RemoteEvent,
    func = sv.replicatedStorage.Catalog.Remotes.RemoteFunction,
}

return { dir,sv }