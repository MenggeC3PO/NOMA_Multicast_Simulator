%%%%%%%%%%%%%%%%%%%%%%%%%
% NOMA Hybrid Multi-Service Multicast Configuration Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%
% Configuration for NOMA (Non-Orthogonal Multiple Access) hybrid multi-service multicast.
% Two types of users are considered: Type I for high-priority (e.g., mobile video users) and
% Type II for standard-priority (e.g., fixed television receivers).

UserNum = 60; % Total number of users
UserNumTypeI = UserNum / 2; % Number of Type I users
UserNumTypeII = UserNum / 2; % Number of Type II users
CellRadius = 200; % Cell radius in meters
BsTransmitPower_W = 10; % Base station transmission power in Watts
NomaPowerRatio = 0.8; % Power allocation factor for NOMA (allocated to high-priority layer)
PathLossExpTypeI = 4; % Path-loss exponent for Type I users
PathLossExpTypeII = 2.5; % Path-loss exponent for Type II users
Pi = 3.1415926;
CarrierFreq_GHz = 2; % Carrier frequency in GHz
LightSpeed = 300000000; % Speed of light in m/s
WaveLength = LightSpeed / (CarrierFreq_GHz * 10^9); % Wavelength calculation
PathLossConst = (4 * Pi / WaveLength)^2; % Path loss constant
SimNum = 10000; % Number of Monte Carlo simulations
NoisePower_dBm = -174; % Noise power in dBm/Hz

BsTransmitSnr_dB = [0, 5, 10, 15, 20, 25, 30, 35, 40]; % SNR values in dB

FirstDataLayerMulticastRate = 0.5; % Multicast rate for the first data layer (b/s/Hz)
SecondDataLayerMulticastRate = 1; % Multicast rate for the second data layer (b/s/Hz)

AveMulticastRate = zeros(1, length(BsTransmitSnr_dB)); % Average multicast rate initialization

% Simulation loop for calculating the average multicast rate
for SnrLoop = 1:length(BsTransmitSnr_dB)
   SumRateCounter = 0;
   for SimLoop = 1:SimNum
      TransmitSntTemp = 10^(BsTransmitSnr_dB(SnrLoop) / 10);
      
      % Random generation of user distances from the base station
      %% Type I Users
      DistanceTypeI = CellRadius * rand(1, UserNumTypeI); 
      PathLossTypeI = PathLossConst * DistanceTypeI.^(-PathLossExpTypeI);
      %% Type II Users
      DistanceTypeII = CellRadius * rand(1, UserNumTypeII); 
      PathLossTypeII = PathLossConst * DistanceTypeII.^(-PathLossExpTypeII);

      % Small-scale fading assumed to be Rayleigh fading
      SmallScaleFadTypeI = normrnd(0, 1, [1, UserNumTypeI]);
      SmallScaleFadTypeII = normrnd(0, 1, [1, UserNumTypeII]);

      % SNIR calculations for each user type and each layer
      UserTypeIDecodeL1Sinr = (abs(SmallScaleFadTypeI).^2 .* PathLossTypeI * NomaPowerRatio * TransmitSntTemp) ...
                              ./ (abs(SmallScaleFadTypeI).^2 .* PathLossTypeI * (1 - NomaPowerRatio) * TransmitSntTemp + 1);
                              
      UserTypeIIDecodeL1Sinr = (abs(SmallScaleFadTypeII).^2 .* PathLossTypeII * NomaPowerRatio * TransmitSntTemp) ...
                               ./ (abs(SmallScaleFadTypeII).^2 .* PathLossTypeII * (1 - NomaPowerRatio) * TransmitSntTemp + 1);

      UserTypeIIDecodeL2Sinr = abs(SmallScaleFadTypeII).^2 .* PathLossTypeII * (1 - NomaPowerRatio) * TransmitSntTemp;

      % Rate calculations and summation
      for UserLoop = 1:UserNumTypeI
         UserRateL1 = log2(1 + UserTypeIDecodeL1Sinr(UserLoop));
         if UserRateL1 >= FirstDataLayerMulticastRate
            SumRateCounter = SumRateCounter + UserRateL1; 
         end
      end
      
      for UserLoop = 1:UserNumTypeII
         UserRateL1 = log2(1 + UserTypeIIDecodeL1Sinr(UserLoop));
         UserRateL2 = log2(1 + UserTypeIIDecodeL2Sinr(UserLoop));
         
         if UserRateL1 >= FirstDataLayerMulticastRate
            SumRateCounter = SumRateCounter + FirstDataLayerMulticastRate; 
         end
         
         if UserRateL1 >= FirstDataLayerMulticastRate && UserRateL2 >= SecondDataLayerMulticastRate
            SumRateCounter = SumRateCounter + SecondDataLayerMulticastRate; 
         end
      end
   end

   AveMulticastRate(SnrLoop) = SumRateCounter / (SimNum * (UserNumTypeI + UserNumTypeII));
end

% Plotting the average multicast rate
figure;
plot(BsTransmitSnr_dB, AveMulticastRate);
xlabel('Base Station Transmit SNR (dB)');
ylabel('Average Multicast Rate (b/s/Hz)');
title('Average Multicast Rate versus SNR');
legend('Average Multicast Rate');
grid on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Multicast Outage Probability Calculation (requires modification)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following part of the code for outage probability is incomplete and requires further development.
% Additional code should include the logic for outage probability calculation similar to above average rate calculation.
