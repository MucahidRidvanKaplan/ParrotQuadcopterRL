function usePARROT = useParrotSupportPkg()
% USEPARROTSUPPORTPKG Helper function to determine if the Parrot
% Support Package should be used. This is a private function not intended for
% direct use.

% Copyright 2018-2023 The MathWorks, Inc.

model = 'flightControlSystem';

isFCSLoaded = bdIsLoaded(model);
if ~isFCSLoaded
    try
        load_system(model);
    catch
        % For timing issue during BaT build where model only exists in internal 
        % directory and is not on the path
        usePARROT = false;
        return;
    end
end

hwBoard = get_param(model,'HardwareBoard');
    
usePARROT = isParrotSupportPkgInstalled() && contains(hwBoard, 'PARROT', 'IgnoreCase', true);
