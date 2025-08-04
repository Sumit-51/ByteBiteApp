//firebaseauth.cpp


#include "firebaseauth.h"
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonValue>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrlQuery>
#include <QUrl>
#include <QDebug>
#include <QUuid>
#include <QDateTime>
#include <QSslConfiguration>
#include <QStandardPaths>
#include <QSettings>

const QString FirebaseAuth::FIREBASE_AUTH_URL = "https://identitytoolkit.googleapis.com/v1/accounts";
const QString FirebaseAuth::FIREBASE_FIRESTORE_URL = "https://firestore.googleapis.com/v1/projects";

FirebaseAuth::FirebaseAuth(QObject *parent)
    : QObject(parent)
    , m_networkManager(new QNetworkAccessManager(this))
    , m_apiKey(qgetenv("FIREBASE_API_KEY").isEmpty() ? "AIzaSyBSfOQQPEIUDkh16EVPU9j9IGCdhEyx-lE" : qgetenv("FIREBASE_API_KEY"))
    , m_projectId(qgetenv("FIREBASE_PROJECT_ID").isEmpty() ? "bytebitelogin" : qgetenv("FIREBASE_PROJECT_ID"))
    , m_isReady(false)
    , m_isStudent(false)
    , m_userDisplayName("guest")
    , m_readyTimer(new QTimer(this))
{
    qDebug() << "🔥 FirebaseAuth initialized for Android";
    qDebug() << "📋 Project ID:" << m_projectId;
    qDebug() << "🔑 API Key:" << m_apiKey.left(20) + "...";

    setupNetworkManager();

    m_readyTimer->setSingleShot(true);
    m_readyTimer->setInterval(2000);
    connect(m_readyTimer, &QTimer::timeout, this, &FirebaseAuth::initializeReady);
    m_readyTimer->start();
}

void FirebaseAuth::setupNetworkManager()
{
    qDebug() << "🔍 Setting up network manager with SSL support";
    qDebug() << "🔒 SSL Support Available:" << QSslSocket::supportsSsl();

    if (!QSslSocket::supportsSsl()) {
        qDebug() << "❌ WARNING: SSL support not available - Firebase will fail";
        qDebug() << "🔧 SSL Library Build Version:" << QSslSocket::sslLibraryBuildVersionString();
        qDebug() << "🔑 SSL Library Runtime Version:" << QSslSocket::sslLibraryVersionString();
    } else {
        qDebug() << "✅ SSL support confirmed - Firebase should work";

        QSslConfiguration sslConfig = QSslConfiguration::defaultConfiguration();
        sslConfig.setProtocol(QSsl::TlsV1_2OrLater);
        sslConfig.setPeerVerifyMode(QSslSocket::VerifyPeer);
        sslConfig.setCaCertificates(QSslConfiguration::systemCaCertificates());

        QSslConfiguration::setDefaultConfiguration(sslConfig);
        qDebug() << "🔐 SSL configuration applied successfully";
    }

    qDebug() << "📡 Network manager configured for Android";
}

void FirebaseAuth::initializeReady()
{
    m_isReady = true;
    emit isReadyChanged();
    qDebug() << "🔥 Firebase ready for Android!";
}

void FirebaseAuth::updateUserStatus(const QString &email)
{
    if (email.endsWith(".ku.edu.np")) {
        m_isStudent = true;
        m_userDisplayName = "student";
        qDebug() << "👨‍🎓 User is a student:" << email;
    } else {
        m_isStudent = false;
        m_userDisplayName = "not student";
        qDebug() << "👤 User is not a student:" << email;
    }

    emit isStudentChanged();
    emit userDisplayNameChanged();
}

void FirebaseAuth::clearUserSession()
{
    m_idToken.clear();
    m_currentUserEmail.clear();
    m_isStudent = false;
    m_userDisplayName = "guest";

    emit currentUserEmailChanged();
    emit isStudentChanged();
    emit userDisplayNameChanged();
}

