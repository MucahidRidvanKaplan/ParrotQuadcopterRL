%% X position
figure;
plot(posref.time,posref.signals.values(:,1))
hold on; grid on;
plot(estim.time, estim.signals.values(:,1))
title('X Position');
xlabel('Time [s]'); ylabel('Position [m]');
%% Y position
figure;
plot(posref.time,posref.signals.values(:,2))
hold on; grid on;
plot(estim.time, estim.signals.values(:,2))
title('Y Position');
xlabel('Time [s]'); ylabel('Position [m]');
%% Z position
figure;
plot(posref.time,posref.signals.values(:,3))
hold on; grid on;
plot(estim.time, estim.signals.values(:,3))
title('Z Position');
xlabel('Time [s]'); ylabel('Altitude [m]');
%% Roll angle
figure;
plot(posref.time,posref.signals.values(:,8))
hold on; grid on;
plot(estim.time, estim.signals.values(:,6))
title('Roll Attitude');
xlabel('Time [s]'); ylabel('Angle [rad]');
%% Pitch angle
figure;
plot(posref.time,posref.signals.values(:,7))
hold on; grid on;
plot(estim.time, estim.signals.values(:,5))
title('Pitch Attitude');
xlabel('Time [s]'); ylabel('Angle [rad]');
%% Yaw angle
figure;
plot(posref.time,posref.signals.values(:,4))
hold on; grid on;
plot(estim.time, estim.signals.values(:,4))
title('Yaw Attitude'); 
xlabel('Time [s]'); ylabel('Angle [rad]');
%% XY Position
figure;
plot(posref.signals.values(:,1),posref.signals.values(:,2))
hold on; grid on;
plot(estim.signals.values(:,1), estim.signals.values(:,2))
title('XY Position');
xlabel('Time [s]'); ylabel('Position [m]');