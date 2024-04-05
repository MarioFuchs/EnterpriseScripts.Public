Function Delete-TeamsCache
{
Param(
[string]$Path
)
Write-Host "Deleting $Path"
$Files=Get-ChildItem -Path $Path -Recurse 
$Result=$Files | Remove-Item -Force -Recurse
return "OK "+$Files.Count + "-"+$Result.Count
}

Function Get-DirSize
{
Param(
[string]$Path
)
Write-Host "Enumerating $Path"
$Size=(Get-ChildItem -Path $Path -Recurse | Measure-Object -Property Length -Sum).Sum
return $("{0:N2} MB" -f ($Size/1MB))
}
Function Update-SizeDisplay()
{
$lbl5.Text=(Get-DirSize -Path $CacheDir1)
$lbl6.Text=(Get-DirSize -Path $CacheDir2)
}

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$CacheDir1=$env:APPDATA+"\Microsoft\Teams\Cache"
$CacheDir2=$env:LOCALAPPDATA+"\Packages\MSTeams_8wekyb3d8bbwe\LocalCache"

#region Forms Definition
$Form=New-Object System.Windows.Forms.Form

$Form.Text="Teams Client Cache Deletion Tool"
$Form.Width=850
$Form.Height=350
$Form.StartPosition=[System.Windows.Forms.FormStartPosition]::CenterScreen
$Form.FormBorderStyle=[System.Windows.Forms.FormBorderStyle]::FixedDialog

$StatusBar=New-Object System.Windows.Forms.StatusBar
[void]$StatusBar.Panels.Add("Bereit")
$Form.Controls.Add($StatusBar)

$lbl1=New-Object System.Windows.Forms.Label; $lbl1.Text="Classic Teams Client Cache Folder"; $lbl1.Top=10; $lbl1.Left=10; $lbl1.Width=500; $Form.Controls.Add($lbl1)
$lbl2=New-Object System.Windows.Forms.Label; $lbl2.Text="New Teams Client Cache Folder"; $lbl2.Top=70; $lbl2.Left=10; $lbl2.Width=500; $Form.Controls.Add($lbl2)

$lbl3=New-Object System.Windows.Forms.Label; $lbl3.Text=$CacheDir1; $lbl3.Top=40; $lbl3.Left=10; $lbl3.Width=700; $Form.Controls.Add($lbl3)
$lbl4=New-Object System.Windows.Forms.Label; $lbl4.Text=$CacheDir2; $lbl4.Top=100; $lbl4.Left=10; $lbl4.Width=700; $Form.Controls.Add($lbl4)

$InfoFont=[System.Drawing.Font]::new("MS Sans Serif",8,[System.Drawing.FontStyle]::Bold)
$lbl3.Font=$InfoFont; $lbl3.ForeColor="Blue"
$lbl4.Font=$InfoFont; $lbl4.ForeColor="Blue"

$lbl5=New-Object System.Windows.Forms.Label; $lbl5.Text=(Get-DirSize -Path $CacheDir1); $lbl5.Top=40; $lbl5.Left=710; $lbl5.Width=120; $Form.Controls.Add($lbl5)
$lbl6=New-Object System.Windows.Forms.Label; $lbl6.Text=(Get-DirSize -Path $CacheDir2); $lbl6.Top=100; $lbl6.Left=710; $lbl6.Width=120; $Form.Controls.Add($lbl6)
$lbl5.TextAlign=[System.Drawing.ContentAlignment]::TopRight
$lbl6.TextAlign=[System.Drawing.ContentAlignment]::TopRight

$lbl7=New-Object System.Windows.Forms.Label; $lbl7.Text="Warning: All teams processes and the outlook application will be terminated."; $lbl7.Top=225; $lbl7.Left=10; $lbl7.Width=700; $lbl7.ForeColor="Red"; $Form.Controls.Add($lbl7)

$btn1=New-Object System.Windows.Forms.Button; $btn1.Text="Delete Cache Directories"; $btn1.Top=180; $btn1.Left=10; $btn1.Width=820; $btn1.Height=40
$btn1.Add_Click({ 
    Get-Process ms-teams | Stop-Process -Force
    Get-Process outlook | Stop-Process -Force
    Get-Process Teams | Stop-Process -Force
    $Result1=Delete-TeamsCache -Path $CacheDir1
    $Result2=Delete-TeamsCache -Path $CacheDir2
    [System.Windows.Forms.MessageBox]::Show("Classic Teams: "+$Result1+"`n"+"New Teams: "+$Result2,"Deleted Teams Cache Directories")
    Update-SizeDisplay
    $Timer1.Start()
})

$Form.Controls.Add($btn1)

$Timer1=New-Object System.Windows.Forms.Timer
$Timer1.Interval=5000
$Timer1.Add_Tick({
    Update-SizeDisplay
})
#endregion

$Timer1.Enabled=$true
Update-SizeDisplay

$Result=$Form.ShowDialog()
$Timer1.Stop()
$Timer1.Dispose()