void FirebaseAuth::signUp(const QString &email, const QString &password)
{
    qDebug() << "🔥 Android SignUp requested for:" << email;

    QJsonObject data;
    data["email"] = email;
    data["password"] = password;
    data["returnSecureToken"] = true;

    makeAuthRequest("signUp", data, "signup");
}

void FirebaseAuth::login(const QString &email, const QString &password)
{
    qDebug() << "🔥 Android Login requested for:" << email;

    QJsonObject data;
    data["email"] = email;
    data["password"] = password;
    data["returnSecureToken"] = true;

    makeAuthRequest("signInWithPassword", data, "login");
}

void FirebaseAuth::logout()
{
    qDebug() << "🔥 Android Logout requested";
    clearUserSession();
}

void FirebaseAuth::sendPasswordReset(const QString &email)
{
    qDebug() << "🔑 Android Password reset requested for:" << email;

    QString trimmedEmail = email.trimmed().toLower();

    if (trimmedEmail.isEmpty()) {
        emit passwordResetSent(false, "Please enter your email address");
        return;
    }

    if (!trimmedEmail.contains("@") || !trimmedEmail.contains(".")) {
        emit passwordResetSent(false, "Please enter a valid email address");
        return;
    }

    QJsonObject data;
    data["email"] = trimmedEmail;
    data["requestType"] = "PASSWORD_RESET";

    makePasswordResetRequest(data);
}

void FirebaseAuth::sendEmailVerification()
{
    qDebug() << "📧 Android Email verification requested";

    if (m_idToken.isEmpty()) {
        emit emailVerificationSent(false, "No authentication token available");
        return;
    }

    QJsonObject data;
    data["idToken"] = m_idToken;
    data["requestType"] = "VERIFY_EMAIL";

    makeEmailVerificationRequest(data);
}

void FirebaseAuth::submitOrder(const QString &orderDataJson)
{
    qDebug() << "📦 Android Submitting order to Firestore...";

    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(orderDataJson.toUtf8(), &error);

    if (error.error != QJsonParseError::NoError) {
        qDebug() << "❌ JSON parse error:" << error.errorString();
        emit orderSubmitted(false, "Invalid order data format", "");
        return;
    }

    QJsonObject orderData = doc.object();
    QString orderId = generateOrderId();

    orderData["orderId"] = orderId;
    orderData["timestamp"] = QDateTime::currentDateTime().toString(Qt::ISODate);
    orderData["status"] = "pending";  // 🔥 FIXED: Changed from "confirmed" to "pending"
    orderData["user"] = m_userDisplayName;
    orderData["platform"] = "Android";
    orderData["isStudent"] = m_isStudent;

    makeFirestoreRequest(orderData, orderId);
}

void FirebaseAuth::makeAuthRequest(const QString &endpoint, const QJsonObject &data, const QString &requestType)
{
    QString url = QString("%1:%2?key=%3").arg(FIREBASE_AUTH_URL, endpoint, m_apiKey);

    QNetworkRequest request;
    request.setUrl(QUrl(url));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("User-Agent", "ByteBite-Android/1.0");
    request.setRawHeader("Accept", "application/json");

    QJsonDocument doc(data);
    QNetworkReply *reply = m_networkManager->post(request, doc.toJson());

    reply->setProperty("requestType", requestType);
    connect(reply, &QNetworkReply::finished, this, &FirebaseAuth::handleAuthReply);
}

void FirebaseAuth::makePasswordResetRequest(const QJsonObject &data)
{
    QString url = QString("%1:sendOobCode?key=%2").arg(FIREBASE_AUTH_URL, m_apiKey);

    QNetworkRequest request;
    request.setUrl(QUrl(url));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("User-Agent", "ByteBite-Android/1.0");
    request.setRawHeader("Accept", "application/json");

    QJsonDocument doc(data);
    QNetworkReply *reply = m_networkManager->post(request, doc.toJson());

    connect(reply, &QNetworkReply::finished, this, &FirebaseAuth::handlePasswordResetReply);
}

