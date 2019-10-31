$TxtPath = "C:\Users\administrator.AMERINETCENTRAL\Desktop\Computers.csv"
$File = Import-Csv $TxtPath
$Computers = $File.Computers

foreach($Computer in $Computers)
{
    Enter-PSSession -ComputerName $Computer
    $Drive = Get-PSDrive C
    $FreeHD = $Drive.used
    $FreeHD = $FreeHD/1GB
    $i = 0
    $obj = new-object psobject -Property @{
        ComputerName = $Computer
        FreeDisk = $FreeHD
    }
    if($FreeHD -lt 75 -AND $i -eq 0)
    {
        $obj | Export-Csv -Path "StorageAlertTest.csv"
        $i++
    }
    elseif ($FreeHD -lt 75 -AND $i -ge 1) 
    {
        $obj | Export-Csv -Path "StorageAlertTest.csv" -Append
        $i++
    }
    Exit-PSSession
}

$options = @{
    'SmtpServer' = "intrelay.amerinetcentral.org"
    'To' = "matt.ward@intalere.com"
    'From' = "DiskAlertMgmr@intalere.com"
    'Subject' = "Free Disk Space Alert"
    'Body' = "The attached spreadsheet contains all scanned systems that have fallen below 75 Gb of free disk space."
    'Attachments' = "StorageAlertTest.csv"
}

Send-MailMessage @options