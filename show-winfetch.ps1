function show-winfetch
{
    param (
        [string]$logoOverride
    )
    clear-host
    Write-Host
    Write-Host
    $username = $env:USERNAME
    $hostname = $env:COMPUTERNAME
    $os = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty Caption
    $build = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\' | Select-Object -ExpandProperty DisplayVersion
    $version = (Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty Version).split('.')[-1]
    $uptime = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty LastBootUpTime | ForEach-Object { [Management.ManagementDateTimeConverter]::ToDateTime($_) }
    $uptime = New-TimeSpan -Start $uptime -End (Get-Date) | Select-Object -Property Days, Hours, Minutes, Seconds
    $uptime = "$( $uptime.Days ) days, $( $uptime.Hours ) hours, $( $uptime.Minutes ) minutes, $( $uptime.Seconds ) seconds"
    $terminal = (Get-Host).UI.RawUI.WindowTitle
    $resolution = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Size
    $videoController = Get-WmiObject -Class Win32_VideoController
    $refreshRate = [math]::Round([Int16]::Parse($videoController[-1].CurrentRefreshRate) / 5) * 5
    $GPU = $videoController[-1].Name
    $CPU = Get-WmiObject -Class Win32_Processor | Select-Object -ExpandProperty Name
    $RAM = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum | Select-Object -ExpandProperty Sum
    $RAM = [math]::Round($RAM / 1MB, 2)
    $FREE_RAM = Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty FreePhysicalMemory
    $FREE_RAM = [math]::Round($FREE_RAM / 1KB, 2)
    $USED_RAM = $RAM - $FREE_RAM
    $Disk = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq 'C:' } | Select-Object -ExpandProperty Size
    $Disk = [math]::Round($Disk / 1GB, 2)
    $FREE_Disk = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq 'C:' } | Select-Object -ExpandProperty FreeSpace
    $FREE_Disk = [math]::Round($FREE_Disk / 1GB, 2)
    $resolution = "$( $resolution.Width )x$( $resolution.Height ) @$( $refreshRate )Hz"


    if ($os -match "Windows 11")
    {
        $logo = $Global:OSLogos.windows11
    }
    elseif ($os -match "Windows 10")
    {
        $logo = $Global:OSLogos.windows10
    }
    else
    {
        $logo = $Global:OSLogos.windows
    }
    if ($logoOverride)
    {
        $logo = $Global:OSLogos.$logoOverride
    }

    $labels = @(
        "",
        "",
        "OS: ",
        "Build: ",
        "Uptime: ",
        "Resolution: ",
        "Terminal: ",
        "CPU: ",
        "GPU: ",
        "Memory: ",
        "Disk: "
    )

    $values = @(
        "$username@$hostname",
        "-------------------",
        "$os",
        "$build ($version)",
        "$uptime",
        "$resolution",
        "$terminal",
        "$CPU",
        "$GPU",
        "$USED_RAM MB / $RAM MB ($([math]::Round($USED_RAM / $RAM * 100) )%)",
        "C:\ $DISK GB ($FREE_DISK GB free)"
    )

    $lines = $logo -split "`n"
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $lineContent = $lines[$i].padright(45, " ")
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 6, $Host.UI.RawUI.CursorPosition.Y
        if ($i -eq 0)
        {
            Write-Host "$lineContent " -ForegroundColor Blue -NoNewline
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 53, $Host.UI.RawUI.CursorPosition.Y
            Write-Host "$username" -ForegroundColor Blue -NoNewline
            Write-Host "@" -ForegroundColor White -NoNewline
            Write-Host "$hostname" -ForegroundColor Blue
        }
        elseif ($i -lt $labels.Count)
        {
            Write-Host "$lineContent " -ForegroundColor Blue -NoNewline
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 53, $Host.UI.RawUI.CursorPosition.Y
            Write-Host "$($labels[$i])" -ForegroundColor Blue -NoNewline
            Write-Host "$( $values[$i] )" -ForegroundColor White
        }
        elseif ($i -eq $labels.Count + 1)
        {
            Write-Host "$lineContent " -ForegroundColor Blue -NoNewline
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 53, $Host.UI.RawUI.CursorPosition.Y
            Write-Host "Mem%  " -ForegroundColor Blue -NoNewline
            Write-Host "-=[ " -ForegroundColor White -NoNewline
            Write-Host "".PadRight(20 - [math]::Round($FREE_RAM / $RAM * 20), "/") -ForegroundColor Red -NoNewline
            Write-Host "".PadRight([math]::Round($FREE_RAM / $RAM * 20), "/") -ForegroundColor White -NoNewline
            Write-Host " ]=-" -ForegroundColor White
        }
        elseif ($i -eq $labels.Count + 3)
        {
            Write-Host "$lineContent " -ForegroundColor Blue -NoNewline
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 53, $Host.UI.RawUI.CursorPosition.Y
            Write-Host "Disk% " -ForegroundColor Blue -NoNewline
            Write-Host "-=[ " -ForegroundColor White -NoNewline
            Write-Host "".PadRight(20 - [math]::Round($FREE_DISK / $DISK * 20), "/") -ForegroundColor Red -NoNewline
            Write-Host "".PadRight([math]::Round($FREE_DISK / $DISK * 20), "/") -ForegroundColor White -NoNewline
            Write-Host " ]=-" -ForegroundColor White
        }
        elseif ($i -eq $labels.Count + 5)
        {
            Write-Host "$lineContent " -ForegroundColor Blue -NoNewline
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 53, $Host.UI.RawUI.CursorPosition.Y
            Write-Host "    " -BackgroundColor Black -NoNewline
            Write-Host "    " -BackgroundColor Blue -NoNewline
            Write-Host "    " -BackgroundColor Green -NoNewline
            Write-Host "    " -BackgroundColor Cyan -NoNewline
            Write-Host "    " -BackgroundColor Red -NoNewline
            Write-Host "    " -BackgroundColor Magenta -NoNewline
            Write-Host "    " -BackgroundColor Yellow -NoNewline
            Write-Host "    " -BackgroundColor White -NoNewline
            Write-Host "" -BackgroundColor Black
        }
        elseif ($i -eq $labels.Count + 6)
        {
            Write-Host "$lineContent " -ForegroundColor Blue -NoNewline
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 53, $Host.UI.RawUI.CursorPosition.Y
            Write-Host "    " -BackgroundColor DarkGray -NoNewline
            Write-Host "    " -BackgroundColor Blue -NoNewline
            Write-Host "    " -BackgroundColor Green -NoNewline
            Write-Host "    " -BackgroundColor Cyan -NoNewline
            Write-Host "    " -BackgroundColor Red -NoNewline
            Write-Host "    " -BackgroundColor Magenta -NoNewline
            Write-Host "    " -BackgroundColor Yellow -NoNewline
            Write-Host "    " -BackgroundColor Gray -NoNewline
            Write-Host "" -BackgroundColor Black
        }
        else
        {
            Write-Host "$lineContent" -ForegroundColor Blue
        }
    }
    Write-Host
    Write-Host
}



