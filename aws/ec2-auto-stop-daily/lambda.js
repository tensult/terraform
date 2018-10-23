const AWS = require('aws-sdk');

function getEc2Regions() {
    const ec2 = new AWS.EC2({ region: 'ap-south-1' });
    return ec2.describeRegions().promise();
}

function getEc2Instances(regionName, stateName, tagKey, tagValue) {
    const ec2 = new AWS.EC2({ region: regionName });
    const filters = [];
    if (stateName) {
        filters.push({
            Name: 'instance-state-name',
            Values: [
                stateName
            ]
        });
    }
    if (tagKey && tagValue) {
        filters.push({
            Name: 'tag:' + tagKey,
            Values: [
                tagValue
            ]
        });
    }
    return ec2.describeInstances({
        Filters: filters
    }).promise();
}

function filterStoppableEc2InstanceIds(ec2Reservations) {
    return ec2Reservations.map((reservation) => {
        return reservation.Instances;
    }).reduce((allInstances, instancesInReservation) => {
        if (instancesInReservation) {
            allInstances = allInstances.concat(instancesInReservation);
        }
        return allInstances;
    }, []).filter((instance) => {
        return !instance.Tags || !instance.Tags.find((tag) => {
            return tag.Key.toLowerCase() === 'donotstop'
        });
    }).map((instance) => {
        return instance.InstanceId;
    })
}

function stopRunningEc2Instances(instanceIds, regionName) {
    const ec2 = new AWS.EC2({ region: regionName });
    return ec2.stopInstances({
        InstanceIds: instanceIds
    }).promise();
}


exports.handler = async (event) => {
    // console.log(JSON.stringify(AWS.config));
    try {
        let ec2Regions = await getEc2Regions();
        for (let i = 0; i < ec2Regions.Regions.length; i++) {
            console.log(ec2Regions.Regions[i].RegionName);
            let ec2Instances = await getEc2Instances(ec2Regions.Regions[i].RegionName, 'running');
            if (!ec2Instances.Reservations || ec2Instances.Reservations === 0) {
                continue;
            }
            let filteredRunningEc2InstanceIds = filterStoppableEc2InstanceIds(ec2Instances.Reservations);
            console.log(filteredRunningEc2InstanceIds)
            if (filteredRunningEc2InstanceIds && filteredRunningEc2InstanceIds.length) {
                let doStopRunningEc2Instances = await stopRunningEc2Instances(filteredRunningEc2InstanceIds, ec2Regions.Regions[i].RegionName);
                console.log(doStopRunningEc2Instances);
            }
        }
        return;
    } catch (err) {
        throw err;
    }
};