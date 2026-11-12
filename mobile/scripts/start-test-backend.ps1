$ErrorActionPreference = 'Stop'
Write-Output 'HIPPIE_BACKEND_STARTING'

$connection = New-Object System.Net.Sockets.TcpClient
try {
    $connection.Connect('127.0.0.1', 3000)
    Write-Output 'Porta 3000 ja esta em uso. Reutilizando o servidor em execucao.'
    Write-Output 'HIPPIE_BACKEND_READY'
    exit 0
} catch [System.Net.Sockets.SocketException] {
    # Start the development API when no server is listening.
} finally {
    $connection.Dispose()
}

$backendPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../backend'))
if (-not (Test-Path -LiteralPath (Join-Path $backendPath 'package.json'))) {
    throw "Backend nao encontrado em $backendPath"
}

Push-Location -LiteralPath $backendPath
try {
    & npm.cmd run start:dev 2>&1 | ForEach-Object {
        Write-Output $_
        if ("$_" -match 'Hippie Turismo: http://') {
            Write-Output 'HIPPIE_BACKEND_READY'
        }
    }
    if ($LASTEXITCODE -ne 0) {
        throw "O backend terminou com erro ($LASTEXITCODE). Verifique a saida acima."
    }
} finally {
    Pop-Location
}
