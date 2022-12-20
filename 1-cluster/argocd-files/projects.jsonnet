local project = std.parseYaml(importstr 'lib/project.yaml');
local envs = ['dev', 'stage', 'prod'];
local prefix = '1-cluster-';
[
    project {
        metadata+: {
            name: prefix + env
        },
        spec+: {
            destinations: [{
                namespace: '%s-*' % env,
                server: 'http://cluster-one:8001'
            }]
        }
    } for env in envs
]
