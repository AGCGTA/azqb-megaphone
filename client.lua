local QBCore = exports['qb-core']:GetCoreObject()
local filter = -1
local megaphoneProp = 0

local function awaitLoadAnimDict(dict)
  RequestAnimDict(dict)
  while not HasAnimDictLoaded(dict) do Wait(0) end
end

local function hasMegaphone()
  for _, item in pairs(QBCore.Functions.GetPlayerData().items) do
    if item.name == "megaphone" then
      return true
    end
  end
  return false
end

RegisterCommand("+megaphone", function()
  if not hasMegaphone() then return end
  exports["pma-voice"]:overrideProximityRange(100.0, true)
  TriggerServerEvent('azqb-megaphone:submix', true)
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  awaitLoadAnimDict("molly@megaphone")
  TaskPlayAnim(ped, "molly@megaphone", "megaphone_clip", 4.0, 4.0, -1, 49, 0, false, false, false)
  megaphoneProp = CreateObject(`prop_megaphone_01`, pos.x, pos.y, pos.z, true, true, true)
  AttachEntityToEntity(megaphoneProp, ped, GetPedBoneIndex(ped, 28422), 0.0500, 0.0540, -0.0060, -71.8855, -13.0889, -16.0242, true, true, false, true, 1, true)
end, false)

RegisterCommand("-megaphone", function()
  exports["pma-voice"]:clearProximityOverride()
  StopAnimTask(PlayerPedId(), "molly@megaphone", "megaphone_clip", 4.0)
  ClearPedTasks(PlayerPedId())
  if megaphoneProp ~= 0 then
    DeleteObject(megaphoneProp)
    megaphoneProp = 0
  end
  
  TriggerServerEvent('azqb-megaphone:submix', false)
end, false)

RegisterKeyMapping('+megaphone', 'Use megaphone', '', '')

CreateThread(function()
  filter = CreateAudioSubmix("megaphone")
  SetAudioSubmixEffectRadioFx(filter, 0)
  SetAudioSubmixEffectParamInt(filter, 0, GetHashKey("default"), 0)
  SetAudioSubmixEffectParamInt(filter, 0, GetHashKey("freq_low"), 0.0)
  SetAudioSubmixEffectParamInt(filter, 0, GetHashKey("freq_hi"), 10000.0)
  SetAudioSubmixEffectParamInt(filter, 0, GetHashKey("rm_mod_freq"), 300.0)
  SetAudioSubmixEffectParamInt(filter, 0, GetHashKey("rm_mix"), 0.2)
  SetAudioSubmixEffectParamInt(filter, 0, GetHashKey("fudge"), 0.0)
  SetAudioSubmixEffectParamInt(filter, 0, GetHashKey("o_freq_lo"), 200.0)
  SetAudioSubmixEffectParamInt(filter, 0, GetHashKey("o_freq_hi"), 5000.0)
  AddAudioSubmixOutput(filter, 0)
end)

RegisterNetEvent('azqb-megaphone:updateSubmix', function(state, source)
  if state then
      MumbleSetSubmixForServerId(source, filter)
  else
      MumbleSetSubmixForServerId(source, -1)
  end
end)