$ErrorActionPreference = "Stop"

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  throw "Docker is not installed or not on PATH."
}

docker compose version | Out-Null

function Copy-IfMissing($Source, $Destination) {
  if (Test-Path $Destination) {
    Write-Host "Keeping existing $Destination"
  } else {
    Copy-Item $Source $Destination
    Write-Host "Created $Destination from $Source"
  }
}

Copy-IfMissing ".env.example" ".env"
Copy-IfMissing "masjid-core/.env.example" "masjid-core/.env"
Write-Host "Review .env and masjid-core/.env, then run: docker compose up --build -d"
