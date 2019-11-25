import argparse
import json
import requests
import sys
from copy import deepcopy
try:
    from urllib.parse import urlparse, urljoin
except:
    from urlparse import urlparse, urljoin

GROUPS_ENDPOINT = "/api/groups/"
PROJECTS_ENDPOINT = "/api/projects/"
BACKENDS_ENDPOINT = "/api/backends/"


def find_or_create(url, object_dict, headers):
    modified_object_dict = deepcopy(object_dict)
    if "group" in object_dict.keys():
        group = modified_object_dict["group"].split("/")[-2]
        modified_object_dict["group"] = group
    obj_response = requests.get(url, params=modified_object_dict, headers=headers)
    obj = None
    if obj_response.status_code == 200:
        if obj_response.json()['count'] == 1:
            return obj_response.json()['results'][0]['url']
        else:
            obj_response2 = requests.post(url, json=object_dict, headers=headers)
            if obj_response2.status_code == 201:
                return obj_response2.json()['url']
            else:
                print(obj_response2.text)
    return None


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-t",
                        "--token",
                        help="Token used for authorization",
                        required=True,
                        dest="token")
    parser.add_argument("-v",
                        "--debug",
                        action="store_true",
                        default=False,
                        help="Enable debug",
                        dest="debug")
    parser.add_argument("-u",
                        "--url",
                        help="SQUAD instance URL",
                        required=True,
                        dest="url")
    parser.add_argument("-l",
                        "--group",
                        help="Group name",
                        required=True,
                        dest="group_name")
    parser.add_argument("-w",
                        "--project",
                        help="Project name",
                        required=True,
                        dest="project_name")

    args = parser.parse_args()

    headers = {
        "Authorization": "Token %s" % args.token
    }

    # create SQUAD group
    group_url = urljoin(args.url, GROUPS_ENDPOINT)
    group_data = {
        "name": args.group_name,
        "slug": args.group_name,
        "description": args.group_name + " group"}
    group = find_or_create(group_url, group_data, headers)
    if group is None:
        print("Group not created")
        sys.exit(1)

    # create SQUAD project
    project_url = urljoin(args.url, PROJECTS_ENDPOINT)
    project_data = {
        "name": args.project_name,
        "slug": args.project_name,
        "description": args.project_name + " project",
        "group": group,
        "is_public": True,
		"enabled_plugins_list": [],
        "wait_before_notification": 120,
        "notification_timeout": 300,
        "moderate_notifications": False,
        "html_mail": True}
    project = find_or_create(project_url, project_data, headers)
    if project is None:
        print("Project not created")
        sys.exit(1)

if __name__ == "__main__":
    main()
