{% from "elasticsearch/settings.sls" import elasticsearch with context %}

{%- if elasticsearch.custom_repo_url != '' %}
  {%- set repo_url = elasticsearch.custom_repo_url ~ (elasticsearch.major_version|string) ~ '.x' %}
{%- else %}
  {%- if elasticsearch.major_version >= 5 %}
    {%- set repo_url = 'https://artifacts.elastic.co/packages/' ~ (elasticsearch.major_version|string) ~ '.x' %}
  {%- else %}
    {%- set repo_url = 'http://packages.elastic.co/elasticsearch/2.x' %}
  {%- endif %}

  {%- if elasticsearch.major_version >= 5 and grains['os_family'] == 'Debian' %}
apt-transport-https:
  pkg.installed
  {%- endif %}
{%- endif %}

elasticsearch_repo:
  pkgrepo.managed:
    - humanname: Elasticsearch {{ elasticsearch.major_version }}
{%- if grains.get('os_family') == 'Debian' %}
  {%- if elasticsearch.custom_repo_url != '' %}
    - name: deb {{ repo_url }} stable main
  {%- else %}
    {%- if elasticsearch.major_version >= 5 %}
    - name: deb {{ repo_url }}/apt stable main
    {%- else %}
    - name: deb {{ repo_url }}/debian stable main
    {%- endif %}
  {%- endif %}
    - dist: stable
    - file: /etc/apt/sources.list.d/elasticsearch.list
    - clean_file: true
  {%- if elasticsearch.custom_repo_gpgkey != '' %}
    - key_url: {{ elasticsearch.custom_repo_gpgkey }}
  {%- else %}
    - keyid: D88E42B4
    - keyserver: keyserver.ubuntu.com
  {%- endif %}
{%- elif grains['os_family'] == 'RedHat' %}
    - name: elasticsearch
  {%- if elasticsearch.custom_repo_url != '' %}
    - name: deb {{ repo_url }}
  {%- else %}
    {%- if elasticsearch.major_version >= 5 %}
    - baseurl: {{ repo_url }}/yum
    {%- else %}
    - baseurl: {{ repo_url }}/centos
    {%- endif %}
  {%- endif %}
    - enabled: 1
    - gpgcheck: 1
  {%- if elasticsearch.custom_repo_gpgkey != '' %}
    - gpgkey: {{ elasticsearch.custom_repo_gpgkey }}
  {%- else %}
    - gpgkey: http://artifacts.elastic.co/GPG-KEY-elasticsearch
  {%- endif %}
{%- endif %}
