#!/bin/bash

export SOURCE_REGISTRY_USERNAME="#Enter username provided by Devtron team"
export SOURCE_REGISTRY_TOKEN="#Enter token provided by Devtron team"
export TARGET_REGISTRY="#Enter target registry url "
export TARGET_REGISTRY_USERNAME="#Enter target registry username"
export TARGET_REGISTRY_TOKEN="#Enter target registry token/password"

SOURCE_REGISTRY="quay.io/devtron"
TARGET_REGISTRY=${TARGET_REGISTRY}
SOURCE_IMAGES_FILE_NAME="${SOURCE_IMAGES_FILE_NAME:=devtron-images-ea-ent.txt.source}"
TARGET_IMAGES_FILE_NAME="${TARGET_IMAGES_FILE_NAME:=devtron-images.txt.target}"
podman login -u $TARGET_REGISTRY_USERNAME -p $TARGET_REGISTRY_TOKEN $TARGET_REGISTRY
podman login -u $SOURCE_REGISTRY_USERNAME -p $SOURCE_REGISTRY_TOKEN devtronent.azurecr.io
cp $SOURCE_IMAGES_FILE_NAME $TARGET_IMAGES_FILE_NAME
while read source_image; do
  if [[ "$source_image" == *"devtron:"* || "$source_image" == *"hyperion:"* || "$source_image" == *"dashboard:"* || "$source_image" == *"casbin:"* || "$source_image" == *"test:"* ]]
  then
  SOURCE_REGISTRY="devtronent.azurecr.io"
  sed -i "s|${SOURCE_REGISTRY}|${TARGET_REGISTRY}|g" $TARGET_IMAGES_FILE_NAME
  elif [[ "$source_image" == *"workflow-controller:"* || "$source_image" == *"argoexec:"* || "$source_image" == *"argocd:"* ]]
  then
  SOURCE_REGISTRY="quay.io/argoproj"
  sed -i "s|${SOURCE_REGISTRY}|${TARGET_REGISTRY}|g" $TARGET_IMAGES_FILE_NAME
  elif [[ "$source_image" == *"redis:"* ]]
  then
  SOURCE_REGISTRY="public.ecr.aws/docker/library"
  sed -i "s|${SOURCE_REGISTRY}|${TARGET_REGISTRY}|g" $TARGET_IMAGES_FILE_NAME
  else
  SOURCE_REGISTRY="quay.io/devtron"
  sed -i "s|${SOURCE_REGISTRY}|${TARGET_REGISTRY}|g" $TARGET_IMAGES_FILE_NAME
  fi
done <$SOURCE_IMAGES_FILE_NAME
echo "Target Images file finalized"

while read -r -u 3 source_image && read -r -u 4 target_image ; do
  echo "Pushing $source_image $target_image"
  podman manifest create $source_image
  podman manifest add $source_image $source_image --all
  podman manifest push $source_image $target_image --all
done 3<"$SOURCE_IMAGES_FILE_NAME" 4<"$TARGET_IMAGES_FILE_NAME"
