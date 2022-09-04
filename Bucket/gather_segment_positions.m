function segment_positions= gather_segment_positions(node_positions, snpm)
%"""""""""""""""""""""""""""""""""""""""""""
 %  Gather segment positions into one array
 %""""""""""""""""""""""""""""""""""""""""""""
% snpm =[2     3
%        4     1
%        5     6
%        6     7
%        8     5
%        3     4];
% node_positions=[0 0;4 0;4 1 ;0 1;1 1.98418861;3 1.98418861...
%                     ;3 2.98418861;1 2.98418861];
%--------------------------------------------------------------------

num_segments = size(snpm,1);
%Two nodes in two dimensions = 4
segment_positions = zeros(num_segments, 4 );
for segment_id=1:num_segments
        segm_nd = snpm(segment_id,:);
        segment_positions(segment_id, :) =[node_positions(segm_nd(:,1),:) node_positions(segm_nd(:,2),:)];
end

end

