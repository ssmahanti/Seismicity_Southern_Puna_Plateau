%*************************************************************************%
%                                                                         %
%  script INPUT_PARAMETERS                                                %
%                                                                         %
%  list of input parameters needed for the inversion                      %
%                                                                         %
%*************************************************************************%
%--------------------------------------------------------------------------
% input file with focal mechnaisms
%--------------------------------------------------------------------------
input_file = '../Data/v5/puna_mech_all_v5.dat';

%--------------------------------------------------------------------------
% output file with results
%--------------------------------------------------------------------------
output_file = '../Output/v5/puna_mech_all_v5';

% ASCII file with calculated principal mechanisms
principal_mechanisms_file = '../Output/v5/puna_mech_all_v5';
%--------------------------------------------------------------------------
% accuracy of focal mechansisms
%--------------------------------------------------------------------------
% number of random noise realizations for estimating the accuracy of the
% solution
N_noise_realizations = 200;

% estimate of noise in the focal mechanisms (in degrees)
% the standard deviation of the SP distribution of
% errors
mean_deviation = 15;

%--------------------------------------------------------------------------
% figure files
%--------------------------------------------------------------------------
shape_ratio_plot = '../Figures/v5/shape_ratio_all_puna_v5';
stress_plot      = '../Figures/v5/stress_directions_all_puna_v5';
P_T_plot         = '../Figures/v5/P_T_axes_all_puna_v5';
Mohr_plot        = '../Figures/v5/Mohr_circles_all_puna_v5';
faults_plot      = '../Figures/v5/faults_all_puna_v5';

%--------------------------------------------------------------------------
% advanced control parameters (usually not needed to be changed)
%--------------------------------------------------------------------------
% number of iterations of the stress inversion 
N_iterations = 6;

% number of initial stres inversions with random choice of faults
N_realizations = 10;

% axis of the histogram of the shape ratio
shape_ratio_min = 0;
shape_ratio_max = 1;
shape_ratio_step = 0.025;

shape_ratio_axis = shape_ratio_min:shape_ratio_step:shape_ratio_max;

% interval for friction values
friction_min  = 0.20;
friction_max  = 1.40;
friction_step = 0.05;



