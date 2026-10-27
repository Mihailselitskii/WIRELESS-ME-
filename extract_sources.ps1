Add-Type -AssemblyName System.IO.Compression.FileSystem
$jar = "C:\Users\mihai\.gradle\caches\neoformruntime\intermediate_results\mergeWithSources_e709d2077f2dea4eadf7380042a71835d124a1cc_output.jar"
$z = [System.IO.Compression.ZipFile]::OpenRead($jar)
$out = "C:\Users\mihai\AppData\Local\Temp\mcsrc"
if (-not (Test-Path $out)) { New-Item -ItemType Directory -Force $out | Out-Null }
$want = @(
  'net/minecraft/resources/Identifier.java',
  'net/minecraft/world/level/storage/ValueOutput.java',
  'net/minecraft/world/level/storage/ValueInput.java',
  'net/minecraft/world/entity/player/Player.java',
  'net/minecraft/world/level/block/entity/BlockEntity.java',
  'net/minecraft/world/level/block/BaseEntityBlock.java',
  'net/minecraft/world/level/block/entity/EntityBlock.java',
  'net/minecraft/nbt/NbtUtils.java',
  'net/minecraft/core/component/DataComponents.java'
)
foreach ($w in $want) {
  $e = $z.GetEntry($w)
  if ($e) {
    $r = New-Object IO.StreamReader($e.Open())
    $txt = $r.ReadToEnd(); $r.Close()
    $fn = Join-Path $out ($w -replace '[/$\\]','_')
    [IO.File]::WriteAllText($fn, $txt)
    Write-Host "extracted $fn"
  } else { Write-Host "MISSING $w" }
}
$z.Dispose()
