#https://learn.microsoft.com/en-us/mem/intune/protect/compliance-custom-json
$ToCheck=@"
{
"Rules":[ 
    { 
       "SettingName":"FreeSpacePercent",
       "Operator":"LessThan",
       "DataType":"Int64",
       "Operand":"50",
       "MoreInfoUrl":"https://abc.com",
       "RemediationStrings":[ 
          { 
             "Language":"en_US",
             "Title":"Diskspace on C is low. {ActualValue} percent free space.",
             "Description": "Something is wrong there"
          }
       ]
    }
 ]
}
"@

#https://learn.microsoft.com/en-us/mem/intune/protect/compliance-custom-script
$Volume=Get-Volume -DriveLetter C

$RetVal=@{
    SizeGB=[math]::Floor($Volume.Size/1GB)
    FreeSpaceGB=[math]::Floor($Volume.SizeRemaining/1GB)
    FreeSpacePercent=[int64]::Parse([math]::Floor($Volume.SizeRemaining/$Volume.Size*100))
}

return $RetVal | ConvertTo-Json -Compress
