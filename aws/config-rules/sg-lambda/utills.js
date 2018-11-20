
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
        padding-top: 12px;
        padding-bottom: 12px;
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




exports.prepareMailBody = prepareMailBody;
