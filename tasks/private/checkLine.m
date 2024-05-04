function [noflyflag,lineinfo] = checkLine(wp,noflyc,noflyr,z,noflyflag)
% This is a helper function for the dubinPathGeneration function. It checks
% crossings between dubin straight paths and no-fly zones.

% Copyright 2015-2023 The MathWorks, Inc.

lineinfo = [];
jj = 1;

for m = 1:size(noflyc,1)
    % Check for the distance from the lines to the no fly zone
    TnTx = wp(z+2,1:3)-wp(z+1,1:3);
    CTx = noflyc(m,:)-wp(z+1,1:3);
    uTnTx = TnTx/norm(TnTx);
    CTnTx = dot(uTnTx,CTx);
    % Orthogonal distance to the line
    dist = sqrt(norm(CTx)^2-CTnTx^2);
    % Make sure that the orthogonal distance is between Tx and Tn
    intTnTx = noflyc(m,:)+(-CTx-dot(-CTx,uTnTx)*uTnTx);
    tTnTx = (intTnTx-wp(z+1,1:3))*uTnTx';
    if dist+2*eps<noflyr(m) && tTnTx>=0 && tTnTx<=norm(TnTx)
        noflyflag = true;
        % Calculate vector of the crossing line at the origin
        mTnTx = TnTx(2)/TnTx(1);
        Tx = wp(z+1,1:3);
        dx = Tx(2)-noflyc(m,2)-mTnTx*Tx(1);
        a = mTnTx^2+1;
        b = 2*mTnTx*dx-2*noflyc(m,1);
        c = noflyc(m,1)^2+dx^2-noflyr(m)^2;
        % Solve the equations for the points along the safe circle
        rx = roots([a b c]);
        ry = mTnTx*(rx-Tx(1))+Tx(2);
        distTx1 = norm(Tx-[rx(1) ry(1) 0]);
        distTx2 = norm(Tx-[rx(2) ry(2) 0]);
        if distTx1<=distTx2
            lineinfo(jj,:) = [m distTx1]; %#ok<AGROW>
        else
            lineinfo(jj,:) = [m distTx2]; %#ok<AGROW>
        end
        jj = jj+1;
    end
end