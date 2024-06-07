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
    exportgraphics(gcf,'DDPG_ActorCriticLayers.emf','ContentType','vector')
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
    exportgraphics(gcf,'PPO_ActorCriticLayers.emf','ContentType','vector')
end

env_rollPitch = rlSimulinkEnv(mdl,"flightController/Flight Controller/Attitude/" +...
    "Roll & Pitch RL Agent/RL Agent",observationInfo,pitch_roll_actionInfo);

validateEnvironment(env_rollPitch)

trainOpts = rlTrainingOptions;
FinalTrainingTime = 10;
trainOpts.MaxEpisodes = 500;
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
%% PID
mdl = "asbQuadcopter";

[env,obsInfo,actInfo] = localCreatePIDEnv(mdl);
numObs = prod(obsInfo.Dimension);
numAct = prod(actInfo.Dimension);
rng(0)
initialGain = single([0.013 0.01 0.01 0.01 -0.002 -0.0028]);
lowerLimits = single([0.001 0.001 0.001 0.001 -0.005 -0.005]); % Her bir kazanç için alt sınırlar
upperLimits = single([0.02 0.02 0.02 0.02 -0.001 -0.0012]);       % Her bir kazanç için üst sınırlar

actorNet = [
    featureInputLayer(numObs)
    fullyConnectedPIDLayer(initialGain,'ActOutLyr',lowerLimits,upperLimits)
    ];

actorNet = dlnetwork(actorNet);

actor = rlContinuousDeterministicActor(actorNet,obsInfo,actInfo);

criticNet = localCreateCriticNetwork(numObs,numAct);

critic1 = rlQValueFunction(dlnetwork(criticNet), ...
    obsInfo,actInfo,...
    ObservationInputNames='stateInLyr', ...
    ActionInputNames='actionInLyr');

critic2 = rlQValueFunction(dlnetwork(criticNet), ...
    obsInfo,actInfo,...
    ObservationInputNames='stateInLyr', ...
    ActionInputNames='actionInLyr');

critic = [critic1 critic2];

actorOpts = rlOptimizerOptions( ...
    LearnRate=1e-3, ...
    GradientThreshold=1);

criticOpts = rlOptimizerOptions( ...
    LearnRate=1e-3, ...
    GradientThreshold=1);

agentOpts = rlTD3AgentOptions(...
    SampleTime=Ts,...
    MiniBatchSize=1, ...
    ExperienceBufferLength=1e6,...
    ActorOptimizerOptions=actorOpts,...
    CriticOptimizerOptions=criticOpts);

agentOpts.TargetPolicySmoothModel.StandardDeviation = sqrt(0.1);

TD3_agentObj = rlTD3Agent(actor,critic,agentOpts);

maxepisodes = 1000;
maxsteps = ceil(10/Ts);
trainOpts = rlTrainingOptions(...
    MaxEpisodes=maxepisodes, ...
    MaxStepsPerEpisode=maxsteps, ...
    ScoreAveragingWindowLength=100, ...
    Verbose=false, ...
    Plots="training-progress",...
    StopTrainingCriteria="AverageReward",...
    StopTrainingValue=1500);

doTraining = true;

if doTraining
    % Train the agent.
    trainingStats = train(TD3_agentObj,env,trainOpts);
else

trainingStats = [];
agent = TD3_agentObj;

% Bloğun yolunu belirt
blockPath = "flightController/Flight Controller/Attitude/" +...
    "Roll & Pitch RL Agent/RL Agent";

