default_action :create

property :homedir, String
property :groups, Array, default: []
property :shared, Array, default: []
property :key_source, String
property :uid, Integer
property :gid, Integer

action :create do # rubocop:disable Metrics/BlockLength
  nr = new_resource
  homedir = if nr.homedir.nil?
              get_user(nr.name)[:dir] || "/var/app/#{nr.name}"
            else
              nr.homedir
            end

  group nr.name do
    gid nr.gid if nr.gid
    append true
  end

  user nr.name do
    uid nr.uid if nr.uid
    gid nr.name
    shell '/bin/bash'
    comment nr.name
    home homedir
  end

  nr.groups.each do |name|
    group name do
      members nr.name
      append true
    end
  end

  directory '/home' do
    path ::File.dirname(homedir)
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
  end

  directory homedir do
    owner nr.name
    group nr.name
    mode '0755'
  end

  directory "#{homedir}/.ssh" do
    owner nr.name
    group nr.name
    mode '0700'
  end

  if nr.key_source
    cookbook_file "#{homedir}/.ssh/id_rsa" do
      source nr.key_source
      owner nr.name
      group nr.name
      mode '0600'
    end

    cookbook_file "#{homedir}/.ssh/id_rsa.pub" do
      source "#{nr.key_source}.pub"
      owner nr.name
      group nr.name
      mode '0644'
    end
  end

  %w(
    bin
    releases
    shared
  ).each do |d|
    directory "#{homedir}/#{d}" do
      owner nr.name
      group nr.name
      mode '0755'
    end
  end

  shared = %w(cache log) + nr.shared

  shared.uniq.each do |d|
    directory "#{homedir}/shared/#{d}" do
      owner nr.name
      group nr.name
      mode '0755'
    end

    link "#{homedir}/#{d}" do
      to "#{homedir}/shared/#{d}"
    end
  end

  file "/etc/logrotate.d/deploy-#{nr.name}" do
    content <<-EOS
#{homedir}/shared/log/*.log {
 missingok
 rotate 21
 copytruncate
}
EOS
    owner 'root'
    group 'root'
    mode '0644'
  end
end
