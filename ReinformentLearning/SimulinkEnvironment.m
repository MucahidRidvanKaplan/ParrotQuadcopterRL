


mdl = "asbQuadcopter";
open_system(mdl)

actionInfo = rlNumericSpec([2 1]);
actionInfo.Name = "Tau_pitch_roll";

open_system("flightController/Flight Controller/Attitude/" +...
    "RL Attitude Agent/observations")

observationInfo = rlNumericSpec([6 1],...
    LowerLimit=[-inf -inf -inf -inf -inf -inf]',...
    UpperLimit=[ inf  inf inf inf  inf inf]');
observationInfo.Name = "observations";
observationInfo.Description = "roll pitch vs.";

open_system("flightController/Flight Controller/Attitude/" +...
    "RL Attitude Agent/rewardFunction")


agentObj = rlDDPGAgent(observationInfo,actionInfo);
agentObj.SampleTime = Ts;


env = rlSimulinkEnv(mdl,"flightController/Flight Controller/Attitude/" +...
    "RL Attitude Agent/RL Agent",observationInfo,actionInfo);


return
env.ResetFcn = @(in)localResetFcn(in);


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