% Short scrpit to get a track following a gradient of given image.
% Written by Satoshi Yamashita.

function result = ss_get_track(image)
% Function to get a track starting from left bottom corner and following a 
%   gradient of given image.
% result = ss_get_track(image)
% Argument image is a grayscale image.
% Return value is a dictionary containing the track and brightness along
%   the track.
%   "track": a 2D number array whose column vector represents a point on
%       the track.
%   "track image": an image of the track.
%   "E(floor)/w": brightness of the image bottom line with respect to x.
%   "E(track)/w": brightness of the image on the track with respect to x.

dict = SYDictionary;

siz = image.frameSize;
bitmap = zeros(siz,'uint8');

tracer = CSTracer;
track = tracer.trace(image,[1,1]);
dict.setObjectForKey("track",track);

r = round(track(1,:));
c = round(track(2,:));
indices = sub2ind(siz,r(:),c(:));
bitmap(indices) = 255;
dict.setObjectForKey("track image",SYImage(SYData(bitmap)));

mask = bitmap > 0;

bitmapRep = image.representations.objectAtIndex(1);
bitmap = bitmapRep.bitmap;
dict.setObjectForKey("E(floor)/w",bitmap.var(1,:));

bitmap.var(~mask) = 0;
aver = sum(double(bitmap.var),1) ./ sum(double(mask),1);
dict.setObjectForKey("E(track)/w",aver);

result = dict;
end
