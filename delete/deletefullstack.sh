#!/bin/bash

WORKDIR="/opt/delete"
CLUSTER_REPO=$CLUSTER-gke-gsm
SCRIPTNAME=`basename "$0"`
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if [[ $# -ne 1 ]]; then
    echo "`date`: ERROR: Illegal number of parameters: $SCRIPTNAME $@"  >> $WORKDIR/error.log
    exit 2
fi

APPNAME=$1

exec >> $WORKDIR/$APPNAME.txt 2>&1

# Debug
set -x

echo "`date`: Deleting app $APPNAME..."

echo "Cloning or pulling cluster repository..."

cd $WORKDIR

git clone https://github.com/${GIT_ORGANIZATION}/${CLUSTER_REPO}.git || (echo "Repo already exists, pulling..." && git -C ${CLUSTER_REPO}/ pull origin)

cd ${CLUSTER_REPO}

echo "Deleting app from staging"
# Delete chart entry in the helmfiles/jx-staging/helmfile.yaml
awk -v pattern="- chart: dev\/$APPNAME[[:blank:]]*$" 'BEGIN{ print_flag=1 } 
{
    if( $0 ~ pattern ) 
    {
       print_flag=0;
       next
    } 
    if( $0 ~ /^[a-zA-Z0-9\d-]/ ) 
    {
        print_flag=1;   
    } 
    if ( print_flag == 1 ) 
        print $0

} ' helmfiles/jx-staging/helmfile.yaml > helmfile.tmp

mv helmfile.tmp helmfiles/jx-staging/helmfile.yaml

# echo "Deleting app from production"
# Delete chart entry in the helmfiles/jx-production/helmfile.yaml
# TODO

echo "Deleting app in config-root staging..."
# Delete application folder in jx-staging config-root
rm -rf config-root/namespaces/jx-staging/$APPNAME

# echo "Deleting app in config-root production..."
# Delete application folder in jx-production config-root
# TODO
# rm -rf config-root/namespaces/jx-production/$APPNAME

echo "Deleting repositories entries in cluster repo..."
# Delete yaml file in source-repositories
rm config-root/namespaces/jx/source-repositories/$GIT_ORGANIZATION-$APPNAME.yaml
# Delete entries from .jx/gitops/source-config.yaml
sed -i "/$APPNAME\$/d" .jx/gitops/source-config.yaml

echo "Pushing to GitOps repository"
git add .
git commit -m "Delete app $APPNAME"
git push

# echo "Deleting repositories resources in jx namespace..."
# Delete sr resources in jx namespace
kubectl -n jx delete sr $GIT_ORGANIZATION-$APPNAME

echo "Deleting resources in staging namespace created for the database dependency..."
# Delete resources in staging created for the database dependency
kubectl -n jx-staging delete externalsecret $APPNAME-${APPNAME}db
kubectl -n jx-staging delete secret $APPNAME-${APPNAME}db
kubectl -n jx-staging delete secret $(kubectl -n jx-staging get secret | grep $APPNAME-$APPNAME-token-* | awk NF=1)
kubectl -n jx-staging delete serviceaccount $APPNAME-$APPNAME
kubectl -n jx-staging patch pvc data-$APPNAME-${APPNAME}db-0 -p '{"metadata":{"finalizers":null}}'
kubectl -n jx-staging delete pvc data-$APPNAME-${APPNAME}db-0

echo "Deleting images and charts..."
N=0
for digest in $(gcloud container images list-tags gcr.io/${PROJECT}/${APPNAME} --limit=999999 --format='get(digest)'); do
    (
      set -x
      gcloud container images delete --quiet  --force-delete-tags "gcr.io/$PROJECT/${APPNAME}@${digest}"
    )
    let N=N+1
  done
echo "Deleted ${N} images of ${APPNAME} in gcr.io."

CHARTMUSEUM=$(kubectl -n jx get ing chartmuseum -o jsonpath={.spec.rules[0].host})
CMUSER=$(kubectl -n jx get secret jenkins-x-chartmuseum -o jsonpath={.data.BASIC_AUTH_USER} |base64 -d)
CMPASS=$(kubectl -n jx get secrets jenkins-x-chartmuseum -o jsonpath={.data.BASIC_AUTH_PASS} |base64 -d)

N=0
for TAG in $(curl -s -X GET http://${CHARTMUSEUM}/api/charts/${APPNAME} | grep -oP 'appVersion":"\K[0-9.]+'); do
    (
        set -x
      curl --user ${CMUSER}:${CMPASS}  --location --request DELETE "http://${CHARTMUSEUM}/api/charts/${APPNAME}/${TAG}"
    )
    let N=N+1
done
echo "Deleted ${N} charts of ${APPNAME} in Chartmuseum."