void FirebaseAuth::makeEmailVerificationRequest(const QJsonObject &data)
{
    QString url = QString("%1:sendOobCode?key=%2").arg(FIREBASE_AUTH_URL, m_apiKey);

    QNetworkRequest request;
    request.setUrl(QUrl(url));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("User-Agent", "ByteBite-Android/1.0");
    request.setRawHeader("Accept", "application/json");

    QJsonDocument doc(data);
    QNetworkReply *reply = m_networkManager->post(request, doc.toJson());

    connect(reply, &QNetworkReply::finished, this, &FirebaseAuth::handleEmailVerificationReply);
}

void FirebaseAuth::makeUserInfoRequest(const QString &idToken)
{
    QString url = QString("%1:lookup?key=%2").arg(FIREBASE_AUTH_URL, m_apiKey);

    QNetworkRequest request;
    request.setUrl(QUrl(url));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("User-Agent", "ByteBite-Android/1.0");

    QJsonObject data;
    data["idToken"] = idToken;

    QJsonDocument doc(data);
    QNetworkReply *reply = m_networkManager->post(request, doc.toJson());

    connect(reply, &QNetworkReply::finished, this, &FirebaseAuth::handleUserInfoReply);
}

void FirebaseAuth::makeFirestoreRequest(const QJsonObject &data, const QString &orderId)
{
    QString url = QString("%1/%2/databases/(default)/documents/orders?documentId=%3&key=%4")
    .arg(FIREBASE_FIRESTORE_URL, m_projectId, orderId, m_apiKey);

    QNetworkRequest request;
    request.setUrl(QUrl(url));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("User-Agent", "ByteBite-Android/1.0");
    request.setRawHeader("Accept", "application/json");

    if (!m_idToken.isEmpty()) {
        request.setRawHeader("Authorization", QString("Bearer %1").arg(m_idToken).toUtf8());
    }

    QJsonObject firestoreDoc;
    QJsonObject fields;

    auto it = data.constBegin();
    while (it != data.constEnd()) {
        QJsonObject fieldValue;

        if (it.value().isString()) {
            fieldValue["stringValue"] = it.value().toString();
        } else if (it.value().isDouble()) {
            fieldValue["integerValue"] = QString::number(it.value().toInt());
        } else if (it.value().isBool()) {
            fieldValue["booleanValue"] = it.value().toBool();
        } else if (it.value().isArray()) {
            QJsonObject arrayValue;
            QJsonArray valuesArray;

            QJsonArray items = it.value().toArray();
            for (int i = 0; i < items.size(); ++i) {
                const QJsonValue &item = items.at(i);
                if (item.isObject()) {
                    QJsonObject mapValue;
                    QJsonObject itemFields;

                    QJsonObject itemObj = item.toObject();
                    auto itemIt = itemObj.constBegin();
                    while (itemIt != itemObj.constEnd()) {
                        QJsonObject itemFieldValue;
                        if (itemIt.value().isString()) {
                            itemFieldValue["stringValue"] = itemIt.value().toString();
                        } else if (itemIt.value().isDouble()) {
                            itemFieldValue["integerValue"] = QString::number(itemIt.value().toInt());
                        }
                        itemFields[itemIt.key()] = itemFieldValue;
                        ++itemIt;
                    }

                    mapValue["mapValue"] = QJsonObject{{"fields", itemFields}};
                    valuesArray.append(mapValue);
                }
            }

            arrayValue["arrayValue"] = QJsonObject{{"values", valuesArray}};
            fieldValue = arrayValue;
        }

        fields[it.key()] = fieldValue;
        ++it;
    }

    firestoreDoc["fields"] = fields;

    QJsonDocument doc(firestoreDoc);
    QNetworkReply *reply = m_networkManager->post(request, doc.toJson());
    reply->setProperty("orderId", orderId);
    connect(reply, &QNetworkReply::finished, this, &FirebaseAuth::handleOrderSubmitReply);
}

