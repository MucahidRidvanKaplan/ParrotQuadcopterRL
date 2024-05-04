function specifyVariantConfiguration
% SPECIFYVARIANTCONFIGURATION Helper function to set the visualization mode

% Copyright 2022-2023 The MathWorks, Inc.

indx = listdlg('PromptString',{'Select a Preconfigured Variant Configuration.','','Note: You can create any customized configuration by setting the variant control', 'variables to appropriate values.'},...
                            'SelectionMode','single', 'ListSize', [400,100],...
                            'ListString',{'Test default nonlinear model with SL3D visualization', 'Test linear model to design and debug',...
'Test simple nonlinear model and analyze', 'Simulate simple linear model for analysis', 'Interactive testing of nonlinear model with SL3D visualization'});
        
if indx == 1
    assignin('base','VSS_COMMAND', 0); % Signal Editor
    assignin('base','VSS_ENVIRONMENT', 0); % Constant
    assignin('base','VSS_SENSORS', 1); % Dynamics
    assignin('base','VSS_VEHICLE', 1); % Nonlinear Airframe
    assignin('base','VSS_VISUALIZATION', 3); % Simulink 3D
elseif indx == 2
    assignin('base','VSS_COMMAND', 0); % Signal Editor
    assignin('base','VSS_ENVIRONMENT', 1); % Variable
    assignin('base','VSS_SENSORS', 1); % Dynamics
    assignin('base','VSS_VEHICLE', 0); % Linear Airframe
    assignin('base','VSS_VISUALIZATION', 0); % Scopes
elseif indx == 3
    assignin('base','VSS_COMMAND', 0); % Signal Editor
    assignin('base','VSS_ENVIRONMENT', 0); % Constant
    assignin('base','VSS_SENSORS', 0); % Feedthrough
    assignin('base','VSS_VEHICLE', 1); % Nonlinear Airframe
    assignin('base','VSS_VISUALIZATION', 1); % Send values to workspace
elseif indx == 4
    assignin('base','VSS_COMMAND', 2); % Pre-saved data
    assignin('base','VSS_ENVIRONMENT', 0); % Constant
    assignin('base','VSS_SENSORS', 0); % Feedthrough
    assignin('base','VSS_VEHICLE', 0); % Linear Airframe
    assignin('base','VSS_VISUALIZATION', 1); % Send values to workspace
elseif indx == 5
    assignin('base','VSS_COMMAND', 1); % Joystick
    assignin('base','VSS_ENVIRONMENT', 1); % Variable
    assignin('base','VSS_SENSORS', 1); % Dynamics
    assignin('base','VSS_VEHICLE', 1); % Nonlinear Airframe
    assignin('base','VSS_VISUALIZATION', 3); % Simulink 3D
end