rem *** Clean up kuberneties name sapce, docker images and containers and login to docker hub ***
rem docker system prune -a
rem kubectl delete ns employee
rem resore to factory defualts from Troubleshoot icon in deocker desktop


rem *** Get credentials for kubectl ***
az aks get-credentials --resource-group aks-demo-rg --name aks-demo
kubectl get nodes

rem *** the mnifest are here ***
cd C:\Kubernetes\Kubernetes-Azure\deployment

rem *** create employee namespace ***
kubectl create ns employee
pause
kubectl get ns
pause

rem *** create connection string and sa password secrets to MSSQL ***
kubectl create secret generic mssql-secret --namespace=employee --from-literal='ConnectionString="server=mssql-service;Initial Catalog=EmployeeDB;Persist Security Info=False;User ID=sa;Password=MyDemoPwd2021!;MultipleActiveResultSets=true"' --from-literal='SA_PASSWORD=MyDemoPwd2021!'
echo  ****** create secret generic mssql-secret manually!!! *****
pause
rem kubectl create secret generic mssql-secret --namespace=employee --from-literal=ConnectionString=.\cn.txt --from-literal=SA_PASSWORD=.\pass.txt
pause
kubectl get secret mssql-secret -n employee -oyaml
pause
rem *** deploy MSSQl with secret and persistent volume (take few minutes on the first time)***
kubectl get storageclass 
rem update default in mssql-deploy-with-secret-and-pv.yml in storageClassName
pause
kubectl apply -f .\mssql-deploy-with-secret-and-pv.yml
pause
kubectl get pvc -n employee
kubectl get pv -n employee 
pause
kubectl get pods -n employee
pause
kubectl get all -n employee
pause
rem get the service external IP for sql server on aks and update the server in ConnectionStrings__ConnectionString in OS environment variables. close vscode and open again.
timeout 150
pause
rem *** create EMPLOYEEDB using dotnet ef core (make sure the connection string is updated in Employees\appsettings.json or in Environmet Variables for User)  ***
rem ConnectionStrings__ConnectionString -> server=localhost,1433;Initial Catalog=EmployeeDB;Persist Security Info=False;User ID=sa;Password=MyDemoPwd2021!;MultipleActiveResultSets=true
cd C:\Kubernetes\Kubernetes-Azure\Employees
kubectl get svc -n employee  (get external ip for sql server)
Option1 - appsettings.json -> ConnectionString -> "server=server-ip;Initial Catalog=EmployeeDB;Persist Security Info=False;User ID=sa;Password=MyDemoPwd2021!;MultipleActiveResultSets=true"
Option2 - Add to environment variable: Variable name:  ConnectionStrings__ConnectionString  Variable value: server=server-ip,1433;Initial Catalog=EmployeeDB;Persist Security Info=False;User ID=sa;Password=MyDemoPwd2021!;MultipleActiveResultSets=true
cd employee
dotnet ef database update
dotnet build
dotnet run
http://localhost:5000/     (check the web application works with SQL server in K8s)

pause
rem if failed check if ConnectionStrings__ConnectionString exists in OS environmwnr variables (user and system)
rem check sql server pod if failed
kubectl get pods -n employee
kubectl -n employee exec -it mssql-deployment-6bcb97764c-m675k  -- /bin/sh
/opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U sa -Q "SELECT Physical_Name FROM sys.master_files" -P "MyDemoPwd2021!" -W
/opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U sa -Q "SELECT * FROM EmployeeDB.INFORMATION_SCHEMA.TABLES" -P "MyDemoPwd2021!" -W
/opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U sa -Q "SELECT * FROM EmployeeDB.dbo.Employees" -P "MyDemoPwd2021!" -W
/opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U sa -Q "SELECT * FROM EmployeeDB.dbo.__EFMigrationsHistory" -P "MyDemoPwd2021!" -W

rem dotnet build
rem pause
rem dotnet run
rem pause
rem http://localhost:5000/
rem pause

rem *** Create docker image and push it to docker hub ***
rem cd C:\Kubernetes\Kubernetes-Azure
rem docker build -t employees:v5 .  
rem pause
rem docker images | more
rem pause
rem docker tag employees:v5 yaronzlotolov/employees:v5
rem pause
rem docker images | more
rem pause
rem docker push yaronzlotolov/employees:v5
rem pause
rem https://hub.docker.com/repository/docker/yaronzlotolov/employees
rem pause

rem *** TLS/SSL certification secret for employee web site in inngress-nginx
cd C:\Kubernetes\Kubernetes-Azure\certification
kubectl create secret tls employee-secret --key privkey.pem --cert cert.pem -n employee
pause
kubectl get secret employee-secret -n employee -oyaml
pause
kubectl describe secret employee-secret -n employee
pause


rem ** deploy netcore web application with ingress-nginx ***
cd C:\Kubernetes\Kubernetes-Azure\deployment
pause
kubectl apply -f .\ingress-nginx-deployment.yml
pause
kubectl get all -n ingress-nginx
timeout 120
pause
rem check netcore-deploy-with-ingress-nginx.yml -> yaronzlotolov/employees:v5
rem pause
cd C:\Kubernetes\Kubernetes-Azure\deployment
docker pull yaronzlotolov/employees:v5
pause
rem Do NOT cd C:\Kubernetes\Kubernetes-Azure\Deployment!!!!!!
kubectl apply -f .\netcore-deploy-with-ingress-nginx.yml 
rem sleep 60 sec
pause
kubectl get all -n employee
pause
http://external-ip/  (make sure port 80)
pause
kubectl get ing -n employee
kubectl describe ing -n employee
C:\Windows\System32\drivers\etc\hosts  (external-ip DNS)
pause
rem in case of problem restart VScode
rem kubectl delete -f .\netcore-deploy-with-ingress-nginx.yml
pause
rem kubectl get all -n employee
pause
rem kubectl -n employee get deploy employee-deployment -oyaml
rem set netcore-deploy-with-ingress-nginx.yml -> employees:v5
rem docker pull yaronzlotolov/employees:v5
rem kubectl describe -n employee pod/employee-deployment-59db54f94c-gkgj4
pause
rem cd C:\Kubernetes\Kubernetes-Azure\deployment
rem kubectl apply -f .\netcore-deploy-with-ingress-nginx.yml 
pause
kubectl get all -n employee
pause
rem C:\Windows\System32\drivers\etc\hosts > 127.0.0.1 employee.management.com
rem employee.management.com


rem *** monitoring - install Chocolaty for kubernetes helm repo for prometheus-operator *** 
helm repo update
pause
helm install prometheus stable/prometheus-operator
pause
kubectl apply -f .\prometheus-ingress-controller.yml
kubectl get all
kubectl --namespace default get pods -l "release=prometheus"
kubectl get pods
kubectl get service prometheus-prometheus-oper-prometheus -o yaml
pause
timeout 30
kubectl get ing  
kubectl describe ing  (address is the external-ip and Host is prometheus.gui.com)
C:\Windows\System32\drivers\etc\hosts > Address prometheus.gui.com 
https://prometheus.gui.com/
user:admin
password: prom-operator
rem Manage > Kubernetes / Compute Resources / Pod

Done! 

Next go to argocd folder and use commands.txt for gitops