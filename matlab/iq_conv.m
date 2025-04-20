% Import Data %
data = importdata('binary-output.txt');

% Set sampling frequency
sampling_frequency = 2048000;

% Get length of data string
length_data = int32(length(data)/2);

% Create integer matrix
data_int = zeros(length_data,2);

for i=1:length_data
    % Turn values from decimal to string
    data_string = num2str(data(1,i));
    
    result = mod(i,2);
    if result == 1
        data_int(i,1)= bin2dec(data_string);
        data_int(i,1) = (data_int(i,1) - 127.5) / 127.5;
    else
        data_int(i-1,2)= bin2dec(data_string);
        data_int(i-1,2) = (data_int(i-1,2) - 127.5) / 127.5;
    end
end


% Declare matrix for amplitude values and matrix for phase values
amplitude = zeros(length_data/2,1);

phase = zeros(length_data/2,1);

% Count of index
index = 1;



% Compute real value and phase
% Where the amplitude is equal to A = sqrt (X^2 + Y^2)
% And the phase is equal to A = arctan (Y/X)
for i=1:length_data
 
    result = mod(i,2);
    if result == 1
        amplitude(index,1) = sqrt(data_int(i,1).^2 * data_int(i,2).^2);
        phase(index,1) = atan(data_int(i,2)/data_int(i,1));          
        index = index + 1;
    end
end

% Compute the time duration of the samples
second_per_sample = (1/sampling_frequency);


% Number of seconds in sample data
time_of_sample = double(length_data)/sampling_frequency;

% Convert samples into index %
time_cos = 0:(time_of_sample)/(index-2):time_of_sample;

y = zeros(1,index-1);

% Compute and plot the cos wave
for i=1:index-1
    y(1,i) = amplitude(i,1)*cos(2*sampling_frequency*time_cos(1,i) + phase(i,1));
end


figure(1)
plot(time_cos(1,1:1000),y(1,1:1000));


average_array = zeros(1,index);
sum = 0;
counter = 1;

% Compute the average value of the instantaneous amplitude 
for i=1:index
    sum = sum + amplitude(i,1);
    result = mod(i,6);
    if result == 0
        average_array(1,counter) = sum*(1/6);
        counter = counter + 1;
        sum = 0;
    end
end
