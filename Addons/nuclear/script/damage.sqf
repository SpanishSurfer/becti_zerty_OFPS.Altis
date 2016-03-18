private ["_xpos", "_ypos", "_vehicles", "_units", "_airs", "_objects", "_distance", "_damage","_wave_radius", "_speed", "_vel", "_x"];

_xpos = _this select 0;
_ypos = _this select 1;

_wave_radius = radiation_radius * 1.5;

_vehicles = nearestobjects [[_xpos, _ypos , 0], ["Car", "Motorcycle", "Tank", "Air", "Ship"], radiation_radius * 1.5];
_objects = nearestobjects [[_xpos, _ypos, 0], [], _wave_radius];

sleep 4;
//Core Damage Area Destroy all in this radius
{
	  if ( _x iskindof "Static" || _x iskindof "Man" || _x iskindof "Car" || _x iskindof "Motorcycle" || _x iskindof "Tank" || _x iskindof "Ship" || _x iskindof "Air") then
	  {
		{_x setdammage 1} foreach (crew _x);
		_x setdammage 1;
	  };
} foreach ([_xpos, _ypos, 0] nearobjects ["All", 200]);
//Destroy all in wider radius ignore map structures
{
	if ( ! (_x isKindOf "House") ) then
    {
	  if ( _x iskindof "Static" || _x iskindof "Man" || _x iskindof "Car" || _x iskindof "Motorcycle" || _x iskindof "Tank" || _x iskindof "Ship" || _x iskindof "Air") then
	  {
		{_x setdammage 1} foreach (crew _x);
		_x setdammage 1;
	  };
	};
} foreach ([_xpos, _ypos, 0] nearobjects ["All", 800]);
//Blast wave
[_xpos, _ypos] execvm "Addons\nuclear\script\damage2.sqf"; 
//Destroy air units in main radius
_airs = nearestobjects [[_xpos, _ypos , 0], ["Air"], radiation_radius];
{
  _distance = [_xpos, _ypos, 0] distance _x;
  _dir = asin (((getpos _x select 1) - _ypos) / _distance);
  if ( getpos _x select 0 < _xpos ) then {_dir = 180 - _dir};
  _vel = velocity _x;
  _damage = 1 - _distance / radiation_radius;
  _damage = _damage * _damage;
  _speed = 4 * (_damage + random (_damage / 4));
  _speed = _speed * main_nuclear_blow_speed;
  _x setvelocity [(_vel select 0) + (_speed * cos _dir),
                  (_vel select 1) + (_speed * sin _dir),
                  _speed / 3];
  _x setdammage ((getdammage _x) + _damage);
} foreach _airs;
//EMP effects
{[_x] execvm "Addons\nuclear\script\electro_pulse.sqf"} foreach _vehicles;
//Destroy units in radius
{
if ( ! (_x isKindOf "House") ) then
    {
    if ( _x iskindof "Man" || _x iskindof "Car" || _x iskindof "Motorcycle" || _x iskindof "Tank" || _x iskindof "Ship" ) then
    {
      _distance = [_xpos, _ypos, 0] distance _x;
      _dir = asin (((getpos _x select 1) - _ypos) / _distance);
      if ( getpos _x select 0 < _xpos ) then {_dir = 180 - _dir};
      _vel = velocity _x;
      _damage = 1 - _distance / radiation_radius;
      _damage = _damage * _damage;
      _speed = _damage + random (_damage / 4);
      if ( _x iskindof "Man" ) then {_speed = _speed * 2} else {[_x, _speed * 4] execvm "Addons\nuclear\script\rotate.sqf"};
      _speed = _speed * main_nuclear_blow_speed;
      _x setvelocity [(_vel select 0) + (_speed * cos _dir),
                      (_vel select 1) + (_speed * sin _dir),
                      _speed / 3];
      _x setdammage ((getdammage _x) + _damage);
    }; 
}; 
} foreach _objects; 