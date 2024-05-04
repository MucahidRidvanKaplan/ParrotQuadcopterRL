function [wi,ti,ki,di] = noFlyLine(Tn,Tx,noflyc,noflyr,dr)
% This is a helper function for the dubinPathGeneration function. It
% calculates the intermediate waypoint whenever a straight dubin trajectory
% crosses a no-fly zone.

% Copyright 2015-2023 The MathWorks, Inc.

% Calculate the radius for the location of the new waypoint
safer = noflyr + dr;

% Calculate vector of the crossing line at the origin
TnTx = Tn-Tx;
mTnTx = TnTx(2)/TnTx(1);

if abs(mTnTx)<=0.0001 % This is the case when the line TnTx is parallel to the X axis
    y1 = noflyc(2)-noflyr;
    y2 = noflyc(2)+noflyr;
    if abs(Tn(2)-y1)<abs(Tn(2)-y2)
        wi = [noflyc(1) y1 0];
    else
        wi = [noflyc(1) y2 0];
    end
    ti = 0;
elseif abs(mTnTx)>=1e10
    x1 = noflyc(1)-noflyr;
    x2 = noflyc(1)+noflyr;
    if abs(Tn(1)-x1)<abs(Tn(1)-x2)
        wi = [x1 noflyc(2) 0];
    else
        wi = [x2 noflyc(2) 0];
    end
    ti = 90;
else
    % Rotate the vector 90 deg to obtain the slope for the orthogonal line to
    % the crossing line.
    TnTxp = angle2dcm(pi/2,0,0)*TnTx';
    mCW = TnTxp(2)/TnTxp(1);
    
    % Solve the equations for the points along the safe circle
    a = mCW^2+1;
    b = -2*noflyc(1)-2*mCW^2*noflyc(1);
    c = noflyc(1)^2+mCW^2*noflyc(1)^2-safer^2;
    rx = roots([a b c]);
    ry = mCW*(rx-noflyc(1))+noflyc(2);
    
    % Find the intercept between the crossing line and its orthogonal
    xi = (noflyc(2)+mTnTx*Tx(1)-Tx(2)-mCW*noflyc(1))/(mTnTx-mCW);
    yi = mCW*(xi-noflyc(1))+noflyc(2);
    
    % Calculate the distance between the two intercepts along the circle
    % equation and the intercept between the crossing line and its orthogonal.
    % The solution will be the intercept on the circle that is closest to the
    % line intercept.
    n1 = norm([rx(1) ry(1)]-[xi yi]);
    n2 = norm([rx(2) ry(2)]-[xi yi]);
    if n1<=n2
        wi = [rx(1) ry(1) 0];
    else
        wi = [rx(2) ry(2) 0];
    end
    
    % Calculate heading using the same orientation as the crossing line
    ti = atan2d(TnTx(2),TnTx(1));
end
% Calculate direction
cp = sign(cross(TnTx,wi-noflyc));
di = cp(3);

% Calculate curvature based on safe radius for no fly zone
ki = 1/safer;