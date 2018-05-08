{% set salt_version = salt.pillar.get('salt:release', 'latest') %}

salt:
  pkgrepo.managed:
    - humanname: saltstack
    - name: deb http://repo.saltstack.com/apt/debian/9/amd64/2018.3 stretch main
    - file: /etc/apt/sources.list.d/saltstack.list
    - key_url: https://repo.saltstack.com/apt/debian/9/amd64/latest/SALTSTACK-GPG-KEY.pub
