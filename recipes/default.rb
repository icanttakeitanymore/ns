include_recipe 'common'

secret_conf = openbao.read(node['ns']['secret']['path'], node['ns']['secret']['mount'])

%w(
  pdns-server
  pdns-backend-pgsql
  pdns-recursor
).each do |pkg|
  package pkg do
    action :install
  end
end

execute 'pdns-check-config' do
  command 'pdns_server --config=check'
  action :nothing
  notifies :restart, 'service[pdns]', :delayed
end

bao_pki_cert 'pdns' do
  role node['ns']['pki']['role']
  cn 'pdns'
  mount node['ns']['pki']['mount']
  mode '0600'
  owner 'pdns'
  issuing_ca '/etc/powerdns/pg_ca.pem'
  certificate '/etc/powerdns/pg_cert.pem'
  private_key '/etc/powerdns/pg_cert_key.pem'
  notifies :restart, 'service[pdns]', :delayed
end

template '/etc/powerdns/pdns.conf' do
  source 'pdns.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
  variables(
    root_apikey: secret_conf[:root_apikey]
  )
  notifies :run, 'execute[pdns-check-config]', :immediately

end

service 'pdns' do
  action [:enable, :start]
end

execute 'pdns-recursor-check-config' do
  command 'pdns_recursor --config=check'
  action :nothing
  notifies :restart, 'service[pdns-recursor]', :delayed
end

template '/etc/powerdns/recursor.conf' do
  source 'recursor.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
  notifies :run, 'execute[pdns-recursor-check-config]', :immediately
end

directory '/etc/systemd/system/pdns-recursor.service.d' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

file '/etc/systemd/system/pdns-recursor.service.d/override.conf' do
  content <<~EOF
    [Unit]
    After=pdns.service
    Wants=pdns.service
  EOF

  owner 'root'
  group 'root'
  mode '0644'

  notifies :run, 'execute[systemctl-daemon-reload]', :immediately
end

execute 'systemctl-daemon-reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

service 'pdns-recursor' do
  action [:enable, :start]
end


node['ns']['zones'].each do |zone_name, data|
  ns_zone_config zone_name do
    records data
    api_key secret_conf[:root_apikey]
    action :update
  end
end
