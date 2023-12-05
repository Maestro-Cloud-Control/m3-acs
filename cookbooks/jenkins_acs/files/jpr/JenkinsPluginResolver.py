from urllib.request import urlopen
import json, sys

uc_url = ''
uc_fallback_url = 'https://updates.jenkins-ci.org/current/update-center.json'

class JenkinsPluginResolver(object):
    def __init__(self):
        self._plugins = dict()
        self._uc_post = self._load_update_center_post()
        self._load_update_center_post()

    def _load_update_center_post(self):
        try:
            raw = urlopen(uc_url).read().decode("utf-8")
            raw = raw.replace('updates.jenkins-ci.org', 'a')
        except:
            print('Falling back to updates.jenkins-ci.org')
            raw = urlopen(uc_fallback_url).read().decode("utf-8")
        fixed = raw.lstrip('updateCenter.post(').rstrip('\n);')
        return json.loads(fixed)

    def clear(self):
        self._plugins = dict()

    def uc_post(self):
        return self._uc_post

    def dump(self):
        return self._plugins

    def load(self, plugin, version='latest', optional=False):
        if plugin not in self._plugins:
            try:
                dependencies = self._uc_post['plugins'][plugin]['dependencies']
            except KeyError:
                if optional:
                    print("Optional plugin '%s' not found in the " \
                        "Update Center" % plugin)
                    return
                else:
                    raise RuntimeError(
                        "plugin '%s' doesn't exist in the Update Center"
                        % plugin)
            if version == 'latest':
                self._plugins[plugin] = \
                    self._uc_post['plugins'][plugin]['version']
            else:
                self._plugins[plugin] = version
            for dependency in dependencies:
                self.load(plugin=dependency['name'],
                          optional=dependency['optional'])
        elif version != 'latest':
            self._plugins[plugin] = version

    def contingent(self, plugin):
        for p_name, p_data in self._uc_post['plugins'].items():
            for dep in p_data['dependencies']:
                if plugin == dep['name']:
                    print(p_name)
