<#
    .Synopsis
    Script to parse the latest NVD dataset

    .Description
    This file will parse a json file and return the results as a CSV file

    .Example
    & '.\week 15.ps1' -year "2020" -keyword "java" -filename "nvd-data.csv"

    .Example
    & '.\week 15.ps1' -y "2020" -k "java" -f "nvd-data.csv"

    .Notes
    Created by Duane Dunston. Written by Gabe Quinto. 12/13/2021
#>

 param (
    [Alias("y")]
    [Parameter(Mandatory=$true)]
    [int]$year,

    [Alias("k")]
    [Parameter(Mandatory=$true)]
    [string]$keyword,

    [Alias("f")]
    [Parameter(Mandatory=$true)]
    [string]$filename
 )

cls

$nvd_vulns = (Get-Content -Raw -Path ".\nvdcve-1.1-$year.json" | `
ConvertFrom-Json) | select CVE_Items

#CSV File

#$filename = "nvd-data.csv"

#Headers for the csv file
Set-Content -Value "`"PublishDate`",`"Description`",`"Impact`",`"CVE`"" $filename

# Array to store data

$theV = @()

foreach ($vuln in $nvd_vulns.CVE_Items) {

    #vuln Description
    $descript = $vuln.cve.description.description_data
    
    #$keyword = "java"
    # Search for the keywork
     if ($descript -imatch "$keyword") {
    
    # Publish date
    $pubDate = $vuln.publishedDate

    # Description
    $z = $descript | select Value
    $description = $z.value

    #Impact
    $y = $vuln.impact
    $impact = $y.baseMetricV2.severity

    # CVE number
    $cve = $vuln.cve.CVE_data_meta.ID
    
    # Format the CSV file
    $theV += "`"$pubDate`",`"$description`",`"$impact`",`"$cve`"`n"
    
     }
    
    
}
 
"$theV" | Add-Content -Path $filename  