for episode = 1:maxepisodes
    % Ortamı sıfırla
    observation = reset(env);
    totalReward = 0;
    % Bloğun portlarını elde et
    portHandles = get_param(blockPath, 'PortHandles');
    
    % Giriş portunu al (ilk giriş portu)
    observation = portHandles.Inport(1);
    
    for step = 1:maxsteps
        % Gözlemi uygun boyutta kontrol et
        if isrow(observation)
            observation = observation';
        end

        % Aksiyonu seç
        action = getAction(agent, {rand(obsInfo.Dimension)});
        
        % Ortamda aksiyonu uygula
        [nextObservation, reward, isDone, ~] = step(env);
        
        % Deneyimi sakla
        experience = rlExperience(observation, action, reward, nextObservation);
        agent = updateExperienceBuffer(agent, experience);
        
        % Ajanı güncelle
        agent = learnFromExperience(agent);
        
        % Ağırlıkları sınırla
        clippedParams = clipWeights(agent, lowerLimits, upperLimits);
        agent = setLearnableParameters(agent, clippedParams);
        
        % Toplam ödülü güncelle
        totalReward = totalReward + reward;
        
        % Durum güncelle
        observation = nextObservation;
        
        if isDone
            break;
        end
    end
    
    % Eğitim istatistiklerini kaydet
    trainingStats = [trainingStats; totalReward];
    
    % İlerlemeden bilgi ver
    fprintf('Episode: %d, Total Reward: %.2f\n', episode, totalReward);
end

    % Load pretrained agent for the example.
    % load("WaterTankPIDtd3.mat","agent")
end

% get PID Controller Coeff.
actor = getActor(TD3_agentObj);
parameters = getLearnableParameters(actor);

Pitch_Kp = parameters{1}(1)
Pitch_Ki = parameters{1}(2)
Pitch_Kd = parameters{1}(3)

Roll_Kp = parameters{1}(4)
Roll_Ki = parameters{1}(5)
Roll_Kd = parameters{1}(6)

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


function in = localResetFcn(in,mdl)

% % Randomize reference signal
% blk = sprintf([mdl '/Desired \nWater Level']);
% hRef = 10 + 4*(rand-0.5);
% in = setBlockParameter(in,blk,'Value',num2str(hRef));
% 
% % Randomize initial water height
% hInit = rand;
% blk = [mdl '/Water-Tank System/H'];
% in = setBlockParameter(in,blk,'InitialCondition',num2str(hInit));

end


function [env,obsInfo,actInfo] = localCreatePIDEnv(mdl)

% Define the observation specification obsInfo 
% and the action specification actInfo.
obsInfo = rlNumericSpec([6 1]);
obsInfo.Name = 'observations';
obsInfo.Description = 'integrated error and error';

actInfo = rlNumericSpec([2 1]);
actInfo.Name = 'PID outputs';

% Build the environment interface object.
env = rlSimulinkEnv(mdl,"flightController/Flight Controller/Attitude/" +...
    "Roll & Pitch RL Agent/RL Agent",obsInfo,actInfo);

% Set a cutom reset function that randomizes 
% the reference values for the model.
env.ResetFcn = @(in)localResetFcn(in,mdl);
end

function criticNet = localCreateCriticNetwork(numObs,numAct)
statePath = [
    featureInputLayer(numObs,Name='stateInLyr')
    fullyConnectedLayer(32,Name='fc1')
    ];

actionPath = [
    featureInputLayer(numAct,Name='actionInLyr')
    fullyConnectedLayer(32,Name='fc2')
    ];

commonPath = [
    concatenationLayer(1,2,Name='concat')
    reluLayer
    fullyConnectedLayer(32)
    reluLayer
    fullyConnectedLayer(1,Name='qvalOutLyr')
    ];

criticNet = layerGraph();
criticNet = addLayers(criticNet,statePath);
criticNet = addLayers(criticNet,actionPath);
criticNet = addLayers(criticNet,commonPath);

criticNet = connectLayers(criticNet,'fc1','concat/in1');
criticNet = connectLayers(criticNet,'fc2','concat/in2');
end

function clippedParams = clipWeights(agent, lowerLimit, upperLimit)
params = getLearnableParameters(agent);
for i = 1:length(params)
    params{i}.Value = max(min(params{i}.Values, upperLimit(i)), lowerLimit(i));
end
clippedParams = params;
% agent = setLearnableParameters(agent, params);

end