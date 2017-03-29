name 'deploy'
maintainer 'Benedikt Böhm'
maintainer_email 'bb@xnull.de'
license 'Apache 2.0'
description 'Helper resources for application deployment'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.0.0'

source_url 'https://github.com/zenops-cookbooks/deploy' if respond_to?(:source_url)
issues_url 'https://github.com/zenops-cookbooks/deploy/issues' if respond_to?(:issues_url)

depends "aws"
