%% 04.06.2024
load trainingInfo_04062024.mat
plot(trainingInfo)
figure;
plot(trainingInfo.TotalAgentSteps, trainingInfo.EpisodeReward); 
hold on; grid on;
plot(trainingInfo.TotalAgentSteps, trainingInfo.AverageReward)
plot(trainingInfo.TotalAgentSteps, trainingInfo.EpisodeQ0)
title('Episode reward for ParrotQuadcopter with rlPPOAgent')
xlabel('Steps')
ylabel('Episode Reward')
legend("EpisodeReward","AverageReward","EpisodeQ0","Location","best")

if 0
    exportgraphics(gcf,'trainingInfo_04062024.eps','ContentType','vector')
    exportgraphics(gcf,'trainingInfo_04062024.emf','ContentType','vector')
end

%% 03.06.2024
load trainingInfo_03062024.mat
plot(trainingInfo)
figure;
plot(trainingInfo.TotalAgentSteps, trainingInfo.EpisodeReward); 
hold on; grid on;
plot(trainingInfo.TotalAgentSteps, trainingInfo.AverageReward)
plot(trainingInfo.TotalAgentSteps, trainingInfo.EpisodeQ0)
title('Episode reward for ParrotQuadcopter with rlPPOAgent')
xlabel('Steps')
ylabel('Episode Reward')
legend("EpisodeReward","AverageReward","EpisodeQ0","Location","best")

if 0
    exportgraphics(gcf,'trainingInfo_03062024.eps','ContentType','vector')
    exportgraphics(gcf,'trainingInfo_03062024.emf','ContentType','vector')
end

%% 29.05.2024
load trainingInfo_29052024.mat
plot(trainingInfo)
figure;
plot(trainingInfo.TotalAgentSteps, trainingInfo.EpisodeReward); 
hold on; grid on;
plot(trainingInfo.TotalAgentSteps, trainingInfo.AverageReward)
plot(trainingInfo.TotalAgentSteps, trainingInfo.EpisodeQ0)
title('Episode reward for ParrotQuadcopter with rlPPOAgent')
xlabel('Steps')
ylabel('Episode Reward')
legend("EpisodeReward","AverageReward","EpisodeQ0","Location","best")

if 1
    exportgraphics(gcf,'trainingInfo_29052024.eps','ContentType','vector')
    exportgraphics(gcf,'trainingInfo_29052024.emf','ContentType','vector')
end

%% 28.05.2024
load trainingInfo_28052024.mat
plot(trainingInfo)
figure;
plot(trainingInfo.TotalAgentSteps, trainingInfo.EpisodeReward); 
hold on; grid on;
plot(trainingInfo.TotalAgentSteps, trainingInfo.AverageReward)
plot(trainingInfo.TotalAgentSteps, trainingInfo.EpisodeQ0)
title('Episode reward for ParrotQuadcopter with rlPPOAgent')
xlabel('Steps')
ylabel('Episode Reward')
legend("EpisodeReward","AverageReward","EpisodeQ0","Location","best")

if 1
    exportgraphics(gcf,'trainingInfo_28052024.eps','ContentType','vector')
    exportgraphics(gcf,'trainingInfo_28052024.emf','ContentType','vector')
end

%% 27.05.2024
load trainingInfo_27052024.mat
plot(trainingInfo)
figure;
plot(trainingInfo.TotalAgentSteps, trainingInfo.EpisodeReward); 
hold on; grid on;
plot(trainingInfo.TotalAgentSteps, trainingInfo.AverageReward)
plot(trainingInfo.TotalAgentSteps, trainingInfo.EpisodeQ0)
title('Episode reward for ParrotQuadcopter with rlDDPGAgent')
xlabel('Steps')
ylabel('Episode Reward')
legend("EpisodeReward","AverageReward","EpisodeQ0","Location","best")

if 0
    exportgraphics(gcf,'trainingInfo_27052024.eps','ContentType','vector')
    exportgraphics(gcf,'trainingInfo_27052024.emf','ContentType','vector')
end