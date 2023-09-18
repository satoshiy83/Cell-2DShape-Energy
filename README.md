# Cell-2DShape-Energy
This project provides tools to analyze columnar cell’s energy with respect to its 2D shape.

## Installation
Download files and put them in a folder with a suitable name. Go to Matlab command line, enter “addpath" + a full path of the folder, and enter “savepath”.

## Requirement
This project requires no Matlab toolbox, but a custom framework of objective classes SYObject family which is available at [![DOI](https://zenodo.org/badge/235579182.svg)](https://zenodo.org/badge/latestdoi/235579182).

## Example
Below is an example of the analysis.
It made an energy landscape with respect to a width of apical perimeter and a curvature of lateral perimeter. The columnar cell was assigned the curvature to its one lateral side another lateral side perimeter was kept straight.
```
% parameters.
name = “oneside_flat”;
rh_max = 2;
constriction_rate = 0.25;
step_n = 100;

compression_factor = 1.01;
lambda = 1;
width = 13;
height = 18;
ab_ratio = 1.6;


% initialization.
mkdir(dest);

A_0 = width * height * compression_factor;
J_b = lambda * (A_0 - width * height) * height;
J_l = lambda * (A_0 - width * height) * width;

cel = CSCell;
cel.w = width / 2;
cel.r_1 = 0;
cel.r_2 = 0;
cel.r_3 = 0;
cel.J_a = J_b * ab_ratio;
cel.J_l = J_l;
cel.J_b = J_b;
cel.lambda = lambda;
cel.A_0 = A_0;

cel.p_2 = [width / 2, height];
cel.p_3 = [-width / 2, height];

deformer = CSCellDeformer;

% enumerate ab_ratio.
map = zeros(step_n);
w = width / 2;
interval = (w * constriction_rate - w) / (step_n - 1);
w_array = w:interval:(w * constriction_rate);
interval = 1 / (height * rh_max * (step_n - 1));
c_array = 0:interval:(1 / (height * rh_max));
cel_0 = cel;

array = SYArray;
cel_base = cel_0.copy;
for i = 1:step_n
    cel = cel_base.copy;
    w = w_array(i);
    cel.w = w;
    deformer.shapeForMinimumEnergy(cel);

    cel_base = cel.copy;
    array.addObject(cel);
    map(1,i) = CSCellEnergy.energyOfCell(cel);
        
    cel_pre = cel;
    for j = 2:step_n
        cel = cel_pre.copy;

        r = 1 / c_array(j);
        cel.r_1 = r;
        deformer.shapeForMinimumEnergy(cel);

        cel_pre = cel.copy;
        array.addObject(cel);
        map(j,i) = CSCellEnergy.energyOfCell(cel);
    end
end

image = SYImage(SYData(map));
image.writeToFile(name + “.heatmap.tif”,false);
data = array.data;
data.writeToFile(name + “.array.mat”);
```

Among the 100 times 100 cells, 10 times 10 cells were picked up and illustrated as representatives.
```
w = width / 2;
interval = (w * constriction_rate - w) / (step_n - 1);
w_array = w:interval:(w * constriction_rate);
interval = 1 / (height * rh_max * (step_n - 1));
c_array = 0:interval:(1 / (height * rh_max));

data = SYData;
data.initWithContentsOfFile(name + “.array.mat”);
array = SYArray;
array.initWithData(data);

indices = [1,10:10:step_n];
for i = indices
    w = w_array(i);

    for j = indices
        c = c_array(j);

        str = name + “.w” + sprintf(“%03d”,i) + “.c” + sprintf(“%03d”,j);

        index = (i - 1) * step_n + j;
        cel = array.objectAtIndex(index);
        image = ss_draw_cell(cel,4);
        image.writeToFile(str + “.tif”,false);
    end
end
```

A path following a gradient of the energy landscape was calculated numerically.
```
image = SYImage(name + “.heatmap.tif”);
dict = ss_get_track(image);
path_image = dict.objectForKey(“track image”);
path_image.writeToFile(name + “.path.tif”,false);
```
A change of energy with respect to the apical width was also stored in the dictionary with a key “E(track)/w”.
