% CS Class CSCell < SYObject.
% Written by Satoshi Yamashita.
% Data class representing a cell.

classdef CSCell < SYObject
properties
    w = 0; % apical width.
    r_1 = 0; % curvature radius 1.
    r_2 = 0; % curvature radius 2.
    r_3 = 0; % curvature radius 3.
    J_a = 0; % apical surface contractility.
    J_l = 0; % lateral surface contractility.
    J_b = 0; % basal surface contractility.
    lambda = 0; % volume constraint.
    A_0 = 0; % resting state volume.
    
    p_2 = [0, 0]; % p_2 coordinate (x, y).
    p_3 = [0, 0]; % p_3 coordinate (x, y).
end

methods
function obj = initWithData(obj,data)
% Initialization method with SYData instance.
% obj = initWithData(obj,data)
    obj.w = data.var.w;
    obj.r_1 = data.var.r_1;
    obj.r_2 = data.var.r_2;
    obj.r_3 = data.var.r_3;
    obj.J_a = data.var.J_a;
    obj.J_l = data.var.J_l;
    obj.J_b = data.var.J_b;
    obj.lambda = data.var.lambda;
    obj.A_0 = data.var.A_0;
    
    obj.p_2 = data.var.p_2;
    obj.p_3 = data.var.p_3;
end
function dest = copy(obj,dest)
% Method to make a shallow copy.
% dest = copy(obj,dest)
% Return value is an instance of the class.
    if nargin < 2
        dest = CSCell;
    end
    copy@SYObject(obj,dest);
    
    dest.w = obj.w;
    dest.r_1 = obj.r_1;
    dest.r_2 = obj.r_2;
    dest.r_3 = obj.r_3;
    dest.J_a = obj.J_a;
    dest.J_l = obj.J_l;
    dest.J_b = obj.J_b;
    dest.lambda = obj.lambda;
    dest.A_0 = obj.A_0;
    
    dest.p_2 = obj.p_2;
    dest.p_3 = obj.p_3;
end

function result = data(obj)
% Method to convert the instance to an SYData instance.
% result = data(obj)
    s.w = obj.w;
    s.r_1 = obj.r_1;
    s.r_2 = obj.r_2;
    s.r_3 = obj.r_3;
    s.J_a = obj.J_a;
    s.J_l = obj.J_l;
    s.J_b = obj.J_b;
    s.lambda = obj.lambda;
    s.A_0 = obj.A_0;
    
    s.p_2 = obj.p_2;
    s.p_3 = obj.p_3;
    
    result = SYData(s);
end

function result = chord_1(obj)
% Method to get a length of chord 1.
% result = chord_1(obj)
% Return value is a number representing the chord length.
    result = sqrt((obj.p_2(1) - obj.w)^2 + obj.p_2(2)^2);
end
function result = chord_2(obj)
% Method to get a length of chord 2.
% result = chord_2(obj)
% Return value is a number representing the chord length.
    result = ...
        sqrt((obj.p_2(1) - obj.p_3(1))^2 + (obj.p_2(2) - obj.p_3(2))^2);
end
function result = chord_3(obj)
% Method to get a length of chord 3.
% result = chord_3(obj)
% Return value is a number representing the chord length.
    result = sqrt((obj.p_3(1) + obj.w)^2 + obj.p_3(2)^2);
end

function result = theta_1(obj)
% Method to get a half angle of arc 1.
% result = theta_1(obj)
% Return value is a number representing the arc angle.
    if obj.r_1 == 0
        result = nan;
        return;
    end
    
    c = obj.chord_1;
    sint = c / (2 * obj.r_1);
    if sint > 1 || sint < -1
        result = nan;
        return;
    end
    
    result = asin(sint);
end
function result = theta_2(obj)
% Method to get a half angle of arc 2.
% result = theta_2(obj)
% Return value is a number representing the arc angle.
    if obj.r_2 == 0
        result = nan;
        return;
    end
    
    c = obj.chord_2;
    sint = c / (2 * obj.r_2);
    if sint > 1 || sint < -1
        result = nan;
        return;
    end
    
    result = asin(sint);
end
function result = theta_3(obj)
% Method to get a half angle of arc 3.
% result = theta_3(obj)
% Return value is a number representing the arc angle.
    if obj.r_3 == 0
        result = nan;
        return;
    end
    
    c = obj.chord_3;
    sint = c / (2 * obj.r_3);
    if sint > 1 || sint < -1
        result = nan;
        return;
    end
    
    result = asin(sint);
end

function result = arc_1(obj)
% Method to get a length of arc 1.
% result = arc_1(obj)
% Return value is a number representing the arc length.
    t = obj.theta_1;
    if isnan(t)
        result = obj.chord_1;
    else
        result = 2 * obj.r_1 * t;
    end
end
function result = arc_2(obj)
% Method to get a length of arc 2.
% result = arc_2(obj)
% Return value is a number representing the arc length.
    t = obj.theta_2;
    if isnan(t)
        result = obj.chord_2;
    else
        result = 2 * obj.r_2 * t;
    end
end
function result = arc_3(obj)
% Method to get a length of arc 3.
% result = arc_3(obj)
% Return value is a number representing the arc length.
    t = obj.theta_3;
    if isnan(t)
        result = obj.chord_3;
    else
        result = 2 * obj.r_3 * t;
    end
end

function result = area(obj)
% Method to get an area in the cell.
% result = area(obj)
% Return value is a number representing the cell area.
    r = obj.r_1;
    c = obj.chord_1;
    t = obj.theta_1;
    if isnan(t)
        B_1 = 0;
    else
        B_1 = r^2 * t - c * r * cos(t) / 2;
    end
    r = obj.r_2;
    c = obj.chord_2;
    t = obj.theta_2;
    if isnan(t)
        B_2 = 0;
    else
        B_2 = r^2 * t - c * r * cos(t) / 2;
    end
    r = obj.r_3;
    c = obj.chord_3;
    t = obj.theta_3;
    if isnan(t)
        B_3 = 0;
    else
        B_3 = r^2 * t - c * r * cos(t) / 2;
    end
    
    rect = (obj.w * obj.p_2(2) + obj.p_2(1) * obj.p_3(2) - ...
        obj.p_2(2) * obj.p_3(1) + obj.p_3(2) * obj.w) / 2;
    
    result = B_1 + B_2 + B_3 + rect;
end

function result = isArcBroken(obj)
% Method to check vertices positions validity.
% result = isArcBroken(obj)
% Return value is a boolean.
    if obj.r_1 ~= 0 && isnan(obj.theta_1)
        result = true;
        return;
    end
    if obj.r_2 ~= 0 && isnan(obj.theta_2)
        result = true;
        return;
    end
    if obj.r_3 ~= 0 && isnan(obj.theta_3)
        result = true;
        return;
    end
    
    result = false;
end

end
end
