$ErrorActionPreference = 'Stop'

function Require-Command {
    param([string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' not found in PATH. Open the script from a ModelSim/Questa-enabled shell."
    }
}

Require-Command vlib
Require-Command vmap
Require-Command vcom
Require-Command vsim

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $repoRoot

Write-Host "[1/4] Recreating work library..."
if (Test-Path "work") {
    Remove-Item -Recurse -Force "work"
}
vlib work
vmap work work

Write-Host "[2/4] Compiling VHDL sources..."
$sources = @(
    "src/arb1.vhd",
    "src/arb.vhd",
    "src/simple_arb.vhd",
    "src/arb_seu.vhd",
    "verification/drivers/driver.vhd",
    "verification/checkers/property_checker.vhd",
    "verification/checkers/protocol_checker.vhd",
    "verification/checkers/protocol_checker1.vhd",
    "verification/tb/arbtb1.vhd",
    "verification/tb/arbtb2.vhd",
    "verification/tb/arbtb3.vhd",
    "verification/tb/arb_tb.vhd",
    "verification/tb/arb_seu_tb.vhd"
)

foreach ($src in $sources) {
    Write-Host "  - vcom $src"
    & vcom $src
}

Write-Host "[3/4] Running all testbenches..."
$testbenches = @(
    "arbtb1",
    "arbtb2",
    "arbtb3",
    "arb_tb",
    "arb_seu_tb"
)

foreach ($tb in $testbenches) {
    Write-Host "  - vsim work.$tb"
    & vsim -c "work.$tb" -do "run -all; quit -f"
}

Write-Host "[4/4] Completed successfully."
