
# dotfiles

Welcome to my dotfiles repo.  I use `chezmoi` to manage my home directory, 
synchronize application settins, and install packages on my computers.

# This Document

This is an early version of this document.  I am still developing this setup,
and some of the things I want to do are not implemented yet or the
implementation doesn't fully work properly.  I'm using this document to note 
things about my workflow, some of which aren't automated by chezmoi.  And to 
some degree, this document will mix things I have implemented with things I 
have not, though I will try to be clear which are which.

# My computing profile

I am an IT Professional.  I do some programming, but I also do other technical 
work.  

I do more command line work than the average non-technical user, and (as my use
of chezmoi shows) I like reproducible, idempotent processes.  Windows System 
Administration (which I also do) drives me crazy for this reason.  My command 
line work includes spending a fair amount of time in `powershell` on windows 
and `zsh` on Linux.  My Linux work is primarily in `wsl` development 
environments (running on my Windows desktops) or remote servers that I connect 
to using `ssh`.  

I know people who pretty much use the CLI exclusively, I am also an opinionated 
user of GUIs.  Most of my work is done on Windows desktop computers, but I find 
Windows 11 in its base setup basically unusable.  (If I have to use someone 
else's Win11 computer for a few minutes without installing
my whole setup, I *must* at least move the start menu to the left!)  I really
like VSCode and Windows Terminal and use them extensively.  I think someone
needs to rethink the whole idea of tabbed windows, but obviously they're what
we've got for now.  (And don't get me wrong-- having them is better than not
having them, and WAY better than the old Windows MDI paradigm).

I have a strong bias towards open-source software, and these days MOST of my
toolchain is Open Source.  In terms of application software I install on my 
computers, the main exceptions these days are Windows itself, Obsidian, and
Start11.  And Excel.   

I don't currently use MacOS or Linux GUIs much, but I have in the past and 
expect to do so again in the future.  My next home computer will probably 
dual-boot Windows and Linux, although WSL makes it less urgent to be able to
do this.

# chezmoi workflow

I have auto-commit and auto-push turned on.  Both zsh and powershell are 
set to run chezmoi update and chezmoi apply at login.  After editing a dotfile 
in my home directory, I run `chezmoi re-add`, which picks up the change, 
commits it, and pushes it to github.   `chezmoi re-add` turns out to be the command that makes `chezmoi` really a time-saver for me.  When I read people
complaining about `chezmoi` on the web, it's the process of editing files in
the chezmoi directory rather than where they're being used that turns people 
off.  For the most part, you don't have to do this.  Edit files that have 
been added to chezmoi in-place, then run chezmoi re-add.

For easy access to scripts and templates, I have chezmoi create a symlink at 
`~/chezmoi` pointing to `~/.local/share/chezmoi`.  This allows me to easily 
switch to the directory, or open it with `code chezmoi`

If a file needs to be different on different machines, use `chezmoi 
add --template` to convert it to a template.

# The goal

When I sign into a new computer or environment, I'd like to be able to 
reproduce my preferred setup with a minimal number of steps.  

Ideally those steps should pretty much be:
 
  1. Install a dependency or two (On many modern OSs, the prereqs--
     git, ssh, and a package manager-- all already there. But in some
     environments I may need to install some of these things)
  2. Make an ssh key and upload it to github `ssh-keygen`
  3. Install chezmoi and have it apply my dotfiles repository from github. 
     This installs a set of packages, which depend on the OS I'm running on.
     (The "installing the right set of packages" part is a work in progress).

     In Linux: 
     `sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply git@github.com:dchaploeb/dotfiles.git` 

     or in powershell: `iex "&{$(irm 'https://get.chezmoi.io/ps1')} -- init --apply git@github.com:dchaploeb/dotfiles.git"`
 
  4. In some cases, I may need to tweak a setting or two in 
     `~/.config/chezmoi/chezmoi.toml` [TODO].  After doing this, I may need to 
     run `chezmoi apply` again.
  5. After chezmoi installs everything, I may need to sign into a few
     other sync services.  Today those sync services are Proton Drive, 
     vscode sync, Obsidian sync, and iCloud.

In an ideal world, there is no step 6.  Everything I need is installed, my 
data is synced and configured the way I like it at this point.  Getting to this 
ideal is a work in progress.

# Functionality (and desired functionality)

## Dotfiles, Profiles, and Preferences

 - ✅ Sync .gitconfig
 - ✅ Sync zsh dotfiles
 - ✅ Sync powershell profile
 - ✅ Powershell profile installs to all of the places it might be needed 
      (4 of them, at the moment; there will be one more if I start using pwsh 
      on linux).  Because this multi-install makes running the actual $PROFILE
      file awkward, I now use a profile directory and run everything in it. In
      the rare event that I need to edit the actual profile script, the 
      editable version of that lives at 
      `~/chezmoi/.chezmoitemplates/Microsoft.PowerShell_profile.ps1.tmpl`
 - ✅ Sync Windows Terminal Settings
 - ✅ Sync icons for use with windows terminal.
 - ✅ Sync my custom `retrobar` theme and settings on Windows
 
## Scripts and aliases
 - ✅ On windows, my defines a unix-like `ls` function and a useful `Add-ToPath` function
 - ✅ Python convert_png_to_ico.py (works!)
 - TODO: More to come from dev environments.

## Package management

This is the area that needs the most work.  If I needed EXACTLY the same
in every environment, I really wouldn't need multiple environments so much.
Plus scripts that install software often aren't idempotent, and often aren't
fast, so you don't want it checking all of your software every time you're 
just trying to get to work.  But getting the packages I need installed 
quickly and efficiently is a big part of the point of this project, so I'm
stil working on this.

 -  ✅ Install needed packages on linux
 -  TODO: Seperate some packages that are only needed for certain projects
 -  TODO: Finish winget package installation
 -  TODO: Fix powershell module installation
 -  TODO: Move as many `bin/` install scripts as possible to actual scripts run 
    by `chezmoi`.

## Start Menu and Web Shortcuts (on Windows)

I use retrobar to create a Windows XP style taskbar, and Start11 to create a Windows 10 style Start menu.  Fight Me.

I also make pretty heavy use of Brave "application" shortcuts, which install 
into the start menu.  (You could do something similar with any chromium-based
browser).  But those "applications" aren't easily syncable between
computers, nor is there a simple way to script making the browser create
them.  So I'm working on an alternative.

In theory the Start11 integration should be easy, but it's one of those 
things that I haven't tried yet because it's a little scary (Start11 settings 
are stored in the registry), and my manually-created start menus on most of 
my computers are more-or-less how I want them, so I'm reluctant to potentially
hose them.

Start11 is a closed-source commercial product, so if I can find an open-source
launcher that does more or less what I need, I'll consider it.

 - ✅ Sync Retrobar theme and prefs
 - TODO: Build and install Web shortcuts
 - TODO: Start11 integration (or other start menu manager, if I can find one 
   that meets my needs.)  