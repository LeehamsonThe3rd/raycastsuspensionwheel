local Wheel = {}
Wheel.__index = Wheel

local UP = Vector3.yAxis
local ZERO = Vector3.zero
local RAYPARAMS = RaycastParams.new()

function Wheel.new(Component : Part, Chassis : Part)
	local self = {}

	self.Chassis = Chassis
	self.Component = Component
	self.Force = Component:FindFirstChildOfClass("VectorForce")

	self.Offset = self.Component.Weld.C0
	self.WheelRadius = self.Component.Size.Y/2

	self.SuspensionRay = nil
	self.SpringLength = 0
	self.StiffnessForce = 0
	self.DamperForce = 0
	self.SuspensionLength = 0
	self.Velocity = 0
	self.XForce = 0
	self.ZForce = 0
	self.GravityForce = 0
	self.SuspensionForce = ZERO
	self.RotationOnlyWheelDirectionCFrame = ZERO

	RAYPARAMS.FilterDescendantsInstances = {self.Chassis}

	setmetatable(self, Wheel)	
	return self
end

function Wheel:Update(DeltaTime)
	local SuspensionRayOrigin = self.Chassis.CFrame:ToWorldSpace(self.Offset:Inverse()).Position
	local SuspensionRayDirection = -self.Chassis.CFrame.UpVector*(self.Component:GetAttribute("MaxSuspensionLength"))

	self.SuspensionRay = workspace:Raycast(
		SuspensionRayOrigin, 
		SuspensionRayDirection, 
		RAYPARAMS
	)

	local DeltaTime = math.clamp(DeltaTime,0.00000000001,math.huge)

	if self.SuspensionRay then 
		self.SpringLength = math.clamp(self.SuspensionRay.Distance - self.WheelRadius, 0, self.Component:GetAttribute("MaxSuspensionLength"))
		self.StiffnessForce = self.Component:GetAttribute("SpringStiffness") * (self.Component:GetAttribute("MaxSuspensionLength") - self.SpringLength)
		self.DamperForce = self.Component:GetAttribute("DamperStiffness") * ((self.SuspensionLength-self.SpringLength)/DeltaTime)
		self.SuspensionForce = UP * (self.StiffnessForce+self.DamperForce) * self.Chassis:GetMass()

		self.RotationOnlyWheelDirectionCFrame = CFrame.lookAt(ZERO, self.Chassis.CFrame.LookVector, self.Chassis.CFrame.UpVector)

		self.Velocity = self.RotationOnlyWheelDirectionCFrame:VectorToObjectSpace(self.Chassis:GetVelocityAtPosition(self.SuspensionRay.Position))
		self.XForce = self.RotationOnlyWheelDirectionCFrame.RightVector * -self.Velocity.X * (self.Component:GetAttribute("WheelFriction")*self.Chassis:GetMass())
		self.ZForce = self.RotationOnlyWheelDirectionCFrame.LookVector * self.Velocity.Z * (self.Component:GetAttribute("WheelFriction")*self.Chassis:GetMass()/3)
		self.GravityForce = -workspace.Gravity * self.SuspensionRay.Normal * 100

		self.SuspensionLength = self.SpringLength
		self.Force.Force = self.SuspensionForce + self.XForce + self.ZForce + self.GravityForce

		if not self.Component:GetAttribute("SuspensionVisible") then return end
		self.Component.Weld.C1 = CFrame.new((-self.WheelRadius + self.SuspensionRay.Distance) * -UP)
	else
		self.SuspensionLength = self.Component:GetAttribute("MaxSuspensionLength")
		self.Force.Force = ZERO

		if not self.Component:GetAttribute("SuspensionVisible") then return end
		self.Component.Weld.C1 = CFrame.new((-self.WheelRadius + self.Component:GetAttribute("MaxSuspensionLength"))*-UP)
	end
end

return Wheel
