$ErrorActionPreference = 'SilentlyContinue'

function Write-Color {

    param (
        [Parameter()][string]$Text,
        [Parameter(Mandatory=$false)][string]$Color = 'White'
    )

    $TextColor = @{
        Object = $Text;
        ForegroundColor = $Color;
        NoNewline = $true
    }

    Write-Host @TextColor

}

Write-Color "`nHello Felix! -| v1.6 |- FireLies 2022`n" 
Write-Color "`nUsage:" -Color Cyan; Write-Color " felix [-Extension] [-Path]`n`n"
""

function Felix {

    [CmdletBinding()]
    Param (

        [Parameter(Mandatory=$true)]
        [ValidateScript({

            $ExtSet = '.docx', '.doc', '.pdf', '.pptx', '.xlsx', '.xls', '.txt', '.mp4', '.mp3', '.jpg', '.jpeg', '.png', '*'

            if (($_ -notin $ExtSet) -or (!($_))) {
                Write-Color "`nPlease assign the extension parameter correctly `nValid extensions: "; Write-Color "$($ExtSet -join ', ')`n" -Color 'Cyan'
                Write-Color "`nTIPS:" -Color 'Cyan'; Write-Color " --Use felix * to select all extensions `n      --Use separator (,) to assign more than 1`n`n"
                $false; break
            }

            $true

        })]
        [string[]]$Extension,

        [Parameter(Mandatory=$false)]
        [string]$Path = "C:\Users\"+[Environment]::UserName+"\Documents"
    )

    ""
    if (!(Test-Path "$Path")) {
        Write-Color "$Path does not exist. Please check the name correctly`n"
        ""; break
    }

    Write-Color "The following proccess will be done recursively. You're on your own`n" -Color 'Cyan'
    cmd /c Pause

    ""
    foreach ($Value in $Extension) {

        Write-Color "--Trying: $Value" -Color 'Cyan'; Write-Color " in $Path\...`n"
        foreach ($File in ([string[]]$GetName = Get-ChildItem "$Path\" -Recurse -Filter *$Value -Name)) {
            Out-Null | Out-File "$Path\$File" -Force

            switch ([int[]](Get-Item "$Path\$File" | ForEach-Object {[int]($_.length /1kb)})) {
                0 {Write-Color "O" -Color 'Green'; Write-Color " $Path\$File`n"; $Success++}
                default {Write-Color "X" -Color 'Red'; Write-Color " $Path\$File`n"; $Failed++}
            }
        }
        
        if ($GetName.length -eq 0) {
            Write-Color "--Cannot find $Value file(s)`n"
        }

        ""
    }

    Write-Color "  Success: $Success  //  Failed: $Failed`n" -Color 'Cyan'
    ""
}