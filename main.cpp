//main.cpp


#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QSslSocket>
#include <QQmlContext>
#include "firebaseauth.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    app.setApplicationName("ByteBite");
    app.setApplicationVersion("1.0");
    app.setOrganizationName("ByteBite-Team");

    qDebug() << "🚀 ByteBite Android Starting";

    // CRITICAL: Register FirebaseAuth BEFORE creating QML engine
    qmlRegisterType<FirebaseAuth>("FirebaseAuth", 1, 0, "FirebaseAuth");
    qDebug() << "✅ FirebaseAuth registered for QML";

    // Check SSL support
    qDebug() << "🔒 SSL Support Available:" << QSslSocket::supportsSsl();

    // Create QML engine AFTER registration
    QQmlApplicationEngine engine;
    engine.addImportPath("qrc:/");
    engine.addImportPath("qrc:/qt/qml/");

    const QUrl url(QStringLiteral("qrc:/qt/qml/quick/Main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, []() {
                         qDebug() << "❌ QML object creation failed";
                         QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);

    qDebug() << "🔄 Loading QML...";
    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        qDebug() << "❌ No root objects created";
        return -1;
    }

    qDebug() << "✅ App ready and working!";
    return app.exec();
}
