Connect-AzureRmAccount
$allResources = @()
$subscriptions=Get-AzureRMSubscription
ForEach($vsub in $subscriptions){
Select-AzureRmSubscription $vsub.SubscriptionID
Write-Host
Write-Host "Working on " $vsub
Write-Host
$allResources += $allResources |Select-Object $vsub.SubscriptionID,$vsub.Name
Set-AzureRMContext $vsub
Get-AzureRMConsumptionUsageDetail
}