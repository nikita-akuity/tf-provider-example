local project = std.parseYaml(importstr 'lib/project.yaml');
local envs = ['dev', 'stage', 'prod'];
local clouds = ['aws', 'azure', 'gcp'];
local prefix = '1-cluster-';
[
    project {
        metadata+: {
            name: prefix + env
        },
        spec+: {
            destinations: [{
                namespace: '%s-*' % env,
                server: 'http://cluster-%s-*:8001' % cloud,
            } for cloud in clouds ]
        }
    } for env in envs
]
