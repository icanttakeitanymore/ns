default[:ns][:zones] = {
  'east.local' => {
    'ns' => ['ns1.east.local', 'ns2.east.local'],
    'a' => [  
      ['01.pg-common.db.east.local', '120', '192.168.5.14)'],
      ['01.vault.east.local', '120', '192.168.5.11'],
      ['02.pg-common.db.east.local', '120', '192.168.5.15'],
      ['02.vault.east.local', '120', '192.168.5.12'],
      ['03.pg-common.db.east.local', '120', '192.168.5.16'],
      ['03.vault.east.local', '120', '192.168.5.13'],
      ['cinc.east.local', '3600', '192.168.5.5'],
      ['ns1.east.local', '3600', '192.168.5.2'],
      ['ns2.east.local', '3600', '192.168.5.3'],
      ['pg-common.db.east.local', '120', '192.168.5.17'],
      ['vault.east.local', '120', '10.100.0.100'],
      ['workstation.east.local', '3600', '192.168.5.1'],
    ],
  }
}