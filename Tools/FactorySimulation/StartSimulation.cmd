
@ECHO OFF
SETLOCAL EnableDelayedExpansion

SET "arg1=%1"
SET "arg2=%2"
SET "arg3=%3"
SET "arg4=%4"
SET "arg5=%5"
SET "arg6=%6"
SET "arg7=%7"
SET "arg8=%8"
SET "arg9=%9"
SHIFT
SET "arg10=%9"
SHIFT
SET "arg11=%9"
SHIFT
SET "arg12=%9"
SHIFT
SET "arg13=%9"
SHIFT
SET "arg14=%9"
SHIFT
SET "arg15=%9"
SHIFT
SET "arg16=%9"

ECHO .
ECHO Arguments provided:
ECHO 1: !arg1!
ECHO 2: !arg2!
ECHO 3: !arg3!
ECHO 4: !arg4!
ECHO 5: !arg5!
ECHO 6: !arg6!=
ECHO 7: !arg7!
ECHO 8: !arg8!
ECHO 9: !arg9!
ECHO 10: !arg10!
ECHO 11: !arg11!
ECHO 12: !arg12!
ECHO 13: !arg13!
ECHO 14: !arg14!
ECHO 15: !arg15!
ECHO 16: !arg16!

if "%~1"=="" goto :InvalidArgument
IF NOT !arg1!==Endpoint goto :InvalidArgument
IF NOT !arg3!==SharedAccessKeyName goto :InvalidArgument
IF NOT !arg4!==RootManageSharedAccessKey goto :InvalidArgument
IF NOT !arg5!==SharedAccessKey goto :InvalidArgument
IF NOT !arg7!==DefaultEndpointsProtocol goto :InvalidArgument
IF NOT !arg8!==https goto :InvalidArgument
IF NOT !arg9!==AccountName goto :InvalidArgument
IF NOT !arg11!==AccountKey goto :InvalidArgument
IF NOT !arg13!==EndpointSuffix goto :InvalidArgument
IF NOT !arg14!==core.windows.net goto :InvalidArgument
goto :Config

:InvalidArgument
ECHO Argument error:
ECHO Input parameters must be of the form Endpoint=sb://[eventhubnamespace].servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=[key] DefaultEndpointsProtocol=https;AccountName=[storageaccountname];AccountKey=[key];EndpointSuffix=core.windows.net [subscriptionID] [tenantID]
EXIT /B 1

:Config
SET "connectionstring=!arg1!=!arg2!;!arg3!=!arg4!;!arg5!=!arg6!="
SET "name=!arg2!"
SET "storageconnectionstring=!arg7!=!arg8!;!arg9!=!arg10!;!arg11!=!arg12!==;!arg13!=!arg14!"
SET "storagename=!arg10!"

ECHO .
ECHO Events Hub connection string: !connectionstring!
ECHO Storage Account connection string: !storageconnectionstring!
ECHO Event Hubs name: !name!
ECHO Storage Account name: !storagename!
ECHO Azure Subscription: !arg15!
ECHO Azure Tenant: !arg16!

CALL az account clear
CALL az config set core.enable_broker_on_windows=false
CALL az login -t !arg16!
CALL az account set -s !arg15!
CALL az extension add --name azure-iot-ops --allow-preview true
CALL az extension add --name connectedk8s

ECHO .
ECHO Copying Publisher config files...
Xcopy /E /I /Y .\PublisherConfig C:\k8s\PublisherConfig

ECHO Copying Kubernetes deployment files...
Xcopy /E /I /Y ..\..\Deployment C:\k8s\Deployment

ECHO Configuring Publisher config files...
C:
CD "C:\k8s\PublisherConfig\Munich\"
CALL :ReplaceEventHubName
CALL :ReplaceEventHubKey

CD "C:\k8s\PublisherConfig\Seattle\"
CALL :ReplaceEventHubName
CALL :ReplaceEventHubKey

