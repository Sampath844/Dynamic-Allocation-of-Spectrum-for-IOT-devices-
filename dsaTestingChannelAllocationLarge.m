% Parameters
num_devices = 100;            % Total number of IoT devices
num_channels = 10;            % Number of available channels, set to 10
time_steps = 50;              % Simulation time steps
priority_levels = randi([1, 3], num_devices, 1);  % Random priority for each device (1 = High, 3 = Low)

% Initialize RFID data for each device (Random Data)
rfid_data = randi([1000, 9999], num_devices, time_steps);

% Initialize Channel Usage (channels vs time matrix)
channel_usage = cell(num_channels, time_steps);

% Graph Coloring Initial Channel Assignment
channels = graph_coloring_assignment(num_devices, num_channels, priority_levels);

% Hybrid Genetic Algorithm to Optimize Channel Allocation
optimized_channels = genetic_algorithm_optimization(channels, priority_levels, num_channels, time_steps);

% Function to dynamically assign spectrum
for t = 1:time_steps
    for ch = 1:num_channels
        assigned_devices = find(optimized_channels(:, t) == ch);
        
        if ~isempty(assigned_devices)
            % Sort devices by priority (High -> Low)
            [~, idx] = sort(priority_levels(assigned_devices));
            sorted_devices = assigned_devices(idx);
            
            % Assign data to the channel, ensuring higher priority fills first
            data_list = {};  % Initialize cell array for storing device data as character vectors
            for d = 1:length(sorted_devices)
                device_id = sorted_devices(d);
                % Convert each entry to character vector
                data_list{end+1} = char(sprintf("Dev%d (Priority: %d, RFID: %d)", device_id, priority_levels(device_id), rfid_data(device_id, t)));
            end
            % Join character vectors with ', ' separator
            channel_usage{ch, t} = strjoin(data_list, ', ');
        end
    end
    
    % Plotting Channel Usage Over Time
    clf; % Clear figure for fresh plotting
    hold on;
    for ch = 1:num_channels
        for t_plot = 1:t  % Plot up to the current time step to slow down visualization
            if ~isempty(channel_usage{ch, t_plot})
                text(t_plot, ch, channel_usage{ch, t_plot}, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center');
            end
        end
    end
    xlabel('Time');
    ylabel('Channels');
    title('Dynamic Spectrum Allocation for IoT Devices');
    ylim([1 num_channels]);  % Fix y-axis range to 1 to 10
    yticks(1:num_channels);  % Set y-ticks to show integer channel numbers
    grid on;
    hold off;
    
    % Pause to slow down the display for each time step
    pause(0.5);  % Adjust the pause duration as needed to control the speed
end

% --- Helper Functions ---
function channels = graph_coloring_assignment(num_devices, num_channels, priority_levels)
    % Initialize channel allocation array
    channels = randi([1, num_channels], num_devices, 1);
end

function optimized_channels = genetic_algorithm_optimization(channels, priority_levels, num_channels, time_steps)
    % Initialize optimized channel matrix with graph coloring result
    optimized_channels = repmat(channels, 1, time_steps);

    % Simulate the genetic algorithm approach
    % Parameters
    num_generations = 100;
    mutation_rate = 0.05;

    for gen = 1:num_generations
        for d = 1:length(optimized_channels)
            if rand < mutation_rate
                optimized_channels(d, :) = randi([1, num_channels], 1, time_steps);
            end
        end
    end
end
