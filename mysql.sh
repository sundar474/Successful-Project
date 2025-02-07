#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
   if [ $1 -ne 0 ]
   then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access."
    exit 1 # manually exit if error comes.
else
    echo "You are super user."
fi

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing MySQL Server"     

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling MySQL server"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting MySQL Server"

# Secure MySQL installation with root password
mysql_secure_installation --set-root-pass RoboShop@1 <<EOF
RoboShop@1
EOF
VALIDATE $? "Securing MySQL Installation"

# Login to MySQL and execute commands without manual password entry
echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'RoboShop@1';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;" | sudo mysql -u root -pRoboShop@1 &>>$LOGFILE
VALIDATE $? "Configuring MySQL User Permissions"

# Restart MySQL service
systemctl restart mysqld &>>$LOGFILE
VALIDATE $? "Restarting MySQL Server"

echo "MySQL setup completed successfully."
