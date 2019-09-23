elife-api-nginx-conf:
    file.managed:
        - name: /etc/nginx/sites-enabled/elife-api.conf
        - template: jinja
        - source: salt://elife-api/config/etc-nginx-sitesenabled-elifeapi-https.conf
        - require:
            - file: uwsgi-params # builder-base-formula/salt/elife/uwsgi-params.sls (included by uwsgi.sls)
            - pkg: nginx-server
            - cmd: web-ssl-enabled
        - watch_in:
            - nginx-server-service

elife-api-uwsgi-conf:
    file.managed:
        - name: /srv/elife-api/uwsgi.ini
        - source: salt://elife-api/config/srv-elifeapi-uwsgi.ini
        - template: jinja
        - require:
            - elife-api-repo

{% if salt['grains.get']('osrelease') == "14.04" %}

# 12.04, obsolete
elife-api-init-script:
    file.managed:
        - name: /etc/init.d/elife-api-uwsgi
        - source: salt://elife-api/config/etc-init.d-elife-api-uwsgi
        - mode: 755
        - require_in:
            - service: elife-api-uwsgi

{% else %}

elife-api-init-script:
    file.absent:
        - name: /etc/init.d/elife-api-uwsgi

uwsgi-elife-api.socket:
    service.running:
        - enable: True
        - require:
            - file: uwsgi-socket-elife-api # builder-base-formula.uwsgi
        - require_in:
            - service: uwsgi-elife-api

{% endif %}

uwsgi-elife-api:
    service.running:
        - enable: True
        - require:
            {% if salt['grains.get']('osrelease') != "14.04" %}
            - file: uwsgi-service-elife-api # builder-base-formula.uwsgi
            {% endif %}
            - file: elife-api-init-script
            - file: elife-api-uwsgi-conf
            - file: elife-api-nginx-conf
            - uwsgi-pkg # no longer installs uwsgi globally since 16.04+
        - watch:
            - elife-api-repo
            - service: nginx-server-service

