local sv = require(script.etc.sv)
if sv.userInputService.TouchEnabled == false then require(script.pc) else require(script.mobile) end