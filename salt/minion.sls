{%- set packages_upgrade = salt['pillar.get']('packages_upgrade', False) %}
{%- if packages_upgrade %}
  {%- set pkg_install_or_latest = 'pkg.latest' %}
{%- else %}
  {%- set pkg_install_or_latest = 'pkg.installed' %}
{%- endif %}

{%- set salt_master = salt['pillar.get']('salt:minion:master', 'salt') %}

include:
  - .common

salt-minion:
  {{ pkg_install_or_latest }}:
    - pkgs:
      - salt-minion
    - require:
      - pkgrepo: salt
  service:
    - running
    - enable: True
    - reload: False
    - require:
      - pkg: salt-minion

/etc/salt/minion:
    file.managed:
        - user: root
        - group: root
        - mode: '0400'
        - contents: ''
        - contents_newline: False
        - require:
          - pkg: salt-minion
        - watch_in:
          - service: salt-minion

/etc/salt/minion.d/master.conf:
    file.managed:
        - user: root
        - group: root
        - mode: '0400'
        - contents: 'master: {{ salt_master }}'
        - template: jinja
        - context:
          salt_master: {{ salt_master }}
        - require:
          - pkg: salt-minion
        - watch_in:
          - service: salt-minion

/etc/salt/minion.dpkg-dist:
    file.absent