void FirebaseAuth::handleAuthReply()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    QString requestType = reply->property("requestType").toString();
    QByteArray data = reply->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(data);
    QJsonObject obj = doc.object();

    bool success = (reply->error() == QNetworkReply::NoError);
    QString message;

    if (success) {
        if (requestType == "signup") {
            m_idToken = obj["idToken"].toString();
            m_currentUserEmail = obj["email"].toString();
            updateUserStatus(m_currentUserEmail);
            emit currentUserEmailChanged();
            message = "Account created successfully! Please check your email for verification.";
            emit signupResult(true, message);
        } else if (requestType == "login") {
            QString idToken = obj["idToken"].toString();
            QString email = obj["email"].toString();

            m_idToken = idToken;
            m_currentUserEmail = email;
            updateUserStatus(m_currentUserEmail);
            makeUserInfoRequest(idToken);
        }
    } else {
        QJsonObject error = obj["error"].toObject();
        QString errorMsg = error["message"].toString();

        if (errorMsg.contains("EMAIL_EXISTS")) {
            message = "Account already exists with this email. Try logging in instead!";
        } else if (errorMsg.contains("WEAK_PASSWORD")) {
            message = "Password too weak. Use at least 6 characters with letters and numbers.";
        } else if (errorMsg.contains("EMAIL_NOT_FOUND")) {
            message = "No account found with this email. Try signing up first!";
        } else if (errorMsg.contains("INVALID_PASSWORD")) {
            message = "Incorrect password. Please try again.";
        } else if (errorMsg.contains("TOO_MANY_ATTEMPTS_TRY_LATER")) {
            message = "Too many login attempts. Please wait a few minutes and try again.";
        } else {
            message = errorMsg.isEmpty() ? "Authentication failed. Please try again." : errorMsg;
        }

        if (requestType == "signup") {
            emit signupResult(false, message);
        } else if (requestType == "login") {
            emit loginResult(false, message);
        }
    }

    reply->deleteLater();
}

void FirebaseAuth::handleUserInfoReply()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    QByteArray data = reply->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(data);
    QJsonObject obj = doc.object();

    bool success = (reply->error() == QNetworkReply::NoError);

    if (success) {
        QJsonArray users = obj["users"].toArray();
        if (!users.isEmpty()) {
            QJsonObject user = users.first().toObject();
            bool emailVerified = user["emailVerified"].toBool();

            if (emailVerified) {
                emit currentUserEmailChanged();
                emit loginResult(true, "Login successful!");
            } else {
                clearUserSession();
                emit loginResult(false, "Please verify your email before logging in. Check your inbox for the verification link!");
            }
        } else {
            emit loginResult(false, "Failed to get user information. Please try again.");
        }
    } else {
        emit loginResult(false, "Failed to verify account status. Please try again.");
    }

    reply->deleteLater();
}

void FirebaseAuth::handlePasswordResetReply()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    QByteArray responseData = reply->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(responseData);
    QJsonObject obj = doc.object();

    bool success = (reply->error() == QNetworkReply::NoError);
    QString message;

    if (success) {
        message = "Password reset email sent successfully!\n\n📧 Please check:\n• Your Gmail inbox\n• Spam/Junk folder\n• Promotions tab\n\n⏰ Email may take 1-2 minutes to arrive.";
    } else {
        QJsonObject error = obj["error"].toObject();
        QString errorMsg = error["message"].toString();

        if (errorMsg.contains("EMAIL_NOT_FOUND")) {
            message = "❌ No account found with this email address.\nPlease check your email or sign up for a new account.";
        } else if (errorMsg.contains("INVALID_EMAIL")) {
            message = "❌ Invalid email address format.\nPlease enter a valid email address.";
        } else if (errorMsg.contains("TOO_MANY_ATTEMPTS_TRY_LATER")) {
            message = "⏳ Too many password reset attempts.\nPlease wait a few minutes before trying again.";
        } else {
            message = "❌ Failed to send password reset email.\nPlease try again.";
        }
    }

    emit passwordResetSent(success, message);
    reply->deleteLater();
}

