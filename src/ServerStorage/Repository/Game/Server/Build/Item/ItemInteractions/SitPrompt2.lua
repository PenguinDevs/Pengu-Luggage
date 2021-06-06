local module = {}

return setmetatable(module, {
    __call = function(_, ...)
        require(script.Parent.SitPrompt)(...)
    end;
})