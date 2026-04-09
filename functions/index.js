const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendMonthlyExpenseNotification = functions.pubsub
  .schedule("59 23 28-31 * *") // মাসের শেষ দিন রাত 11:59 PM
  .timeZone("Asia/Dhaka")
  .onRun(async () => {

    const payload = {
      notification: {
        title: "মাসিক খরচ রিপোর্ট",
        body: "এই মাসে আপনার খরচ আগের মাসের তুলনায় বেড়েছে",
      },
    };

    await admin.messaging().sendToTopic(
      "monthly_expense",
      payload
    );

    return null;
  });
