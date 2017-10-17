local world;

local load = function(w)
	world = w;
end

local new = function(x, y, w, h, mode)
	local box = {};
	box.body = love.physics.newBody(world, x, y, mode or "dynamic");
	box.shape = love.physics.newRectangleShape(w, h);
	box.fixture = love.physics.newFixture(box.body, box.shape);
	box.w = w;
	box.h = h;
	box.r = math.random(31, 200);
	box.g = math.random(31, 200);
	box.b = math.random(31, 200);
	return box;
end

return {
	load = load;
	new = new;
}