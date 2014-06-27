function log = off_center_tether_launch
% Code demonstrating using the hybrid_integrator function to model a
% puck attached to a tether, with the taut tether modeled as a spring
% contact and the tether attached to the puck at the center 

% Add the default relative location of the hybrid integrator files to the
% path
addpath('../') 

% Set the system parameters
p.r = 1;            % Radius of the puck
p.m = 1;            % Mass of the puck
p.k = 10000;        % Springiness of tether 
p.l = 1;            % Length of tether (taut but not stretched)
p.o = 1;            % Offset distance of tether on puck from center of mass
p.i1 = 1;           % Intertia of puck with respoct to the center of mass  
p.i2 = 1;           % Intertia of puck with respect to the origin  

% Build the system model structure
puck_model = model_tetheredpuck(p);

% Set the initial conditions
IC = [0;10;pi/2;0;0;0];       % Puck starting position, velocity, phi, phi_v, theta1, theta1_v 
Idomain = 'propelled';        % Physics domain in which to start

% Set the timespan
timespan = [0 0.2];

% Use a dummy force
forcing = @forces_zero;


%%%%%%%%%%%%%%
% Calculate the motion over the specified timespan
log = hybrid_integrator(puck_model,timespan,IC,Idomain,forcing,'array');


%%%%%%%%%%%%%
% Plot the output

% For this demo, the state is the same across all segments, so
% concatenation is simple even for the non-array cases
time = log.time;                % array
%time = cat(1,log.time{:});      % cell
%time = cat(2,log.sol(:).x)';    % solution

state = log.state;              % array
%state = cat(1,log.state{:});    % cell
%state = cat(2,log.sol(:).y)';   % solution

% Find all the local maxima, which are the at the (first) output of the
% (first) 'other' event function for the propelled mode
event_key = cat(1,log.event_key);
local_max_I = find_events(event_key,'propelled','other',1,1);

%abstract out the event time and state
event_time = log.event_time;
event_state = log.event_state;

%select only the position maxima
max_time = event_time(local_max_I);
max_state = event_state(local_max_I,:);

% A reasonably pretty plot of the output, in a figure unlikely to be
% occupied already
f = figure(17772);
clf(f)

h1 = axes('Position',[.15 .55 .75 .3]);
plot(time,state(:,1),'Color','r','LineWidth',3)
ylabel('distance from launcher','FontSize',14)
title('Puck Off-Centered Launching Model','FontSize',14)
line('XData',max_time(2:end),'YData',max_state(2:end,1),...
	'Marker','o','Color',[100 100 118]/255,'MarkerSize',10,...
	'LineStyle','none','LineWidth',2)
set(h1,'FontSize',14)

h2 = axes('Position',[.15 .15 .75 .3]);
plot(time,state(:,2),'Color','k','LineWidth',3)
ylabel('velocity','FontSize',14)
xlabel('time','FontSize',14)
set(h2,'FontSize',14)



end