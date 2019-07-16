# Set date range for exported usage data
$startDate = "2019-06-15"
$endDate = "2019-07-14"

# Login
# Prereq: Authenticate to Azure:
# PS> Connect-AzureRmAccount
# PS> Save-AzureRmProfile -Path "c:\Users\sran\Documents\Azure_PowerShell_Scripts\credentials\sran_profile.json"
# Auto-Login:
Import-AzureRmContext -Path "c:\Users\sran\Documents\Azure_PowerShell_Scripts\credentials\sran_profile.json"

# Get all Azure subscriptions
$subscriptions = Get-AzureRmSubscription

# Use for-each to loop over all subscriptions
ForEach($sub in $subscriptions){
    $subId = $sub.subscriptionId
    Select-AzureRmSubscription -SubscriptionId $subId
    Write-Host
    Write-Host "Working on " $subId
    Write-Host
    
    # Set path to exported CSV file
    $filename = "c:\Users\sran\Documents\Azure_PowerShell_Scripts\details\usageData-${subId}-${startDate}-${endDate}.csv"

    # Export data
    $usageData = Get-AzureRmConsumptionUsageDetail `
        -StartDate $startDate `
        -EndDate $endDate `
        -Expand MeterDetails
    $usageData | 
        Select `
            AccountName, `
            BillingPeriodId, `
            ConsumedService, `
            CostCenter, `
            Currency, `
            DepartmentName, `
            Id, `
            InstanceId, `
            InstanceLocation, `
            InstanceName, `
            IsEstimated, `
            @{n="MeterCategory";e={$_.MeterDetails.MeterCategory}}, `
            @{n="MeterLocation";e={$_.MeterDetails.MeterLocation}}, `
            @{n="MeterName";e={$_.MeterDetails.MeterName}}, `
            @{n="MeterSubCategory";e={$_.MeterDetails.MeterSubCategory}}, `
            @{n="Unit";e={$_.MeterDetails.Unit}}, `
            MeterId, `
            Name, `
            PretaxCost, `
            Product, `
            SubscriptionGuid, `
            SubscriptionName, `
            Type, `
            UsageStart, `
            UsageEnd, `
            UsageQuantity |
        Export-Csv `
            -Append `
            -NoTypeInformation:$true `
            -Path $filename
}
