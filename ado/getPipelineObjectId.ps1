Import-Module Az

$context = Get-AzContext
Write-Host "##vso[task.setvariable variable=TF_VAR_pipelineObjectId]$($context.Account.Id)"