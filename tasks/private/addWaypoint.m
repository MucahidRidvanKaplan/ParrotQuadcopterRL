function wp = addWaypoint(wp,wi,ti,ki,di,idxn,noflyc,noflyr,dr)
% This is a helper function for the dubinPathGeneration function. It takes
% an intermediate waypoint wi and its characteristics and recalculates
% previous and next dubin paths.

% Copyright 2015-2023 The MathWorks, Inc.

wp = [wp;zeros(3,13)];
wp(idxn+3:end,:) = wp(idxn:end-3,:);

% Check that the intermediate waypoint is not inside a no fly zone
wicheck = [];
CWi = zeros(size(noflyc));
dist = zeros(size(noflyr));

% For each of the no fly zones that are violated, the distance to each
% no-fly zone center is calculated.
for m = 1:size(noflyc,1)
    CWi(m,:) = noflyc(m,:)-wi;
    dist(m) = norm(CWi(m,:));
    if dist(m)<=noflyr(m)
        wicheck = [wicheck; dist(m)+noflyr(m)+dr(m) m]; %#ok<AGROW>
    end
end

% Order the distances and then calculate the position of the intermediate
% point and heading depending on which distance is closer to the original
% intermediate waypoint.
if ~isempty(wicheck)
    wicheck = sortrows(wicheck);
    m = wicheck(1,2);
    uCwi = CWi(m,:)/dist(m);
    wi = wi + uCwi*(dist(m)+noflyr(m)+dr(m));
    ki = 1/(noflyr(m)+dr(m));
    rotCWi = angle2dcm(di*pi/2,0,0)*uCwi';
    ti = atan2d(rotCWi(2),rotCWi(1));
end

% Map intermediate waypoint
wp(idxn+2,1:3) = wi;
wp(idxn+2,6) = ti;
wp(idxn+2,7) = ki;
wp(idxn+2,8) = di;
wp(idxn+2,9) = 1/ki;
wp(idxn+2,5) = 2;
wp(idxn+2,4) = 1;

% Calculate dubin path for previous waypoint to intermediate
% no-fly zone waypoint.
[Tn,Tx,psio,phiex,phien,psif,osx,osy,ofx,ofy] = dubinPath(wp(idxn-1,1:3),wp(idxn-1,6),...
    wp(idxn-1,8),wp(idxn-1,7),wi,ti,di,ki);
wp(idxn-1,10:13) = [osx osy psio phiex];
wp(idxn,:) = [Tx 2 3 zeros(1,8)];
wp(idxn+1,:) = [Tn 1 3 0 0 wp(idxn+2,8) wp(idxn+2,9) ofx ofy phien psif];

% Calculate dubin path for intermediate no-fly zone waypoint to
% next waypoint.
[Tn,Tx,psio,phiex,phien,psif,osx,osy,ofx,ofy] = dubinPath(wi,ti,...
    di,ki,wp(idxn+5,1:3),wp(idxn+5,6),wp(idxn+5,8),wp(idxn+5,7));
wp(idxn+2,10:13) = [osx osy psio phiex];
wp(idxn+3,:) = [Tx 2 3 zeros(1,8)];
wp(idxn+4,:) = [Tn 1 3 0 0 wp(idxn+5,8) wp(idxn+5,9) ofx ofy phien psif];