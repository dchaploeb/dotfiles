if (-not $env:CHEZMOI) {
    cd ~/chezmoi
    git pull
    cd ~
    chezmoi apply
}
