function log = hybrid_integrator(model,t,IC,domain,forces,output_style)
% log = hybrid_integrator(model,t,IC,domain,forces,output_style)
% Integrate the motion of a system with hybrid dynamics
%
% t is the timespan over which to return the system state
% model is a data structure describing the hybrid model
% IC is the vector of initial conditions for the system
% domain is the name of the initial dynamics model used
% forces is a function handle to the forcing function. This
%     function should accept time, state, and the name of the current
%     model as inputs, even if it doesn't use all of them
% transitions is a vector of handles to matlab ODE event functions that
%     encode the transition graph between the models
% integrators is a vector of handles to the differential equation solvers
%	to call for the different models
% output style is 'array','cell', or 'solution'. The first two options
%   group the motion into arrays or cell arrays of arrays (divided at the
%   switch points), while the last returns the integration results as an
%   array of Matlab ODE solutions.
%
% Author: Ross L. Hatton
% Release: 1.0
% Release Date: November 8, 2010


	%%%%%%%%%%%%%
	% Preprocess the model by replacing any empty event responses with a
	% null function
	
	% Get the names of all domains in the model
	domain_names = fieldnames(model);
	
	% Loop over all domains
	for i = 1:length(domain_names)
		
		% Pull out the structure of the domain
		d_struct = model.(domain_names{i});
		
		% Loop over all transition response functions
		for j = 1:length(d_struct.transition_response)
			
			% Loop over all outputs of each response function
			for k = 1:length(d_struct.transition_response{j})
				
				% Replace any empty function specifications with a null
				% response function
				if isempty(d_struct.transition_response{j}{k})
					
					d_struct.transition_response{j}{k} = @response_null;
					
				end
				
			end
			
		end
		
	end
	


	%%%%%%%%%%%
	% Run until the end of the time window is reached

	%Set the initial conditions
	t_start = t(1); % Time to start integration
	x_start = IC;                 % State initial conditions

	%Prepare the log -- different behavor based on the output style given
	
	log.model = model;
	log.domain_computation_time = [];
	
	switch output_style
		
		case 'array'
			
			log.time = [];
			log.state = [];
			log.domain = {};
			log.event_time = [];
			log.event_state = [];
			log.event_index = [];
			log.event_key = [];
			
		case 'cell'
				
			log.time = {};
			log.state = {};
			log.domain = {};
			log.event_time = {};
			log.event_state = {};
			log.event_index = {};
			log.event_key = {};

			
		case 'solution'
			
			log.domain = {};
			log.sol = [];
			
		otherwise
			
			error('''output_style'' should be ''array'', ''cell'', or ''solution''.')
			
	end
		

	% Record how long the integration took as a whole
	integration_start_time = tic;
	
	while t_start < t(end)
		
		% Record how long it takes to compute each integration
		domain_start_time = tic;
		
		%%%%%%%%%%%%%%
		% Load the active dynamics model
		current_model = model.(domain); % model being used
		F = @(t,x) forces(t,x,domain); % forcing function in effect
		
		%concatenate the event functions
		[eventfun,key] = eventconcat(domain,...
			current_model.transition_events,...
			current_model.other_events,...
			current_model.transition_to,...
			current_model.transition_response,...
			current_model.other_events_response,...
			F,x_start,t_start);

		% Set the trigger events and any other integrator options
		options = odeset('Events',eventfun,current_model.integrator_options{:});

		
		
		%%%%%%%%%%%%
		% Run the active dynamics model and put the output into the requested style
		
		% List the inputs according to the ODE input style
		integrator_arguments = {@(t,x) current_model.dynamics(t,x,F), [t_start,t(end)],...
					x_start,options};
		
		% Call the ODE integration function with syntax appropriate to the
		% desired output
		switch output_style
			
			% For array and cell output, the ODE function outputs should be
			% listed individually
			case {'array','cell'}
			
				% Actual ODE function call
				[temp_time, temp_state, temp_event_time, temp_event_state, temp_event_index] = ...
					current_model.integrator(integrator_arguments{:});
				
				% Set the next starting time
				t_start = temp_time(end); 

				% Concatenate the output from this segment into the log,
				% according to the output style
				switch output_style

					case 'array'

						log.time = [log.time; temp_time]; %note that matlab uses (x,y), for our (t,x);
						log.state = [log.state; temp_state];
						log.domain = [log.domain; repmat({domain},size(temp_time,1),1)]; % mark each row
						log.event_time = [log.event_time; temp_event_time];
						log.event_state = [log.event_state; temp_event_state];
						log.event_index = [log.event_index; temp_event_index];
						for i = 1:length(temp_event_index)
							log.event_key = [log.event_key; key(temp_event_index(i),:)];
						end

					case 'cell'

						log.time{end+1,1} = temp_time; %note that matlab uses (x,y), for our (t,x);
						log.state{end+1,1} = temp_state;
						log.domain{end+1,1} = domain;
						log.event_time{end+1,1} = temp_event_time;
						log.event_state{end+1,1} = temp_event_state;
						log.event_index{end+1,1} = temp_event_index;
						log.event_key{end+1,1} = cell(0,4);
						for i = 1:length(temp_event_index)
							log.event_key{end,1} = [log.event_key{end,1}; key(temp_event_index(i),:)];
						end

				end
			
			% Solution-style output puts all of the data from the
			% integration into its own structure
			case 'solution'
				
				% Actual ODE function call
				sol = current_model.integrator(integrator_arguments{:});
		
				% the ODE functions leave out the event time and state
				% fields if there are no events. To regularize the
				% structure format, we create these fields as empty arrays
				% if they are not already present
				if ~isfield(sol,'xe')
					sol.xe = [];
					sol.ye = [];
					sol.ie = [];
				end

				% Concatenate the log files
				log.sol = [log.sol; sol];
				log.domain{end+1,1} = domain;
				
				% Set the next starting time
				t_start = sol.x(end); 
				
				% Extract data from solution structure to feed to
				% termination checker
				temp_event_index = sol.ie';
				temp_state = sol.y';

			% If the output style was set to anything else, return an error
			otherwise
				
				error('''output_style'' should be ''array'', ''cell'', or ''solution''. Something in this function has modified this variable')
				
		end
				
		%%%%%%%%%%%%%%%%
		%Check if the output was terminated by a transition or another
		%event/time completion
		
		%Detect any events that occured
		if ~isempty(temp_event_index); 
		
			% Extract the final event
			final_event = temp_event_index(end);
		
			% If the integration sequence ended with a call for a
			% transition, prepare the conditions for the next integration run
			if strcmp(key{final_event,1},'transition')

				% Identify the new physics domain				
				domain_entry = current_model.transition_to{key{final_event,2}}...			
					{key{final_event,3}};
				
				% Take the name of the new domain as either the
				% domain_entry string, or the string that it evaluates to
				% as a function of time, state, and applied force
				switch class(domain_entry)
					
					case 'char'
						
						domain = domain_entry;
						
					case 'function_handle'
						
						domain = domain_entry(temp_time(end),temp_state(end,:),F);
						
				end
				
				%set the initial conditions for the next integration
				x_start = current_model.state_map.(domain)(temp_state(end,:)); % new starting state
			
			% If the last integration ended with a terminal non-transition,
			% all further integration should be stopped, and this program
			% ended with a warning	
			elseif key{final_event,4} == 1
			

				warning('Integration ended early with a non-transition terminal event') %#ok<WNTAG>
				break

			else

				% Time completed with only non-terminal events

			end
			
		else
			
			% Time completed with no events
			
		end

		% Save integration time to log structure
		log.domain_computation_time(end+1,1) = toc(domain_start_time);
		
	end
	
	% Save total integration time to log structure
	log.total_computation_time = toc(integration_start_time);


end

function response_null(t,x,F) %#ok<INUSD>
% Response functions allow for other functions to be triggered by
% transition events. If such a response is not needed, this function is
% substituted into the hybrid model for any responses given as empty arrays

	%This is a dummy function

end

function [eventfun,key] = eventconcat(domain,transition_events,other_events,...
	transition_to,transition_response,other_events_response,F,x_start,t_start)
%[eventfun,key] = eventconcat(domain,transition_events,other_events,...
%	transition_to,transition_response,other_events_response,F,x_start,t_start)
%
% Returns the handle to an event function that concatenates all the event
% functions specified for the system, and a key for decoding the output

	%%%%%%%%%%%
	% build the key, checking to make sure that the transition_to,
	% transition_response, and other_event_response values are consistent
	% with their functions
	
	key = cell(0,4); % prime the key structure
	
	% build key for transition events
	for i = 1:length(transition_events)
		 
		% test the events at start of integration
		[val,term] = transition_events{i}(t_start,x_start,F);
		
		% make sure transitions and results are consistent
		assert(length(val) == length(transition_to{i}),...
			'transition_events{%i} has %i outputs, but transition_to{%i} has %i entries',i,length(val),i,length(transition_to{i}))
		assert(length(val) == length(transition_response{i}),...
			'transition_events{%i} has %i outputs, but transition_response{%i} has %i entries',i,length(val),i,length(transition_to{i}))

		% if these numbers check out, then build the first part of the key
		for j = 1:length(val)
			
			key{end+1,1} = 'transition';    % Mark as transition
			key{end,2}   = i;    % Mark as ith transition event function
			key{end,3}   = j;    % Mark as jth event in function
			key{end,4} = term(j); % Mark if this is a terminal event
			key{end,5} = domain; % Include the name of the domain
			
		end
					
	end
	
	
	% loop over all other events
	for i = 1:length(other_events)
		 
		% test the events at start of integration
		[val,term] = other_events{i}(t_start,x_start,F);
		
		% make sure transitions and results are consistent
		assert(length(val) == length(other_events_response{i}),...
			'other_events{%i} has %i outputs, but other_events_response{%i} has %i entries',i,length(val),i,length(other_events_response{i}))

		% if these numbers check out, then build the first part of the key
		for j = 1:length(val)
			
			key{end+1,1} = 'other';    % Mark as other event
			key{end,2}   = i;    % Mark as ith other event function
			key{end,3}   = j;    % Mark as jth event in function
			key{end,4} = term(j); % Mark if this is a terminal event
			key{end,5} = domain; % Include the name of the domain
			
		end
			
	end
	
	
	eventfun = @(t,x) eventconcat_helper(t,x,F,transition_events,...
		other_events);

end

% Base function for concatenated events
function [value,isterminal,direction] = eventconcat_helper(t,x,F,...
	transition_events,other_events)

	value = [];
	isterminal = value;
	direction = value;

	for i = 1:length(transition_events)
		
		% Get the values for this event
		[valuet,isterminalt,directiont] = transition_events{i}(t,x,F);
		
		% Concatenate these values into the output 
		value = [value; valuet(:)]; % (:) forces column output
		isterminal = [isterminal; isterminalt(:)];
		direction = [direction; directiont(:)];
		
	end
		
	
	for i = 1:length(other_events)
		
		% Get the values for this event
		[valuet,isterminalt,directiont] = other_events{i}(t,x,F);
		
		% Concatenate these values into the output 
		value = [value; valuet(:)]; % (:) forces column output
		isterminal = [isterminal; isterminalt(:)];
		direction = [direction; directiont(:)];
		
	end
	
	
end