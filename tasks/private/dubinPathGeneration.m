function wp = dubinPathGeneration(p,t,d,kk,noflyc,noflyr,dr)
% This function calculates a dubin path trajectory using a set of poses,
% and no-fly or restricted zones and characteristics.
% Inputs:
% p:        XYZ coordinates for the specific pose. For now all Z
%           coordinates should be 0. The analysis is only performed in
%           2D.
% t:        Aircraft orientation in degrees with respect to the X axis.
% d:        Turn direction for the specific pose. It can be either +1 for
%           clockwise or -1 for counter-clockwise.
% kk:       Turn curvature. Defined as 1/TurnRadius.
% noflyc:   No fly zones centers XYZ coordinates.
% noflyr:   No fly zones radii.
% dr:       No fly zones safety margin.
%
% Output:
% wp:       Waypoint matrix for the dubin path trajectory generation.
% Defined as follows:
% wp(1:3):  XYZ coordinates of the waypoint.
% wp(4):    Line type. Set 1 for 'arc' and 2 for 'straight line', 3 is for
%           final point.
% wp(5):    Waypoint type. Set 1 to 'user defined', 2 for 'no fly zones', 3
%           for 'dubin intermediate waypoint', 4 for final point. 
% wp(6):    t - Heading for specific waypoint pose. Does not apply for
%           Waypoint type 'dubin intermediate waypoint'.
% wp(7):    k - Curvature for specific waypoint pose. Does not apply for
%           Waypoint type 'dubin intermediate waypoint'.
% wp(8):    d - Direction for the specific waypoint pose. Does not apply
%           for Waypoint type 'dubin intermediate waypoint'. Turn direction
%           +1 for clockwise -1 for anticlockwise.
% wp(9):    Radius. Only applies to arc line types.
% wp(10:11): XY coordinates for the center for the arc line type.
% wp(12:13): Start, ending angle for the arc line type.
    
% Copyright 2015-2023 The MathWorks, Inc.

z = 1;

% Pre-allocate waypoint matrix
wp = zeros((size(p,1)-1)*3+1,13);

% Initialize the pose in the waypoint matrix
wp(z,:) = [p(1,:) 1 1 t(1) kk(1) d(1) 1/kk(1) zeros(1,4)];

% Calculate user entered waypoints
for k = 1:size(p,1)-1

    % Add the poses to the waypoint matrix
    wp(z+3,:) = [p(k+1,:) 1 1 t(k+1) kk(k+1) d(k+1) 1/kk(k+1) zeros(1,4)];
    
    % Check that both waypoints are not in the no fly zones
    for m = 1:size(noflyc,1)
        for n = z:3:z+3
            % Distance to no fly zone
            CWi = noflyc(m,:)-wp(n,1:3);
            dist = norm(CWi);
            if dist<=noflyr(m)
                % User waypoint is replaced for the closest waypoint
                % outside the no fly zone.
                [wi,ti,ki] = noFlyWaypoint(wp(n,1:3),wp(n,6),wp(n,7),noflyc(m,:),noflyr(m),dr(m),'user');
                wp(n,:)  = [wi 1 1 ti ki wp(n,8) 1/ki zeros(1,4)];
            end
        end        
    end
    % Create intermediate waypoints using dubin's
    [Tn,Tx,psio,phiex,phien,psif,osx,osy,ofx,ofy] = dubinPath(wp(z,1:3),wp(z,6),...
        wp(z,8),wp(z,7),wp(z+3,1:3),wp(z+3,6),wp(z+3,8),wp(z+3,7));
    
    % Map dubin path results to waypoint matrix
    wp(z,10:13) = [osx osy psio phiex];
    wp(z+1,:) = [Tx 2 3 zeros(1,8)];
    wp(z+2,:) = [Tn 1 3 0 0 wp(z+3,8) wp(z+3,9) ofx ofy phien psif];
    
    noflyflag = true;
    zadd = 1;
    while noflyflag
        noflyflag = false;
        
        % Check for starting arc crossing no fly zones
        [noflyflag,arcinfo] = checkArc(wp,noflyc,noflyr,z,noflyflag);
        
        if noflyflag
            % Check that if there are multiple no fly zones crossing the
            % arc, then use the one is closest to the initial waypoint.
            sortablearc(:,1) = arcinfo(:,1);
            sortablearc(:,2) = min(wp(z,12)-arcinfo(2:3),[],2);
            sortablearc = sortrows(sortablearc,2);
            m = sortablearc(1,1);
            C = noflyc(m,1:2)-wp(z,10:11);
            [wi,ti,ki,di,idxn] = noFlyArc(wp,C,noflyc(m,:),noflyr(m),dr(m),z);
            wp(z+1,7) = ki;
            wp(z+1,9) = 1/ki;
            wp = addWaypoint(wp,wi,ti,ki,di,idxn,noflyc,noflyr,dr);
            zadd = zadd+1;
            
            % No need to continue no fly zone analyses at this point,
            % therefore straight line and ending arc analyses are skipped.
            continue;
        end
        
        % Check for straight line path crossing no fly zones
        [noflyflag,lineinfo] = checkLine(wp,noflyc,noflyr,z,noflyflag);

        if noflyflag
            % Check that if there are multiple no fly zones crossing the
            % line, then use the one is closest to Tx.
            lineinfo = sortrows(lineinfo,2);
            m = lineinfo(1);
            % Calculate the new intermediate waypoint           
            [wi,ti,ki,di] = noFlyLine(wp(z+2,1:3),wp(z+1,1:3),noflyc(m,:),noflyr(m),dr(m));
            wp = addWaypoint(wp,wi,ti,ki,di,z+1,noflyc,noflyr,dr);
            zadd = zadd+1;
            
            % No need to continue no fly zone analyses at this point,
            % therefore straight line and ending arc analyses are skipped.
            continue;
        end
        
        % Check for ending arc crossing no fly zones
        [noflyflag,arcinfoe] = checkArc(wp,noflyc,noflyr,z+2,noflyflag);
        
        if noflyflag
            % Check that if there are multiple no fly zones crossing the
            % arc, then use the one is closest to the initial waypoint.
            sortablearce(:,1) = arcinfoe(:,1);
            sortablearce(:,2) = min(wp(z,12)-arcinfoe(2:3),[],2);
            sortablearce = sortrows(sortablearce,2);
            m = sortablearce(1,1);
            C = noflyc(m,1:2)-wp(z+2,10:11);
            [wi,ti,ki,di,idxn] = noFlyArc(wp,C,noflyc(m,:),noflyr(m),dr(m),z+2);
            wp(z+3,7) = ki;
            wp(z+3,9) = 1/ki;
            wp = addWaypoint(wp,wi,ti,ki,di,idxn,noflyc,noflyr,dr);
            zadd = zadd+1;
            
            % No need to continue no fly zone analyses at this point,
            % therefore straight line and ending arc analyses are skipped.
            continue;
        end
        % Increase waypoint index
        if zadd>1 && ~noflyflag
            z = z+3;
            noflyflag = true;
            zadd = zadd-1;
        end
    end
    % Increase waypoint index
    z = z+3;
end

% Add characteristics to the final waypoint
wp(end,4:5) = [3 4];
