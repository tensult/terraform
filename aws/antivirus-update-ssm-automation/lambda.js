const AWS = require('aws-sdk');

const ec2 = new AWS.EC2();
const ssm = new AWS.SSM();

function getStoppedInstances() {
    return ec2.describeInstances({
        Filters: [{
                "Name": "instance-state-name",
                "Values": [
                    "stopped"
                ]
            },
            {
                "Name": "block-device-mapping.status",
                "Values": [
                    "attached"
                ]
            }
        ]
    }).promise()
}

function getInstanceIdsByPlatform(ec2DescribeInstancesResponse) {
    const windowsInstanceIds = [];
    const linuxInstanceIds = [];
    for (let reservation of ec2DescribeInstancesResponse.Reservations) {
        for (let instance of reservation.Instances) {
            if (instance.Platform === 'Windows') {
                windowsInstanceIds.push(instance.InstanceId);
            } else {
                linuxInstanceIds.push(instance.InstanceId)
            }
        }
    }
    return {
        windows: windowsInstanceIds,
        linux: linuxInstanceIds
    };
}

exports.handler = async () => {
    try {
        const stoppedInstances = await getStoppedInstances();
        const instanceIds = getInstanceIdsByPlatform(stoppedInstances);
        let ssmAutomationExecutionIds = [];
        if (instanceIds.windows && instanceIds.windows.length) {
            const execution = await ssm.startAutomationExecution({
                DocumentName: process.env.AV_UPDATE_AUTOMATION_DOCUMENT_NAME,
                Parameters: {
                    instanceIds: instanceIds.windows,
                    platform: "windows"
                }
            }).promise();
            ssmAutomationExecutionIds.put(execution.AutomationExecutionId);
        }
        if (instanceIds.linux && instanceIds.linux.length) {
            const execution = await ssm.startAutomationExecution({
                DocumentName: process.env.AV_UPDATE_AUTOMATION_DOCUMENT_NAME,
                Parameters: {
                    instanceIds: instanceIds.linux,
                    platform: "linux"
                }
            }).promise();
            ssmAutomationExecutionIds.put(execution.AutomationExecutionId);
        }
        console.log("SSMAutomationExecutionIds", ssmAutomationExecutionIds);
        return;
    } catch (err) {
        throw err;
    }
};