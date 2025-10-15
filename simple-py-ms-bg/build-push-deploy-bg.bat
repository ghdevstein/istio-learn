cd ui-service-v1
docker build -t vinodhdevaarul/simple-py-ms:ui-v1-bg-01 -f Dockerfile_v1 .
docker push vinodhdevaarul/simple-py-ms:ui-v1-bg-01
cd ..

cd ui-service-v2
docker build -t vinodhdevaarul/simple-py-ms:ui-v2-bg-01 -f Dockerfile_v2 .
docker push vinodhdevaarul/simple-py-ms:ui-v2-bg-01
cd ..


cd data-service-v1
docker build -t vinodhdevaarul/simple-py-ms:data-v1-bg-01 -f Dockerfile-v1 .
docker push vinodhdevaarul/simple-py-ms:data-v1-bg-01
cd ..

cd data-service-v2
docker build -t vinodhdevaarul/simple-py-ms:data-v2-bg-01 -f Dockerfile-v2 .
docker push vinodhdevaarul/simple-py-ms:data-v2-bg-01
cd ..

cd trigger-service
docker build -t vinodhdevaarul/simple-py-ms:trigger-bg-01 .
docker push vinodhdevaarul/simple-py-ms:trigger-bg-01
cd ..

kubectl delete ns spms-bg
kubectl create ns spms-bg
kubectl label ns spms-bg istio-injection=enabled

REM kubectl apply -f manifests\bg-internal\mixed-approach-bg-internal.yml -n spms-bg
REM kubectl apply -f manifests\bg-internal\k8s-manifests.yml -n spms-bg

kubectl apply -f manifests\ingress.yml -n spms-bg
kubectl apply -f manifests\istio-manifests.yml -n spms-bg
kubectl apply -f manifests\k8s-manifests.yml -n spms-bg
