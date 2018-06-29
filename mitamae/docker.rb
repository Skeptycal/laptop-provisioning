download 'docker-compose' do
  url "https://github.com/docker/compose/releases/download/#{node[:docker_compose_version]}/docker-compose-Linux-x86_64"
  destination "#{ENV['HOME']}/.local/bin/docker-compose"
  mode '0755'
  checksum node[:docker_compose_checksum]
end

add_user_to_group 'moe' do
  group 'docker'
end