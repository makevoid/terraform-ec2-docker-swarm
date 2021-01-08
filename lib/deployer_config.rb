module DeployerConfig

  def deployer_config_pull
    exe "cd #{PATH}/vendor && git clone #{DEPLOYER_CONFIG_GIT_URI}"
    pull = "git pull origin master --rebase=false"
    exe "cd #{PATH}/vendor/deployer-config && #{pull}"
  end

  def deployer_config_read
    YAML.load_file "#{PATH}/vendor/deployer-config/config.yml"
  end

  def deployer_config_write(config)
    config = config.to_yaml
    File.open("#{PATH}/vendor/deployer-config/config.yml", "w") do |file|
      file.write config
    end
  end

  def deployer_config_push
    exe "cd #{PATH}/vendor/deployer-config && git add config.yml && git commit -m 'aws-infra - add new stack' && git push origin master"
  end

  def deployer_config_update(domain:, stack_name:)
    deployer_config_pull
    config = deployer_config_read
    # TODO: return if config exists
    config = deployer_config_edit config, ip_vm_a: IP_VM_A, ip_vm_b: IP_VM_B, domain: domain, stack_name: stack_name
    deployer_config_write config
    deployer_config_push
  end

  def deployer_config_edit(config, ip_vm_a:,  ip_vm_b:, domain:, stack_name:)
    conf_base = DEPLOYER_CONFIG_STACK_CONF
    stack_name_base = conf_base.fetch :stack_name
    stack_name = "#{stack_name_base}_#{stack_name}".to_sym

    stack_configs = {
      stack_name: stack_name_base,
      github_repo: conf_base.fetch(:github_repo),
      branch_name: "master",
      skip_repo_build: true,
      deploy_via_tag: true,
      tag_name: "latest",
      use_env_var_file: true,
      swarm_master_ip: ip_vm_a,
      swarm_nodes_ips: [ip_vm_a, ip_vm_b],
      domain: domain,
      containers: conf_base.fetch(:containers),
    }
    config[stack_name] = stack_configs
    config
  end

end
