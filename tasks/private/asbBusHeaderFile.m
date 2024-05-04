function prop = asbBusHeaderFile(property, usePARROT)
% ASBBUSHEADERFILE Utility to determine header file location for quadcopter
% model. 

% Copyright 2017-2023 The MathWorks, Inc.

switch property
    case 'HeaderLocation'
        if usePARROT
            prop = fullfile(codertarget.parrot.internal.getSpPkgRootDir,'include','HAL.h');
        else
            prop = '';
        end
    case 'DataScope'
        if usePARROT
            prop = 'Imported';
        else
            prop = 'Auto';
        end
    otherwise
        error(message('aeroblks_demos_quad:asbquadcopter:unkownCategory'));
end
