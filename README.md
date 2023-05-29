# Raycast Suspension Wheel

A (mostly) easy-to-use ROBLOX module that allows for wheels with raycast suspension instead of the standard physics-based wheels

## How to use 🏁

### Installation Guide 🔧

To use this module you will need to copy the source code and place it into a module script. Then put this in your project, you will then need to create a chassis and some wheel parts. Once that is done, ensure that each wheel has its own `Attachment`, `VectorForce`, and `Weld` objects, name these `Attachment`, `VectorForce`, and `Weld` respectively. There is one more required step before using the module. Be sure that each wheel has these 5 attributes `SuspensionDamping : number`, `SuspensionHeight : number`, `SuspensionSpring : number`, `Debug : boolean`, and `RollingResistance : number` (please note the colon followed by the type is just so you know what type of attribute to make, it's means nothing more than that). Another thing to note is that the horizontal wheel friction is controlled by custom physical properties **ENABLE CUUSTOM PHYSICAL PROPERTIES OR YOU WILL GET CONSOLE ERRORS** (the perfered value is 1 so the wheel doesn't slip on small hills) Once done you may finally use the module!

### Scripting 💻

This module is so easy to use it only requires that you call two functions from the class, those being `.new(VehicleModel : Model, Model : Part)`, to create the wheel, and `:Update()` to update the wheel physics.

**If the wheels are tuned correctly everything should be working at this point** 

Example:
```lua
local RunService  = game:GetService("RunService")
local WheelModule = require(script.Parent:WaitForChild("WheelModule"))

local VehicleModule = {}
VehicleModule.__index = VehicleModule

function VehicleModule.new(Model : Model)
	local self = setmetatable({}, VehicleModule)
	
	self.Model  = Model
	self.Wheels = {}
	
	self:GetWheels()
	
	self.Model.PrimaryPart:SetNetworkOwner(nil)
	RunService.Heartbeat:Connect(function() self:Update() end)
	
	return self
end

function VehicleModule:GetWheels()
	for _,Wheel in pairs(self.Model.Wheels:GetChildren()) do
		table.insert(self.Wheels, WheelModule.new(self.Model, Wheel))
	end
end

function VehicleModule:UpdateWheels()
	for _,Wheel in pairs(self.Wheels) do
		Wheel:Update()
	end
end

function VehicleModule:Update()
	self:UpdateWheels()
end

return VehicleModule
```

## Documentation 📚

`Wheel.new(VehicleModel : Model, Model : Part)`: Instantiates the wheel class using the provided `VehicleModel` and `Model` parameters.

`Wheel:Update()`: Recalculates the wheel's suspension and forces.
