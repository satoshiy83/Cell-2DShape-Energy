% CS Class CSCellEnergy < SYObject.
% Written by Satoshi Yamashita.
% Processor class to calculate cell energy with respect to its shape.

classdef CSCellEnergy < SYObject
properties

end

methods(Static)
function result = energyOfCell(cel)
% Method to get an energy of a cell.
% result = energyOfCell(cel)
% Return value is a number representing the energy.
    result = cel.J_a * 2 * cel.w + ...
        cel.J_l * (cel.arc_1 + cel.arc_3) + cel.J_b * cel.arc_2 + ...
        cel.lambda * (cel.area - cel.A_0) ^ 2;
end

function result = dEwrtx_2(cel)
% Method to get a change of energy with respect to x of point p_2.
% result = dEwrtx_2(cel)
% Return value is a number representing the change.
    c_1 = cel.chord_1;
    c_2 = cel.chord_2;
    t_1 = cel.theta_1;
    t_2 = cel.theta_2;
    A = cel.area;
    
    if isnan(t_1)
        da_1 = (cel.p_2(1) - cel.w) / c_1;
        dB_1 = 0;
    else
        da_1 = (cel.p_2(1) - cel.w) / (c_1 * cos(t_1));
        dB_1 = c_1 * (cel.p_2(1) - cel.w) / (4 * cel.r_1 * cos(t_1));
    end
    if isnan(t_2)
        da_2 = (cel.p_2(1) - cel.p_3(1)) / c_2;
        dB_2 = 0;
    else
        da_2 = (cel.p_2(1) - cel.p_3(1)) / (c_2 * cos(t_2));
        dB_2 = c_2 * (cel.p_2(1) - cel.p_3(1)) / (4 * cel.r_2 * cos(t_2));
    end
    
    result = cel.J_l * da_1 + cel.J_b * da_2 + ...
        2 * cel.lambda * (A - cel.A_0) * (dB_1 + dB_2 + cel.p_3(2) / 2);
end
function result = dEwrty_2(cel)
% Method to get a change of energy with respect to y of point p_2.
% result = dEwrty_2(cel)
% Return value is a number representing the change.
    c_1 = cel.chord_1;
    c_2 = cel.chord_2;
    t_1 = cel.theta_1;
    t_2 = cel.theta_2;
    A = cel.area;
    
    if isnan(t_1)
        da_1 = cel.p_2(2) / c_1;
        dB_1 = 0;
    else
        da_1 = cel.p_2(2) / (c_1 * cos(t_1));
        dB_1 = c_1 * cel.p_2(2) / (4 * cel.r_1 * cos(t_1));
    end
    if isnan(t_2)
        da_2 = (cel.p_2(2) - cel.p_3(2)) / c_2;
        dB_2 = 0;
    else
        da_2 = (cel.p_2(2) - cel.p_3(2)) / (c_2 * cos(t_2));
        dB_2 = c_2 * (cel.p_2(2) - cel.p_3(2)) / (4 * cel.r_2 * cos(t_2));
    end
    
    result = cel.J_l * da_1 + cel.J_b * da_2 + 2 * cel.lambda * ...
        (A - cel.A_0) * (dB_1 + dB_2 + (cel.w - cel.p_3(1)) / 2);
end
function result = dEwrtx_3(cel)
% Method to get a change of energy with respect to x of point p_3.
% result = dEwrtx_3(cel)
% Return value is a number representing the change.
    c_2 = cel.chord_2;
    c_3 = cel.chord_3;
    t_2 = cel.theta_2;
    t_3 = cel.theta_3;
    A = cel.area;
    
    if isnan(t_2)
        da_2 = (cel.p_3(1) - cel.p_2(1)) / c_2;
        dB_2 = 0;
    else
        da_2 = (cel.p_3(1) - cel.p_2(1)) / (c_2 * cos(t_2));
        dB_2 = c_2 * (cel.p_3(1) - cel.p_2(1)) / (4 * cel.r_2 * cos(t_2));
    end
    if isnan(t_3)
        da_3 = (cel.p_3(1) + cel.w) / c_3;
        dB_3 = 0;
    else
        da_3 = (cel.p_3(1) + cel.w) / (c_3 * cos(t_3));
        dB_3 = c_3 * (cel.p_3(1) + cel.w) / (4 * cel.r_3 * cos(t_3));
    end
    
    result = cel.J_l * da_3 + cel.J_b * da_2 + ...
        2 * cel.lambda * (A - cel.A_0) * (dB_2 + dB_3 - cel.p_2(2) / 2);
end
function result = dEwrty_3(cel)
% Method to get a change of energy with respect to y of point p_3.
% result = dEwrty_3(cel)
% Return value is a number representing the change.
    c_2 = cel.chord_2;
    c_3 = cel.chord_3;
    t_2 = cel.theta_2;
    t_3 = cel.theta_3;
    A = cel.area;
    
    if isnan(t_2)
        da_2 = (cel.p_3(2) - cel.p_2(2)) / c_2;
        dB_2 = 0;
    else
        da_2 = (cel.p_3(2) - cel.p_2(2)) / (c_2 * cos(t_2));
        dB_2 = c_2 * (cel.p_3(2) - cel.p_2(2)) / (4 * cel.r_2 * cos(t_2));
    end
    if isnan(t_3)
        da_3 = cel.p_3(2) / c_3;
        dB_3 = 0;
    else
        da_3 = cel.p_3(2) / (c_3 * cos(t_3));
        dB_3 = c_3 * cel.p_3(2) / (4 * cel.r_3 * cos(t_3));
    end
    
    result = cel.J_l * da_3 + cel.J_b * da_2 + 2 * cel.lambda * ...
        (A - cel.A_0) * (dB_2 + dB_3 + (cel.p_2(1) + cel.w) / 2);
end

end
end
