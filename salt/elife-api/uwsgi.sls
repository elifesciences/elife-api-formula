elife-api-nginx-conf:
    file.managed:
        - name: /etc/nginx/sites-enabled/elife-api.conf
        - template: jinja
{% if pillar.elife.env == 'dev' %}
        - source: salt://elife-api/config/etc-nginx-sitesavailable-elifeapi-http.conf
{% else %}
        - source: salt://elife-api/config/etc-nginx-sitesavailable-elifeapi-https.conf
        - require:
            - git: elife-api-repo
            - cmd: acme-fetch-certs
{% endif %}

elife-api-uwsgi-conf:
    file.managed:
        - name: /srv/elife-api/uwsgi.ini
        - source: salt://elife-api/config/srv-elifeapi-uwsgi.ini
        - template: jinja
        - require:
            - git: elife-api-repo
            
elife-api-uwsgi:
    file.managed:
        - name: /etc/init.d/elife-api-uwsgi
        - source: salt://elife-api/config/etc-init.d-elife-api-uwsgi
        - mode: 755

    service.running:
        - enable: True
        - require:
            - file: elife-api-uwsgi
            - file: elife-api-uwsgi-conf
            - file: uwsgi-params
            - pip: uwsgi-pkg
        - watch:
            - service: nginx-server-service

