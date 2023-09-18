% Short script to draw a cell.
% Written by Satoshi Yamashita.

function result = ss_draw_cell(cel,zoomFactor)
% Function to draw a cell.
% result = ss_draw_cell(cel,zoomFactor)
% Argument cel is CSCell instance.
% Argument zoomFactor is a number to zoom the returning image.
% Retrun value is an image of the cell.

    frame = [0,0,0,0];

    p_1 = [cel.w,0] * zoomFactor;
    p_2 = cel.p_2 * zoomFactor;
    p_3 = cel.p_3 * zoomFactor;
    p_4 = [-cel.w,0] * zoomFactor;
    c_1 = cel.r_1 * zoomFactor;
    c_2 = cel.r_2 * zoomFactor;
    c_3 = cel.r_3 * zoomFactor;

    enframe_arc(p_1,p_2,c_1);
    enframe_arc(p_2,p_3,c_2);
    enframe_arc(p_3,p_4,c_3);

    siz = [frame(2) - frame(1) + 3,frame(4) - frame(3) + 3];
    bitmap = SYData(zeros(siz));
    bitmap.var(:) = 1.0;
    context = SYGraphicsContext(bitmap,siz(2),siz(1), ...
        8,SYGraphicsContext.CompositeModeOver, ...
        SYGraphicsContext.ColorSpaceGrayscale,nan,[0,255]);

    p_1 = p_1 - [frame(3),frame(1)] + 2;
    p_2 = p_2 - [frame(3),frame(1)] + 2;
    p_3 = p_3 - [frame(3),frame(1)] + 2;
    p_4 = p_4 - [frame(3),frame(1)] + 2;

    painter = SYPainter(context);
    p.x = p_1(1);
    p.y = p_1(2);
    painter.move(p);

    add_arc(p_1,p_2,c_1);
    add_arc(p_2,p_3,c_2);
    add_arc(p_3,p_4,c_3);
    add_arc(p_4,p_1,0);

    painter.stroke([0.0]);

    image = SYImage(context);
    seg = IPConnectedComponents.connectedBinaryComponents(image,4);
    hem = unique([seg(1,:), seg(end,:), seg(:,1)', seg(:,end)']);
    seg(any(seg == permute(hem,[1,3,2]),3)) = 0;
    mask = seg > 0;
    bitmap.var(mask) = 0.75;

    result = SYImage(bitmap);

    function enframe_arc(p_i,p_o,c)
        x_min = min([floor(p_i(1)),floor(p_o(1)),frame(3)]);
        x_max = max([ceil(p_i(1)),ceil(p_o(1)),frame(4)]);
        y_min = min([floor(p_i(2)),floor(p_o(2)),frame(1)]);
        y_max = max([ceil(p_i(2)),ceil(p_o(2)),frame(2)]);
        frame = [y_min,y_max,x_min,x_max];
        if c == 0
            return
        end

        % get center point o.
        r = abs(c);
        m = (p_i + p_o)' ./ 2;
        s = [0,-1; 1,0] * (p_o - p_i)';
        S = s .* sqrt(r^2 / sum(s .^ 2) - 0.25);
        o = m + S;

        % get angle t.
        t = asin(sqrt(sum(s .^ 2)) / (2 * r));
        if c < 0
            t = pi - t;
        end

        % get entering and exiting angles.
        z = -s(1) - 1i*s(2);
        T = angle(z);
        t_i = T - t;
        t_o = T + t;

        % enframe arc.
        if t_i > t_o
            frame(3) = min([floor(o(1) - r),frame(3)]);
        end
        if (t_i < 0 && t_o > 0) || ...
           (t_i > t_o && t_o > 0) || ...
           (t_i > t_o && t_i < 0)
            frame(4) = max([ceil(o(1) + r),frame(4)]);
        end
        if (t_i < pi / 2 && t_o > pi / 2) || ...
           (t_i < pi / 2 && t_i > t_o) || ...
           (t_i > t_o && t_o > pi / 2)
            frame(2) = max([ceil(o(2) + r),frame(2)]);
        end
        if (t_i < -pi / 2 && t_o > -pi / 2) || ...
           (t_i < -pi / 2 && t_i > t_o) || ...
           (t_i > t_o && t_o > -pi / 2)
            frame(1) = min([floor(o(2) - r),frame(1)]);
        end        
    end

    function add_arc(p_i,p_o,c)
        if c == 0
            p.x = p_o(1);
            p.y = p_o(2);
            painter.addLine(p)
            return
        end

        % get center point o.
        r = abs(c);
        m = (p_i + p_o)' ./ 2;
        s = [0,-1; 1,0] * (p_o - p_i)';
        S = s .* sqrt(r^2 / sum(s .^ 2) - 0.25);
        o.x = m(1) + S(1);
        o.y = m(2) + S(2);
        
        % get angles.
        x = p_i(1) - o.x;
        y = p_i(2) - o.y;
        t_i = atan2(y,x);

        x = p_o(1) - o.x;
        y = p_o(2) - o.y;
        t_o = atan2(y,x);

        % add the arc.
        painter.addArc(o,c,t_i,t_o,false);
    end
end