void FirebaseAuth::handleEmailVerificationReply()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    bool success = (reply->error() == QNetworkReply::NoError);
    QString message;

    if (success) {
        message = "Verification email sent successfully!";
    } else {
        QByteArray data = reply->readAll();
        QJsonDocument doc = QJsonDocument::fromJson(data);
        QJsonObject obj = doc.object();
        QJsonObject error = obj["error"].toObject();

        message = error["message"].toString();
        if (message.isEmpty()) {
            message = "Failed to send verification email. Please try again.";
        }
    }

    emit emailVerificationSent(success, message);
    reply->deleteLater();
}

void FirebaseAuth::handleOrderSubmitReply()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    QString orderId = reply->property("orderId").toString();
    bool success = (reply->error() == QNetworkReply::NoError);
    QString message;

    if (success) {
        message = "Order submitted successfully!";
        emit orderSubmitted(true, message, orderId);
    } else {
        message = QString("Failed to submit order: %1").arg(reply->errorString());
        emit orderSubmitted(false, message, "");
    }

    reply->deleteLater();
}

QString FirebaseAuth::generateOrderId()
{
    QString timestamp = QString::number(QDateTime::currentMSecsSinceEpoch());
    QString uuid = QUuid::createUuid().toString(QUuid::WithoutBraces).left(8);
    return QString("ORDER_%1_%2").arg(timestamp, uuid);
}

void FirebaseAuth::fetchUserOrders()
{
    qDebug() << "📋 Fetching user orders...";

    QString userEmail = m_currentUserEmail;
    if (userEmail.isEmpty()) {
        emit userOrdersLoaded(false, "[]");
        return;
    }

    QString url = QString("%1/%2/databases/(default)/documents/orders?key=%3")
                      .arg(FIREBASE_FIRESTORE_URL, m_projectId, m_apiKey);

    QNetworkRequest request;
    request.setUrl(QUrl(url));
    request.setRawHeader("User-Agent", "ByteBite-Android/1.0");

    QNetworkReply *reply = m_networkManager->get(request);
    reply->setProperty("userEmail", userEmail);
    connect(reply, &QNetworkReply::finished, this, &FirebaseAuth::handleUserOrdersReply);
}

void FirebaseAuth::handleUserOrdersReply()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    QString userEmail = reply->property("userEmail").toString();
    QByteArray data = reply->readAll();

    if (reply->error() == QNetworkReply::NoError) {
        QJsonParseError parseError;
        QJsonDocument doc = QJsonDocument::fromJson(data, &parseError);

        if (parseError.error != QJsonParseError::NoError) {
            qDebug() << "❌ JSON Parse Error:" << parseError.errorString();
            emit userOrdersLoaded(false, "[]");
            reply->deleteLater();
            return;
        }

        QJsonObject obj = doc.object();
        QJsonArray documents = obj["documents"].toArray();
        QJsonArray userOrders;

        qDebug() << "📦 Processing" << documents.size() << "total orders";

        for (const QJsonValue &docValue : documents) {
            QJsonObject document = docValue.toObject();
            QJsonObject fields = document["fields"].toObject();

            QString orderUserEmail = fields.contains("userEmail") ?
                                         fields["userEmail"].toObject()["stringValue"].toString() : "";

            if (orderUserEmail == userEmail) {
                QJsonObject order;
                order["orderId"] = fields.contains("orderId") ?
                                       fields["orderId"].toObject()["stringValue"].toString() : "";
                order["status"] = fields.contains("status") ?
                                      fields["status"].toObject()["stringValue"].toString() : "pending";
                order["restaurant"] = fields.contains("restaurant") ?
                                          fields["restaurant"].toObject()["stringValue"].toString() : "";
                order["totalAmount"] = fields.contains("totalAmount") ?
                                           fields["totalAmount"].toObject()["integerValue"].toString().toInt() : 0;
                order["orderDate"] = fields.contains("orderDate") ?
                                         fields["orderDate"].toObject()["stringValue"].toString() : "";
                order["orderTime"] = fields.contains("orderTime") ?
                                         fields["orderTime"].toObject()["stringValue"].toString() : "";
                order["customerName"] = fields.contains("customerName") ?
                                            fields["customerName"].toObject()["stringValue"].toString() : "";

                userOrders.append(order);
            }
        }

        qDebug() << "✅ Found" << userOrders.size() << "orders for user:" << userEmail;

        QJsonDocument ordersDoc(userOrders);
        emit userOrdersLoaded(true, ordersDoc.toJson(QJsonDocument::Compact));
    } else {
        qDebug() << "❌ Failed to load orders:" << reply->errorString();
        emit userOrdersLoaded(false, "[]");
    }

    reply->deleteLater();
}

