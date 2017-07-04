local folderPath = (...):match("(.-)[^%.]+$")

local Class = require(folderPath .. "Dependencies.class")
local Event = require(folderPath .. "Dependencies.signal")
local utils = require(folderPath .. "Dependencies.utils")

local debugging = false

HooIDebug = function()
	debugging = not debugging
end

local HooI = {
	ObjectType = "HooI";

	Canvas = require(folderPath .. "canvas");
	Widget = require(folderPath .. "widget");
	Button = require(folderPath .. "button");

	-- Constructor
	canvases = {};
	canvasId = 1;


	-- Functions

	-- Returns true if canvas was added.
	-- Returns false if addition failed or it was already added.
	addCanvas = function(self, newCanvas)
		if utils.typeOf(newCanvas, "Canvas") then
			-- If canvas was previously added. Place it accordingly.
			if newCanvas.id then
				if self.canvases[newCanvas.id] then
					return false
				else
					self.canvases[newCanvas.id] = newCanvas
					return true 
				end
			end

			-- Add a new canvas to the table
			self.canvases[self.canvasId] = newCanvas
			newCanvas.id = self.canvasId
			self.canvasId = self.canvasId + 1
			return true
		end
		return false
	end;

	-- Returns true if canvas was removed.
	-- Returns false if parameter is invalid or canvas couldn't be found.
	removeCanvas = function(self, canvas)
		if type(canvas) == "number" then
			return self:removeCanvasById(canvas)
		elseif utils.typeOf(canvas, "Canvas") then
			return self:removeCanvasByRef(canvas)
		end
		return false
	end;

	removeCanvasById = function(self, id)
		if self.canvases[id] then
			self.canvases[id] = nil
			return true
		end
		return false
	end;

	removeCanvasByRef = function(self, ref)
		for k, canvas in pairs(self.canvases) do
			if canvas == ref then
				self.canvases[k] = nil
				return true
			end
		end
		return false
	end;

	update = function(self, dt)
		local hUpdate = true
		local mouseX, mouseY = love.mouse.getPosition()
		for k, canvas in pairs(self.canvases) do
			if canvas:hoverUpdate(mouseX, mouseY, hUpdate) then
				hUpdate = false
			end
			
			canvas:update(dt)
		end
	end;

	draw = function(self)
		for k, canvas in pairs(self.canvases) do
			canvas:draw(debugging)
		end
	end;

	mousepressed = function(self, x, y, button)
		for k, canvas in pairs(self.canvases) do
			if canvas:click(x, y, button) then
				break
			end
		end
	end;

	mousereleased = function(self, x, y, button)
		for k, canvas in pairs(self.canvases) do
			canvas:clicked(x, y, button)
		end
	end;

	-- y is the relevant up / down
	wheelmoved = function(self, x, y)
		for k, canvas in pairs(self.canvases) do
			canvas:wheelmoved(x, y)
		end
	end;

	resize = function(self, w, h)
		for k, canvas in pairs(self.canvases) do
			canvas:resize(w, h)
		end
	end;
}

-- Overwrite to handle resolution changes.

local originalResize = love.resize
love.resize = function(w, h)
	HooI:resize(w, h)
	originalResize(w, h)
end

local originalWindowSetMode = love.window.setMode 
love.window.setMode = function(w, h, flags)
	local ow, oh = love.window.getMode()
	w = w or ow
	h = h or oh
	HooI:resize(w, h)
	originalWindowSetMode(w, h, flags)
end

return HooI
