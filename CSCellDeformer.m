% CS Class CSCellDeformer < SYObject.
% Written by Satoshi Yamashita.
% Processor class to find a cell shape for a minimum energy.

classdef CSCellDeformer < SYObject
properties
    loop_max = 2000;
    epsilon = 0.1^5;
    
    step_n = 21;
    step_w_0 = 0.1;
    conv_factor = 0.2;
    conv_n = 6;
end

methods(Static)
function result = sequenceFrom(origin,direction,number,interval)
% Method to prepare an array of points along a given direction.
% result = sequenceFrom(origin,direction,number,interval)
% Argument origin is double[2] specifying an original point.
% Argument direction is double[2] representing a direction of the points
%   sequence from the origin.
% Argument number is a number indicating a number of the points.
% Argument interval is a number specifying a width between sequential
%   points.
% Return value is a 2D number array whose row vector represents the point.
    l = sqrt(sum(direction .^ 2));
    if l == 0
        result = nan;
        return;
    end
    step = interval * direction / l;
    
    x_seq = origin(1):step(1):origin(1) + step(1) * (number - 1);
    y_seq = origin(2):step(2):origin(2) + step(2) * (number - 1);
    
    result = [x_seq',y_seq'];
end
function result = sequenceAround(origin,direction,number,interval)
% Method to prepare an array of points along a given direction.
% result = sequenceAround(origin,direction,number,interval)
% Argument origin is double[2] specifying a center point.
% Argument direction is double[2] representing a direction of the points
%   sequence from the origin.
% Argument number is a number indicating a number of the points.
% Argument interval is a number specifying a width between sequential
%   points.
% Return value is a 2D number array whose row vector represents the point.
    l = sqrt(sum(direction .^ 2));
    if l == 0
        result = nan;
        return;
    end
    step = interval * direction / l;
    
    w_x = step(1) * (number - 1) / 2;
    w_y = step(2) * (number - 1) / 2;
    x_seq = origin(1) - w_x:step(1):origin(1) + w_x;
    y_seq = origin(2) - w_y:step(2):origin(2) + w_y;
    
    result = [x_seq',y_seq'];
end

end

methods
function shapeForMinimumEnergy(obj,cel)
% Method to find a cell shape for a minimum energy.
% shapeForMinimumEnergy(obj,cel)
% Argument cel is a CSCell instance. The cell will be deformed into the
%   minimum energy shape.
    for count = 1:obj.loop_max
        % move p_2.
        gx = CSCellEnergy.dEwrtx_2(cel);
        gy = CSCellEnergy.dEwrty_2(cel);
        
        dp_2 = sqrt(gx^2 + gy^2);
        if dp_2 > obj.epsilon
            w = obj.step_w_0;
            sequence = ...
                CSCellDeformer.sequenceFrom(cel.p_2,[gx,gy],obj.step_n,w);
            E_array = zeros(1,obj.step_n);

            dount = 0;
            while dount < obj.conv_n
                for i = 1:obj.step_n
                    cel.p_2 = sequence(i,:);
                    E_array(i) = CSCellEnergy.energyOfCell(cel);
                end
                [~,index] = min(E_array);
                p = sequence(index,:);
                if index > 1 && index < obj.step_n
                    w = w * obj.conv_factor;
                    dount = dount + 1;
                end
                sequence = ...
                    CSCellDeformer.sequenceAround(p,[gx,gy],obj.step_n,w);
            end
            cel.p_2 = p;
        end
        
        % move p_3.
        gx = CSCellEnergy.dEwrtx_3(cel);
        gy = CSCellEnergy.dEwrty_3(cel);
        
        dp_3 = sqrt(gx^2 + gy^2);
        if dp_3 > obj.epsilon
            w = obj.step_w_0;
            sequence = ...
                CSCellDeformer.sequenceFrom(cel.p_3,[gx,gy],obj.step_n,w);
            E_array = zeros(1,obj.step_n);

            dount = 0;
            while dount < obj.conv_n
                for i = 1:obj.step_n
                    cel.p_3 = sequence(i,:);
                    E_array(i) = CSCellEnergy.energyOfCell(cel);
                end
                [~,index] = min(E_array);
                p = sequence(index,:);
                if index > 1 && index < obj.step_n
                    w = w * obj.conv_factor;
                    dount = dount + 1;
                end
                sequence = ...
                    CSCellDeformer.sequenceAround(p,[gx,gy],obj.step_n,w);
            end
            cel.p_3 = p;
        end
        
        % check convergence.
        if dp_2 < obj.epsilon && dp_3 < obj.epsilon
            break;
        end
    end
end


end
end
