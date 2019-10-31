$TxtPath = "C:\Users\administrator.AMERINETCENTRAL\Desktop\Computers.csv"
$File = Import-Csv $TxtPath
$Computers = $File.Computers

foreach($Computer in $Computers)
{
    $MaxHD = get-CimInstance -Classname Win32_LogicalDisk -ComputerName $Computer | where-Object{$_.DeviceID -eq "C:"} | select-object -Property Size | ForEach-Object {"{0:N2}" -f ($_.Size / 1GB)}
    $UsedHD = get-CimInstance -Classname Win32_LogicalDisk -ComputerName $Computer  | where-Object{$_.DeviceID -eq "C:"} | select-object -Property FreeSpace | ForEach-Object {"{0:N2}" -f ($_.FreeSpace / 1GB)}
    $OpSys = (get-CimInstance Win32_OperatingSystem).name
    $i = 0
    $obj = new-object psobject -Property @{
        ComputerName = $Computer
        MaxDisk = $MaxHD
        FreeDisk = $UsedHD
        OperatingSystem = $OpSys
    }
    if($UsedHD -lt 75 -AND $i -eq 0)
    {
        $obj | Export-Csv -Path "StorageAlertTest.csv"
        $i++
    }
    elseif ($UsedHD -lt 75 -AND $i -ge 1) 
    {
        $obj | Export-Csv -Path "StorageAlertTest.csv" -Append
        $i++
    }
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