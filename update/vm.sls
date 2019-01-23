{% if grains['os'] == 'Debian' %}
# mitigation for DSA-4371-1 (CVE-2019-3462)
/etc/apt/sources-dsa-4371-1.list:
  file.managed:
    - contents:
      - deb http://cdn-fastly.deb.debian.org/debian-security {{ grains['oscodename'] }}/updates main

/etc/apt/apt.conf.d/99dsa-4371-1:
  file.managed:
    - contents: |
        Dir::Etc::SourceList "/etc/apt/sources-dsa-4371-1.list";
        Dir::Etc::SourceParts "";
        Acquire::http::AllowRedirect "false";
    - require:
      - file: /etc/apt/sources-dsa-4371-1.list

{%- if grains['oscodename'] == 'stretch' %}
{%- set pkg = "libapt-pkg5.0" %}
{%- set pkgver = "1.4.9" %}
{%- elif grains['oscodename'] == 'jessie' %}
{%- set pkg = "libapt-pkg4.12" %}
{%- set pkgver = "1.0.9.8.5" %}
{%- else %}
# sid, buster, unknown
{%- set pkg = "libapt-pkg5.0" %}
{%- set pkgver = "1.8.0~alpha3.1" %}
{%- endif %}

{{pkg}}:
  pkg.installed:
    - version: {{pkgver}}
    - refresh: True
    - allow_updates: True
    - require:
      - file: /etc/apt/apt.conf.d/99dsa-4371-1

# remove the config after, but only if update was successful
# avoid file.missing as it would have the same name as the state creating the
# file
rm -f /etc/apt/apt.conf.d/99dsa-4371-1:
  cmd.run:
    - require:
      - pkg: {{pkg}}
{% endif %}


update:
  pkg.uptodate:
    - refresh: True
{% if grains['os'] == 'Debian' %}
    - dist_upgrade: True
    - require:
      - pkg: {{pkg}}
{% endif %}

