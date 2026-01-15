function Felix_Home {
@"
  _____       _    0  _    _ 
 |  ___| ___ | |   _ \ \  / /
 |  __|/ __ \| |  | | \ \/ /
 | |  |  ___/| |__| | / /\ \   < v2.0 >--< 2025 >
 |_|   \____/|____|_|/_/  \_\  https://github.com/FireLies/Felix
 
 Destroy file(s) for maximum 'unrecoverability'

 <> Usage: Felix -e [Extensions] -p [Path] -n [iteration (default is 3)] -r [recurse]
 <> Use ',' separator for multiple extensions
 <> Use '*' to assign all extensions that exist in the selected path

"@
}

function Felix {
    param (
        [Parameter(Mandatory=$true)]
        [Alias('e')][string[]]$Extensions,

        [Parameter(Mandatory=$true)]
        [Alias('p')][string]$Path,

        [Alias('n')][int]$Passes = 3,

        [Alias('r')][switch]$RecurseAction
    )

    # User input checking segment
    #============================================================================================================
    ""
    # Check if user assigned all extension '*'
    # If yes, then skip extension checking and continue
    if ($Extensions -notcontains "*") {
        foreach ($file in $Extensions) {
            if ((Get-ChildItem -Path $Path -Filter "*$file" -File -Recurse).Count -eq 0) {
                Write-Host "[!] No $file found, removing it from process"
                [string[]]$Extensions = $Extensions | Where-Object {$_ -ne $file}
            }
        }

        if ($Extensions.Count -eq 0) {
            Write-Host "[!] All assigned extensions has been removed, unable proceed further`n"
            return
        } else {
            Write-Host "[+] $($Extensions -join ', ') found"
        }

    } else {
        Write-Host "[+] All extensions are assigned"
    }

    $filteredExtensions = $Extensions | ForEach-Object {
        if ($_ -like '.*') {"*$_"} else {"*.$_"}
    } | ForEach-Object {$_.ToLower()}

    $itemParameters = @{Path = $Path; File = $true}
    $searchSubDir = (Get-ChildItem -Path $Path -Recurse -Directory).Count

     # Check for recurse mode
    if ($RecurseAction) {
        $itemParameters.Recurse = $true
        Write-Host "[+] Recurse mode initiated`n |--[+] Found $searchSubDir sub directories"
    } else {
        $itemParameters.Path = (Join-Path $Path '*')
    }

    #============================================================================================================

    [string[]]$itemList = Get-ChildItem @itemParameters -Include $filteredExtensions -Name

    Write-Host "[+] $($itemList.Count) file(s) will be proccessed"

    $searchSubItems = Get-ChildItem -Path $Path -File -Recurse -Include $filteredExtensions | Where-Object {
        $_.DirectoryName -ne $Path
    }

    if ($searchSubItems.Count -gt 0 -and !$RecurseAction) {
        Write-Host " |--[+] Found $($searchSubItems.Count) file(s) within $searchSubDir sub directories"
        Write-Host " |--[!] Recurse mode not initiated, $($searchSubItems.Count) file(s) will not be processed"
    }

    switch ($(Read-Host "[?] All checks completed and ready to process. Continue y/n?")) {
        "y" {continue}
        "n" {Write-Host "[+] Proccess is canceled`n"; return}
        Default {Write-Host "[!] Invalid input, only accept y or n`n"; return}
    }

    $success, $failed = 0, 0
    $failedItems = [System.Collections.Generic.List[string]]::new()

    for ($i = 0; $i -lt $Passes; $i++) {
        $progressCounter = 0

        foreach ($item in $itemList) {
            $progressCounter++
            $progressPercent = ($progressCounter / $itemList.Count) * 100
            Write-Host "`r[o] Iteration $($i + 1)/$Passes $("{0:F1}" -f $progressPercent)%  " -NoNewline

            try {

                $fileStream = [System.IO.File]::Open(("$Path\$item"), 'Open', 'Write')
                
                [void]$fileStream.Seek(0, 'Begin')
                $bytesRemaining = $item.Length

                $buffer = New-Object byte[] 4096
                $randomize = [System.Security.Cryptography.RandomNumberGenerator]::Create()
                $randomize.GetBytes($buffer)
                $randomize.Dispose()

                $fileStream.Write($buffer, 0, ([Math]::Min($bytesRemaining, $buffer.Length)))
                $fileStream.Close()

            } catch {
                $failed++
                $failedItems.Add("     | iter $($i + 1) -- $Path\$item")

            } finally {
                if ($fileStream) {
                    $fileStream.Close()
                }
            }

            $success++
        }
    }
    
    Write-Host "`n[+] Overwrite completed`n[=] Overwritten $(($success / $Passes) - $failed) / Failed $failed"

    if ($failedItems.Count -gt 0) {
        Write-Host " |--[!] Failed to overwrite the following item(s)`n$($failedItems.ToArray() -join "`n")"
    }
    ""
}

Felix_Home