% NOMA Multi-Service Multicast Configuration Parameters
% Simulates a NOMA system for two types of service classes
% Class I (high priority) corresponds to data layer 1 (service 1)
% Class II (low priority) corresponds to data layer 2 (service 2)

UserNum = 60; % Total number of users
UserNumTypeI = UserNum / 2; % Number of Class I users
UserNumTypeII = UserNum / 2; % Number of Class II users
CellRadius = 200; % Cell radius in meters
BsTransmitPower_W = 10; % Base station transmission power in Watts
NomaPowerRatio = 0.8; % Power allocation ratio for NOMA (allocated to high-priority layer)
PathLossExpTypeI = 4; % Path-loss exponent for Class I
PathLossExpTypeII = 2.5; % Path-loss exponent for Class II
Pi = pi; % Use MATLAB's built-in value for pi
CarrierFreq_GHz = 2; % Carrier frequency in GHz
LightSpeed = 3e8; % Speed of light in m/s (use MATLAB's built-in constant)
WaveLength = LightSpeed / (CarrierFreq_GHz * 1e9); % Wavelength calculation
PathLossConst = (4 * Pi / WaveLength)^2; % Path loss constant
SimNum = 10000; % Number of Monte Carlo simulations
NoisePower_dBm = -174; % Noise power in dBm/Hz
BsTransmitSnr_dB = [0, 5, 10, 15, 20, 25, 30, 35, 40]; % SNR values in dB

FirstDataLayerMulticastRate = 0.5; % Multicast rate for the first data layer (b/s/Hz)
SecondDataLayerMulticastRate = 1; % Multicast rate for the second data layer (b/s/Hz)

AveMulticastRate = zeros(1, length(BsTransmitSnr_dB)); % Initialize average multicast rate

% Simulation loop
for SnrLoop = 1:length(BsTransmitSnr_dB)
    SumRateCounter = 0;
    for SimLoop = 1:SimNum
        TransmitSnrTemp = 10^(BsTransmitSnr_dB(SnrLoop) / 10);
        DistanceTypeI = CellRadius * rand(1, UserNumTypeI); % Random user distances
        PathLossTypeI = PathLossConst * DistanceTypeI.^(-PathLossExpTypeI);
        DistanceTypeII = CellRadius * rand(1, UserNumTypeII); % Random user distances
        PathLossTypeII = PathLossConst * DistanceTypeII.^(-PathLossExpTypeII);

        % Simulate small-scale fading
        SmallScaleFadTypeI = randn(1, UserNumTypeI);
        SmallScaleFadTypeII = randn(1, UserNumTypeII);

        % Calculate SINR for both user types and data layers
        UserTypeIDecodeL1Sinr = (abs(SmallScaleFadTypeI).^2 .* PathLossTypeI * NomaPowerRatio * TransmitSnrTemp) ./ ...
                                (abs(SmallScaleFadTypeI).^2 .* PathLossTypeI * (1 - NomaPowerRatio) * TransmitSnrTemp + 1);
        UserTypeIIDecodeL1Sinr = (abs(SmallScaleFadTypeII).^2 .* PathLossTypeII * NomaPowerRatio * TransmitSnrTemp) ./ ...
                                 (abs(SmallScaleFadTypeII).^2 .* PathLossTypeII * (1 - NomaPowerRatio) * TransmitSnrTemp + 1);
        UserTypeIIDecodeL2Sinr = abs(SmallScaleFadTypeII).^2 .* PathLossTypeII * (1 - NomaPowerRatio) * TransmitSnrTemp;

        % Evaluate rates and accumulate
        for UserLoop = 1:UserNumTypeI
            UserRateL1 = log2(1 + UserTypeIDecodeL1Sinr(UserLoop));
            if
