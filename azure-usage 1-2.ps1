# Import
Import-Module -Name AzureRM.UsageAggregates

# Set date range for exported usage data
$reportedStartTime = "2019-06-25"
$reportedEndTime = "2019-06-26"

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
    $filename = "c:\Users\sran\Documents\Azure_PowerShell_Scripts\usageData\usageData-${subId}-${reportedStartTime}-${reportedEndTime}.csv"

    # Set usage parameters
    $granularity = "Daily" # Can be Hourly or Daily
    $showDetails = $true

    # Export Usage to CSV
    $appendFile = $false
    $continuationToken = $null
    Do { 
        $usageData = Get-UsageAggregates `
            -ReportedStartTime $reportedStartTime `
            -ReportedEndTime $reportedEndTime `
            -AggregationGranularity $granularity `
            -ShowDetails:$showDetails `
            -ContinuationToken $continuationToken
        $usageData.UsageAggregations.Properties | 
            Select-Object `
                UsageStartTime, `
                UsageEndTime, `
                @{n='SubscriptionId';e={$subscriptionId}}, `
                MeterCategory, `
                MeterId, `
                MeterName, `
                MeterSubCategory, `
                MeterRegion, `
                Unit, `
                Quantity, `
                @{n='Project';e={$_.InfoFields.Project}}, `
                InstanceData | 
            Export-Csv `
                -Append:$appendFile `
                -NoTypeInformation:$true `
                -Path $filename
        if ($usageData.NextLink) {
            $continuationToken = `
                [System.Web.HttpUtility]::`
                UrlDecode($usageData.NextLink.Split("=")[-1])
        } else {
            $continuationToken = ""
        }
        $appendFile = $true
    } until (!$continuationToken)
}
