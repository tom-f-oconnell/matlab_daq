
close all;

files = dir('*.mat');

set(gcf, 'Visible', 'off');

for file = files'
    clear data;
    clear time;
    % TODO way to explicitly load some variables without having to clear?
    % TODO TODO option to not re-plot if figure already exists
    splt = strsplit(file.name, '_');
    % TODO allow selecting format, including matlab plot
    png_name = strcat(strjoin(splt(1:3), '_'), '.png');
    
    load(file.name);
    % PID voltage should be on this channel
    % plotting just this one, since w/ both, the 5v often swamps signal
    % TODO scale PID s.t. can plot both
    fig = plot(data(:,1));
    curr_limits = axis;
    axis([curr_limits(1), curr_limits(2), 0, 0.5]);
    % TODO why didn't fig work when gcf does? (still an issue?)
    saveas(gcf, png_name);
end

% TODO include a subplot / other plot that shows average of single pulse
% + change over time

%set(gcf, 'Visible', 'on');