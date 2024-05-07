function Write-UsedBar
{
    param (
        [int]$free,
        [int]$total,
        [String]$lable,
        [String]$color
    )
    Write-Host "$lable% ".PadRight(6) -ForegroundColor $color -NoNewline
    Write-Host "-=[ " -ForegroundColor White -NoNewline
    Write-Host "".PadRight(20 - [math]::Round($free / $total * 20), "/") -ForegroundColor Red -NoNewline
    Write-Host "".PadRight([math]::Round($free / $total * 20), "/") -ForegroundColor White -NoNewline
    Write-Host " ]=-" -ForegroundColor White -NoNewline
}

function show-winfetch {
    param (
        [string]$logoOverride
    )
    clear-host
    Write-Host
    Write-Host
    $os = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty Caption
    $build = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\' | Select-Object -ExpandProperty DisplayVersion
    $version = (Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty Version).split('.')[-1]
    $uptimeObject = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty LastBootUpTime | ForEach-Object { [Management.ManagementDateTimeConverter]::ToDateTime($_) }
    $uptime = New-TimeSpan -Start $uptimeObject -End (Get-Date) | Select-Object -Property Days, Hours, Minutes, Seconds
    $uptime = "$( $uptime.Days ) days, $( $uptime.Hours ) hours, $( $uptime.Minutes ) minutes, $( $uptime.Seconds ) seconds"
    $terminal = (Get-Host).UI.RawUI.WindowTitle
    $resolution = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Size
    $videoController = Get-WmiObject -Class Win32_VideoController
    if ($videoController.count -gt 1) {
        $videoController = $videoController[-1]
    }
    $refreshRate = [math]::Round([Int16]::Parse($videoController.CurrentRefreshRate) / 5) * 5
    $GPU = $videoController.Name
    $CPU = Get-WmiObject -Class Win32_Processor | Select-Object -ExpandProperty Name
    $RAM = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum | Select-Object -ExpandProperty Sum
    $RAM = [math]::Round($RAM / 1MB, 2)
    $FREE_RAM = [math]::Round((Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty FreePhysicalMemory) / 1KB, 2)
    $Disk = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq 'C:' } | Select-Object -ExpandProperty Size
    $Disk = [math]::Round($Disk / 1GB, 2)
    $FREE_Disk = [math]::Round((Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq 'C:' } | Select-Object -ExpandProperty FreeSpace) / 1GB, 2)
    $resolution = "$( $resolution.Width )x$( $resolution.Height ) @$( $refreshRate )Hz"

    $Global:OSLogos.GetEnumerator() | ForEach-Object {
        if ( $os.toLower().replace(' ', '').contains($_.Name)) {
            $Global:logoObject = $_.Value
        }
    }

    if (-not $Global:logoObject) {
        return "No logo found for $os"
    }

    if ($logoOverride) {
        $Global:logoObject = $Global:OSLogos.$logoOverride
    }

    $logo = $Global:logoObject.logo

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
        "",
        "-------------------",
        "$os",
        "$build ($version)",
        "$uptime",
        "$resolution",
        "$terminal",
        "$CPU",
        "$GPU",
        "$( $RAM - $FREE_RAM ) MB / $RAM MB ($([math]::Round(($RAM - $FREE_RAM) / $RAM * 100) )%)",
        "C:\ $DISK GB ($FREE_DISK GB free)"
    )

    $lines = $logo -split "`n"
    Clear-Host
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $lineContent = $lines[$i]
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 6, $Host.UI.RawUI.CursorPosition.Y
        Write-Host "$lineContent" -ForegroundColor $logoObject.color -NoNewline
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 53, $Host.UI.RawUI.CursorPosition.Y
        if ($i -eq 0) {
            Write-Host "$env:USERNAME" -ForegroundColor $logoObject.color -NoNewline
            Write-Host "@" -ForegroundColor White -NoNewline
            Write-Host "$env:COMPUTERNAME" -ForegroundColor $logoObject.color -NoNewline
        }
        elseif ($i -lt $labels.Count) {
            Write-Host "$( $labels[$i] )" -ForegroundColor $logoObject.color -NoNewline
            Write-Host "$( $values[$i] )" -ForegroundColor White -NoNewline
        }
        elseif ($i -eq $labels.Count + 1) {
            Write-UsedBar -free $FREE_RAM -total $RAM -lable "Mem" -color $logoObject.color
        }
        elseif ($i -eq $labels.Count + 3) {
            Write-UsedBar -free $FREE_DISK -total $DISK -lable "Disk" -color $logoObject.color
        }
        elseif ($i -eq $labels.Count + 5 -or $i -eq $labels.Count + 6) {
            if ($i % 2) {
                $color = "DarkGray"
                $color2 = "Gray"
            }
            else {
                $color = "Black"
                $color2 = "White"
            }
            @( $color, "Blue", "Green", "Cyan", "Red", "Magenta", "Yellow", $color2  ) | ForEach-Object {
                Write-Host "    " -BackgroundColor $_ -NoNewline
            }
        }
        Write-Host "" -BackgroundColor Black -ForegroundColor White
    }
    Write-Host
    Write-Host
}



$Global:OSLogos = @{
    windows11 = @{
        logo = @"
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
        color = "Blue"
    }
    windows10 = @{
        logo = @"
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
        color = "Blue"
    }
    windows7 = @{
        logo = @"
            .,;+##+;,
         :tt:::tt333EE3
         Et:::ztt33EEEL  @Ee.,      ..,
        ;tt:::tt333EE7  ;EEEEEEttttt33#
       :Et:::zt333EEQ.  @EEEEEttttt33QL
       it::::tt333EEF  @EEEEEEttttt33F
      ;3=*^'''"*4EEV  :EEEEEEttttt33@.
      ,.=::::!t=.,    @EEEEEEtttz33QF
     ;::::::::zt33)    "4EEEtttji3P*
    :t::::::::tt33. :Z3z..  '' ,..g.
    i::::::::zt33F  AEEEtttt::::ztF
   ;:::::::::t33V  ;EEEttttt::::t3
   E::::::::zt33L  @EEEtttt::::z3F
  (3=*^'''"*4E3)  ;EEEtttt:::::tZ'
                  :EEEEtttt::::z7
                   "VEzjt:;;z>*^'




"@
        color = "Blue"
    }

}
