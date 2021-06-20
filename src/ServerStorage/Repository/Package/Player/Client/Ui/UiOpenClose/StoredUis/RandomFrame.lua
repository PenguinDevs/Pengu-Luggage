-- Example Ui

local module = {}

module.OPENED_ON_INIT = true

module.openDet = {
    pos = UDim2.new(0.5, 0, 0.5, 0);
    call = function()
        print("yes")
    end;

    touch = UDim2.new(0.25, 0, 0.5, 0);
}
module.closeDet = {
    pos = UDim2.new(0.5, 0, -0.5, 0);
    call = function()
        print("no")
    end;

    touch = UDim2.new(0.25, 0, -0.5, 0);
}

module.openEvents = {
    
}
module.closeEvents = {
    
}
module.triggerEvents = {
    workspace.Baseplate.Touched;
}

return module