clc;
clear all;

pre_num = 200; % how many frames you want to zero
baselinetime = 5 % how many seconds in the beginning of the first trial to be used to calculate baseline
SamplingRate = 200;

%%
[shortfilename, pathname, ] =  uigetfile('*.mat');
filename = [pathname shortfilename];
data = load(filename, 'data');

%%
AI5_data = data.data(:,2);
PID_data = data.data(:,1);
datalength = size(AI5_data,1);

%%
figure(1)
subplot(1,2,1)
plot(AI5_data,'color',[104/255 0 0]);
title('trigger');
xlabel('time');
ylabel('trigger [V]');
subplot(1,2,2)
plot(PID_data);
title('PID signal');
xlabel('time');
ylabel('PID signal [V]');
%%
% finding onset and offset timepoints
AI5_data_bin = AI5_data >2;
AI5_data_bin(1:pre_num) = zeros(1,pre_num);
AI5_data_diff = [AI5_data_bin(2:end); 0] - AI5_data_bin;
Onset = find(AI5_data_diff > 0);
Offset = find(AI5_data_diff < 0);
%%
x = PID_data;
Fs = 200;                    % sample rate in Hz
N = datalength;                     % number of signal samples
t = (0:N-1)/Fs;              % time vector
t =t';
% Design a 70th order lowpass FIR filter with cutoff frequency of 75 Hz.
Fnorm = 400/(Fs/2); % Normalized frequency
Fnorm = 10;
df = designfilt('lowpassfir','FilterOrder',100,'CutoffFrequency',Fnorm,'SampleRate',Fs);
D = mean(grpdelay(df)) % filter delay in samples

y = filter(df,[x; zeros(D,1)]); % Append D zeros to the input data
y = y(D+1:end);                  % Shift data to compensate for delay

figure(2)
plot(t,AI5_data_bin,'r','linewidth',1.5);
hold on
plot(t,x,'r','linewidth',1.5);
hold on
plot(t,y,'b','linewidth',1.5);
%xlim([100000 100000+10000]);
hold off
title('Filtered Waveforms');
xlabel('Time (s)')

legend('Original Noisy Signal','Filtered Signal');
grid on
axis tight
%% segmentation of repititions

rep_num = size(Onset,1)-3; % omitting the last trial when it's -3.
PID_seg = zeros(rep_num, ceil(datalength/rep_num) );
PID_seg_no_base = zeros(rep_num, ceil(datalength/rep_num) );
PID_seg_no_base_norm = zeros(rep_num, ceil(datalength/rep_num) );
baseline = zeros(rep_num,1);
MaxVal = zeros(rep_num,1);
for I = 1: rep_num %% skipping the first two trials
    PID_seg(I,1:20*SamplingRate+1) = PID_data(Onset(I+2):Onset(I+2)+20*SamplingRate); 
    baseline(I) = mean(PID_data(Onset(I+2):Offset(I+2)));
    PID_seg_no_base(I,1:20*SamplingRate+1) = PID_seg(I,1:20*SamplingRate+1) - baseline(I);
    MaxVal(I) = max(PID_seg_no_base(I,:));
    PID_seg_no_base_norm(I,1:20*SamplingRate+1) = PID_seg_no_base(I,1:20*SamplingRate+1)/MaxVal(I);
end
% segmentation of filtered data
%PID_seg_no_base = PID_seg - baseline;
PID_data_filtered = y;
PID_seg_filtered = zeros(rep_num, ceil(datalength/rep_num) );
PID_seg_no_base_filtered = zeros(rep_num, ceil(datalength/rep_num) );
PID_seg_no_base_norm_filtered = zeros(rep_num, ceil(datalength/rep_num) );
baseline_filtered = zeros(rep_num,1);
MaxVal_filtered = zeros(rep_num,1);
for I = 1: rep_num
    PID_seg_filtered(I,1:20*SamplingRate+1) = PID_data_filtered(Onset(I+2):Onset(I+2)+20*SamplingRate); 
    baseline_filtered(I) = mean(PID_data_filtered(Onset(I+2):Offset(I+2)));
    PID_seg_no_base_filtered(I,1:20*SamplingRate+1) = PID_seg_filtered(I,1:20*SamplingRate+1) - baseline_filtered(I);
    MaxVal_filtered(I) = max(PID_seg_no_base_filtered(I,:));
    PID_seg_no_base_norm_filtered(I,1:20*SamplingRate+1) = PID_seg_no_base_filtered(I,1:20*SamplingRate+1)/MaxVal_filtered(I);
