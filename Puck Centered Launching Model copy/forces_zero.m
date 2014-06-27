function f = forces_zero(t,x,domain)
% f = forces_zero(t,x,domain)
% Simple forcing function that returns a scalar zero force for each
% configuration variable (half as many configuration variables as state)
%
% Input parameters:
% t: time (unused)
% x: state
% domain: the physics domain the system is in (unused)


	f = zeros(size(x).*[0.5 1]);

end