$Global:OSLogos = [PSCustomObject]@{
    windows11 = @"
WWWWWWWWWWWWWWWWWW   WWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWW   WWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWW   WWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWW   WWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWW   WWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWW   WWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWW   WWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWW   WWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWW   WWWWWWWWWWWWWWWWWW

WWWWWWWWWWWWWWWWWW   WWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWW   WWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWW   WWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWW   WWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWW   WWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWW   WWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWW   WWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWW   WWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWW   WWWWWWWWWWWWWWWWWW
"@
    windows10 = @"
                                ..,
                      ....,,:;+ccWWWW
        ...,,+:;  cWWWWWWWWWWWWWWWWWW
  ,ccWWWWWWWWWWW  WWWWWWWWWWWWWWWWWWW
  WWWWWWWWWWWWWW  WWWWWWWWWWWWWWWWWWW
  WWWWWWWWWWWWWW  WWWWWWWWWWWWWWWWWWW
  WWWWWWWWWWWWWW  WWWWWWWWWWWWWWWWWWW
  WWWWWWWWWWWWWW  WWWWWWWWWWWWWWWWWWW
  WWWWWWWWWWWWWW  WWWWWWWWWWWWWWWWWWW

  WWWWWWWWWWWWWW  WWWWWWWWWWWWWWWWWWW
  WWWWWWWWWWWWWW  WWWWWWWWWWWWWWWWWWW
  WWWWWWWWWWWWWW  WWWWWWWWWWWWWWWWWWW
  WWWWWWWWWWWWWW  WWWWWWWWWWWWWWWWWWW
  WWWWWWWWWWWWWW  WWWWWWWWWWWWWWWWWWW
  ''ccWWWWWWWWWW  WWWWWWWWWWWWWWWWWWW
         ''\\*::  :ccWWWWWWWWWWWWWWWW
                         ''''''*::cWW
                                   ''
"@
    windows = @"
            .,;+##+;,
         :tt:::tt333EE3
         Et:::ztt33EEEL      @Ee.,      ..,
        ;tt:::tt333EE7      ;EEEEEEttttt33#
       :Et:::zt333EEQ.      @EEEEEttttt33QL
       it::::tt333EEF      @EEEEEEttttt33F
      ;3=*^'''"*4EEV      :EEEEEEttttt33@.
      ,.=::::!t=.,        @EEEEEEtttz33QF
     ;::::::::zt33)        "4EEEtttji3P*
    :t::::::::tt33.     :Z3z..  '' ,..g.
    i::::::::zt33F      AEEEtttt::::ztF
   ;:::::::::t33V      ;EEEttttt::::t3
   E::::::::zt33L      @EEEtttt::::z3F
  (3=*^'''"*4E3)      ;EEEtttt:::::tZ'
                      :EEEEtttt::::z7
                       "VEzjt:;;z>*^'





"@

}
