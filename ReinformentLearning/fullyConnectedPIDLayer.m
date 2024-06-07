classdef fullyConnectedPIDLayer < nnet.layer.Layer

    properties (Learnable)
        Weights
    end

    properties
        lowerLimit
        upperLimit
    end
    
    methods
        function obj = fullyConnectedPIDLayer(Weights, Name, lowerLimit, upperLimit)

            % Set layer name
            obj.Name = Name;

            % Set layer description
            obj.Description = "Fully connected layer with PID gains";
        
            % Set layer weights
            obj.Weights = Weights;

            % Set limits
            obj.lowerLimit = lowerLimit;
            obj.upperLimit = upperLimit;

        end
        
        function Z = predict(obj, X)
            obj.Weights = max(min(obj.Weights, obj.upperLimit), obj.lowerLimit);
            Z1 = fullyconnect([X(1) X(3) X(5)]',...
                [obj.Weights(1) obj.Weights(3) obj.Weights(5)], 0, 'DataFormat','CB');
            Z2 = fullyconnect([X(2) X(4) X(6)]',...
                [obj.Weights(2) obj.Weights(4) obj.Weights(6)], 0, 'DataFormat','CB');
            % Z1 = obj.Weights(1) * X(1) + obj.Weights(3) * X(3) + obj.Weights(5) * X(5);
            % Z2 = obj.Weights(2) * X(2) + obj.Weights(4) * X(4) + obj.Weights(6) * X(6);

            % Combine outputs into a single variable
            Z = [Z1; Z2];
            
        end
    end
end