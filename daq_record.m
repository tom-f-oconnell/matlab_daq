% Tom O'Connell
daqreset;

s = daq.createSession('ni'); % create session
device = 'Dev2';

% check Dev1 is in daq.getDevices?

% pid output
s.addAnalogInputChannel(device, 'ai1', 'Voltage');
% all control signals
s.addAnalogInputChannel(device, 'ai2', 'Voltage');
%s.addAnalogInputChannel(device, 'ai2', 'valve_control');

% digital channels don't seem to support clocked sampling (?)
%{
digital_inputs = 6;
for n = 0:(digital_inputs - 1)
    s.addDigitalChannel(device, strcat('port0/line', num2str(n)), 'InputOnly');
end
%}
s.DurationInSeconds = 3600 * 20;
s.Rate = 200; % Hz

% why is there no space included between end of take and number?
% annoying...
disp(strcat('Acquisition should take ', num2str(s.DurationInSeconds), ' seconds.'));
t1 = clock;
[data, time] = s.startForeground;
t2 = clock;
disp(strcat('Acquisition took ', num2str(etime(t2, t1)), ' seconds.'));

% TODO save in directly other than exactly where code is. sub / upper
% TODO i think they should be named based on when aquisition starts, not
% finishes
filename = strcat(datestr(datetime('now'), 'yyyymmdd_HHMMSS'), '_pid_data.mat');
save(filename, 'data', 'time');