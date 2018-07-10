default_action :create

attribute :user, kind_of: String, name_attribute: true
attribute :repository, kind_of: String, required: true
attribute :revision, kind_of: String, default: nil
attribute :purge_before_symlink, kind_of: Array, default: []
attribute :symlink_before_migrate, kind_of: Hash, default: {}
attribute :symlinks, kind_of: Hash, default: {}
attribute :force, kind_of: [TrueClass, FalseClass], default: false

def initialize(name, run_context=nil)
  super(name, run_context)
  @action = :create
end

def before_migrate(arg=nil, &block)
  arg ||= block
  set_or_return(:before_migrate, arg, kind_of: [Proc, String])
end

def before_symlink(arg=nil, &block)
  arg ||= block
  set_or_return(:before_symlink, arg, kind_of: [Proc, String])
end

def before_restart(arg=nil, &block)
  arg ||= block
  set_or_return(:before_restart, arg, kind_of: [Proc, String])
end

action :create do
  nr = new_resource # rebind
  user = get_user(nr.user)
  path = user[:dir]
  revision = nr.revision || node.chef_environment

  deploy_branch path do
    repository nr.repository
    revision revision
    enable_submodules true

    user nr.user

    action :force_deploy if nr.force

    purge_before_symlink nr.purge_before_symlink
    symlink_before_migrate nr.symlink_before_migrate
    symlinks nr.symlinks

    migrate true
    migration_command '/bin/true' # use callbacks for actual work

    before_migrate nr.before_migrate
    before_symlink nr.before_symlink
    before_restart nr.before_restart
  end
end
