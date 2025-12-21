# Installation Guide - Terraform

This guide will help you install Terraform on Windows using the provided script.

## Quick Installation

### Option 1: Using the Installation Script (Recommended)

1. **Open PowerShell as Administrator**:
   - Press `Win + X`
   - Select "Windows PowerShell (Admin)" or "Terminal (Admin)"
   - Or right-click PowerShell and select "Run as Administrator"

2. **Navigate to the terraform directory**:
   ```powershell
   cd "C:\Jobapp final\jobapp-full\terraform\aws"
   ```

3. **Run the installation script**:
   ```powershell
   .\install-terraform.ps1
   ```

4. **Follow the prompts** - The script will:
   - Check if Chocolatey is installed
   - Install Chocolatey if needed
   - Install Terraform using Chocolatey
   - Verify the installation

5. **Close and reopen PowerShell** (to refresh PATH)

6. **Verify installation**:
   ```powershell
   terraform version
   ```

### Option 2: Manual Installation

If you prefer to install manually or the script doesn't work:

#### Install Chocolatey

1. Open PowerShell as Administrator
2. Run:
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
   ```

#### Install Terraform

```powershell
choco install terraform -y
```

#### Verify Installation

Close and reopen PowerShell, then:

```powershell
terraform version
```

## Troubleshooting

### Script Execution Policy Error

If you get an execution policy error:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Then run the script again.

### Chocolatey Installation Fails

- Make sure you're running PowerShell as Administrator
- Check your internet connection
- Try installing Chocolatey manually (see Option 2)

### Terraform Not Found After Installation

1. **Close and reopen PowerShell** (important!)
2. Verify PATH:
   ```powershell
   $env:PATH -split ';' | Select-String terraform
   ```
3. If not found, manually refresh:
   ```powershell
   $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
   ```

### Check Installation

```powershell
# Check Chocolatey
choco --version

# Check Terraform
terraform version

# Check if commands are available
Get-Command choco
Get-Command terraform
```

## After Installation

Once Terraform is installed:

1. Navigate to terraform directory:
   ```powershell
   cd "C:\Jobapp final\jobapp-full\terraform\aws"
   ```

2. Initialize Terraform:
   ```powershell
   terraform init
   ```

3. Review the plan:
   ```powershell
   terraform plan
   ```

## Alternative: Using winget

If you have Windows 10/11 with winget:

```powershell
winget install HashiCorp.Terraform
```

## Need Help?

- [Terraform Downloads](https://www.terraform.io/downloads)
- [Chocolatey Documentation](https://chocolatey.org/docs)
- [Terraform Documentation](https://www.terraform.io/docs)


