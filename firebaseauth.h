#ifndef FIREBASEAUTH_H
#define FIREBASEAUTH_H

#include <QObject>
#include <QString>
#include <QQmlEngine>
#include <QJsonObject>
#include <QJsonDocument>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QTimer>
#include <QSslConfiguration>

class FirebaseAuth : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(bool isReady READ isReady NOTIFY isReadyChanged)
    Q_PROPERTY(QString currentUserEmail READ currentUserEmail NOTIFY currentUserEmailChanged)
    Q_PROPERTY(bool isStudent READ isStudent NOTIFY isStudentChanged)
    Q_PROPERTY(QString userDisplayName READ userDisplayName NOTIFY userDisplayNameChanged)

public:
    explicit FirebaseAuth(QObject *parent = nullptr);

    bool isReady() const { return m_isReady; }
    QString currentUserEmail() const { return m_currentUserEmail; }
    bool isStudent() const { return m_isStudent; }
    QString userDisplayName() const { return m_userDisplayName; }

    Q_INVOKABLE void signUp(const QString &email, const QString &password);
    Q_INVOKABLE void login(const QString &email, const QString &password);
    Q_INVOKABLE void sendPasswordReset(const QString &email);
    Q_INVOKABLE void sendEmailVerification();
    Q_INVOKABLE void submitOrder(const QString &orderDataJson);
    Q_INVOKABLE void logout();
    Q_INVOKABLE void fetchUserOrders();
    Q_INVOKABLE void fetchMenuItems(const QString &restaurantName);

signals:
    void signupResult(bool success, const QString &message);
    void loginResult(bool success, const QString &message);
    void passwordResetSent(bool success, const QString &message);
    void emailVerificationSent(bool success, const QString &message);
    void orderSubmitted(bool success, const QString &message, const QString &orderId);
    void userOrdersLoaded(bool success, const QString &ordersJson);
    void menuItemsLoaded(bool success, const QString &restaurantName, const QString &menuJson);
    void isReadyChanged();
    void currentUserEmailChanged();
    void isStudentChanged();
    void userDisplayNameChanged();

private slots:
    void handleAuthReply();
    void handlePasswordResetReply();
    void handleEmailVerificationReply();
    void handleUserInfoReply();
    void handleOrderSubmitReply();
    void handleUserOrdersReply();
    void handleMenuItemsReply();
    void initializeReady();

private:
    void makeAuthRequest(const QString &endpoint, const QJsonObject &data, const QString &requestType);
    void makePasswordResetRequest(const QJsonObject &data);
    void makeEmailVerificationRequest(const QJsonObject &data);
    void makeUserInfoRequest(const QString &idToken);
    void makeFirestoreRequest(const QJsonObject &data, const QString &orderId);
    QString generateOrderId();
    void setupNetworkManager();
    void updateUserStatus(const QString &email);
    void clearUserSession();

    QNetworkAccessManager *m_networkManager;
    QString m_apiKey;
    QString m_projectId;
    QString m_idToken;
    QString m_currentUserEmail;
    bool m_isReady;
    bool m_isStudent;
    QString m_userDisplayName;
    QTimer *m_readyTimer;

    static const QString FIREBASE_AUTH_URL;
    static const QString FIREBASE_FIRESTORE_URL;
};

#endif // FIREBASEAUTH_H
