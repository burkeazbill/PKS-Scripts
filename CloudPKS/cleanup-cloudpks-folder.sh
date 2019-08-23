#!/bin/bash
#
# Author: Burke Azbill
# Repo: https://github.com/burkeazbill/PKS-Scripts
# Purpose:
#   The purpose of this script is to provide you with a simple
#   method to cleanup Clusters and Projects in a given folder.
#
# Who benefits?
#   Anyone who creates multiple Clusters and Projects on a regular basis.
#   This is a common requirement for those providing demos or enablement.

# Load Private file for ORG and TOKEN
# Contents of the file should be as follows:
# export ORG="ORGANIZATION-ID-FROM-DEVELOPER-CENTER-OVERVIEW"
# export TOKEN="YOUR-VMWARE-CLOUD-SERVICES-API-TOKEN"
source ~/.cloud-pks-auth.txt
# The line above will load the contents of the hidden .cloud-pks-auth.txt file
# found in the user home directory ( In my case, this is /Users/bazbill )
# The file's read permissions are limited to the owner of the file (and root), making this
# a secure method to store confidential information, and allowing this script to be shared

# Set the following line to the folder name you wish to cleanup:
VKEFOLDER="Student-Test-Folder"
LOGFILE=`date '+%Y-%m-%d-%H-%M-%S'.log`
export VKE_LOG=$PWD/$LOGFILE
echo "Logging to:" ${VKE_LOG}

vke folder set $VKEFOLDER > /dev/null 2>&1
echo "The following Projects and Clusters will be deleted if you answer Yes:"
vke project list --folder $VKEFOLDER
vke cluster list --folder $VKEFOLDER
echo ""
# Confirm actions:
read -p "Are you CERTAIN you wish to Delete them? [y/N] " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
  # Get Projects in json format:
  VKE_PROJECTS=$(vke -o json project list)
  # Place the name of each project in an array
  VKE_PROJECT_NAMES=$(jq -r '.items[].name' <<<"$VKE_PROJECTS")

  # Loop through the array and display each name:
  for VKEPROJECT in $VKE_PROJECT_NAMES; do
    echo "Cleaning up Project:" $VKEPROJECT | tee -a ${VKE_LOG}
    # Get clusters for current project
    vke project set $VKEPROJECT > /dev/null 2>&1
    VKE_CLUSTERS=$(vke -o json cluster list)
    VKE_CLUSTER_NAMES=$(jq -r '.items[].name' <<<"$VKE_CLUSTERS")
    for VKECLUSTER in $VKE_CLUSTER_NAMES; do
      echo "-->Deleting Cluster:" $VKEFOLDER\\$VKEPROJECT\\$VKECLUSTER | tee -a ${VKE_LOG}
      # vke cluster delete "$VKECLUSTER" --folder "$VKEFOLDER" --project "$VKEPROJECT" | tee -a ${VKE_LOG}
    done
    echo "-->Deleting Project:" $VKEFOLDER\\$VKEPROJECT | tee -a ${VKE_LOG}
    # vke project delete $VKEPROJECT --folder "$VKEFOLDER" | tee -a ${VKE_LOG}
    echo "" >> ${VKE_LOG}
  done
fi