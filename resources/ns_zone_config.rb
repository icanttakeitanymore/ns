resource_name :ns_zone_config
provides :ns_zone_config

property :zone_name, String, name_property: true
property :records, Hash, required: true
property :api_url, String, default: 'http://127.0.0.1:8081/api/v1/servers/localhost/zones'
property :api_key, String, sensitive: true, required: true

action :update do
  require 'json'
  require 'net/http'

  # 1. Prepare desired RRsets from attributes
  desired_rrsets = []
  new_resource.records['a'].each do |name, ttl, ip|
    # Ensure FQDN ends with a dot as required by PDNS API
    fqdn = name.end_with?('.') ? name : "#{name}."
    # Sanitize IP (handles the closing parenthesis typo in your attributes)
    clean_ip = ip.to_s.delete(')')

    desired_rrsets << {
      "name" => fqdn,
      "type" => "A",
      "ttl" => ttl.to_i,
      "changetype" => "REPLACE",
      "records" => [
        { "content" => clean_ip, "disabled" => false }
      ]
    }
  end

  # 2. Fetch current state from API
  uri = URI("#{new_resource.api_url}/#{new_resource.zone_name}")
  http = Net::HTTP.new(uri.host, uri.port)
  
  get_request = Net::HTTP::Get.new(uri.path, { 'X-API-Key' => new_resource.api_key })
  
  begin
    response = http.request(get_request)
    
    if response.code == '200'
      current_zone_data = JSON.parse(response.body)
      current_rrsets = current_zone_data['rrsets']
      
      # Compare desired vs current to find delta
      to_update = desired_rrsets.select do |desired|
        current = current_rrsets.find { |r| r['name'] == desired['name'] && r['type'] == desired['type'] }
        
        # Condition: record missing, TTL mismatch, or IP mismatch
        current.nil? || 
        current['ttl'] != desired['ttl'] || 
        current['records'][0]['content'] != desired['records'][0]['content']
      end

      if to_update.empty?
        Chef::Log.debug("Zone #{new_resource.zone_name} is up to date.")
      else
        # 3. Apply only the changed records
        updated_names = to_update.map { |r| r['name'] }.join(', ')
        
        converge_by("update DNS records in zone #{new_resource.zone_name}: #{updated_names}") do
          patch_request = Net::HTTP::Patch.new(uri.path, {
            'X-API-Key' => new_resource.api_key,
            'Content-Type' => 'application/json'
          })
          patch_request.body = { "rrsets" => to_update }.to_json
          
          patch_response = http.request(patch_request)
          unless patch_response.code.to_i == 204
            raise "PowerDNS API error during update: #{patch_response.body}"
          end
        end
      end
    elsif response.code == '404'
      Chef::Log.error("Zone #{new_resource.zone_name} not found. Ensure the zone is created before managing records.")
    else
      Chef::Log.error("Unexpected PDNS API response: #{response.code} - #{response.body}")
    end
  rescue StandardError => e
    Chef::Log.error("Failed to connect to PowerDNS API: #{e.message}")
  end
end