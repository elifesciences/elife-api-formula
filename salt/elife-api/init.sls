elife-api-repo:
    git.latest:
        - name: https://github.com/elifesciences/elife-api.git
        - target: /srv/elife-api/
        - rev: {{ salt['elife.cfg']('project.branch', 'master') }}
        - branch: {{ salt['elife.cfg']('project.branch', 'master') }}
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
            - git: elife-api-repo

elife-api-virtualenv:
    virtualenv.managed:
        - user: {{ pillar.elife.deploy_user.username }}
        - name: /srv/elife-api/venv/
        - cwd: /srv/elife-api/
        - requirements: /srv/elife-api/requirements.txt
        - require:
            - file: elife-api-dir

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
        - name: ./manage.sh collectstatic --noinput'
        - require:
            - file: cfg-file
            - virtualenv: elife-api-virtualenv
        - watch_in:
            - service: nginx-server-service
