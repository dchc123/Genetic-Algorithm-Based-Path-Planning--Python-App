function [corner_vertices, offset_points] = identify_corners(points, CL, curvature_threshold_degrees, offset)
    % Calculate vertex neighborhoods
    vertex_neighborhoods = cell(size(points, 1), 1);
    for ii = 1:size(CL, 1)
        for jj = 1:size(CL, 2)
            vertex_neighborhoods{CL(ii, jj)} = unique([vertex_neighborhoods{CL(ii, jj)}; CL(ii, mod(jj, 3) + 1); CL(ii, mod(jj + 1, 3) + 1)]);
        end
    end

    % Calculate discrete mean curvature in degrees
    mean_curvature = zeros(size(points, 1), 1);
    for ii = 1:size(points, 1)
        neighbors = vertex_neighborhoods{ii};
        neighbors = neighbors(neighbors ~= ii);
        n = length(neighbors);
        if n < 2 % Skip points that only have one neighbor
            continue;
        end
        sum_angles = 0;
        sum_edge_lengths = 0;
        for jj = 1:n
            v1 = points(neighbors(jj), :) - points(ii, :);
            v2 = points(neighbors(mod(jj, n) + 1), :) - points(ii, :);
            angle = atan2d(norm(cross(v1, v2)), dot(v1, v2));
            sum_angles = sum_angles + angle;
            sum_edge_lengths = sum_edge_lengths + norm(v1);
        end
        mean_curvature(ii) = (360 - sum_angles) / sum_edge_lengths;
    end

    % Convert the curvature threshold from degrees to the method's units
    curvature_threshold = 2 * tand(curvature_threshold_degrees/2);

    % Find corner vertices using curvature threshold
    corner_vertices = find(mean_curvature > curvature_threshold);

    % Remove corner vertices that are not connected to any edge
    connected_to_edge = false(size(corner_vertices));
    for ii = 1:numel(corner_vertices)
        vertex_edges = sum(ismember(CL, corner_vertices(ii)), 2) > 0;
        connected_to_edge(ii) = any(vertex_edges);
    end
    corner_vertices = corner_vertices(connected_to_edge);

    % Offset the vertices
    offset_points = points;
    offset_points(corner_vertices, 3) = offset_points(corner_vertices, 3) + offset;
end
