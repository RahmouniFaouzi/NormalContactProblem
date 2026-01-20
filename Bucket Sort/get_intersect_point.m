function x= get_intersect_point(A,B)
% get the intrsect points 
s1_x = A(3) - A(1);     s1_y = A(4) - A(2);
s2_x = B(3) - B(1);     s2_y = B(4) - B(2);

s = (-s1_y * (A(1) - B(1)) + s1_x * (A(2) - B(2))) / (-s2_x * s1_y + s1_x * s2_y);
t = ( s2_x * (A(2) - B(2)) - s2_y * (A(1) - B(1))) / (-s2_x * s1_y + s1_x * s2_y);

if (s >= 0 && s <= 1 && t >= 0 && t <= 1)
    [x ] = [A(1)+(t * s1_x)   A(2)+(t * s1_y)];
else
    [x ] = [] ;
end

end