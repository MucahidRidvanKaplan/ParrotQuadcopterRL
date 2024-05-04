function [wi,ti,ki,di,idxn] = noFlyArc(wp,C,noflyc,noflyr,dr,idx)
% This is a helper function for the dubinPathGeneration function. It
% calculates an intermediate waypoint whenever a dubin arc tajectory
% crosses a no-fly zone.

% Copyright 2015-2023 The MathWorks, Inc.

% Calculate safe radius
safer = noflyr+dr;

% Calculate intermediate waypoint and waypoint
% characteristics.
uC = C/norm(C);
wi = noflyc(1:2)+safer*uC;
wi = [wi 0];
ki = 1/(safer+norm(C));
di = wp(idx,8);
uCP = angle2dcm(di*pi/2,0,0)*[uC 0]';
ti = mod(atan2d(uCP(2),uCP(1))+360,360);

% Estimate the row location for the waypoint, considering
% that an arc can be either at the start or the end of a
% dubin path section.
if idx==1 % First arc for the first user defined waypoint
    idxn=idx+1;
else
    if wp(idx-1,4)==1 % Previous waypoint is an arc, therefore is the start arc for a waypoint
        idxn = idx;
    elseif wp(idx-1,4)==2 % Previous waypoint is a line, therefore the arc is the ending arc for the dubin path
        idxn = idx-1;
    end
end