function [noflyflag,arcinfo] = checkArc(wp,noflyc,noflyr,z,noflyflag)
% This is a helper function for the dubinPathGeneration function. It checks
% crossings between dubin arcs and no-fly zones.

% Copyright 2015-2023 The MathWorks, Inc.

% Check for starting arc crossing no fly zones
arcinfo = [];
jj = 1;

for m = 1:size(noflyc,1)
    % Calculate vector from the arc center to the no fly zone
    C = noflyc(m,1:2)-wp(z,10:11);
    % Calculate the distance beween the centers
    R = norm(C);
    % Check that the distance is between the sum of the radii and
    % the absolute value of the difference (to make sure they are even
    % in range of each other).
    if R+2*eps(R)<abs(noflyr(m)+wp(z,9)) && R+2*eps(R)>abs(noflyr(m)-wp(z,9))
        % Calculate the angles at which the intersection between the
        % two circles occurs.
        rc = noflyr(m);
        rb = wp(z,9);
        if R>rb
            a = (rb^2-rc^2+R^2)/(2*R);
            dt = acosd(a/rb);
        elseif R<rb
            b = (rb^2-rc^2-R^2)/(2*R);
            dt = acosd((R+b)/rb);
        elseif R==rb+rc || R==abs(rb-rc)
            dt = 0;
        end
        th = atan2d(C(2),C(1));
        th1 = mod(th+dt+360,360);
        th2 = mod(th-dt+360,360);
        % Check that the intersection of the circles is within the arcs
        % sweeped by the dubin maneuver. A waypoint is only added if
        % that's the case.
        % To avoid confusion, the swept angles are rotated with respect to
        % the starting angle, and re-set to be between 0 and 360 deg.
        if wp(z,8)==-1 % Counterclockwise direction
            ddt = 360-wp(z,12);
            dt1 = mod(ddt+th1+360,360);
            dt2 = mod(ddt+th2+360,360);
            df = mod(ddt+wp(z,13),360);
        else
            ddt = 360-wp(z,13);
            dt1 = mod(ddt+th1+360,360);
            dt2 = mod(ddt+th2+360,360);
            df = mod(ddt+wp(z,12),360);
        end
        if (dt1>=0 && dt1 <=df) || (dt2>=0 && dt2<=df)
            noflyflag = true;
            arcinfo(jj,:) = [m th1 th2]; %#ok<AGROW>
            jj = jj+1;
        end
    end
end