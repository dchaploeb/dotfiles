
# dotfiles

Welcome to my dotfiles repo.  I use `chezmoi` to manage my home directory, synchronize application settins, and install packages on my computers.

# This Document

This is an early version of this document.  I am still developing this setup and some of the things I want to do are not implemented yet or the implementation doesn't fully work properly.  I'm using this document to note things about my workflow, some of which aren't automated by chezmoi.  And to some degree, this document will mix things I have implemented with things I have not, though I will try to be clear which are which.

# My use profile

I am an IT Professional.  I do some programming, but I also do other technical work.  

I do more command line work than the average non-technical user, and (as my use of chezmoi shows) I like reproducible, idempotent processes.  Windows System Administration (which I also do) drives me crazy for this reason.  My command line work includes spending a fair amount of time in `powershell` on windows and `zsh` on Linux.  My Linux work is primarily in `wsl` development environments (running on my Windows desktops) or remote servers that I connect to using `ssh`

I am also an opinionated user of GUIs.  I find Windows 11 in its base setup unusable.  

I don't currently use MacOS or Linux GUIs much, but I have in the past and expect to do so again in the future.

# chezmoi workflow

I have auto-commit and auto-push turned on.  Both zsh and powershell [TODO] are set to run chezmoi update and chezmoi apply at login.  After editing a dotfile in my home directory, I run chezmoi re-add, which picks up the change, commits it, and pushes it to github.  

For easy access to scripts and templates, I have chezmoi create a symlink at ~/chezmoi pointing to ~/.local/share/chezmoi

If a file needs to be different on different machines, use chezmoi template to convert it to a template.

# The goal

When I sign into a new computer or environment, I'd like to be able to reproduce my preferred setup with a minimal number of steps.  

Ideally those steps should pretty much be:
 
  1. Install a dependency or two (On many modern OSs, the prereqs--
     git, ssh, and a package manager-- all already there. But in some
     environments I may need to install some of these things)
  2. Make an ssh key and upload it to github
  3. Install chezmoi and have it apply my dotfiles repository from github. This installs a set of packages, which depend on the OS I'm running in.
  4. In some cases, I may need to tweak a setting or two in ~/.config/chezmoi/chezmoi.toml [TODO].  After doing this, I may need to run chezmoi apply again.
  5. After chezmoi installs everything, I may need to sign into a few
     other sync services.  Today those sync services are Proton Drive, vscode sync, Obsidian sync, and iCloud.

 In an ideal world, there is no step 6.  Everything I need is synced and configured the way I like it at this point.  Getting to this ideal is a work in progress.

# Functionality (and desired functionality)

## Dotfiles, Profiles, and Preferences

 - ✅ Sync .gitconfig
 - ✅ Sync zsh dotfiles
 - ✅ Sync powershell profile
 - TODO: Make Powershell profile go to the right place on powershell 7, on all computers (There is additional complexity because the location of "Documents" may vary).  Right now there are multiple copies of this in the repo, fix.
 - ✅ Sync Windows Terminal Settings
 - TODO: figure out where to put icons and sync those
 - ✅ Sync my custom `retrobar` theme and settings on Windows
 
## Scripts and aliases
 - ✅ On windows, my $PROFILE defines a unix-like `ls` function and a useful `Add-ToPath` function
 - ✅ Python convert_png_to_ico.py (works!)
 - TODO: More to come from dev environments.

## Package management
 -  ✅ Install needed packages on linux
 -  TODO: Seperate some packages that are only needed for certain projects
 -  TODO: Finish winget package installation
 -  TODO: Fix powershell module installation
 -  TODO: python -m pip install --user pillow

## Start Menu
 - ✅ Sync Retrobar theme and prefs
 - TODO: Start11 integration (or other start menu manager, if I can find one that meets my needs.)
 - TODO: Build and install Web shortcuts, put them in the start menu

 