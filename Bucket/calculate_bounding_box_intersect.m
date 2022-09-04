function  spatial_bb = calculate_bounding_box_intersect(a, b)
%-------------------------------------------------------
% Return intersection of two bounding boxes, if it exists
%-------------------------------------------------------

xL = max( a(1), b(1) );
yB = max( a(2), b(2) );
xR = min( a(3), b(3) );
yT = min( a(4), b(4) );
if xL < xR && yB < yT
    XL=xL; YB=yB; XR=xR; YT=yT;
else
    XL=[]; YB=[]; XR=[]; YT=[];
end
spatial_bb = [XL, YB, XR, YT];

end