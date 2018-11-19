const AWS = require('aws-sdk');

const ssm = new AWS.SSM();

function getInstanceIds(event) {
    return event.detail.responseElements.instancesSet.items.map((instance) => {
        return instance.instanceId;
    });
}

function getInstanceTagsMap(event) {
    return event.detail.requestParameters.tagSpecificationSet.items.filter((tagSet) => {
        return tagSet.resourceType === "instance";
    }).map((tagSet) => {
        return tagSet.tags;
    }).reduce((tagsMap, tag) => {
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
    if(instanceTags.os_type.startsWith('AmazonLinux')) {
        return executeAutomationDocument(process.env.LAUNCH_AUTOMATION_DOCUMENT_AMAZON_LINUX. instanceIds);
    } else if(instanceTags.os_type.startsWith('RedHat')) {
        return executeAutomationDocument(process.env.LAUNCH_AUTOMATION_DOCUMENT_REDHAT_LINUX. instanceIds);
    } else if(instanceTags.os_type.startsWith('CentOS')) {
        return executeAutomationDocument(process.env.LAUNCH_AUTOMATION_DOCUMENT_CENTOS_LINUX. instanceIds);
    } else if(instanceTags.os_type.startsWith('Ubuntu')) {
        return executeAutomationDocument(process.env.LAUNCH_AUTOMATION_DOCUMENT_UBUNTU_LINUX. instanceIds);
    } else if(instanceTags.os_type.startsWith('Windows2012')) {
        return executeAutomationDocument(process.env.LAUNCH_AUTOMATION_DOCUMENT_WINDOW2012. instanceIds);
    } else if(instanceTags.os_type.startsWith('Windows2016')) {
        return executeAutomationDocument(process.env.LAUNCH_AUTOMATION_DOCUMENT_WINDOW2016. instanceIds);
    }
}

exports.handler = async (event) => {
    try {
        const instanceIds = getInstanceIds(event);
        const instanceTags = getInstanceTagsMap(event);
        await executeAutomation(instanceIds, instanceTags);
        return;
    } catch (err) {
        throw err;
    }
};