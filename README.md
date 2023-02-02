#Currently Broken

# Raycast Suspension Wheel

An easy-to--use ROBLOX module that allows for wheels with raycast suspension instead of the standard physics-based wheels

[![IMAGE ALT TEXT](http://img.youtube.com/vi/1xAgwgzFBus/0.jpg)](http://www.youtube.com/watch?v=1xAgwgzFBus "The WHEEL (and suspension...)")

My video on it: https://www.youtube.com/watch?v=1xAgwgzFBus

## How to use 🏁

### Installation Guide 🔧

To use this module you will need to copy the source code and place it into a module script. Then put this in your project, you will then need to create a chassis and some wheel parts. Once that is done, ensure that each wheel has its own `Attachment`, `VectorForce`, and `Motor6D` objects, name these `Attachment`, `Force`, and `Weld` respectively. There is one more required step before using the module. Be sure that each wheel has these 5 attributes `DamperStiffness : number`, `MaxSuspensionLength : number`, `SpringStiffness : number`, `SuspensionVisible : boolean`, and `WheelFriction : number` (please note the colon followed by the type is just so you know what type of attribute to make, it's means nothing more than that). Once done you may finally use the module!

### Scripting 💻

This module is so easy to use it only requires that you call two functions from the class, those being `.new(Wheel : Part, Chassis : Part)`, to create the wheel, and `:Update(DeltaTime : number)` to update the wheel physics.

**If the wheels are tuned correctly everything should be working at this point** 

Example:
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Wheel = require(ReplicatedStorage.Components.Wheel)

local Wheel1 = Wheel.new(script.Parent.wheel1, script.Parent)
local Wheel2 = Wheel.new(script.Parent.wheel2, script.Parent)
local Wheel3 = Wheel.new(script.Parent.wheel3, script.Parent)
local Wheel4 = Wheel.new(script.Parent.wheel4, script.Parent)

RunService.Heartbeat:Connect(function(dt)
	Wheel1:Update(dt)
	Wheel2:Update(dt)
	Wheel3:Update(dt)
	Wheel4:Update(dt)
end)

```

## Documentation 📚

`Wheel.new(Wheel : Part, Chassis : Part)`: Instantiates the wheel class using the provided `Wheel` and `Chassis` parameters.

`Wheel:Update(DeltaTime : number)`: Recalculates the wheel's suspension and forces using the provided `DeltaTime` parameter.
