#!/bin/bash

# Địa chỉ bucket S3
s3_bucket_list=("s3://mutosi-airbyte-backup" "s3://mutosi-gitlab-backup" "s3://mutosi-harbor-prods" "s3://mutosi-metabase-backup" "s3://mutosi-uptime-kuma-backup" "s3://mutosi-zabbix-backup" "s3://mutosi-jenkins-backup")
#s3_bucket="s3://mutosi-airbyte-backup"

# Tính thời gian cách đây 7 ngày (604800 giây)
seven_days_ago=$(date -d "7 days ago" +%s)
#echo $seven_days_ago


# lặp qua danh sách bucket để duyệt các file và xóa các file tạo quá 7 ngày
for s3_bucket in "${s3_bucket_list[@]}"; do
   # Danh sách tệp trong bucket
   s3_files=$(s3cmd ls "$s3_bucket")

   echo "$(date '+%Y-%m-%d %H:%M:%S') -- starting --"  >> /opt/script-delete-file-on-s3/script.logs
   # Lặp qua từng dòng trong danh sách tệp
   while IFS= read -r line; do
     # Lấy tên tệp và thời gian tạo
     file_name=$(echo "$line" | awk '{print $4}')
     creation_date=$(echo "$line" | awk '{print $1, $2}')
     # Chuyển đổi thời gian tạo thành định dạng số giây từ epoch
     creation_timestamp=$(date -d "$creation_date" +%s)
     # Kiểm tra nếu tệp có định dạng yyyy-mm-dd.zip và tạo lâu hơn 7 ngày

     #if [[ $file_name =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}\.zip$ ]] && (( creation_timestamp < seven_days_ago )); then
     if (( creation_timestamp < seven_days_ago )); then
        #echo $file_name
        # Xóa tệp
        s3cmd rm "$s3_bucket/$file_name"
        s3cmd rm $file_name
        echo "$(date +'%Y-%m-%d %H:%M:%S'): remove file zip: $file_name --> done" >> /opt/script-delete-file-on-s3/script.logs
     fi
   done <<< $s3_files
done
echo "$(date '+%Y-%m-%d %H:%M:%S') -- done --"  >> /opt/script-delete-file-on-s3/script.logs
