# Multi-Sensor Calibration: RealSense D435 & Livox Mid-360 IMU

**Date:** March 9, 2026
**Hardware:** Intel RealSense D435 (RGB) & Livox Mid-360 (Internal InvenSense ICM-40609 IMU)

## 📌 Overview

This project performs calibration between a camera and a LiDAR-embedded IMU. A key challenge addressed is the high noise floor introduced by the Mid-360's internal motor vibrations, which can cause standard datasheet-based calibrations to fail.

## 🛠 Prerequisites & Environment

* **OS:** Ubuntu 20.04 (Noetic) inside Docker
* **Toolbox:** [Kalibr](https://github.com/JunghoYoo/kalibr)
* **Sensor Drivers:** `realsense2_camera`, `livox_ros_driver2`

## 1. Data Characterization & Bag Validation

Before calibration, the recorded ROS bag was inspected to ensure correct message types, topic names, and sufficient data duration.

```bash
rosbag info /data/DataBag_2026-03-08-14-42-53/data.bag

```

```text
path:        /data/DataBag_2026-03-08-14-42-53/data.bag
version:     2.0
duration:    1:06s (66s)
messages:    18059
topics:      /camera/color/camera_info             1997 msgs    : sensor_msgs/CameraInfo     
             /camera/color/image_raw/compressed    1997 msgs    : sensor_msgs/CompressedImage
             /livox/imu                           13394 msgs    : sensor_msgs/Imu            
             /livox/lidar                           670 msgs    : livox_ros_driver2/CustomMsg
             /tf_static                               1 msg     : tf2_msgs/TFMessage

```

**Topic Frequencies:**
```bash
./script/check_hzbag.sh /data/DataBag_2026-03-08-14-42-53/data.bag

```
```bash
----------------------------------------------------------------------------------------
Calculating topic frequencies for: /data/DataBag_2026-03-08-14-42-53/data.bag
Total Duration: 66 seconds
----------------------------------------------------------------------------------------
Topic: /camera/color/image_raw/compressed                 Frequency:   30.26 Hz
Topic: /livox/imu                                         Frequency:  202.94 Hz
Topic: /livox/lidar                                       Frequency:   10.15 Hz
Topic: /tf_static                                         Frequency:    0.02 Hz
----------------------------------------------------------------------------------------
```
All desired topics were recorded correctly with sufficient duration.

```bash
rqt_bag /data/DataBag_2026-03-08-14-42-53/data.bag 

```

* 🖼 [Check Synchronization](rqt_bag.png)

## 2. Camera Intrinsic Calibration

Adjust the rosbag path, filename, and time in `run_camcal.sh`, then execute:

```bash
./run_camcal.sh

```

* 🖼 [Target Detection Visualization](tagdetection_cam.png)

### Calibration Summaries

Three datasets were collected to find the optimal intrinsic model. The **Pinhole-Radtan** model was selected based on the lowest RMSE (**0.298125 px**).

**Dataset 2026-03-08-14-42-53 Results:**
| MODEL | STATUS | RMSE (PIXELS) |
| :--- | :--- | :--- |
| **pinhole-radtan** | **SUCCESS** | **0.298125 px** |
| pinhole-equi | SUCCESS | 0.308822 px |

**Calibration Artifacts:**

* 📄 [Camera Intrinsic Report](data-report-cam.pdf)
* ⚙️ [Final Camera Chain YAML](data-camchain.yaml)
* 🖼 [Factory Calibration Information (rs-enumerate-devices -c)](realsense_factorycal.txt)

## 3. Camera-IMU Extrinsic Calibration

The IMU noise model was "inflated" beyond datasheet values to account for real-world mechanical vibration from the LiDAR motor.

### IMU Noise Configuration

* ⚙️ [Livox Mid-360 IMU Config (imu_livox_mid360.yaml)](imu_livox_mid360.yaml)

```bash
# Note: Increasing 'max-iter' can improve convergence.
# Warning: Setting IMU noise too low may lead to optimization failure.
rosrun kalibr kalibr_calibrate_imu_camera \
--target /data/april_6x6_lunarlab.yaml \
--imu /data/imu_livox_mid360.yaml \
--imu-models calibrated \
--cam /data/DataBag_2026-03-08-14-42-53/results/pinhole-radtan_single/data-camchain.yaml \
--bag /data/DataBag_2026-03-08-14-42-53/data.bag \
--max-iter 30

```

## 4. Final Results

The optimization achieved sub-pixel accuracy and identified a stable time offset.

### Residuals

* **Reprojection Error (Mean):** 0.8511 px
* **Gyroscope Error (Mean):** 0.0165 rad/s
* **Accelerometer Error (Mean):** 1.3658 m/s²

### Transformation $T_{cam0\_imu0}$ (IMU to Camera)

```text
[[ 0.01115756, -0.99980799,  0.0161085,   0.05985381],
 [ 0.3396543,  -0.01136222, -0.94048171,  0.2311032 ],
 [ 0.94048416,  0.0159648,   0.33946231,  0.04132155],
 [ 0.0,         0.0,         0.0,         1.0       ]]

```

* **Time Shift:** 0.01027s (Camera leads IMU)

**Results Artifacts:**

* 🖼 [Joint Detection Visualization](tagdetection_camimu.png)
* 📄 [Final Calibration PDF Report](data-report-imucam.pdf)

## 5. Engineering Insights

1. **Vibration Handling:** Using datasheet-only values for the ICM-40609 often fails in Kalibr due to LiDAR motor noise. Inflating the noise density allowed the solver to prioritize visual features while maintaining physical motion trends.
2. **Verification:** The translation results were cross-checked with physical ruler measurements to ensure a global minimum was reached.
3. **Cross-Calibration:** For higher precision, a LiDAR-to-Camera calibration is recommended to validate these results against the Livox factory LiDAR-to-IMU transform.

## 🔗 References

* [Livox Lidar-Camera Calibration Guide](https://livox-wiki-en.readthedocs.io/en/latest/tutorials/other_product/sensor_calibration.html#lidar-camera-calibration)
* [Intel RealSense Calibration Tool](https://dev.realsenseai.com/docs/calibration)
* [Tangram Vision: Kalibr to Metrical Migration](https://docs.tangramvision.com/metrical/14.1/special_topics/kalibr_to_metrical_migration/)

