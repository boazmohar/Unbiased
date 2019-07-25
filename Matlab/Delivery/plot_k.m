function fig = plot_k(data)
fig = figure('units', 'normalized','position',[0 0 1 1]);
f.PaperPositionMode = 'auto';
hax = [];
virus = data.virus_sub;
names = {'Cell','Saturated','Small'};
for k = 1:3
    index = data.CellType == k & virus > prctile(virus, 25);
    z = data.z(index);
    if ~isempty(z) 
        z = z+rand(length(z), 1);
        z = z*500;
        hax(k) = plot_one(3, k, data.x(index), data.y(index), ...
            z, ...
            data.fraction_sub(index), sprintf('k=%s',names{k}));
    end
end
linkprop(hax, 'CameraPosition');
view(90, 0)
end

