%explanation
%step           : simulates one step of interaction between the agent and the environment.
%                 It takes an action (velocity commands) as input, updates the drone's position
%                 based on these commands, calculates the reward, and checks if the episode is done
%                 based on termination conditions.
%reset          : resets the environment to its initial state at the beginning of each episode
%getObservation :returns the current observation (state) of the environment, which in this case is the drone's position.
%calculateReward : calculates the reward based on the current state, which is the negative distance
%                  to the target (center of the square). 
%isEpisodeDone   : checks if the episode is done based on termination conditions, 
%                   which in this case is after the drone has drawn the square and returned to the starting position

classdef DroneEnvironment < rl.env.MATLABEnvironment
    properties
        % Drone dynamics parameters
        MaxVelocity = 1; % Maximum velocity of the drone
        TimeStep = 0.005; % Time step for simulation
        
        % Environment parameters
        SquareSize = 5; % Size of the square (meters)
        StartPosition = [0, 0]; % Starting position of the drone
        CurrentPosition; % Current position of the drone
        StepCount = 0; % Step count for episode termination
    end
    
    methods
        function this = DroneEnvironment()
            % Constructor
            this.CurrentPosition = this.StartPosition;
        end
        
        function [observation, reward, isDone] = step(this, action)
            % Apply action to the environment and simulate one step
            
            % Convert action to velocity commands
            velocity = this.MaxVelocity * action;
            
            % Update drone position based on velocity commands
            this.CurrentPosition = this.CurrentPosition + velocity * this.TimeStep;
            
            % Calculate reward
            reward = this.calculateReward();
            
            % Check if episode is done based on termination conditions
            isDone = this.isEpisodeDone();
            
            % Increment step count
            this.StepCount = this.StepCount + 1;
            
            % Return observation
            observation = this.getObservation();
        end
        
        function initialObservation = reset(this)
            % Reset the environment to an initial state
            
            % Reset drone position
            this.CurrentPosition = this.StartPosition;
            
            % Reset step count
            this.StepCount = 0;
            
            % Return initial observation
            initialObservation = this.getObservation();
        end
        
        function observation = getObservation(this)
            % Get observation (state) from the environment
            
            % For simplicity, observation is the current position of the drone
            observation = this.CurrentPosition;
        end
        
        function reward = calculateReward(this)
            % Calculate reward based on current state
            
            % For simplicity, reward is based on distance to the target (center of the square)
            targetPosition = this.StartPosition;
            distanceToTarget = norm(this.CurrentPosition - targetPosition);
            reward = -distanceToTarget; % Negative distance as reward (closer to target is better)
        end
        
        function isDone = isEpisodeDone(this)
            % Check if episode is done (termination conditions)
            
            % Terminate episode after drawing the square and returning to the start position
            isDone = false;
            if this.StepCount >= (4 * this.SquareSize / this.MaxVelocity) + 1 % Plus 1 for returning to start position
                isDone = true;
            end
        end
    end
end
