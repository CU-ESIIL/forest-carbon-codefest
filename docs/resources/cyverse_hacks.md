# Transitioning Workflows to CyVerse: A Guide for ESIIL Postdocs

## Earth Lab Data Storage
- **Path:** `/home/jovyan/data-store/iplant/home/shared/earthlab/`
- Ensure your project has a directory within the Earth Lab data storage.

## Setup
1. **CyVerse Account:**
   - Create an account if not already owned.
   - Contact Tyson for account upgrades after maximizing current limits.

## GitHub Connection
- Follow Elsa Culler's guide for connecting GitHub to CyVerse.
- Select “JupyterLab ESIIL” and choose “macrosystems” in the version dropdown.
- Clone into `/home/jovyan/data-store`.
- Clone `innovation-summit-utils` for SSH connection to GitHub.
- Run `conda install -c conda-forge openssh` in the terminal if encountering errors.
- GitHub authentication is session-specific.

## RStudio in DE
1. Copy your instance ID. It can be found in your analyis URL in form https://<instance_id>.cyverse.run/lab.
2. Use your ID in these links:  
   - `https://<id>.cyverse.run/rstudio/auth-sign-in` 
   - `https://<id>.cyverse.run/rstudio/` 

## Package Requests
- List desired packages here for future container updates.

## Data Transfer to CyVerse
- Use GoCommands for HPC/CyVerse transfers.
- **Installation:**
  - **Linux:** (Command)
  - **Windows Powershell:** (Command)
- **Usage:** 
  - Use `put` for upload and `get` for download.
  - Ensure correct CyVerse directory path.
