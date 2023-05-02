while true
do
    timestamp=$(shuf -i 1-100000000 -n 1)
    temp=$(shuf -i 18-53 -n 1)
    number=$(shuf -i 1-3113 -n 1)
    wifi=$(shuf -i 1-9 -n 1)
    echo "Updating entity"

    curl localhost:1026/v2/entities/wifi001/attrs -s -S -H 'Content-Type: application/json' -X PATCH -d '{
      "userid": {
        "value": "68:17:29:9A:7F:7'$wifi'",
        "type": "Property"
      },
      "timestamp":{
         "value":"2023'$timestamp'",
         "type":"Property"
      },
      "visits":{
         "value":"'$number'",
         "type":"Property"
      },
      "count":{
         "value":"'$number'",
         "type":"Property"
      }
    }'
    sleep 1
done