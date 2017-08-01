require 'json'

MAIN_GAME = 0
REIGN_OF_GIANTS = 1
CAPY_DLC = 2

NO_DLC_TABLE = {REIGN_OF_GIANTS=false, CAPY_DLC=false}
ALL_DLC_TABLE = {REIGN_OF_GIANTS=true, CAPY_DLC = false}
DLC_LIST = {REIGN_OF_GIANTS, CAPY_DLC}

local __DLCEnabledTable = {}

function IsDLCEnabled(index)
    return __DLCEnabledTable[index] or false
end

function SetDLCEnabled(tbl)
	tbl = tbl or {}
	__DLCEnabledTable = tbl
end

local parameters = json.decode(GEN_PARAMETERS or {})
SetDLCEnabled(parameters.DLCEnabled)

print("DLC(RoG) enabled : ",IsDLCEnabled(REIGN_OF_GIANTS))
print("DLC(Shipwrecked) enabled : ",IsDLCEnabled(CAPY_DLC))