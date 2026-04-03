#!/usr/bin/env python3
import aws_cdk as cdk

from stacks.sg_alert_stack import SgAlertStack

app = cdk.App()
SgAlertStack(app, "AgrSgAlertStack",
    env=cdk.Environment(account="100225593120", region="us-east-1"),
)

app.synth()
