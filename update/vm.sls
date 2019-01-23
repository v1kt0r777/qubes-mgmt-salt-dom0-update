{% if grains['os'] == 'Debian' %}
# mitigation for DSA-4371-1 (CVE-2019-3462)
dsa-4371-update:
  cmd.script:
    - source: salt://update/dsa-4371-update
    - runas: root
    - stateful: True
{% endif %}


update:
  pkg.uptodate:
    - refresh: True
{% if grains['os'] == 'Debian' %}
    - dist_upgrade: True
    - require:
      - cmd: dsa-4371-update
{% endif %}

