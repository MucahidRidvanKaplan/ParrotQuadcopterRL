function [Tn,Tx,psio,phiex,phien,psif,osx,osy,ofx,ofy] = dubinPath(po,ts,do,ko,pf,tf,df,kf)
% This is a helper function for the dubinPathGeneration function. It
% calculates the dubin path waypoints based on 2 specific poses.

% Copyright 2015-2023 The MathWorks, Inc.

% Initial turning radius
ro = 1/ko;

% Final turning radius
rf = 1/kf;

% Calculate pose vectors based on attitude
qo = [ro*cosd(ts) ro*sind(ts) 0];
qf = [rf*cosd(tf) rf*sind(tf) 0];

% Rotate 90 deg to find the location of the turning center
qco = angle2dcm(do*pi/2,0,0)*qo';
qcf = angle2dcm(df*pi/2,0,0)*qf';
os = po+qco';
of = pf+qcf';

% Calculate entry and exit angles based on the turning directions for the
% initial and final pose.
if do==1 && df==1
    magc = norm(os-of);
    psi = atan2d((of(2)-os(2)),(of(1)-os(1))); 
    phie = asind((rf-ro)/magc);
    if isreal([psi phie])
        phiex = mod(phie+90+psi+360,360);
        phien = mod(phie+90+psi+360,360);
    else
        error(message('aeroblks_demos_quad:asbquadcopter:complexityError'));
    end
elseif do==-1 && df==-1
    magc = norm(os-of);
    psi = atan2d((of(2)-os(2)),(of(1)-os(1))); 
    phie = asind((rf-ro)/magc);
    if isreal([psi phie])
        phiex = mod(-phie-90+psi+360,360);
        phien = mod(-phie-90+psi+360,360);
    else
        error(message('aeroblks_demos_quad:asbquadcopter:complexityError'));
    end
elseif do==1 && df==-1 
    si = (ro*of+rf*os)/(ro+rf);
    sio = si-os;
    sif = si-of;
    epso = mod(atan2d(sio(2),sio(1))+360,360);
    epsf = mod(atan2d(sif(2),sif(1))+360,360);
    nsio = norm(sio);
    nsif = norm(sif);
    alphao = acosd(ro/nsio);
    alphaf = acosd(rf/nsif);
    if isreal([alphao alphaf])
        phiex = mod(epso+alphao+360,360);
        phien = mod(epsf+alphaf+360,360);    
    else
        error(message('aeroblks_demos_quad:asbquadcopter:complexityError'));
    end
elseif do==-1 && df==1 
    si = (ro*of+rf*os)/(ro+rf);
    sio = si-os;
    sif = si-of;
    epso = mod(atan2d(sio(2),sio(1))+360,360);
    epsf = mod(atan2d(sif(2),sif(1))+360,360);
    nsio = norm(sio);
    nsif = norm(sif);
    alphao = acosd(ro/nsio);
    alphaf = acosd(rf/nsif);
    if isreal([alphao alphaf])
        phiex = mod(epso-alphao+360,360);
        phien = mod(epsf-alphaf+360,360);
    else
        error(message('aeroblks_demos_quad:asbquadcopter:complexityError'));
    end      
end

% Calculate entry and exit waypoints
Tx = os + [ro*cosd(phiex) ro*sind(phiex) 0];   
Tn = of + [rf*cosd(phien) rf*sind(phien) 0];

% Calculate sweeping angles
psio = mod(atan2d(-qco(2),-qco(1))+360,360);
psif = mod(atan2d(-qcf(2),-qcf(1))+360,360);

% Arrange values for exit
osx = os(1);
osy = os(2);
ofx = of(1);
ofy = of(2);