ECHO Configuring Deployment files...
CD "C:\k8s\Deployment\Munich\"
CALL :ReplaceStorageAccountKeyMES
CALL :ReplaceStorageAccountKeyPublisher
CALL :ReplaceStorageAccountKeyCommander
CALL :ReplaceEventHubNameCommander
CALL :ReplaceEventHubKeyCommander
CALL :ReplaceStorageAccountKeyProductionLine

CD "C:\k8s\Deployment\Seattle\"
CALL :ReplaceStorageAccountKeyMES
CALL :ReplaceStorageAccountKeyPublisher
CALL :ReplaceStorageAccountKeyCommander
CALL :ReplaceEventHubNameCommander
CALL :ReplaceEventHubKeyCommander
CALL :ReplaceStorageAccountKeyProductionLine

ECHO .
ECHO Starting Munich production line...
ECHO ==================================
ECHO .

ECHO Uploading UA-CloudPublisher config files to cloud...
CD "C:\k8s\PublisherConfig\Munich\"
CALL az storage container create -n munich --connection-string !storageconnectionstring!
CALL az storage blob upload-batch -d munich --connection-string !storageconnectionstring! -s "." --destination-path "app/settings" --overwrite

ECHO Starting UA-CloudPublisher, UA-CloudCommander and MES to upload OPC UA cert to cloud...
CD "C:\k8s\Deployment\Munich\"
kubectl apply -f UA-CloudPublisher.yaml

ECHO Starting UA-CloudCommander...
kubectl apply -f UA-CloudCommander.yaml

ECHO Starting MES...
kubectl apply -f MES.yaml

ECHO Waiting for OPC UA certs to be created, please be patient...
Timeout 45 /nobreak

ECHO Starting production line...
kubectl apply -f ProductionLine.yaml

ECHO Waiting for OPC UA certs to be oploaded, please be patient...
Timeout 45 /nobreak

ECHO Restarting UA-CloudPublisher...
CD "C:\k8s\Deployment\Munich\"
kubectl delete service -n munich ua-cloudpublisher
kubectl delete deployment -n munich ua-cloudpublisher
kubectl apply -f UA-CloudPublisher.yaml

ECHO .
ECHO Starting Seattle production line...
ECHO ==================================
ECHO .

Echo Uploading UA-CloudPublisher config files to cloud...
CD "C:\k8s\PublisherConfig\Seattle\"
CALL az storage container create -n seattle --connection-string !storageconnectionstring!
CALL az storage blob upload-batch -d seattle --connection-string !storageconnectionstring! -s "." --destination-path "app/settings" --overwrite

ECHO Starting UA-CloudPublisher, UA-CloudCommander and MES to upload OPC UA cert to cloud...
CD "C:\k8s\Deployment\Seattle\"
kubectl apply -f UA-CloudPublisher.yaml

ECHO Starting UA-CloudCommander...
kubectl apply -f UA-CloudCommander.yaml

ECHO Starting MES...
kubectl apply -f MES.yaml

ECHO Waiting for OPC UA certs to be created, please be patient...
Timeout 45 /nobreak

ECHO Starting production line...
kubectl apply -f ProductionLine.yaml

ECHO Waiting for OPC UA certs to be uploaded, please be patient...
Timeout 45 /nobreak

Echo Restarting UA-CloudPublisher...
CD "C:\k8s\Deployment\Seattle\"
kubectl delete service -n seattle ua-cloudpublisher
kubectl delete deployment -n seattle ua-cloudpublisher
kubectl apply -f UA-CloudPublisher.yaml

ECHO .
ECHO Production lines started.
kubectl apply -f https://raw.githubusercontent.com/Azure/AKS-Edge/main/samples/storage/local-path-provisioner/local-path-storage.yaml
az provider register -n "Microsoft.ExtendedLocation"
az provider register -n "Microsoft.Kubernetes"
az provider register -n "Microsoft.KubernetesConfiguration"
az provider register -n "Microsoft.IoTOperationsOrchestrator"
az provider register -n "Microsoft.IoTOperationsMQ"
az provider register -n "Microsoft.IoTOperationsDataProcessor"
az provider register -n "Microsoft.DeviceRegistry"
EXIT /B 0

