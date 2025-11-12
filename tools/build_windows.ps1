Param(
  [ValidateSet('Release','Debug')]
  [string]$Config = 'Release',
  [string]$Arch = 'x64',
  [string]$Generator = 'Visual Studio 17 2022',
  [string]$BuildDir = 'build/windows'
)

Write-Host "[OTClient] Build Windows iniciado (Config=$Config, Arch=$Arch)" -ForegroundColor Cyan

# Verifica CMake
if (-not (Get-Command cmake -ErrorAction SilentlyContinue)) {
  Write-Error 'CMake não encontrado no PATH. Instale CMake e tente novamente.'
  exit 1
}

# Descobre VCPKG
$vcpkgRoot = $env:VCPKG_ROOT
if (-not $vcpkgRoot) {
  if (Test-Path "$PSScriptRoot\..\vcpkg") {
    $vcpkgRoot = Resolve-Path "$PSScriptRoot\..\vcpkg"
  }
}

$toolchainArg = ''
if ($vcpkgRoot -and (Test-Path "$vcpkgRoot\scripts\buildsystems\vcpkg.cmake")) {
  $toolchainArg = "-DCMAKE_TOOLCHAIN_FILE=$vcpkgRoot\scripts\buildsystems\vcpkg.cmake"
  Write-Host "Usando vcpkg em: $vcpkgRoot" -ForegroundColor Green
} else {
  Write-Host 'vcpkg não detectado. Continuando sem toolchain (pode falhar por dependências).' -ForegroundColor Yellow
}

# Cria pasta de build
New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null

# Configura projeto com CMake (Visual Studio)
$configureCmd = @(
  'cmake',
  '-S', '.',
  '-B', $BuildDir,
  '-G', $Generator,
  '-A', $Arch,
  $toolchainArg
) -join ' '

Write-Host "Configurando: $configureCmd" -ForegroundColor Cyan
cmd /c $configureCmd
if ($LASTEXITCODE -ne 0) { Write-Error 'Falha na configuração CMake.'; exit $LASTEXITCODE }

# Compila
$buildCmd = @(
  'cmake',
  '--build', $BuildDir,
  '--config', $Config,
  '--', '/m'
) -join ' '

Write-Host "Compilando: $buildCmd" -ForegroundColor Cyan
cmd /c $buildCmd
if ($LASTEXITCODE -ne 0) { Write-Error 'Falha na compilação.'; exit $LASTEXITCODE }

Write-Host "Build concluído com sucesso em '$BuildDir' ($Config)." -ForegroundColor Green
