local modulePath = (...):match("(.-)[^%.]+$")
local Class = require(modulePath .. "Dependencies.class")
local utils = require(modulePath .. "Dependencies.utils")

Addons = {}

Addons.Callback = Class{
	ObjectType = "Callback";

	init = function(self, f, ...)
		self.f = f
		self.args = {...}

		return self
	end;

	__call = function(self, ...)
		if type(...) == "table" then
			for k, v in pairs(...) do
				table.insert(self.args, v)
			end
		else
			if ... then
				table.insert(self.args, v)
			end
		end
		self.f(unpack(self.args))
	end;
}

Addons.Hoverable = Class{
	ObjectType = "Hoverable";

	init = function(self, callbacks)
		self.hoverableData = {}
		self.hoverableData.bHovered = false;
		self.hoverableData.fBeginHover = callbacks.fBeginHover or function() print("fBeginHover no callback provided!", self) end;
		self.hoverableData.fEndHover = callbacks.fEndHover or function() print("fEndHover no callback provided!", self) end;

		return self
	end;

	exec_unhovered = function(self)
		if self.clickableData.bClick then
			self.clickableData.bClick = false 
		end
		
		self.hoverableData.bHovered = false 
		if self.hoverableData.fEndHover then
			self.hoverableData:fEndHover()
		end

		return true
	end;


	exec_hovered = function(self)
		self.hoverableData.bHovered = true
		if self.hoverableData.fBeginHover then
			self.hoverableData:fBeginHover()
		end

		return true
	end;
}

Addons.Clickable = Class{
	ObjectType = "Clickable";
	__includes = Addons.Hoverable;

	init = function(self, callbacks)
		Addons.Hoverable.init(self, callbacks)
		self.clickableData = {}
		self.clickableData.bClick = false
		self.clickableData.fClick = callbacks.fClick or function(self) print("fClick no callback provided!", self) end;
		self.clickableData.fClicked = callbacks.fClicked or function(self) print("fClicked no callback provided!", self) end;
		self.clickableData.fDisable = callbacks.fDisable or function(self) print("fDisable no callback provided!", self) end;
		self.clickableData.fEnable = callbacks.fEnable or function(self) print("fEnable no callback provided!", self) end;
		self.clickableData.disabled = false

		return self
	end;

	exec_enableClick = function(self)
		self.clickableData.disabled = false
		if self.clickableData.fEnable then
			self.clickableData:fEnable()
		end
	end;

	exec_disableClick = function(self)
		self.clickableData.disabled = true
		if self.clickableData.fDisable then
			self.clickableData:fDisable()
		end
	end;

	exec_click = function(self, x, y, button)
		if self.clickableData.fClick then
			if not self.clickableData.disabled then
				self.clickableData.bClick = true
				self.clickableData.fClick(x, y, button, self)
			end

			return true
		end
	end;

	exec_clicked = function(self, x, y, button)
		if self.clickableData.bClick then
			self.clickableData.bClick = false

			if self.clickableData.fClicked then
				if not self.clickableData.disabled then
					self.clickableData.fClicked(x, y, button, self)
				end

				return true
			end
		end
	end;
}

return Addons