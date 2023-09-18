% CS Class CSTracer < SYObject.
% Written by Satoshi Yamashita.
% Processor class to get a track following a gradinet.

classdef CSTracer < SYObject
properties
    dp = nan; % Float.
    threshold_grad = nan; % Float.
end

methods
function obj = CSTracer()
% Processor class to get a track following a gradient.
% obj = CSTracer()
    obj.dp = 1.0e-2;
    obj.threshold_grad = 1.0e-10;
end

function result = trace(obj,map,origin)
% Method to find a path following a gradinet numerically.
% result = trace(obj,map,origin)
% Argument map is a grayscale image of the gradient.
% Argument origin is double[2] indicating an original point of the path.
% Return value is a 2D number array whose column vector represents a point
%   on the path.
    gradImage = IPGradient.Prewitt(map);
    bitmapRep = gradImage.representations.objectAtIndex(2); % d map/d y.
    bitmap = bitmapRep.bitmap.var;
    bitmapRep = gradImage.representations.objectAtIndex(1); % d map/d x.
    bitmap = cat(3,bitmap,bitmapRep.bitmap.var);
    gradient = SYData(bitmap);

    mgrad = mean(bitmap(:));

    siz = map.frameSize;
    track = zeros(2,round((siz(1) + siz(2)) / obj.dp));

    p = origin(:);
    for i = 1:size(track,2)
        track(:,i) = p(:);

        grad = weightedMeanAt(gradient,p);

        % Check if the gradient is larger than threshold.
        if sum(grad .^ 2) < obj.threshold_grad
            break
        end

        p = p + grad(:) .* obj.dp ./ mgrad;

        % Check if the point is inside frame.
        if any(p < 1) || any(p > siz')
            break
        end
    end

    result = track(:,1:i);
end

end
end

function result = weightedMeanAt(bitmap,position)
% Function to get a gradient at a point.
% result = weightedMeanAt(bitmap,position)
% Argument bitmap is an SYData instance containing a 3D number array of the
%   gradient map raw data.
% Argument position is double[2] representing the point.
% Return valune is double[1,1,2] representing the gradient.
    f = floor(position);
    c = ceil(position);
    fd = (position - f) .^ 2;
    cd = (c - position) .^ 2;

    d_ll = sqrt(fd(1) + fd(2));
    d_lr = sqrt(fd(1) + cd(2));
    d_ul = sqrt(cd(1) + fd(2));
    d_ur = sqrt(cd(1) + cd(2));
    total = d_ll + d_lr + d_ul + d_ur;

    if total == 0
        result = bitmap.var(f(1),f(2),:);
    else
        result = (bitmap.var(f(1),f(2),:) .* d_ll ...
                + bitmap.var(f(1),c(2),:) .* d_lr ...
                + bitmap.var(c(1),f(2),:) .* d_ul ...
                + bitmap.var(c(1),c(2),:) .* d_ur) ./ total;
    end
end
