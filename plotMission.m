
ft2m = .3048;
m2nmi = .000539957;
N2lbf = .2248;
fpm2ms = .00508;
%Show power vs total power
figure()
plot(mission_history(:,10)./1e6, 'b');
hold on
plot(mission_history(:,11)./1e6, 'r');
xlabel('Mission Segment');
ylabel('Total power (MW)');
legend('Flight Power Required', 'Max power available (TT4 = 1525)', 'Location', 'SouthEast');

figure()
%Show flight profile
plot(mission_history(:,3).*m2nmi, mission_history(:,4)/(100*ft2m));
xlabel('Range (nmi)');
ylabel('Altitude (ft/100)');
axis equal

figure()
%Show cumulative fuel burn
plot(mission_history(:,3).*m2nmi, mission_history(:,2)*N2lbf);
xlabel('Range (nmi)');
ylabel('Fuel (lbf)');

figure()
%Show gross weight
plot(mission_history(:,3).*m2nmi, mission_history(:,14)*N2lbf);
xlabel('Range (nmi)');
ylabel('Gross Weight (lbf)');

figure()
%Show CL
plot(mission_history(:,3).*m2nmi, mission_history(:,9));
xlabel('Range (nmi)');
ylabel('CL');

figure()
%Show roc
plot(mission_history(:,3).*m2nmi, mission_history(:,5)/fpm2ms);
xlabel('Range (nmi)');
ylabel('roc (m/s)');