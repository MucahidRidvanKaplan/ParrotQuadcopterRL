function isPARROTInstalled = isParrotSupportPkgInstalled()
% ASBISPARROTSUPPORTPKGINSTALLED Helper function to determine if the Parrot
% Support Package is installed. 

% Copyright 2017-2023 The MathWorks, Inc.

% Get list of installed support packages
installedSupportPackages = matlabshared.supportpkg.getInstalled;
isPARROTInstalled = false;

% Check if the PARROT support package is installed.
if ~isempty(installedSupportPackages)
    isPARROTInstalled = any(strcmpi('Simulink Support Package for PARROT Minidrones', ...
        {installedSupportPackages.Name}));
% Check if the file is in a sandbox/internal testing
else
    parrotDir = [];
    try
        parrotDir = codertarget.parrot.internal.getSpPkgRootDir;
    catch
    end
    if ~isempty(parrotDir)
        isPARROTInstalled = true;
    end
end