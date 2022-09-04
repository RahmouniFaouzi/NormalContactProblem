function bound_box = calculate_bounding_box(nodes, inflate)
%==============================%
%   Calculate a bounding box   %
%==============================%

x = nodes(:,1);
y = nodes(:,2);
X_min= min(x)-inflate;
Y_min=min(y)-inflate;
X_max=max(x)+inflate;
Y_max=max(y)+inflate;
bound_box=[X_min,Y_min, X_max,Y_max];
%
end