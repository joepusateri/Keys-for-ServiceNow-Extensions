snkeys.pl
===============

snkeys.pl uses a PagerDuty V2 API token to query the environment for all extensions
that are related to ServiceNow and returns the Service ID, Escalation Policy ID and
Webhook ID for that extension

In ServiceNow, a mapping is created between Assignment Groups and a combination of
Escalation Policy, Service and Webhook.

In the ServiceNow integration version 5 and up, the mapping could exist between
Assignment Groups and Escalation Policies AND Configuration Items and a combination
of Service and Webhook.

In the case where a ServiceNow Assignment Group needs to be manually mapped to an
existing PagerDuty Escalation Policy, the IDs have to be looked up in PagerDuty.

This handy script will output a CSV with all the right IDs for each Extension.

It works only with PagerDuty's V2 API token

    ./snkeys.pl -p <V2 API token>
