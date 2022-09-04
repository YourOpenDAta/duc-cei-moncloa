curl -v http://localhost:1026/v2/subscriptions -s -S -H 'Content-Type: application/json' -d @- <<EOF
{
   "description":"A subscription to get info about the WiFi sensors",
   "subject":{
      "entities":[
         {
            "id":"wifi001",
            "type":"wifi"
         }
      ],
      "condition":{
         "attrs":[
            "userid",
            "timestamp",
            "count"
         ]
      }
   },
   "notification":{
      "http":{
         "url":"http://localhost:9001/notify"
      },
      "attrs":[
         
      ]
   },
   "expires":"2040-01-01T14:00:00.00Z",
   "throttling":5
}
EOF
