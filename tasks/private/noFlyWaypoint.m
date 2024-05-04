function [pi,ti,ki] = noFlyWaypoint(wi,tw,kw,noflyc,noflyr,dr,wptype)
% This is a helper function for the dubinPathGeneration function. It
% calculates an alternate pose whenever a user-defined waypoint is inside a
% no fly zone.

% Copyright 2015-2023 The MathWorks, Inc.

% Distance to no fly zone
CWi = noflyc-wi;

safer = noflyr+dr;
% No fly zone waypoint addition
if CWi(1) == 0
    rx = [noflyc(1);noflyc(1)];
    ry = [noflyc(2)+safer;noflyc(2)-safer];
    xi = wi(1);
    yi = wi(2);
else
    mCW = CWi(2)/CWi(1);
    a = mCW^2+1;
    b = -2*noflyc(1)-2*mCW^2*noflyc(1);
    c = noflyc(1)^2+mCW^2*noflyc(1)^2-safer^2;
    rx = roots([a b c]);
    ry = mCW*(rx-noflyc(1))+noflyc(2);
    xi = (mCW*wi(1)+wi(2)+mCW*noflyc(1)-noflyc(2))/(2*mCW);
    yi = mCW*(xi-noflyc(1))+noflyc(2);
end
n1 = norm([rx(1) ry(1)]-[xi yi]);
n2 = norm([rx(2) ry(2)]-[xi yi]);
if n1<=n2
    pi = [rx(1) ry(1) 0];
else
    pi = [rx(2) ry(2) 0];
end
switch wptype
    case 'dubin'
        if CWi(1)==0
            ti = 0;
        else
            ti = mod(atand(mCW)+90+360,360);
        end
    case 'user'
        ti = tw;
    otherwise
        ti =tw;
end
% Check if turning radius is bigger and choose it
if safer>=1/kw
    ki= 1/safer;
else
    ki = 1/kw;
end