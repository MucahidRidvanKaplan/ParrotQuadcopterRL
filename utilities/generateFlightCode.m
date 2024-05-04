function generateFlightCode()
% GENERATEFLIGHTCODE generates code for deployment in the Parrot (R) mini
% drone. It requires Embedded Coder (R) and Simulink Coder (TM).

% Copyright 2017-2023 The MathWorks, Inc.

model = 'flightControlSystem';
open_system(model);
rtwbuild(model);