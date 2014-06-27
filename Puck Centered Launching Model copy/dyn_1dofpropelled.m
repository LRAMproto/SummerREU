function xdot = dyn_1dofpropelled(t,x,F,p)
% xdot = dyn_1dofballistics(t,x,F,p)
% simple 1 dof ballistics under specified gravity
%
% Input parameters:
% t: time
% x: state
% F: Forcing function (takes time and state as parameters)
% p: system parameters (of which the gravitational constant p.g and mass p.m are necessary)

    xdot(1,1) = x(2);   %the rate at which LCM is changing at a specific point in time
    xdot(2,1) = 0;      %the acceleration of LCM at a specific point in time (which is zero due to no acceleration) 
    xdot(3,1) = x(4);   %the rate at which phi is changing at a specific point in time
    xdot(4,1) = 0;      %the acceleration of phi at a specific point in time (which is zero due to no acceleration) 
    xdot(5,1) = x(6);   %the rate at which theta1 is changing at a specific point in time
    xdot(6,1) = 0;      %the acceleration at which theta1 is changing at a specific point in time (which is zero due to no acceleration) 

end
