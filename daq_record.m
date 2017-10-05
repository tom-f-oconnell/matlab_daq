% Tom O'Connell
daqreset;

s = daq.createSession('ni'); % create session
device = 'Dev1';

% check Dev1 is in daq.getDevices?

% pid output
s.addAnalogInputChannel(device, 1:3, 'Voltage');
% all control signals

% digital channels don't seem to support clocked sampling (?)
%{
digital_inputs = 6;
for n = 0:(digital_inputs - 1)
    s.addDigitalChannel(device, strcat('port0/line', num2str(n)), 'InputOnly');
end
%}
s.DurationInSeconds = 1000;
s.Rate = 200; % Hz

% why is there no space included between end of take and number?
% annoying...
disp(strcat('Acquisition should take ', num2str(s.DurationInSeconds), ' seconds.'));
t1 = clock;
[data, time] = s.startForeground;
t2 = clock;
disp(strcat('Acquisition took ', num2str(etime(t2, t1)), ' seconds.'));

filename = strcat(datestr(datetime('now'), 'yyyymmdd_HHMMSS'), '_pid_data.mat');
save(filename, 'data', 'time');