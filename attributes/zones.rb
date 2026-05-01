default[:ns][:zones] = {
  'east.local' => {
    'ns' => ['ns1.east.local', 'ns2.east.local'],
    'a' => [  
      ['01.pg-common.db.east.local', '120', '192.168.5.14'],
      ['02.pg-common.db.east.local', '120', '192.168.5.15'],
      ['03.pg-common.db.east.local', '120', '192.168.5.16'],
      ['pg-common.db.east.local', '120', '192.168.5.17'],
      ['01.vault.east.local', '120', '192.168.5.11'],
      ['02.vault.east.local', '120', '192.168.5.12'],
      ['03.vault.east.local', '120', '192.168.5.13'],
      ['cinc.east.local', '3600', '192.168.5.5'],
      ['ns1.east.local', '3600', '192.168.5.2'],
      ['ns2.east.local', '3600', '192.168.5.3'],

      ['vault.east.local', '120', '10.100.0.100'],
      ['workstation.east.local', '3600', '192.168.5.1'],
      ['01.cp.east.local', '120', '192.168.5.18'],
      ['02.cp.east.local', '120', '192.168.5.19'],
      ['03.cp.east.local', '120', '192.168.5.20'],
      ['01.kubelet.east.local', '120', '192.168.5.22'],
      ['02.kubelet.east.local', '120', '192.168.5.23'],
      ['03.kubelet.east.local', '120', '192.168.5.24'],
      ['01.scylla.east.local', '120', '192..168.5.25'],
      ['02.scylla.east.local', '120', '192..168.5.26'],
      ['03.scylla.east.local', '120', '192..168.5.27'],
      ['cp.east.local', '120', '192.168.5.21'],
    ],
  }
}