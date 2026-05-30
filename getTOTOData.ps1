Param($dataSize=0)
# powershell -NoProfile -ExecutionPolicy RemoteSigned .\getTOTOData.ps1 -dataSize 1

function getTOTOData($dataSize=0) {
    $url = 'https://www.singaporepools.com.sg/en/product/pages/toto_results.aspx'
    $ie = New-Object -ComObject InternetExplorer.Application
    $ie.Visible = $true
    $ie.Navigate($url)
    while ($ie.busy -or $ie.readystate -ne 4) { Start-Sleep -Seconds 1 }

    $currentDocument = $ie.Document
    if ($dataSize -eq 0) {
        $dataSize = ($currentDocument.getElementsByTagName('SELECT'))[0].length
    }

    $result = @()
    for ($i=0; $i -lt $dataSize; $i++) {
        # ($currentDocument.getElementsByTagName('SELECT'))[0].selectedIndex = $i
        $outerhtml = ($currentDocument.getElementsByTagName('SELECT'))[0][$i].outerhtml
        # get link sppl
        $startPos = $outerhtml.IndexOf('querystring') + 'querystring="'.Length
        $endPos = $outerhtml.IndexOf('">')
        $sppl = $outerhtml.Substring($startPos, $endPos - $startPos)
        # get Draw No.
        $drawNum = ($currentDocument.getElementsByTagName('SELECT'))[0][$i].value

        $result += @{ link = 'https://www.singaporepools.com.sg/en/product/sr/Pages/toto_results.aspx?' + $sppl; draw = $drawNum }
    }

    # export TOTO results
    Set-Location -Path $PSScriptRoot
    $dataTxt = '.\data.txt'
    if ((Test-Path -Path $dataTxt) -eq $true) {
        $dateTime = Get-Date
        $dateTimeString = '{0:yyyyMMdd_hhmmss}' -f $dateTime
        Rename-Item -Path $dataTxt -NewName $dateTimeString'_data.txt' -Force
    }
    Out-File -FilePath $dataTxt -Encoding default

    for ($i=0; $i -lt $dataSize; $i++) {
        $ie.Navigate($result[$i]['link'])
        while ($ie.busy -or $ie.readystate -ne 4) { Start-Sleep -Seconds 1 }

        $currentDocument = $ie.Document
        $drawNum = $result[$i]['draw']
        $dataArr =  $drawNum + "," `
                    + $currentDocument.getElementsByClassName('win1')[0].outerText + "," `
                    + $currentDocument.getElementsByClassName('win2')[0].outerText + "," `
                    + $currentDocument.getElementsByClassName('win3')[0].outerText + "," `
                    + $currentDocument.getElementsByClassName('win4')[0].outerText + "," `
                    + $currentDocument.getElementsByClassName('win5')[0].outerText + "," `
                    + $currentDocument.getElementsByClassName('win6')[0].outerText + "," `
                    + $currentDocument.getElementsByClassName('additional')[0].outerText
        # Write-Host $dataArr
        Out-File -FilePath $dataTxt -Encoding default -InputObject $dataArr -Append
        # pause
    }

    $ie.Quit()
    [void][Runtime.Interopservices.Marshal]::ReleaseComObject($ie)
}

getTOTOData -dataSize $dataSize
