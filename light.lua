local RADIUS = 500;
local radial_data = love.image.newImageData(RADIUS*2, RADIUS*2);
local width, height, canvas, circle;

do
	local canvas = love.graphics.newCanvas(width, height);
	radial_data:mapPixel(function(x, y, r, g, b, a)
		local dx = RADIUS - x;
		local dy = RADIUS - y;
		local dist = (dx*dx + dy*dy)^0.5;
		local val = math.max(RADIUS - dist, 0) / RADIUS;
		return 255, 255, 255, val*255;
	end);
	circle = love.graphics.newImage(radial_data);
end

local new = function(x, y, r, g, b)
	return {
		x = x;
		y = y;
		r = r;
		g = g;
		b = b;
	}
end

local inside = function(light, boxes)
	local x = light.x;
	local y = light.y;
	for i = 1, #boxes do
		local box = boxes[i];
		local lx, ly = box.body:getLocalPoint(x, y);
		if math.abs(lx) < box.w/2 and math.abs(ly) < box.h/2 then
			return box;
		end
	end
	return false;
end

local image = function()
	return circle;
end

return {
	image = image;
	inside = inside;
	new = new;
}