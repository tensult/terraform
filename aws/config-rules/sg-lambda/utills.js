

const securityGroupMailBody = (resourceObject)=>{
    return `<!DOCTYPE html>
    <html>
    <body>
    <p><font size="+2"></font>Dear User,</font></p>
    <font size="+3" color="red">Attention:</font> This is to inform you that the port you have opened does not meet the security compliance standard followed by ${process.env.company_name}. The resource details are attached below.
    <p><font size="+1">Security Group Details:</font></p>
    </body>
    </html>
    ${prepareMailBody(resourceObject)} 
    <p><font size="+1">Note:</font></p>  
    1. Security Group is the firewall of your instance, opening ports unnecessarily can compromise the security.<br>
    2. Please reach out to CIO Team to make changes to the security group(s), if necessary.
    <p><font size="+1">Have a great day!</font></p>
    </body></html>`
}

function prepareHtml(table, headers) {
    let htmlBody = ``
    headers.forEach((header) => {
        htmlBody = header ? htmlBody + `<th>${header}</th>` : htmlBody;
    })
    htmlBody = "<tr>" + htmlBody + "</tr>"
    return `<!DOCTYPE html><html><style>
    #customers {
        font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
        border-collapse: collapse;
        width: 100%;
    }
    #customers td, #customers th {
        border: 1px solid #ddd;
        padding: 8px;
    }
    #customers tr:nth-child(even){background-color: #f2f2f2;}
    #customers tr:hover {background-color: #ddd;}
    #customers th {
        padding-top: 8px;
        padding-bottom: 8px;
        text-align: left;
        background-color: #4CAF50;
        color: white;
    }
    </style>
    <body><table id="customers"> ${htmlBody}${table}</table> </body></html>`
}



function prepareMailBody(instances) {
    let htmlTable = ``;
    let headers = Object.keys(instances[0]);
    instances.forEach((instance) => {
        const instanceElements = Object.keys(instance);
        instanceElements.forEach((element) => {
            htmlTable = instance[element] ? htmlTable + `<td>${instance[element]}</td>` : htmlTable + `<td>Not Mentioned</td>`;
        })
        htmlTable = '<tr>' + htmlTable + '</tr>';
    });
    return prepareHtml(htmlTable, headers);
}


exports.securityGroupMailBody = securityGroupMailBody;
