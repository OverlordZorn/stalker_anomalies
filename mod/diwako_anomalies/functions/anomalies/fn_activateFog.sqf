/*
	Function: anomaly_fnc_activateElectra

	Description:
        Activates anomaly when something enters its activation range

    Parameters:
        _trg - the anomaly trigger that is being activated (default: objNull)
		_list - thisList given by the trigger (default: [])

    Returns:
        nothing

	Author:
	diwako 2017-12-11
*/
params[["_trg",objNull],["_list",[]]];

if(isNull _trg) exitWith {};
if(_trg getVariable ["anomaly_type",""] != "fog") exitWith {};

{
	if((_x isKindOf "Man") && {local _x}) then {
		if(!(toUpper(goggles _x) in ANOMALY_GAS_MASKS)) then {
			if(isPlayer _x) then {
				[] spawn {
					private _effect = [4];
					if(isNil "ANOMALY_BLUR_HANDLE") then {
						private _name = "DynamicBlur";
						private _priority = 400;
						ANOMALY_BLUR_HANDLE = ppEffectCreate [_name, _priority];
						while {
							ANOMALY_BLUR_HANDLE < 0
						} do {
							_priority = _priority + 1;
							ANOMALY_BLUR_HANDLE = ppEffectCreate [_name, _priority];
						};
						ANOMALY_BLUR_HANDLE ppEffectEnable true;
					};
					ANOMALY_BLUR_HANDLE ppEffectAdjust _effect;
					ANOMALY_BLUR_HANDLE ppEffectCommit 1;
					sleep 1;
					ANOMALY_BLUR_HANDLE ppEffectAdjust [0];
					ANOMALY_BLUR_HANDLE ppEffectCommit 10;
				};
			};
			if((cba_missiontime - 2.5) > (_x getVariable["anomaly_cough",-1])) then {
				// cough cough
				private _coughers = ["WoundedGuyA_02","WoundedGuyA_04","WoundedGuyA_05","WoundedGuyA_07","WoundedGuyA_08"];
				[{
					params["_unit"];
					[_unit, selectRandom _coughers] remoteExecCall ["say3d"];
				}, [_x], (random 2)] call CBA_fnc_waitAndExecute;
				_x setVariable["anomaly_cough",cba_missiontime];
			};
			if(!isNil "ace_medical_fnc_addDamageToUnit") then {
				// Ace medical is enabled
				private _dam = 1;
				if(isPlayer _x) then {
					_dam = (missionNamespace getVariable ["ace_medical_playerDamageThreshold", 1]) / 20;
				} else {
					_res = _x getVariable ["ace_medical_unitDamageThreshold", [1, 1, 1]];
					_dam = ((_res#0 + _res#1 + _res#2) / 3) / 6;
				};
				[_x, _dam, "body", "punch"] call ace_medical_fnc_addDamageToUnit;
			} else {
				// Ace medical is not enabled
				_dam = damage _x;
				_x setDamage (_dam + 0.05);
			};
		};
	};
	false
} count _list;
