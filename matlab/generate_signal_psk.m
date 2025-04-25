% Establish Fs
Fs = 1000;

% Define Sampling Period
T = 1/Fs;

% Define Length of Signal in time (ms)
L = 100000; % Same as 1 second

% Number of samples per sine_wave
number_of_samples = 360;

% Create time array for symbols with sampling period
t = (0:L-1)*T;

% Binary signal
binary_signal = zeros(1,length(t));

% Output Y signal
y = zeros(1,length(t));

% Generate first random value
%rand_value = randi([0 1]);
rand_value = 1;

% Assign first random value to binary signal
binary_signal(1,1) = rand_value;

% FSK Center Frequencies
Fc1 = 1;
Fc2 = 10;

% Establish Bit Rate
Rb = 250;

% Number of Samples
num_samples = (Fs/Rb)*(L/Fs);

% Create Feature Matrix
feature_matrix = zeros(num_samples,6);

% Establish Baud Rate
Baud_rate = 250;

for i=1:(length(t))
    
    if(mod(i,(Fs/4)+1) == 0)
        rand_value = randi([0 1]);
        binary_signal(1,i) = rand_value;
            if(rand_value == 0)
                y(1,i) = cos(2*pi*t(1,i)*Fc1);
            else
                y(1,i) = cos((2*pi*t(1,i)*Fc1)+ pi/2);
            end

    else
            binary_signal(1,i) = rand_value;
            if(rand_value == 0)
                y(1,i) = cos(2*pi*t(1,i)*Fc1);
            else
                y(1,i) = cos((2*pi*t(1,i)*Fc1)+ pi/2);
            end
    end
end

% SNR to be kept while adding AWGN
SNR = 10;

%Add White Guassian Noise to signal
y_awgn = awgn(y,SNR,'measured');

figure(1)
plot(t(1:1001),y_awgn(1:1001))


figure(2)
plot(t,y)

figure(3)
plot(t,binary_signal)

% Create matrix for amplitude normalized
amplitude_normalized = zeros(1,length(t));

% Create matrix for normalized-centered instantaneous amplitude
normalized_centered_instantaneous_amplitude = zeros(1,length(t));

% Create matrix for unwrapped phase
unwrapped_phase = zeros(1,length(t));

% Create matrix for centered non linear instantaneous phase
centered_non_inear_instantaneous_phase = zeros(1,length(t));

% Create matrix for frequency at normalized value
normalized_frequency = zeros(1,length(t));

j = 0;

