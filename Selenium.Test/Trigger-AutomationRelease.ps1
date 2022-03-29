# PAT, Release definitionId and PollingFrequencyInSeconds are the inputs for this script. Once a pipeline is triggered using these parameters, a response is received and Id is used from the response to track newly created pipeline.


# This section represents payload for triggering a release through script
function CreateJsonBody
{
    $value = @"
{
 "definitionId":$Env:DefinitionID,
 "isDraft":false,
 "manualEnvironments":[]
}
"@
 return $value
}

# This is the Azure DevOps endpoint through which we can trigger a pipeline
$uri = "https://vsrm.dev.azure.com/elead1one/eleadplatform/_apis/release/releases?api-version=5.0"
$json = CreateJsonBody
$header = @{Authorization = 'Basic ' +[Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$Env:PAT")) }

$result = Invoke-RestMethod -Uri $uri -Body $json -Method Post -Header $header -ContentType "application/json"
write-host "Newly created release id is : " $result.id
"Newly created release url is https://dev.azure.com/elead1one/EleadPlatform/_releaseProgress?_a=release-pipeline-progress&releaseId=$($result.id)"

# Poll for every few seconds configured at pipeline variables to get release status
while($TRUE){
	$release = "https://vsrm.dev.azure.com/elead1one/eleadplatform/_apis/release/releases/"+ $result.id + "?api-version=6.0"
	$res = Invoke-RestMethod -Uri $release -Method Get -Header $header -ContentType "application/json"
	Write-Host "Release status is : "  $res.environments[0].status
	if($res.environments[0].status -eq 'succeeded'){
		write-host "condition-satisfied"
		write-host $res.environments[0].status
		exit 0
	}
	elseif($res.environments[0].status -eq 'rejected'){
		write-host "condition-satisfied"
		write-host $res.environments[0].status
		exit 1
	}
	Start-Sleep -s $Env:PollingFrequencyInSeconds
}
