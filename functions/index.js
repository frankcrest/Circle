const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
    //var badgeCount = 1;
exports.sendNotification = functions.database.ref('/Notifications/Messages/{pushId}').onWrite((change,context) => {
    console.log('Push notification event triggered for testing');
    console.log(change);
    const message = change.after.val();
    const senderUid = message.Sender;
    const receiverUid = message.SendTo;
    const chatMessage = message.Message;
    const senderName = message.SenderName;
    console.log(receiverUid);
    const promises = [];

    console.log('notifying ' + receiverUid + ' about ' + chatMessage + ' from ' + senderUid);

        const payload = {
            notification: {
                title: senderName,
                body: chatMessage,
                //badge: badgeCount.toString(),
                sound: "default",
                content_available: "true"
            }
        };

    //badgeCount++;
        return admin
     .database()
     .ref("fcmToken").child(receiverUid)
     .once("value")
     .then(allToken => {
       if (allToken.val()) {
         const token = Object.keys(allToken.val());
         console.log(`token? ${token}`);
         return admin
           .messaging()
           .sendToDevice(token, payload)
           .then(response => {
             return null;
           });
       }
       return null;
     });
 });
