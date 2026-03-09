#!/bin/bash

# Camera models
# https://github.com/ethz-asl/kalibr/wiki/supported-models
MODELS=(
    "pinhole-radtan"
    "pinhole-equi"
    "pinhole-fov"
    "omni-none"
    "omni-radtan"
    "eucm-none"
    "ds-none"
)

TARGET="/data/april_6x6_lunarlab.yaml"
BAGFOLDER="/data/DataBag_2026-03-08-14-42-53" # No trailing slash needed here
BAGFILE="data.bag"
TOPICS="/camera/color/image_raw/compressed"
TIME_RANGE="0 90"
FREQ="30" 
+-
export QT_QPA_PLATFORM=offscreen
SUMMARY_REPORT=""

# Full path to bag
FULL_BAG_PATH="$BAGFOLDER/$BAGFILE"
# Strip .bag for the prefix Kalibr uses
BAG_PREFIX=$(basename "$BAGFILE" .bag)

for MODEL in "${MODELS[@]}"; do
    FOLDER_NAME="${MODEL}_single"
    RESULT_PATH="$BAGFOLDER/results/$FOLDER_NAME"
    
    echo "----------------------------------------------------------"
    echo "RUNNING SINGLE CALIB: $MODEL"
    echo "----------------------------------------------------------"
    
    mkdir -p "$RESULT_PATH"
    # Stay in catkin_ws or a neutral dir; Kalibr will write to $BAGFOLDER
    cd /catkin_ws

    xvfb-run -a rosrun kalibr kalibr_calibrate_cameras \
       --target "$TARGET" \
       --bag "$FULL_BAG_PATH" \
       --bag-from-to $TIME_RANGE \
       --models $MODEL \
       --topics $TOPICS \
       --bag-freq $FREQ \
       --verbose \
       --show-extraction \
       --dont-show-report

    # Check for the camchain file in the BAGFOLDER
    CAMCHAIN_FILE=$(ls -t "$BAGFOLDER"/${BAG_PREFIX}-camchain.yaml 2>/dev/null | head -n 1)

    # 1. Check if the file exists AND contains actual numbers (not 'nan')
    if [ -f "$CAMCHAIN_FILE" ] && ! grep -q "nan" "$CAMCHAIN_FILE"; then
        STATUS="SUCCESS"
        
        # Explicitly find the report inside the BAGFOLDER
        TEXT_REPORT=$(ls -t "$BAGFOLDER"/${BAG_PREFIX}-results-cam.txt 2>/dev/null | head -n 1)
        
        if [ -n "$TEXT_REPORT" ]; then
            # This extracts the first value (0.293 in your case) after the "+- [" string
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
printf "%-13s | %-7s | %-20s\n" "MODEL" "STATUS" "RMSE (PIXELS)"
echo "----------------------------------------------------------"
echo -e "$SUMMARY_REPORT" | column -t -s '|'
echo "=========================================================="

