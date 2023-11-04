import numpy as np
import matplotlib.pyplot as plt

# NOMA Hybrid Multi-Service Multicast Configuration Parameters
UserNum = 60
UserNumTypeI = UserNum // 2
UserNumTypeII = UserNum // 2
CellRadius = 200
BsTransmitPower_W = 10
NomaPowerRatio = 0.8
PathLossExpTypeI = 4
PathLossExpTypeII = 2.5
Pi = np.pi
CarrierFreq_GHz = 2
LightSpeed = 3e8
WaveLength = LightSpeed / (CarrierFreq_GHz * 1e9)
PathLossConst = (4 * Pi / WaveLength)**2
SimNum = 10000
NoisePower_dBm = -174

BsTransmitSnr_dB = np.array([0, 5, 10, 15, 20, 25, 30, 35, 40])
FirstDataLayerMulticastRate = 0.5
SecondDataLayerMulticastRate = 1

AveMulticastRate = np.zeros(len(BsTransmitSnr_dB))

# Simulation loop for calculating the average multicast rate
for SnrIndex, Snr_dB in enumerate(BsTransmitSnr_dB):
    SumRateCounter = 0
    TransmitSnrTemp = 10**(Snr_dB / 10)

    for _ in range(SimNum):
        DistanceTypeI = CellRadius * np.random.rand(UserNumTypeI)
        PathLossTypeI = PathLossConst * DistanceTypeI**(-PathLossExpTypeI)
        DistanceTypeII = CellRadius * np.random.rand(UserNumTypeII)
        PathLossTypeII = PathLossConst * DistanceTypeII**(-PathLossExpTypeII)

        SmallScaleFadTypeI = np.random.randn(UserNumTypeI)
        SmallScaleFadTypeII = np.random.randn(UserNumTypeII)

        UserTypeIDecodeL1Sinr = (abs(SmallScaleFadTypeI)**2 * PathLossTypeI * NomaPowerRatio * TransmitSnrTemp) / \
                                (abs(SmallScaleFadTypeI)**2 * PathLossTypeI * (1 - NomaPowerRatio) * TransmitSnrTemp + 1)

        UserTypeIIDecodeL1Sinr = (abs(SmallScaleFadTypeII)**2 * PathLossTypeII * NomaPowerRatio * TransmitSnrTemp) / \
                                 (abs(SmallScaleFadTypeII)**2 * PathLossTypeII * (1 - NomaPowerRatio) * TransmitSnrTemp + 1)

        UserTypeIIDecodeL2Sinr = abs(SmallScaleFadTypeII)**2 * PathLossTypeII * (1 - NomaPowerRatio) * TransmitSnrTemp

        UserRateL1TypeI = np.log2(1 + UserTypeIDecodeL1Sinr)
        UserRateL1TypeII = np.log2(1 + UserTypeIIDecodeL1Sinr)
        UserRateL2TypeII = np.log2(1 + UserTypeIIDecodeL2Sinr)

        SumRateCounter += np.sum(UserRateL1TypeI[UserRateL1TypeI >= FirstDataLayerMulticastRate])
        SumRateCounter += np.sum(FirstDataLayerMulticastRate * (UserRateL1TypeII >= FirstDataLayerMulticastRate))
        SumRateCounter += np.sum(SecondDataLayerMulticastRate * (UserRateL1TypeII >= FirstDataLayerMulticastRate) * (UserRateL2TypeII >= SecondDataLayerMulticastRate))

    AveMulticastRate[SnrIndex] = SumRateCounter / (SimNum * (UserNumTypeI + UserNumTypeII))

# Plotting the average multicast rate
plt.figure()
plt.plot(BsTransmitSnr_dB, AveMulticastRate, 'b-o')
plt.xlabel('Base Station Transmit SNR (dB)')
plt.ylabel('Average Multicast Rate (b/s/Hz)')
plt.title('Average Multicast Rate versus SNR')
plt.legend(['Average Multicast Rate'])
plt.grid(True)
plt.show()
