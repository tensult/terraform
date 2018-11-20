const AWS = require('aws-sdk');

const ssm = new AWS.SSM();
const ec2 = new AWS.EC2();


function getInstances(instanceIds) {
    return ec2.describeInstances({
        Filters: [{
            "Name": "instance-id",
            "Values": instanceIds
        }]
    }).promise()
}

function addVolumeTags(volumeIds, tags) {
    const volumeTags = tags.filter((tag) => {
        return !tag.Key.startsWith("aws:");
    });

    return ec2.createTags({
        Resources: volumeIds,
        Tags: volumeTags
    }).promise();
}

function getInstanceIds(event) {
    return event.detail.responseElements.instancesSet.items.map((instance) => {
        return instance.instanceId;
    });
}

function getVolumeIds(ec2DescribeInstancesResponse) {
    const volumeIds = [];
    for (let reservation of ec2DescribeInstancesResponse.Reservations) {
        for (let instance of reservation.Instances) {
            for (let blockDevice of instance.BlockDeviceMappings) {
                if (blockDevice.Ebs) {
                    volumeIds.push(blockDevice.Ebs.VolumeId);
                }
            }
        }
    }
    return volumeIds;
}

function getInstanceTags(ec2DescribeInstancesResponse) {
    return ec2DescribeInstancesResponse.Reservations[0].Instances[0].Tags;
}

function getInstanceTagsMap(ec2DescribeInstancesResponse) {
    return getInstanceTags(ec2DescribeInstancesResponse).reduce((tagsMap, tag) => {
        tagsMap[tag.Key] = tag.Value;
        return tagsMap;
    }, {});
}

function executeAutomationDocument(documentName, instanceIds) {
    return ssm.startAutomationExecution({
        DocumentName: documentName,
        Parameters: {
            instanceIds
        }
    }).promise()
    .then((response) => {
        console.log("AutomationExecutionId", response.AutomationExecutionId);
    });
}

function executeAutomation(instanceIds, instanceTags) {
    console.log("instanceTags", instanceTags);
    if(!instanceTags.os_type) {
        console.error("No os_type tag so ignoring automation:", instanceIds);
        return;
    }
    if (instanceTags.os_type.startsWith('AmazonLinux')) {
        return executeAutomationDocument(process.env.LAUNCH_AUTOMATION_DOCUMENT_AMAZON_LINUX, instanceIds);
    } else if (instanceTags.os_type.startsWith('RedHat')) {
        return executeAutomationDocument(process.env.LAUNCH_AUTOMATION_DOCUMENT_REDHAT_LINUX, instanceIds);
    } else if (instanceTags.os_type.startsWith('CentOS')) {
        return executeAutomationDocument(process.env.LAUNCH_AUTOMATION_DOCUMENT_CENTOS_LINUX, instanceIds);
    } else if (instanceTags.os_type.startsWith('Ubuntu')) {
        return executeAutomationDocument(process.env.LAUNCH_AUTOMATION_DOCUMENT_UBUNTU_LINUX, instanceIds);
    } else if (instanceTags.os_type.startsWith('Windows2012')) {
        return executeAutomationDocument(process.env.LAUNCH_AUTOMATION_DOCUMENT_WINDOWS_2012, instanceIds);
    } else if (instanceTags.os_type.startsWith('Windows2016')) {
        return executeAutomationDocument(process.env.LAUNCH_AUTOMATION_DOCUMENT_WINDOWS_2016, instanceIds);
    }
}

exports.handler = async (event) => {
    try {
        console.log("Received", JSON.stringify(event, null, 2));
        const instanceIds = getInstanceIds(event);
        const ec2DescribeInstancesResponse = await getInstances(instanceIds);
        const instanceTags = getInstanceTagsMap(ec2DescribeInstancesResponse);
        await executeAutomation(instanceIds, instanceTags);
        const volumeIds = getVolumeIds(ec2DescribeInstancesResponse);
        await addVolumeTags(volumeIds, getInstanceTags(ec2DescribeInstancesResponse));
        return;
    } catch (err) {
        throw err;
    }
};