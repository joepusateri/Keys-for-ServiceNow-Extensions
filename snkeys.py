#!/usr/bin/env python

import argparse
import pdpyras
import sys
import csv

# Get all services and store the EP for each

def get_extensions(session):
    escalation_policies_by_serviceid = {}
    for service in session.iter_all('services'):
        escalation_policies_by_serviceid[service['id']]=service['escalation_policy']['id']

# Get all extensions and for the SNOW ones, print out the IDs
    with sys.stdout as csvfile:
        fieldnames = ['service_name','service_id','escalation_policy_id','webhook_id']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames, extrasaction='ignore', dialect='excel', quoting=csv.QUOTE_ALL )
        writer.writeheader()
        for ext in session.iter_all('extensions'):
            # If the extension has a SNOW user defined...
            if 'snow_user' in ext['config']:
                row = {'service_name': ext['extension_objects'][0]['summary'],
                       'service_id': ext['extension_objects'][0]['id'],
                       'escalation_policy_id': escalation_policies_by_serviceid[ext['extension_objects'][0]['id']],
                       'webhook_id': ext['id']}
                writer.writerow(row)

if __name__ == '__main__':
    ap = argparse.ArgumentParser(description="Exports service id, escalation policy id and webhook id for all ServiceNow Extensions")
    ap.add_argument('-p', '--api-key', required=True, help="REST API key")
    args = ap.parse_args()
    session = pdpyras.APISession(args.api_key)
    get_extensions(session)