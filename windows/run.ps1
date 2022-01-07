$ver = $host | select version
if ($ver.Version.Major -gt 1)  {$Host.Runspace.ThreadOptions = "ReuseThread"}

# Verify that user running script is an administrator
$IsAdmin=[Security.Principal.WindowsIdentity]::GetCurrent()
If ((New-Object Security.Principal.WindowsPrincipal $IsAdmin).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator) -eq $FALSE)
{
    "`nERROR: You are NOT a local administrator.  Run this script after logging on with a local administrator account." # We are not running "as Administrator" - so relaunch as administrator
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell"; # Create a new process object that starts PowerShell
    $newProcess.Arguments = $myInvocation.MyCommand.Definition; # Specify the current script path and name as a parameter
    $newProcess.Verb = "runas"; # Indicate that the process should be elevated
    [System.Diagnostics.Process]::Start($newProcess); # Start the new process
    exit # Exit from the current, unelevated, process
}

$platform = "x64"
if ([intptr]::Size -eq 4) { $platform = "x86" }

$download = "https://github.com/robemmerson/qualys-log4j-scanner/raw/main/windows/$platform/Log4jScanner.exe"
$scanner = "%TEMP%\Log4jScanner.exe"

Write-Host Downloading latest release
Invoke-WebRequest $download -Out $scanner

Write-Host Running Qualys scan...
& "$scanner" /scan /report_sig

Write-Host Tidying up....
Remove-Item $scanner -Force