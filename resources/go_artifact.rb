default_action :create

property :user, String, name_attribute: true
property :remote_path, String
property :bucket, String
property :aws_access_key_id, String
property :aws_secret_access_key, String
property :s3_url, String
property :token, String

action :create do
  nr = new_resource # rebind
  user = get_user(nr.user)
  path = user[:dir]

  aws_s3_file "#{path}/bin/#{nr.user}.current" do
    remote_path nr.remote_path
    bucket nr.bucket
    aws_access_key_id nr.aws_access_key_id
    aws_secret_access_key nr.aws_secret_access_key
    owner nr.user
    group nr.user
    mode "0755"
    notifies :run, "bash[make-versioned-binary]", :immediately
  end

  bash "make-versioned-binary" do
    action :nothing
    user nr.user
    code <<-EOH
    version=$(#{path}/bin/#{nr.user}.current -version)
    if [ -z "$version" ]; then
      version=$(#{path}/bin/#{nr.user}.current version)
    fi
    cp #{path}/bin/#{nr.user}.current #{path}/bin/#{nr.user}.${version}
    ln -Tfs #{path}/bin/#{nr.user}.${version} #{path}/bin/#{nr.user}
    EOH
  end
end
