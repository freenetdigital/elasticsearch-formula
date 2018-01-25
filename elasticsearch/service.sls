include:
  - elasticsearch.pkg
  - elasticsearch.config
  - elasticsearch.systemd

elasticsearch_service:
  service.running:
    - name: elasticsearch
    - enable: True
{%- if salt['pillar.get']('elasticsearch:config') %}
    - watch:
      - file: elasticsearch_cfg
      - file: /etc/systemd/system/elasticsearch.service.d/elasticsearch.conf
{%- endif %}
    - require:
      - pkg: elasticsearch
