import json
import os

cookbooks_dir_path = os.path.join(os.path.dirname(__file__), 'cookbooks')


def resolve_version(file_content):
    for line in file_content:
        if line.startswith('version '):
            start_index = line.find('\'') + 1
            end_index = line.find('\'', start_index)
            return line[start_index:end_index]


name_version_mapping = {}
for dir_name in os.listdir(cookbooks_dir_path):
    with open(
            os.path.join(cookbooks_dir_path, dir_name, 'metadata.rb')) as file:
        file_content = file.readlines()
    version = resolve_version(file_content=file_content)
    name_version_mapping.update({dir_name: version})

environments_dir_path = os.path.join(os.path.dirname(__file__), 'environments')
for file in os.listdir(environments_dir_path):
    with open(os.path.join(environments_dir_path, file)) as json_file:
        json_content = json.load(json_file)

    for service, version in name_version_mapping.items():
        if service not in json_content['cookbook_versions']:
            print(f'Service {service} version not exists in {file}')
        elif version not in json_content['cookbook_versions'][service]:
            print(f'Service {service} {version} version does not match to '
                  f'{json_content["cookbook_versions"][service]} in {file}')
