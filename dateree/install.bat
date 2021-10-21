rem Datree - validate the manifest are wriiten according to k8s best practice and without volnerability
rem open wsl and install unxip
sudo apt-get install zip unzip
pause

rem *** instal datree ***
curl https://get.datree.io | /bin/bash

rem *** check datree installed and check policy of k8s-demo.yaml ***
datree test ~/.datree/k8s-demo.yaml

rem see all datree rules in policy - need to authorize with github
https://app.datree.io/login?cliId=6oaFgDR6bYqmM8XytYnKFM

rem update rule - Prevent Service from exposing node port to use ClusterIP instaed.

rem *** fix yaml according to datree policy ***
rem sudo nano  ~/.datree/k8s-demo.yaml
owner: --  > owner: yaron 
image nginx:latest  --> image nginx:1.21 (make sure we installed tested image and not latest)
limits --> add memory: "128Mi" (make sure the cluster is helthy and not stucked)
readinessProbe: -->  livenessProbe: (add a properly configured livenessProbe to catch possible deadlocks)


rem *** check again datree policy on k8s-demo.yaml ***
datree test ~/.datree/k8s-demo.yaml

