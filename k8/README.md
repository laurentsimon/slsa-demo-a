https://minikube.sigs.k8s.io/docs/start/
minikube start
minikube delete -all

kubectl apply -f ngnix-delpoyment.yml
kubectl rollout status deployment/nginx-deployment
kubectl get pods --show-labels --namespace default # or get po
kubectl get deployments --show-labels --namespace default # or get deploy
kubectl get rs (replica set)

kubectl rollout history deployment/nginx-deployment

= update image
kubectl set image deployment/nginx-deployment nginx=nginx:1.16.1
or update file