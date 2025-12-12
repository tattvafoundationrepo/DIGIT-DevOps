#!/bin/bash

# List of images to retag and push
IMAGES=(
  "egovio/egov-accesscontrol:v1.1.3-72f8a8f87b-24"
  "egovio/egov-apportion-service:v1.1.5-72f8a8f87b-5"
  "egovio/egov-enc-service:v1.1.2-72f8a8f87b-9"
  "egovio/egov-hrms:v1.2.5-1715164454-6"
  "egovio/egov-localization:v1.1.0-f9375a4"
  "egovio/egov-location:v1.1.3-2ee9ec37-1"
  "egovio/egov-user-event:v1.1.3-a8da9ece-3"
  "egovio/egov-workflow-v2:v1.1.0-42786ef"
  "egovio/employee:v1.5.2-0af363ce1-372"
  "egovio/nginx-ingress-controller:0.26.1"
  "egovio/pdf-service:v1.1.6-96b24b0d72-22"
)

# Registry details
ACCOUNT="tattvafoundation"  # Same as repo and account name

echo "Starting image retag and push process..."
echo "=================================="

for image in "${IMAGES[@]}"; do
  # Extract image name and tag
  image_name=$(echo "$image" | cut -d: -f1 | cut -d/ -f2)
  image_tag=$(echo "$image" | cut -d: -f2)
  
  # Create new image name
  new_image="${ACCOUNT}/${image_name}:${image_tag}"
  
  echo ""
  echo "Processing: $image"
  echo "New image: $new_image"
  echo "---"
  
  # Pull the original image
  echo "Pulling: $image"
  docker pull "$image"
  
  # Tag the image with new registry
  echo "Retagging to: $new_image"
  docker tag "$image" "$new_image"
  
  # Push to new registry
  echo "Pushing: $new_image"
  docker push "$new_image"
  
  echo "✓ Completed for $image_name"
done

echo ""
echo "=================================="
echo "All images have been retagged and pushed!"
echo "=================================="
