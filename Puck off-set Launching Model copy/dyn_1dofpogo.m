function xdot = dyn_1dofpogo(t,x,F,p)
% xdot = dyn_1dofpogo(t,x,F,p)
% simple spring-mass-damper system, used to model the stance phase of a
% bounce
%
% Input parameters:
% t: time
% x: state
% F: Forcing function (takes time and state as parameters)
% p: system parameters, of which the necessary elements are
%	p.g - the gravitational constant 
%	p.m - ball mass
%	p.spring - the effective stiffness of the ball
%	p.damper - the effective damping in the ball


	% state is position, velocity

	compression = p.l-x(1); %compression of the ball
	compression_v = x(2);   %compression velocity of the ball

	% state derivative is velocity, accelleration. Force on the ball is
	% mostly from spring and damping effects due to compression, but
	% gravity plays a small role, as does any externally applied force
	
	xdot(1,1) = x(2);
	xdot(2,1) = (p.k*compression)/p.m + F(t,x)/p.m;
	
end