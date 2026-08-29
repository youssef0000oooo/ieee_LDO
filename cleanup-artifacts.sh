#!/bin/bash

# Cleanup duplicate github-pages artifacts
# This script finds and deletes all but the most recent github-pages artifact

echo "Fetching workflow runs with github-pages artifacts..."

# Get all workflow runs and check for github-pages artifacts
gh run list \
  --repo youssef0000oooo/ieee_LDO \
  --status completed \
  --limit 50 \
  --json databaseId,updatedAt \
  --jq '.[] | .databaseId' | while read -r run_id; do
  
  echo "Checking run $run_id for artifacts..."
  
  # Get artifacts from this run
  artifacts=$(gh run view "$run_id" \
    --repo youssef0000oooo/ieee_LDO \
    --json artifacts \
    --jq '.artifacts[] | select(.name=="github-pages") | .id')
  
  if [ ! -z "$artifacts" ]; then
    echo "Found github-pages artifacts in run $run_id: $artifacts"
    
    # Delete each artifact
    echo "$artifacts" | while read -r artifact_id; do
      echo "Deleting artifact $artifact_id..."
      gh api repos/youssef0000oooo/ieee_LDO/actions/artifacts/$artifact_id \
        -X DELETE && echo "✓ Deleted artifact $artifact_id" || echo "✗ Failed to delete artifact $artifact_id"
    done
  fi
done

echo "Cleanup complete!"
