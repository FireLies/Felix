<#
Author      : Johannes Titor
Version     : 2.2.1
Last update : 16 Oct 2026
PowerShell  : 5.1
#>

function Home {
Write-Host @"
                _   _
  ______     _   \./      
 |  ___/___ | \   _ /\  /\
 |  __/ __ \| |  | |\ \/ /
 | | |  ___/| |__| |/ /\ \  < v2.2.1 >--< 16 Oct 2026 >
 |_/  \____/|____/_|\/  \/  https://github.com/FireLies/Felix
 
"@ -ForegroundColor Cyan

Write-Host @" 
 PowerShell: $($PSVersionTable.PSVersion.ToString(2)) | User env: C:\Users\$([Environment]::UserName)`n
"@ -ForegroundColor DarkCyan

@"
 Wipe file(s) by overwriting them using random bytes

 <> Usage: Felix [-e Extensions] [-p Path] [-n iteration (default is 1)] [-r recurse]
 <> Use ',' separator for multiple extensions
 <> Use '*' to assign all extensions that exist in the selected path
 <> Use home to show this menu

"@
}

function Felix {
    param (
        [Parameter(Mandatory=$true)]
        [Alias('e')][string[]]$extensions,

        [Parameter(Mandatory=$true)]
        [Alias('p')][string]$path,

        [Alias('n')][int]$iterations = 1,

        [Alias('r')][switch]$recurseAction
    )

    # User input checking segment
    #============================================================================================================
    ""
    if ($extensions -notcontains "*") {
        foreach ($file in $extensions) {
            if ((Get-ChildItem -Path $path -Filter "*$file" -File -Recurse).Count -eq 0) {
                Write-Host "[!] No $file found, removing it from process"
                [string[]]$extensions = $extensions | Where-Object {$_ -ne $file}
            }
        }

        if ($extensions.Count -eq 0) {
            Write-Host "[!] All assigned extensions has been removed, unable to proceed further`n"
            return
        } else {
            Write-Host "[+] $($extensions -join ', ') found"
        }

    } else {
        Write-Host "[+] All extensions are assigned"
    }
    #------------------------------------------------------------------------------------------------------------
    $filteredExtensions = $extensions | ForEach-Object {
        if ($_ -like '.*') {"*$_"} else {"*.$_"}
    } | ForEach-Object {$_.ToLower()}
    #------------------------------------------------------------------------------------------------------------
    if ($iterations -le 0 ) {
        $iterations = 1
        Write-Host "[!] Iteration must be an int and cannot be <= 0. It'll be set to default"
    }
    #------------------------------------------------------------------------------------------------------------
    $itemParameters = @{Path = $path; File = $true}
    $searchSubDir = (Get-ChildItem -Path $path -Recurse -Directory).Count

    if ($recurseAction) {
        $itemParameters.Recurse = $true
        Write-Host "[+] Recurse mode initiated`n |--[+] Found $searchSubDir sub directories"
    } else {
        $itemParameters.Path = (Join-Path $path '*')
    }

    [string[]]$itemList = Get-ChildItem @itemParameters -Include $filteredExtensions -Name

    Write-Host "[+] $($itemList.Count) file(s) will be proccessed"

    $searchSubItems = Get-ChildItem -Path $path -File -Recurse -Include $filteredExtensions | Where-Object {
        $_.DirectoryName -ne $path
    }

    if ($searchSubItems.Count -gt 0 -and !$recurseAction) {
        Write-Host " |--[+] Found $($searchSubItems.Count) file(s) within $searchSubDir sub directories"
        Write-Host " |--[!] Recurse mode not initiated, $($searchSubItems.Count) file(s) will not be processed"

    } 
    
    if ($itemList.Count -le 0) {
        Write-Host "[!] Unable to proccess $($itemList.Count) file`n"
        return
    } 

    switch ($(Read-Host "[?] All checks completed and ready to process. Continue y/n?")) {
        "y" {continue}
        "n" {Write-Host "[+] Proccess is canceled`n"; return}
        Default {Write-Host "[!] Invalid input, only accept y or n`n"; return}
    }
    #============================================================================================================
    # End of user input check

    $timeToFinish = [System.Diagnostics.Stopwatch]::StartNew()
    $processList = [System.Collections.Generic.List[string]]::new($itemList)
    $failedItems = [System.Collections.Generic.List[string]]::new()
    $failed, $success= 0, 0

    $logDirPath = $PWD.Path + "\Log"
    if (-not (Test-Path $logDirPath)) {
        [void](New-Item $logDirPath -ItemType "Directory")
    }
    
    $logDateTime = (Get-Date -Format "ddMMyy-HHmm-ss")
    $failedLogPath = $($PWD.Path + "\Log") + "\FailedLog-$($logDateTime).txt"
    [void](New-item -Path $failedLogPath -ItemType "File")

    Write-Host "[+] Begin at $(Get-Date -Format "HH:mm:ss tt")"

    for ($iter = 0; $iter -lt $iterations; $iter++) {
        $progressCounter = 0
        $removeFromProcess = [System.Collections.Generic.List[string]]::new()

        foreach ($item in $processList) {
            $progressCounter++
            $progressPercent = ($progressCounter / $itemList.Count) * 100
            Write-Host "`r[o] Iteration $($iter + 1)/$iterations $("{0:F1}" -f $progressPercent)%  " -NoNewline

            $fileStream = $null
            $filePath = "$path\$item"
            
            if (-not(Test-Path -LiteralPath $filePath)) {
                $failed++
                $failedItems.Add("@iteration $($iter + 1) [MISSING]-> $filePath")
                $removeFromProcess.Add($item)
                continue
            }

            try {
                $buffer = New-Object byte[] 4096
                $randomize = [System.Security.Cryptography.RandomNumberGenerator]::Create()
                $fileStream = [System.IO.File]::Open($filePath, 'Open', 'Write')
                $bytesRemaining = $fileStream.Length

                [void]$fileStream.Seek(0, 'Begin')

                while ($bytesRemaining -gt 0) {
                    $randomize.GetBytes($buffer)
                    $writeSize = [Math]::Min($bytesRemaining, $buffer.Length)
                    $fileStream.Write($buffer, 0, $writeSize)
                    $bytesRemaining -= $writeSize
                }

                $randomize.Dispose()
                
            } catch {
                Write-Host "[$($iter)] Something went wrong during process" -ForegroundColor Red

            } finally {
                if ($fileStream) {
                    $fileStream.Close()

                }
            }
        }

        foreach ($removeItem in $removeFromProcess) {
            [void]$processList.Remove($removeItem)
        }
    }

    Write-Host "`n[+] Success: $($itemList.Count -  $failed) | Failed: $failed " -NoNewline
    Write-Host "| Time elapsed: $([Math]::Round($timeToFinish.Elapsed.TotalSeconds, 2)) sec"

    if ($failedItems.Count -gt 0) {
        Set-Content -Path $failedLogPath -Value $failedItems
        Write-Host " |--[!] Failed item(s) log: ...\Felix\Log\FailedLog-$($logDateTime).txt"
    } else {
        Remove-Item $failedLogPath -Force
    }
    ""
}

Home
