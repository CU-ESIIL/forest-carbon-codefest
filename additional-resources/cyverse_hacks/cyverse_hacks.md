# Transitioning Workflows to CyVerse: Tips & Tricks

## Forest Carbon Codefest Data Storage
- **Path:** `~/data-store/data/iplant/home/shared/earthlab/forest_carbon_codefest/`
- Your team has a subdirectory within the Team_outputs directory.

## Setup
1. **CyVerse Account:**
   - Create an account if not already owned.
   - Contact Tyson for account upgrades after maximizing current limits.

## GitHub Connection
- Follow [the guide for connecting GitHub to CyVerse](https://cu-esiil.github.io/forest-carbon-codefest/collaborating-on-the-cloud/cyverse-instructions/)
- Select “JupyterLab ESIIL” and choose “macrosystems” in the version dropdown.
- Clone into `/home/jovyan/data-store`.
- Clone `innovation-summit-utils` for SSH connection to GitHub.
- Run `conda install -c conda-forge openssh` in the terminal if encountering errors.
- GitHub authentication is session-specific.

## RStudio in Discovery Environment
1. Copy your instance ID. It can be found in your analyis URL in form https://<instance_id>.cyverse.run/lab.
2. Use your ID in these links and run them each, in sequence, in the same browser window:  
   - `https://<id>.cyverse.run/rstudio/auth-sign-in` 
   - `https://<id>.cyverse.run/rstudio/` 

## Data Transfer to CyVerse
- Use GoCommands for HPC/CyVerse transfers.
- **Installation:**
  - **Linux:** GOCMD_VER=$(curl -L -s https://raw.githubusercontent.com/cyverse/gocommands/main/VERSION.txt); \
curl -L -s https://github.com/cyverse/gocommands/releases/download/${GOCMD_VER}/gocmd-${GOCMD_VER}-linux-amd64.tar.gz | tar zxvf -
  - **Windows Powershell:** curl -o gocmdv.txt https://raw.githubusercontent.com/cyverse/gocommands/main/VERSION.txt ; $env:GOCMD_VER = (Get-Content gocmdv.txt)
curl -o gocmd.zip https://github.com/cyverse/gocommands/releases/download/$env:GOCMD_VER/gocmd-$env:GOCMD_VER-windows-amd64.zip ; tar zxvf gocmd.zip ; del gocmd.zip ; del gocmdv.txt
- **Usage:** 
  - ./gocmd init
  - Hit enter until you are asked for your iRODS Username (which is your cyverse username)
  - Use `put` for upload and `get` for download.
  - Ensure correct CyVerse directory path. Note that the CyVerse directory path should start from “/iplant/home/…” (i.e. if you start from ‘/home/jovyan/…’ GoCommands will not find the directory and throw an error)
