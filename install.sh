#!/bin/bash

if [ -n "$BASH_VERSION" ]; then
  echo "Устанавливаем Zsh и необходимые пакеты..."
  
  # Установка Zsh и Git
  sudo apt update
  sudo apt install -y zsh git curl jq
  
  chsh -s /bin/zsh
  
  # Установка Oh My Zsh без автоматического запуска Zsh
  RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  
  exec zsh "$0" "$@"

  exit 0
fi


# Изменение темы на 'eastwood'
sed -i 's/^ZSH_THEME=".*"/ZSH_THEME="eastwood"/' ~/.zshrc

# Добавление кастомных алиасов
cat <<EOF >> ~/.zshrc

# Custom aliases
alias zs='/usr/local/bin/zellij --layout ~/.config/zellij/layout.kdl'
alias lnav='/usr/local/bin/lnav'
EOF

# Установка плагина zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# Добавление плагина zsh-autosuggestions в секцию plugins
if grep -q "^plugins=(" ~/.zshrc; then
    sed -i '/^plugins=(/ s/git/& zsh-autosuggestions/' ~/.zshrc
else
    echo "plugins=(git zsh-autosuggestions)" >> ~/.zshrc
fi

# Получение последней версии Zellij и URL бинарного файла
LATEST_VERSION=$(curl --silent "https://api.github.com/repos/zellij-org/zellij/releases/latest" | jq -r '.tag_name')
ASSET_URL=$(curl --silent "https://api.github.com/repos/zellij-org/zellij/releases/latest" | jq -r '.assets[] | select(.name | test("zellij-x86_64-unknown-linux-musl.tar.gz")) | .browser_download_url')

# Скачивание, распаковка и установка Zellij
curl -L $ASSET_URL -o zellij-$LATEST_VERSION.tar.gz
tar -xvzf zellij-$LATEST_VERSION.tar.gz
sudo mv zellij /usr/local/bin/
rm -rf zellij-$LATEST_VERSION*
# lnav
LATEST_VERSION=$(curl --silent "https://api.github.com/repos/tstack/lnav/releases/latest" | jq -r '.tag_name')
ASSET_URL=$(curl --silent "https://api.github.com/repos/tstack/lnav/releases/latest" | jq -r '.assets[] | select(.name | test("lnav-.*-linux-musl-x86_64.zip")) | .browser_download_url')

# Скачивание, распаковка и установка Zellij
curl -L $ASSET_URL -o lnav-$LATEST_VERSION.zip
unzip lnav-$LATEST_VERSION.zip
EXTRACTED_DIR=$(ls -d lnav-*/ | head -n 1)
sudo mv "$EXTRACTED_DIR/lnav" /usr/local/bin/
rm -rf "$EXTRACTED_DIR" "lnav-$LATEST_VERSION.zip"

# Создание конфигурационного файла для Zellij
mkdir -p ~/.config/zellij
cat <<EOF > ~/.config/zellij/layout.kdl
layout {
     pane split_direction="vertical" {
           pane split_direction="vertical" {
              pane name="sally"
              pane name="lnav"
     }
      }
      pane size=1 borderless=true {
          plugin location="zellij:compact-bar"
      }
  }
EOF

# Настройка Vim
cat <<EOF > ~/.vimrc
" Кодировка UTF-8
set encoding=utf8

" Отключение совместимости с vi. Нужно для правильной работы некоторых опций
set nocompatible

" Игнорировать регистр при поиске
set ignorecase

" Не игнорировать регистр, если в паттерне есть большие буквы
set smartcase

" Подсвечивать найденный паттерн
set hlsearch

" Интерактивный поиск
set incsearch

" Размер табов - 2
set tabstop=2
set softtabstop=2
set shiftwidth=2

" Превратить табы в пробелы
set expandtab

" Таб перед строкой будет вставлять количество пробелов определённое в shiftwidth
set smarttab

" Копировать отступ на новой строке
set autoindent
set smartindent

" Показывать номера строк
set number

" Относительные номера строк
set relativenumber

" Автокомплиты в командной строке
set wildmode=longest,list

" Подсветка синтаксиса
syntax on

" Разрешить использование мыши
set mouse=a

" Использовать системный буфер обмена
set clipboard=unnamedplus

" Быстрый скроллинг
set ttyfast

" Курсор во время скроллинга будет всегда в середине экрана
set so=30

" Встроенный плагин для распознавания отступов
filetype plugin indent on
EOF

# Применение изменений в Zsh
source ~/.zshrc

echo "Скрипт успешно завершен в Zsh."

