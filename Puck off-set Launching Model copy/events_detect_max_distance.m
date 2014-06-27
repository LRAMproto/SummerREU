function [value, isterminal, direction] = events_detect_max_distance(t,x,F)
% [value, isterminal, direction] = events_detect_max_distance(t,x,F)
% This is an event function of the type used by Matlab's ODE routines. It
% detects when a tethered puck reaches the maximum distance away from the
% launcher. 
%
% Input parameters:
% t: time (unused)
% x: state
% F: Forcing function (takes time and state as parameters) (unused)

	% Max value is when the velocity (second state variable) is zero
	value = x(2);

	% This is not a terminal condition
	isterminal = 0;

	% The velocity should be crossing from positive to negative
	direction = -1;

end 

