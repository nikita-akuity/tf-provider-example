local project = std.parseYaml(importstr 'lib/project.yaml');
local envs = ['dev', 'stage', 'prod', 'preview'];
[
    project {
        metadata+: {
            name: env
        },
        spec+: {
            destinations: [{
                namespace: 'akuity-%s-*' % env,
                server: 'http://cluster-%s-*' % env
            }]
        }
    } for env in envs
]
