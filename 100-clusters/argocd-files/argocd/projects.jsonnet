local project = std.parseYaml(importstr 'lib/project.yaml');
local envs = ['dev', 'stage', 'prod', 'preview'];
local prefix = '100-clusters-';
[
    project {
        metadata+: {
            name: prefix + env
        },
        spec+: {
            destinations: [{
                namespace: 'akuity-%s-*' % env,
                server: 'http://cluster-%s-*' % env
            }]
        }
    } for env in envs
]
