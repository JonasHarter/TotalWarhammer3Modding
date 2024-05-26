local aucm = core:get_static_object("aucm");

function aucm:shuffleTable(tbl)
	for i = #tbl, 2, -1 do
		local j = cm:random_number(i);
		tbl[i], tbl[j] = tbl[j], tbl[i];
	end
	return tbl;
end

function aucm:getTableKeys(tbl)
	local keys = {};
	for key, _ in pairs(tbl) do
		table.insert(keys, key);
	end
	return keys;
end

function aucm:log(txt)
	if aucm:getConfigEnableLogging() then
		out("[kafka][aucm] " .. txt)
	end
end