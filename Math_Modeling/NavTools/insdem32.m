%
%   insdem32.m
%
%   In version 2 of the toolbox, we specified flight maneuvers 
%   (i.e., pitch-up, roll, turn, etc). Now in version 3, we will
%   specify desired states (i.e., altitude, heading, airspeed).
%   Thus we will not specify a pitch-up segment, followed by a climb
%   segment, followed by a pitch-down (back to level) segment.
%   Instead we will simply specify a new desired altitude.  The same is
%   true for turning to a new heading.
%
%   One note of caution:  In this example you will see that there are two
%   'straight' segments at the beginning.  One accelerates from 0 up to 75
%   m/s.  The second accelerates from 75 m/s up to 200 m/s.  The reason for
%   this is the first segment is simulating the acceleration along the
%   runway prior to rotation (a.k.a., take-off).  The 6DOF does not work
%   for airspeeds that are at or below stall speed and thus a simple
%   constant acceleration is modeled 'along the runway' but then the 6DOF
%   is used when the aircraft is 'flying.'
%
%   GPSoft LLC
%   September 2007
%
%
clear all
close all

initpos = [100 200 50];   % initial position
initvtm = 0;   % initial airspeed in meters-per-second

% 
% Note that we are not free to specify pitch and roll since
% these will be dictated by the trim flight condition
initpsi=90*pi/180;       % initial yaw angle

% seg number; duration; v_final; climb_ang; turn-rate; heading_final;
% alt_final; Tinc=0.01s
flightsegf16 = [10 20 75 NaN NaN NaN NaN 0.01;  % Level accel up to 75 meters/sec
                5 NaN 200 NaN NaN 90 50 0.01;  % Level accel up to 200 meters/sec
                7 NaN NaN 15 NaN 90 2500 0.01; % 15 deg climb to altitude of 2500 meters
                5 10 200 NaN NaN 90 2500 0.01;  % Straight-and-level for 10 seconds
                9 NaN 200 NaN -3 270 2500 0.01; % -3 deg/s turn to heading of 270 deg
                5 10 200 NaN NaN 270 2500 0.01;  % Straight-and-level for 10 seconds
                7 NaN 200 -20 NaN 270 1500 0.01;  % -20 deg descent to 1500 meters
                5 20 200 NaN NaN 270 1500 0.01];  % Straight-and-level for 20 seconds

profile = profilef16(initpos,initvtm,initpsi,flightsegf16);
time = profile(:,19);   % run time in seconds

h = waitbar(0,'Calculating Euler Angles');
ntot = size(profile,1);
n = 0;
for k = 1:ntot,
    n = n + 1;
    dcmnb=[profile(k,10:12); profile(k,13:15); profile(k,16:18)];
    dcmbn=dcmnb';
    eulv=dcm2eulr(dcmbn);
    roll_deg(n) = eulv(1)*180/pi;
    pitch_deg(n) = eulv(2)*180/pi;
    yaw_deg(n) = eulv(3)*180/pi; 
    if yaw_deg(n) < 0, yaw_deg(n)=yaw_deg(n)+360; end
    time_eulr(n) = time(k);
    waitbar(k/ntot,h)
end
close(h)

figure
plot3(profile(:,1),profile(:,2),profile(:,3))
axis equal
title('Flight Path Generated By PROFILEF16')
xlabel('east (meters)')
ylabel('north (meters)')
zlabel('up (meters)')
grid

figure
subplot(311)
plot(time,profile(:,1))
title('INSDEM32: Position Components')
ylabel('east in meters')
subplot(312)
plot(time,profile(:,2))
ylabel('north in meters')
subplot(313)
plot(time,profile(:,3))
ylabel('vertical in meters')
xlabel('run time in seconds')

figure
subplot(311)
plot(time,profile(:,4))
title('INSDEM32: Velocity Components')
ylabel('east vel in m/s')
subplot(312)
plot(time,profile(:,5))
ylabel('north vel in m/s')
subplot(313)
plot(time,profile(:,6))
ylabel('vertical vel in m/s')
xlabel('run time in seconds')

figure
subplot(311)
plot(time_eulr,roll_deg)
title('INSDEM32: Euler Angles')
ylabel('roll angle in deg')
subplot(312)
plot(time_eulr,pitch_deg)
ylabel('pitch angle in deg')
subplot(313)
plot(time_eulr,yaw_deg)
ylabel('yaw angle in deg')
xlabel('run time in seconds')

