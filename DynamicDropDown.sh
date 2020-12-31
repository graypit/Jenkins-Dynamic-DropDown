#!/usr/bin/env bash
# Author: Habib Guliyev
# Global Variables:
Username='JenkinsUser'
Token='JenkinsUserToken'
JenkinsUrl='https://jenkins.example.com'
JenkinsJobName='job/foldername/job/jobname'
RandomName=`shuf -i 19943-457563 -n 1`
ExceptionList='default|kube-*|metallb-*|istio-*'

function CollectNamespaces() {
  for zone in {aws,azure}
  do
    for config in $(ls ./kubeconfigs/$zone/)
    do
      export KUBECONFIG=./kubeconfigs/$zone/$config
      timeout 3s kubectl get ns|tail --lines=+2|awk '{ print $1 }' >> ns-list-$zone
    done
    NamespaceList=$(sed "s/^/$zone:  /" ns-list-$zone|awk '!seen[$0]++'|egrep -v "$ExceptionList"|sort >> all-ns)
    rm -f ns-list-$zone
  done
  FirstNS=$(cat all-ns|head -n1)
}

function DropDownPreparation(){
  LineSpaces=$(echo -e '\t')
  cat all-ns | while read -r ns
  do
    printf '%s\n' "$LineSpaces<string>$ns</string>" >> $RandomName.xml
  done
  for zone in {aws,azure};do echo "$LineSpaces<string>Others:  $zone</string>" >> $RandomName.xml;done
  rm -f all-ns
}

function GetAndUpdateJenkinsJob(){
    curl -s -X GET -u "$Username:$Token" "$JenkinsUrl/$JenkinsJobName/config.xml" -o job.xml -H "Content-Type:text/xml" -k
    PropsStart=$(cat -n job.xml |grep "<string>$FirstNS</string>"| awk {'print $1'}|head -n1)
    PropsStartEnd=$(cat -n job.xml|tail --lines=+$PropsStart| grep '</a>'| awk '{print $1;}')
    cat job.xml |head -n +$PropsStart|head -n-1 > $RandomName.xml
    DropDownPreparation
    cat job.xml |tail -n +$PropsStartEnd >> $RandomName.xml
    curl -s -X POST -u "$Username:$Token" "$JenkinsUrl/$JenkinsJobName/config.xml" --data-binary "@$RandomName.xml" -H "Content-Type:text/xml" -k
    rm -rf job.xml $RandomName.xml
}
CollectNamespaces
GetAndUpdateJenkinsJob