void FirebaseAuth::fetchMenuItems(const QString &restaurantName)
{
    qDebug() << "🍽️ Fetching menu for restaurant:" << restaurantName;

    QString url = QString("%1/%2/databases/(default)/documents/restaurants/%3/menu?key=%4")
                      .arg(FIREBASE_FIRESTORE_URL, m_projectId, restaurantName, m_apiKey);

    QNetworkRequest request;
    request.setUrl(QUrl(url));
    request.setRawHeader("User-Agent", "ByteBite-Android/1.0");

    QNetworkReply *reply = m_networkManager->get(request);
    reply->setProperty("restaurantName", restaurantName);
    connect(reply, &QNetworkReply::finished, this, &FirebaseAuth::handleMenuItemsReply);
}

void FirebaseAuth::handleMenuItemsReply()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    QString restaurantName = reply->property("restaurantName").toString();
    QByteArray data = reply->readAll();

    if (reply->error() == QNetworkReply::NoError) {
        QJsonParseError parseError;
        QJsonDocument doc = QJsonDocument::fromJson(data, &parseError);

        if (parseError.error != QJsonParseError::NoError) {
            qDebug() << "❌ JSON Parse Error:" << parseError.errorString();
            emit menuItemsLoaded(false, restaurantName, "[]");
            reply->deleteLater();
            return;
        }

        QJsonObject obj = doc.object();
        QJsonArray documents = obj["documents"].toArray();
        QJsonArray menuItems;

        for (const QJsonValue &docValue : documents) {
            QJsonObject document = docValue.toObject();
            QJsonObject fields = document["fields"].toObject();

            // Only include enabled items
            bool enabled = fields.contains("enabled") ?
                               fields["enabled"].toObject()["booleanValue"].toBool() : true;

            if (enabled) {
                QJsonObject item;
                item["id"] = fields.contains("id") ?
                                 fields["id"].toObject()["integerValue"].toString().toInt() : 0;
                item["name"] = fields.contains("name") ?
                                   fields["name"].toObject()["stringValue"].toString() : "";
                item["price"] = fields.contains("price") ?
                                    fields["price"].toObject()["integerValue"].toString().toInt() : 0;
                item["description"] = fields.contains("description") ?
                                          fields["description"].toObject()["stringValue"].toString() : "";
                item["image"] = fields.contains("image") ?
                                    fields["image"].toObject()["stringValue"].toString() : "🍽️";
                item["color"] = fields.contains("color") ?
                                    fields["color"].toObject()["stringValue"].toString() : "#3b82f6";

                menuItems.append(item);
            }
        }

        qDebug() << "✅ Loaded" << menuItems.size() << "enabled items for" << restaurantName;

        QJsonDocument menuDoc(menuItems);
        emit menuItemsLoaded(true, restaurantName, menuDoc.toJson(QJsonDocument::Compact));
    } else {
        qDebug() << "❌ Failed to load menu:" << reply->errorString();
        emit menuItemsLoaded(false, restaurantName, "[]");
    }

    reply->deleteLater();
}
