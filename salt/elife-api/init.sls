elife-api-repo:
    builder.git_latest:
        - name: git@github.com:elifesciences/elife-api.git
        - identity: {{ pillar.elife.projects_builder.key or '' }}
        - rev: master
        - branch: master
        - target: /srv/elife-api/
        - force_fetch: True
        - force_checkout: True
        - force_reset: True

elife-api-dir:
    file.directory:
        - name: /srv/elife-api
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - recurse:
            - user
            - group
        - require:
            - elife-api-repo

elife-api-virtualenv:
    cmd.run:
        - user: {{ pillar.elife.deploy_user.username }}
        - name: ./install.sh
        - cwd: /srv/elife-api/
        - require:
            - file: elife-api-dir

# todo: remove once uwsgi available in elife-api/requirements.txt
elife-api-uwsgi-hack:
    cmd.run:
        - cwd: /srv/elife-api/
        - user: {{ pillar.elife.deploy_user.username }}
        - name: |
            set -e
            source venv/bin/activate
            pip install "uWSGI==2.0.17.1"
        - require:
            - elife-api-virtualenv

cfg-file:
    file.managed:
        - user: {{ pillar.elife.deploy_user.username }}
        - name: /srv/elife-api/app.cfg
        - source: 
            - salt://elife-api/config/srv-elife-api-{{ salt['elife.cfg']('project.branch', 'develop') }}.cfg
            - salt://elife-api/config/srv-elife-api-app.cfg
        - template: jinja
        - require:
            - file: elife-api-dir

collect-static:
    cmd.run:
        - user: {{ pillar.elife.deploy_user.username }}
        - cwd: /srv/elife-api/
        - name: ./manage.sh collectstatic --noinput
        - require:
            - file: cfg-file
            - cmd: elife-api-virtualenv
        - watch_in:
            - service: nginx-server-service
