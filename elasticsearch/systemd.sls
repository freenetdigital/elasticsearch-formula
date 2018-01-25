{%- if grains.get('init') == 'systemd' %}

{% from "elasticsearch/map.jinja" import elasticsearch_map with context %}

{%- if elasticsearch_map.config['bootstrap.memory_lock'] or elasticsearch_map.config['bootstrap.mlockall'] %}
/etc/systemd/system/elasticsearch.service.d/elasticsearch.conf:
  file.managed:
    - makedirs: True

memlock_systemd_configuration:
  ini.options_present:
    - name: /etc/systemd/system/elasticsearch.service.d/elasticsearch.conf
    - separator: '='
    - strict: True
    - sections:
        Service:
          LimitMEMLOCK: 'infinity'
    - require:
      - file: /etc/systemd/system/elasticsearch.service.d/elasticsearch.conf
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: /etc/systemd/system/elasticsearch.service.d/elasticsearch.conf
{%- endif %}
{%- endif %}
