# apt packages
%w(
  ruby2.5
  ruby2.5-dev
  build-essential
  git
  i3
  i3status
  suckless-tools
  redshift-gtk
  geoclue-2.0
  gnome-encfs-manager
  gnome-terminal
  autossh
  compton
  unclutter
  urlscan
  mutt
  docker-ce
  riot-web
  numix-gtk-theme
  numix-icon-theme
  feh
  gnupg
  transmission-gtk
  neovim
  unzip
  dkms
  pass
  libdbus-glib-1-dev
  whois
  htop
  mpv
  i965-va-driver
  vdpau-va-driver
  curl
  jq
  network-manager-openvpn-gnome
  network-manager-openconnect-gnome
  unrar
  w3m
  yarn
  gimp
  pinentry-curses
  libsecret-1-dev
  azure-cli
  exuberant-ctags
  nodejs
  keepassx
  mosh
  signal-desktop
  xclip
  silversearcher-ag
  pulseaudio-module-bluetooth
  shellcheck
  hugo
  gopass
  python3-pip
  python-pip
  ttf-mscorefonts-installer
  fonts-font-awesome
  fonts-powerline
).each do |p|
  package p
end

# Install golang separately to we can keep track of the version
package "golang-#{node[:golang_version]}"
package 'glide'

# Remove a couple of apt packages
%w(
  thunderbird
  pidgin
  apport-gtk
).each do |p|
  package p do
    action [:remove]
  end
end

# Python2 pip packages installed locally
%w(
  keyring
  awscli
  streamlink
  neovim
  SecretStorage
  dbus-python
  flake8
  msgpack-python
  python-language-server
).each do |python_p|
  pip python_p do
    pip_binary '/usr/bin/pip2'
    action [:upgrade]
    options '--user'
    user node[:login_user]
  end
end

# Python3 pip packages installed locally
%w(
  neovim
).each do |python_p|
  pip python_p do
    pip_binary '/usr/bin/pip3'
    action [:upgrade]
    options '--user'
    user node[:login_user]
  end
end

# Install the libsecret helper
execute 'make' do
  cwd '/usr/share/doc/git/contrib/credential/libsecret'
  not_if 'test -f /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret'
end

{
  'google-chrome-stable' => 'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb',
  'mattermost-desktop' => "https://releases.mattermost.com/desktop/#{node[:mattermost_version]}/mattermost-desktop-#{node[:mattermost_version]}-linux-amd64.deb"
}.each do |name, url|
  apt name do
    source_url url
  end
end

# Global rubygems
%w(
  bundler
  neovim
  ohai
  rubocop
  rubocop-rspec
).each do |g|
  gem_package g
end

rustup 'stable' do
  user node[:login_user]
end

download 'powerline-go' do
  url "https://github.com/justjanne/powerline-go/releases/download/v#{node[:powerline_go_version]}/powerline-go-linux-amd64"
  destination "#{ENV['HOME']}/.local/bin/powerline-go"
  mode '0755'
  checksum node[:powerline_go_checksum]
end

download 'ctop' do
  url "https://github.com/bcicen/ctop/releases/download/v#{node[:ctop_version]}/ctop-#{node[:ctop_version]}-linux-amd64"
  destination "#{ENV['HOME']}/.local/bin/ctop"
  mode '0755'
  checksum node[:ctop_checksum]
end

download 'awstools' do
  url "https://github.com/sam701/awstools/releases/download/#{node[:awstools_version]}/awstools_linux_amd64"
  destination "#{ENV['HOME']}/.local/bin/awstools"
  mode '0755'
  checksum node[:awstools_checksum]
end

download 'minikube' do
  url "https://github.com/kubernetes/minikube/releases/download/v#{node[:minikube_version]}/minikube-linux-amd64"
  destination "#{ENV['HOME']}/.local/bin/minikube"
  mode '0755'
  checksum node[:minikube_checksum]
end

{
  'ruby' => '/usr/bin/ruby2.5',
  'gem' => '/usr/bin/gem2.5',
  'vim' => '/home/moe/AppImages/nvim.appimage',
  'pinentry' => '/usr/bin/pinentry-curses',
  'node' => '/usr/bin/nodejs'
}.each do |n, p|
  elements = p.split('/')
  elements.pop
  l = (elements << n).join('/')

  alternatives n do
    path p
    link l
  end
end

saml2aws_install node[:saml2aws_version] do
  checksum node[:saml2aws_checksum]
end
