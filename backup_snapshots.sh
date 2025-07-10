#!/bin/bash

# Configuration - Set these variables before running
DEST_ACCOUNT_ID="${DEST_ACCOUNT_ID:-}"  # Set via environment variable or modify here
REGION="${AWS_REGION:-ap-southeast-1}"

# Validation
if [ -z "$DEST_ACCOUNT_ID" ]; then
  echo "❌ Error: DEST_ACCOUNT_ID is not set!"
  echo "💡 Set it via environment variable: export DEST_ACCOUNT_ID=123456789012"
  echo "💡 Or modify the script directly"
  exit 1
fi

echo "🚀 Starting EC2 migration process..."
echo "📋 Configuration:"
echo "   - Destination Account: $DEST_ACCOUNT_ID"
echo "   - Region: $REGION"
echo "   - Timestamp: $(date)"
echo ""

# Get instance ID and Name pairs
echo "🔍 Fetching EC2 instance info from region $REGION..."
mapfile -t instances < <(
  aws ec2 describe-instances --region $REGION \
    --query "Reservations[].Instances[].[InstanceId, Tags[?Key=='Name']|[0].Value || 'Unnamed']" \
    --output text | tr '\t' '\n'
)

TOTAL_INSTANCES=$((${#instances[@]} / 2))
echo "📊 Found $TOTAL_INSTANCES EC2 instances to process"
echo ""

# Show first few instances to verify format
if [ $TOTAL_INSTANCES -gt 0 ]; then
  echo "🔍 Instance list preview:"
  for ((i=0; i<${#instances[@]} && i<6; i+=2)); do
    echo "   Instance ID: ${instances[i]}"
    echo "   Instance Name: ${instances[i+1]:-'Unnamed'}"
    echo ""
  done
fi

TOTAL_SNAPSHOTS=0
SUCCESSFUL_SNAPSHOTS=0

# Loop through instances
for ((i=0; i<${#instances[@]}; i+=2)); do
# for ((i=0; i<1; i+=2)); do
  INSTANCE_ID=${instances[i]}
  INSTANCE_NAME=${instances[i+1]:-"Unnamed"}
  INSTANCE_NUM=$(((i/2) + 1))

  echo "🖥️  Processing instance $INSTANCE_NUM/$TOTAL_INSTANCES: $INSTANCE_ID ($INSTANCE_NAME)"

  # Get volume IDs and encryption status
  mapfile -t volumes < <(
    aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --region $REGION \
      --query "Reservations[].Instances[].BlockDeviceMappings[].Ebs.VolumeId" \
      --output text
  )

  VOLUME_COUNT=${#volumes[@]}
  echo "   📊 Found $VOLUME_COUNT volume(s) attached to this instance"

  # Create snapshot for each volume
  for ((v=0; v<${#volumes[@]}; v++)); do
    VOLUME_ID=${volumes[v]}
    VOLUME_NUM=$((v + 1))
    TOTAL_SNAPSHOTS=$((TOTAL_SNAPSHOTS + 1))

    # Check if volume is encrypted
    ENCRYPTED=$(aws ec2 describe-volumes \
      --volume-ids "$VOLUME_ID" \
      --region $REGION \
      --query "Volumes[0].Encrypted" \
      --output text)

    if [ "$ENCRYPTED" == "True" ]; then
      echo "   ⚠️  Volume $VOLUME_ID is encrypted. Make sure KMS key is shared with $DEST_ACCOUNT_ID"
    fi

    echo "   📸 Creating snapshot $VOLUME_NUM/$VOLUME_COUNT for volume $VOLUME_ID..."
    START_TIME=$(date +%s)

    SNAPSHOT_ID=$(aws ec2 create-snapshot \
      --volume-id "$VOLUME_ID" \
      --description "Backup of $INSTANCE_NAME ($VOLUME_ID)" \
      --region $REGION \
      --query "SnapshotId" \
      --output text 2>/dev/null)

    if [ $? -eq 0 ] && [ -n "$SNAPSHOT_ID" ]; then
      END_TIME=$(date +%s)
      DURATION=$((END_TIME - START_TIME))
      echo "   ✅ Snapshot created: $SNAPSHOT_ID (in ${DURATION}s)"
      SUCCESSFUL_SNAPSHOTS=$((SUCCESSFUL_SNAPSHOTS + 1))

      # Add Name tag to snapshot (properly escape special characters)
      echo "   🏷️  Adding name tag to snapshot..."
      aws ec2 create-tags \
        --resources "$SNAPSHOT_ID" \
        --tags "Key=Name,Value=$INSTANCE_NAME" \
        --region $REGION 2>/dev/null

      if [ $? -eq 0 ]; then
        echo "   ✅ Name tag added successfully"
      else
        echo "   ⚠️  Failed to add name tag (non-critical)"
      fi

      # Share snapshot
      echo "   🤝 Sharing snapshot $SNAPSHOT_ID with account $DEST_ACCOUNT_ID..."
      SHARE_START=$(date +%s)
      aws ec2 modify-snapshot-attribute \
        --snapshot-id "$SNAPSHOT_ID" \
        --attribute createVolumePermission \
        --operation-type add \
        --user-ids "$DEST_ACCOUNT_ID" \
        --region $REGION

      if [ $? -eq 0 ]; then
        SHARE_END=$(date +%s)
        SHARE_DURATION=$((SHARE_END - SHARE_START))
        echo "   ✅ Snapshot shared successfully (in ${SHARE_DURATION}s)"
      else
        echo "   ❌ Failed to share snapshot $SNAPSHOT_ID"
      fi
    else
      echo "   ❌ Failed to create snapshot for volume $VOLUME_ID"
    fi
  done

  echo "   ✅ Finished processing instance $INSTANCE_ID"
  echo ""
done

echo "📈 Migration Summary:"
echo "   - Total instances processed: $TOTAL_INSTANCES"
echo "   - Total snapshots attempted: $TOTAL_SNAPSHOTS"
echo "   - Successful snapshots: $SUCCESSFUL_SNAPSHOTS"
echo "   - Failed snapshots: $((TOTAL_SNAPSHOTS - SUCCESSFUL_SNAPSHOTS))"
echo "   - Completion time: $(date)"

if [ $SUCCESSFUL_SNAPSHOTS -eq $TOTAL_SNAPSHOTS ]; then
  echo "✅ All snapshots created and shared successfully!"
else
  echo "⚠️  Some snapshots failed. Please review the logs above."
fi
