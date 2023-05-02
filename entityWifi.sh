curl http://localhost:1026/v2/entities -s -S -H 'Content-Type: application/json' -d @- <<EOF
{
      "id":"wifi001",
      "type":"wifi",
      
      "timestamp":{
         "value":"20220828132150",
         "type":"Property"
      },
      "userid":{
         "value":"ED:94:F6:FD:DD:A3",
         "type":"Property"
      },
      "count":{
         "value":3,
         "type":"Property"
      },
      "minact":{
         "value":"101001011100011",
         "type":"Property"
      },
      "tseen":{
         "value":900,
         "type":"Property"
      },
      "tacum":{
         "value":47700,
         "type":"Property"
      },
      "visits":{
         "value":1,
         "type":"Property"
      },
      "act24h":{
         "value":96,
         "type":"Property"
      },
      "pwr":{
         "value":-87,
         "type":"Property"
      },
      "oui":{
         "value":"canon",
         "type":"Property"
      },
      "ap":{
         "value":"EF:94:F6:3D:DD:A2",
         "type":"Property"
      },
      "essid":{
         "value":"TP-LINK_3DD0A2",
         "type":"Property"
      },
      "apwr":{
         "value":-9,
         "type":"Property"
      }
   }
EOF
