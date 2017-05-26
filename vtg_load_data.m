% Vertigo
%
% Jon Sowman 2017
% jon+vertigo@jonsowman.com

% Get raw data
[csvfile, csvpath] = uigetfile('*.csv');
csvdata = csvread([csvpath csvfile]);

% Split into GPS and IMU data
gpsidx = find(csvdata(:,2) == 1);
imuidx = find(csvdata(:,2) == 2);
quatidx = find(csvdata(:,2) == 3);
gpsdata = csvdata(gpsidx, :);
imudata = csvdata(imuidx, :);
quatdata = csvdata(quatidx, :);

% Adjust all times
gpsdata(:,1) = (gpsdata(:,1) - gpsdata(1,1)) / 1000;
imudata(:,1) = (imudata(:,1) - imudata(1,1)) / 1000;
quatdata(:,1) = (quatdata(:,1) - quatdata(1,1)) / 1000;

% Do quaternion->Euler conversion
euldata = zeros(length(quatdata), 3);
for i = 1:length(quatdata)
    euldata(i,:) = vtg_quat2eul(quatdata(i,3:6));
end
%euldata = vtg_quat2eul(quatdata);
t = imudata(:,1); %Time Variable
pdegree = 1; %Polyfit Degree of X
% Acceleration Polyfit
px = polyfit(imudata(:,1), imudata(:,3), pdegree);
ppx = polyval(px, t);

py = polyfit(imudata(:,1), imudata(:,4), pdegree);
ppy = polyval(py, t);

pz = polyfit(imudata(:,1), imudata(:,5), pdegree);
ppz = polyval(pz, t);

% 1st Integrals
qx = polyint(px);
qqx = polyval(qx, t);
qy = polyint(py);
qqy = polyval(qy, t);
qz = polyint(pz);
qqz = polyval(qz, t);
subplot(5,1,2);
plot(t, qqx, t, qqy, t, qqz);
xlabel('Time (s)');
ylabel('Velocity (ms^-1)');
legend('x', 'y', 'z');  

% 2nd Integrals
rx = polyint(qx);
rrx = polyval(rx, t);
ry = polyint(qy);
rry = polyval(ry, t);
rz = polyint(qz);
rrz = polyval(rz, t);
subplot(5,1,1);
plot(t, rrx, t, rry, t, rrz);
xlabel('Time (s)');
ylabel('Displacement (m)');
legend('x', 'y', 'z');  

% Plot raw imu data
% Accelerations
subplot(5,1,3);
plot(imudata(:,1), imudata(:,3:5));
% Plot Acceleration Regression Line
hold on;
plot(t, ppx, '--', t, ppy, '--', t, ppz, '--');
xlabel('Time (s)');
ylabel('Acceleration (g)');
legend('x', 'y', 'z');

% Rate gyros
subplot(5,1,4);
plot(imudata(:,1), imudata(:,6:8));
xlabel('Time (s)');
ylabel('Gyro (deg/s)');
legend('x', 'y', 'z');

% Plot DMP data
subplot(5,1,5);
plot(quatdata(:,1), euldata);
xlabel('Time (s)');
ylabel('Orientation (deg)');
legend('roll', 'pitch', 'yaw');