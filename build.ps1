$rpfmPath = "D:\Projects\TotalWarhammer3Modding\_RustPackFileManager\rpfm_cli.exe"
$tw3Schema = "C:\Users\Jonas\AppData\Roaming\FrodoWazEre\rpfm\config\schemas\schema_wh3.ron"
$files = Get-ChildItem ".\"
foreach ($f in $files){
    $folderNameFull = $f.FullName
    $folderName = $f.Name
    $folderObject = get-item $folderNameFull
    if(!$folderObject.PSIsContainer) {
        break
    }
    $packFileName = "$folderNameFull\$folderName.pack"
    $importFolderName = "$folderNameFull\pack"
    & $rpfmPath --game warhammer_3 pack create -p $packFileName
    & $rpfmPath --game warhammer_3 pack add -F $importFolderName -p $packFileName -t $tw3Schema

}