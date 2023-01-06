#On the VM to read
#Raw data
$respraw=Invoke-WebRequest -Headers @{"Metadata"="true"} -Method GET -Proxy $Null -Uri "http://169.254.169.254/metadata/instance?api-version=2021-01-01"
$respraw
$respraw.Content
$respraw.Content | ConvertFrom-Json | ConvertTo-Json -Depth 6

#A better way that automatically creates us a nice PowerShell object with the response
$resp=Invoke-RestMethod -Headers @{"Metadata"="true"} -Method GET -Proxy $Null -Uri "http://169.254.169.254/metadata/instance?api-version=2021-01-01"
$respJSON = $resp | ConvertTo-Json -Depth 6

#Compute only, could do Network, all the main JSON headings
Invoke-RestMethod -Headers @{"Metadata"="true"} -Method GET -Proxy $Null -Uri "http://169.254.169.254/metadata/instance/compute?api-version=2021-01-01"

#Just get tags
Invoke-RestMethod -Headers @{"Metadata"="true"} -Method GET -Proxy $Null -Uri "http://169.254.169.254/metadata/instance/compute/tagsList?api-version=2021-01-01"

#Lets look at some of it
Write-Output "VM name - $($resp.compute.name), RG - $($resp.compute.resourceGroupName), VM size - $($resp.compute.vmSize)"

#userData view
$resp.compute.userData
[System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($resp.compute.userData))

#Scheduled events (this includes things like terminations if VMSS with grace window)
Invoke-RestMethod -Headers @{"Metadata"="true"} -Method GET -Proxy $Null -Uri "http://169.254.169.254/metadata/scheduledevents?api-version=2019-08-01"

<#
EventId : ID
EventStatus : Scheduled
EventType : Terminate
ResourceType : VirtualMachine
Resources : {vmss_3}
NotBefore : Tue, 04 May 2022 03:25:23 GMT
#>

#Linux
curl -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2020-09-01" | jq