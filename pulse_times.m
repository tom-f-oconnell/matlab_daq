
dv_threshold = 4;
diffed = diff(data);

up = diffed > dv_threshold;
down = diffed < -dv_threshold;
n_up = sum(up);
n_down = sum(down);

n_channels = size(data, 2);

for c = 1:n_channels
    if n_up(c) == n_down(c)
        up_indices = find(up(:,c));
        down_indices = find(down(:,c));
        disp(strcat(['Channel ', num2str(c)]));
        for i = 1:n_up(c)
            % assumes all pins start low (as all mine do)
            % and don't have on transients surrounding trial
            if up_indices(i) > down_indices(i)
                disp(strcat([' Had up transition ', ...
                    'before first down, but assumed to start low.']));
                disp('Skipping.');
                break;
            else
                disp(strcat(['High for ', num2str(time(down_indices(i)) - ...
                    time(up_indices(i))), ' seconds']));
                if i < n_up(c)
                    disp(strcat(['Low for ', num2str(time(up_indices(i + 1)) - ...
                        time(down_indices(i))), ' seconds']));
                end
            end
        end
    else
        disp(strcat(['Pin recorded on channel ', num2str(c), ...
            ' ended in a different state than it was at when recording began.']));
        disp('Not trying to match edges of pulses.');
        continue;
    end
end