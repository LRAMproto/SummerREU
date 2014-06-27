function [value, isterminal, direction] = events_puckreturntest_launch(t,x,F,p)
% [value, isterminal, direction] = events_puckreturntest_launch(t,x,F,p)
% This is an event function of the type used by Matlab's ODE routines. It
% detects when a tethered puck position reached the length of the string 
% and is in direction back towards the launcher.   
%
% Input parameters:
% t: time (unused)
% x: state
% F: Forcing function (takes time and state as parameters) (unused)
% p: system parameters (of which the tether length p.l is necessary)

	% launch is when the tether is at it's full length 
	value = x(1)- p.l;

	%integration should stop at launch, when tether length is less than
	%full 
	isterminal = 1;

	%puck is returning back to launcher, tether length is less than full  
	direction = -1;

end