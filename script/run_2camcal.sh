#!/bin/bash

# Camera models
# https://github.com/ethz-asl/kalibr/wiki/supported-models
MODELS=(
    "pinhole-equi pinhole-equi"
    "omni-radtan omni-radtan"
    "eucm-none eucm-none"
    "ds-none ds-none"
)


TARGET="/data/april_6x6_lunarlab.yaml"
BAGFOLDER="/data/DataBag_2026-03-10-21-17-14" # No trailing slash needed here

BAGFILE="data_0.bag"
TOPICS="/left_camera/image/compressed /right_camera/image/compressed"
#TIME_RANGE="0 90"
#FREQ="10" 

export MPLBACKEND=Agg
export QT_QPA_PLATFORM=offscreen

# Full path to bag
FULL_BAG_PATH="$BAGFOLDER/$BAGFILE"
# Strip .bag for the prefix Kalibr uses
BAG_PREFIX=$(basename "$BAGFILE" .bag)

for MODEL in "${MODELS[@]}"; do
    FOLDER_NAME="${MODEL}_stereo"
    RESULT_PATH="$BAGFOLDER/results/$FOLDER_NAME"
    
    echo "----------------------------------------------------------"
    echo "RUNNING Stereo CALIB: $MODEL"
    echo "----------------------------------------------------------"
    
    mkdir -p "$RESULT_PATH"
    # Stay in catkin_ws or a neutral dir; Kalibr will write to $BAGFOLDER
#       --bag-from-to $TIME_RANGE \
 #      --bag-freq $FREQ \
    cd /catkin_ws

    rosrun kalibr kalibr_calibrate_cameras \
       --target "$TARGET" \
       --bag "$FULL_BAG_PATH" \
       --models $MODEL \
       --topics $TOPICS \
       --verbose \
       --dont-show-report

    # Check for the camchain file in the BAGFOLDER
    CAMCHAIN_FILE=$(ls -t "$BAGFOLDER"/${BAG_PREFIX}-camchain.yaml 2>/dev/null | head -n 1)

    # 1. Check if the file exists AND contains actual numbers (not 'nan')
    if [ -f "$CAMCHAIN_FILE" ] && ! grep -q "nan" "$CAMCHAIN_FILE"; then
        STATUS="SUCCESS"
        
        # Explicitly find the report inside the BAGFOLDER
        TEXT_REPORT=$(ls -t "$BAGFOLDER"/${BAG_PREFIX}-results-cam.txt 2>/dev/null | head -n 1)
        
        if [ -n "$TEXT_REPORT" ]; then
            RMSE_VAL=$(grep "reprojection error:" "$TEXT_REPORT" | sed -n 's/.*+- \[\([^,]*\),.*/\1/p' | xargs)
            RMSE="${RMSE_VAL} px"
        else
            RMSE="Check PDF"
        fi
        
        # Move everything to the clean results folder
        mv "$BAGFOLDER"/${BAG_PREFIX}-* "$RESULT_PATH/"
    else
        STATUS="FAILED"
        RMSE="N/A"
    fi
    
    # Store result for the table
    SUMMARY_REPORT="${SUMMARY_REPORT}${MODEL}|${STATUS}|${RMSE}\n"
done

# Print final summary table
echo ""
echo "=========================================================="
echo "                KALIBR CALIBRATION SUMMARY"
echo "=========================================================="
printf "%23s | %-7s | %-20s\n" "MODEL" "STATUS" "RMSE (PIXELS)"
echo "----------------------------------------------------------"
echo -e "$SUMMARY_REPORT" | column -t -s '|'
echo "=========================================================="

