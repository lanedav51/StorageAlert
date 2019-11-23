$TxtPath = "Insert csv Location"
$File = Import-Csv $TxtPath
$Computers = $File.Computers
$i=0
foreach($Computer in $Computers)
{
    Enter-PSSession -ComputerName $Computer
    $MaxHD = get-CimInstance -Classname Win32_LogicalDisk | where-Object{$_.DeviceID -eq "C:"} | select-object -Property Size | ForEach-Object {"{0:N2}" -f ($_.Size / 1GB)}
    $UsedHD = get-CimInstance -Classname Win32_LogicalDisk | where-Object{$_.DeviceID -eq "C:"} | select-object -Property FreeSpace | ForEach-Object {"{0:N2}" -f ($_.FreeSpace / 1GB)}
    $OpSys = (get-CimInstance Win32_OperatingSystem).name
    $obj = new-object psobject -Property @{
        Computer_Name = $Computer
        Operating_System = $OpSys
        Total_Disk = $MaxHD
        Disk_Free = $UsedHD
    }
    if($UsedHD -lt 10 -AND $i -eq 0)
    {
        $obj | Export-Csv -Path "StorageLow_$(get-date -f yyyy-MM-dd).csv"
        $i=1
    }
    elseif ($UsedHD -lt 10 -AND $i -eq 1)
    {
        $obj | Export-Csv -Path "StorageLow_$(get-date -f yyyy-MM-dd).csv" -Append
    }
    Exit-PSSession
}

$options = @{
    'SmtpServer' = "SMTP"
    'To' = "example@email.com"
    'From' = "from@email.com"
    'Subject' = "Free Disk Space Alert"
    'Body' = "The attached spreadsheet contains all scanned systems that have fallen below 10 Gb of free disk space."
    'Attachments' = "StorageLow_$(get-date -f yyyy-MM-dd).csv"
}

Send-MailMessage @options