end

%% segmentation of filtered data
OnsetT = floor(Onset/SamplingRate/60/60);
OnsetDiff = [0; OnsetT(1:end-1)] - OnsetT;
HourOnset = find(OnsetDiff<0);

%%
AveTrace = zeros(size(HourOnset,1),ceil(datalength/rep_num));
AveTrace_filtered = zeros(size(HourOnset,1),ceil(datalength/rep_num));
AveTrace(1,:) = mean(PID_seg_no_base(1:HourOnset(1),:),1);
AveTrace_filtered(1,:) = mean(PID_seg_no_base_filtered(1:HourOnset(1),:),1);
for i= 2:size(HourOnset,1)
    AveTrace(i,:) = mean(PID_seg_no_base(HourOnset(i-1)+1:HourOnset(i),:),1);
    AveTrace_filtered(i,:) = mean(PID_seg_no_base_filtered(HourOnset(i-1)+1:HourOnset(i),:),1);
end
figure(6)
for I = 1:size(HourOnset,1)
    %plot(t(1:size(PID_seg_no_base_norm_filtered,2))',...
    %PID_seg_no_base_norm(I,:)','color',[1-I/rep_num 0 I/rep_num]);
    plot(AveTrace(I,:)','color',[1-I/size(HourOnset,1) 0 I/size(HourOnset,1)]);
    %ylim([0.1 0.18])
    xlim([0 4000])
    title('unfiltered')
    xlabel('Time [ms]')
    ylabel('Baseline-corrected PID Signal [V], averaged per hour')
    hold on
end
figure(7)
for I = 1: size(HourOnset,1)
    %plot(t(1:size(PID_seg_no_base_norm_filtered,2))',...
    %PID_seg_no_base_norm(I,:)','color',[1-I/rep_num 0 I/rep_num]);
    plot(AveTrace_filtered(I,:)','color',[1-I/size(HourOnset,1) 0 I/size(HourOnset,1)]);
    %ylim([0.1 0.18])
    xlim([0 4000])
    title('300Hz-filtered')
    xlabel('Time [ms]')
    ylabel('Baseline-corrected PID Signal [V], averaged per hour')
    %colorbar()
    hold on
end
hold off
%%
figure(4)
hold on
for I = 1: 20:rep_num
    %plot(t(1:size(PID_seg_no_base_norm_filtered,2))',...
    %PID_seg_no_base_norm(I,:)','color',[1-I/rep_num 0 I/rep_num]);
    plot(PID_seg_no_base(I,:)','color',[1-I/rep_num 0 I/rep_num]);
    %ylim([0.1 0.18])
    xlim([0 4000])
    title('unfiltered')
    xlabel('Time (s)')
    ylabel('Normalized PID Signal')
    hold on
end
hold off

%%
figure(5)
hold on
for I = 1: 20:rep_num
    %(t(1:size(PID_seg_filtered_no_base_norm,2))',PID_seg_filtered_no_base_norm(I,:)','color',[1-I/rep_num 0 I/rep_num]);
    plot(PID_seg_no_base_filtered(I,:)','color',[1-I/rep_num 0 I/rep_num]);
    %ylim([0.1 0.18])
    xlim([0 4000])
    title('300hz filtered')
    xlabel('Time (s)')
    ylabel('Normalized PID Signal')
    hold on
end
hold off
%%
%save([filename 'processed.mat']);
