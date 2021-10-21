rem *** create namespace argocd***
kubectl create ns argocd
pause

rem *** get argocd cli version and install it ***
$version = (Invoke-RestMethod https://api.github.com/repos/argoproj/argo-cd/releases/latest).tag_name
echo $version
pause
$url = "https://github.com/argoproj/argo-cd/releases/download/" + $version + "/argocd-windows-amd64.exe"
pause
$output = "argocd.exe"
pause
Invoke-WebRequest -Uri $url -OutFile $output
pause

rem *** install argocd ***
cd C:\Kubernetes\Kubernetes-Azure\argocd
kubectl apply -n argocd -f install.yml
rem kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.0.5/manifests/install.yaml
pause

kubectl get all -n argocd
pause

rem *** get login password and decode base64***
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"

decode the password here: https://www.base64decode.org/  (NHEYjgHlPFXAEtPt)

kubectl get svc -n argocd
kubectl port-forward svc/argocd-server -n argocd 8080:443
https://localhost:8080 

user:admin 
password: NHEYjgHlPFXAEtPt

rem *** change password ***
.\argocd.exe account update-password
decoded password (pKJytFOYYSryobiL) --> admin

rem *** login from GUI ***
https://localhost:8080 
user:admin 
password: admin


rem *** creare new app from command ***
kubectl config view  ( get k8s server url)

.\argocd.exe app create employee-app --repo https://github.com/yaronzlotolov/Kubernetes-Docker-Desktop.git --path deplyment --dest-server https://kubernetes.defualts.svc --dest-namespace default


rem *** create app from argocd GUI ***
rem **** add github repository and path to deployment
rem **** sync github with local deployment

rem *** scale up employee deploy to 2
kubectl -n employee scale deploy employee-deployment --replicas 2
pause
kubectl get all -n employee
pause
see in https://localhost:31927/applications/employees?operation=false that employee has 2 pods
rem sync
rem the number of employee pods is 1


