$regionName = "eastus"
$tags = Get-AzNetworkServiceTag -Location $regionName

$output= @()
foreach ($tag in $tags.Values) {

    $ipAddressPrefixes = ""
    $b = $($tag.Properties.AddressPrefixes) -split " "
    $ipAddressPrefixes = $b -join ","

    $result = New-Object -TypeName PSObject -Property @{
        ServiceTag = $tag.Name
        ServiceTagValues = $ipAddressPrefixes
        ServiceTagChangeNumber = $tag.Properties.ChangeNumber
    }
    $output += $result
}

#$output | select ServiceTag, ServiceTagChangeNumber, ServiceTagValues | ogv
$output | select ServiceTag, ServiceTagChangeNumber, ServiceTagValues | export-csv -NoTypeInformation "tags.csv"
