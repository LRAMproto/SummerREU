function xdot = dyn_1dofpogo(t,x,F,p)
% xdot = dyn_1dofpogo(t,x,F,p)
% simple spring-mass-damper system, used to model the stance phase of a
% tether 
%
% Input parameters:
% t: time
% x: state
% F: Forcing function (takes time and state as parameters)
% p: system parameters, of which the necessary elements are
%	p.m - puck mass
%	p.k - the effective stiffness of the tether
%	p.l - the length of the tether 
%   p.r - the radius of the puck 


	% state is position, velocity

	compression = p.l-x(1); %the length the tether has stretched
	compression_v = x(2);   %the velocity at which the tether is stretching 

	% state derivative is velocity, accelleration. Force on the puck is
	% mostly from spring and damping effects due to compression
	
	xdot(1,1) = x(2);
	xdot(2,1) = (p.k*compression)/p.m + F(t,x)/p.m; 
	
end