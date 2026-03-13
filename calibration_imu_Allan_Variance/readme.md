# IMU Noise Model Estimation

**Date:** March 13, 2026  
**Hardware:**
* **Handsfree TB100:** IMU @ 800Hz
* **RealSense D435i:** IMU @ 400Hz
* **Livox MID-360:** Internal IMU @ 200Hz

## 🚀 Overview
This project evaluates the noise characteristics of three different IMUs using Allan Variance analysis to determine the optimal sensor for SLAM (Simultaneous Localization and Mapping). 

**Key Finding:** Despite being located near the LiDAR's internal motor, the **Livox MID-360** internal IMU exhibits the best noise performance (lowest random walk). While the **TB100** offers a high 800Hz sampling rate, its noise density is significantly higher than the Livox.

## 🛠 Prerequisites & Environment
* **OS:** Ubuntu 20.04 (Noetic) / Docker
* **Toolbox:** [allan_variance_ros](https://github.com/ori-drs/allan_variance_ros)
* **Drivers:** `realsense2_camera`, `livox_ros_driver2`, `handsfree_ros_imu`

## 1. Data Characterization & Bag Validation
For accurate stochastic noise modeling, a long-duration static capture is required (ideally 3+ hours). This dataset contains ~50 minutes of stationary data, providing a sufficient approximation for commercial-grade MEMS sensors.

```bash
rosbag info /data/imu_2026-03-13-09-47-44.bag 
```

```text
path:        /data/imu_2026-03-13-09-47-44.bag
version:     2.0
duration:    49:16s (2956s)
start:       Mar 13 2026 13:47:44.30 (1773409664.30)
end:         Mar 13 2026 14:37:00.73 (1773412620.73)
size:        1.5 GB
messages:    4142463
compression: none [1954/1954 chunks]
types:       sensor_msgs/Imu [6a62c6daae103f4ff57a132d6f95cec2]
topics:      /camera/imu      1179537 msgs    : sensor_msgs/Imu
             /handsfree/imu   2371648 msgs    : sensor_msgs/Imu
             /livox/imu        591278 msgs    : sensor_msgs/Imu
```

**Topic Frequencies:**
```bash
./check_hzbag1.sh /data/imu_2026-03-13-09-47-44.bag 
```
```bash
----------------------------------------------------------------------------------------
Calculating topic frequencies for: /data/imu_2026-03-13-09-47-44.bag
Total Duration: 2956 seconds
----------------------------------------------------------------------------------------
Topic: /camera/imu                                        Frequency:  399.03 Hz
Topic: /handsfree/imu                                     Frequency:  802.32 Hz
Topic: /livox/imu                                         Frequency:  200.03 Hz

```
All desired topics were recorded correctly with sufficient duration.

```bash
roscore &
rqt_bag /data/imu_2026-03-13-09-47-44.bag

```
Three topics are not time-synchronized with each other. Especially, messages from /handsfree/imu are not equally distributed.


* 🖼 [Check Synchronization](rqt_bag.png)

## 2. Reorganize ROS messages by timestamp

```bash
rosrun allan_variance_ros cookbag.py --input original_rosbag --output cooked_rosbag
```

```bash
rosrun allan_variance_ros cookbag.py --input /data/imu_2026-03-13-09-47-44.bag --output ./my_bags/cooked_rosbag.bag

```
## 3. Run the Allan Variance computation tool

Prepare IMU config files for each IMU topic.
* 🚀 [TB100/acceleration](./imu_tb100/acceleration.png)
* 🧭 [TB100/gyro](./imu_tb100/gyro.png)
* 🚀 [RealSense D435i](./imu_d435i/acceleration.png)
* 🧭 [RealSense D435i](./imu_d435i/gyro.png)
* 🚀 [Livox MID-360](./imu_mid360/acceleration.png)
* 🧭 [Livox MID-360](./imu_mid360/gyro.png)

```bash
rosrun allan_variance_ros allan_variance my_bags imu_config.yaml
```

**Dataset imu_2026-03-13-09-47-44 Results:**
**Measured Noise Models:**
| IMU Topic | Accel Noise | Accel Walk | Gyro Noise | Gyro Walk | Rate |
| :--- | :--- | :--- | :--- | :--- | :--- |
| /livox/imu	| 0.0003	| 3.15E-06	| 0.00028	| 5.09E-06	| 200Hz |
| /handsfree/imu	| 0.00069	| 8.10E-06	| 0.00046	| 3.24E-06	| 800Hz |
| /camera/imu | 0.00169	| 2.52E-05	| 0.00018	| 1.50E-06	| 400Hz |


### Noise Model Summaries

In SLAM, we look for low Noise Density (white noise/jitter) and low Random Walk (bias instability/drift over time). 
Low random walk is particularly critical because it determines how quickly your trajectory will "drift" when external corrections (like loop closures or LIDAR matching) are unavailable.

## 4. Engineering Insights

1. For General SLAM (LIO-SAM, Fast-LIO): Use /livox/imu. Its superior accelerometer random walk minimizes trajectory drift over long distances. Note: Software low-pass filtering is recommended to mitigate potential motor-induced vibrations.
2. For High-Dynamics / UAVs: The /handsfree/imu is preferred. The 800Hz rate provides better integration for aggressive maneuvers and aids in LiDAR de-skewing, provided the EKF can handle the higher noise floor.
3. Sensor Limitation: Avoid the RealSense D435i IMU for primary odometry. While its gyroscope is remarkably stable, the high accelerometer noise leads to poor gravity alignment and pitch/roll divergence.
   
## 🔗 References

* [IMU Fundamentals, Part 4: Allan Deviation and IMU Error Modeling](https://www.tangramvision.com/blog/the-allan-deviation-and-imu-error-modeling-part-4-of-5)

