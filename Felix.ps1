$ErrorActionPreference = 'SilentlyContinue'

@"
`nHello Felix! -| v1.7 |- FireLies 2022 -> https://github.com/FireLies/Felix
`nUsage: felix [-Extension] [-Path]`n
"@

function Felix {

    [CmdletBinding()]
    Param (

        [Parameter(Mandatory=$true)]
        [ValidateScript({

            if (($_ -notin ([string[]]$ValidExtensions = Get-Content $PWD\ValidExtensions.txt)) -or (!($_))) {
                Write-Host "
                `rPlease assign the extension parameter correctly `nValid extensions: $($ValidExtensions -join ', ')
                `nTIPS: --Use felix * to select all extensions
                `r      --Use (,) to assign more than 1`n"
                $false
                break
            }

            $true
        })]
        [string[]]$Extension,

        [Parameter(Mandatory=$false)]
        [string]$Path = "C:\Users\"+[Environment]::UserName+"\Documents"
    )

    
    process {

        if (!(Test-Path "$Path")) {
            Write-Host "$Path does not exist. Please check the name correctly`n"
            break
        }

        Write-Host "`nThe following process will be done recursively. You're on your own"
        cmd /c Pause; ""

        foreach ($Value in $Extension) {
            Write-Host "--Trying: $Value in $Path\..."

            foreach ($File in ([string[]]$GetName = Get-ChildItem "$Path\" -Recurse -Filter *$Value -Name)) {
                Out-Null | Out-File "$Path\$File" -Force

                switch ([int[]](Get-Item "$Path\$File" | ForEach-Object {[int]($_.length /1kb)})) {
                    0 {Write-Host "o $Path\$File"; $Success++}
                    default {Write-Host "- $Path\$File"; $Failed++}
                }
            }
            
            if ($GetName.length -eq 0) {
                Write-Host "--Cannot find $Value file(s)"
            }; ""
        }

        Write-Host "  Success: $Success  //  Failed: $Failed`n"
    }
}