elife-api-nginx-conf:
    file.managed:
        - name: /etc/nginx/sites-enabled/elife-api.conf
        - template: jinja
        - source: salt://elife-api/config/etc-nginx-sitesenabled-elifeapi-https.conf

elife-api-uwsgi-conf:
    file.managed:
        - name: /srv/elife-api/uwsgi.ini
        - source: salt://elife-api/config/srv-elifeapi-uwsgi.ini
        - template: jinja
        - require:
            - elife-api-repo

{% if salt['grains.get']('osrelease') == "14.04" %}

# v.old
elife-api-init-script:
    file.managed:
        - name: /etc/init.d/elife-api-uwsgi
        - source: salt://elife-api/config/etc-init.d-elife-api-uwsgi
        - mode: 755
        - require_in:
            - service: elife-api-uwsgi

{% else %}

uwsgi-elife-api.socket:
    service.running:
        - enable: True
        - require:
            - file: uwsgi-socket-elife-api # builder-base-formula.uwsgi
        - require_in:
            - service: elife-api-uwsgi

{% endif %}

elife-api-uwsgi:
    service.running:
        - enable: True
        - require:
            - file: elife-api-uwsgi-conf
            - file: uwsgi-params # builder-base-formula/salt/elife/uwsgi-params.sls (included by uwsgi.sls)
            - uwsgi-pkg # no longer installs uwsgi globally since 16.04+
        - watch:
            - service: nginx-server-service

