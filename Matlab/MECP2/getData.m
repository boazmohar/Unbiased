function data = getData(filename,info,x,y,w,h)
%data = getFOV(filename,info,x,y,w,h) 
% open tif file with bfopen and reshape accprding to info
if nargin == 2
    f = bfopen(filename);
    data = f{1};
    data = cat(3, data{:,1});
    data = reshape(data, info.Height,info.Width,info.chs, info.zs);
else
    f = bfopen(filename, x, y, w, h);
    data = f{1};
    data = cat(3, data{:,1});
    data = reshape(data,h,w,info.chs, info.zs);
end

end

