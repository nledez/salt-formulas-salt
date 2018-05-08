{%- set packages_upgrade = salt['pillar.get']('packages_upgrade', False) %}
{%- if packages_upgrade %}
  {%- set pkg_install_or_latest = 'pkg.latest' %}
{%- else %}
  {%- set pkg_install_or_latest = 'pkg.installed' %}
{%- endif %}

include:
  - .common

salt-master:
  {{ pkg_install_or_latest }}:
    - pkgs:
      - salt-master
      - salt-api
      - git
      - python-git
    - require:
      - pkgrepo: salt
  service:
    - running
    - enable: True
    - reload: False
    - require:
      - pkg: salt-master

/srv:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755

{%- for dir in ['pillar', 'salt'] %}
/srv/{{ dir }}:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755
    - require:
      - file: /srv
{%- endfor %}

/etc/salt/master.dpkg-dist:
    file.absent
