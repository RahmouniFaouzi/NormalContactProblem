function NODEIN= distribute_nodes(node_positions, spatial_bb)
%-----------------------------------------------
% Distributes nodes into Overlab Box
%------------------------------------------------
x1 = spatial_bb(1);  y1 = spatial_bb(2);
x2 = spatial_bb(3);  y2 = spatial_bb(4);
count=1 ; NODEIN=[] ;
for i=1:size(node_positions,1)
    x_node=node_positions(i,1);y_node=node_positions(i,2);
    if x1 <= x_node && x_node<= x2
        if y1 <= y_node && y_node <= y2
            NODEIN(count)=i;
            count=count+1;
        end
end
end
