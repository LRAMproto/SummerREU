function [value, isterminal, direction] = events_tetheredpuck_stretch(t,x,F,p)
% [value, isterminal, direction] = events_ballbouncetest_impact(t,x,F,p)
% This is an event function of the type used by Matlab's ODE routines. It
% detects when a tethered puck reaches when the distance of the puck is
% that distance away from the launcher. 
%
% Input parameters:
% t: time
% x: state
% F: Forcing function (takes time and state as parameters)
% p: system parameters (of which the puck radius p.r is necessary)

	% impact is when when the string is at its full length 
	value = x(1)- p.l;  

	% integration should stop at tautness
	isterminal = 1;

	% puck is moving away from launcher 
	direction = 1;

end
