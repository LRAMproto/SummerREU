function xdot = dyn_3dofpogo(t,x,F,p)
%This function illustrates the offset of the tethers effect when the tether
%becomes taught and causes angular velocity 
% Input parameters:
% t: time
% x: state
% F: Forcing function (takes time and state as parameters)
% p: system parameters, of which the necessary elements are
%	p.m - puck mass
%	p.k - the effective stiffness of the tether
%	p.l - the length of the tether 
%   p.r - the radius of the puck 

LCM = x(1);         %LCM: distance from the puck center of mass to the origin 
LCM_v = x(2);       %LCM_v: the rate at which the distance from the puck center of mass to the origin is changing 
phi = x(3);         %phi: the angle between the distance of p.o and LCM  
phi_v = x(4);       %phi_v: the rate at which the the angle between the distance of the tether attachment point to the center of mass and LCM is changing 
theta1 = x(5);      %theta1: the angle between LCM and the horizontal  
theta1_v = x(6);    %theta1_v: the rate at which the angle between the LCM and the horizontal are changing 



A = phi - theta1;   %A: the angle between p.o and the horizontal 

theta2 = atan((LCM*sin(theta1)+ p.o*sin(A))/(LCM*cos(theta1)-p.o*cos(A)));  %theta2: the angle between the tether the horizontal 

theta3 = theta2 - theta1; %theta3: the angle between the tether and LCM 

S = sqrt((LCM*cos(theta1) - p.o*cos(A))^2 + (LCM*sin(theta1)+p.o*sin(A))^2); %S: the length of the stretched tether



xdot(1,1) = x(2);                                                       %the rate at which LCM is changing at a specific point in time
xdot(2,1) = -p.k*(S*cos(theta3)-p.l*cos(theta3))/p.m;                   %the acceleration of LCM at a specific point in time
xdot(3,1) = x(4);                                                       %the rate at which phi is changing at a specific point in time
xdot(4,1) = -p.k*((S*cos(theta3)-p.l*cos(theta3))*p.o*sin(phi))/p.i1;   %the acceleration of phi at a specific point in time 
xdot(5,1) = x(6);                                                       %the rate at which theta1 is changing at a specific point in time   
xdot(6,1) = (p.k*S*sin(theta3)*LCM)/p.i2;                               %the acceleration at which theta1 is changing at a specific point in time 

	
end