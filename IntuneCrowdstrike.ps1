# Set the API Client ID and Secret from https://falcon.crowdstrike.com/api-clients-and-keys/clients and populate the variables below
# The CCID is pulled via a function in the script, there is no need to populate it.
# Created with inspiration from https://github.com/cliv/cs-falcon-protect-intune and the crowdstrike api guide

$CLIENT_ID=
$CLIENT_SECRET=
$URI_BASE= # Ex. https://api.crowdstrike.com, https://api.us-2.crowdstrike.com

function Get-Access-Token {
    $json=$(Invoke-WebRequest -Method POST -Body "client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}" -uri ${URI_BASE}/oauth2/token | ConvertFrom-Json)
    echo $json.access_token
}

function Get-SHA256 {
    $json=$(Invoke-WebRequest -Headers @{"Authorization" = "Bearer $(Get-Access-Token)"} -uri ${URI_BASE}/sensors/combined/installers/v1\?filter=platform%3A%22windows%22 | ConvertFrom-Json)
    echo $json.resources[0].sha256
}

function Get-CCID {
    $json=$(Invoke-WebRequest -Headers @{"Authorization" = "Bearer $(Get-Access-Token)"} -Uri ${URI_BASE}/sensors/queries/installers/ccid/v1 | ConvertFrom-Json)
    echo $json.resources
}

# check for install
if (!(Test-Path "C:\Program Files\CrowdStrike\CSFalconService.exe") -and (!(Get-Service -Name csagent).Status -ne 'Running')) {
    Invoke-WebRequest -OutFile c:\Windows\Temp\CrowdstrikeInstaller.exe -H @{"Authorization" = "Bearer $(Get-Access-Token)"} -Uri ${URI_BASE}/sensors/entities/download-installer/v1?id=$(Get-SHA256)
    c:\Windows\Temp\CrowdstrikeInstaller.exe /install /quiet /norestart CID=$(Get-CCID)
    rm c:\Windows\Temp\CrowdstrikeInstaller.exe
} else {
    echo "Crowdstrike Falcon is installed and running"
}
