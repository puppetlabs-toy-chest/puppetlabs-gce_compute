gce_httphealthcheck { 'basic-http-check':
    ensure       => absent,
}
gce_targetpool { 'www-pool':
    ensure       => absent,
    region       => 'us-central1',
}
gce_forwardingrule { 'www-rule':
    ensure       => absent,
    region       => 'us-central1',
}
Gce_forwardingrule['www-rule'] -> Gce_targetpool['www-pool']
Gce_targetpool['www-pool'] -> Gce_httphealthcheck['basic-http-check']
