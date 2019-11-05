% This post-processing script, reads timing data from .csv files generated
% by the C++ code. This script can be used either with Matlab or Octave.

% The post-processing is based on Chapter 9, Section 9.3.2 from the book
% Introduction to High Performance Computing for Scientists and Engineers
% by Hager, Wellein

%graphics_toolkit ("gnuplot") % to be used only with Octave

format long

% For weak scaling tests, the number of nodes per process are the same.
L_ = 240; % total number of nodes per process per dimension. Therefore total nodes = L_^3.

MPI_process_vector = [1,2,3,4,6,8,12,16]; % Number of MPI process
Num_simulation = length(MPI_process_vector);

% The computational work is calculated in terms of number of lattice site
% updates (in millions) per sec. The terminology used is as follows:
% LUP = number of lattice site updates
% MLUP = number of lattice site updates in millions = LUP/10^6
% MLUPs = number of lattice site updates in millions per sec = MLUPs/Time(sec)

%% Extract data

MLUPs_vec = zeros(1,Num_simulation);
Comm_time_vec = zeros(1,Num_simulation);

for sitr = 1:length(MPI_process_vector)    
Procs = MPI_process_vector(sitr);

Comm_time = []; % First column of timing.csv is the communication time
Jacobi_time = []; % Second column of timing.csv is the jacobi solver time

for pitr=1:Procs
    log = strcat('timing',num2str(pitr-1),'.csv');
    %fprintf("file = %s\n",log);
    temp = csvread(strcat('./NN',num2str(L_),'/proc',num2str(Procs),'/',log),0,0);
    Comm_time = [Comm_time temp(:,1)];
    Jacobi_time = [Jacobi_time temp(:,2)];
end

% exclude the first iteration, as it may involve communication jitter that
% can pollute the average
Comm_time = Comm_time(2:end,:);
Jacobi_time = Jacobi_time(2:end,:);
Total_time = Comm_time + Jacobi_time;

Comm_time_max = max(Comm_time,[],2);
Comm_time_min = min(Comm_time,[],2);
Jacobi_time_max = max(Jacobi_time,[],2);
Jacobi_time_min = min(Jacobi_time,[],2);
Total_time_max = max(Total_time,[],2);
Total_time_min = min(Total_time,[],2);

avg_Comm_time_max = mean(Comm_time_max);
avg_Comm_time_min = mean(Comm_time_min);
avg_Jacobi_time_max = mean(Jacobi_time_max);
avg_Jacobi_time_min = mean(Jacobi_time_min);
avg_Total_time_max = mean(Total_time_max);
avg_Total_time_min = mean(Total_time_min);

% The average of the maximum communication time is taken as the
% charateristic communication time of the simulation
% Average is taken over the number of iterations
% Maximum is taken over all the process ranks
Comm_time_vec(sitr) = avg_Comm_time_max;

LUPs = L_^3*Procs; 
MLUPs = LUPs/10^6;
MLUPs_vec(sitr) = MLUPs/avg_Total_time_max;
fprintf("Procs = %.2e, MLUPs/sec = %.3e, Avg max comm time = %.3e, Avg max time = %.3e, Slowdown = %.3e\n",...
    Procs, MLUPs_vec(sitr), avg_Comm_time_max, avg_Total_time_max, MLUPs_vec(1)*Procs/MLUPs_vec(sitr));

end

%% Plotting
figure(L_);
font = 20;
subplot(1,2,1);
plot(MPI_process_vector, MLUPs_vec(1)*MPI_process_vector, '-sk');
hold on
plot(MPI_process_vector, MLUPs_vec, '-ob');
xlabel('Number of nodes (with 1 process per node)', 'FontSize', font);
ylabel('Performance [MLUPs/sec]', 'FontSize', font);
legend('Linear',strcat(num2str(L_),' nodes per process per dimension'));
set(gca,'FontSize',font);

subplot(1,2,2);
hold on
plot(MPI_process_vector, Comm_time_vec,'-ob');
xlabel('Number of nodes (with 1 process per node)', 'FontSize', font);
ylabel('Communication time (sec)', 'FontSize', font);
set(gca,'FontSize',font);

% Estimation of latency (Tl) and bandwidth (B)
% MPID = size of MPI_DOUBLE
% cLk = (L_^2*2*MPID/B+Tl)
k = [2 2 4 4 6 6 6]; % k = 0 corresponds to 1 process and is therefore excluded
if(L_==120)
    cLk120 = Comm_time_vec(2:end)./k;
end
if(L_==240)
    cLk240 = Comm_time_vec(2:end)./k;
end

% To  estimate the latency and bandwidth run this script for L_ = 120 and
% 240 and finally execute the below code in if condition
if(0)
MPID = 8;
B = 3*120^2*2*MPID./(cLk240-cLk120);
fprintf("Bandwidth in MB/s for the : ")
fprintf("%f ",B/10^6);
Tl = cLk120 - 120^2*2*MPID./B;
fprintf("\nLatency in sec : ");
fprintf("%e ",Tl);
fprintf("\n");
end