local sv = require(script.Parent.Parent.etc.sv)
if sv.userInputService.TouchEnabled == false then require(script.pc) else require(script.mobile) end