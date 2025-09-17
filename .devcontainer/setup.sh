
#!/usr/bin/env bash
set -e
sudo apt-get update
sudo apt-get install -y curl unzip xz-utils file git
if [ ! -d "$HOME/flutter" ]; then
  git clone -b stable https://github.com/flutter/flutter.git $HOME/flutter
fi
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> $HOME/.bashrc
export PATH="$HOME/flutter/bin:$PATH"
flutter --version
flutter config --enable-web
if [ ! -f "pubspec.yaml" ]; then
  flutter create .
fi
flutter pub get || true
