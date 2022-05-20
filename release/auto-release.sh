APP_DOCKER_REPO=$APP_DOCKER_REPO
APP_MANIFEST=$APP_MANIFEST
HYPERION_APP_MANIFEST=$HYPERION_APP_MANIFEST
REPO=$REPO
GIT_REPO=$GIT_REPO
GIT_CONFIG_EMAIL=$GIT_CONFIG_EMAIL
GIT_CONFIG_NAME=$GIT_CONFIG_NAME
GIT_USERNAME=$GIT_USERNAME
GITHUB_TOKENS=$GITHUB_TOKENS
GIT_BRANCH=$GIT_BRANCH
RAW_GIT_REPO=$RAW_GIT_REPO
VERSION_FILE=$VERSION_FILE
RELEASE_BRANCH=$RELEASE_BRANCH
MIGRATOR_FILE=$MIGRATOR_FILE
MIGRATOR_LINE_1=$MIGRATOR_LINE_1
MIGRATOR_LINE_2=$MIGRATOR_LINE_2
MIGRATOR_LINE_BOM_1=$MIGRATOR_LINE_BOM_1
MIGRATOR_LINE_BOM_2=$MIGRATOR_LINE_BOM_2
VERSION_FILE_CHART=$VERSION_FILE_CHART
DEVTRON_BOM_FILE=$DEVTRON_BOM_FILE
MIGRATOR_LINE_CHART_1=$MIGRATOR_LINE_CHART_1
MIGRATOR_LINE_CHART_2=$MIGRATOR_LINE_CHART_2


#Getting the commits
BUILD_COMMIT=$(git rev-parse HEAD)
echo $BUILD_COMMIT
echo $DOCKER_IMAGE_TAG
echo "========================check================================"
mkdir preci
cd preci
wget https://github.com/cli/cli/releases/download/v1.5.0/gh_1.5.0_linux_386.tar.gz -O ghcli.tar.gz
tar --strip-components=1 -xf ghcli.tar.gz
echo "=============================after cli download======================="
echo $GITHUB_TOKENS > tokens.txt
echo "===========================check token======================="
bin/gh auth login --with-token < tokens.txt
echo "================================authentication==============="
bin/gh repo clone "$REPO"
echo "========================================repo clone command above==="
cd devtron
git checkout "$GIT_BRANCH"
git checkout -b "$RELEASE_BRANCH"
echo "============ ls -la========"
#ls -la
#Updating Image in the yaml for devtron
sed -i "s/quay.io\/devtron\/$APP_DOCKER_REPO:.*/quay.io\/devtron\/$APP_DOCKER_REPO:$DOCKER_IMAGE_TAG\"/" manifests/yamls/$APP_MANIFEST
sed -i "s/quay.io\/devtron\/$APP_DOCKER_REPO:.*/quay.io\/devtron\/$APP_DOCKER_REPO:$DOCKER_IMAGE_TAG\"/" charts/devtron/$DEVTRON_BOM_FILE


#Setting Git configurations
echo "----setting up git config---------------"
git config --system user.email "$GIT_CONFIG_EMAIL"
git config --system user.name "$GIT_CONFIG_NAME"
echo "https://raw.githubusercontent.com/$REPO/$GIT_BRANCH/$VERSION_FILE"
DEV_RELEASE=$(curl -L -s  "https://raw.githubusercontent.com/$REPO/$GIT_BRANCH/$VERSION_FILE" )
RELEASE_VERSION=$(../bin/gh release list -L 1 -R $REPO | awk '{print $1}')

#Comparing version mentioned in the version.txt with latest release version
if [[ $DEV_RELEASE == $RELEASE_VERSION ]]
  then
    #RELEASE_VERSION=$(../bin/gh release list -L 1 -R $REPO | awk '{print $1}')
    NEXT_RELEASE_VERSION=$(echo ${DEV_RELEASE} | awk -F. -v OFS=. '{$NF++;print}')
    echo "NEXTVERSION from inside loop: $NEXT_RELEASE_VERSION"
    sed -i "s/$DEV_RELEASE/$NEXT_RELEASE_VERSION/" $VERSION_FILE
  else
    NEXT_RELEASE_VERSION=$DEV_RELEASE
    echo "NEXTVERSION from inside ESLE: $NEXT_RELEASE_VERSION"
fi
#Updating LTAG Version in the installation-script
sed -i "s/LTAG=.*/LTAG=\"$NEXT_RELEASE_VERSION\";/" manifests/installation-script

#Updating latest installation-script URL in the devtron-installer.yaml
sed -i "s,url.*,url: "$RAW_GIT_REPO"$NEXT_RELEASE_VERSION\/manifests\/installation-script,g" manifests/install/devtron-installer.yaml

#appVersion change inside devtron-bom file
sed -i "s,release.*,release: \"$NEXT_RELEASE_VERSION\",g" charts/devtron/$DEVTRON_BOM_FILE


#-----------------------------------
echo "=================If else check from migration======================="
if [[ $MIGRATOR_LINE_1 == "x" ]]
  then
   echo "No Migration Changes"
  else 
# ========== Updating the Migration script with latest commit hash ==========
    echo "Migration hash update"
    sed -i "$MIGRATOR_LINE_1 s/value.*/value: $BUILD_COMMIT/" manifests/yamls/$MIGRATOR_FILE
fi