while j ~= num_samples

    average_instataneous_amplitude = 0;

    % Compute Average Instantaneous Amplitude
    for i=(j*Fs/4)+1:(j+1)*(Fs/4)
        average_instataneous_amplitude = abs(y_awgn(1,i)) + average_instataneous_amplitude;
    end

    average_instataneous_amplitude = (1/(Fs/4))*average_instataneous_amplitude;


    % Compute the Value of the Normalized Amplitude
    for i=(j*Fs/4)+1:(j+1)*(Fs/4)
        amplitude_normalized(1,i) = abs(y_awgn(1,i))/average_instataneous_amplitude;
    end

    % Compute the Value of the Centered Normalized Instantaneous Amplitude
    for i=(j*Fs/4)+1:(j+1)*(Fs/4)
        normalized_centered_instantaneous_amplitude(1,i) = amplitude_normalized(1,i)-1;
    end


    standard_deviation_instantaneous_amplitude = 0;
    sum_acn_squared = 0;
    sum_acn = 0;
    for i=(j*Fs/4)+1:(j+1)*(Fs/4)
        sum_acn_squared = sum_acn_squared + normalized_centered_instantaneous_amplitude(1,i).^2;
        sum_acn = sum_acn + abs(normalized_centered_instantaneous_amplitude(1,i));
    end

    sum_acn_squared = (1/Fs/4)*sum_acn_squared;
    sum_acn = ((1/Fs/4)*sum_acn).^2;
    standard_deviation_instantaneous_amplitude = sqrt(sum_acn_squared-sum_acn);

    feature_matrix(j+1,1) = standard_deviation_instantaneous_amplitude;

    % Compute the normalized-centered instantaneous amplitude of the intercepted signal
    gamma_max = fft(normalized_centered_instantaneous_amplitude,Fs/4).^2;

    feature_matrix(j+1,2) = max(gamma_max);
    
    % Find all frequencies
    %figure(4)
    %plot(t(1,1:Fs/4),(Fs/4)*abs(gamma_max),"LineWidth",3)

    % Declare the array for the unwrapped phase
    unwrapped_phase(1,(j*Fs/4)+1:(j+1)*(Fs/4)) = unwrap(y_awgn(1,(j*Fs/4)+1:(j+1)*(Fs/4)));


    % Compute the Value of the Centered Normalized Instantaneous Amplitude
    for i=(j*Fs/4)+1:(j+1)*(Fs/4)
        centered_non_inear_instantaneous_phase(1,i) = unwrapped_phase(1,i) - ((2*pi*(Fc1)*i)/Fs);
    end

    standard_deviation_instantaneous_phase = 0;

    % Compute the Value of the Centered Normalized Instantaneous Amplitude
    sum_unwrapped_squared = 0;
    sum_unwrapped = 0;
    for i=(j*Fs/4)+1:(j+1)*(Fs/4)
        sum_unwrapped_squared = sum_unwrapped_squared + centered_non_inear_instantaneous_phase(1,i).^2;
        sum_unwrapped = sum_unwrapped + abs(centered_non_inear_instantaneous_phase(1,i));
    end

    sum_unwrapped_squared = (1/Fs/4)*sum_unwrapped_squared;
    sum_unwrapped = (1/Fs/4)*sum_unwrapped;

    standard_deviation_instantaneous_phase = sqrt(sum_unwrapped_squared-sum_unwrapped);

    feature_matrix(j+1,3) = standard_deviation_instantaneous_phase;

    standard_deviation_direct_phase = 0;

    % Compute the Value of the Centered Normalized Instantaneous Amplitude
    sum_unwrapped_direct_squared = 0;
    sum_unwrapped_direct = 0;
    for i=(j*Fs/4)+1:(j+1)*(Fs/4)
        sum_unwrapped_direct_squared = sum_unwrapped_direct_squared + centered_non_inear_instantaneous_phase(1,i).^2;
        sum_unwrapped_direct = sum_unwrapped_direct + (centered_non_inear_instantaneous_phase(1,i));
    end

    sum_unwrapped_direct_squared = ((1/Fs/4)*sum_unwrapped_direct_squared);
    sum_unwrapped_direct = ((1/Fs/4)*sum_unwrapped_direct).^2;

    standard_deviation_direct_phase = sqrt(sum_unwrapped_direct_squared-sum_unwrapped_direct);

    feature_matrix(j+1,4) = standard_deviation_direct_phase;

    % Compute average frequency over sample, which will be the same over one
    % symbol
    sum_frequency = 0;
    for i=(j*Fs/4)+1:(j+1)*(Fs/4)
        sum_frequency = sum_frequency + (1/(Fs/4))*Fc1;
    end

    for i=(j*Fs/4)+1:(j+1)*(Fs/4)
        normalized_frequency(1,i) = (((Fc1-sum_frequency)/Rb)*Rb ) - Baud_rate;    
    end

    % Standard Deviation of Absolute Value of Instantaneous Frequency
    deviation_instantaneous_frequency = 0;

    % Compute the Value of the Centered Normalized Instantaneous Frequency
    sum_frequency_squared = 0;
    sum_frequency = 0;
    for i=(j*Fs/4)+1:(j+1)*(Fs/4)
        sum_frequency_squared = sum_frequency_squared + normalized_frequency(1,i).^2;
        sum_frequency = sum_frequency + abs(normalized_frequency(1,i));
    end

    sum_frequency_squared = ((1/Fs/4)*sum_frequency_squared);
    sum_frequency = ((1/Fs/4)*sum_frequency).^2;

    deviation_instantaneous_frequency = sqrt(sum_frequency_squared-sum_frequency);

    feature_matrix(j+1,5) = deviation_instantaneous_frequency;

    feature_matrix(j+1,6) = 5;

    j = j + 1;
end

writematrix(feature_matrix,'psk2_test_data.xls')

