mdl = "asbQuadcopter";
% open_system(mdl)


%% Roll Pitch
action_number = 2;
LimitVector = [5*1e-3 5*1e-3]';
pitch_roll_actionInfo = rlNumericSpec([action_number 1],...
    LowerLimit = -LimitVector,...
    UpperLimit = LimitVector);
pitch_roll_actionInfo.Name = "Tau_pitch_roll";

% open_system("flightController/Flight Controller/Attitude/" +...
%     "Roll & Pitch RL Agent/observations")

state_number = 6;
LimitVector = [pi pi pi pi pi/4 pi/4]';
observationInfo = rlNumericSpec([state_number 1],...
    LowerLimit = -LimitVector,...
    UpperLimit = LimitVector);
observationInfo.Name = "observations";
observationInfo.Description = "roll pitch vs.";

% open_system("flightController/Flight Controller/Attitude/" +...
%     "Roll & Pitch RL Agent/rewardFunction")


initOpts = rlAgentInitializationOptions(NumHiddenUnit=2,UseRNN=true);
DDPGagentObj = rlDDPGAgent(observationInfo,pitch_roll_actionInfo,initOpts);
DDPGagentObj.SampleTime = Ts;

PPOagentObj = rlPPOAgent(observationInfo,pitch_roll_actionInfo,initOpts);
PPOagentObj.SampleTime = Ts;


env_rollPitch = rlSimulinkEnv(mdl,"flightController/Flight Controller/Attitude/" +...
    "Roll & Pitch RL Agent/RL Agent",observationInfo,pitch_roll_actionInfo);

validateEnvironment(env_rollPitch)
return

%% Yaw
yaw_actionInfo = rlNumericSpec([1 1]);
yaw_actionInfo.Name = "Tau_yaw";

% open_system("flightController/Flight Controller/Yaw/" +...
%     "Yaw RL Agent/observations")

state_number = 12;
LimitVector = [100 100 100 pi pi pi 2 2 2 pi pi pi]';
observationInfo = rlNumericSpec([state_number 1],...
    LowerLimit = -LimitVector,...
    UpperLimit = LimitVector);
observationInfo.Name = "observations";
observationInfo.Description = "roll pitch vs.";

% open_system("flightController/Flight Controller/Yaw/" +...
%     "Yaw RL Agent/rewardFunction")


initOpts = rlAgentInitializationOptions(NumHiddenUnit=2,UseRNN=true);
DDPGagent2Obj = rlDDPGAgent(observationInfo,yaw_actionInfo,initOpts);
DDPGagent2Obj.SampleTime = Ts;

PPOagent2Obj = rlPPOAgent(observationInfo,yaw_actionInfo,initOpts);
PPOagent2Obj.SampleTime = Ts;


env_yaw = rlSimulinkEnv(mdl,"flightController/Flight Controller/Yaw/" +...
    "Yaw RL Agent/RL Agent",observationInfo,yaw_actionInfo);

validateEnvironment(env_yaw)

%%
env_rollPitch.ResetFcn = @(in)localResetFcn(in);


function in = localResetFcn(in)

% Randomize reference signal
h = 3*randn + 10;
while h <= 0 || h >= 20
    h = 3*randn + 10;
end
in = setBlockParameter(in, ...
    "rlwatertank/Desired \nWater Level", ...
    Value=num2str(h));

% Randomize initial height
h = 3*randn + 10;
while h <= 0 || h >= 20
    h = 3*randn + 10;
end
in = setBlockParameter(in, ...
    "rlwatertank/Water-Tank System/H", ...
    InitialCondition=num2str(h));

end