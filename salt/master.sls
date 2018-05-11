{% from "salt/map.jinja" import salt_settings with context %}

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
  file.recurse:
    - name: {{ salt_settings.config_path }}/master.d
    - template: jinja
    - user: root
    - group: root
    - file_mode: 644
    - source: salt://{{ slspath }}/files/master.d
    - clean: {{ salt_settings.clean_config_d_dir }}
    - exclude_pat: _*
  service:
    - running
    - enable: True
    - reload: False
    - require:
      - pkg: salt-master
    - watch:
      - file: salt-master

/srv/:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755

{%- for dir in ['pillar', 'salt', 'reactor', '_scripts'] %}
/srv/{{ dir }}/:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755
    - require:
      - file: /srv/
{%- endfor %}

/srv/reactor/{files}:
  file.recurse:
    - name: /srv/reactor
    - user: root
    - group: root
    - file_mode: 644
    - template: jinja
    - source: salt://{{ slspath }}/files/reactor
    - exclude_pat: _*
    - require:
      - file: /srv/reactor/

/srv/_scripts/{files}:
  file.recurse:
    - name: /srv/_scripts
    - user: root
    - group: root
    - file_mode: 755
    - template: jinja
    - source: salt://{{ slspath }}/files/_scripts
    - exclude_pat: _*
    - require:
      - file: /srv/_scripts/

/etc/salt/master.dpkg-dist:
    file.absent
