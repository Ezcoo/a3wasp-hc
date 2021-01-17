params ["_player", "_selectedGroupTemplate", "_position", "_direction"];

[_player, _selectedGroupTemplate, _position, _direction] spawn {
    params ["_player", "_selectedGroupTemplate", "_position", "_direction"];

    _isVehicle = true;

    _side = side _player;
    _sideID = _side Call WFCO_FNC_GetSideID;
    _unitGroup = createGroup [_side, true];
    {
            _c = missionNamespace getVariable _x;
            sleep (_c # QUERYUNITTIME);

            if (_x isKindOf "Man") then {
                _isVehicle = false;
                [_x, _unitGroup, _position, _sideID] Call WFCO_FNC_CreateUnit;
                [str _side,'UnitsCreated',1] Call WFCO_FNC_UpdateStatistics;
            } else {
                _vehicleArray = [[_position # 0, _position # 1, .5], _direction, _x, _unitGroup] call bis_fnc_spawnvehicle;
                _vehicle = _vehicleArray # 0;
                _vehicle setVectorUp surfaceNormal position _vehicle;
                _vehicle  spawn {_this allowDamage false; sleep 15; _this allowDamage true};
                _position = [_position, 30] call WFCO_fnc_getEmptyPosition;
                [str _side,'UnitsCreated',1] Call WFCO_FNC_UpdateStatistics;
                {
                    [_x, typeOf _x,_unitGroup,_position,_sideID] spawn WFCO_FNC_InitManUnit;

                    private _classLoadout = missionNamespace getVariable Format ['WF_%1ENGINEER', _side];
                    _x disableAI "RADIOPROTOCOL";
                    _x setUnitLoadout _classLoadout;
                    _x setUnitTrait ["Engineer",true];
                    [str _side,'UnitsCreated',1] Call WFCO_FNC_UpdateStatistics;
                } forEach crew _vehicle;

                _unitskin = -1;
                _type = typeOf _vehicle;
                _vehicleCoreArray = missionNamespace getVariable [_type, []];
                if((count _vehicleCoreArray) > 10) then { _unitskin = _vehicleCoreArray # 10 };
                [_vehicle, _sideID, false, true, true, _unitskin] call WFCO_FNC_InitVehicle;
                _vehicle allowCrewInImmobile true;
            _vehicle engineOn true
        }
    } forEach _selectedGroupTemplate;

    _unitGroup allowFleeing 0;
    _unitGroup setCombatMode "YELLOW";

    if (_isVehicle) then {
		_unitGroup setFormation "FILE";
		_unitGroup setBehaviour "COMBAT";
	} else {
		_unitGroup setBehaviour "AWARE";
	};
    _unitGroup setSpeedMode "FULL";
    _unitGroup enableAttack false;

    _unitGroup setVariable ["isHighCommandPurchased",true, true];
}