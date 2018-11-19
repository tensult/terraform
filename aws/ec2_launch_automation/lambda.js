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
    return ec2.createTags({
        Resources: volumeIds,
        Tags: tags
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
            for(let blockDevice of instance.BlockDeviceMappings) {
                if(blockDevice.Ebs) {
                    volumeIds.push(blockDevice.Ebs.VolumeId);
                }
            }
        }
    }
    return volumeIds;
}

function getInstanceTags(event) {
    return event.detail.requestParameters.tagSpecificationSet.items.filter((tagSet) => {
        return tagSet.resourceType === "instance";
    }).map((tagSet) => {
        return tagSet.tags;
    });
}

function getInstanceTagsMap(event) {
    getInstanceTags(event).reduce((tagsMap, tag) => {
        tagsMap[tag.key] = tag.value;
        return tagsMap;
    }, {});
}

function executeAutomationDocument(documentName, instanceIds) {
    return ssm.startAutomationExecution({
        DocumentName: documentName,
        Parameters: {
            instanceIds
        }
    }).promise();
}

function executeAutomation(instanceTags, instanceIds) {
    if (instanceTags.os_type.startsWith('AmazonLinux')) {
        return executeAutomationDocument(process.env.LAUNCH_AUTOMATION_DOCUMENT_AMAZON_LINUX, instanceIds);
    } else if (instanceTags.os_type.startsWith('RedHat')) {
        return executeAutomationDocument(process.env.LAUNCH_AUTOMATION_DOCUMENT_REDHAT_LINUX, instanceIds);
    } else if (instanceTags.os_type.startsWith('CentOS')) {
        return executeAutomationDocument(process.env.LAUNCH_AUTOMATION_DOCUMENT_CENTOS_LINUX, instanceIds);
    } else if (instanceTags.os_type.startsWith('Ubuntu')) {
        return executeAutomationDocument(process.env.LAUNCH_AUTOMATION_DOCUMENT_UBUNTU_LINUX, instanceIds);
    } else if (instanceTags.os_type.startsWith('Windows2012')) {
        return executeAutomationDocument(process.env.LAUNCH_AUTOMATION_DOCUMENT_WINDOW2012, instanceIds);
    } else if (instanceTags.os_type.startsWith('Windows2016')) {
        return executeAutomationDocument(process.env.LAUNCH_AUTOMATION_DOCUMENT_WINDOW2016, instanceIds);
    }
}

exports.handler = async (event) => {
    try {
        const instanceIds = getInstanceIds(event);
        const instanceTags = getInstanceTagsMap(event);
        await executeAutomation(instanceIds, instanceTags);
        const ec2DescribeInstancesResponse = await getInstances(instanceIds);
        const volumeIds = getVolumeIds(ec2DescribeInstancesResponse);
        await addVolumeTags(volumeIds, getInstanceTags(event));
        return;
    } catch (err) {
        throw err;
    }
};