:ReplaceEventHubName
SET "original=[myeventhubsnamespace].servicebus.windows.net"
SET "replacement=!name!"
SET "replacement=!replacement:sb:=!"
SET "replacement=!replacement:/=!"
(
FOR /F "tokens=* delims=" %%a IN (settings.json) DO (
 SET "line=%%a"
 SET "line=!line:%original%=%replacement%!"
 ECHO !line!
)
) > output.json
DEL settings.json
RENAME output.json settings.json
EXIT /B 0

:ReplaceEventHubNameCommander
SET "original=[myeventhubsnamespace].servicebus.windows.net"
SET "replacement=!name!"
SET "replacement=!replacement:sb:=!"
SET "replacement=!replacement:/=!"
(
FOR /F "tokens=* delims=" %%a IN (UA-CloudCommander.yaml) DO (
 SET "line=%%a"
 SET "line=!line:%original%=%replacement%!"
 ECHO !line!
)
) > output.yaml
DEL UA-CloudCommander.yaml
RENAME output.yaml UA-CloudCommander.yaml
EXIT /B 0

:ReplaceEventHubKey
SET "original=[myeventhubsnamespaceprimarykeyconnectionstring]"
SET "replacement=!connectionstring!"
(
FOR /F "tokens=* delims=" %%a IN (settings.json) DO (
 SET "line=%%a"
 SET "line=!line:%original%=%replacement%!"
 ECHO !line!
)
) > output.json
DEL settings.json
RENAME output.json settings.json
EXIT /B 0

:ReplaceEventHubKeyCommander
SET "original=[myeventhubsnamespaceprimarykeyconnectionstring]"
SET "replacement=!connectionstring!"
(
FOR /F "tokens=* delims=" %%a IN (UA-CloudCommander.yaml) DO (
 SET "line=%%a"
 SET "line=!line:%original%=%replacement%!"
 ECHO !line!
)
) > output.yaml
DEL UA-CloudCommander.yaml
RENAME output.yaml UA-CloudCommander.yaml
EXIT /B 0

:ReplaceStorageAccountKeyMES
SET "original=[mystorageaccountkey1connectionstring]"
SET "replacement=!storageconnectionstring!"
(
FOR /F "tokens=* delims=" %%a IN (MES.yaml) DO (
 SET "line=%%a"
 SET "line=!line:%original%=%replacement%!"
 ECHO !line!
)
) > output.yaml
DEL MES.yaml
RENAME output.yaml MES.yaml
EXIT /B 0

:ReplaceStorageAccountKeyPublisher
SET "original=[mystorageaccountkey1connectionstring]"
SET "replacement=!storageconnectionstring!"
(
FOR /F "tokens=* delims=" %%a IN (UA-CloudPublisher.yaml) DO (
 SET "line=%%a"
 SET "line=!line:%original%=%replacement%!"
 ECHO !line!
)
) > output.yaml
DEL UA-CloudPublisher.yaml
RENAME output.yaml UA-CloudPublisher.yaml
EXIT /B 0

:ReplaceStorageAccountKeyCommander
SET "original=[mystorageaccountkey1connectionstring]"
SET "replacement=!storageconnectionstring!"
(
FOR /F "tokens=* delims=" %%a IN (UA-CloudCommander.yaml) DO (
 SET "line=%%a"
 SET "line=!line:%original%=%replacement%!"
 ECHO !line!
)
) > output.yaml
DEL UA-CloudCommander.yaml
RENAME output.yaml UA-CloudCommander.yaml
EXIT /B 0

:ReplaceStorageAccountKeyProductionLine
SET "original=[mystorageaccountkey1connectionstring]"
SET "replacement=!storageconnectionstring!"
(
FOR /F "tokens=* delims=" %%a IN (ProductionLine.yaml) DO (
 SET "line=%%a"
 SET "line=!line:%original%=%replacement%!"
 ECHO !line!
)
) > output.yaml
DEL ProductionLine.yaml
RENAME output.yaml ProductionLine.yaml
EXIT /B 0
