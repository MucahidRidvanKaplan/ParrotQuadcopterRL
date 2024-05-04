function tr = plotWaypoint(ax,wp,noflyc,noflyr)
% This function plots the dubin path trajectory and no fly zones based on a
% waypoint matrix that is created by the function dubinPathGeneration.

% Copyright 2015-2023 The MathWorks, Inc.

% Plotting
hold(ax,'on');
tr = [];
ddeg = 0.5;

% Determine heading size
dx = max(wp(:,1))-min(wp(:,1));
dy = max(wp(:,2))-min(wp(:,2));
dh = 0.025*(dx+dy);

for k = 1:size(wp,1)
    switch wp(k,4)
        case 1 %arc
            psif = wp(k,13);
            thf = wp(k,12);
            rf = wp(k,9);
            df = wp(k,8);
            of = wp(k,10:11);
            while abs(thf-psif)>ddeg
                oo = of + [rf*cosd(thf) rf*sind(thf)];
                tr = [tr;oo]; %#ok<*AGROW> 
                thf = mod(atan2d(sind(thf-ddeg*df),cosd(thf-ddeg*df))+360,360);
            end
            % Plot waypoints and arc centers
            plot(ax,of(1),of(2),'oc',...
                wp(k,1),wp(k,2),'kx');
        case 2 % line
            tr = [tr;wp(k,1:2);wp(k+1,1:2)];
            % Plot waypoints
            plot(ax,wp(k:k+1,1),wp(k:k+1,2),'kx');
        case 3 % final waypoint
            plot(ax,wp(k,1),wp(k,2),'kx');
    end
    if wp(k,5)~=3 % Plot poses for waypoints
        plot(ax,[wp(k,1) wp(k,1)+dh*cosd(wp(k,6))],[wp(k,2) wp(k,2)+dh*sind(wp(k,6))],'b');
    end
end
% Plot trajectory
plot(ax,tr(:,1),tr(:,2),'r');
% Plot no-fly zones
th = 0:ddeg:360;
for k = 1:size(noflyc,1)
    plot(ax,noflyc(k,1)+noflyr(k)*cosd(th),noflyc(k,2)+noflyr(k)*sind(th),'g');    
end
axis equal
grid on
hold(ax,'off');