if [[ $MIGRATOR_LINE_2 == "x" ]]
  then
   echo "No Migration Changes for casbin"
  else 
# ========== Updating the Migration script with latest commit hash ==========
    echo "Migration hash update"
    sed -i "$MIGRATOR_LINE_2 s/value.*/value: $BUILD_COMMIT/" manifests/yamls/$MIGRATOR_FILE
fi

if [[ $MIGRATOR_LINE_BOM_1 == "x" ]]
  then
   echo "No Migration Changes"
  else 
# ========== Updating the Migration script with latest commit hash ==========
    echo "Migration hash update"
    sed -i "$MIGRATOR_LINE_BOM_1 s/GIT_HASH.*/GIT_HASH: \"$BUILD_COMMIT\"/" charts/devtron/$DEVTRON_BOM_FILE
fi

if [[ $MIGRATOR_LINE_BOM_2 == "x" ]]
  then
   echo "No Migration Changes for casbin"
  else 
# ========== Updating the Migration script with latest commit hash ==========
    echo "Migration hash update"
    sed -i "$MIGRATOR_LINE_BOM_2 s/GIT_HASH.*/GIT_HASH: \"$BUILD_COMMIT\"/" charts/devtron/$DEVTRON_BOM_FILE
fi

if [[ $MIGRATOR_LINE_CHART_1 == "x" ]]
  then
   echo "No Migration Changes"
  else 
# ========== Updating the Migration script with latest commit hash ==========
    echo "Migration hash update"
    sed -i "$MIGRATOR_LINE_CHART_1 s/GIT_HASH.*/GIT_HASH: \"$BUILD_COMMIT\"/" charts/devtron/$HYPERION_APP_MANIFEST
fi

if [[ $MIGRATOR_LINE_CHART_2 == "x" ]]
  then
   echo "No Migration Changes for casbin"
  else 
# ========== Updating the Migration script with latest commit hash ==========
    echo "Migration hash update"
    sed -i "$MIGRATOR_LINE_CHART_2 s/GIT_HASH.*/GIT_HASH: \"$BUILD_COMMIT\"/" charts/devtron/$HYPERION_APP_MANIFEST
fi

echo "=================If else end for migration======================="


echo "==============================Hyperion Repo==========================="
ls
pwd
echo "=============================checking files=========================="

cd charts/devtron

#Updating Image in the yaml for hyperion
sed -i "s/quay.io\/devtron\/$APP_DOCKER_REPO:.*/quay.io\/devtron\/$APP_DOCKER_REPO:$DOCKER_IMAGE_TAG\"/" $HYPERION_APP_MANIFEST

echo "######################################"

if [[ $DEV_RELEASE == $RELEASE_VERSION ]]
  then
    #RELEASE_VERSION=$(../bin/gh release list -L 1 -R $REPO | awk '{print $1}')
    HYP_RELEASE_VERSION=$(echo ${DEV_RELEASE} | awk -F. -v OFS=. '{$NF++;print}')
    echo "NEXTVERSION from inside loop: $HYP_RELEASE_VERSION"
    sed -i "s/$DEV_RELEASE/$HYP_RELEASE_VERSION/" $HYPERION_APP_MANIFEST
  else
    HYP_RELEASE_VERSION=$DEV_RELEASE
    echo "NEXTVERSION from inside ESLE: $HYP_RELEASE_VERSION"
fi

echo "##############################################"

echo "-----------------Chart version change---------"
wget https://raw.githubusercontent.com/$REPO/$GIT_BRANCH/charts/devtron/Chart.yaml -O version.yaml
CHART_DEV_RELEASE=$(sed -nre '13s/^[^0-9]*(([0-9]+\.)*[0-9]+).*/\1/p' version.yaml)
echo $CHART_DEV_RELEASE

CHART_NEXT_RELEASE=$(echo ${CHART_DEV_RELEASE} | awk -F. -v OFS=. '{$NF++;print}')

echo $CHART_NEXT_RELEASE

sed -i "s/$CHART_DEV_RELEASE/$CHART_NEXT_RELEASE/" $VERSION_FILE_CHART

rm version.yaml

#------------------------appVersion change in Chart.yaml-----------------------------------------------
wget https://raw.githubusercontent.com/$REPO/$GIT_BRANCH/manifests/version.txt -O version.txt
VERSION_OLD=`cat version.txt`
VERSION_NEW=$(echo "$VERSION_OLD" | tr -dc '[. [:digit:]]') 
echo $VERSION_NEW
VERSION_FINAL=$(echo ${VERSION_NEW} | awk -F. -v OFS=. '{$NF++;print}')
echo $VERSION_FINAL
sed -i "s/appVersion.*/appVersion: $VERSION_FINAL/" $VERSION_FILE_CHART
rm version.txt
#------------------------------------------------------------------------------------
git pull origin "$RELEASE_BRANCH" -v
git commit -am "Updated latest image of $APP_DOCKER_REPO in installer"
git push https://$GIT_USERNAME:$GITHUB_TOKENS@$GIT_REPO "$RELEASE_BRANCH" -v

PR_RESPONSE=$(../../../bin/gh pr create --title "RELEASE: PR for $NEXT_RELEASE_VERSION" --body "Updates in $APP_DOCKER_REPO micro-service and charts" --base $GIT_BRANCH --head $RELEASE_BRANCH --repo $REPO)
echo "FINAL PR RESPONSE: $PR_RESPONSE"
