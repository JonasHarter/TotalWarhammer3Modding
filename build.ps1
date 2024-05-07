$rpfmPath = "..\_RustPackFileManager\rpfm_cli.exe"
# \AppData\Roaming\FrodoWazEre\rpfm\config\schemas\schema_wh3.ron
$tw3Schema = ".\schema_wh3.ron"
$files = Get-ChildItem ".\"
foreach ($f in $files) {
    $folderNameFull = $f.FullName
    $folderName = $f.Name
    $folderObject = get-item $folderNameFull
    if(!$folderObject.PSIsContainer) {
        break
    }
    $packFileName = "$folderNameFull\kafka_$folderName.pack"
    $importFolderName = "$folderNameFull\pack"
    Remove-Item -Path $packFileName
    & $rpfmPath --game warhammer_3 pack create -p $packFileName
    & $rpfmPath --game warhammer_3 pack add -F $importFolderName -p $packFileName -t $tw3Schema
}