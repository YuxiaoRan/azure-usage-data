# Set date range for exported usage data
$date = "2019-07-15"

# Login
Connect-AzureRmAccount

# Connect to DB
$database = 'test_import_2'
$server = 'CAT-C0CYVHA\SQLEXPRESS'
$table = 'dbo.usageData'

# Get all Azure subscriptions
$subscriptions = Get-AzureRmSubscription

# Use for-each to loop over all subscriptions
ForEach($sub in $subscriptions){
    $subId = $sub.subscriptionId
    Select-AzureRmSubscription -SubscriptionId $subId
    Write-Host
    Write-Host "Pulling Data from " $subId
    Write-Host
    
    # Set path to exported CSV file
    $filename = "c:\Users\sran\Documents\testData\usageData-${subId}-${date}.csv"

    # Export data
    try{
        $usageData = Get-AzureRmConsumptionUsageDetail `
            -StartDate $date `
            -EndDate $date `
            -Expand MeterDetails
        $usageData | 
            Select `
                ConsumedService, `
                Currency, `
                InstanceId, `
                InstanceName, `
                @{n="MeterCategory";e={$_.MeterDetails.MeterCategory}}, `
                @{n="MeterLocation";e={$_.MeterDetails.MeterLocation}}, `
                @{n="MeterName";e={$_.MeterDetails.MeterName}}, `
                @{n="MeterSubCategory";e={$_.MeterDetails.MeterSubCategory}}, `
                @{n="Unit";e={$_.MeterDetails.Unit}}, `
                MeterId, `
                Name, `
                PretaxCost, `
                SubscriptionGuid, `
                SubscriptionName, `
                UsageStart, `
                UsageEnd, `
                UsageQuantity |
            Export-Csv `
                -NoTypeInformation:$true `
                -Path $filename
    }
    catch{
        Write-Host "Unable to access data"
    }
    
    Try{
        # Import to DB
        Import-CSV "c:\Users\sran\Documents\testData\usageData-${subId}-${date}.csv" |
        ForEach-Object{
            Invoke-Sqlcmd `
                -Database $database -ServerInstance $server `
                -Query "INSERT INTO $table VALUES ('$($_.ConsumedService)','$($_.Currency)','$($_.InstanceId)','$($_.InstanceName)'
                ,'$($_.MeterCategory)','$($_.MeterLocation)','$($_.MeterName)','$($_.MeterSubCategory)','$($_.Unit)','$($_.MeterId)'
                ,'$($_.Name)','$($_.PretaxCost)','$($_.SubscriptionGuid)','$($_.SubscriptionName)','$($_.UsageStart)','$($_.UsageEnd)','$($_.UsageQuantity)')"
        }
        #Remove-Item "c:\Users\sran\Documents\testData\usageData-${subId}-${date}.csv"
    }
    Catch{
        Write-Host "Data Not Found"
    }
    
}