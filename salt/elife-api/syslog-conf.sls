elife-api-syslog-conf:
    file.managed:
        - name: /etc/syslog-ng/conf.d/elife-api.conf
        - source: salt://elife-api/config/etc-syslog-ng-conf.d-elife-api.conf
        - template: jinja
        - require:
            - pkg: syslog-ng
        - watch_in:
            - service: syslog-ng
