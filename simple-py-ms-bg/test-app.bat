@echo off
setlocal enabledelayedexpansion

echo 🚀 Testing minikube nginx + Istio setup
echo ========================================
echo.

REM Get minikube IP
echo 📍 Getting Minikube IP...
for /f "tokens=*" %%i in ('minikube ip 2^>nul') do set MINIKUBE_IP=%%i
if "%MINIKUBE_IP%"=="" (
    echo ❌ Error: Could not get minikube IP. Is minikube running?
    echo Run: minikube start
    pause
    exit /b 1
)
echo 📍 Minikube IP: %MINIKUBE_IP%

REM Get nginx ingress NodePort
echo 🔌 Getting nginx ingress NodePort...
for /f "tokens=*" %%i in ('kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath^="{.spec.ports[0].nodePort}" 2^>nul') do set NODEPORT=%%i
if "%NODEPORT%"=="" (
    echo ❌ Error: Could not get NodePort. Is nginx-ingress installed?
    echo Run: minikube addons enable ingress
    pause
    exit /b 1
)
echo 🔌 NodePort: %NODEPORT%

REM Build base URL
set BASE_URL=http://%MINIKUBE_IP%:%NODEPORT%
echo 🌐 Base URL: %BASE_URL%

echo.
echo 🧪 Testing Blue/Green Deployment
echo ================================
echo.

echo 1️⃣ Testing BLUE version (default traffic):
echo Command: curl -H "Host: spms-bg-v2" "%BASE_URL%"
curl -s -H "Host: spms-bg-v2" "%BASE_URL%" 2>nul
if !errorlevel! neq 0 (
    echo ❌ Blue test failed - check if services are running
) else (
    echo ✅ Blue test completed
)
echo.

echo 2️⃣ Testing GREEN version (with version header):
echo Command: curl -H "Host: spms-bg-v1" -H "version: green" "%BASE_URL%"
curl -s -H "Host: spms-bg-v1" -H "version: green" "%BASE_URL%" 2>nul
if !errorlevel! neq 0 (
    echo ❌ Green test failed - check Virtual Service configuration
) else (
    echo ✅ Green test completed
)
echo.

echo 🔍 Debugging Information
echo =======================
echo.

echo 📋 Ingress Status:
kubectl get ingress -n spms-bg 2>nul
if !errorlevel! neq 0 echo ❌ No ingress found in spms-bg namespace
echo.

echo 🛠️ Istio Gateway Status:
kubectl get gateway -n spms-bg 2>nul
if !errorlevel! neq 0 echo ❌ No gateway found in spms-bg namespace
echo.

echo 🛣️ Virtual Service Status:
kubectl get virtualservice -n spms-bg 2>nul
if !errorlevel! neq 0 echo ❌ No virtualservice found in spms-bg namespace
echo.

echo 🎯 DestinationRule Status:
kubectl get destinationrule -n spms-bg 2>nul
if !errorlevel! neq 0 echo ❌ No destinationrule found in spms-bg namespace
echo.

echo 🔧 Services in spms-bg:
kubectl get svc -n spms-bg 2>nul
if !errorlevel! neq 0 echo ❌ No services found in spms-bg namespace
echo.

echo 📦 Pods in spms-bg:
kubectl get pods -n spms-bg 2>nul
if !errorlevel! neq 0 echo ❌ No pods found in spms-bg namespace
echo.

echo 🔧 Nginx Ingress Controller Status:
kubectl get pods -n ingress-nginx 2>nul
if !errorlevel! neq 0 echo ❌ Nginx ingress controller not found
echo.

echo 🌐 Istio System Status:
kubectl get pods -n istio-system 2>nul
if !errorlevel! neq 0 echo ❌ Istio system not found
echo.

echo 📝 Manual Testing Commands:
echo ============================
echo Default (Blue):  curl -H "Host: spms-bg-v2" %BASE_URL%
echo Green:           curl -H "Host: spms-bg-v1" -H "version: green" %BASE_URL%
echo Port Forward:    kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80
echo Tunnel:          minikube tunnel  ^(run in separate terminal^)
echo.

