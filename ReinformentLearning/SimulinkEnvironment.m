mdl = "asbQuadcopter";
% load_system(mdl)


%% Roll Pitch
action_number = 2;
LimitVector = [0.005 0.005]';
pitch_roll_actionInfo = rlNumericSpec([action_number 1],...
    LowerLimit = -LimitVector,...
    UpperLimit = LimitVector);
pitch_roll_actionInfo.Name = "Tau_pitch_roll";

% open_system("flightController/Flight Controller/Attitude/" +...
%     "Roll & Pitch RL Agent/observations")

state_number = 6;
LimitVector = [pi/6 pi/6 pi/6 pi/6 pi/4 pi/4]';
observationInfo = rlNumericSpec([state_number 1]);
observationInfo.Name = "observations";
observationInfo.Description = "roll pitch vs.";

% open_system("flightController/Flight Controller/Attitude/" +...
%     "Roll & Pitch RL Agent/rewardFunction")


initOpts = rlAgentInitializationOptions(NumHiddenUnit=64,UseRNN=true);

DDPGagentObj = rlDDPGAgent(observationInfo,pitch_roll_actionInfo,initOpts);
DDPGagentObj.SampleTime = Ts;
DDPGagentObj.AgentOptions.ActorOptimizerOptions.LearnRate = 0.01;

DDPG_actorNet = getModel(getActor(DDPGagentObj));
DDPG_criticNet = getModel(getCritic(DDPGagentObj));

figure("Position",[680 458 720 420]);
subplot(1,2,1);
plot(layerGraph(DDPG_actorNet));
title('DDPG Actor Net')
subplot(1,2,2);
plot(layerGraph(DDPG_criticNet));
title('DDPG Critic Net')
if 0
    exportgraphics(gcf,'DDPG_ActorCriticLayers.eps','ContentType','vector')
end

PPOagentObj = rlPPOAgent(observationInfo,pitch_roll_actionInfo,initOpts);
PPOagentObj.SampleTime = Ts;
PPOagentObj.AgentOptions.ActorOptimizerOptions.LearnRate = 0.01;

PPO_actorNet = getModel(getActor(PPOagentObj));
PPO_criticNet = getModel(getCritic(PPOagentObj));

figure("Position",[680 458 720 420]);
subplot(1,2,1);
plot(layerGraph(PPO_actorNet));
title('PPO Actor Net')
subplot(1,2,2);
plot(layerGraph(PPO_criticNet));
title('PPO Critic Net')
if 0
    exportgraphics(gcf,'PPO_ActorCriticLayers.eps','ContentType','vector')
end

env_rollPitch = rlSimulinkEnv(mdl,"flightController/Flight Controller/Attitude/" +...
    "Roll & Pitch RL Agent/RL Agent",observationInfo,pitch_roll_actionInfo);

validateEnvironment(env_rollPitch)

trainOpts = rlTrainingOptions;
FinalTrainingTime = 10;
trainOpts.MaxEpisodes = 2000;
trainOpts.MaxStepsPerEpisode = FinalTrainingTime/Ts;
trainOpts.StopTrainingCriteria = "AverageReward";
trainOpts.StopTrainingValue = 1500;
trainOpts.ScoreAveragingWindowLength = 10;
trainOpts.SaveAgentCriteria = "EpisodeReward";
trainOpts.SaveAgentValue = 1000;
trainOpts.SaveAgentDirectory = "savedAgents";
trainOpts.Verbose = true;
trainOpts.Plots = "training-progress";
trainOpts.StopOnError = 'on';

trainOpts.UseParallel = false;

answer = questdlg('Would you like training for RL?', ...
	'Training', ...
	'Yes','No','Yes');
% Handle response
switch answer
    case 'Yes'
        trainingInfo = train(PPOagentObj,env_rollPitch,trainOpts);
    case 'No'
        
end

return
% Retraining from remaining episode
% trainingInfo.EpisodeIndex(end)
trainingInfo.TrainingOptions.MaxEpisodes = 5000;
trainingInfo = train(PPOagentObj,env_rollPitch,trainingInfo);
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