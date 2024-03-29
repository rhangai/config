# Configurando Linux

## Vídeo

### Fedora

https://docs.fedoraproject.org/en-US/quick-docs/how-to-set-nvidia-as-primary-gpu-on-optimus-based-laptops/

## Audio

### Links

https://askubuntu.com/questions/1230016/headset-microphone-not-working-on-ubuntu-20-04

https://www.kernel.org/doc/html/latest/sound/hd-audio/models.html

### Acer predator

Editar `/etc/modprobe.d/alsa-base.conf`

```
options snd-hda-intel model=aspire-headset-mic
options snd-hda-intel power_save=0
options snd-hda-intel power_save_controller=N
```

## KDE

KRunner com meta

```sh
kwriteconfig5 --file ~/.config/kwinrc --group ModifierOnlyShortcuts --key Meta "org.kde.kglobalaccel,/component/org_kde_krunner_desktop,,invokeShortcut,_launch" && qdbus org.kde.KWin /KWin reconfigure
```

# Configuração

## Shell

-   https://ohmyz.sh/
-   https://github.com/romkatv/powerlevel10k#oh-my-zsh
-   https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md
-   https://github.com/rhangai/config

## Fontes

Baixar https://www.nerdfonts.com/font-downloads e extrair para ~/.fonts/nome-da-fonte depois:

```sh
fc-cache -f
fc-list
```

## Aplicativos

Flatpak https://flatpak.org/setup/

-   https://flathub.org/apps/details/com.visualstudio.code
-   https://flathub.org/apps/details/com.skype.Client
-   https://flathub.org/apps/details/org.gimp.GIMP

# Utilitários

## node+yarn

https://github.com/nvm-sh/nvm

```sh
nvm install 16
npm install -g yarn
```

## exa

Alternativa para ll, ls, lt, l

```sh
alias ls='exa'
alias ll='exa -lhagF --git'
alias l='exa -lhagF --git'
alias lt='exa -lhagFT --level=2'
```

## bat

Alternativa para cat

```sh
bat arquivo
```

## ncdu

Alternativa para du

```
ncdu pasta
```

## diff-so-fancy

```sh
npm install -g diff-so-fancy
```

https://github.com/so-fancy/diff-so-fancy
