local modulePath = (...):match("(.-)[^%.]+$")
local Class = require(modulePath .. "Dependencies.class")
local utils = require(modulePath .. "Dependencies.utils")

local Widget = Class{
	ObjectType = "Widget";

	-- Values starting with p are percent based. 0 - 1
	-- drawables is a table of HooGraphics drawable objects
	-- functions is a table of functions that should be overwritten. The following functions are available:
	--		click     -> When the user presses a mouse button above the widget. Gets (x, y, button) as parameters. Return true if click is used.
	--		clicked   -> Same as click but is called when the mouse button is released. Return true if clicked is used.
	-- 		hovered   -> When the user hovers above the widget.
	--		unhovered -> When the mouse doesn't hover the widget anymore.
	--		resize 	  -> Called upon screen size change. (w, h) new width and height of the screen. The widget size will be adapted automatically.
	-- 		update 	  -> Update call per frame. parameters: (self, dt) no return
	init = function(self, px, py, pw, ph, drawables, functions)
		self.px = px or 0
		self.py = py or 0
		self.pw = pw or 0.1
		self.ph = ph or 0.1
		local windowX, windowY = love.window.getMode()
		self.x = self.px * windowX
		self.y = self.py * windowY
		self.w = self.pw * windowX
		self.h = self.ph * windowY
		self.debugColor = {math.random(0, 255), math.random(0, 255), math.random(0, 255)}
		self.drawQueue = love.graphics.newDrawQueue()

		if functions then
			for k, v in pairs(functions) do
				if type(v) == "function" then
					self[k] = v
				end
			end
		end

		if drawables then
			for k, v in pairs(drawables) do
				self:addDrawable(v)
			end
		end

		return self
	end;

	addDrawable = function(self, newDrawable)
		if utils.typeOf(newDrawable, "Drawable") then
			return self.drawQueue:add(newDrawable)
		end
		return false
	end;

	removeDrawable = function(self, drawable)
		if utils.typeOf(drawable, "Drawable") then
			return self.drawQueue:remove(drawable)
		end
	end;

	draw = function(self, debugging)
		love.graphics.push()
		love.graphics.translate(self.x, self.y)
		love.graphics.setScissor(self.x, self.y, self.w, self.h)
		
		self.drawQueue:draw()


		if debugging then
			love.graphics.setColor(self.debugColor)
			love.graphics.rectangle("fill", 0, 0, self.w, self.h)
			love.graphics.setColor(255, 255, 255)
		end

		love.graphics.setScissor()
		love.graphics.pop()
	end;

	exec_resize = function(self, w, h)

	end;
}

return Widget