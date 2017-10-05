
close all;

files = dir('*.mat');

set(gcf, 'Visible', 'off');

for file = files'
    clear data;
    clear time;
    load(file.name);
    fig = plot(data(:,1));
    curr_limits = axis;
    axis([curr_limits(1), curr_limits(2), 0, 5]);
    splt = strsplit(file.name, '_');
    png_name = strcat(strjoin(splt(1:3), '_'), '.png');
    % TODO why didn't fig work when gcf does?
    saveas(gcf, png_name);
end

%set(gcf, 'Visible', 'on');