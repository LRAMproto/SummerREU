function xdot = dyn_1dofpropelled(t,x,F,p)
% xdot = dyn_1dofballistics(t,x,F,p)
% simple 1 dof ballistics under specified gravity
%
% Input parameters:
% t: time
% x: state
% F: Forcing function (takes time and state as parameters)
% p: system parameters (of which the gravitational constant p.g and mass p.m are necessary)

% state is position, velocity
% state derivative is velocity, gravitational acceleration

	xdot(1,1) = x(2);
	xdot(2,1) = F(t,x)/p.m;

end
