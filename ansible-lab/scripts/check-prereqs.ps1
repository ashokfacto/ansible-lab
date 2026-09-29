# Run in Windows PowerShell:  powershell -ExecutionPolicy Bypass -File .\scripts\check-prereqs.ps1
Write-Host "== Ansible lab prerequisite check ==" -ForegroundColor Cyan
$os = Get-CimInstance Win32_OperatingSystem
Write-Host ("Windows : {0} (build {1})" -f $os.Caption, $os.BuildNumber)
$ramGB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 1)
Write-Host ("RAM     : {0} GB {1}" -f $ramGB, $(if ($ramGB -ge 8) {"OK"} else {"(8 GB+ recommended)"}))
$virt = (Get-CimInstance Win32_Processor | Select-Object -First 1).VirtualizationFirmwareEnabled
Write-Host ("Virtualization in BIOS: {0}" -f $(if ($virt) {"Enabled"} else {"Not detected - enable VT-x/AMD-V (may show False if Hyper-V already running)"}))
if (Get-Command wsl.exe -ErrorAction SilentlyContinue) {
  Write-Host "WSL     : installed"; wsl.exe -l -v
} else { Write-Host "WSL     : MISSING -> run 'wsl --install -d Ubuntu-24.04' as Administrator" -ForegroundColor Yellow }
if (Get-Command docker -ErrorAction SilentlyContinue) {
  docker --version
  docker info *> $null; if ($LASTEXITCODE -eq 0) { Write-Host "Docker  : running" } else { Write-Host "Docker  : installed but NOT running -> start Docker Desktop" -ForegroundColor Yellow }
} else { Write-Host "Docker  : MISSING -> install Docker Desktop (WSL2 backend)" -ForegroundColor Yellow }
if (Get-Command code -ErrorAction SilentlyContinue) { Write-Host "VS Code : installed" } else { Write-Host "VS Code : optional, recommended" }
