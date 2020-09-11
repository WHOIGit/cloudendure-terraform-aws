import requests
import json
import os
import time
import sys

HOST = 'https://console.cloudendure.com'
endpoint = '/api/latest/{}'
user_api_token = os.environ['USER_API_TOKEN']

def lambda_handler(event, context):
    print(event)
    source_machine_name = event['source_machine_name']
    print(source_machine_name)
    session = requests.Session()
    session.headers.update({'Content-type': 'application/json', 'Accept': 'text/plain'})

    # Login to CloudEndure with API Token, create requests Session()
    login_data = {'userApiToken': user_api_token}
    resp = session.post(HOST + endpoint.format('login'), data = json.dumps(login_data))
    print(resp.status_code)
    if resp.status_code != 200 and resp.status_code != 307:
        print ("Bad login credentials")
        sys.exit()
    # Update session headers with response cookie
    session.headers.update({'X-XSRF-TOKEN' : resp.cookies['XSRF-TOKEN']})

    # Fetch the CloudEndure project ID in order to locate the machine itself
    projects_resp = session.get(HOST + endpoint.format('projects'))
    projects = json.loads(projects_resp.content)['items']

    project_id = None
    machine_id = None

    # Fetch the CloudEndure machine ID in order monitor the replication progress and launch the target server
    print ('Getting machine id...')
    for project in projects:
        project_id = project['id']
        print(project_id )

        machines_resp = session.get(url=HOST+endpoint.format('projects/{}/machines').format(project_id))
        machines = json.loads(machines_resp.content)['items']

        machine_id = [m['id'] for m in machines if source_machine_name.lower() == m['sourceProperties']['name'].lower()]

        if machine_id:
            print( machine_id[0])
            break

    if not machine_id:
        print(F'Error! No agent with name {source_machine_name} found')
        sys.exit()

    items = {'machineId': machine_id[0]}
    payload = {'items': [items], 'launchType': 'TEST'}
    print('Launching target server')
    launch_resp = session.post(url=HOST+endpoint.format('projects/{}/launchMachines').format(project_id), data=json.dumps(payload))
    if launch_resp.status_code != 202:
        print ('Error creating target machine!')
        print ('Status code is: ', launch_resp.status_code)
        sys.exit()

    print('Target server creation completed!')

    return {
        'statusCode': 200,
    }
