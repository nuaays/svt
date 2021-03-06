#!/bin/bash

SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`

exitstatus=0

PARALLEL_NODES=5
PARALLEL_TESTS="EmptyDir|Conformance"
PARALLEL_SKIP="Serial|Flaky|Disruptive|Slow|should be applied to XFS filesystem when a pod is created"
# Need to debug
PARALLEL_SKIP="Prometheus|"$PARALLEL_SKIP
echo $PARALLEL_SKIP
SERIAL_TESTS="Serial"
SERIAL_SKIP="Flaky|Disruptive|Slow" 

cd
yum install atomic-openshift-tests
mkdir /root/go
export GOPATH=/root/go
export PATH=$PATH:$GOPATH/bin
go get github.com/onsi/ginkgo/ginkgo
export KUBECONFIG=/etc/origin/master/admin.kubeconfig

# create wildfly imagestream
cd $SCRIPTPATH
oc create -n openshift -f ./wildfly_imagestream.json


TEST_REPORT_DIR=/tmp TEST_REPORT_FILE_NAME=svt-parallel ginkgo -v "-focus=$PARALLEL_TESTS" "-skip=$PARALLEL_SKIP" -p -nodes "$PARALLEL_NODES"  /usr/libexec/atomic-openshift/extended.test  || exitstatus=$?
#TEST_REPORT_DIR=/tmp TEST_REPORT_FILE_NAME=svt-serial ginkgo -v "-focus=$SERIAL_TESTS" "-skip=$SERIAL_SKIP" /usr/libexec/atomic-openshift/extended.test  || exitstatus=$?
 
