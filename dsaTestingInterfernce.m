
% Function for Genetic Algorithm Optimization
function optimized_channels = genetic_algorithm_optimization(initial_channels, device_priorities, num_channels, num_time_steps, num_devices)
    population_size = 50;
    num_generations = 100;
    mutation_rate = 0.05;
    
    % Initialize the population with random channel assignments for all devices and time steps
    population = randi([1, num_channels], population_size, num_devices * num_time_steps);
    
    for gen = 1:num_generations
        for p = 1:population_size
            % Mutation: randomly change channel assignments for devices in the population
            if rand < mutation_rate
                population(p, :) = randi([1, num_channels], 1, num_devices * num_time_steps);
            end
        end
        
        % Evaluate fitness of the population
        population = evaluate_fitness(population, device_priorities, num_devices, num_time_steps);
    end
    
    % Return the best solution (the first individual in the sorted population)
    optimized_channels = reshape(population(1, :), num_devices, num_time_steps);
end

% Evaluate fitness of each individual in the population
function population = evaluate_fitness(population, device_priorities, num_devices, num_time_steps)
    fitness = zeros(size(population, 1), 1);
    for p = 1:size(population, 1)
        fitness(p) = calculate_fitness(reshape(population(p, :), num_devices, num_time_steps), device_priorities, num_devices, num_time_steps);
    end
    [~, sorted_idx] = sort(fitness);
    population = population(sorted_idx, :);
end

% Calculate fitness: penalize interference and consider priority
function fitness = calculate_fitness(channel_assignment, device_priorities, num_devices, num_time_steps)
    fitness = 0;
    for t = 1:num_time_steps
        for d = 1:num_devices
            % Detect interference: if multiple devices are assigned to the same channel at the same time
            for d2 = 1:num_devices
                if d ~= d2 && channel_assignment(d, t) == channel_assignment(d2, t)
                    fitness = fitness + abs(device_priorities(d) - device_priorities(d2));
                end
            end
        end
    end
end

% Main script for running the genetic algorithm
num_devices = 10;               % Number of IoT devices
num_channels = 6;               % Number of channels available
num_time_steps = 10;             % Number of time steps for data transmission
device_priorities = randi([1, 10], num_devices, 1);  % Random priority levels (1 = high, 10 = low)
rfid_data = randi([1000, 9999], num_devices, num_time_steps); % Random RFID tag data for each device

% Initial channel assignment (can be based on any initial heuristic)
assigned_channels = randi([1, num_channels], num_devices, num_time_steps);

% Optimize channels using the genetic algorithm
optimized_channels = genetic_algorithm_optimization(assigned_channels, device_priorities, num_channels, num_time_steps, num_devices);

% Display optimized channels for the first 5 devices as a sample output
disp('Optimized Channel Assignments (for first 5 devices):');
disp(optimized_channels(1:5, :));

% Graph: Plot the optimized channel assignments over time
figure;
hold on;

% Loop through each device and plot its channel usage over time
for dev = 1:num_devices
    % Get the optimized channel assignments for this device
    device_channels = optimized_channels(dev, :);
    
    % Plot the device's channel usage over time (y-axis = channel, x-axis = time)
    plot(1:num_time_steps, device_channels, '-o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k', 'LineWidth', 2);
end

title('Optimized Channel Assignments for Devices');
xlabel('Time');
ylabel('Channel Assignment');
grid on;
hold off;
