%%%%%%%%%%%%%%%%%%%%%%%%%
% NOMA Multi-Rate Multicast Configuration Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%
%
UserNum = 60; % Total number of users
CellRadius = 200; % Cell radius in meters
BsTransmitPower_W = 10; % Base station transmission power in Watts
NomaPowerRatio = 0.8; % Power allocation factor for NOMA (allocated to high-priority layer)
PathLossExp = 4; % Path-loss exponent
CarrierFreq_GHz = 2; % Carrier frequency in GHz
LightSpeed = 3e8; % Speed of light in m/s (using MATLAB's built-in constant)
WaveLength = LightSpeed / (CarrierFreq_GHz * 1e9);
PathLossConst = (4 * pi / WaveLength)^2; % Path loss constant
SimNum = 10000; % Number of Monte Carlo simulations
NoisePower_dBm = -174; % Noise power in dBm/Hz
BsTransmitSnr_dB = [0, 5, 10, 15, 20, 25, 30, 35, 40]; % SNR values in dB

FirstDataLayerMulticastRate = 0.5; % Multicast rate for the first data layer (b/s/Hz)
SecondDataLayerMulticastRate = 1; % Multicast rate for the second data layer (b/s/Hz)

AveMulticastRate = zeros(1, length(BsTransmitSnr_dB)); % Initialize average multicast rate

% Simulation for average multicast rate calculation
for SnrLoop = 1:length(BsTransmitSnr_dB)
   SumRateCounter = 0;
   for SimLoop = 1:SimNum
      TransmitSnrTemp = 10^(BsTransmitSnr_dB(SnrLoop) / 10);
      Distance = CellRadius * rand(1, UserNum); 
      PathLoss = PathLossConst * Distance.^(-PathLossExp);
      SmallScaleFad = normrnd(0, 1, [1, UserNum]); 

      % SNIR calculations for both data layers
      UserDecodeL1Sinr = (abs(SmallScaleFad).^2 .* PathLoss * NomaPowerRatio * TransmitSnrTemp) ...
                         ./ (abs(SmallScaleFad).^2 .* PathLoss * (1 - NomaPowerRatio) * TransmitSnrTemp + 1);
      UserDecodeL2Sinr = (abs(SmallScaleFad).^2 .* PathLoss * (1 - NomaPowerRatio) * TransmitSnrTemp); 

      % Instantaneous rate calculations for all users
      UserDecodeL1InstRate = log2(1 + UserDecodeL1Sinr);
      UserDecodeL2InstRate = log2(1 + UserDecodeL2Sinr);
      
      % Check if the rates satisfy the multicast rate requirements
      for UserLoop = 1:UserNum
         if UserDecodeL1InstRate(UserLoop) >= FirstDataLayerMulticastRate
            SumRateCounter = SumRateCounter + UserDecodeL1InstRate(UserLoop);
         end
         if UserDecodeL1InstRate(UserLoop) >= FirstDataLayerMulticastRate && ...
            UserDecodeL2InstRate(UserLoop) >= SecondDataLayerMulticastRate
            SumRateCounter = SumRateCounter + UserDecodeL2InstRate(UserLoop);
         end
      end    
   end

   AveMulticastRate(SnrLoop) = SumRateCounter / (SimNum * UserNum);
end

% Plotting the average multicast rate
figure;
plot(BsTransmitSnr_dB, AveMulticastRate, 'b-o');
xlabel('Base Station Transmit SNR (dB)');
ylabel('Average Multicast Rate (b/s/Hz)');
title('NOMA Average Multicast Rate vs SNR');
legend('Average Multicast Rate');
grid on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outage Probability Calculation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following code is intended for calculating the outage probability.
% It should be completed and verified for accuracy.
% Currently, this section is a placeholder and requires implementation.
