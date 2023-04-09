local public = {}
local private = {}

exports('register', function(point, job, grade)
	for a, b in pairs(Config) do
		if type(b) == 'table' then
			if point[a] then
				for c, d in pairs(b) do
					if not point[a][c] then
						point[a][c] = d
					end
				end
			end
		elseif not point[a] then
			point[a] = b
		end
	end
	if point.action and point.action.xevent then -- xPlayer
		point.action.event = function(src, action)
			local xPlayer = ESX.GetPlayerFromId(src)
			if not job or job == xPlayer.job.name and grade <= xPlayer.job.grade then
				point.action.xevent(src, xPlayer, action)
			end
		end
	end
	local id = exports.points:register(point)
	if job then
		if not private[job] then
			private[job] = {}
		end
		grade = grade or 0
		if not private[job][grade] then
			private[job][grade] = {}
		end
		table.insert(private[job][grade], id)
	else
		table.insert(public, id)
	end
end)

local function toggle(src, job, show)
	if job and private[job.name] then
		for grade, points in pairs(private[job.name]) do
			if grade <= job.grade then
				for _, point in ipairs(points) do
					exports.points[show and 'show' or 'hide'](0, point, src)
				end
			end
		end
	end
end

AddEventHandler('esx:playerLoaded', function(src, xPlayer)
	for _, point in ipairs(public) do
		exports.points:show(point, src)
	end
	toggle(src, xPlayer.job, true)
end)

AddEventHandler('esx:setJob', function(src, job, _job)
	toggle(src, _job)
	toggle(src, job, true)
end)

AddEventHandler('esx:playerLogout', function(src)
	toggle(src, ESX.GetPlayerFromId(src).job)
end)