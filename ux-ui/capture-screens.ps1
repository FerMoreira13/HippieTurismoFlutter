$ErrorActionPreference = 'Stop'
$serial = 'emulator-5554'
$output = Join-Path $PSScriptRoot 'assets'
New-Item -ItemType Directory -Force -Path $output | Out-Null

function Send-AdbService($socket, [string]$name) {
  $stream = $socket.GetStream()
  $bytes = [Text.Encoding]::ASCII.GetBytes(('{0:x4}' -f $name.Length) + $name)
  $stream.Write($bytes, 0, $bytes.Length)
  $header = New-Object byte[] 4
  [void]$stream.Read($header, 0, 4)
  if ([Text.Encoding]::ASCII.GetString($header) -ne 'OKAY') { throw 'Falha na conexão ADB.' }
}

function Invoke-AdbShell([string]$command) {
  $client = [Net.Sockets.TcpClient]::new()
  $client.ReceiveTimeout = 15000
  $client.Connect('127.0.0.1', 5037)
  try {
    Send-AdbService $client "host:transport:$serial"
    Send-AdbService $client "shell:$command"
    $stream = $client.GetStream()
    $buffer = New-Object byte[] 8192
    while (($count = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) { }
  } finally { $client.Dispose() }
}

function Save-Screen([string]$name) {
  $client = [Net.Sockets.TcpClient]::new()
  $client.ReceiveTimeout = 15000
  $client.Connect('127.0.0.1', 5037)
  try {
    Send-AdbService $client "host:transport:$serial"
    Send-AdbService $client 'exec:screencap -p'
    $stream = $client.GetStream()
    $file = [IO.File]::Create((Join-Path $output $name))
    try {
      $buffer = New-Object byte[] 65536
      while (($count = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) { $file.Write($buffer, 0, $count) }
    } finally { $file.Dispose() }
  } finally { $client.Dispose() }
}

Invoke-AdbShell 'input tap 108 2280'; Start-Sleep -Seconds 2; Save-Screen '01-explorar.png'
Invoke-AdbShell 'input tap 324 2280'; Start-Sleep -Seconds 2; Save-Screen '02-mapa.png'
Invoke-AdbShell 'input tap 540 2280'; Start-Sleep -Seconds 2; Save-Screen '03-salvos.png'
Invoke-AdbShell 'input tap 756 2280'; Start-Sleep -Seconds 2; Save-Screen '04-roteiro.png'
Invoke-AdbShell 'input tap 970 2280'; Start-Sleep -Seconds 2; Save-Screen '05-perfil.png'
Invoke-AdbShell 'input tap 108 2280'; Start-Sleep -Seconds 1
Invoke-AdbShell 'input tap 490 1730'; Start-Sleep -Seconds 3; Save-Screen '06-detalhes.png'
Invoke-AdbShell 'input keyevent 4'
