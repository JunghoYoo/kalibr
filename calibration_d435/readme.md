# Camera Calibration: RealSense D435

**Date:** May 30, 2026
**Hardware:** Intel RealSense D435 (RGB)

## 📌 Overview

This project performs calibration between a camera and a LiDAR-embedded IMU. A key challenge addressed is the high noise floor introduced by the Mid-360's internal motor vibrations, which can cause standard datasheet-based calibrations to fail.

## 🛠 Prerequisites & Environment

* **OS:** Ubuntu 20.04 (Noetic) inside Docker
* **Toolbox:** [Kalibr](https://github.com/JunghoYoo/kalibr)
* **Sensor Drivers:** `realsense2_camera`

## 1. Data Characterization & Bag Validation

Before calibration, the recorded ROS bag was inspected to ensure correct message types, topic names, and sufficient data duration.
This rosbag is recorded by realsense-viewer (640x480, 30fps).

```bash
rosbag info /data/DataBag_2026-03-08-14-42-53/data.bag
```

```text
path:         /data/DataBag_2026-05-30/20260530_011835.bag
version:      2.0
duration:     1:54s (114s)
start:        Jan 01 1970 00:00:00.00 (0.00)
end:          Jan 01 1970 00:01:54.72 (114.72)
size:         2.0 GB
messages:     82672
compression:  lz4 [3441/3441 chunks; 66.59%]
uncompressed: 3.0 GB @ 26.4 MB/s
compressed:   2.0 GB @ 17.6 MB/s (66.59%)
types:        diagnostic_msgs/KeyValue  [cf57fdc6617a881a88c16e768132149c]
              geometry_msgs/Transform   [ac9eff44abf714214112b05d54a3cf9b]
              realsense_msgs/StreamInfo [311d7e24eac31bb87271d041bf70ff7d]
              sensor_msgs/CameraInfo    [c9a58c1b0b154e0e6da7578cb991d214]
              sensor_msgs/Image         [060021388200f6f0f447d0fcd9c64743]
              std_msgs/Float32          [73fcbf46b49191e672908e50842a83d4]
              std_msgs/String           [992ce8a1687cec8c8bd883ec73ca41d1]
              std_msgs/UInt32           [304a39449588c7f8ce2df6e8001c5fce]
topics:       /device_0/info                                                        16 msgs    : diagnostic_msgs/KeyValue 
              /device_0/sensor_0/info                                                2 msgs    : diagnostic_msgs/KeyValue 
              /device_0/sensor_0/option/Auto_Exposure_Limit/description              1 msg     : std_msgs/String          
              /device_0/sensor_0/option/Auto_Exposure_Limit/value                    1 msg     : std_msgs/Float32         
              /device_0/sensor_0/option/Auto_Exposure_Limit_Toggle/description       1 msg     : std_msgs/String          
              /device_0/sensor_0/option/Auto_Exposure_Limit_Toggle/value             1 msg     : std_msgs/Float32         
              /device_0/sensor_0/option/Auto_Gain_Limit/description                  1 msg     : std_msgs/String          
              /device_0/sensor_0/option/Auto_Gain_Limit/value                        1 msg     : std_msgs/Float32         
              /device_0/sensor_0/option/Auto_Gain_Limit_Toggle/description           1 msg     : std_msgs/String          
              /device_0/sensor_0/option/Auto_Gain_Limit_Toggle/value                 1 msg     : std_msgs/Float32         
              /device_0/sensor_0/option/Depth_Units/description                      1 msg     : std_msgs/String          
              /device_0/sensor_0/option/Depth_Units/value                            1 msg     : std_msgs/Float32         
              /device_0/sensor_0/option/Emitter_Always_On/description                1 msg     : std_msgs/String          
              /device_0/sensor_0/option/Emitter_Always_On/value                      1 msg     : std_msgs/Float32         
              /device_0/sensor_0/option/Emitter_Enabled/description                  1 msg     : std_msgs/String          
              /device_0/sensor_0/option/Emitter_Enabled/value                        1 msg     : std_msgs/Float32         
              /device_0/sensor_0/option/Emitter_On_Off/description                   1 msg     : std_msgs/String          
              /device_0/sensor_0/option/Emitter_On_Off/value                         1 msg     : std_msgs/Float32         
              /device_0/sensor_0/option/Enable_Auto_Exposure/description             1 msg     : std_msgs/String          
              /device_0/sensor_0/option/Enable_Auto_Exposure/value                   1 msg     : std_msgs/Float32         
              /device_0/sensor_0/option/Error_Polling_Enabled/description            1 msg     : std_msgs/String          
              /device_0/sensor_0/option/Error_Polling_Enabled/value                  1 msg     : std_msgs/Float32         
              /device_0/sensor_0/option/Exposure/description                         1 msg     : std_msgs/String          
              /device_0/sensor_0/option/Exposure/value                               1 msg     : std_msgs/Float32         
              /device_0/sensor_0/option/Frames_Queue_Size/description                1 msg     : std_msgs/String          
              /device_0/sensor_0/option/Frames_Queue_Size/value                      1 msg     : std_msgs/Float32         
              /device_0/sensor_0/option/Gain/description                             1 msg     : std_msgs/String          
              /device_0/sensor_0/option/Gain/value                                   1 msg     : std_msgs/Float32         
              /device_0/sensor_0/option/Global_Time_Enabled/description              1 msg     : std_msgs/String          
              /device_0/sensor_0/option/Global_Time_Enabled/value                    1 msg     : std_msgs/Float32         
              /device_0/sensor_0/option/Hdr_Enabled/description                      1 msg     : std_msgs/String          
              /device_0/sensor_0/option/Hdr_Enabled/value                            1 msg     : std_msgs/Float32         
              /device_0/sensor_0/option/Inter_Cam_Sync_Mode/description              1 msg     : std_msgs/String          
              /device_0/sensor_0/option/Inter_Cam_Sync_Mode/value                    1 msg     : std_msgs/Float32         
              /device_0/sensor_0/option/Laser_Power/description                      1 msg     : std_msgs/String          
              /device_0/sensor_0/option/Laser_Power/value                            1 msg     : std_msgs/Float32         
              /device_0/sensor_0/option/Output_Trigger_Enabled/description           1 msg     : std_msgs/String          
              /device_0/sensor_0/option/Output_Trigger_Enabled/value                 1 msg     : std_msgs/Float32         
              /device_0/sensor_0/option/Sequence_Id/description                      1 msg     : std_msgs/String          
              /device_0/sensor_0/option/Sequence_Id/value                            1 msg     : std_msgs/Float32         
              /device_0/sensor_0/option/Sequence_Name/description                    1 msg     : std_msgs/String          
              /device_0/sensor_0/option/Sequence_Name/value                          1 msg     : std_msgs/Float32         
              /device_0/sensor_0/option/Sequence_Size/description                    1 msg     : std_msgs/String          
              /device_0/sensor_0/option/Sequence_Size/value                          1 msg     : std_msgs/Float32         
              /device_0/sensor_0/option/Stereo_Baseline/description                  1 msg     : std_msgs/String          
              /device_0/sensor_0/option/Stereo_Baseline/value                        1 msg     : std_msgs/Float32         
              /device_0/sensor_0/post_processing                                    10 msgs    : std_msgs/String          
              /device_0/sensor_1/Color_0/image/data                               3440 msgs    : sensor_msgs/Image        
              /device_0/sensor_1/Color_0/image/metadata                          79120 msgs    : diagnostic_msgs/KeyValue 
              /device_0/sensor_1/Color_0/info                                        1 msg     : realsense_msgs/StreamInfo
              /device_0/sensor_1/Color_0/info/camera_info                            1 msg     : sensor_msgs/CameraInfo   
              /device_0/sensor_1/Color_0/tf/0                                        1 msg     : geometry_msgs/Transform  
              /device_0/sensor_1/info                                                2 msgs    : diagnostic_msgs/KeyValue 
              /device_0/sensor_1/option/Auto_Exposure_Priority/description           1 msg     : std_msgs/String          
              /device_0/sensor_1/option/Auto_Exposure_Priority/value                 1 msg     : std_msgs/Float32         
              /device_0/sensor_1/option/Backlight_Compensation/description           1 msg     : std_msgs/String          
              /device_0/sensor_1/option/Backlight_Compensation/value                 1 msg     : std_msgs/Float32         
              /device_0/sensor_1/option/Brightness/description                       1 msg     : std_msgs/String          
              /device_0/sensor_1/option/Brightness/value                             1 msg     : std_msgs/Float32         
              /device_0/sensor_1/option/Contrast/description                         1 msg     : std_msgs/String          
              /device_0/sensor_1/option/Contrast/value                               1 msg     : std_msgs/Float32         
              /device_0/sensor_1/option/Enable_Auto_Exposure/description             1 msg     : std_msgs/String          
              /device_0/sensor_1/option/Enable_Auto_Exposure/value                   1 msg     : std_msgs/Float32         
              /device_0/sensor_1/option/Enable_Auto_White_Balance/description        1 msg     : std_msgs/String          
              /device_0/sensor_1/option/Enable_Auto_White_Balance/value              1 msg     : std_msgs/Float32         
              /device_0/sensor_1/option/Exposure/description                         1 msg     : std_msgs/String          
              /device_0/sensor_1/option/Exposure/value                               1 msg     : std_msgs/Float32         
              /device_0/sensor_1/option/Frames_Queue_Size/description                1 msg     : std_msgs/String          
              /device_0/sensor_1/option/Frames_Queue_Size/value                      1 msg     : std_msgs/Float32         
              /device_0/sensor_1/option/Gain/description                             1 msg     : std_msgs/String          
              /device_0/sensor_1/option/Gain/value                                   1 msg     : std_msgs/Float32         
              /device_0/sensor_1/option/Gamma/description                            1 msg     : std_msgs/String          
              /device_0/sensor_1/option/Gamma/value                                  1 msg     : std_msgs/Float32         
              /device_0/sensor_1/option/Global_Time_Enabled/description              1 msg     : std_msgs/String          
              /device_0/sensor_1/option/Global_Time_Enabled/value                    1 msg     : std_msgs/Float32         
              /device_0/sensor_1/option/Hue/description                              1 msg     : std_msgs/String          
              /device_0/sensor_1/option/Hue/value                                    1 msg     : std_msgs/Float32         
              /device_0/sensor_1/option/Power_Line_Frequency/description             1 msg     : std_msgs/String          
              /device_0/sensor_1/option/Power_Line_Frequency/value                   1 msg     : std_msgs/Float32         
              /device_0/sensor_1/option/Saturation/description                       1 msg     : std_msgs/String          
              /device_0/sensor_1/option/Saturation/value                             1 msg     : std_msgs/Float32         
              /device_0/sensor_1/option/Sharpness/description                        1 msg     : std_msgs/String          
              /device_0/sensor_1/option/Sharpness/value                              1 msg     : std_msgs/Float32         
              /device_0/sensor_1/option/White_Balance/description                    1 msg     : std_msgs/String          
              /device_0/sensor_1/option/White_Balance/value                          1 msg     : std_msgs/Float32         
              /device_0/sensor_1/post_processing                                     2 msgs    : std_msgs/String          
              /file_version                                                          1 msg     : std_msgs/UInt32
```

**Topic Frequencies:**
```bash
./script/check_hzbag.sh /data/DataBag_2026-05-30/20260530_011835.bag
```
```bash
----------------------------------------------------------------------------------------
Calculating topic frequencies for: /data/DataBag_2026-05-30/20260530_011835.bag
Total Duration: 114 seconds
----------------------------------------------------------------------------------------
Topic: /device_0/info                                     Frequency:    0.14 Hz
Topic: /device_0/sensor_0/info                            Frequency:    0.02 Hz
Topic: /device_0/sensor_0/option/Auto_Exposure_Limit/description Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Auto_Exposure_Limit/value Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Auto_Exposure_Limit_Toggle/description Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Auto_Exposure_Limit_Toggle/value Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Auto_Gain_Limit/description Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Auto_Gain_Limit/value    Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Auto_Gain_Limit_Toggle/description Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Auto_Gain_Limit_Toggle/value Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Depth_Units/description  Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Depth_Units/value        Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Emitter_Always_On/description Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Emitter_Always_On/value  Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Emitter_Enabled/description Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Emitter_Enabled/value    Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Emitter_On_Off/description Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Emitter_On_Off/value     Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Enable_Auto_Exposure/description Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Enable_Auto_Exposure/value Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Error_Polling_Enabled/description Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Error_Polling_Enabled/value Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Exposure/description     Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Exposure/value           Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Frames_Queue_Size/description Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Frames_Queue_Size/value  Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Gain/description         Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Gain/value               Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Global_Time_Enabled/description Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Global_Time_Enabled/value Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Hdr_Enabled/description  Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Hdr_Enabled/value        Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Inter_Cam_Sync_Mode/description Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Inter_Cam_Sync_Mode/value Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Laser_Power/description  Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Laser_Power/value        Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Output_Trigger_Enabled/description Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Output_Trigger_Enabled/value Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Sequence_Id/description  Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Sequence_Id/value        Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Sequence_Name/description Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Sequence_Name/value      Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Sequence_Size/description Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Sequence_Size/value      Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Stereo_Baseline/description Frequency:    0.01 Hz
Topic: /device_0/sensor_0/option/Stereo_Baseline/value    Frequency:    0.01 Hz
Topic: /device_0/sensor_0/post_processing                 Frequency:    0.09 Hz
Topic: /device_0/sensor_1/Color_0/image/data              Frequency:   30.18 Hz
Topic: /device_0/sensor_1/Color_0/image/metadata          Frequency:  694.04 Hz
Topic: /device_0/sensor_1/Color_0/info                    Frequency:    0.01 Hz
Topic: /device_0/sensor_1/Color_0/info/camera_info        Frequency:    0.01 Hz
Topic: /device_0/sensor_1/Color_0/tf/0                    Frequency:    0.01 Hz
Topic: /device_0/sensor_1/info                            Frequency:    0.02 Hz
Topic: /device_0/sensor_1/option/Auto_Exposure_Priority/description Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/Auto_Exposure_Priority/value Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/Backlight_Compensation/description Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/Backlight_Compensation/value Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/Brightness/description   Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/Brightness/value         Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/Contrast/description     Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/Contrast/value           Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/Enable_Auto_Exposure/description Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/Enable_Auto_Exposure/value Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/Enable_Auto_White_Balance/description Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/Enable_Auto_White_Balance/value Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/Exposure/description     Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/Exposure/value           Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/Frames_Queue_Size/description Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/Frames_Queue_Size/value  Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/Gain/description         Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/Gain/value               Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/Gamma/description        Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/Gamma/value              Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/Global_Time_Enabled/description Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/Global_Time_Enabled/value Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/Hue/description          Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/Hue/value                Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/Power_Line_Frequency/description Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/Power_Line_Frequency/value Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/Saturation/description   Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/Saturation/value         Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/Sharpness/description    Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/Sharpness/value          Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/White_Balance/description Frequency:    0.01 Hz
Topic: /device_0/sensor_1/option/White_Balance/value      Frequency:    0.01 Hz
Topic: /device_0/sensor_1/post_processing                 Frequency:    0.02 Hz
Topic: /file_version                                      Frequency:    0.01 Hz
----------------------------------------------------------------------------------------
```
All desired topics were recorded correctly with sufficient duration.

```bash
rqt_bag /data/DataBag_2026-05-30/20260530_011835.bag
```

* 🖼 [Check Synchronization](rqt_bag.png)

## 2. Camera Intrinsic Calibration

Adjust the rosbag path, filename, and time in `run_camcal.sh`, then execute:

```bash
./run_camcal.sh
```

* 🖼 [Target Detection Visualization](tagdetection_cam.png)

### Calibration Summaries

Three datasets were collected to find the optimal intrinsic model. The **Pinhole-EquiDistant** model was selected based on the lowest RMSE (**0.192749 px**).

**Dataset 2026-05-30-01-17-35 Results:**
| MODEL | STATUS | RMSE (PIXELS) |
| :--- | :--- | :--- |
| **pinhole-equi** | **SUCCESS** | **0.192749 px** |
| pinhole-radtan | SUCCESS | 0.220960 px |

**Calibration Artifacts:**

pinhole-equi
* 📄 [Camera Intrinsic Report](pinhole-equi_single/20260530_011835-report-cam.pdf)
* ⚙️ [Final Camera Chain YAML](pinhole-equi_single/20260530_011835-camchain.yaml)

pinhole-radtan
* 📄 [Camera Intrinsic Report](pinhole-radtan_single/20260530_011835-report-cam.pdf)
* ⚙️ [Final Camera Chain YAML](pinhole-radtan_single/20260530_011835-camchain.yaml)

## 3. Engineering Insights

1. **ROS Recording:**  When recording a rosbag, ensure the target covers all regions of the camera's field of view. Move the camera at a constant, steady velocity so that downsampled frames retain crisp, distinct target features. If the camera's shutter speed is too slow, quick movements will introduce motion blur. Monitor the live stream while recording and adjust your pacing accordingly.
2. **Kalibr:** Avoid processing the entire time range and maximum frequency of the original rosbag. Introducing too many dense spatio-temporal constraints into the batch optimization framework often triggers a convergence failure or causes the solver to get trapped in poor local minima. Downsample frequencies where appropriate.

## 🔗 References

* [Intel RealSense Calibration Tool](https://dev.realsenseai.com/docs/calibration)
* [Tangram Vision: Kalibr to Metrical Migration](https://docs.tangramvision.com/metrical/14.1/special_topics/kalibr_to_metrical_migration/)
