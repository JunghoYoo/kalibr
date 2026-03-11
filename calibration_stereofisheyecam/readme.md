# Fisheye stereo vision camera calibration

**Date:** March 11, 2026
**Hardware:** TaoCamera (fisheye lens/global shutter/RGB)

## 📌 Overview

This project performs calibration between a camera and a LiDAR-embedded IMU. A key challenge addressed is the high noise floor introduced by the Mid-360's internal motor vibrations, which can cause standard datasheet-based calibrations to fail.

## 🛠 Prerequisites & Environment

* **OS:** Ubuntu 20.04 (Noetic) inside Docker
* **Toolbox:** [Kalibr](https://github.com/JunghoYoo/kalibr)
* **Sensor Drivers:** `Camera_SDK_HAIKANG'

## 1. Data Characterization & Bag Validation

Before calibration, the recorded ROS bag was inspected to ensure correct message types, topic names, and sufficient data duration.

```bash
rosbag info /data/DataBag_2026-03-10-21-17-14/data_0.bag 
```

```text
path:        /data/DataBag_2026-03-10-21-17-14/data_0.bag
version:     2.0
duration:    59.7s
start:       Mar 11 2026 01:17:16.15 (1773191836.15)
end:         Mar 11 2026 01:18:15.84 (1773191895.84)
size:        201.4 MB
messages:    1196
compression: none [240/240 chunks]
types:       sensor_msgs/CompressedImage [8f7a12909da2c9d3332d540a0977563f]
topics:      /left_camera/image/compressed    598 msgs    : sensor_msgs/CompressedImage
            /right_camera/image/compressed   598 msgs    : sensor_msgs/CompressedImage
```

**Topic Frequencies:**
```bash
./script/check_hzbag.sh /data/DataBag_2026-03-10-21-17-14/data_0.bag 

```
```bash
----------------------------------------------------------------------------------------
Calculating topic frequencies for: /data/DataBag_2026-03-10-21-17-14/data_0.bag
Total Duration: 59.7 seconds
----------------------------------------------------------------------------------------
Topic: /left_camera/image/compressed                      Frequency:   10.02 Hz
Topic: /right_camera/image/compressed                     Frequency:   10.02 Hz
----------------------------------------------------------------------------------------
```
All desired topics were recorded correctly with sufficient duration.

```bash
roscore &
rqt_bag /data/DataBag_2026-03-10-21-17-14/data_0.bag

```
Two topics are not time-synchronized with each other.


* 🖼 [Check Synchronization](rqt_bag.png)

## 2. Camera Intrinsic Calibration

Adjust the rosbag path, filename, and time in `run_camcal.sh`, then execute:

```bash
./run_camcal.sh

```

* 🖼 [Target Detection Visualization](tagdetection_cam.png)

### Calibration Summaries

Four camera models were tested with one of 3 collected datasets to find the optimal intrinsic model. 
The **eucm-none** model was selected based on the lowest RMSE (**0.374368 0.378345 px**).
Also, the **pinhole-equi** model is provided based on the low RMSE (**0.387448 0.398807**) with wide support such as OpenCV or COLMAP.

**Dataset 2026-03-10-21-17-14 Results:**
| MODEL | STATUS | RMSE (PIXELS) |
| :--- | :--- | :--- |
| pinhole-equi | SUCCESS | 0.387448 / 0.398807 px |
| omni-radtan | SUCCESS | 0.370988 / 0.383646 px |
| eucm-none | SUCCESS | 0.374368 / 0.378345 px |
| ds-none | SUCCESS | 0.390110 / 0.399569 px |

**Calibration Artifacts:**

* 📄 [EUCM-Camera Intrinsic Report](eucm-none eucm-none_stereo/data_0-report-cam.pdf)
* ⚙️ [EUCM-Final Camera Chain YAML](eucm-none eucm-none_stereo/data_0-camchain.yaml)
* 🖼 [Camera datasheet](fisheyecamera_spec.pdf)

## 3. Engineering Insights

1. **Fisheye Data Collection Strategy:** Due to the extreme wide Field-of-View (FoV), it is critical to position the calibration target close to the lens to minimize detection errors. To ensure a robust calibration, move the camera to cover all areas of the 2D image, specifically ensuring markers are detected in high-distortion regions near the corners.
2. **Synchronization Awareness:** Analysis via `rqt_bag` revealed that stereo camera topics were not perfectly time-synchronized. For high-accuracy stereo vision, hardware-level triggering or software filters (like `ApproximateTime` synchronizers) are essential to prevent baseline drift in 3D reconstructions.
3. **Optimal Model Selection:** The choice depends on your software pipeline:
* **EUCM (Extended Unified Camera Model):** Selected for this project due to the best RMSE balance (0.374 px left / 0.378 px right). Recommended for **3DGRUT** and **Basalt** VIO due to numerical stability with wide-angle sensors.
* **Pinhole-Equidistant:** Best for **OpenCV**, **COLMAP**, or standard **ROS** nodes. It provides low RMSE (0.387 px left / 0.398 px right) and has the widest third-party support.   
   
## 🔗 References

* [Kalibr supported camera models](camera_model.md)









